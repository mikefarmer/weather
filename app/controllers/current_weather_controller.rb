# frozen_string_literal: true

class CurrentWeatherController < ApplicationController
  def show
    @query = session[:current_weather_query]
    @weather = CurrentWeather.find(@query) if @query.present?
  end

  def create
    session[:current_weather_query] = params[:query]

    redirect_to current_weather_path
  end
end
