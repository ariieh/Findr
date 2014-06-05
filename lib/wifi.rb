require 'json'
require 'addressable/uri'
require 'rest-client'

#free wifi locations NYC:
#https://data.cityofnewyork.us/api/views/4u6b-frhh/rows.json

class WifiFindr
  
  def initialize(address = "36 Cooper Square, New York, NY 10003")
    @url = "https://data.cityofnewyork.us/api/views/4u6b-frhh/rows.json"
    @address = address
    @zip = @address[-5..-1]
  end

  def locations
    #parse the results with JSON
    results = JSON.parse(RestClient.get(@url))
    
    #get only the addresses where the data matches 
    #up with free wifi and our zip code
    results = results["data"]
      .map { |location| location[9..-1] }
      .select { |result| result[6] == @zip && result[-2].strip == "Free" }
    
    #turns the location information into an address
    #that is then pumped into the google distance
    #api. a distance is then added to each location
    results.each do |location|
      destination_address = "#{location[1]}, #{location[2]}, NY #{location[6]}"
      
      request = Addressable::URI.new(
        :scheme => "https",
        :host => "maps.googleapis.com",
        :path => "maps/api/distancematrix/json",
        :query_values => {
          origins: @address,
          destinations: destination_address,
          mode: "walking"
        }
      ).to_s
      
      distances = JSON.parse(RestClient.get(request)) 
      location << distances["rows"][0]["elements"][0]["distance"]["text"].to_f
    end
    
    #sort results by shortest distance and then display
    #only the top 10
    results.sort! {|a, b| a[-1] <=> b[-1]}
    results[0..9]
  end
end

puts WifiFindr.new.locations