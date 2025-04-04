class RemoveBubblesAutoPopAt < ActiveRecord::Migration[8.1]
  def change
    remove_column :bubbles, :auto_pop_at
  end
end
