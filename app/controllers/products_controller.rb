class ProductsController < ApplicationController
  http_basic_authenticate_with :name => ENV['name'], password: ENV['password'], only: :index

  def index
    @products = Product.count
  end
   
  def get_csv
    start_index = params[:start].to_i
    end_index = params[:end].to_i
    products = Product.includes(sub_category: :category)
    csv_data = ProductExportService.to_csv(products, start_index, end_index)
    filename = "products_list_#{params[:start].to_s}_#{params[:end].to_s}.csv"
    respond_to do |format|
      format.csv do
        send_data csv_data, filename: filename, disposition: 'attachment'
      end
    end
  end
end