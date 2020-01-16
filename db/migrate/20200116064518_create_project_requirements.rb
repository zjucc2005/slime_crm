class CreateProjectRequirements < ActiveRecord::Migration[6.0]
  def change
    create_table :project_requirements do |t|
      t.bigint :created_by
      t.references :project
      t.string :status
      t.text :content

      t.timestamps :null => false
    end
  end
end
