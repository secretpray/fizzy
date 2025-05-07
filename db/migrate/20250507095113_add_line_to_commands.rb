class AddLineToCommands < ActiveRecord::Migration[8.1]
  def change
    add_column :commands, :line, :text
  end
end
