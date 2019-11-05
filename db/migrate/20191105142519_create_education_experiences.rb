class CreateEducationExperiences < ActiveRecord::Migration[6.0]
  def change
    create_table :education_experiences do |t|
      t.references :candidate
      t.datetime :started_at
      t.datetime :ended_at
      t.string :school
      t.string :major
      t.string :degree
      t.text :description

      t.timestamps :null => false
    end
  end
end
