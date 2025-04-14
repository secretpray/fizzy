class NotificationsController < ApplicationController
  def index
    if @page&.first?
      @unread = Current.user.notifications.unread.ordered
    end

    set_page_and_extract_portion_from Current.user.notifications.read.ordered
  end

  def mark_read
    @notification = Current.user.notifications.find(params[:id])
    @notification.update!(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_back fallback_location: notifications_path }
      format.turbo_stream
    end
  end
end
