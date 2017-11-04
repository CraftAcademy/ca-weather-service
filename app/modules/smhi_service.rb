module SMHIService
  API_URL = 'https://opendata-download-metfcst.smhi.se/api'.freeze
  def self.get_forecast(city, country = 'Sweden')
    lat, lon = Geocoder.coordinates("#{city}, #{country}")
    feed = HTTParty.get("#{API_URL}/category/pmp3g/version/2/geotype/point/lon/#{lon.round(5)}/lat/#{lat.round(5)}/data.json")
    temperature = feed.parsed_response['timeSeries'].first['parameters'].detect { |obj| obj['name'] == 't' }['values'].first
    current_weather_value = feed.parsed_response['timeSeries'].first['parameters'].detect { |obj| obj['name'] == 'Wsymb2' }['values'].first
    current_weather_in_words = parse_current_weather_value(current_weather_value)
    { forecast: current_weather_in_words, temperature: "#{temperature}℃" }
  rescue
    { message: 'Could not perform operation' }
  end

  def self.parse_current_weather_value(value)
    values = [
      'Clear sky',
      'Nearly clear sky',
      'Variable cloudiness',
      'Halfclear sky',
      'Cloudy sky',
      'Overcast',
      'Fog',
      'Light rain showers',
      'Moderate rain showers',
      'Heavy rain showers',
      'Thunderstorm',
      'Light sleet showers',
      'Moderate sleet showers',
      'Heavy sleet showers',
      'Light snow showers',
      'Moderate snow showers',
      'Heavy snow showers',
      'Light rain',
      'Moderate rain',
      'Heavy rain',
      'Thunder',
      'Light sleet',
      'Moderate sleet',
      'Heavy sleet',
      'Light snowfall',
      'Moderate snowfall',
      'Heavy snowfall'
    ]
    values[value - 1]
  end
end
