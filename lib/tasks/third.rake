require 'watir'
require 'json'

task :third => :environment do

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

  base_url = "https://www.thejewelryvine.com"
  last_page_url = "https://www.thejewelryvine.com/product-category/childrens-jewelry-collections/disney-childrens-jewelry/"
  last_url_record = nil
  pages_array = []

  attempts = 0
  begin
    if LastPageUrl.last&.url == last_page_url
      LastPageUrl.delete_all
    end
    browser.goto "#{base_url}"
    pages = browser.elements(xpath: "//li[contains(@class, 'menu-item') and contains(@class, 'menu-item-type-taxonomy') and contains(@class, 'menu-item-object-product_cat') and not(contains(@class, 'menu-item-design-default')) and not(contains(@class, 'has-dropdown')) and not(contains(@class, 'nav-dropdown-col'))]")
    
    pages.each do |page|
      page_url = page.a.href
      pages_array << page_url
      if page_url ==  LastPageUrl.last&.url
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
      LastPageUrl.create!(url: page)
      puts page
      browser.goto page

      break if page == last_page_url
    end
  rescue StandardError => e
    attempts += 1
    puts "Error encountered: #{e.message}. Attempt #{attempts} of 3."
    sleep 3
    retry if attempts < 3
  end
  browser.close
end