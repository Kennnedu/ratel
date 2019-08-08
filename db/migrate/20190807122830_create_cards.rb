class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.string :name
      t.integer :user_id

      t.timestamps
    end

    add_index :cards, :user_id
  end
end
