class CreateProjectTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :project_tasks do |t|
      t.bigint :created_by
      t.string :category

      t.references :project
      t.references :candidate
      t.string :status
      t.decimal :cpt, :precision => 10, :scale => 2
      t.decimal :fee, :precision => 10, :scale => 2
      t.integer :duration     # 时长
      t.datetime :started_at  # 访谈开始时间
      t.datetime :ended_at    # 访谈结束时间

      t.timestamps :null => false
    end
  end
end
