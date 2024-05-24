require 'watir'
require 'json'

task :third => :environment do

  options = [ '--disable-infobars', '--disable-extensions', '--disable-gpu','--no-sandbox', '--disable-dev-shm-usage', '--disable-blink-features=AutomationControlled', '--disable-images','--disable-css']

  browser = Watir::Browser.new :chrome, options: { args: options }
  raise Exception.new "Browser error" if !browser.present?

  base_url = "https://www.thejewelryvine.com"
  last_page_url = "https://www.thejewelryvine.com/product-category/childrens-jewelry-collections/disney-childrens-jewelry/"
  last_url_record = nil
  pages_array = []
  cleaned_last_url = nil
  attempts = 0

  begin
    
    if LastPageUrl.any?
      if !LastPageUrl.last.url.nil?
        if LastPageUrl.last&.url.include?('/page/')
          url_data = LastPageUrl.last&.url.split('/page/')
          cleaned_last_url = url_data.first
        else
          cleaned_last_url = LastPageUrl.last&.url
        end
        if cleaned_last_url == last_page_url
          LastPageUrl.delete_all
        end
      end
    end
  
    browser.goto "#{base_url}"
    pages = browser.elements(xpath: "//li[contains(@class, 'menu-item') and contains(@class, 'menu-item-type-taxonomy') and contains(@class, 'menu-item-object-product_cat') and not(contains(@class, 'menu-item-design-default')) and not(contains(@class, 'has-dropdown')) and not(contains(@class, 'nav-dropdown-col'))]")
    
    pages.each do |page|
      page_url = page.a.href
      pages_array << page_url
      if page_url ==  cleaned_last_url
        last_url_record = page_url
      end
    end
  
    start_url = last_url_record.present? ? last_url_record : pages_array.first
    start_index = pages_array.index(start_url)

    if start_index.nil?
      puts "Starting URL not found in the list. Using the entire list."
      start_index = 0
    end

    pages_to_process = pages_array[start_index..-1]

    pages_to_process.each do |page|
      last_page_number = 1
      if LastPageUrl.any?
        if !LastPageUrl.last.url.nil?
          if LastPageUrl.last&.url.include?('/page/')
            last_page_number = url_data.second.to_i
            LastPageUrl.delete_all
          end
        end
      end

      browser.goto page
      products_pagination =  browser.element(xpath: "/html/body/div[2]/main/div/div[1]/div/nav/ul")
      products = browser.elements(xpath: "//*[contains(@class, 'name') and contains(@class, 'product-title') and contains(@class, 'woocommerce-loop-product__title')]")
      if products_pagination.lis.present?
        second_last_li = products_pagination.lis[-2]
        a_tag = second_last_li.a
        products_page_count = a_tag.text.to_i
        (last_page_number..products_page_count).each do |page_number|
          url = "#{page}/page/#{page_number}"
          last_url_record = url
          puts "==================#{url}================"
          puts "=================================="
          # get_product(products)
          # browser_4 = Watir::Browser.new :chrome, options: { args: options }
          # raise Exception.new "Browser error" if !browser_4.present?
          # products.each do |product|
          #   browser_4.goto product.a.href
          #   # product_title = browser_4.element(xpath: "/html/body/div[2]/main/div/div[2]/div[1]/div/div/div[2]/h1").text
          #   # product_price = browser_4.element(xpath: "/html/body/div[2]/main/div/div[2]/div[1]/div/div/div[2]/div[4]/p/span/bdi").text
          #   # product_sku = browser_4.element(xpath: "/html/body/div[2]/main/div/div[2]/div[1]/div/div/div[2]/div[6]/span[1]/span").text
          #   # puts "==============================prodcut details========================"
          #   # puts " =================#{product_title}==========#{product_price}=============#{product_sku}"
          #   # puts "==============================end ==================================="
          #   # Product.create!(product_url: prodcut.a.href )
          # end
          # browser_4.close 
          # puts "=================================="
          # puts "================== page end ============"
          browser.goto(url)
        end
      end
      break if page == last_page_url
    end
   
  rescue StandardError => e
    LastPageUrl.create!(url: last_url_record)
    attempts += 1
    puts "Error encountered: #{e.message}. Attempt #{attempts} of 5."
    sleep 5
    retry if attempts < 5
  end
  puts "=============script end==================="
  browser.close
end

# def get_product(products)
#   debugger
#   options = ['--disable-infobars','--disable-extensions','--disable-gpu','--headless',
#   '--no-sandbox','--disable-dev-shm-usage','--disable-blink-features=AutomationControlled',
#   '--disable-images','--disable-css']

#   browser_4 = Watir::Browser.new :chrome, options: { args: options }
#   raise Exception.new "Browser error" if !browser_4.present?
#   products.each do |product|
#       # puts product.a.href
#     # if attempt < 3
#       browser_4.goto product.a.href
#       # product_title = browser_4.element(xpath: "/html/body/div[2]/main/div/div[2]/div[1]/div/div/div[2]/h1").text
#       # product_price = browser_4.element(xpath: "/html/body/div[2]/main/div/div[2]/div[1]/div/div/div[2]/div[4]/p/span/bdi").text
#       # product_sku = browser_4.element(xpath: "/html/body/div[2]/main/div/div[2]/div[1]/div/div/div[2]/div[6]/span[1]/span").text
#       # puts "==============================prodcut details========================"
#       # puts " =================#{product_title}==========#{product_price}=============#{product_sku}"
#       # puts "==============================end ==================================="
#       # attempt +=1
#     # end
#       browser_4.close 
#   end
# end