--PART-1

--Importing Datasets
SELECT
    *
FROM
    data1;

SELECT
    *
FROM
    data2;

--Number of rows
SELECT
    COUNT(*)
FROM
    data1;

SELECT
    COUNT(*)
FROM
    data2;

--Dataset of Sikkim & Odisha
SELECT
    *
FROM
    data1
WHERE
    state IN ( 'Sikkim', 'Orissa' );

--Total population of India from the dataset
SELECT
    SUM(population) AS total_population
FROM
    data2;

--Average growth% of India
SELECT
    round(AVG(growth) * 100,
          3) AS avg_growth
FROM
    data1;

--State wise average groeth%
SELECT
    state,
    round(AVG(growth) * 100,
          3) AS state_avg_growth
FROM
    data1
GROUP BY
    state
ORDER BY
    state_avg_growth DESC;
--Top 5 states have average growth%
SELECT
    state,
    round(AVG(growth) * 100,
          2) AS top_5_state_growth
FROM
    data1
GROUP BY
    state
ORDER BY
    top_5_state_growth DESC
FETCH FIRST 5 ROWS ONLY;

--Average sex ratio in India from dataset
SELECT
    round(AVG(sex_ratio),
          0) AS avg_sex_ratio
FROM
    data1;

--Statewise average sex ratio
SELECT
    state,
    round(AVG(sex_ratio),
          0) AS state_avg_sex_ratio
FROM
    data1
GROUP BY
    state
ORDER BY
    state_avg_sex_ratio DESC;
--Top 5 states having lowest sex ratio
SELECT
    state,
    round(AVG(sex_ratio),
          0) AS state_avg_sex_ratio
FROM
    data1
GROUP BY
    state
ORDER BY
    state_avg_sex_ratio
FETCH FIRST 5 ROWS ONLY;

--Average Literacy in India from dataset
SELECT
    round(AVG(literacy),
          2) AS avg_literacy
FROM
    data1;

--Statewise average Literacy
SELECT
    state,
    round(AVG(literacy),
          0) AS state_avg_literacy
FROM
    data1
GROUP BY
    state
ORDER BY
    state_avg_literacy DESC;
--States having Literacy % greater than 85
SELECT
    state,
    round(AVG(literacy),
          0) AS state_avg_literacy
FROM
    data1
GROUP BY
    state
HAVING
    round(AVG(literacy),
          0) > 85
ORDER BY
    state_avg_literacy DESC;

--Create two table and join them using union operator to show top and lowest literacy rated states
--Table 1 for top states
CREATE TABLE top_liteacy (
    state         VARCHAR2(255),
    literacy_rate FLOAT
);

INSERT INTO top_liteacy
    SELECT
        state,
        round(AVG(literacy),
              0) AS literacy_rate
    FROM
        data1
    GROUP BY
        state
    ORDER BY
        literacy_rate DESC
    FETCH FIRST 5 ROWS ONLY;

SELECT
    *
FROM
    top_liteacy;

--Table2 for lowest states
CREATE TABLE low_literacy (
    state         VARCHAR2(255),
    literacy_rate FLOAT
);

INSERT INTO low_literacy
    SELECT
        state,
        round(AVG(literacy),
              0) AS literacy_rate
    FROM
        data1
    GROUP BY
        state
    ORDER BY
        literacy_rate
    FETCH FIRST 5 ROWS ONLY;

SELECT
    *
FROM
    low_literacy;

--Union the tables to show the data
SELECT
    *
FROM
    (
        SELECT
            *
        FROM
            top_liteacy
    ) a
UNION
SELECT
    *
FROM
    (
        SELECT
            *
        FROM
            low_literacy
    ) b;

--States name starts with A
SELECT DISTINCT
    state
FROM
    data1
WHERE
    state LIKE 'A%';

--States name ends with A
SELECT DISTINCT
    state
FROM
    data1
WHERE
    state LIKE '%a';

--PART-2

SELECT
    *
FROM
    data3;

SELECT
    *
FROM
    data4;

--Joining two tables
SELECT
    a.district,
    a.state_,
    a.sex_ratio / 1000 AS sex_ratio,
    b.population
FROM
         data3 a
    INNER JOIN data4 b ON a.district = b.district;

--Calculating the numbers of male and female
--male = population/(sex_ratio+1)
--female= (population*sex_ratio)/(sex_ratio+1)

--Distrctwise Male & Female
SELECT
    district,
    state_,
    population,
    round(population /(sex_ratio + 1), 0)               AS number_of_male,
    round((population * sex_ratio) /(sex_ratio + 1), 0) AS number_of_female
FROM
    (
        SELECT
            a.district,
            a.state_,
            a.sex_ratio / 1000 AS sex_ratio,
            b.population
        FROM
                 data3 a
            INNER JOIN data4 b ON a.district = b.district
    );

--Statewise Male & Female
SELECT
    state_,
    SUM(number_of_male)   AS total_male,
    SUM(number_of_female) AS total_female,
    SUM(population)       AS total_population
FROM
    (
        SELECT
            district,
            state_,
            round(population /(sex_ratio + 1), 0)               AS number_of_male,
            population,
            round((population * sex_ratio) /(sex_ratio + 1), 0) AS number_of_female
        FROM
            (
                SELECT
                    a.district,
                    a.state_,
                    a.sex_ratio / 1000 AS sex_ratio,
                    b.population
                FROM
                         data3 a
                    INNER JOIN data4 b ON a.district = b.district
            )
    )
GROUP BY
    state_;

--Total literate persons & illiterate persons district wise 
SELECT
    a.district,
    a.state_,
    a.literacy,
    round(population *(literacy / 100), 0)               AS literate_person,
    round(population -(population *(literacy / 100)), 0) AS illitetrate_person,
    b.population
FROM
         data3 a
    INNER JOIN data4 b ON a.district = b.district;

--Total literate and illiterate persons state wise
SELECT
    state_,
    SUM(literate_person)    AS total_literate_person,
    SUM(illitetrate_person) AS total_illitetrate_person
FROM
    (
        SELECT
            a.district,
            a.state_,
            a.literacy,
            round(population *(literacy / 100), 0)               AS literate_person,
            round(population -(population *(literacy / 100)), 0) AS illitetrate_person,
            b.population
        FROM
                 data3 a
            INNER JOIN data4 b ON a.district = b.district
    )
GROUP BY
    state_;

--Districtwise previous population & current population
SELECT
    c.district,
    c.state_,
    round(population /(1 + growth), 0) AS previous_poulation,
    population                         AS current_population
FROM
    (
        SELECT
            a.district,
            a.state_,
            a.growth,
            b.population
        FROM
                 data3 a
            INNER JOIN data4 b ON a.district = b.district
    ) c;

--Statesiwse previous & current population
SELECT
    state_,
    SUM(previous_poulation) AS total_previous_population,
    SUM(current_population) AS total_current_population
FROM
    (
        SELECT
            c.district,
            c.state_,
            round(population /(1 + growth), 0) AS previous_poulation,
            population                         AS current_population
        FROM
            (
                SELECT
                    a.district,
                    a.state_,
                    a.growth,
                    b.population
                FROM
                         data3 a
                    INNER JOIN data4 b ON a.district = b.district
            ) c
    )
GROUP BY
    state_;

--Statewise population per sq.km2
SELECT
    c.state_,
    SUM(population) total_population,
    SUM(area_km2)   total_area,
    round(SUM(population) / SUM(area_km2),
          0)        per_sqkm_population
FROM
    (
        SELECT
            a.district,
            a.state_,
            b.population,
            b.area_km2,
            round((population / area_km2), 0) AS population_per_sqkm
        FROM
                 data3 a
            INNER JOIN data4 b ON a.district = b.district
    ) c
GROUP BY
    state_;

--Top 5 literate districts of each states
SELECT
    *
FROM
    (
        SELECT
            state_,
            district,
            literacy,
            RANK()
            OVER(PARTITION BY state_
                 ORDER BY
                     literacy DESC
            ) AS rank_
        FROM
            data3
    ) a
WHERE
    a.rank_ IN ( 1, 2, 3, 4, 5 );














