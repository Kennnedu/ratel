class CreateRules < ActiveRecord::Migration[5.2]
  def change
    create_table :rules do |t|
      t.string :type
      t.string :name
      t.jsonb :condition
      t.belongs_to :user

      t.belongs_to :tag

      t.timestamps
    end
  end
end
