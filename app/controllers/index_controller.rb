get '/' do
  get_forecast(params)
  erb :index
end

post '/sms' do
  city, country = parse_incoming_sms(params)
  get_forecast({city: city, country: country})
  reply_to_sms(@current_forecast)
end

def get_forecast(params = {})
  forecast = SMHIService.get_forecast(city = params[:city], country = params[:country])
  if invalid_response?(forecast)
    @current_forecast = forecast[:message]
  else
    @current_forecast = "Conditions in #{city} for the upcoming #{forecast.size} hours:"
    forecast.each do |slot|
      @current_forecast += slot_message(slot)
    end
    @current_forecast += "\n\nWeather-SMS is a service from Craft Academy"
  end
end

def reply_to_sms(message_body)
  twiml = Twilio::TwiML::MessagingResponse.new do |reply|
    reply.message(body: message_body)
  end
  twiml.to_s
end

def parse_incoming_sms(params)
  params['Body'].gsub(' ', '').split(',')
end

def invalid_response?(response)
  response.is_a? Hash and response.key?(:message)
end

def slot_message(slot)
  "\n - #{slot[:time]}: #{slot[:forecast]}, #{slot[:temperature]}℃, with #{slot[:wind_direction]} winds up to #{slot[:wind_speed]} meters/second"
end