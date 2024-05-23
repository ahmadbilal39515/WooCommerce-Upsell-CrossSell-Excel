require 'watir'
require 'json'

task :up_cross_sell_script => :environment do
  # Initialize the browser (e.g., Chrome)
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

  begin
    max_retries = 3

    pages = [
      '/product-category/newj/',
      '/product-category/theme/',
      '/product-category/kids-earrings/',
      '/product-category/rings/',
      '/product-category/bracelets/',
      '/product-category/necklaces/',
      '/birthstone-jewelry-for-children/',
      '/product-category/kids-religious-jewelry/',
      '/product-category/baby-jewelry/',
      '/product-category/childrens-jewelry-collections/'
    ]

    # Retrieve the last visited URL from the model
    last_url_record = LastPageUrl.last
    LastPageUrl.delete_all
    if last_url_record
      start_url = last_url_record.url
    else
      start_url = pages.first # Default to the first URL if no record is found
    end

    # Find the index of the starting URL
    start_index = pages.index(start_url)
    
    if start_index.nil?
      puts "Starting URL not found in the list. Using the entire list."
      start_index = 0
    end

    # Slice the array from the starting index
    pages_to_process = pages[start_index..-1]

    pages_to_process.each do |page|
      attempts = 0

      begin
        attempts += 1
        browser.goto "https://www.thejewelryvine.com#{page}"

        # Your scraping logic here...

        # Get the current URL and store it in the model
        LastPageUrl.create!(url: page)

      rescue StandardError => e
        puts "An error occurred: #{e.message}"
        retry if attempts < max_retries
      end
    end

  ensure
    # Close the browser at the end
    browser.close
  end
end
