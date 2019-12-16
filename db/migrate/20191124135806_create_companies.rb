class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :category    # 公司类型
      t.bigint :created_by  # 数据创建者

      t.string :name        # 公司名
      t.string :name_abbr   # 公司简称
      t.string :tax_id      # 税号
      t.string :industry    # 行业
      t.string :city        # 城市
      t.string :address     # 地址
      t.string :phone       # 联系电话
      t.text :description   # 说明

      t.timestamps :null => false
    end
  end
end
