class CreateContracts < ActiveRecord::Migration[6.0]
  def change
    create_table :contracts do |t|
      t.bigint :owner_id
      t.references :company
      t.string :file
      t.string :company_name
      t.string :tax_id
      t.string :address
      t.string :phone
      t.boolean :is_tax_included
      t.boolean :is_invoice_needed
      t.string :bank
      t.string :bank_user
      t.string :client_finance_info

      t.timestamps :null => false
    end
  end
end
