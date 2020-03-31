class AddChargeDurationToProjectTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :project_tasks, :charge_duration, :integer
    add_column :project_tasks, :pm_id, :bigint
  end
end
