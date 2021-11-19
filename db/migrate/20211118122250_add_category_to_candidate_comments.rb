class AddCategoryToCandidateComments < ActiveRecord::Migration[6.0]
  def change
    add_column :candidate_comments, :category, :string
    add_column :candidate_comments, :is_active, :boolean, default: false
  end
end
