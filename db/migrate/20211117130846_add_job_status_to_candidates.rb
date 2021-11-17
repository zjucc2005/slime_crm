class AddJobStatusToCandidates < ActiveRecord::Migration[6.0]
  def change
    add_column :candidates, :job_status, :string
  end
end
