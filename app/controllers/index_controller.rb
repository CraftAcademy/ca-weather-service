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
  if forecast[:message]
    @current_forecast = forecast[:message]
  else
    @current_forecast = "Conditions in #{city} are #{forecast[:forecast]} with a temperature of #{forecast[:temperature]}"
    @current_forecast += "\n\n#{APP_NAME} is a service from Craft Academy"
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
