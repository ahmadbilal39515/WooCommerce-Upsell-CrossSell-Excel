class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :title
      t.string :price
      t.string :sku
      t.string :product_url
      t.references :category
      t.references :sub_category
      t.timestamps
    end
  end
end
