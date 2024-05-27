class CreateSubCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :sub_categories do |t|
      t.string :title
      t.references :category
      t.timestamps
    end
  end
end
