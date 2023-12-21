# frozen_string_literal: true

LOCALE = "es"
CODE_NAMES_CORRECTIONS = {
  {
    area_name: GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_AREA_NAME,
    kind: GobiertoBudgetsData::GobiertoBudgets::EXPENSE
  } => {
    LOCALE => {
      "gasto de personal" => "gastos de personal",
      "crédito global y otros imprevistos" => "fondo de contingencia y otros imprevistos"
    }
  }
}.freeze

class BudgetCodeData
  attr_reader :code_name, :clean_code_name, :code, :level, :parent_code, :index, :kind, :area_name, :functional

  alias type area_name

  delegate :present?, to: :code

  def initialize(code_name, index:, kind:, area_name:, functional: false)
    @code_name = code_name
    @index = index
    @kind = kind
    @area_name = area_name
    @functional = functional

    process_code_name
    correct_code_name
    get_code
  end

  def data
    {
      code:,
      level:,
      kind:,
      parent_code:,
      type:
    }
  end

  def locale
    LOCALE
  end

  def process_code_name
    case area_name
    when GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_AREA_NAME, GobiertoBudgetsData::GobiertoBudgets::FUNCTIONAL_AREA_NAME
      return unless /^--/.match?(code_name)

      @level = 1
      @clean_code_name = code_name.gsub(/^--/, "").downcase
    when GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_FUNCTIONAL_AREA_NAME
      return unless /^-/.match?(code_name)

      @level = functional ? 2 : 1
      @clean_code_name = code_name.gsub(/^-/, "").gsub(/\.$/, "").downcase
    end
  end

  def category_area_name
    @category_area_name ||= if area_name == GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_FUNCTIONAL_AREA_NAME
                              functional ? GobiertoBudgetsData::GobiertoBudgets::FUNCTIONAL_AREA_NAME : GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_AREA_NAME
                            else
                              area_name
                            end
  end

  def correct_code_name
    if CODE_NAMES_CORRECTIONS.has_key?(area_name: category_area_name, kind:)
      @clean_code_name = CODE_NAMES_CORRECTIONS[{ area_name: category_area_name, kind: }][locale].fetch(clean_code_name, clean_code_name)
    end
  end

  def get_code
    return if clean_code_name.blank?

    categories = GobiertoBudgetsData::GobiertoBudgets::Category.all(area_name: category_area_name, kind:, locale:)

    category = categories.find { |code, value| code.length == @level && value.downcase == clean_code_name }
    return if category.blank?

    @code = category[0]
    @parent_code = @level < 2 ? nil : @code[0..@level - 2]
  end
end
