class CreateProductTags < ActiveRecord::Migration[7.1]
  def change
    create_table :product_tags do |t|
      t.string :name
      t.references :product
      t.timestamps
    end
  end
end
