class AddCompanyNameToProjectCodeAreas < ActiveRecord::Migration[6.0]
  def change
    add_column :project_code_areas, :company_name, :string
    add_column :project_code_areas, :address, :string
    add_column :project_code_areas, :email, :string
  end
end
