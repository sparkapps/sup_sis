
class ApplicationController < Sinatra::Base

  ########################
  # Configuration
  ########################

  configure do
    enable :logging
    enable :method_override
    enable :sessions

    set :session_secret, 'super secret'

    uri    = URI.parse(ENV["REDISTOGO_URL"])
    $redis = Redis.new({:host     => uri.host,
                        :port     => uri.port,
                        :password => uri.password,
                        :db       => 14})

    #######################
    # API KEYS
    #######################
    CLIENT_ID       = ""
    CLIENT_SECRET   = ""
    CALLBACK_URL    = "http://tranquil-reef-9096.herokuapp.com/oauth2callback"
  end

  before do
    logger.info "Request Headers: #{headers}"
    logger.warn "Params: #{params}"
  end

  after do
    logger.info "Response Headers: #{response.headers}"
  end

end
