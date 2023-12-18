# frozen_string_literal: true

require_relative "./budget_location_data"
require_relative "./budget_code_data"

class SourceFiles
  FILES = {
    "PX_153011_cepsp_pspmun04" => {
      url: "https://www.eustat.eus/bankupx/Resources/PX/Databases/DB/PX_153011_cepsp_pspmun04.px",
      title: "Ingresos de ayuntamientos de la C.A. de Euskadi por capítulos (derechos liquidados) y ámbitos territoriales. 1983 - 2021",
      index: GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_EXECUTED,
      kind: GobiertoBudgetsData::GobiertoBudgets::INCOME,
      area_name: GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_AREA_NAME,
      category_economic_dimension: { "es" => "capítulos de ingreso", "eu" => "sarreraren kapituluak", "en" => "income sections" }
    },
    "PX_153011_cepsp_pspmun05" => {
      url: "https://www.eustat.eus/bankupx/Resources/PX/Databases/DB/PX_153011_cepsp_pspmun05.px",
      title: "Gastos de ayuntamientos de la C.A. de Euskadi por capítulos (obligaciones liquidadas) y ámbitos territoriales. 1983 - 2021",
      index: GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_EXECUTED,
      kind: GobiertoBudgetsData::GobiertoBudgets::EXPENSE,
      area_name: GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_AREA_NAME,
      category_economic_dimension: { "es" => "capítulos de gasto", "eu" => "gastuaren kapituluak", "en" => "expenditure sections" }
    },
    "PX_153011_cepsp_psppre01" => {
      url: "https://www.eustat.eus/bankupx/Resources/PX/Databases/DB/PX_153011_cepsp_psppre01.px",
      title: "Presupuestos de ingresos de los ayuntamientos de la C.A. de Euskadi por ámbitos territoriales. 1998 - 2022",
      index: GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_FORECAST,
      kind: GobiertoBudgetsData::GobiertoBudgets::INCOME,
      area_name: GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_AREA_NAME,
      category_economic_dimension: { "es" => "capítulos de ingreso", "eu" => "sarreraren kapituluak", "en" => "income sections" }
    },
    "PX_153011_cepsp_psppre02" => {
      url: "https://www.eustat.eus/bankupx/Resources/PX/Databases/DB/PX_153011_cepsp_psppre02.px",
      title: "Presupuestos de gastos de los ayuntamientos de la C.A. de Euskadi por ámbitos territoriales. 1998 - 2022",
      index: GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_FORECAST,
      kind: GobiertoBudgetsData::GobiertoBudgets::EXPENSE,
      area_name: GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_AREA_NAME,
      category_economic_dimension: { "es" => "capítulos de gasto", "eu" => "gastuaren kapituluak", "en" => "expenditure sections" }
    },
    "PX_153011_cepsp_pspmun06" => {
      url: "https://www.eustat.eus/bankupx/Resources/PX/Databases/DB/PX_153011_cepsp_pspmun06.px",
      title: "Gastos de ayuntamientos de la C.A. de Euskadi por ámbitos territoriales, clasificación funcional y clasificación económica. 2017 - 2021",
      index: GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_FORECAST,
      kind: GobiertoBudgetsData::GobiertoBudgets::EXPENSE,
      area_name: GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_FUNCTIONAL_AREA_NAME,
      functional_component: true,
      category_economic_dimension: { "es" => "clasificación económica", "eu" => "sailkapen ekonomikoa", "en" => "economic classification" },
      category_functional_dimension: { "es" => "clasificación funcional", "eu" => "sailkapen funtzionala", "en" => "functional classification" }
    }
  }
end
