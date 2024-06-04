# app/workers/csv_export_worker.rb
class CsvExportWorker
  include Sidekiq::Worker

  def perform(start_date, end_date)
    start_date = start_date.to_date.beginning_of_day
    end_date = end_date.to_date.end_of_day
    products = Product.includes(sub_category: :category).where(created_at: start_date..end_date)
    csv_data = ProductExportService.to_csv(products)
    filename = "products_list_#{start_date.to_s}_#{end_date.to_s}.csv"
    temp_file_path = Rails.root.join('tmp', filename)

    File.open(temp_file_path, 'w') do |file|
      file.write(csv_data)
      Rails.logger.info("CSV file created at #{temp_file_path}")
    end
    
    Sidekiq.redis do |conn|
      conn.set("csv_download_#{jid}", temp_file_path.to_s)
      Rails.logger.info("File path stored in Redis with key: csv_download_#{jid}")
    end
  end
end
