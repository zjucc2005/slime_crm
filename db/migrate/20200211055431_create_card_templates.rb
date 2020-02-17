class CreateCardTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :card_templates do |t|
      t.string :category
      t.string :name
      t.text :content

      t.timestamps :null => false
    end
  end
end
