# app/workers/csv_export_worker.rb
class CsvExportWorker
  include Sidekiq::Worker

  def perform(start_date, end_date)
    start_date = start_date.to_date.beginning_of_day
    end_date = end_date.to_date.end_of_day
    products = Product.includes(sub_category: :category).where(created_at: start_date..end_date)
    csv_data = ProductExportService.to_csv(products)
  
    # Store CSV data in Redis with job ID
    Sidekiq.redis do |conn|
      conn.set("csv_download_#{jid}", csv_data)
    end
  end
end
