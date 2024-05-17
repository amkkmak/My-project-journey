-- Exploratory Data Analysis
-- Understand which countries have most laid off: U.S, it is 7 times of 2nd country, india  
-- Understand laid off of each year- 2023 with only three months data of the year
-- Understand which industries have heaviest laid off: consumer and retail
-- Understnd which stages have most laid off: Post-IPO is 5 times more than others including acquired, series C and D
-- Rolling total shows month by month progession. Data of 2021 shows it comparetively low number of laid off. Data from 2022 starts dramatically increase
-- Ranking companies who have larger layoff by years

SELECT*
FROM layoffs_staging2;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 DESC;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT stage, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT SUBSTRING(date, 1, 7) AS 'MONTH', SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(date, 1, 7) IS NOT NULL
GROUP BY SUBSTRING(date, 1, 7)
ORDER BY 1 ASC;

WITH Rolling_total AS
(
SELECT SUBSTRING(date, 1, 7) AS MONTH, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(date, 1, 7) IS NOT NULL
GROUP BY SUBSTRING(date, 1, 7)
ORDER BY 1 ASC
)
SELECT MONTH, total_off, SUM(total_off) OVER (ORDER BY MONTH) AS Rolling_total
FROM Rolling_total;

SELECT company, YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(date)
ORDER BY 3 desc;

-- 1st CTE
WITH Company_year (comapny, year, total_laid_off) AS 
(
SELECT company, YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(date)
), Company_Year_Rank AS -- 2nd CTE
(
SELECT *, 
DENSE_RANK()OVER(partition by year ORDER BY total_laid_off desc) AS Ranking
FROM Company_year
WHERE year IS NOT NULL
) -- 3rd CTE
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5 ;

