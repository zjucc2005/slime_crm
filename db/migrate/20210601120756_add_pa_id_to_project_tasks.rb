class AddPaIdToProjectTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :project_tasks, :pa_id, :bigint
  end
end
