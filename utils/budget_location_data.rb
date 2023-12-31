# frozen_string_literal: true

LOCATION_NAMES_CORRECTIONS = {
  "Arrankudiaga-Zollo" => "Arrankudiaga",
  "Agurain/Salvatierra" => "Salvatierra/Agurain",
  "Donostia / San Sebastián" => "Donostia/San Sebastián",
  "Ribera Baja/Erriberabeitia" => "Ribera Baja/Erribera Beitia"
}.freeze

AUTONOMOUS_REGION_ID = "16"

class BudgetLocationData
  attr_accessor :year
  attr_reader :location, :ine_code

  delegate :present?, to: :location

  def initialize(location_name, year)
    @location_name = LOCATION_NAMES_CORRECTIONS.fetch(location_name, location_name)
    @location = INE::Places::PlacesCollection.records.find do |loc|
      loc.name == @location_name && loc.province.autonomous_region.id == AUTONOMOUS_REGION_ID
    end
    @ine_code = location&.id&.to_i
    @year = year.to_i
  end

  def data
    return if location.blank?

    {
      organization_id: location.id,
      ine_code:,
      province_id: location.province.id.to_i,
      autonomy_id: AUTONOMOUS_REGION_ID.to_i,
      year: year.to_i,
      population:
    }
  end

  def population
    GobiertoBudgetsData::GobiertoBudgets::Population.get(location.id, year.to_i)
  end

  def self.location_ids
    INE::Places::PlacesCollection.records.select do |loc|
      loc.province.autonomous_region.id == AUTONOMOUS_REGION_ID
    end.map(&:id)
  end
end
