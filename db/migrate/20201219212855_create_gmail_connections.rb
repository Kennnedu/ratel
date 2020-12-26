class CreateGmailConnections < ActiveRecord::Migration[5.2]
  def change
    create_table :gmail_connections do |t|
      t.belongs_to :user
      t.boolean :connected, default: false
      t.string :report_sender
      t.datetime :connected_at

      t.timestamps
    end 
  end
end
