# frozen_string_literal: true

LOCATION_NAMES_CORRECTIONS = {
  "Arrankudiaga-Zollo" => "Arrankudiaga",
  "Agurain/Salvatierra" => "Salvatierra/Agurain",
  "Donostia / San Sebastián" => "Donostia/San Sebastián",
  "Ribera Baja/Erriberabeitia" => "Ribera Baja/Erribera Beitia"
}.freeze

AUTONOMOUS_REGION_ID = "16"

class BudgetLocationData
  attr_reader :raw_data

  delegate :present?, to: :location

  def initialize
    @raw_data = GobiertoBudgetsData::GobiertoBudgets::Population.get_by(autonomy_id: AUTONOMOUS_REGION_ID)
  end

  def data(location, year)
    year = year.to_i

    return if location.blank?

    {
      organization_id: location.id,
      ine_code: location.id.to_i,
      province_id: location.province.id.to_i,
      autonomy_id: AUTONOMOUS_REGION_ID.to_i,
      year: year.to_i,
      population: population(location, year)
    }
  end

  def location_from_name(location_name)
    location_name = LOCATION_NAMES_CORRECTIONS.fetch(location_name, location_name)
    INE::Places::PlacesCollection.records.find do |loc|
      loc.name == location_name && loc.province.autonomous_region.id == AUTONOMOUS_REGION_ID
    end
  end

  def population(location, year)
    year.downto(year - 2).map do |y|
      found = raw_data.find do |item|
        id = [location.ine_code, y, GobiertoBudgetsData::GobiertoBudgets::POPULATION_TYPE].join("/")
        item["_id"] == id
      end

      next if found.blank?

      found.dig("_source", "value")
    end.compact.first
  end

  def self.location_ids
    INE::Places::PlacesCollection.records.select do |loc|
      loc.province.autonomous_region.id == AUTONOMOUS_REGION_ID
    end.map(&:id)
  end
end
