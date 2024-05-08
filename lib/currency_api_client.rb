module CurrencyApiClient
  require 'faraday'
  require 'json'

  BASE_URL = 'https://api.currencyapi.com/v3'

  def self.client
    Faraday.new(url: BASE_URL) do |faraday|
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end
  end

  def self.api_key
    Rails.application.credentials.currencyapi[:api_key]
  end

  def self.request(endpoint, params = {})
    response = client.get(endpoint) do |req|
      req.params = params.merge(apikey: api_key)
    end
    handle_response(response)
  end

  def self.handle_response(response)
    if response.success?
      JSON.parse(response.body)
    else
      Rails.logger.error "API request failed: Status #{response.status}, Body #{response.body}"
      nil
    end
  rescue JSON::ParserError => e
    Rails.logger.error "JSON parsing error: #{e.message}"
    nil
  end

  def self.convert(value, source, target)
    params = { value: value, base_currency: source, currencies: target }
    request('convert', params)
  end

  def self.supported_currencies
    response = request('currencies')
    return {} unless response

    data = response['data'] || {}
    data.transform_values { |details| details['name'] }
  end

  def self.latest_rate(source, target)
    params = { base_currency: source, currencies: target }
    response = request('latest', params)
    return nil unless response && response['data'] && response['data'][target]

    response['data'][target]['value'].to_f.round(2)
  end

  def self.historical_rates(dates, source, target)
    rates = {}
    dates.each do |date|
      params = { date: date, base_currency: source, currencies: target }
      response = request('historical', params)
      rate = response['data'] && response['data'][target] ? response['data'][target]['value'].to_f.round(2) : nil
      rates[date] = rate
    end
    rates
  end
end
