require 'rubygems'
require 'json'
require 'pp'

#parse data from JSON files and store in array of hashes
tv_data = JSON.parse(File.read('TVNews_results200.json'))
tv_data += JSON.parse(File.read('TVNews_results400.json'))
tv_data += JSON.parse(File.read('TVNews_results600.json'))
tv_data += JSON.parse(File.read('TVNews_results800.json'))
tv_data += JSON.parse(File.read('TVNews_results1000.json'))

#create empty array to store topics in
topics = []

tv_data.each { |hash| hash["topic"] }.each do |key, value|
  key.each do |k, v|
  	if k == "topic"
  	  topics.push(v)
  	else
  	  nil
  	end
  end 
end

#array of a hash of an array of strings

topics = topics.flatten

frequencies = Hash.new(0)
topics.each { |word| frequencies[word] += 1 }
frequencies = frequencies.sort_by { |a, b| b }
frequencies.reverse!
frequencies.each { |word, frequency| puts word + ": " + frequency.to_s }