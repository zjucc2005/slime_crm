class AddExpertAliasToProjectTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :project_tasks, :expert_alias, :string
  end
end
