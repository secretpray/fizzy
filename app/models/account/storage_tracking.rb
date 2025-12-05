module Account::StorageTracking
  extend ActiveSupport::Concern

  def adjust_storage(delta)
    increment!(:bytes_used, delta)
  end

  def adjust_storage_later(delta)
    Account::AdjustStorageJob.perform_later(self, delta) unless delta.zero?
  end

  # This can be slow. Intended to be used from scripts/jobs.
  def recalculate_bytes_used
    update_columns bytes_used: count_bytes_used
  end

  private
    def count_bytes_used
      total_bytes = 0

      cards.with_rich_text_description_and_embeds.find_each do |card|
        total_bytes += card.bytes_used
        total_bytes += card.comments.with_rich_text_body_and_embeds.sum(&:bytes_used)
      end

      total_bytes
    end
end
