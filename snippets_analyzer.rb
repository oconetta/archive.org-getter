require 'csv'
require 'fileutils'
require 'pp'
load 'date_and_snippet.rb'

#DEFINE METHODS

class Hash
	#method to write results to file
	def write_to_csv
		puts 'Enter a name for the file:'
		file_name = gets.chomp.gsub(' ', '_')
		path = FileUtils.pwd
		FileUtils.mkdir_p(path) unless File.exists?(path)
		new_file = File.new(path + '/' + file_name + '.csv', 'w')
		csv_string = CSV.generate do |csv|
		  self.each do |key, value|
		    csv << [key, value]
		  end
		end
		new_file.write(csv_string)
		new_file.close
		if File.exists?(path)
			puts 'CSV export successful!'
		else
			puts 'CSV export failed'
		end
	end
end

csv_array = []
#method to read from multiple CSV files and store in array
def csv_to_array(folder, array)
	files_array = []
	#get file path
	path = FileUtils.pwd + '/' + folder + '/'
	files_in_path = Dir.entries(path)
	files_in_path.delete_if { |file| !file.include?('csv') }
	files_in_path.each do |file|
		text = File.read(path + file)
		text = text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
		text = text.gsub(/\\\"/, "\"\"")
		CSV.parse(text, {:col_sep => ',', :quote_char => '"'}) do |entry|
			entry = DateAndSnippet.new(entry[0], entry[1])
			array.push(entry)
		end
	end
	array = array.flatten
	return array
end

#get rid of non-word comments; downcap all letters
def preprocess(string)
	string = string.gsub(/\W/, ' ')
	string = string.downcase
	return string
end

#method to find most frequent words total in the snippets
def find_frequent_words(date_and_snippet_array) # has to be passed a DateAndSnippet array
	snippet_array = []
	frequencies = Hash.new(0)
	file = File.read(FileUtils.pwd + '/stopwords.txt')
	stopwords = file.split(' ')
	date_and_snippet_array.each do |entry|
		text = entry.text
		text = preprocess(text).split(' ')
		snippet_array.push(text)
	end
	snippet_array = snippet_array.flatten
	snippet_array.each do |word|
		not_found = true
		stopwords.each do |stopword|
			if word == stopword
				snippet_array.delete(word) 
				not_found = false
			end	
		end
		if not_found then frequencies[word] += 1 end
	end
	frequencies = frequencies.sort_by { |a, b| b }
	frequencies = Hash[frequencies.reverse!]
	return frequencies
end

#sort the array by week
def sort_array_by_week(date_and_snippet_array)
	return date_and_snippet_array if date_and_snippet_array.size <= 1
	swapped = true
	while swapped do
		swapped = false
		0.upto(date_and_snippet_array.size-2) do |i|
			if date_and_snippet_array[i].date > date_and_snippet_array[i+1].date
				date_and_snippet_array[i], date_and_snippet_array[i+1] = date_and_snippet_array[i+1], date_and_snippet_array[i+1]
				swapped = true
			end
		end
	end
	return date_and_snippet_array
end

#search for a particular term
def search_for_terms(date_and_snippet_array)
	search_terms = []
	puts 'Which proposition are you working on? Give a number.'
	prop_num = gets.chomp.to_i
	case prop_num
		when 30
			prop_30_search_terms = ['jerry brown', 'tax', 'tax increase', 'millionaires', 'children', 'schools', 'charles munger', 'education funding', 'yes on 30', 'no on 30', 'yes on 38', 'no on 38']
			search_terms = search_terms.concat(prop_30_search_terms)
		when 34
			prop_34_search_terms = ['death penalty', 'california death penalty', 'safe california', 'repeal', 'inmates', 'yes on 34', 'no on 34']
			search_terms = search_terms.push(prop_34_search_terms).flatten
		when 36
			prop_36_search_terms = ['yes on 36', 'no on 36', 'shane taylor', 'charlie beck', 'three strikes reform', 'softening three strikes', 'michael romano', 'three strikes project', 'california watch', 'george gascon', 'steve cooley', 'mike reynolds', 'kimber reynolds']
			search_terms = search_terms.push(prop_36_search_terms).flatten
		when 37
			prop_37_search_terms = ['monsanto', 'fight', 'gmo', 'gmo reform', 'your right to know', 'information', 'yes on 37', 'no on 37', 'nestle']
			search_terms = search_terms.push(prop_37_search_terms).flatten
		when 38
			prop_38_search_terms = ['molly munger', 'charles munger', 'yes on 38', 'no on 38', 'no on 30', 'yes on 30', 'tax', 'millionaires', 'tax increase']
			search_terms = search_terms.push(prop_38_search_terms).flatten
		else
			abort('Not a valid proposition. Start the script over.')
	end

	puts 'Terms to search TV data for: '
	pp search_terms
	puts 'Would you like to add any more search terms?'
	puts 'Enter n if not; enter any other letter if yes'
	yn = gets.chomp
	yn = yn.downcase
	if yn != 'n'
		puts 'Enter your extra search terms. Separate each one by a comma and a space:'
		new_search_terms = gets.chomp
		new_search_terms = new_search_terms.downcase
		new_search_terms = new_search_terms.split(', ')
		search_terms = search_terms.concat(new_search_terms)
	elsif yn == 'n'
		nil
	end

	frequencies = Hash.new(0)
	snippet_array = []
	date_and_snippet_array.each do |entry|
		text = entry.text
		text = preprocess(text).split(' ')
		snippet_array.push(text)
	end
	snippet_array = snippet_array.flatten
	matches = []
	snippet_array.each do |word|
		if search_terms.include?(word) then frequencies[word] += 1 end
	end
	frequencies = frequencies.sort_by { |a, b| b }
	frequencies = Hash[frequencies.reverse!]
	return frequencies
end

#output an array to CSV
def write_date_and_snippet_to_csv (date_and_snippet_array)
	#output array to CSV
	puts 'Enter a name for the file:'
	file_name = gets.chomp.gsub(' ', '_')
	path = FileUtils.pwd
	FileUtils.mkdir_p(path) unless File.exists?(path)
	new_file = File.new(path + '/' + file_name + '.csv', 'w')
	csv_string = CSV.generate({:col_sep => ',', :quote_char => '"'}) do |csv|
	  #sort the array by date
	  date_and_snippet_array.sort.each do |entry|
	    csv << [entry.date, entry.text]
	  end
	end
	new_file.write(csv_string)
	new_file.close
end

#RUN PROGRAM

#check for right directory
puts 'This script will not work unless you are in the folder that contains the folder your CSV files are located in.'
puts 'Are you in that folder? Answer n if not, any other letter if so.'
yn = gets.chomp
yn = yn.downcase
if yn == 'n' then abort('Add the files to this directory and try again.') end

#pick the correct folder with the CSV data
puts 'Here are the files in this directory:'
puts Dir.glob('*')
puts 'Write the name of the folder you want to work from EXACTLY as it is shown:'
folder_name = gets.chomp
#note: path and file names cannot have spaces

csv_array = csv_to_array(folder_name, csv_array)
frequent_words = find_frequent_words(csv_array)
#frequent_words.write_to_csv
sorted_dates = sort_array_by_week(csv_array)
#write_date_and_snippet_to_csv(sorted_dates)
terms = search_for_terms(sorted_dates)
terms.write_to_csv