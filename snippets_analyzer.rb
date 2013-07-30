require 'csv'
require 'fileutils'
require 'pp'
load 'date_and_snippet.rb'

#check for right directory
puts 'This script will not work unless you are in the folder that contains the folder your CSV files are located in.'
puts 'Are you in that folder? Answer n if not, any other letter if so.'
yn = gets.chomp
yn = yn.downcase!
if yn == 'n' then abort('Add the files to this directory and try again.') end

#pick the correct folder with the CSV data
puts 'Here are the files in this directory:'
puts Dir.glob('*')
puts 'Write the name of the folder you want to work from EXACTLY as it is shown:'
folder_name = gets.chomp
#note: path names cannot have spaces

#read CSV files
path = FileUtils.pwd + '/' + folder_name + '/'
files_in_path = Dir.entries(path)
files_in_path.delete_if { |file| !file.include?('csv') }
files_in_path.each do |file|
end

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
yn_2 = gets.chomp
yn_2 = yn_2.downcase!
if yn_2 != 'n'
	puts 'Enter your extra search terms. Separate each one by a comma and a space:'
	new_search_terms = gets.chomp
	new_search_terms = new_search_terms.split(', ')
	search_terms = search_terms.concat(new_search_terms)
end

pp search_terms
#ask user for proposition
#switch statement with number of proposition and that gives you key words to look at
#user can plug in any word and see how frequency changes over time
	#have set options for each proposition and option to add any extra words

	#look for n-grams

#most frequent words total
#most frequent words as time changes (by week, 12 week)
#observe how frequency of word we pick changes

#output item to hash IF item is not a stopword

#sort by source