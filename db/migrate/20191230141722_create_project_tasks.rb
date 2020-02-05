class CreateProjectTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :project_tasks do |t|
      t.bigint :created_by
      t.string :category
      t.references :project
      t.references :candidate
      t.string :status

      t.decimal :charge_rate,  :precision => 8,  :scale => 4  # 收费倍率, 类似折扣
      t.decimal :base_price,   :precision => 10, :scale => 2  # 基础价格
      t.decimal :actual_price, :precision => 10, :scale => 2  # 实际价格 = 基础价格 * 收费倍率

      t.string :interview_form  # 访谈形式
      t.integer :duration       # 时长
      t.datetime :started_at    # 访谈开始时间
      t.datetime :ended_at      # 访谈结束时间
      t.decimal :cost, :precision => 10, :scale => 2  # 成本, 即支付给专家的费用
      t.string :payment_method  # 成本支付方式
      t.jsonb :payment_info, :default => {}  # 支付信息(快照信息)
      t.string :charge_status   # 收费状态
      t.string :payment_status  # 成本支付状态

      t.timestamps :null => false
    end
  end
end
