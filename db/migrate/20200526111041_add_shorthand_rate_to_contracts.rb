class AddShorthandRateToContracts < ActiveRecord::Migration[6.0]
  def change
    add_column :contracts, :shorthand_rate, :decimal, :precision => 10, :scale => 2
  end
end
