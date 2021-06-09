class CreateRules < ActiveRecord::Migration[5.2]
  def change
    create_table :rules do |t|
      t.string :type
      t.string :name
      t.jsonb :condition
      t.belongs_to :user

      # depends on type
      t.belongs_to :tag
      t.belongs_to :card

      t.timestamps
    end
  end
end
