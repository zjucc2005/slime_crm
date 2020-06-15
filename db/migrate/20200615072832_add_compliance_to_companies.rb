class AddComplianceToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :compliance, :string
    add_column :companies, :compliance_file, :string
  end
end
