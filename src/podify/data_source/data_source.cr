require "cossack"

module DataSource
  class ServerError < Exception; end

  private def process_response(response : Cossack::Response | HTTP::Client::Response)
    case response.status
    when 200..299
      return response.body
    when 400
      raise ServerError.new("400: Server Not Found")
    when 429
      raise ServerError.new("429: Quota exceeded")
    when 500
      raise ServerError.new("500: Internal Server Error")
    when 502
      raise ServerError.new("502: Bad Gateway")
    when 503
      raise ServerError.new("503: Service Unavailable")
    when 504
      raise ServerError.new("504: Gateway Timeout")
    else
      raise ServerError.new("Server returned error #{response.status}")
    end
  end
end
