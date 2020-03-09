class CreateProjectTaskCosts < ActiveRecord::Migration[6.0]
  def change
    create_table :project_task_costs do |t|
      t.references :project_task
      t.string :category
      t.decimal :price, :precision => 10, :scale => 2
      t.string :currency
      t.string :memo
      t.string :payment_status
      t.jsonb :payment_info, :default => {}

      t.timestamps :null => false
    end
  end
end
