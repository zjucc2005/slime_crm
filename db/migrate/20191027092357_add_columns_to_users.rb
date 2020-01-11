class AddColumnsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :name_cn, :string
    add_column :users, :name_en, :string
    add_column :users, :role, :string
    add_column :users, :title, :string
    add_column :users, :status, :string
    add_column :users, :phone, :string
    add_column :users, :date_of_birth, :datetime
    add_column :users, :date_of_employment, :datetime
    add_column :users, :date_of_resignation, :datetime
    add_column :users, :candidate_access_limit, :integer
  end
end
