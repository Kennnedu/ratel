class CreateTagsAndRecordsTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :name
      t.belongs_to :user

      t.timestamps
    end

    create_table :records_tags do |t|
      t.belongs_to :tag
      t.belongs_to :record

      t.timestamps
    end
  end
end
