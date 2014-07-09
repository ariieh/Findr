require 'json'
require 'addressable/uri'
require 'rest-client'

class SearchItem < ActiveRecord::Base
  
  def self.full_address(address)
    #get full address and zip
    address_request = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/geocode/json",
      :query_values => {
        address: address,
      }
    ).to_s
    
    address_results = JSON.parse(RestClient.get(address_request))
    
    return nil if address_results["status"] == "ZERO_RESULTS"
    
    {
      address: address_results["results"][0]["formatted_address"],
      zip: address_results["results"][0]["address_components"].select{|hash| hash["types"][0] == "postal_code"}[0]["long_name"]
    }
  end
  
  def self.wifi_locations(address, zip)
    #free wifi locations NYC:
    @url = "https://data.cityofnewyork.us/api/views/4u6b-frhh/rows.json"

    @address = address
    @zip = zip
    
    #parse the URL results with JSON
    results = JSON.parse(RestClient.get(@url))
  
    #get only the addresses where the data matches 
    #up with free wifi and our zip code
    results = results["data"]
      .map { |location| location[9..-1] }
      .select { |result| result[6] == @zip && result[-2].strip == "Free" }
  
    #turns the location information into an address
    #that is then pumped into the google distance
    #api. a distance is then added to each location
    
    destination_addresses = ""
    results.each do |location|
      destination_addresses += "#{location[1]}, #{location[2]}, NY #{location[6]} |"
    end
      
    request = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/distancematrix/json",
      :query_values => {
        origins: @address,
        destinations: destination_addresses,
        mode: "walking"
      }
    ).to_s
  
    distances = JSON.parse(RestClient.get(request))
    
    results.each_with_index do |location, index|
      location << distances["rows"][0]["elements"][index]["distance"]["text"].to_f
    end
    
    #sort results by shortest distance and then display
    #only the top 10
    results.sort! {|a, b| a[-1] <=> b[-1]}
    results[0..9]
  end
  
  # turns out these aren't public!
  # def self.bathroom_locations(address)
  #   @url = "https://data.cityofnewyork.us/api/views/h87e-shkn/rows.json"
  #   address_results = self.full_address(address)
  #
  #   return nil unless address_results
  #
  #   @address = address_results[:address]
  #   @zip = address_results[:zip]
  #
  #   results = JSON.parse(RestClient.get(@url))
  # end

end
