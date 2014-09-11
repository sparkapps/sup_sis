
class ApplicationController < Sinatra::Base

  ########################
  # Configuration
  ########################

  configure do
    enable :logging
    enable :method_override
    enable :sessions

    set :session_secret, 'super secret'

    # setting up redis connection
    uri    = URI.parse(ENV["REDISTOGO_URL"])
    $redis = Redis.new({:host     => uri.host,
                        :port     => uri.port,
                        :password => uri.password})

    #######################
    # API KEYS
    #######################
    CLIENT_ID       = "109928263333-qtgs1fd13qmi0ns3r94q84b8ing71680.apps.googleusercontent.com"
    CLIENT_SECRET   = "_MLTgNJ0BPjT1N5Gl5Dy47GZ"
    CALLBACK_URL    = "http://tranquil-reef-9096.herokuapp.com/oauth2callback"
    # CALLBACK_URL    = "http://localhost:9292/oauth2callback"

    # prior to trying redis.incr, create counter
    # $counter = $redis.keys.size + 1

    # set up messages hash as class variable
    # @@messages = [{:sender_name => "Neil Sidhu", :new_post => "Hello World!", :post_date => "September 5, 2014"}]
  end

  # set up loggers
  before do
    logger.info "Request Headers: #{headers}"
    logger.warn "Params: #{params}"
  end

  after do
    logger.info "Response Headers: #{response.headers}"
  end

end
