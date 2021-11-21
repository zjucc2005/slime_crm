class AddSeqToCardTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :card_templates, :seq, :integer, default: 0
  end
end
