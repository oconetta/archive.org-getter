require 'rubygems'
require 'open-uri'
require 'json'
require 'rest_client'
require 'csv'
require 'longurl'

#ask for filename, prop
puts "Are you in the directory in which the CSV file you want to use is located? Answer y/n"
yn = gets.chomp
  if yn.downcase != 'y'
    abort("Change to the directory and try again.")
  else
    puts "What is the filename? Write it with the .csv extension (for example, myfile.csv)"
    filename = gets.chomp
    puts "Which proposition are you working on?"
    prop = gets.chomp
  end

#set user agent
resp = RestClient.get 'http://api.longurl.org/v2/services', :user_agent => "http_expander/1.0"
if resp.code != 200 then puts "Server error" end

urls = []
search_critera = { 'text' => 'RT @CalWatchdog: NEW: Cal State illegally promotes Prop. 30 tax increase http://t.co/yXD1Vdnu' }
options = { :headers => :first_row }

headers = nil
matches = nil

CSV.open(filename.to_s, "r", options) do |csv|
  matches = csv.find_all do |row|
    match = true
    search_critera.keys.each do |key|
      match = match && ( row[key] == search_critera[key])
    end
  match
end
end

puts matches

abort

frequencies = Hash.new(0)
urls.each { |url| frequencies[url] += 1 }
frequencies = frequencies.sort_by { |a, b| b }
frequencies.reverse!
puts "For Prop. #{prop}:"
frequencies.each { |url, frequency| puts url + ": " + frequency.to_s }

#want to convert CSV/XLSX file into an array of hashes with their own keys and values
#search in body of text for http://t.co/
	#if it's there
		#set to url variable
		#change : to %3A
		#change / to %2F
		#use longurl to expand the link - RestClient.get 'http://api.longurl.org/v2/expand?url=URL HERE'
		#add to frequency 
	#if not, continue going through the array