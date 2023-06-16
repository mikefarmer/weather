# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherApi do
  subject { described_class.new }

  context 'when geocoding a location' do
    let(:valid_location) { 'Beverly Hills, CA 90210' }
    let(:valid_location_response) { [{ 'lat' => 34.0901, 'lon' => -118.4065 }] }

    before do
      success = Net::HTTPSuccess.new(1.0, 200, 'OK')
      allow(success).to receive(:body) { valid_location_response.to_json }
      allow(Net::HTTP).to receive(:get_response) { success }
    end

    it 'converts a location description of city/state/zip to a latitude and longitude' do
      response = subject.location(valid_location)
      expect(response).to match({ lat: an_instance_of(Float), lon: an_instance_of(Float) })
    end

    it 'converts a zip code to a latitude and longitude' do
      expect(subject).to receive(:request_lat_long_from_zip)
        .with('90210')
        .and_return(valid_location_response.first)

      response = subject.location('90210')
      expect(response).to match({ lat: an_instance_of(Float), lon: an_instance_of(Float) })
    end
  end

  context 'when getting the weather for a zipcode' do
    let(:valid_current_weather_response) { { 'temp' => 72.0 } }

    before do
      success = Net::HTTPSuccess.new(1.0, 200, 'OK')
      allow(success).to receive(:body) { valid_current_weather_response.to_json }
      allow(Net::HTTP).to receive(:get_response) { success }
    end

    it 'returns a weather model' do
      result = subject.current_weather('90210')
      expect(result).to match({ 'temp' => an_instance_of(Float) })
    end
  end

  context 'when any request is unsuccessful' do
    it 'raises a json parser error when the response is not json' do
      success = Net::HTTPSuccess.new(1.0, 200, 'OK')
      allow(success).to receive(:body) { 'not json' }
      allow(Net::HTTP).to receive(:get_response) { success }
      expect { subject.location('90210') }.to raise_error(WeatherApi::HTTPError)
    end

    it 'raises an HTTPError when the response is unknown' do
      failure = Net::HTTPBadGateway.new(1.0, 502, 'Bad Gateway')
      allow(Net::HTTP).to receive(:get_response) { failure }
      expect { subject.location('90210') }.to raise_error(WeatherApi::HTTPError)
    end

    it 'raises an InvalidLocationError when the response is not found' do
      failure = Net::HTTPNotFound.new(1.0, 404, 'Not Found')
      allow(Net::HTTP).to receive(:get_response) { failure }
      expect { subject.location('90210') }.to raise_error(WeatherApi::InvalidLocationError)
    end
  end
end
