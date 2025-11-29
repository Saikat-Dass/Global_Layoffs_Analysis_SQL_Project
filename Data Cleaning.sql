SELECT * FROM layoffs;

-- Remove Duplicates
 
CREATE TABLE layoffs_2nd
LIKE layoffs;

INSERT INTO layoffs_2nd
SELECT * 
FROM layoffs;

CREATE TABLE `layoffs_3rd` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_3rd
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_2nd;

-- Standardizing the data

UPDATE layoffs_3rd
SET company = TRIM(company), location = TRIM(location), 
industry = TRIM(industry), 
country = TRIM(TRAILING '.' FROM country), 
stage = TRIM(stage);

UPDATE layoffs_3rd
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT(industry) FROM layoffs_3rd
WHERE industry LIKE 'Crypto';

UPDATE layoffs_3rd
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_3rd
MODIFY COLUMN `date` DATE;

-- Finding out Null Values

UPDATE layoffs_3rd
SET 
company = nullif(company, ''), 
location = nullif(location, ''), 
industry = nullif(industry, ''), 
total_laid_off = nullif(total_laid_off, ''),
percentage_laid_off = nullif(percentage_laid_off, ''), 
stage = nullif(stage, ''), 
country = nullif(country, ''), 
funds_raised_millions = nullif(funds_raised_millions, '');


UPDATE layoffs_3rd l1
JOIN layoffs_3rd l2
 ON l1.company = l2.company
SET l1.industry = l2.industry
WHERE l1.industry IS NULL
AND l2.industry IS NOT NULL;

-- Deleting Unwanted Columns If Any

SELECT *
FROM layoffs_3rd
WHERE company IN (
    SELECT company
    FROM layoffs_3rd
    GROUP BY company
    HAVING count(*) > 1
)
AND company IN (
	SELECT company
    FROM layoffs_3rd
    WHERE total_laid_off IS NULL OR percentage_laid_off IS NULL
);

DELETE 
FROM layoffs_3rd
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;


ALTER TABLE layoffs_3rd
DROP COLUMN row_num;