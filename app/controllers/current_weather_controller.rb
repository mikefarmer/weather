# frozen_string_literal: true

class CurrentWeatherController < ApplicationController
  def show
    @invalid_location = false
    @query = session[:current_weather_query]
    @weather = CurrentWeather.find(@query) if @query.present?
  rescue WeatherApi::InvalidLocationError
    @weather = nil
    @invalid_location = true
  end

  def create
    session[:current_weather_query] = params[:query]

    redirect_to current_weather_path
  end
end
