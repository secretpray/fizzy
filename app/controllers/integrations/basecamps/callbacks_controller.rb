class Integrations::Basecamps::CallbacksController < ApplicationController
  skip_before_action :require_tenant
  allow_unauthenticated_access

  def show
    Integration::Basecamp.set_up_later(code: params[:code], state: params[:state])
  end
end
