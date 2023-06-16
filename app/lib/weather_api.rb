# frozen_string_literal: true

# Wrapper for the open-weather-api gem
class WeatherApi
  class HTTPError < StandardError; end
  class InvalidLocationError < StandardError; end

  CURRENT_BASE_URL = 'https://api.openweathermap.org/data/2.5/weather'
  GEO_BASE_URL = 'https://api.openweathermap.org/geo/1.0/direct'
  ZIP_GEO_BASE_URL = 'https://api.openweathermap.org/geo/1.0/zip'

  # Matches a US zip code or an international postal code
  POSTAL_CODE_ONLY_REGEX = /\A\d{5}(-\d{4})?\z/

  def initialize
    @api_key = Rails.application.credentials.open_weather_api_key
  end

  # Generate a latitude and longitude has from a city, state, and zip code string
  # @param city_state_zip [String] A string containing the city, state, and zip code
  # @return [Hash] A hash containing the latitude and longitude
  # @raise [ArgumentError] If the city_state_zip parameter is invalid
  def location(city_state_zip)
    raise ArgumentError, 'Invalid city state or zip' if city_state_zip.blank?

    json = if city_state_zip.match?(POSTAL_CODE_ONLY_REGEX)
             request_lat_long_from_zip(city_state_zip)
           else
             request_lat_log(city_state_zip)&.first
           end

    raise InvalidLocationError, 'Invalid location' if json.blank?

    {
      lat: json['lat'],
      lon: json['lon']
    }
  end

  # Get the current weather for a given location
  # @param city_state_zip [String] A string containing the city, state, and zip code
  # @return [Hash] A hash containing the current weather data
  def current_weather(city_state_zip)
    loc = location(city_state_zip)
    json = request_current_weather(loc)
    raise InvalidLocationError, 'Invalid location' if json.blank?

    json
  end

  private

  def build_params(params = {})
    {
      appid: @api_key
    }.merge(params)
  end

  def request_current_weather(location)
    uri = URI(CURRENT_BASE_URL)
    params = build_params(location).merge({ units: 'imperial' })
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    check_and_parse_response(response)
  end

  def request_lat_long_from_zip(zip)
    uri = URI(ZIP_GEO_BASE_URL)
    params = build_params({ zip: })
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    check_and_parse_response(response)
  end

  def request_lat_log(city_state_zip)
    uri = URI(GEO_BASE_URL)
    params = build_params({ q: city_state_zip, limit: 1 })
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    check_and_parse_response(response)
  end

  def check_and_parse_response(response)
    case response
    when Net::HTTPSuccess
      JSON.parse(response.body || '{}')
    when Net::HTTPNotFound
      nil
    else
      raise HTTPError, response
    end
  rescue JSON::ParserError
    raise HTTPError, 'Invalid json response from OpenWeather API'
  end
end
