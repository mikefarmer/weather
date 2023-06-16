# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CurrentWeather' do
  describe 'GET /current_weather' do
    it 'loads the default page' do
      get current_weather_path
      expect(response).to have_http_status(:ok)
      expect(response).to have_rendered(:show)
    end

    it 'shows the weather for a given location' do
      post current_weather_path, params: { query: 'Zocca, IT' }
      expect(response).to redirect_to(current_weather_path)
      follow_redirect!
      expect(response.body).to include('test-id-weather-result')
    end
  end
end
