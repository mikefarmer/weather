require 'rails_helper'

RSpec.describe 'CurrentWeather', type: :request do
  describe 'GET /current_weather' do
    it 'loads the default page' do
      get current_weather_path
      expect(response).to have_http_status(200)
      expect(response).to have_rendered(:show)
    end
  end
end
