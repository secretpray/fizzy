#!/usr/bin/env ruby

require_relative "../config/environment"

WEEKS_TO_BACKFILL = 10

ActiveRecord::Base.logger = Logger.new(File::NULL)

ApplicationRecord.with_each_tenant do |tenant|
  WEEKS_TO_BACKFILL.times do |index|
    User.find_each do |user|
      user.generate_weekly_highlights(Time.current - index.weeks)
    end
  end
end
