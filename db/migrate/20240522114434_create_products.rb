class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :title
      t.string :price
      t.string :sku
      t.timestamps
    end
  end
end
