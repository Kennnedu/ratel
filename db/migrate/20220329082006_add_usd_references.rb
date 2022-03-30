class AddUsdReferences < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :usd_id, :integer
  end
end
