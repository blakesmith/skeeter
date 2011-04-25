require 'goliath'

require 'em-synchrony'
require 'em-synchrony/em-http'

class Service < Goliath::API
  def response(env)
    req = EM::HttpRequest.new("http://localhost:4567/images/briones_yeah.jpg").get
    resp = req.response

    [200, {}, resp]
  end
end

