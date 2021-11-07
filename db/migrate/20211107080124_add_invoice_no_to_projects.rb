class AddInvoiceNoToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :invoice_no, :string
    add_column :projects, :invoice_issue_date, :datetime
  end
end
