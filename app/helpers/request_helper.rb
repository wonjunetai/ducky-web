require 'rubygems'
require 'geoip'
require 'google-search'
# require 'google_places'

module RequestHelper

  def get_image(image_url)
    if !image_url.include? "missing.png" #Image is present
      image_tag image_url
    else
      image_tag "emptyducky.jpeg"
    end 
  end

  def find_item(query)
    result = Google::Search::Image.new(query: query, :image_size => small)
    result
  end
  
  def format_output(req_desc) #Gets request.description
  	#The purpose of this function is to prevent overflow of the text
  	#box due to extremely long words
  	#This will be rare if the users aren't fudging up the spacebar
  	#and are not deliberately trying to screw with things
    
    #The textbox can comfortably fit 15 m characters or like 50 i's
    desc_array = req_desc.try(:split, " ")
    desc_array.try(:each) do |word|
    	
    	mult15 = (word.length/15).floor #Length of word in multiples of 15. A 34 character word as a mult15 length of 2
    	
    	if mult15 > 0

    		for i in 1..mult15
    			word.insert(15*i, "\n")
   	 		end

   	 	end
    end
    description = desc_array.try(:join, " ")
    return description
  end 

  def get_location_data(ip)
    db = GeoIP.new(Rails.root.join('app', 'assets', 'dbs', 'GeoLiteCity.dat'))
    location = db.city(ip)
    location.city_name + ", " + location.region_name
  end

  # def spots_near(latitude, longitude)
  #   @client = GooglePlaces::Client.new('AIzaSyDatDsGReYLjSVZ2QUM4Nzv0FMoKznYZfA')
  #   @client.spots(latitude, longitude, :radius => 100, :language => 'en')
  # end

  # def places_near_ip(ip)
  #   location = get_location_data(ip)
  #   spots_near(location.latitude, location.longitude)
  # end

end