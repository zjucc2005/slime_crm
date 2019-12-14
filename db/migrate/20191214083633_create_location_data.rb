class CreateLocationData < ActiveRecord::Migration[6.0]
  def change
    create_table :location_data do |t|
      t.string :name       # 区划名称
      t.string :code       # 国家编码/中国地区编码（身份证前6位）
      t.integer :level     # 区划层级
      t.bigint :parent_id  # 上级区划

      t.timestamps :null => false
    end
  end
end
