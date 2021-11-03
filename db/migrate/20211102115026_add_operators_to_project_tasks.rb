class AddOperatorsToProjectTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :project_tasks, :billed_by, :bigint
    add_column :project_tasks, :charged_by, :bigint
    add_column :project_tasks, :paid_by, :bigint
  end
end
