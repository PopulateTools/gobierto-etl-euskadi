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
#  - 0: Absolute path to a file containing a PX file
#  - 1: Absolute path of the output file
#
# Samples:
#
#   /path/to/project/operations/gobierto_budgets/transform-px-data/run.rb input.px output.json
#

if ARGV.length != 2
  raise "Wrong number of arguments"
end

input_file = ARGV[0]
output_file = ARGV[1]
file_key = File.basename(input_file).gsub("_utf8", "").split(".").first
locale = "es"

puts "[START] transform-px-data/run.rb with file=#{input_file} output=#{output_file}"

file_metadata = SourceFiles::FILES[file_key]
parsed_source_data = RubyPx::Dataset.new(input_file)

category_dimension = file_metadata[:category_economic_dimension][locale]
functional_dimension = file_metadata.dig(:category_functional_dimension, locale)
location_dimension = "ámbitos territoriales"
year_dimension = "periodo"

kounter = 0
output_data = []

parsed_source_data.dimension(location_dimension).each do |location_name|
  location = BudgetLocationData.new(location_name, nil)
  # Skip not found locations (autonomous regions, provinces or not found
  # location names)
  next unless location.present?

  parsed_source_data.dimension(year_dimension).each do |year_name|
    location.year = year_name
    parsed_source_data.dimension(category_dimension).each do |category_name|
      code = BudgetCodeData.new(category_name, **file_metadata.slice(:index, :kind, :area_name))

      # Skip not registered codes (summarized total codes)
      next unless code.present?

      categories_args = [{ category_dimension => category_name }]
      # Merge functional codes if file_metadata[:functional_component]

      categories_args.each do |categories_arg|
        single_data = code.data.merge(location.data)
        amount = parsed_source_data.data(categories_arg.merge(location_dimension => location_name, year_dimension => year_name) )

        # Skip amounts not stored as numbers, i.e. \".\" and \"-\"
        if /\A\-?\d+\z/.match?(amount)
          single_data[:amount] = amount.to_i

          if single_data[:population].try(:positive?)
            single_data[:amount_per_inhabitant] = (single_data[:amount].to_f / single_data[:population]).round(2)
          end
          output_data << single_data
        end
      end
    end
  end
end

File.write(output_file, output_data.to_json)
puts "[END] transform-px-data/run.rb"
