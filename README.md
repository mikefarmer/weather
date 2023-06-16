# Weather Application

## Setup Instructions
1. Make sure you have ruby 3.2.x installed.
2. Clone this repository.
3. Run `bundle install` to install all the required gems.
4. Run `bin/setup` to setup your local environment
4. Run `bin/dev` to start the server.

## Running Tests
1. Run `rake rspec` to run all the tests.

## Rubocop
1. Run `rubocop` to run rubocop.

## Points of interest

* You can toggle caching on and off by running `rails dev:cache`
* The requirement to cache based on zip code does not work well with the OpenWeatherApi because 
   it would require multiple api calls to ensure every query has an associated zip code.
   I didn't realize this until I had already built an API wrapper so I decided to cache by
   query instead.
* I used the new `Data` class to store the data returned from the API. This requires ruby 3.2.x 
* I used Rails credentials to store the API key. To add your own API Key you can run `rails credentials:edit` to use your own API key.