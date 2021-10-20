class AddCodeAreaToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :code_area, :string
  end
end
