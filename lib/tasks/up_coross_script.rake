require 'watir'
require 'selenium-webdriver'
require 'json'

desc "This task going to scapre data"

task second: :environment do
  attempts = 0
  begin 
    attempts += 1
    options = [
      '--disable-infobars',
      '--disable-extensions',
      '--disable-gpu',
      # '--headless', # Uncomment if you need headless mode
      '--no-sandbox',
      '--disable-dev-shm-usage',
      '--disable-blink-features=AutomationControlled',
      '--disable-images',
      '--disable-css'
    ]
    
    browser = Watir::Browser.new :chrome, options: { args: options }
    raise Exception.new "Browser error" if !browser.present?
    pages = ['/product-category/newj/', '/product-category/theme/', '/product-category/kids-earrings/', '/product-category/rings/', '/product-category/bracelets/', '/product-category/necklaces/', '/birthstone-jewelry-for-children/', '/birthstone-jewelry-for-children/', '/product-category/kids-religious-jewelry/', '/product-category/baby-jewelry/', '/product-category/childrens-jewelry-collections/']
    base_url = "https://www.thejewelryvine.com"
     
    last_url_record = LastPageUrl.last

    if last_url_record
      start_url = last_url_record.url
    else
      start_url = pages.first
    end
    start_index = pages.index(start_url)
  
    if start_index.nil?
      puts "Starting URL not found in the list. Using the entire list."
      start_index = 0
    end

    # Slice the array from the starting index
    pages_to_process = pages[start_index..-1]
   
    pages.each do |page|
      browser.goto "#{base_url}#{page}"
      products_categories_type_1 = browser.elements(xpath: "//div[contains(@class, 'product-category') and contains(@class, 'col') and contains(@class, 'product')]")
      products_categories_type_2 = browser.elements(xpath: "//div[contains(@class, 'banner-layers') and contains(@class, 'container')]")
      if products_categories_type_1.any?
        products_categories_type_1.each do |products_category|
          if products_category.div(tag_name: 'div').present?
            category_url = products_category.div(tag_name: 'div').a(tag_name: 'a').href
            browser_2 = Watir::Browser.new :chrome, options: { args: options }
            raise Exception.new "Browser error" if !browser_2.present?
            browser_2.goto category_url
            # products_iteration(browser_2, options, category_url)
            browser_2.close
          end
        end
      elsif products_categories_type_2.any?
        category_type_2_elements = browser.elements(xpath: "//div[contains(@class, 'banner-layers') and contains(@class, 'container')]")
         if category_type_2_elements.any?
            category_type_2_elements.each do |category_type_2_element|
              browser_3 = Watir::Browser.new :chrome, options: { args: options }
              raise Exception.new "Browser error" if !browser_3.present?
              category_type_2_element_url = category_type_2_element.a.href
              puts category_type_2_element_url
              browser_3.goto category_type_2_element_url
              # products_iteration(browser_3, options, category_type_2_element_url)
              browser_3.close
            end
         end
      else
        products_url = "#{base_url}#{page}"
        # products_iteration(browser, options, products_url)
      end
      LastPageUrl.delete_all
      LastPageUrl.create!(url: page)
    end 
  rescue Exception => e
    if attempts < 3
      puts "Attempt #{attempts} failed. Retrying in #{attempts} seconds..."
      sleep 3
      retry
    else
      puts e.message
    end
  end
  browser.close
  puts "=========== script end =============="
end

def products_iteration(browser, options, products_url)
  attempts = 0
  begin
    attempts +=1
    products_pagination =  browser.element(xpath: "/html/body/div[2]/main/div/div[1]/div/nav/ul")
    products = browser.elements(xpath: "//*[contains(@class, 'name') and contains(@class, 'product-title') and contains(@class, 'woocommerce-loop-product__title')]")
    if products_pagination.lis.present?
      second_last_li = products_pagination.lis[-2]
      a_tag = second_last_li.a
      products_page_count = a_tag.text.to_i
      (2..products_page_count).each do |page_number|
        url = "#{products_url}/page/#{page_number}"
        puts "==================#{url}================"
        puts "=================================="
        # get_product(products)
        puts "=================================="
        puts "================== page end ============"
        browser.goto(url)
        # browser.close
      end
    end
  rescue StandardError => e
    puts "An error occurred: #{e.message}"
    retry if attempts < 3
  ensure
    # Close the browser
    browser.close
  end
end

def get_product(products)
  # options = [
  #   '--disable-infobars',
  #   '--disable-extensions',
  #   '--disable-gpu',
  #   '--headless',
  #   '--no-sandbox',
  #   '--disable-dev-shm-usage',
  #   '--disable-blink-features=AutomationControlled',
  #   '--disable-images',
  #   '--disable-css'
  # ]
  # # attempt = 0
  # browser_4 = Watir::Browser.new :chrome, options: { args: options }
  # raise Exception.new "Browser error" if !browser_4.present?
  products.each do |product|
    puts product.a.href
    # if attempt < 3
      # browser_4.goto product.a.href
      # product_title = browser_4.element(xpath: "/html/body/div[2]/main/div/div[2]/div[1]/div/div/div[2]/h1").text
      # product_price = browser_4.element(xpath: "/html/body/div[2]/main/div/div[2]/div[1]/div/div/div[2]/div[4]/p/span/bdi").text
      # product_sku = browser_4.element(xpath: "/html/body/div[2]/main/div/div[2]/div[1]/div/div/div[2]/div[6]/span[1]/span").text
      # puts "==============================prodcut details========================"
      # puts " =================#{product_title}==========#{product_price}=============#{product_sku}"
      # puts "==============================end ==================================="
      # attempt +=1
    # end
  end
  # browser_4.close
end