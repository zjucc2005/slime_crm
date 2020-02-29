class CreateBanks < ActiveRecord::Migration[6.0]
  def change
    create_table :banks do |t|
      t.string :name

      t.timestamps :null => false
    end
  end
end
