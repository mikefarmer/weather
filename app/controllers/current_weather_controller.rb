class CurrentWeatherController < ApplicationController
  def show
    @query = session[:current_weather_query]
    @weather = CurrentWeather.find(@query, force: true)
  end

  def create
    session[:current_weather_query] = params[:query]

    redirect_to current_weather_path
  end
end
