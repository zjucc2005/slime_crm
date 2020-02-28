class CreateCandidateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :candidate_comments do |t|
      t.bigint :created_by
      t.references :candidate
      t.text :content

      t.timestamps :null => false
    end
  end
end
