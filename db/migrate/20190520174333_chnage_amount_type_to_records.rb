class ChnageAmountTypeToRecords < ActiveRecord::Migration[5.2]
  def up
    change_column :records, :amount, :decimal
  end

  def down
    change_column :records, :amount, :float
  end
end
