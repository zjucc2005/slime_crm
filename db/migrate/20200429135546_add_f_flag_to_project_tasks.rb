class AddFFlagToProjectTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :project_tasks, :f_flag, :boolean, :default => false
  end
end
