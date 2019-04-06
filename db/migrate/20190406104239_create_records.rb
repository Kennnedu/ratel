class CreateRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :records do |t|
      t.string :name
      t.string :card
      t.float :amount
      t.float :rest
      t.datetime :performed_at

      t.timestamps
    end
  end
end
