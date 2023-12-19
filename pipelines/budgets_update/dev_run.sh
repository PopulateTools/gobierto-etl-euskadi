#!/bin/bash

RAILS_ENV="development"
GOBIERTO_ETL_UTILS=$DEV_DIR/gobierto-etl-utils
EUSKADI_ETL=$DEV_DIR/gobierto-etl-euskadi
ELASTICSEARCH_URL="http://localhost:9200"
BUDGETS_EUSKADI=$DEV_DIR/gobierto-budgets-comparator-gen-cat
STORAGE_DIR=$EUSKADI_ETL/tmp
FAST_RUN=false
BUCKET_NAME="gobierto-budgets-comparator-dev"

# # Extract > Download last start query date
# s3cmd get s3://$BUCKET_NAME/euskadi/last_excecution_date.txt $STORAGE_DIR/last_excecution_date.txt --force

# # Extract > Clean previous downloads
# cd $DEV_DIR/gobierto-etl-gencat/; ruby operations/gobierto_people/clear-path/run.rb downloads/datasets

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

# Load > Import data
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/load-json-data/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun04.json
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/load-json-data/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun05.json
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/load-json-data/run.rb $STORAGE_DIR/PX_153011_cepsp_psppre01.json
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/load-json-data/run.rb $STORAGE_DIR/PX_153011_cepsp_psppre02.json
cd $EUSKADI_ETL; ruby operations/gobierto-budgets/load-json-data/run.rb $STORAGE_DIR/PX_153011_cepsp_pspmun06.json
