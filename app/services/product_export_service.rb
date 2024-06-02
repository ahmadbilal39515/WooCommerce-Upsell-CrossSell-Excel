
class ProductExportService
  def self.to_csv(products)
    CSV.generate(headers: true) do |csv|
      csv << ["Product Title", "Product SKU", "Product Price", 
              "UpSell_1 Product Title", "UpSell_1 Product SKU", "UpSell_1 Product Price",
              "UpSell_2 Product Title", "UpSell_2 Product SKU", "UpSell_2 Product Price",
              "UpSell_3 Product Title", "UpSell_3 Product SKU", "UpSell_3 Product Price",
              "CrossSell_1 Product Title", "CrossSell_1 Product SKU", "CrossSell_1 Product Price",
              "CrossSell_2 Product Title", "CrossSell_2 Product SKU", "CrossSell_2 Product Price",
              "CrossSell_3 Product Title", "CrossSell_3 Product SKU", "CrossSell_3 Product Price"]

      products.each do |product|
        upsells = find_upsells(product, products)
        cross_sells = find_cross_sells(product, products)

        csv << [
          product.title, product.sku, product.price,
          upsells[0]&.title, upsells[0]&.sku, upsells[0]&.price,
          upsells[1]&.title, upsells[1]&.sku, upsells[1]&.price,
          upsells[2]&.title, upsells[2]&.sku, upsells[2]&.price,
          cross_sells[0]&.title, cross_sells[0]&.sku, cross_sells[0]&.price,
          cross_sells[1]&.title, cross_sells[1]&.sku, cross_sells[1]&.price,
          cross_sells[2]&.title, cross_sells[2]&.sku, cross_sells[2]&.price
        ]
      end
    end
  end

  def self.find_upsells(product, products)
    return [] unless product.sub_category
    category_id = product.sub_category.category&.id
  
    if category_id
      filtered_products = products.select do |p|
        p.sub_category.category_id == category_id &&
        p.sub_category_id == product.sub_category_id &&
        p.id != product.id
      end
    else
      filtered_products = products.select do |p|
        p.sub_category_id == product.sub_category_id &&
        p.id != product.id
      end
    end
  
    filtered_products.sample(3)
  end

  def self.find_cross_sells(product, products)
    return [] unless product.sub_category
    category_id = product.sub_category.category&.id
  
    if category_id
      filtered_products = products.select do |p|
        p.sub_category.category_id != category_id &&
        p.sub_category_id != product.sub_category_id &&
        p.id != product.id
      end
    else
      filtered_products = products.select do |p|
        p.sub_category_id != product.sub_category_id &&
        p.id != product.id
      end
    end
  
    filtered_products.sample(3)
  end
end