#!/bin/bash

RAILS_ENV="development"
GOBIERTO_ETL_UTILS=$DEV_DIR/gobierto-etl-utils
EUSKADI_ETL=$DEV_DIR/gobierto-etl-euskadi
STORAGE_DIR=$EUSKADI_ETL/tmp

# Extract > Clear storage dir
rm -rf $STORAGE_DIR/*

# Extract > Download data
cd $GOBIERTO_ETL_UTILS; ruby operations/api-download/run.rb --source-url https://www.eustat.eus/bankupx/Resources/PX/Databases/DB/PX_153011_cepsp_pspmun04.px --output-file $STORAGE_DIR/PX_153011_cepsp_pspmun04.px
cd $GOBIERTO_ETL_UTILS; ruby operations/api-download/run.rb --source-url https://www.eustat.eus/bankupx/Resources/PX/Databases/DB/PX_153011_cepsp_pspmun05.px --output-file $STORAGE_DIR/PX_153011_cepsp_pspmun05.px
cd $GOBIERTO_ETL_UTILS; ruby operations/api-download/run.rb --source-url https://www.eustat.eus/bankupx/Resources/PX/Databases/DB/PX_153011_cepsp_psppre01.px --output-file $STORAGE_DIR/PX_153011_cepsp_psppre01.px
cd $GOBIERTO_ETL_UTILS; ruby operations/api-download/run.rb --source-url https://www.eustat.eus/bankupx/Resources/PX/Databases/DB/PX_153011_cepsp_psppre02.px --output-file $STORAGE_DIR/PX_153011_cepsp_psppre02.px
cd $GOBIERTO_ETL_UTILS; ruby operations/api-download/run.rb --source-url https://www.eustat.eus/bankupx/Resources/PX/Databases/DB/PX_153011_cepsp_pspmun06.px --output-file $STORAGE_DIR/PX_153011_cepsp_pspmun06.px

# Transform > Convert px files to UTF8
cd $GOBIERTO_ETL_UTILS; ruby operations/convert-to-utf8/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun04.px $STORAGE_DIR/PX_153011_cepsp_pspmun04_utf8.px ISO-8859-1
cd $GOBIERTO_ETL_UTILS; ruby operations/convert-to-utf8/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun05.px $STORAGE_DIR/PX_153011_cepsp_pspmun05_utf8.px ISO-8859-1
cd $GOBIERTO_ETL_UTILS; ruby operations/convert-to-utf8/run.rb $STORAGE_DIR/PX_153011_cepsp_psppre01.px $STORAGE_DIR/PX_153011_cepsp_psppre01_utf8.px ISO-8859-1
cd $GOBIERTO_ETL_UTILS; ruby operations/convert-to-utf8/run.rb $STORAGE_DIR/PX_153011_cepsp_psppre02.px $STORAGE_DIR/PX_153011_cepsp_psppre02_utf8.px ISO-8859-1
cd $GOBIERTO_ETL_UTILS; ruby operations/convert-to-utf8/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun06.px $STORAGE_DIR/PX_153011_cepsp_pspmun06_utf8.px ISO-8859-1

# Transform > Transform PX data do JSON
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/transform-px-data/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun04_utf8.px $STORAGE_DIR/PX_153011_cepsp_pspmun04.json
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/transform-px-data/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun05_utf8.px $STORAGE_DIR/PX_153011_cepsp_pspmun05.json
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/transform-px-data/run.rb $STORAGE_DIR/PX_153011_cepsp_psppre01_utf8.px $STORAGE_DIR/PX_153011_cepsp_psppre01.json
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/transform-px-data/run.rb $STORAGE_DIR/PX_153011_cepsp_psppre02_utf8.px $STORAGE_DIR/PX_153011_cepsp_psppre02.json
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/transform-px-data/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun06_utf8.px $STORAGE_DIR/PX_153011_cepsp_pspmun06.json

# Transform > Aggregate functional and economic data
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/aggregate-data/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun06.json $STORAGE_DIR/PX_153011_cepsp_pspmun06_aggregated.json

# Load > Import data
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/load-json-data/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun04.json $STORAGE_DIR/years.txt
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/load-json-data/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun05.json $STORAGE_DIR/years.txt
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/load-json-data/run.rb $STORAGE_DIR/PX_153011_cepsp_psppre01.json $STORAGE_DIR/years.txt
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/load-json-data/run.rb $STORAGE_DIR/PX_153011_cepsp_psppre02.json $STORAGE_DIR/years.txt
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/load-json-data/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun06.json $STORAGE_DIR/years.txt
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/load-json-data/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun06_aggregated_economic.json $STORAGE_DIR/years.txt
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/load-json-data/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun06_aggregated_functional.json $STORAGE_DIR/years.txt

# Load > Calculate totals
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/generate-location-ids/run.rb $STORAGE_DIR/location_ids.txt
cd $GOBIERTO_ETL_UTILS; ruby operations/gobierto_budgets/update_total_budget/run.rb "$(< $STORAGE_DIR/years.txt)" $STORAGE_DIR/location_ids.txt

# Load > Re-calculate bubbles
cd $GOBIERTO_ETL_UTILS; ruby operations/gobierto_budgets/bubbles/run.rb $STORAGE_DIR/location_ids.txt
