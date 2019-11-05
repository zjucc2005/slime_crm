class CreateProjectExperiences < ActiveRecord::Migration[6.0]
  def change
    create_table :project_experiences do |t|
      t.references :candidate
      t.datetime :started_at
      t.datetime :ended_at
      t.string :name
      t.string :title
      t.text :description

      t.timestamps :null => false
    end
  end
end
