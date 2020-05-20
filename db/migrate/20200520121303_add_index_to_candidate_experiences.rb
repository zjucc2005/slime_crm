class AddIndexToCandidateExperiences < ActiveRecord::Migration[6.0]
  def change
    add_index :candidate_experiences, :org_cn
    add_index :candidate_experiences, :org_en
    add_index :candidate_experiences, :title
  end
end
