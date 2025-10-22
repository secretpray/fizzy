class ApplicationMailer < ActionMailer::Base
  default from: "The Boxcar team <support@37signals.com>"

  layout "mailer"
  append_view_path Rails.root.join("app/views/mailers")
  helper AvatarsHelper, HtmlHelper

  private
    def default_url_options
      super.merge(script_name: Account.sole.slug)
    end
end
