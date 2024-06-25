class ProductsController < ApplicationController
  http_basic_authenticate_with :name => ENV['name'], password: ENV['password'], only: :index

  def index
    @products = Product.count
    debugger
    duplicate_products = @products.group_by(&:sku).select { |sku, products| products.size > 1 }

  end
   
  def get_csv
    start_index = params[:startIndex].to_i
    end_index = params[:endIndex].to_i
    fetch_size = 5000
    excluded_products = Product.includes(sub_category: :category)
    .offset(start_index)
    .limit(end_index - start_index + 1)

    excluded_ids = excluded_products.pluck(:id)
    products = Product.includes(sub_category: :category)
                      .where.not(id: excluded_ids)
                      .order(Arel.sql('RANDOM()'))
                      .limit(fetch_size)
    csv_data = ProductExportService.to_csv(excluded_products, products, start_index, end_index)
    filename = "products_list_#{params[:startIndex].to_s}_#{params[:endIndex].to_s}.csv"
    respond_to do |format|
      format.json do
        render json: { csv_data: csv_data, filename: filename }
      end
    end
  end
end