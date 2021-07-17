class AddCardTemplateIdToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :card_template_id, :bigint
  end
end
