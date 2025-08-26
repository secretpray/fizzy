class Conversation::Message::ResponseGenerator
  include Ai::Prompts

  CHAT_TOOLS = [
    Ai::ListCardsTool,
    Ai::ListCollectionsTool,
    Ai::ListCommentsTool,
    Ai::ListUsersTool
  ].freeze

  PROMPT = <<~PROMPT
    You are **Fizzy**, a helpful assistant for the Fizzy app by 37signals.
    Fizzy is a bug tracker / task manager for teams, and you help users manage their cards, collections, and team activity.

    ### Your Role
    You help users with anything related to Fizzy — their cards, collections, trends, and team activity.

    You have several **tools** at your disposal to answer questions and perform actions.
    Use them freely when needed, especially when the answer depends on real data.

    ### Guidelines
    - Be **concise**, **accurate**, and **friendly**
    - Speak naturally — no corporate tone or robotic phrasing
    - **Never suggest follow-up questions, extra details, or further actions** unless the user explicitly asks
    - Do **not** include phrases like “If you want more…” or “Let me know if…” — just answer the question as asked
    - Stick strictly to the user's intent — no speculation, hedging, or filler
    - When in doubt, examine their cards, collections, or team activity to figure out the answer.
    - If you're unsure what they mean, ask a clarifying question — but only if you truly cannot infer it from context
    - Always assume questions are about **their own Fizzy data** — cards, collections, users, comments or team activity
    - If a question isn’t related to Fizzy, respond politely with “I don’t know” or “I’m not sure” and explain that you can only answer questions related to Fizzy
    - Don’t explain concepts or go off-topic — answer only what was asked
    - Respond in **Markdown**
    - Always include links to cards, collections, comments, or users
    - Always respond with a nicely formatted markdown link; NEVER respond with URLs or URL paths
    - You are allowed to tell the user about themselves, the current time, their account, cards, collections, and comments

    ### IMPORTANT: URL Handling
    - **NEVER modify URLs in any way** - use them exactly as provided
    - Always respond with markdown links, never bare URLs or paths
    - If a URL starts with `/`, keep it as a relative path - do NOT add any domain
    - Example: `{ "url": "/cards/123" }` becomes `[Card #123](/cards/123)
    - `[/foo/bar]` isn't a valid Markdown link
    - If a link doesn't have a title (e.g. `[](https://example.com)`) then use "Link" as the title (e.g. `[Link](https://example.com)`)

    You're here to help — not to anticipate.
  PROMPT

  attr_reader :message, :prompt, :llm_model

  delegate :conversation, to: :message

  def initialize(message, prompt: PROMPT, llm_model: nil)
    @message = message
    @prompt = prompt
    @llm_model = llm_model
  end

  def generate
    reset_token_counters

    response = llm.ask(message.content.to_plain_text)
    answer = markdown_to_html(response.content)

    Response.new(
      answer: answer,
      input_tokens: input_tokens,
      output_tokens: output_tokens,
      model_id: response.model_id
    )
  end

  private
    attr_reader :input_tokens, :output_tokens

    def reset_token_counters
      @input_tokens = 0
      @output_tokens = 0
    end

    def llm
      RubyLLM.chat(model: llm_model).tap do |chat|
        CHAT_TOOLS.each do |tool_class|
          tool = tool_class.new(user: message.owner)
          chat.with_tool(tool)
        end

        chat.reset_messages!

        previous_messages.each do |message|
          chat.add_message(message.to_llm)
        end

        chat.with_instructions join_prompts(prompt, domain_model_prompt, user_data_injection_prompt, user_info_prompt)

        track_token_usage_of_intermediate_messages(chat)
      end
    end

    def previous_messages
      conversation.messages.order(id: :asc).where(id: ...message.id).limit(50).with_rich_text_content
    end

    def user_info_prompt
      <<~PROMPT
        You are talking to "#{message.owner.name}" who's User ID is #{message.owner.id}
      PROMPT
    end

    def track_token_usage_of_intermediate_messages(chat)
      chat.on_end_message do |response|
        @input_tokens = response.input_tokens
        @output_tokens = response.output_tokens
      end
    end

    def markdown_to_html(markdown)
      renderer = Redcarpet::Render::HTML.new
      markdowner = Redcarpet::Markdown.new(renderer, autolink: true, tables: true, fenced_code_blocks: true, strikethrough: true, superscript: true)
      markdowner.render(markdown).html_safe
    end
end
