class DeleteUnusedTagsJob < ApplicationJob
  def perform
    ApplicationRecord.with_each_tenant do |tenant|
      Tag.unused.find_each do |tag|
        tag.destroy!
      end
    end
  end
end
