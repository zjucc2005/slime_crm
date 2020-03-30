class AddExpertRateToProjectTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :project_tasks, :expert_level, :string
    add_column :project_tasks, :expert_rate,  :decimal, :precision => 10, :scale => 2
  end
end
