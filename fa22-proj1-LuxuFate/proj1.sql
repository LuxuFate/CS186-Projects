-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
   FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE "% %"
  ORDER BY namefirst, namelast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
    FROM people
    GROUP BY birthyear
    HAVING AVG(height) > 70
    ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, people.playerID, yearID
  FROM people INNER JOIN HallofFame
  ON people.playerID = HallofFame.playerID
  WHERE inducted = "Y"
  ORDER BY yearid DESC, people.playerID
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, P.playerid, S.schoolID, yearID
  FROM people AS P INNER JOIN HallofFame AS H ON P.playerID = H.playerID
    INNER JOIN CollegePlaying AS C ON P.playerID = C.playerid
    INNER JOIN Schools AS S ON C.schoolID = S.schoolID
  WHERE inducted = "Y" AND S.schoolState = "CA"
  ORDER BY yearID DESC, S.schoolID, P.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT P.playerid, namefirst, namelast, schoolID
  FROM people AS P INNER JOIN HallofFame AS H ON P.playerID = H.playerID
      LEFT OUTER JOIN CollegePlaying AS C ON P.playerID = C.playerid
  WHERE inducted = "Y"
  ORDER BY P.playerid DESC, C.schoolID
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT P.playerid, namefirst, namelast, yearID, ((H-H2B-H3B-HR)+(2*H2B)+(3*H3B)+(4*HR))/CAST(AB AS FLOAT) AS slg
  FROM people as P INNER JOIN batting as B
    ON P.playerID = B.playerID
  WHERE B.AB > 50
  ORDER BY slg DESC, yearID, P.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT P.playerid, namefirst, namelast, SUM((H-H2B-H3B-HR)+(2*H2B)+(3*H3B)+(4*HR))/CAST(SUM(AB) AS FLOAT) AS lslg
    FROM people as P INNER JOIN batting as B
      ON P.playerID = B.playerID
    GROUP BY P.playerid, namefirst, namelast
    HAVING SUM(B.AB) > 50
    ORDER BY lslg DESC, P.playerid
    LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, SUM((H-H2B-H3B-HR)+(2*H2B)+(3*H3B)+(4*HR))/CAST(SUM(AB) AS FLOAT) AS lslg
      FROM people as P INNER JOIN batting as B
        ON P.playerID = B.playerID
      GROUP BY P.playerid, namefirst, namelast
      HAVING SUM(B.AB) > 50
        AND lslg > (SELECT SUM((H-H2B-H3B-HR)+(2*H2B)+(3*H3B)+(4*HR))/CAST(SUM(AB) AS FLOAT) AS lslg
            FROM people as P INNER JOIN batting as B
                ON P.playerID = B.playerID
            WHERE P.playerID = "mayswi01"
            GROUP BY P.playerid)
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
  FROM Salaries
  GROUP BY yearid
  ORDER BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH Salaries2016(salary16) AS
    (SELECT salary
     FROM Salaries
     WHERE yearID = 2016
     ORDER BY salary),
  Range(bot, top) AS
    (SELECT MIN(salary16) AS bot, MAX(salary16) AS top
     FROM Salaries2016)
  SELECT binid,
    (bot + (((top - bot)/10.0) * binid)) as low,
    (bot + (((top - bot)/10.0) * (binid+1))) as high,
    (SELECT COUNT(salary16) FROM Salaries2016
            WHERE salary16 >= (bot + (((top - bot)/10.0) * binid))
                AND (salary16 < (bot + (((top - bot)/10.0) * (binid+1))) OR
                    (binid = 9 AND salary16 = (bot + (((top - bot)/10.0) * (binid+1)))))
    ) as count
  FROM Salaries2016, binids, Range
  GROUP BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH prev(pYear, pMin, pMax, pAvg) AS
  (SELECT yearID, MIN(salary), MAX(salary), AVG(salary)
    FROM Salaries
    GROUP BY yearID),
  curr(cYear, cMin, cMax, cAvg) AS
  (SELECT CurrSalaries.yearID+1, MIN(salary), MAX(salary), AVG(salary)
     FROM Salaries as CurrSalaries
     GROUP BY CurrSalaries.yearID)
  SELECT cYear, pMin-cMin, pMax-cMax, pAvg-cAvg
  FROM prev INNER JOIN curr ON cYear = pYear
  GROUP BY cYear
  ORDER BY cYear
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT S.playerid, namefirst, namelast, S.salary, yearid
  FROM People AS P INNER JOIN Salaries AS S
    ON P.playerID = S.playerID
  WHERE S.yearID = 2000 AND S.salary = (SELECT MAX(salaMax.salary) FROM Salaries AS salaMax WHERE salaMax.yearID = 2000)
  OR S.yearID = 2001 AND S.salary = (SELECT MAX(salaMax.salary) FROM Salaries AS salaMax WHERE salaMax.yearID = 2001)
  ORDER BY S.yearID, P.playerID
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT A.teamID,
    MAX(S.salary) - MIN(S.salary)
  FROM AllStarFull AS A INNER JOIN Salaries AS S
    ON A.playerID = S.playerID AND A.YearID = S.yearID
  WHERE A.YearID = 2016
  GROUP BY A.teamID
  ORDER BY A.teamID
;

