class AddCardIdToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :card_id, :integer
    remove_index :records, :card
    rename_column :records, :card, :card_name_old
    add_index :records, :card_id
  end
end
