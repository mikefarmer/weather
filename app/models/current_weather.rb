# frozen_string_literal: true

# Weather model for the API data from the WeatherAPI
class CurrentWeather
  Main = Data.define(:temp, :feels_like, :temp_min, :temp_max, :pressure, :humidity)
  Wind = Data.define(:speed, :deg, :gust)
  Coord = Data.define(:lon, :lat)
  Description = Data.define(:id, :main, :description, :icon)

  attr_reader :main, :wind, :coord, :description, :location_name

  def self.find(query, force: false)
    return new(query) if force

    Rails.cache.fetch("weather/#{query}", expires_in: 30.minutes) do
      new(query)
    end
  end

  def initialize(query)
    @query = query
    @json = WeatherApi.new.current_weather(query)
    build_data
  end

  def as_json
    {
      main: @main.as_json,
      wind: @wind.as_json,
      coord: @coord.as_json,
      description: @description.as_json,
      location_name: @location_name
    }
  end

  def to_json(*_args)
    as_json.to_json
  end

  def to_s
    "Temperature in #{location_name}: #{main.temp}, feels Like: #{main.feels_like} with #{description.description}"
  end

  def inspect
    to_s
  end

  def icon_url
    "https://openweathermap.org/img/w/#{description.icon}.png"
  end

  def cache_key
    "weather/#{@query}"
  end

  private

  def build_data
    @json.deep_symbolize_keys!
    main = @json[:main].except(:sea_level, :grnd_level)
    wind = @json[:wind]
    wind[:gust] ||= 0
    weather = @json[:weather].first

    @main = Main.new(**main)
    @wind = Wind.new(**wind)
    @coord = Coord.new(**@json[:coord])
    @description = Description.new(**weather)
    @location_name = @json[:name]
  rescue StandardError => e
    Rails.logger.error("Error building weather data: #{e.message}")
  end
end
