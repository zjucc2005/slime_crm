class AddDataChannelToCandidates < ActiveRecord::Migration[6.0]
  def change
    add_column :candidates, :data_channel, :string
  end
end
