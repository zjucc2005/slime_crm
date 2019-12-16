class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.bigint :created_by          # 创建者
      t.references :company

      t.string :name                # 项目名称
      t.string :code                # 项目代码
      t.text :requirement           # 项目需求
      t.string :industry            # 行业

      t.timestamps :null => false
    end
  end
end
