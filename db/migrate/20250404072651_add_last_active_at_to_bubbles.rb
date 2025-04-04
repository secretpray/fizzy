class AddLastActiveAtToBubbles < ActiveRecord::Migration[8.1]
  def change
    add_column :bubbles, :last_active_at, :datetime
    add_index :bubbles, %i[ last_active_at status ]

    execute <<~SQL
      update bubbles
        set last_active_at = activity.last_active_at
        from (
          select bubbles.id as bubble_id, coalesce(max(events.created_at), bubbles.created_at) as last_active_at
          from bubbles
            left join events on bubbles.id = events.bubble_id group by bubbles.id
        ) as activity
        where bubbles.id = activity.bubble_id
    SQL

    change_column_null :bubbles, :last_active_at, false
  end
end
