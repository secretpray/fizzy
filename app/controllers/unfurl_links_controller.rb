class UnfurlLinksController < ApplicationController
  rate_limit to: 50, within: 1.hour, by: -> { Current.user.id }

  def create
    link = Link.unfurl(url_param)

    if link.metadata
      render json: link.metadata
    else
      head :no_content
    end
  rescue Link::BasecampUnfurler::MissingIntegrationError
    render json: { error: :basecamp_integration_not_set_up }, status: :unprocessable_entity
  end

  private
    def url_param
      params.require(:url)
    end
end
