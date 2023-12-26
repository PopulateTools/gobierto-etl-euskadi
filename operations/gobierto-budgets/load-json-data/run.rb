#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

require_relative "../../../utils/source_files.rb"
require "json"

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Absolute path to a file containing a JSON file
#  - 1: Absolute path to a file to store the years with data. This file can
#       exists and will be updated with new years if required
#
# Samples:
#
#   /path/to/project/operations/gobierto_budgets/load-json-data/run.rb data.json years.txt
#

if ARGV.length != 2
  raise "Wrong number of arguments"
end

input_file = ARGV[0]
years_file = ARGV[1]

puts "[START] load-json-data/run.rb with file=#{input_file} and years_file=#{years_file}"

file_key = File.basename(input_file).split(".").first
file_metadata = SourceFiles::FILES[file_key]
index = file_metadata[:index]
parsed_source_data = JSON.parse(File.read(input_file))
puts "  - Importing \"#{file_metadata[:title]}\" for index=#{index} kind=#{file_metadata[:kind]} type=#{file_metadata[:area_name]}"

years_list = File.exist?(years_file) ? File.read(years_file).split.map(&:to_i) : []
new_years = []

grouped_data = parsed_source_data.group_by { |item| item["year"].to_i }.reject { |k, _v| k < 2010 }

grouped_data.each do |year, data|
  nitems = GobiertoBudgetsData::GobiertoBudgets::BudgetLinesImporter.new(index:, year:, data:).import!
  puts "  ---- Imported #{nitems} items for year=#{year}"
  new_years << year if years_list.exclude?(year)
end

if new_years.present?
  years_list = (years_list + new_years).sort
  File.write(years_file, years_list.join(" "))
end

puts "[END] load-json-data/run.rb"
