module SMHIService
  API_URL = 'https://opendata-download-metfcst.smhi.se/api'.freeze

  def self.get_forecast(city, country = 'Sweden')
    begin
      lat, lon = Geocoder.coordinates("#{city}, #{country}")
      feed = HTTParty.get("#{API_URL}/category/pmp3g/version/2/geotype/point/lon/#{lon.round(5)}/lat/#{lat.round(5)}/data.json")
      build_forecast_array(feed)
    rescue
      {message: 'Could not perform operation'}
    end
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

  def self.build_forecast_array(feed)
    forecast_feed = []
    feed['timeSeries'][0..11].each do |obj|
      time = DateTime.parse(obj['validTime']).strftime('%H:%M')
      weather_value = obj['parameters'].detect {|obj| obj['name'] == 'Wsymb2'}['values'].first
      weather_in_words = parse_current_weather_value(weather_value)
      wind_value = obj['parameters'].detect {|obj| obj['name'] == 'wd'}['values'].first
      wind_direction = degrees_to_direction(wind_value)
      wind_speed = obj['parameters'].detect {|obj| obj['name'] == 'ws'}['values'].first
      temperature = obj['parameters'].detect {|obj| obj['name'] == 't'}['values'].first
      forecast_feed.push({time: time,
                          forecast: weather_in_words,
                          temperature: temperature,
                          wind_direction: wind_direction,
                          wind_speed: wind_speed})
    end
    forecast_feed
  end

  def self.degrees_to_direction(num)
    val = (num/22.5) + 0.5
    arr = %w(N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW)
    arr[(val % 16)]
  end

end
