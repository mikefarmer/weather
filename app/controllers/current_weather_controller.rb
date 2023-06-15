class CurrentWeatherController < ApplicationController
  def show
    @zipcode = session[:current_location_zip_code]
  end

  def create
    # TODO: Get the current weather from the OpenWeather API

    session[:current_location_zip_code] = params[:zipcode]

    redirect_to current_weather_path
  end
end
