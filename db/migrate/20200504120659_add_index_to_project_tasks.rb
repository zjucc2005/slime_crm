class AddIndexToProjectTasks < ActiveRecord::Migration[6.0]
  def change
    add_index :project_tasks, :expert_id
    add_index :project_tasks, :client_id
  end
end
