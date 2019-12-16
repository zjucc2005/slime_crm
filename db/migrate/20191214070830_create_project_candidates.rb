class CreateProjectCandidates < ActiveRecord::Migration[6.0]
  def change
    create_table :project_candidates do |t|
      t.string :category
      t.references :project
      t.references :candidate

      t.timestamps :null => false
    end
  end
end