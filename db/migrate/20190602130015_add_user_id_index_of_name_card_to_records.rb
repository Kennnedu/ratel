class AddUserIdIndexOfNameCardToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :user_id, :integer
    add_index :records, :name
    add_index :records, :card
  end
end
