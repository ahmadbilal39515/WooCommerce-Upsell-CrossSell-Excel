class ProductsController < ApplicationController
  http_basic_authenticate_with :name => ENV['name'], password: ENV['password'], only: :index

  def index
  end
   
  def get_csv
    products = Product.includes(sub_category: :category).where(created_at: params[:startDate]..params[:endDate] )
    csv_data = ProductExportService.to_csv(products)
    filename = "products_list_#{params[:startDate].to_s}_#{params[:endDate].to_s}.csv"
    respond_to do |format|
      format.csv do
        send_data csv_data, filename: filename, disposition: 'attachment'
      end
    end
  end

end