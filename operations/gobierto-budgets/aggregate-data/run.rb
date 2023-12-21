#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

require_relative "../../../utils/source_files.rb"
require "json"

# Usage:
#
#  - Must be ran as an independent Ruby script
#  - This operation aggegates data of economic and functional codes from a json
#    with both codes and generates 2 files for them
#
# Arguments:
#
#  - 0: Absolute path to a file containing a PX file
#  - 1: Absolute path of the output file
#
# Samples:
#
#   /path/to/project/operations/gobierto_budgets/transform-px-data/run.rb input.json output.json
#
# The operation will generate 2 files, output_economic.json and output_functional.json

DIMENSIONS = {
  economic: {
    aggregated_key: "functional_code",
    keys: %w(code level parent_code),
    area_name: GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_AREA_NAME
  },
  functional: {
    aggregated_key: "code",
    keys: %w(functional_code),
    recalculate_code: "functional_code",
    area_name: GobiertoBudgetsData::GobiertoBudgets::FUNCTIONAL_AREA_NAME
  }
}

FIRST_GROUP = %w(kind type organization_id ine_code province_id autonomy_id year population)

# This method merges 2 data hashes in one, calculates amount by population if
# population is present and extracts functional code if opts contains a
# recalculate_code key
def unify(hash1, hash2, opts = {})
  data = hash1.merge(hash2)
  if data["population"].try(:positive?)
    data["amount_per_inhabitant"] = (data["amount"].to_f / data["population"]).round(2)
  end
  if (code_key = opts[:recalculate_code]).present?
    data.merge! BudgetCodeData.code_data(data.delete(code_key)).stringify_keys
  end
  data
end

if ARGV.length != 2
  raise "Wrong number of arguments"
end

input_file = ARGV[0]
output_file = ARGV[1]
file_key = File.basename(input_file).gsub("_utf8", "").split(".").first

puts "[START] aggregate-data/run.rb with file=#{input_file} output=#{output_file}"

parsed_source_data = JSON.parse(File.read(input_file))
grouped_data = parsed_source_data.group_by { |data| data.slice(*FIRST_GROUP) }

output_data = DIMENSIONS.keys.each_with_object({}) { |k, output| output[k] = [] }

grouped_data.each do |group_key, values|
  DIMENSIONS.each do |key, opts|
    code_groups = values.group_by { |data| data.slice(*opts[:keys]) }
    sums = code_groups.transform_values { |aggregation_values| { "amount" => aggregation_values.select { |x| x[opts[:aggregated_key]].length == 1 }.map { |v| v["amount"] }.sum } }
    sums.transform_keys! { |k| k.merge(group_key).merge("type" => opts[:area_name]) }
    unified_data = sums.map { |k, v| unify(k, v, opts) }
    output_data[key].concat(unified_data)
  end
end

output_data.each do |key, data|
  file_name = output_file.gsub(/\.(\w*)\z/, "_#{key}.\\1")
  File.write(file_name, data.to_json)
end

puts "[END] aggregate-data/run.rb"
