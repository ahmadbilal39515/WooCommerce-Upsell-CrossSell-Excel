require 'watir'

task :new_up_cross_sell_products => :environment do
  options = ['--disable-infobars', '--disable-extensions', '--disable-gpu', '--no-sandbox', '--disable-dev-shm-usage', '--headless', '--disable-blink-features=AutomationControlled', '--disable-images', '--disable-css']

  browser = Watir::Browser.new :chrome, options: { args: options }
  raise Exception.new "Browser error" unless browser.present?
  base_url = "https://www.thejewelryvine.com"
  last_page_url = "https://www.thejewelryvine.com/product-category/childrens-jewelry-collections/disney-childrens-jewelry/"
  last_url_record = ""
  pages_array = []
  cleaned_last_url = ""
  sub_category = ""
  attempts = 0

  begin
    if LastPageUrl.any?
      last_url = LastPageUrl.last&.url
      cleaned_last_url = last_url&.include?('/page/') ? last_url.split('page/').first : last_url
      LastPageUrl.delete_all if cleaned_last_url == last_page_url
    end

    browser.goto base_url
    pages = browser.elements(xpath: "//li[contains(@class, 'menu-item') and contains(@class, 'menu-item-type-taxonomy') and contains(@class, 'menu-item-object-product_cat') and not(contains(@class, 'menu-item-design-default')) and not(contains(@class, 'has-dropdown')) and not(contains(@class, 'nav-dropdown-col'))]")

    pages.each do |page|
      page_url = page.a.href
      pages_array << page_url
      last_url_record = page_url if page_url == cleaned_last_url
    end

    start_url = last_url_record.presence || pages_array.first
    start_index = pages_array.index(start_url) || 0
    category_pages = pages_array[start_index..-1]

    category_pages.each do |page|
      category_data = page.split('.com')[1].split('/')
      category = category_data[3] ? Category.find_or_create_by(title: category_data[2]) : SubCategory.find_or_create_by(title: category_data[2])
      sub_category = category_data[3] ? category.sub_categories.find_or_create_by(title: category_data[3]) : category

      last_page_number = 1
      if LastPageUrl.any?
        last_url = LastPageUrl.last&.url
        last_page_number = last_url.split('page/').second.to_i if last_url&.include?('/page/')
        browser.goto last_url || page
        LastPageUrl.delete_all
      else
        browser.goto page
      end

      products_pagination = browser.element(xpath: "/html/body/div[2]/main/div/div[1]/div/nav/ul")
      products = browser.elements(xpath: "//*[contains(@class, 'name') and contains(@class, 'product-title') and contains(@class, 'woocommerce-loop-product__title')]")

      if products_pagination.lis.present?
        second_last_li = products_pagination.lis[-2]
        products_page_count = second_last_li.a.text.to_i + 1

        (last_page_number...products_page_count).each do |page_number|
          last_url_record = "#{page}page/#{page_number}"
          LastPageUrl.create!(url: last_url_record)
          puts "==================#{last_url_record}================"
          puts "=================================="
          create_product(browser, products, sub_category)
          puts "=================================="
          puts "================== page end ============"
          next_url = "#{page}page/#{page_number + 1}"
          browser.goto next_url
          GC.start  # Force garbage collection after each iteration
        end
      else
        create_product(browser, products, sub_category)
      end

      break if page == last_page_url
    end

  rescue StandardError => e
    attempts += 1
    puts "Error encountered: #{e.message}. Attempt #{attempts} of 5."
    sleep 5
    retry if attempts < 5
  ensure
    LastPageUrl.create!(url: last_url_record) unless last_url_record.nil?
    browser.close
  end

  puts "=============script end==================="
end

def create_product(browser, products, sub_category)
  products.each do |product|
    product_url = product.a.href
    next if sub_category.products.exists?(product_url: product_url)

    browser.goto product_url
    next unless browser.element(xpath: "//h1[contains(@class, 'product-title') and contains(@class, 'product_title') and contains(@class, 'entry-title')]").present?

    product_sku = browser.element(xpath: "//span[contains(@class, 'sku_wrapper')]").span.text
    product_title = browser.element(xpath: "//h1[contains(@class, 'product-title') and contains(@class, 'product_title') and contains(@class, 'entry-title')]").text
    product_price = browser.input(xpath: "//input[@type='hidden' and contains(@class, 'product-options-product-price')]").value

    sub_category.products.create(title: product_title, price: product_price, sku: product_sku, product_url: product_url)
    puts " =================#{product_title}==========#{product_price}=============#{product_sku}"
  end
end
