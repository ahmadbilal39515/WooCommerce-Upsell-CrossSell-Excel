require 'watir'
require 'webdrivers/chromedriver'

task :old_up_cross_sell_products => :environment do
  chrome_bin_path = ENV['GOOGLE_CHROME_BIN'] || '/app/.apt/usr/bin/google-chrome'

  browser_options = {
    args: [
      '--disable-infobars',
      '--disable-extensions',
      '--disable-gpu',
      '--no-sandbox',
      '--disable-dev-shm-usage',
      '--headless',
      '--disable-blink-features=AutomationControlled',
      '--disable-images',
      '--disable-css'
    ]
  }

  Selenium::WebDriver::Chrome.path = chrome_bin_path
  browser = Watir::Browser.new :chrome, options: browser_options
  raise Exception.new "Browser error" if !browser.present?

  base_url = "https://www.thejewelryvine.com"
  last_page_url = "https://www.thejewelryvine.com/product-category/childrens-jewelry-collections/disney-childrens-jewelry/"
  last_url_record = ""
  cleaned_last_url = ""
  sub_category = ""
  attempts = 0
  debugger

  begin
    if LastPageUrl.any?
      last_url = LastPageUrl.last&.url
      cleaned_last_url = last_url&.include?('/page/') ? last_url.split('page/').first : last_url
      LastPageUrl.delete_all if cleaned_last_url == last_page_url
    end

    browser.goto base_url
    pages = browser.elements(xpath: "//li[contains(@class, 'menu-item') and contains(@class, 'menu-item-type-taxonomy') and contains(@class, 'menu-item-object-product_cat') and not(contains(@class, 'menu-item-design-default')) and not(contains(@class, 'has-dropdown')) and not(contains(@class, 'nav-dropdown-col'))]").map { |page| page.a.href }

    last_url_record = pages.find { |page_url| page_url == cleaned_last_url } || pages.first
    start_index = pages.index(last_url_record)
    category_pages = pages[start_index..-1]

    category_pages.each do |page|
      process_category_page(page, browser, last_page_url, cleaned_last_url, browser_options)
      break if page == last_page_url
      GC.start  # Trigger garbage collection
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

def process_category_page(page, browser, last_page_url, cleaned_last_url, browser_options)
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
    a_tag = second_last_li.a
    products_page_count = a_tag.text.to_i + 1
    (last_page_number...products_page_count).each do |page_number|
      process_product_page(page, page_number, browser, sub_category, browser_options)
      next_url = "#{page}page/#{page_number + 1}"
      browser.goto(next_url)
      GC.start
    end
  else
    process_product_page(page, 1, browser, sub_category, browser_options)
    GC.start
  end
end

def process_product_page(page, page_number, browser, sub_category, browser_options)
  last_url_record = "#{page}page/#{page_number}"
  LastPageUrl.create!(url: last_url_record)
  puts "==================#{last_url_record}================"
  store_products(browser, sub_category)
  puts "=================================="
  puts "================== page end ============"
end

def store_products(browser, sub_category)
  products = browser.elements(xpath: "//*[contains(@class, 'name') and contains(@class, 'product-title') and contains(@class, 'woocommerce-loop-product__title')]")

  products.each do |product|
    product_url = product.a.href
    browser.goto product_url
    next unless browser.element(xpath: "//h1[contains(@class, 'product-title') and contains(@class, 'product_title') and contains(@class, 'entry-title')]").present?
    
    product_sku = browser.element(xpath: "//span[contains(@class, 'sku_wrapper')]").span.text
    product_title = browser.element(xpath: "//h1[contains(@class, 'product-title') and contains(@class, 'product_title') and contains(@class, 'entry-title')]").text
    product_price = browser.input(xpath: "//input[@type='hidden' and contains(@class, 'product-options-product-price')]").value
    
    product = sub_category.products.find_or_initialize_by(sku: product_sku)
    product.assign_attributes(title: product_title, price: product_price, product_url: product_url)
    product.save
    puts " =================#{product_title}==========#{product_price}=============#{product_sku}"
    GC.start
  end
end
