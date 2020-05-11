class AddIsTopToCandidateComments < ActiveRecord::Migration[6.0]
  def change
    add_column :candidate_comments, :is_top, :boolean, :default => false
  end
end
