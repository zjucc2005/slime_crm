class CreateContracts < ActiveRecord::Migration[6.0]
  def change
    create_table :contracts do |t|
      t.bigint :created_by                            # 创建者
      t.references :company

      t.string :file                                  # 合同扫描件
      t.datetime :started_at                          # 合同开始时间
      t.datetime :ended_at                            # 合同到期时间

      t.decimal :rate, :precision => 10, :scale => 2  # 费率
      t.integer :min_bill_duration                    # 最小收费时长
      t.integer :follow_bill_duration                 # 跟进收费时长
      t.datetime :payment_time                        # 账期
      t.string :payment_way                           # 出账方式

      t.boolean :is_tax_included                      # 是否含税
      t.boolean :is_invoice_needed                    # 是否需要发票
      t.jsonb :financial_info                         # 财务信息

      t.timestamps :null => false
    end
  end
end
