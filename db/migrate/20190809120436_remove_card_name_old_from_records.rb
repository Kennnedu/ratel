class RemoveCardNameOldFromRecords < ActiveRecord::Migration[5.2]
  def change
    remove_column :records, :card_name_old, :string, default: ''
  end
end
