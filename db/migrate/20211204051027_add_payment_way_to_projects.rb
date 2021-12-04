class AddPaymentWayToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :payment_way, :string
    add_column :projects, :last_task_created_at, :datetime
  end
end
