class AddFileToProjectRequirements < ActiveRecord::Migration[6.0]
  def change
    add_column :project_requirements, :file, :string
  end
end
