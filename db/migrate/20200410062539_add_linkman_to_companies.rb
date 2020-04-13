class AddLinkmanToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :linkman, :string
  end
end
