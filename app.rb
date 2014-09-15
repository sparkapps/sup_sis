require './application_controller'

class App < ApplicationController

  ########################
  # Routes
  ########################

  get('/') do
    redirect to('/messages')
  end

  get('/messages') do
    base_url        = "https://accounts.google.com/o/oauth2/auth"
    scope           = "profile"
    state           = SecureRandom.urlsafe_base64
    session[:state] = state
    @url            = "#{base_url}?scope=#{scope}&client_id=#{CLIENT_ID}&response_type=code&redirect_uri=#{CALLBACK_URL}&state=#{state}"

    @messages       = $redis.keys("*messages*").map { |posting| JSON.parse($redis.get(posting)) }
    render(:erb, :"sup_messages/index", :layout => :template)
  end

  get('/oauth2callback') do
    code                = params[:code]
    if session[:state]  == params[:state]
      response          = HTTParty.post(
        "https://accounts.google.com/o/oauth2/token",
        :body           =>
          {
          code:          code,
          grant_type:    "authorization_code",
          client_id:     CLIENT_ID,
          client_secret: CLIENT_SECRET,
          redirect_uri:  CALLBACK_URL
          },
        :headers        =>
          {
          "Accept"      => "application/json"
          }
        )
      session[:access_token] = response["access_token"]
    end
    redirect to("/messages")
  end

  get('/messages/new') do
    render(:erb, :"sup_messages/new", :layout => :template)
  end

  post('/messages') do
    name             = params[:name]
    message_title    = params[:message_title]
    message_body     = params[:message_body]
    message_date     = params[:message_date]
    image_url        = params[:image_url]
    index            = $redis.incr("message:index")

    message          =
      {
      name:          name,
      message_title: message_title,
      message_body:  message_body,
      message_date:  message_date,
      image_url:     image_url,
      id:            index
      }

    $redis.set("messages:#{index}", message.to_json)
    redirect to('/messages')
  end

  get('/messages/:id') do
    id            = params[:id]
    one_message   = $redis.get("messages:#{id}")
    @message      = JSON.parse(one_message)
    render(:erb, :"sup_messages/show", :layout => :template)
  end

  get('/messages/:id/edit') do
    id            = params[:id]
    message       = $redis.get("messages:#{id}")
    @message      = JSON.parse(message)
    render(:erb, :"sup_messages/edit", :layout => :template)
  end

  put('/messages/:id') do
    name              = params[:name]
    message_title     = params[:message_title]
    message_body      = params[:message_body]
    message_date      = params[:message_date]
    image_url         = params[:image_url]
    parse_url         = params[:parse_url]
    id                = params[:id]
    updated_message   =
      {
      name:           name,
      message_title:  message_title,
      message_body:   message_body,
      message_date:   message_date,
      image_url:      image_url,
      parse_url:      parse_url,
      id:             id
      }
    $redis.set("messages:#{id}", updated_message.to_json)
    redirect to("/messages/#{id}")
  end

  delete('/messages/:id') do
    id = params[:id]
    $redis.del("messages:#{id}")
    redirect to('/messages')
  end

  get('/as/:id') do
    content_type :json
    id = params[:id]
    @messages       = $redis.keys("*messages*").map { |posting| JSON.parse($redis.get(posting)) }
    one_message     = $redis.get("messages:#{id}")
    @message        = JSON.parse(one_message)
    {
      "name"          => @message["name"],
      "message_title" => @message["message_title"],
      "message_body"  => @message["message_body"],
      "message_date"  => @message["message_date"],
      "image_url"     => @message["image_url"],
    }.to_json
  end

  get('/rss') do
    content_type 'text/xml'
    messages = $redis.keys("*messages*").map { |posting| JSON.parse($redis.get(posting)) }
    rss = RSS::Maker.make("atom") do |maker|
      maker.channel.author = "Neil Sidhu"
      maker.channel.updated = Time.now.to_s
      maker.channel.about = "http://127.0.0.1:9292/rss"
      maker.channel.about = "http://localhost:9292"
      maker.channel.title = "Message"

      messages.each do |message|
        maker.items.new_item do |item|
          item.id         = message["id"].to_s
          item.link       = "/messages/#{message["id"]}"
          item.title      = "Just another message!"
          item.updated    = Time.now.to_s
        end
      end
    end
    rss.to_s
  end

  get('/logout') do
    session[:access_token] = nil
    redirect to("/")
  end

end
