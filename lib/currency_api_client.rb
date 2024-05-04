module CurrencyApiClient
    require 'faraday'
    require 'json'
  
    BASE_URL = 'https://api.currencyapi.com/v3'
    
    # Initializes a Faraday connection
    def self.client
      Faraday.new(url: BASE_URL) do |faraday|
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
  
    # Fetches the conversion rate between two currencies
    def self.convert(value, source, target)
      Rails.logger.debug "Preparing to request conversion from #{source} to #{target}"
      response = client.get('convert') do |req|
        req.params['apikey'] = Rails.application.credentials.currencyapi[:api_key]
        req.params['value'] = value
        req.params['base_currency'] = source
        req.params['currencies'] = target
      end
      Rails.logger.debug "API response for #{source} to #{target}: #{response.body}"
      JSON.parse(response.body)
    end

    def self.supported_currencies
      response = client.get('currencies') do |req|
        req.params['apikey'] = Rails.application.credentials.currencyapi[:api_key]
      end
      if response.success?
        JSON.parse(response.body)['data'].transform_values { |details| details['name'] }
      else
        {}
      end
    end    
  end
  