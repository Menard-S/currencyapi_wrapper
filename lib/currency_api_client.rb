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
      Rails.logger.debug "Requesting supported currencies from API"
      response = client.get('currencies') do |req|
        req.params['apikey'] = Rails.application.credentials.currencyapi[:api_key]
      end
      Rails.logger.debug "Raw API response: #{response.body.inspect}"
      if response.success?
        begin
          data = JSON.parse(response.body)
          if data['data'] && data['data'].is_a?(Hash)
            data['data'].transform_values { |details| details['name'] }
          else
            Rails.logger.error "Unexpected data format: #{data}"
            {}
          end
        rescue JSON::ParserError => e
          Rails.logger.error "JSON parsing error: #{e.message}"
          {}
        end
      else
        Rails.logger.error "Failed to fetch currencies: Status #{response.status}"
        {}
      end
    end    
  end
  