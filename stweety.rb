# stweety.rb - A simple Twitter command-line app.

require 'oauth'
require 'uri'
require 'net/http'
require 'openssl'
require 'json'


## 2. Parsing a User Object
## ------------------------
#
## Parse a response from the API and return a user object.
#def parse_user_response(response)
#  user = nil
#
#  # Check for a successful request
#  if response.code == '200'
#    # Parse the response body, which is in JSON format.
#    # ADD CODE TO PARSE THE RESPONSE BODY HERE
#    user = JSON.parse response.body
#
#    # Pretty-print the user object to see what data is available.
#    puts "Hello, #{user["screen_name"]}!"
#  else
#    # There was an error issuing the request.
#    puts "Expected a response of 200 but got #{response.code} instead"
#  end
#
#  user
#end
#
## Issue the request.
#request = Net::HTTP::Get.new address.request_uri
#request.oauth! $http, $consumer_key, $access_token
#response = $http.request request
#user = parse_user_response(response)
#

## 3. Reading a Tweet
## ------------------
#
## Now you will fetch /1.1/statuses/show.json, which
## takes an 'id' parameter and returns the
## representation of a single Tweet.
#path    = "/1.1/statuses/show.json"
#query   = URI.encode_www_form("id" => 266270116780576768)
#address = URI("#{$baseurl}#{path}?#{query}")
#request = Net::HTTP::Get.new address.request_uri
#
## Print data about a Tweet
#def print_tweet(tweet)
#  # ADD CODE TO PRINT THE TWEET IN "<screen name> - <text>" FORMAT
#  puts "#{tweet['user']['name']} - #{tweet['text']}"
#end
#
## Issue the request.
#request.oauth! $http, $consumer_key, $access_token
#response = $http.request request
#
## Parse and print the Tweet if the response code was 200
#tweet = nil
#if response.code == '200' then
#  tweet = JSON.parse(response.body)
#  print_tweet(tweet)
#end


## 4. Reading a Timeline
## ---------------------
#
## Now you will fetch /1.1/statuses/user_timeline.json,
## returns a list of public Tweets from the specified
## account.
#path    = "/1.1/statuses/user_timeline.json"
#query   = URI.encode_www_form(
#    "screen_name" => "twitterapi",
#    "count" => 10,
#)
#address = URI("#{$baseurl}#{path}?#{query}")
#request = Net::HTTP::Get.new address.request_uri
#
## Print data about a list of Tweets
#def print_timeline(tweets)
#  # ADD CODE TO ITERATE THROUGH EACH TWEET AND PRINT ITS TEXT
#  tweets.each do |tweet|
#    puts tweet['text']
#  end
#end
#
## Issue the request.
#request.oauth! $http, $consumer_key, $access_token
#response = $http.request request
#
## Parse and print the Tweet if the response code was 200
#tweets = nil
#if response.code == '200' then
#  tweets = JSON.parse(response.body)
#  print_timeline(tweets)
#end

# File that stores consumer key and access token in JSON
$keyfile = ".stweetkey"

# All requests will be sent to this server.
$baseurl = "https://api.twitter.com"

# Verifying credentials
def verify_credentials
  
  # Load credentials from a file. 
  creds = JSON.load File.open($keyfile, "r")
  
  # The consumer key identifies the application making the request.
  $consumer_key = OAuth::Consumer.new creds["ck"], creds["cks"]
  
  # The access token identifies the user making the request.
  $access_token = OAuth::Token.new creds["at"], creds["ats"]


  # The verify credentials endpoint returns a 200 status if
  # the request is signed correctly.
  path    = "/1.1/account/verify_credentials.json"
  address = URI "#{$baseurl}#{path}"

  # Build the request and authorize it with OAuth.
  request = Net::HTTP::Get.new address.request_uri
  request.oauth! $http, $consumer_key, $access_token

  # Issue the request and return the response.
  response = $http.request request
  puts "Response #{response.code} #{response.message}"

end

# Updates Twitter status.
def update_status(status)
  
  # You will need to set your application type to
  # read/write on dev.twitter.com
  
  # Note that the type of request has changed to POST.
  # The request parameters have also moved to the body
  # of the request instead of being put in the URL.
  path    = "/1.1/statuses/update.json"
  address = URI "#{$baseurl}#{path}"
  
  request = Net::HTTP::Post.new address.request_uri
  request.set_form_data "status" => status

  # Issue the request.
  request.oauth! $http, $consumer_key, $access_token
  response = $http.request request

  # Parse and print the Tweet if the response code was 200
  tweet = nil
  if response.code == '200' then
    tweet = JSON.parse response.body
    puts "Successfully sent \"#{tweet["text"]}\""
  else
    puts "Could not send the Tweet! "
    puts "Response: #{response.code} #{response.message}"
    error = JSON.parse response.body
    error["errors"].each do |err|
      puts "!!! Error #{err["code"]} : #{err["message"]}"
    end
  end

end


address = URI "#{$baseurl}"

# Set up Net::HTTP to use SSL, which is required by Twitter.
$http             = Net::HTTP.new address.host, address.port
$http.use_ssl     = true
$http.verify_mode = OpenSSL::SSL::VERIFY_PEER

$http.start

print "Verifing credentials... "
verify_credentials

#print "Enter new Twitter status: "
#tweet_text = gets.chomp
#
#update_status tweet_text


input = nil
until input == "/quit"
  print "\n[stweety]$ "
  input = gets.chomp
  if input[0] != '/'
    puts "Are you sure you want to post this: '#{input}'"
    answer = gets.chomp
    if answer[0] == 'y' || answer[0] == 'Y'
      update_status input
    end
  else
    puts "'#{input}' not implemented"
  end
end
