#!/bin/bash

# DB credentials
USER="root"
PASSWORD='$2y$10$K1hW8Cz/7q6P7T1LJZlUIOV5m3PjJThHyZJndcGziUURCgBzUpU2e'
HOST="127.0.0.1"
DATABASE="cots"
SQL_FILE="/systems/scripts/cots_auto_sign.sql"

LOG="/tmp/auto_sign.log"
echo "Running at $(date)" >> "$LOG"

# Run SQL script and log output including row counts
mysql -u "$USER" -p"$PASSWORD" -h "$HOST" "$DATABASE" -e "
SOURCE ${SQL_FILE};
SELECT 'Rows inserted (Attester):', ROW_COUNT();
SELECT 'Rows updated (Attester):', ROW_COUNT();

SELECT 'Rows inserted (Evaluator):', ROW_COUNT();
SELECT 'Rows updated (Evaluator):', ROW_COUNT();

SELECT 'Rows inserted (Reviewer):', ROW_COUNT();
SELECT 'Rows updated (Reviewer):', ROW_COUNT();

SELECT 'Rows inserted (Approver):', ROW_COUNT();
SELECT 'Rows updated (Approver):', ROW_COUNT();
" >> "$LOG" 2>&1

echo "" >> "$LOG"

# Run the SQL script
mysql -u "$USER" -p"$PASSWORD" -h "$HOST" "$DATABASE" < "$SQL_FILE"
