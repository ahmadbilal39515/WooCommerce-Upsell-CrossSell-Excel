class ProductsController < ApplicationController
  http_basic_authenticate_with :name => ENV['name'], password: ENV['password'], only: :index

  def index
  end

  def show
    filename = params[:filename]
    if filename.present?
      file_path = Rails.root.join('tmp', "#{filename}.csv")

      if File.exist?(file_path)
        send_file file_path, type: 'text/csv', disposition: 'attachment'
      else
        render plain: 'File not found', status: :not_found
      end
    else
      flash[:error] = 'Filename parameter is missing'
      redirect_to root_path
    end
  end

  def get_csv
    start_date = params[:startDate]
    end_date = params[:endDate]

    job_id = CsvExportWorker.perform_async(start_date, end_date)
    
    render json: { job_id: job_id, message: 'Your CSV is being generated. Please check back in a moment.' }
  end

  def csv_status
    job_id = params[:job_id]

    Sidekiq.redis do |conn|
      file_path = conn.get("csv_download_#{job_id}")
      Rails.logger.info("status done with #{file_path}")
      if file_path
        render json: { ready: true, download_link: download_url(File.basename(file_path), host: request.host) }
      else
        render json: { ready: false }
      end
    end
  end
  
end