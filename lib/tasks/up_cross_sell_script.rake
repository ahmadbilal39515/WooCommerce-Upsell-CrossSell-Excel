require 'watir'
require 'json'

desc "This task going to scapre data"

task up_cross_sell_product: :environment do
  begin 

    chrome_options = {
          args: %w[--disable-infobars  --window-size=1600,1200 --disable-dev-shm-usage --no-sandbox --disable-gpu]
    }
    browser = Watir::Browser.new :chrome, options: chrome_options
    raise Exception.new "Browser error" if !browser.present?
    pages = ['/product-category/newj/', '/product-category/theme/', '/product-category/kids-earrings/', '/product-category/rings/', '/product-category/bracelets/', '/product-category/necklaces/', '/birthstone-jewelry-for-children/', '/product-category/kids-religious-jewelry/', '/product-category/baby-jewelry/', '/product-category/childrens-jewelry-collections/']
    base_url = "https://www.thejewelryvine.com"
    pages.each do |page|
      browser.goto "#{base_url}#{page}"
      products_categories_type_1 = browser.elements(xpath: "//div[contains(@class, 'product-category') and contains(@class, 'col') and contains(@class, 'product')]")
      products_categories_type_2 = browser.elements(xpath: "//div[contains(@class, 'banner-layers') and contains(@class, 'container')]")
      if products_categories_type_1.any?
        products_categories_type_1.each do |products_category|
          if products_category.div(tag_name: 'div').present?
            category_url = products_category.div(tag_name: 'div').a(tag_name: 'a').href
            browser_2 = Watir::Browser.new :chrome, options: chrome_options
            raise Exception.new "Browser error" if !browser_2.present?
            browser_2.goto category_url
            products_iteration(browser_2, category_url)
            browser_2.close
          end
        end
      elsif products_categories_type_2.any?
      else
        products_url = "#{base_url}#{page}"
        products_iteration(browser, products_url)
      end
    end
    # browser.wait_until { browser.ready_state == 'complete' }
    # script_tags = browser.elements(xpath: "//script[contains(text(), 'window.wpmDataLayer.products')]")

    # script_tags.each do |script_tag|
    #   debugger
    #   script_content = script_tag.text
    #   if script_content.include?('window.wpmDataLayer.products')
    #     # Use a regular expression to extract the JSON object from the script content
    #     regex = /window\.wpmDataLayer\.products\s*=\s*(\{.*?\});/m
    #     match = script_content.match(regex)
    #     json_data = match[1] if match
    #     products_data = JSON.parse(json_data)
    #     puts products_data
    #     debugger
    #     break if json_data # Exit the loop if we've found the data
    #   end
    #   # script_content = script_tag.text
    #   # regex = /window\.wpmDataLayer\.products\s*=\s*(\{.*?\});/m
    #   # match = script_content.match(regex)
    #   # json_data = match[1] if match
    #   # products_data = JSON.parse(json_data)
    #   # puts products_data
    # end


    # elements = browser.elements(xpath: "//li[contains(@class, 'menu-item') and contains(@class, 'menu-item-type-taxonomy') and contains(@class, 'menu-item-object-product_cat') and not(contains(@class, 'menu-item-has-children')) and not(contains(@class, 'menu-item-design-default')) and not(contains(@class, 'has-dropdown'))]")
    
    debugger
  rescue Exception => e
    puts e.message
  end
  puts "=========== script end =============="
end

def products_iteration(browser, products_url)
  products_pagination =  browser.element(xpath: "/html/body/div[2]/main/div/div[1]/div/nav/ul")
  if products_pagination.lis.present?
    products_page_count = products_pagination.lis.size - 1
    (2..products_page_count).each do |page_number|
      url = "#{products_url}/page/#{page_number}"
      browser.goto(url)
    end
  end
end