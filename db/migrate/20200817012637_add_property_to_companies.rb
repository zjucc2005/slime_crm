class AddPropertyToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :property, :jsonb, :default => {}
  end
end
