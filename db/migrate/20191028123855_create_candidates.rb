class CreateCandidates < ActiveRecord::Migration[6.0]
  def change
    create_table :candidates do |t|
      t.string :name_cn
      t.string :name_en
      t.string :avatar
      t.string :category
      t.string :source_channel
      t.string :input_method
      t.bigint :created_by
      t.bigint :owner_id

      t.string :email
      t.string :email1
      t.string :email2
      t.string :phone
      t.string :phone1
      t.string :phone2

      t.string :industry
      t.string :title
      t.decimal :annual_salary, :precision => 10, :scale => 2
      t.datetime :date_of_birth
      t.string :gender
      t.string :city
      t.string :address
      t.text :description
      t.jsonb :tags, :default => []
      t.string :linkedin

      t.string :interview_willingness
      t.decimal :expert_ratio, :precision => 10, :scale => 2
      t.string :bank
      t.string :bank_account
      t.string :bank_card_number
      t.jsonb :property, :default => {}

      t.timestamps :null => false
    end
  end
end
