-- Data Cleaning
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- 1. Remove duplicates
-- 2. Standardise the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns

-- i create a table: layoffs_staging
CREATE TABLE layoffs_staging
LIKE layoffs_yourgpt;

-- ii. layoffs_staging only contain variables
SELECT *
FROM layoffs_staging;

-- iii. insert layoffs_yourgpt's data into layoffs_staging
INSERT layoffs_staging
SELECT *
FROM layoffs_yourgpt;

-- 1. Remove Duplicates
	-- i.build a new variable 
	-- ii. that variable is a result of checking through everyone single variable to see any duplicates. 

    
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, 'date', 
stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging
)

SELECT *
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, 'date', 
stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardising data
SELECT company, trim(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = trim(company);

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'
ORDER BY 1;

	-- update industry
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT distinct(location)
FROM layoffs_staging2
ORDER BY 1;

	-- Find location that are non-u.s.
SELECT *
FROM layoffs_staging2
WHERE location LIKE 'Non%';

SELECT *
FROM layoffs_staging2
WHERE COUNTRY = 'China';

UPDATE layoffs_staging2
SET location = 'Hangzhou'
WHERE company = 'WeDoctor';

SELECT *
FROM layoffs_staging2
WHERE COUNTRY = 'Seychelles';

UPDATE layoffs_staging2
SET location = 'Eden Island'
WHERE company = 'BitMEX';

	-- Check country
SELECT distinct(country)
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

	-- date format
SELECT date, STR_TO_DATE(date, '%m/%d/%Y')
FROM layoffs_staging2;
    
UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%Y/%m/%d');

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;

-- 3. NULL and BLANK values
SELECT *
FROM layoffs_staging2
WHERE industry = 'NULL';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ''
OR industry = 'NULL';


SELECT industry
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND (t2.industry IS NOT NULL OR t2. industry != '');

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND (t2.industry IS NOT NULL OR t2. industry != '');

-- 4. Remove Any Columns
SELECT*
FROM layoffs_staging2
WHERE total_laid_off = 'NULL'
AND percentage_laid_off = 'NULL';

	-- Remove columns that are BLANK in total_laid_off and percentage_laid_off
DELETE
FROM layoffs_staging2
WHERE total_laid_off = 'NULL'
AND percentage_laid_off = 'NULL';

SELECT*
FROM layoffs_staging2;

	-- DROP row_num columns
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
