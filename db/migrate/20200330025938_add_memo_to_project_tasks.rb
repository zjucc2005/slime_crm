class AddMemoToProjectTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :project_tasks, :memo, :string
  end
end
