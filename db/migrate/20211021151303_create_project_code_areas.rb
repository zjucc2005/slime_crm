class CreateProjectCodeAreas < ActiveRecord::Migration[6.0]
  def change
    create_table :project_code_areas do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
