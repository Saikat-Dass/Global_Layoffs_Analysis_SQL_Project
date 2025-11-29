
SELECT * FROM layoffs_3rd;

-- Looking at Percentage to see how big these layoffs were

SELECT MAX(total_laid_off) AS MAX,
MIN(total_laid_off) AS MIN,
MAX(percentage_laid_off) AS MAX_Percent,
MIN(percentage_laid_off) AS MIN_Percent
FROM layoffs_3rd;

-- Total lay offs per Company

SELECT 	company, SUM(total_laid_off) AS Total_laid_off
FROM layoffs_3rd
GROUP BY company
ORDER BY 2 DESC;

-- By What time layoffs mostly Started and What is the current timeline

SELECT MAX(`date`) AS Starting_Date, MIN(`date`) AS Till_now
FROM layoffs_3rd;

-- Which Industry had the most layoff

SELECT industry, SUM(total_laid_off) AS Total_laid
FROM layoffs_3rd
GROUP BY industry
ORDER BY 2 DESC;

-- Which Country had the most layoff

SELECT country, SUM(total_laid_off) AS Total_laid
FROM layoffs_3rd
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(total_laid_off) AS Total_laid
FROM layoffs_3rd
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

ALTER TABLE layoffs_3rd
ADD COLUMN Month_name VARCHAR(20) AS (MONTHNAME(`date`)) AFTER `date`;

--  Rolling Total of Layoffs Per Month

WITH rolling_total AS
(SELECT SUBSTRING(`date`,1,7) AS `YEAR`, SUM(total_laid_off) AS total_laid
FROM layoffs_3rd
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `YEAR` 
ORDER BY 1 ASC)
SELECT `YEAR`, total_laid, SUM(total_laid) OVER(ORDER BY `YEAR`) AS Rolling_total
FROM rolling_total;

-- Per Year basis Layoff of Companies with a Rank

WITH Company_Year AS
(SELECT company, SUM(total_laid_off) AS Total_lay_off, YEAR(`date`) AS `Year`
FROM layoffs_3rd
GROUP BY company, `Year`
ORDER BY 2 DESC)
SELECT *, DENSE_RANK() OVER(PARTITION BY `Year` ORDER BY Total_lay_off DESC) AS `Rank`
FROM Company_Year
WHERE `Year` IS NOT NULL;