class CreateCandidates < ActiveRecord::Migration[6.0]
  def change
    create_table :candidates do |t|
      t.string :category
      t.string :data_source
      t.bigint :created_by
      t.references :company

      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :nickname
      t.string :city
      t.string :email
      t.string :email1
      t.string :phone
      t.string :phone1
      t.string :industry
      t.datetime :date_of_birth
      t.string :gender
      t.text :description

      t.boolean :is_available
      t.decimal :cpt, :precision => 10, :scale => 2
      t.string :currency
      t.jsonb :property, :default => {}

      t.timestamps :null => false
    end
  end
end
