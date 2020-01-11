class CreateCandidateAccessLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :candidate_access_logs do |t|
      t.references :user
      t.references :candidate

      t.timestamps :null => false
    end
  end
end
