class AddAllAccessToBucket < ActiveRecord::Migration[8.1]
  def change
    add_column :buckets, :all_access, :boolean, default: false, null: false
  end
end
