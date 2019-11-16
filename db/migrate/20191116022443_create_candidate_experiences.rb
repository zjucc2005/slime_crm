class CreateCandidateExperiences < ActiveRecord::Migration[6.0]
  def change
    create_table :candidate_experiences do |t|
      t.references :candidate
      t.string :category
      t.datetime :started_at
      t.datetime :ended_at
      t.string :org_cn
      t.string :org_en
      t.string :department
      t.string :title
      t.text :description

      t.timestamps :null => false
    end
  end
end
