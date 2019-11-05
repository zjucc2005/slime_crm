class CreateCandidateFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :candidate_files do |t|
      t.references :candidate
      t.string :category
      t.string :file

      t.timestamps :null => false
    end
  end
end