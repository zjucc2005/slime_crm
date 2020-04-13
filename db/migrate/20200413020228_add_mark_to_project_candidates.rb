class AddMarkToProjectCandidates < ActiveRecord::Migration[6.0]
  def change
    add_column :project_candidates, :mark, :string
  end
end
