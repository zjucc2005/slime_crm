class CreateContracts < ActiveRecord::Migration[6.0]
  def change
    create_table :contracts do |t|
      t.bigint :created_by                               # 创建者
      t.references :company

      t.string :file                                     # 合同扫描件
      t.datetime :started_at                             # 合同开始时间
      t.datetime :ended_at                               # 合同到期时间

      t.decimal :cpt, :precision => 10, :scale => 2      # 费率
      t.string :currency                                 # 币种
      t.string :base_duration                            # 基本收费时长
      t.integer :progressive_duration                    # 递进收费时长
      t.integer :payment_days                            # 账期
      t.string :type_of_payment_day                      # (自然日/工作日)
      t.string :payment_way                              # 出账方式(月结/项目结)

      t.boolean :is_tax_included                         # 是否含税
      t.decimal :tax_rate, :precision => 6, :scale => 5  # 税率
      t.boolean :is_invoice_needed                       # 是否需要发票
      t.jsonb :financial_info, :default => {}            # 财务信息

      t.timestamps :null => false
    end
  end
end
