class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.bigint :created_by          # 创建者
      t.references :company

      t.string :name                # 项目名称
      t.string :code                # 项目代码
      t.string :status              # 项目状态
      t.string :industry            # 行业
      t.datetime :started_at        # 项目启动时间
      t.datetime :ended_at          # 项目结束时间

      t.timestamps :null => false
    end
  end
end
