class AddReportIdToRecords < ActiveRecord::Migration[5.2]
  def change
    add_reference :records, :report, foreign_key: true
  end
end
