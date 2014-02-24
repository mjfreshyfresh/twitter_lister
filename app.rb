require 'json'
require 'net/http'
require 'uri'
require 'oauth'
require './secret.rb'

# Use TWITTER_HANDLES stored in secret.rb for screen_name param
# Couldn't get regex to collect TWITTER_HANDLES, created array by hand - d'oh!
baseurl = "https://api.twitter.com"
path    = "/1.1/users/lookup.json"
query   = URI.encode_www_form("screen_name" => TWITTER_HANDLES)
address = URI("#{baseurl}#{path}?#{query}")
request = Net::HTTP::Get.new(address.request_uri)

# Set up HTTP
http             = Net::HTTP.new(address.host, address.port)
http.use_ssl     = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

# CONSUMER_KEY and ACCESS_TOKEN stored in secret.rb
request.oauth!(http, CONSUMER_KEY, ACCESS_TOKEN)
http.start
response = http.request(request)

# Create a JSON representation of the members' info
data = JSON.parse(response.body)

# Convert JSON array to string and split into separate words
bio = data.map { |h| h["description"].downcase }
bio_string = bio.join(" ")
words = bio_string.split(/\W+/)

# Create hash to sort word frequencies 
frequencies = Hash.new(0)
words.each { |word| frequencies[word] += 1 }
frequencies = frequencies.sort_by {|a, b| b }
frequencies.reverse!

# Convert data back to JSON to save as JavaScript object
zen_masters = JSON.generate(frequencies)
puts zen_masters
  	
# Use d3 to illustrate findings
