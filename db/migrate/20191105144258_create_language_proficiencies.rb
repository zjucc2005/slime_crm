class CreateLanguageProficiencies < ActiveRecord::Migration[6.0]
  def change
    create_table :language_proficiencies do |t|
      t.references :candidate
      t.string :language
      t.string :level

      t.timestamps :null => false
    end
  end
end
