require 'watir'

task :up_cross_sell_products => :environment do

  options = [ '--disable-infobars', '--disable-extensions', '--disable-gpu','--no-sandbox','--disable-dev-shm-usage','--headless', '--disable-blink-features=AutomationControlled', '--disable-images','--disable-css']

  browser = Watir::Browser.new :chrome, options: { args: options }
  raise Exception.new "Browser error" if !browser.present?
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
      if last_url&.include?('/page/')
        url_data = LastPageUrl.last&.url.split('page/')
        cleaned_last_url = url_data.first
      else
        cleaned_last_url = LastPageUrl.last&.url
      end
      if cleaned_last_url == last_page_url
        LastPageUrl.delete_all
      end
    end
    browser.goto "#{base_url}"
    pages = browser.elements(xpath: "//li[contains(@class, 'menu-item') and contains(@class, 'menu-item-type-taxonomy') and contains(@class, 'menu-item-object-product_cat') and not(contains(@class, 'menu-item-design-default')) and not(contains(@class, 'has-dropdown')) and not(contains(@class, 'nav-dropdown-col'))]")
    
    pages.each do |page|
      page_url = page.a.href
      pages_array << page_url
      if page_url == cleaned_last_url
        last_url_record = page_url
      end
    end

    start_url = last_url_record.present? ? last_url_record : pages_array.first
    start_index = pages_array.index(start_url)

    if start_index.nil?
      puts "Starting URL not found in the list. Using the entire list."
      start_index = 0
    end

    category_pages = pages_array[start_index..-1]

    category_pages.each do |page|
      category_data = page.split('.com')[1]
      category_data_second = category_data.split('/')
      if category_data_second[3]

        category = Category.find_or_create_by(title: category_data_second[2])
        sub_category = category.sub_categories.find_or_create_by(title: category_data_second[3])
      else
        sub_category = SubCategory.find_or_create_by(title: category_data_second[2])
      end
      last_page_number = 1
      if LastPageUrl.any?
        last_url = LastPageUrl.last&.url
        if last_url&.include?('/page/')
          last_page_number = url_data.second.to_i
          browser.goto last_url
          LastPageUrl.delete_all
        else
          browser.goto page
        end
      else
        browser.goto page
      end
      
      products_pagination =  browser.element(xpath: "/html/body/div[2]/main/div/div[1]/div/nav/ul")
      products = browser.elements(xpath: "//*[contains(@class, 'name') and contains(@class, 'product-title') and contains(@class, 'woocommerce-loop-product__title')]")
      if products_pagination.lis.present?
        second_last_li = products_pagination.lis[-2]
        a_tag = second_last_li.a
        products_page_count = a_tag.text.to_i+1
        (last_page_number...products_page_count).each do |page_number|
          last_url_record = "#{page}page/#{page_number}"
          LastPageUrl.create!(url: last_url_record)
          puts "==================#{last_url_record}================"
          puts "=================================="
          browser_4 = Watir::Browser.new :chrome, options: { args: options }
          raise Exception.new "Browser error" if !browser_4.present?
          products.each do |product|
            product_url = product.a.href
            existing_product = sub_category.products.find_by(product_url: product_url)
            next if existing_product
            browser_4.goto product_url
            next unless browser_4.element(xpath: "//h1[contains(@class, 'product-title') and contains(@class, 'product_title') and contains(@class, 'entry-title')]").present?
            product_sku = browser_4.element(xpath: "//span[contains(@class, 'sku_wrapper')]").span.text
            product_title = browser_4.element(xpath: "//h1[contains(@class, 'product-title') and contains(@class, 'product_title') and contains(@class, 'entry-title')]").text
            product_price = browser_4.input(xpath: "//input[@type='hidden' and contains(@class, 'product-options-product-price')]").value
            sub_category.products.create(title: product_title, price: product_price, sku: product_sku, product_url: product_url)
            puts " =================#{product_title}==========#{product_price}=============#{product_sku}"
          end
          browser_4.close 
          puts "=================================="
          puts "================== page end ============"
          next_url = "#{page}page/#{page_number+1}"
          browser.goto(next_url)
        end
      end
      break if page == last_page_url
    end
   
  rescue StandardError => e
    attempts += 1
    puts "Error encountered: #{e.message}. Attempt #{attempts} of 5."
    sleep 5
    retry if attempts < 5
  end
  puts "=============script end==================="
  unless last_url_record.nil?
    LastPageUrl.create!(url: last_url_record)
  end
  browser.close
end