# frozen_string_literal: true

# Weather model for the API data from the WeatherAPI
class CurrentWeather
  Main = Data.define(:temp, :feels_like, :temp_min, :temp_max, :pressure, :humidity)
  Wind = Data.define(:speed, :deg, :gust)
  Coord = Data.define(:lon, :lat)
  Description = Data.define(:id, :main, :description, :icon)

  attr_reader :main, :wind, :coord, :description, :location_name

  def self.cache_key(query)
    "weather/#{query}"
  end

  def self.find(query, force: false)
    json = Rails.cache.read(cache_key(query))
    if force || json.blank?
      json = WeatherApi.new.current_weather(query)
      obj = new(query, json)
      obj.cached = false
      obj.cache!
    else
      obj = new(query, json)
      obj.cached = true
    end

    obj
  end

  attr_accessor :cached

  def initialize(query, json)
    @json = json
    @cached = false
    @query = query
    build_data
  end

  def cache!
    Rails.cache.write(CurrentWeather.cache_key(@query), @json, expires_in: 30.minutes)
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

  private

  def build_data
    @json.deep_symbolize_keys!
    weather_data = @json[:weather].first

    @main = Main.new(**main_data)
    @wind = Wind.new(**wind_data)
    @coord = Coord.new(**@json[:coord])
    @description = Description.new(**weather_data)
    @location_name = @json[:name]
  rescue StandardError => e
    Rails.logger.error("Error building weather data: #{e.message}")
  end

  def wind_data
    @wind_data ||= { gust: 0 }.merge(@json[:wind])
  end

  def main_data
    @main_data ||= @json[:main].except(:sea_level, :grnd_level)
  end
end
