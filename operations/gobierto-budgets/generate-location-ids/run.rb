#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

require_relative "../../../utils/source_files.rb"

# Usage:
#
#  - Creates a file with the ids of all euskadi location ids
#
# Arguments:
#
#  - 0: Output fle path
#
# Samples:
#
#   /path/to/project/operations/gobierto_budgets/generate-location-ids/run.rb organization_ids.txt
#

if ARGV.length != 1
  raise "Wrong number of arguments"
end

output_file = ARGV[0]

puts "[START] generate-location-ids/run.rb  with output_file=#{output_file}"

File.write(output_file, BudgetLocationData.location_ids.join("\n"))

puts "[END] generate-location-ids/run.rb"
