class CurrenciesController < ApplicationController
  def index
    @currencies = CurrencyApiClient.supported_currencies
    if @currencies.empty?
      flash[:alert] = "Failed to load currency data. Please try again later."
    end
  end  

  def convert
    amount = params[:amount].to_f
    source = params[:source_currency]
    target = params[:target_currency]
    dates = {
      yesterday: (Date.today - 1).strftime("%Y-%m-%d"),
      seven_days_ago: (Date.today - 7).strftime("%Y-%m-%d"),
      thirty_days_ago: (Date.today - 30).strftime("%Y-%m-%d")
    }
  
    @conversion_result = CurrencyApiClient.convert(amount, source, target)
    @latest_rate = CurrencyApiClient.latest_rate(source, target)
    @historical_results = CurrencyApiClient.historical_rates(dates.values, source, target)
  
    if @conversion_result && @conversion_result['data'] && @conversion_result['data'][target]
      converted_value = @conversion_result['data'][target]['value'].to_f.round(2)
      flash[:conversion_rate] = "#{amount.round(2)} #{source} = #{converted_value} #{target}"
      flash[:historical_rates] = dates.map { |key, date| "#{key.to_s.humanize}: #{@historical_results[date] || 0} #{target}" }.join(", ")
      flash[:latest_rate] = "Today: #{@latest_rate || 0} #{target}"
      flash[:notice] = "Conversion successful"
    else
      flash[:error] = "Conversion failed. Please try again."
    end
    redirect_to root_path
  end          
end
