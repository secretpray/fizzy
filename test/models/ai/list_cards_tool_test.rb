require "test_helper"

class Ai::ListCardsToolTest < ActiveSupport::TestCase
  include McpHelper

  setup do
    @tool = Ai::ListCardsTool.new(user: users(:kevin))
  end

  test "execute" do
    response = @tool.execute
    page = parse_paginated_response(response)

    assert page[:records].is_a?(Array)
  end

  test "execute when ordering the result" do
    response = @tool.execute(ordered_by: "id ASC")
    page = parse_paginated_response(response)
    ids = page[:records].map { |card| card["id"] }

    assert_equal ids.sort, ids, "The IDs are sorted in ascending order"

    response = @tool.execute(ordered_by: "id DESC")
    page = parse_paginated_response(response)
    ids = page[:records].map { |card| card["id"] }

    assert_equal ids.sort.reverse, ids, "The IDs are sorted in descending order"

    assert_raises(ArgumentError) do
      @tool.execute(ordered_by: "created_at foobar")
    end
  end

  test "execute when filtering by ids" do
    creating_card = collections(:writebook).cards.create! creator: users(:kevin), status: :creating
    drafted_card = collections(:writebook).cards.create! creator: users(:kevin), status: :drafted

    cards = cards(:shipping, :logo)
    visible_card_ids = cards.pluck(:id)
    card_ids = visible_card_ids + [ creating_card.id, drafted_card.id ]

    response = @tool.execute(ids: card_ids.join(", "))
    page = parse_paginated_response(response)
    record_ids = page[:records].map { |card| card["id"].to_i }

    assert_equal visible_card_ids.count, record_ids.count
    assert_equal visible_card_ids.sort, record_ids.sort
  end

  test "execute when filtering by collection_ids" do
    collection = collections(:writebook)

    response = @tool.execute(collection_ids: collection.id.to_s)
    page = parse_paginated_response(response)

    assert page[:records].all? { |card| collection.id == card["collection_id"] }
    assert_nil page[:next_param]
  end

  test "execute when filtering by golden" do
    response = @tool.execute(golden: true)
    page = parse_paginated_response(response)

    assert page[:records].all? { |card| card["golden"] == true }
  end

  test "execute when filtering by created_at" do
    response = @tool.execute(created_after: 8.days.ago.to_s)
    page = parse_paginated_response(response)

    assert_not_empty page[:records], "There are cards created in the last 8 days"

    response = @tool.execute(created_after: 3.days.ago.to_s)
    page = parse_paginated_response(response)

    assert_empty page[:records], "There are no cards created in the last 3 days"

    response = @tool.execute(created_before: 3.days.ago.to_s)
    page = parse_paginated_response(response)

    assert_not_empty page[:records], "There are cards created more than 3 days ago"

    response = @tool.execute(created_before: 8.days.ago.to_s)
    page = parse_paginated_response(response)

    assert_empty page[:records], "There are no cards created more than 8 days ago"

    response = @tool.execute(created_before: 3.days.ago.to_s, created_after: 8.days.ago.to_s)
    page = parse_paginated_response(response)

    assert_not_empty page[:records], "There are cards created between 3 and 8 days ago"
  end

  test "execute when filtering by last_active_at" do
    response = @tool.execute(last_active_after: 8.days.ago.to_s)
    page = parse_paginated_response(response)

    assert_not_empty page[:records], "There are cards active in the last 8 days"

    response = @tool.execute(last_active_after: 3.days.ago.to_s)
    page = parse_paginated_response(response)

    assert_empty page[:records], "There are no cards active in the last 3 days"

    response = @tool.execute(last_active_before: 3.days.ago.to_s)
    page = parse_paginated_response(response)

    assert_not_empty page[:records], "There are cards active more than 3 days ago"

    response = @tool.execute(last_active_before: 8.days.ago.to_s)
    page = parse_paginated_response(response)

    assert_empty page[:records], "There are no cards active more than 8 days ago"

    response = @tool.execute(last_active_before: 3.days.ago.to_s, last_active_after: 8.days.ago.to_s)
    page = parse_paginated_response(response)

    assert_not_empty page[:records], "There are cards active between 3 and 8 days ago"
  end
end
