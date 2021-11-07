class AddPropertyToProjectTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :project_tasks, :property, :jsonb, default: {}
  end
end
