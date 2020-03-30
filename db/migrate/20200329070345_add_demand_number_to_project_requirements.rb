class AddDemandNumberToProjectRequirements < ActiveRecord::Migration[6.0]
  def change
    add_column :project_requirements, :demand_number, :integer
  end
end
