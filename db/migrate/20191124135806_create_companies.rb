class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :category
      t.bigint :owner_id

      t.string :name
      t.string :name_abbr
      t.string :industry
      t.string :city
      t.text :description
      t.bigint :bd_id
      t.datetime :bd_started_at
      t.datetime :bd_ended_at

      t.timestamps :null => false
    end
  end
end
