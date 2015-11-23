# config/initializers/geocoder.rb
Geocoder.configure(
  # geocoding service
  lookup: :google,

  # geocoding service request timeout (in seconds)
  timeout: 240,

  # default units
  units: :km
)