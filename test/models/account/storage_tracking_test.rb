require "test_helper"

class Account::StorageTrackingTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
    @account = Current.account
    @account.update!(bytes_used: 0)
  end

  test "track storage deltas" do
    @account.adjust_storage(1000)
    assert_equal 1000, @account.reload.bytes_used

    @account.adjust_storage(-100)
    assert_equal 900, @account.reload.bytes_used
  end

  test "track storage deltas in jobs" do
    assert_enqueued_with(job: Account::AdjustStorageJob, args: [ @account, 1000 ]) do
      @account.adjust_storage_later(1000)
    end

    assert_no_enqueued_jobs only: Account::AdjustStorageJob do
      @account.adjust_storage_later(0)
    end
  end

  test "recalculate bytes used from cards and comments" do
    board = @account.boards.first
    card = board.cards.create!(title: "Test", description: attachment_html(active_storage_blobs(:hello_txt)), status: :published)
    card.comments.create!(body: attachment_html(active_storage_blobs(:hello_txt)))
    card.comments.create!(body: attachment_html(active_storage_blobs(:list_pdf)))

    @account.recalculate_bytes_used

    expected_bytes = active_storage_blobs(:hello_txt).byte_size * 2 + active_storage_blobs(:list_pdf).byte_size
    assert_equal expected_bytes, @account.bytes_used
  end
end
