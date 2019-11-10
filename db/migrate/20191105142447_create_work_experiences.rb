class CreateWorkExperiences < ActiveRecord::Migration[6.0]
  def change
    create_table :work_experiences do |t|
      t.references :candidate
      t.datetime :started_at
      t.datetime :ended_at
      t.string :company_cn
      t.string :company_en
      t.string :title
      t.text :description

      t.timestamps :null => false
    end
  end
end
