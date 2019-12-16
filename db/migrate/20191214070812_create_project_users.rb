class CreateProjectUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :project_users do |t|
      t.string :category
      t.references :project
      t.references :user

      t.timestamps :null => false
    end
  end
end
