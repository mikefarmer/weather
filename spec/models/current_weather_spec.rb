# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrentWeather do
  let(:valid_json) do
    {
      coord: {
        lon: 10.99,
        lat: 44.34
      },
      weather: [
        {
          id: 501,
          main: 'Rain',
          description: 'moderate rain',
          icon: '10d'
        }
      ],
      base: 'stations',
      main: {
        temp: 298.48,
        feels_like: 298.74,
        temp_min: 297.56,
        temp_max: 300.05,
        pressure: 1015,
        humidity: 64,
        sea_level: 1015,
        grnd_level: 933
      },
      visibility: 10_000,
      wind: {
        speed: 0.62,
        deg: 349,
        gust: 1.18
      },
      rain: {
        '1h': 3.16
      },
      clouds: {
        all: 100
      },
      dt: 1_661_870_592,
      sys: {
        type: 2,
        id: 2_075_663,
        country: 'IT',
        sunrise: 1_661_834_187,
        sunset: 1_661_882_248
      },
      timezone: 7200,
      id: 3_163_858,
      name: 'Zocca',
      cod: 200
    }
  end

  let(:weather_api) { instance_double(WeatherApi, current_weather: valid_json) }

  context 'when building the model' do
    before do
      allow(WeatherApi).to receive(:new).and_return(weather_api)
    end

    it 'builds successfully' do
      expect { described_class.new(valid_json) }.not_to raise_error
    end
  end
end
