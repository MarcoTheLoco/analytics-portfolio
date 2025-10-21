-- SQL Tasks (PostgreSQL)
-- 1. Топ-10 стран по выручке
SELECT country, SUM(revenue) AS rev
FROM sales
GROUP BY country
ORDER BY rev DESC
LIMIT 10;

-- 2. Конверсия по дням
SELECT day, COUNT(DISTINCT user_id) FILTER (WHERE event='pay')::float
       / NULLIF(COUNT(DISTINCT user_id) FILTER (WHERE event='view'),0) AS cr
FROM events
GROUP BY day
ORDER BY day;

-- 3. Ретеншн D1 с оконной функцией (примерная схема)
WITH installs AS (
  SELECT user_id, MIN(date) AS d0 FROM events WHERE event='install' GROUP BY user_id
),
d1 AS (
  SELECT e.user_id, MIN(e.date) AS d1
  FROM events e JOIN installs i USING(user_id)
  WHERE e.date = i.d0 + INTERVAL '1 day'
  GROUP BY e.user_id
)
SELECT COUNT(d1.user_id)::float / COUNT(installs.user_id) AS d1_retention
FROM installs LEFT JOIN d1 USING(user_id);
