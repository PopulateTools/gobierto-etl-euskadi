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

def extract_economic_codes(parsed_source_data, dimension_name, index:, kind:, area_name:)
  parsed_source_data.dimension(dimension_name).map do |category_name|
    code = BudgetCodeData.new(category_name, index:, kind:, area_name:)

    next unless code.present?

    { dimension_name => category_name, codes: { main: code } }
  end.compact
end

def extract_functional_codes(parsed_source_data, dimension_name, index:, kind:, area_name:)
  return [] if dimension_name.blank?

  parsed_source_data.dimension(dimension_name).map do |category_name|
    code = BudgetCodeData.new(category_name, functional: true, index:, kind:, area_name:)

    next unless code.present?

    { dimension_name => category_name, codes: { functional: code } }
  end.compact
end

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

economic_codes = extract_economic_codes(parsed_source_data, category_dimension, **file_metadata.slice(:index, :kind, :area_name))
functional_codes = extract_functional_codes(parsed_source_data, functional_dimension, **file_metadata.slice(:index, :kind, :area_name))

categories_args = if functional_codes.present?
                    economic_codes.product(functional_codes).map { |code1, code2| code1.deep_merge(code2) }
                  else
                    economic_codes
                  end

output_data = []
report = BudgetDataReport.new(file_key, total_codes: economic_codes.count * (functional_codes.count.positive? ? functional_codes.count : 1))

parsed_source_data.dimension(location_dimension).each do |location_name|
  location = BudgetLocationData.new(location_name, nil)
  # Skip not found locations (autonomous regions, provinces or not found
  # location names)
  next unless location.present?

  parsed_source_data.dimension(year_dimension).each do |year_name|
    location.year = year_name
    report.mark_year(year_name, ine_code: location.ine_code)

    categories_args.each do |categories_arg|
      single_data = categories_arg[:codes][:main].data.merge(location.data)
      amount = parsed_source_data.data(categories_arg.except(:codes).merge(location_dimension => location_name, year_dimension => year_name))

      if categories_arg[:codes].has_key?(:functional)
        single_data[:functional_code] = categories_arg[:codes][:functional].code
      end

      # Skip amounts not stored as numbers, i.e. \".\" and \"-\"
      if /\A\-?\d+\z/.match?(amount)
        single_data[:amount] = amount.to_f.round(2)

        if single_data[:population].try(:positive?)
          single_data[:amount_per_inhabitant] = (single_data[:amount] / single_data[:population]).round(2)
        end
        output_data << single_data
        report.register_data(single_data)
      end
    end
  end
end

report.print
File.write(output_file, output_data.to_json)
File.write(output_file + ".report.csv", report.report_text)

puts "[END] transform-px-data/run.rb"
