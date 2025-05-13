UPDATE esignature
SET time_date_signed_dt = STR_TO_DATE(time_date_signed, '%M %d, %Y %h:%i:%p')
WHERE time_date_signed IS NOT NULL
  AND time_date_signed NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}';
SELECT 'Datetime Conversion Updated:', ROW_COUNT();


-- 1. Auto-sign Attester (6 hrs after Checker)
INSERT INTO esignature (
  file_name, file_location, cot_id, signatory, sig_position,
  time_date_signed, date_signed, user_type, auto_signed
)
SELECT 
  'docena.png',
  'https://denrncrsys.online:8001/assets/attachments/signatures/docena.png',
  es.cot_id,
  'NICOLAS C. DOCENA JR.',
  'Unit Head, Port Integrated Clearance Office',
  CONCAT(
  DATE_FORMAT(NOW(), '%M %d, %Y %l:%i:'),
  LOWER(DATE_FORMAT(NOW(), '%p'))
), DATE_FORMAT(NOW(), '%Y-%m-%d'), 'attester', 'yes'
FROM esignature es
JOIN certificate_of_transshipment ct ON ct.cot_id = es.cot_id
LEFT JOIN esignature next_es ON next_es.cot_id = es.cot_id AND next_es.user_type = 'attester'
WHERE es.user_type = 'checker'
  AND TIMESTAMPDIFF(SECOND, es.time_date_signed_dt, NOW()) >= 21600
  AND next_es.cot_id IS NULL;
SELECT 'Attester Inserted:', ROW_COUNT();

UPDATE certificate_of_transshipment ct
JOIN esignature es ON ct.cot_id = es.cot_id
SET 
  ct.esig_attester = 1,
  ct.remarks = 'evaluator',
  ct.status = 'For signature of Evaluator'
WHERE es.user_type = 'attester';
SELECT 'Attester Updated:', ROW_COUNT();


-- 2. Auto-sign Evaluator (6 hrs after Attester)
INSERT INTO esignature (
  file_name, file_location, cot_id, signatory, sig_position,
  time_date_signed, date_signed, user_type, auto_signed
)
SELECT 
  'sanchez.jpg',
  'https://denrncrsys.online:8001/assets/attachments/signatures/sanchez.jpg',
  es.cot_id,
  'MARICAR PUNO SANCHEZ',
  'Chief, Enforcement Division',
  CONCAT(
  DATE_FORMAT(NOW(), '%M %d, %Y %l:%i:'),
  LOWER(DATE_FORMAT(NOW(), '%p'))
), DATE_FORMAT(NOW(), '%Y-%m-%d'), 'evaluator', 'yes'
FROM esignature es
JOIN certificate_of_transshipment ct ON ct.cot_id = es.cot_id
LEFT JOIN esignature next_es ON next_es.cot_id = es.cot_id AND next_es.user_type = 'evaluator'
WHERE es.user_type = 'attester'
  AND TIMESTAMPDIFF(SECOND, es.time_date_signed_dt, NOW()) >= 21600
  AND next_es.cot_id IS NULL;
SELECT 'Evaluator Inserted:', ROW_COUNT();

UPDATE certificate_of_transshipment ct
JOIN esignature es ON ct.cot_id = es.cot_id
SET 
  ct.esig_evaluator = 1,
  ct.remarks = 'reviewer',
  ct.status = 'For signature of Reviewer'
WHERE es.user_type = 'evaluator';
SELECT 'Evaluator Updated:', ROW_COUNT();


-- 3. Auto-sign Reviewer (30 mins after Evaluator)
INSERT INTO esignature (
  file_name, file_location, cot_id, signatory, sig_position,
  time_date_signed, date_signed, user_type, auto_signed
)
SELECT 
  'pacis.png',
  'https://denrncrsys.online:8001/assets/attachments/signatures/pacis.png',
  es.cot_id,
  'HENRY P. PACIS',
  'ARD, Technical Services',
  CONCAT(
  DATE_FORMAT(NOW(), '%M %d, %Y %l:%i:'),
  LOWER(DATE_FORMAT(NOW(), '%p'))
), DATE_FORMAT(NOW(), '%Y-%m-%d'), 'reviewer', 'yes'
FROM esignature es
JOIN certificate_of_transshipment ct ON ct.cot_id = es.cot_id
LEFT JOIN esignature next_es ON next_es.cot_id = es.cot_id AND next_es.user_type = 'reviewer'
WHERE es.user_type = 'evaluator'
  AND TIMESTAMPDIFF(SECOND, es.time_date_signed_dt, NOW()) >= 1800
  AND next_es.cot_id IS NULL;
SELECT 'Reviewer Inserted:', ROW_COUNT();

UPDATE certificate_of_transshipment ct
JOIN esignature es ON ct.cot_id = es.cot_id
SET 
  ct.esig_reviewer = 1,
  ct.remarks = 'approver',
  ct.status = 'For signature of Approver'
WHERE es.user_type = 'reviewer';
SELECT 'Reviewer Updated:', ROW_COUNT();


-- 4. Auto-sign Approver (30 mins after Reviewer)
INSERT INTO esignature (
  file_name, file_location, cot_id, signatory, sig_position,
  time_date_signed, date_signed, user_type, auto_signed
)
SELECT 
  'matias.png',
  'https://denrncrsys.online:8001/assets/attachments/signatures/matias.png',
  es.cot_id,
  'ATTY. MICHAEL DRAKE P. MATIAS',
  'Regional Executive Director, DENR-NCR and Regional Director',
  CONCAT(
  DATE_FORMAT(NOW(), '%M %d, %Y %l:%i:'),
  LOWER(DATE_FORMAT(NOW(), '%p'))
), DATE_FORMAT(NOW(), '%Y-%m-%d'), 'approver', 'yes'
FROM esignature es
JOIN certificate_of_transshipment ct ON ct.cot_id = es.cot_id
LEFT JOIN esignature next_es ON next_es.cot_id = es.cot_id AND next_es.user_type = 'approver'
WHERE es.user_type = 'reviewer'
  AND TIMESTAMPDIFF(SECOND, es.time_date_signed_dt, NOW()) >= 1800
  AND next_es.cot_id IS NULL;
SELECT 'Approver Inserted:', ROW_COUNT();

UPDATE certificate_of_transshipment ct
JOIN esignature es ON ct.cot_id = es.cot_id
SET 
  ct.esig_approver = 1,
  ct.status = 'Approved',
  ct.remarks = 'checker'
WHERE es.user_type = 'approver';
SELECT 'Approver Updated:', ROW_COUNT();
