
-- IPL 2025 Analytics Dashboard SQL Project

USE IPL_DB;

-- 1. Total Matches
SELECT COUNT(*) AS total_matches
FROM matches;

-- 2. Matches Won By Team
SELECT match_winner, COUNT(*) AS matches_won
FROM matches
GROUP BY match_winner
ORDER BY matches_won DESC;

-- 3. Team Win Percentage
WITH TeamWins AS (
    SELECT match_winner AS team, COUNT(*) AS wins
    FROM matches
    GROUP BY match_winner
),
MatchesPlayed AS (
    SELECT team, COUNT(*) AS matches_played
    FROM (
        SELECT team1 AS team FROM matches
        UNION ALL
        SELECT team2 AS team FROM matches
    ) t
    GROUP BY team
)
SELECT
    m.team,
    matches_played,
    COALESCE(w.wins,0) AS wins,
    ROUND((COALESCE(w.wins,0)*100.0)/matches_played,2) AS win_percentage
FROM MatchesPlayed m
LEFT JOIN TeamWins w
ON m.team = w.team
ORDER BY win_percentage DESC;

-- 4. Player of the Match Awards
SELECT player_of_the_match,
       COUNT(*) AS awards
FROM matches
GROUP BY player_of_the_match
ORDER BY awards DESC;

-- 5. Rank Teams By Wins
SELECT
    match_winner,
    COUNT(*) AS wins,
    RANK() OVER(ORDER BY COUNT(*) DESC) AS rank_no
FROM matches
GROUP BY match_winner;

-- 6. Toss Impact Analysis
SELECT
    toss_winner,
    COUNT(*) AS toss_wins,
    SUM(CASE WHEN toss_winner = match_winner THEN 1 ELSE 0 END) AS converted_to_match_win
FROM matches
GROUP BY toss_winner;

-- 7. Venue Wise Matches
SELECT
    venue,
    COUNT(*) AS matches
FROM matches
GROUP BY venue
ORDER BY matches DESC;

-- 8. Teams Winning After Losing Toss
SELECT
    match_winner,
    COUNT(*) AS wins
FROM matches
WHERE toss_winner <> match_winner
GROUP BY match_winner
ORDER BY wins DESC;

-- 9. Head-to-Head Analysis
SELECT
    team1,
    team2,
    COUNT(*) AS matches_played,
    SUM(CASE WHEN match_winner = team1 THEN 1 ELSE 0 END) AS team1_wins,
    SUM(CASE WHEN match_winner = team2 THEN 1 ELSE 0 END) AS team2_wins
FROM matches
GROUP BY team1, team2;

-- 10. Top 5 Players Of The Match
SELECT *
FROM (
    SELECT
        player_of_the_match,
        COUNT(*) AS awards,
        ROW_NUMBER() OVER(ORDER BY COUNT(*) DESC) AS rn
    FROM matches
    GROUP BY player_of_the_match
) x
WHERE rn <= 5;

-- 11. Average First Innings Score
SELECT AVG(first_ings_score) AS avg_first_innings_score
FROM matches;

-- 12. Average Second Innings Score
SELECT AVG(second_ings_score) AS avg_second_innings_score
FROM matches;

-- 13. Highest Team Score
SELECT *
FROM matches
ORDER BY first_ings_score DESC;

-- 14. Top Scorers
SELECT
    top_scorer,
    COUNT(*) AS appearances
FROM matches
GROUP BY top_scorer
ORDER BY appearances DESC;

-- 15. Best Bowling Performances
SELECT
    best_bowling,
    COUNT(*) AS appearances
FROM matches
GROUP BY best_bowling
ORDER BY appearances DESC;

-- 16. Subquery Example
SELECT *
FROM matches
WHERE highscore >
(
    SELECT AVG(highscore)
    FROM matches
);

-- 17. Matches By Venue and Winner
SELECT venue, match_winner, COUNT(*) AS wins
FROM matches
GROUP BY venue, match_winner
ORDER BY venue, wins DESC;

-- 18. Most Successful Team At Each Venue
WITH VenueWins AS (
    SELECT venue, match_winner, COUNT(*) AS wins,
           RANK() OVER(PARTITION BY venue ORDER BY COUNT(*) DESC) rnk
    FROM matches
    GROUP BY venue, match_winner
)
SELECT *
FROM VenueWins
WHERE rnk = 1;
