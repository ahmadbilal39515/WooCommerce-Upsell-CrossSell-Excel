class ProductExportService
  def self.to_csv(products)
    upsells_map = precompute_upsells(products)
    cross_sells_map = precompute_cross_sells(products)

    CSV.generate(headers: true) do |csv|
      csv << ["Product Title", "Product SKU", "Product Price", 
              "UpSell_1 Product Title", "UpSell_1 Product SKU", "UpSell_1 Product Price",
              "UpSell_2 Product Title", "UpSell_2 Product SKU", "UpSell_2 Product Price",
              "UpSell_3 Product Title", "UpSell_3 Product SKU", "UpSell_3 Product Price",
              "CrossSell_1 Product Title", "CrossSell_1 Product SKU", "CrossSell_1 Product Price",
              "CrossSell_2 Product Title", "CrossSell_2 Product SKU", "CrossSell_2 Product Price",
              "CrossSell_3 Product Title", "CrossSell_3 Product SKU", "CrossSell_3 Product Price"]
        random_products = products.order("RANDOM()").limit(500)
        random_products.limit(1000).each do |product|
          upsells = upsells_map[product.id] || []
          cross_sells = cross_sells_map[product.id] || []
  
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

  def self.precompute_upsells(products)
    upsells_map = Hash.new { |hash, key| hash[key] = [] }
    
    products.group_by { |p| p.sub_category_id }.each do |sub_category_id, grouped_products|
      grouped_products.combination(2).each do |product1, product2|
        next if product1.id == product2.id
        upsells_map[product1.id] << product2 if product1.sub_category_id == product2.sub_category_id
        upsells_map[product2.id] << product1 if product1.sub_category_id == product2.sub_category_id
      end
    end

    upsells_map.each { |key, value| upsells_map[key] = value.sample(3) }
    upsells_map
  end

  def self.precompute_cross_sells(products)
    cross_sells_map = Hash.new { |hash, key| hash[key] = [] }

    products.group_by { |p| p.sub_category.category_id }.each do |category_id, grouped_products|
      grouped_products.combination(2).each do |product1, product2|
        next if product1.id == product2.id
        unless product1.sub_category.category_id == product2.sub_category.category_id
          cross_sells_map[product1.id] << product2
          cross_sells_map[product2.id] << product1
        end
      end
    end

    cross_sells_map.each { |key, value| cross_sells_map[key] = value.sample(3) }
    cross_sells_map
  end
end