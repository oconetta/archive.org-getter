require 'json'
require 'fileutils'
require 'csv'
load 'date_and_snippet.rb'

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
end

#if the # of items in dates != the # of items in snippets...
if dates.length != snippets.length
  #abort, because the rest of the program won't work!
  abort("We don't have the same amount of dates and snippets!")
end

#array to hold instances of DateAndSnippet
dates_and_snips_array = []

#add DateAndSnippet instances to array
count = 0
while count < dates.length
  entry = DateAndSnippet.new(dates[count], snippets[count])
  dates_and_snips_array.push(entry)
  count += 1
end

#to add to file name
puts 'Which ballot proposition are you working on? (Type a number.)'
ballot_prop = gets.chomp

#output array to CSV
path = FileUtils.pwd
FileUtils.mkdir_p(path) unless File.exists?(path)
new_file = File.new(path + '/Dates_and_Snippets_for_Prop' + ballot_prop.to_s + '.csv', 'w')
csv_string = CSV.generate({:col_sep => ',', :quote_char => '"'}) do |csv|
  #sort the array by date
  dates_and_snips_array.sort.each do |entry|
    csv << [entry.date, entry.text]
  end
end
new_file.write(csv_string)
new_file.close
