class CreateCandidates < ActiveRecord::Migration[6.0]
  def change
    create_table :candidates do |t|
      t.string :category
      t.string :data_source
      t.bigint :owner_id

      t.string :name_cn
      t.string :name_en
      t.string :city
      t.string :email
      t.string :email1
      t.string :phone
      t.string :phone1
      t.string :industry
      t.string :title
      t.datetime :date_of_birth
      t.string :gender
      t.text :description

      t.boolean :is_available
      t.decimal :cpt, :precision => 10, :scale => 2
      t.string :bank
      t.string :bank_card
      t.string :bank_user
      t.string :alipay_account
      t.string :alipay_user
      t.jsonb :property, :default => {}

      t.timestamps :null => false
    end
  end
end
