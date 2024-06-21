class ProductsController < ApplicationController
  http_basic_authenticate_with :name => ENV['name'], password: ENV['password'], only: :index

  def index
    @products = Product.count
  end
   
  def get_csv
    debugger
    start_index = params[:startIndex].to_i
    end_index = params[:endIndex].to_i
    products = Product.includes(sub_category: :category)
    csv_data = ProductExportService.to_csv(products, start_index, end_index)
    filename = "products_list_#{params[:startIndex].to_s}_#{params[:endIndex].to_s}.csv"
    respond_to do |format|
      format.json do
        render json: { csv_data: csv_data, filename: filename }
      end
    end
  end
end