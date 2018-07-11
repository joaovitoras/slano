module Solano
  class Client
    def get(url, params)
      response = RestClient.get(url, format_params(params))
      JSON.parse(response.body)
    end

    private

    def format_params(params)
      {params: params}.merge(headers)
    end

    def headers
      {
        'Content-Type' => 'application/json',
        "X-Tddium-Client-Version" => ENV['TDDIUM_CLIENT_VERSION'],
        "X-Tddium-Api-Key" => ENV['TDDIUM_API_KEY']
      }
    end
  end
end
