# frozen_string_literal: true

class BudgetDataReport
  attr_reader :data

  def initialize(file_key, options = {})
    @file_key = file_key
    @file_metadata = SourceFiles::FILES[file_key]
    @total_codes = options[:total_codes]
    @data = {}
  end

  def mark_year(year, ine_code:)
    key = { ine_code:, year: }

    @data[key] ||= 0
  end

  def register_data(data)
    key = data.slice(:ine_code, :year)
    @data[key] = (@data[key] || 0) + 1
  end

  def report_content
    @report_content ||= data.sort_by { |k, _v| "#{k[:ine_code]}#{k[:year]}" }.map do |k, v|
      [k[:ine_code], k[:year], v, @total_codes]
    end
  end

  def report_text
    text = ""
    text += "\"ine code\",\"year\",\"codes with values\",\"total codes\"\n"
    report_content.each do |report_values|
      text += report_values.join(",") + "\n"
    end
    text
  end

  def print
    puts "Report for #{@file_metadata[:title]}"
    puts "================================================================"

    report_content.each do |report_values|
      puts "#{report_values[0]} (#{report_values[1]}) - #{report_values[2]} / #{report_values[3]}"
    end
  end
end
