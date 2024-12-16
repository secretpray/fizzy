class BoostsController < ApplicationController
  include BubbleScoped, BucketScoped

  def create
    count = if params[:boost_count].to_i == @bubble.boosts_count
      @bubble.boosts_count + 1
    else
      params[:boost_count].to_i
    end
    @bubble.boost!(count)

    respond_to do |format|
      format.turbo_stream
    end
  end
end
