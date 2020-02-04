class CreateCandidatePaymentInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :candidate_payment_infos do |t|
      t.references :candidate
      t.string :category
      t.bigint :created_by

      t.string :bank
      t.string :account
      t.string :username

      t.timestamps :null => false
    end
  end
end
