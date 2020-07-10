class CreateUserChannels < ActiveRecord::Migration[6.0]
  def change
    create_table :user_channels do |t|
      t.string :name

      t.timestamps :null => false
    end
  end
end
