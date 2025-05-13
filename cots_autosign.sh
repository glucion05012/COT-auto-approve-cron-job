#!/bin/bash

# DB credentials
USER="root"
PASSWORD='$2y$10$K1hW8Cz/7q6P7T1LJZlUIOV5m3PjJThHyZJndcGziUURCgBzUpU2e'
HOST="127.0.0.1"
DATABASE="cots"

# SQL query
SQL_QUERY="UPDATE certificate_of_transshipment ct
JOIN esignature es ON ct.cot_id = es.cot_id
LEFT JOIN esignature ea ON ea.cot_id = es.cot_id AND ea.user_type = 'approver'
SET ct.esig_approver = 1, ct.remarks = 'checker', ct.status = 'Approved'
WHERE ct.esig_reviewer = 1
  AND ct.esig_approver <> 1
  AND es.user_type = 'reviewer'
  AND TIMESTAMPDIFF(SECOND, es.date_signed, NOW()) > 172800
  AND ea.cot_id IS NULL;

INSERT INTO esignature (
  file_name,
  file_location,
  cot_id,
  signatory,
  sig_position,
  time_date_signed,
  date_signed,
  user_type
)

SELECT
  'matias.png',
  'https://denrncrsys.online:8001/assets/attachments/signatures/matias.png',
  es.cot_id,
  'ATTY. MICHAEL DRAKE P. MATIAS',
  'Regional Executive Director, DENR - NCR',
  CONCAT(DATE_FORMAT(NOW(), '%M %d, %Y %l:%i:'),LOWER(DATE_FORMAT(NOW(), '%p'))),
  DATE_FORMAT(NOW(), '%Y-%m-%d'),
  'approver'
FROM certificate_of_transshipment ct
JOIN esignature es ON ct.cot_id = es.cot_id
LEFT JOIN esignature ea ON ea.cot_id = es.cot_id AND ea.user_type = 'approver'
WHERE ct.esig_reviewer = 1
  AND ct.esig_approver = 1
  AND es.user_type = 'reviewer'
  AND TIMESTAMPDIFF(SECOND, es.date_signed, NOW()) > 172800
  AND ea.cot_id IS NULL;"

# Run the query
mysql -u "$USER" -p"$PASSWORD" -h "$HOST" -D "$DATABASE" -e "$SQL_QUERY"