class CreateProjectTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :project_tasks do |t|
      t.bigint :created_by
      t.string :category
      t.references :project
      t.bigint :expert_id
      t.bigint :client_id

      # 访谈相关
      t.string :status                                           # 访谈状态
      t.string :interview_form                                   # 访谈形式
      t.integer :duration                                        # 时长
      t.datetime :started_at                                     # 访谈开始时间
      t.datetime :ended_at                                       # 访谈结束时间

      # 收费相关
      t.string   :charge_status                                  # 收费状态
      t.datetime :billed_at                                      # 出账时间
      t.datetime :charged_at                                     # 收费时间
      t.integer  :charge_days                                    # 账期(天数)
      t.datetime :charge_deadline                                # 账期(截止日期)

      t.string :payment_status                                   # 成本支付状态
      t.datetime :paid_at                                        # 成本支付时间

      t.decimal :total_price,     :precision => 10, :scale => 2  # 总费用
      t.decimal :charge_rate,     :precision => 10, :scale => 2  # 收费倍率, 取值Contract#cpt
      t.decimal :base_price,      :precision => 10, :scale => 2  # 基础价格
      t.decimal :actual_price,    :precision => 10, :scale => 2  # 实际价格
      t.string :currency                                         # 币种
      t.boolean :is_taxed,        :default => false              # 是否含税
      t.decimal :tax,             :precision => 10, :scale => 2  # 税费, Contract规则计算得到
      t.boolean :is_shorthand,    :default => false              # 是否速记
      t.decimal :shorthand_price, :precision => 10, :scale => 2  # 税费, Contract规则计算得到
      t.boolean :is_recorded,     :default => false              # 是否录音

      t.timestamps :null => false
    end
  end
end
