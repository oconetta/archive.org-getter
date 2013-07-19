require 'rubygems'
require 'json'
require 'pp'

#parse data from JSON files and store in array of hashes
tv_data = JSON.parse(File.read('TVNews_results200.json'))
tv_data += JSON.parse(File.read('TVNews_results400.json'))
tv_data += JSON.parse(File.read('TVNews_results600.json'))
tv_data += JSON.parse(File.read('TVNews_results800.json'))
tv_data += JSON.parse(File.read('TVNews_results1000.json'))

#create empty array to store snippets in
snippets = []

#take all titles from the hash and put them in a multidimensional array
titles = []
tv_data.each { |hash| hash["title"] }.each do |key, value|
  key.each do |k, v|
    if k == "title"
      v = v.split(" : ")
      titles.push(v)
    else
      nil
    end
  end 
end

#isolate the dates and put them in their own array
i = 0
dates = []
titles.each do |inner|
  inner.each do |date|
    #add blank entries to make sure the date is always the 3rd entry
    if inner.length == 2
      inner.insert(1, "")
    elsif inner.length == 1
      inner.insert(0, "")
      inner.insert(1, "")
    end
    #put the dates in their own array
    if i == 2
      dates.push(date)
      puts date
      i = 0
    else
      i += 1
    end
  end
end

#take all snippets from hash and put them in an array
tv_data.each { |hash| hash["snip"] }.each do |key, value|
  key.each do |k, v|
  	if k == "snip"
  	  snippets.push(v)
  	else
  	  nil
  	end
  end 
end

snippets = snippets.flatten

snippets.each do |snip|
  #get rid of bold tags from the snippets
  if snip.include?('<em>') then snip = snip.gsub!('<em>', "") end
  if snip.include?('</em>') then snip = snip.gsub!('</em>', "") end
	#make it easy to tell where snippets begin and end
  if snip == snippets[0]
		puts "FIRST SNIPPET: " + snip
	else
		puts "NEXT SNIPPET: " + snip
	end
end

dates_and_snips = Hash.new(0)

count = 0
while count < dates.length
  dates_and_snips[dates[count]] = snippets[count]
  count += 1
end

pp dates_and_snips