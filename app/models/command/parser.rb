class Command::Parser
  attr_reader :context

  delegate :user, :cards, :filter, to: :context

  def initialize(context)
    @context = context
  end

  def parse(string)
    parse_command(string).tap do |command|
      command&.line = string
    end
  end

  private
    def parse_command(string)
      command_name, *command_arguments = string.strip.split(" ")

      case command_name
        when "/assign", "/assignto"
          Command::Assign.new(assignee_ids: assignees_from(command_arguments).collect(&:id), card_ids: cards.ids)
        when "/close"
          Command::Close.new(card_ids: cards.ids, reason: command_arguments.join(" "))
        when /^@/
          Command::GoToUser.new(user_id: assignee_from(command_name)&.id)
        else
          parse_free_string(string)
      end
    end

  private
    def assignees_from(strings)
      Array(strings).filter_map do |string|
        assignee_from(string)
      end
    end

    # TODO: This is temporary as it can be ambiguous. We should inject the user ID in the command
    #   under the hood instead, as determined by the user picker. E.g: @1234.
    def assignee_from(string)
      string_without_at = string.delete_prefix("@")
      User.all.find { |user| user.mentionable_handles.include?(string_without_at) }
    end

    def parse_free_string(string)
      if cards = multiple_cards_from(string)
        Command::FilterCards.new(card_ids: cards.ids, params: filter.as_params)
      elsif card = single_card_from(string)
        Command::GoToCard.new(card_id: card.id)
      else
        Command::Search.new(query: string, params: filter.as_params)
      end
    end

    def multiple_cards_from(string)
      if tokens = string.split(/[\s,]+/).filter { it =~ /\A\d+\z/ }.presence
        if tokens.many?
          cards = user.accessible_cards.where(id: tokens)
          cards.any? ? cards : nil
        end
      end
    end

    def single_card_from(string)
      user.accessible_cards.find_by_id(string)
    end
end
