class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.belongs_to :user
      t.integer :status, default: 0
      t.string :error_message
      t.jsonb :document_data

      t.timestamps
    end 
  end
end
