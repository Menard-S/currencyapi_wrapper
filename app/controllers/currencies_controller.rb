class CurrenciesController < ApplicationController
  def index
    Rails.logger.debug "Entering index action"
    @currencies = CurrencyApiClient.supported_currencies
    if @currencies.empty?
      flash[:alert] = "Failed to load currency data. Please try again later."
    end
  end  

  def convert
    amount = params[:amount]
    source = params[:source_currency]
    target = params[:target_currency]
    @conversion_result = CurrencyApiClient.convert(amount, source, target)
    if @conversion_result && @conversion_result['data'] && @conversion_result['data'][target]
      converted_value = @conversion_result['data'][target]['value'].to_f.round(2)
      flash[:conversion_rate] = "#{amount} #{source} = #{converted_value} #{target}"
      flash[:notice] = "Conversion successful"
    else
      flash[:error] = "Conversion failed. Please try again."
    end
    redirect_to root_path
  end       
end
