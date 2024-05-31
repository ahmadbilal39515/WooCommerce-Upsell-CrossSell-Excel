class ProductsController < ApplicationController
  http_basic_authenticate_with :name => ENV['name'], password: ENV['password'], only: :index

  def index
  end
   
  def get_csv
    start_date = params[:startDate].to_date.beginning_of_day
    end_date = params[:endDate].to_date.end_of_day
    products = Product.includes(sub_category: :category).where(created_at: start_date..end_date)
    csv_data = ProductExportService.to_csv(products)
    filename = "products_list_#{params[:startDate].to_s}_#{params[:endDate].to_s}.csv"
    respond_to do |format|
      format.csv do
        send_data csv_data, filename: filename, disposition: 'attachment'
      end
    end
  end

end