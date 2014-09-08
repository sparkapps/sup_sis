require 'sinatra/base'
require 'redis'
require 'json'
require 'uri'
require 'pry'

class App < Sinatra::Base

  ########################
  # Configuration
  ########################

  configure do
    enable :logging
    enable :method_override
    enable :sessions

    # setting up redis connection
    uri = URI.parse(ENV["REDISTOGO_URL"])
    $redis = Redis.new({:host     => uri.host,
                        :port     => uri.port,
                        :password => uri.password})

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

  ########################
  # Routes
  ########################

  get('/') do
    redirect to ('/messages')
  end

  get('/messages') do
    @messages = $redis.keys("*messages*").map { |posting| JSON.parse($redis.get(posting)) }
    # binding.pry
    render(:erb, :"sup_messages/index", :layout => :template)
  end

  # new message form
  get('/messages/new') do
    render(:erb, :"sup_messages/write_message_form", :layout => :template)
  end

  # create a new message
  # thanks to Rob (TA) for explaining routes
  post('/messages') do
    #step 1 create message
    name             = params[:name]
    message_title    = params[:message_title]
    message_body     = params[:message_body]
    message_date     = params[:message_date]
    image_url        = params[:image_url]
    index            = $redis.incr("message:index")

    message =
      {
      name:          name,
      message_title: message_title,
      message_body:  message_body,
      message_date:  message_date,
      image_url:     image_url,
      id:            index
      }
    # binding.pry

    #step 2 save message with redis
    $redis.set("messages:#{index}", message.to_json)
    # binding.pry

    #step 3 redirect to a method to show our newly created message
    redirect to('/messages')
  end

  # get a message by its id and display (show) it
  get('/messages/:id') do
    #grabbing a message by its id in redis
    id            = params[:id]
    one_message   = $redis.get("messages:#{id}")
    @message      = JSON.parse(one_message)
    # binding.pry
    #rendering a show page with that message content
    render(:erb, :"sup_messages/show")
  end

  # get a message by its ID and edit it
  get('/messages/:id/edit') do
    id            = params[:id]
    message       = $redis.get("messages:#{id}")
    @message      = JSON.parse(message)
    render(:erb, :"sup_messages/edit_message")
  end

  # update a message
  put('/messages/:id') do
    name              = params[:name]
    post_title        = params[:post_title]
    post_body         = params[:post_body]
    post_date         = params[:post_date]
    image_url         = params[:image_url]
    id                = params[:id]

    updated_message   =
      {
      name:           name,
      post_title:     post_title,
      post_body:      post_body,
      post_date:      post_date,
      image_url:      image_url,
      id:             id
      }

    $redis.set("messages:#{id}", updated_message.to_json)
    redirect to("/messages/#{id}")
  end

  # delete a message
  delete('/messages/:id') do
    id = params[:id]
    $redis.del("messages:#{id}")
    redirect to('/messages')
  end

end
