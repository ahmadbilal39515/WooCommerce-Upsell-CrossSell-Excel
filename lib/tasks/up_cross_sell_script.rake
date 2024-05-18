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
    
    pages.each do |page|
      browser.goto "https://www.thejewelryvine.com#{page}"
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