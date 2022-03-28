class CreateUsd < ActiveRecord::Migration[5.2]
  def change
    create_table :usds do |t|
      t.decimal :byn
      t.decimal :pln
      t.decimal :eur

      t.timestamps
    end
  end
end
