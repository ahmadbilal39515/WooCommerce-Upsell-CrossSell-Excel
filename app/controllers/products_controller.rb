class ProductsController < ApplicationController
    http_basic_authenticate_with :name => ENV['name'], password: ENV['password'], only: :index

  def index
  end

  # def new
  #   @order_list = OrderList.new
  # end

  # def get_raw_data_csv
  #   @order_list = OrderList.includes(:items).where(transactionTime: params[:startDate]..params[:endDate])
  #   csv_data = RawDataListService.generate_raw_data_csv(@order_list)
  #   filename = "raw_data_list_#{params[:startDate].to_s}_#{params[:endDate].to_s}.csv"
  #   respond_to do |format|
  #     format.csv do
  #       send_data csv_data, filename: filename, disposition: 'attachment'
  #     end
  #   end
  # end

  # def get_csv
  #   @order_list = OrderList.includes(:items).where(transactionTime: params[:startDate]..params[:endDate])
  #   @analytics_data = GetOrderListService.get_analytics(params[:startDate], params[:endDate])
  #   crunch_data = GetOrderListService.crunch(@order_list, @analytics_data)
  #   csv_data = GetOrderListService.generate_csv_data(crunch_data)
  #   filename = "order_list_#{params[:startDate].to_s}_#{params[:endDate].to_s}.csv"
  #   respond_to do |format|
  #     format.csv do
  #       send_data csv_data, filename: filename, disposition: 'attachment'
  #     end
  #   end
  # end
end