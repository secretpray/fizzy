class ActionMcp::BaseController < ActionController::Base
  PROTOCOL_VERSION = "2024-11-05"
  SERVER_NAME = "#{Rails.application.name} MCP"
  SERVER_VERSION = "1.0.0"

  JSONRPC_ERROR_CODES = {
    parse_error: -32700,
    invalid_request: -32600,
    method_not_found: -32601,
    invalid_params: -32602,
    internal_error: -32603
  }

  skip_before_action :verify_authenticity_token

  def create
    result = dispatch_rpc_method
    render json: { jsonrpc: "2.0", result: result, id: params[:id] }
  rescue => e
    render json: { jsonrpc: "2.0", error: { code: -32603, message: e.message }, id: params[:id] }
  end

  def reject_sse
    head :method_not_allowed
  end

  private
    def rpc_params
      @rpc_params ||= (params[:params] || {}).deep_symbolize_keys
    end

    def dispatch_rpc_method
      case params[:method]
      when "initialize"
        initialize_handshake
      when "notifications/initialized"
        dismiss_initialize_notification
      when "tools/list"
        tool_list
      when "tools/call"
        tool_call(rpc_params["name"], rpc_params["arguments"] || {})
      else
        error_response("Method not found", -32601)
      end
    end

    def initialize_handshake
      {
        protocolVersion: PROTOCOL_VERSION,
        capabilities: { tools: {} },
        serverInfo: { name: SERVER_NAME, version: SERVER_VERSION }
      }
    end

    def dismiss_initialize_notification
      {}
    end

    def tool_classes
      ApplicationTool.descendants
    end

    def tool_list
      { "tools": tool_classes.collect { it.new.tool_bundle } }
    end

    def tool_call(tool_name, tool_arguments)
    end

    def rpc_success(result:)
      { jsonrpc: "2.0", id: rpc_id, result: result }
    end
end
