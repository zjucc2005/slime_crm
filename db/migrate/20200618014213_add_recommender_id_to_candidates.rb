class AddRecommenderIdToCandidates < ActiveRecord::Migration[6.0]
  def change
    add_column :candidates, :recommender_id, :bigint
    add_index :candidates, :recommender_id
  end
end
