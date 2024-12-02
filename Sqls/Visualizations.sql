USE TwoKMovie;

--1. Movie Ratings
SELECT 
    m.Title AS MovieTitle,
    COUNT(*) AS TotalRatings,
    AVG(r.Rating) AS AverageRating,
    COUNT(DISTINCT r.UserId) AS Raters
FROM Movies m
LEFT JOIN Rating r ON m.Id = r.MovieId
GROUP BY m.Id, m.Title
ORDER BY AverageRating DESC;

--2. Ratings Trend Over Time
SELECT 
    CAST(r.Date AS DATE) AS RatingDate,
    COUNT(*) AS TotalRatings,
    AVG(r.Rating) AS AverageRating
FROM Rating r
GROUP BY CAST(r.Date AS DATE)
ORDER BY RatingDate;

--3. Top-Rated Movies by Genre
SELECT 
    g.[Name] AS Genre,
    m.Title AS MovieTitle,
    AVG(r.Rating) AS AverageRating,
    COUNT(*) AS TotalRatings
FROM Movies m
JOIN MovieGenres mg ON m.Id = mg.MovieId
JOIN Genres g ON mg.GenreId = g.Id
JOIN Rating r ON m.Id = r.MovieId
GROUP BY g.[Name], m.Title
HAVING COUNT(*) >= 4
ORDER BY g.[Name], AverageRating DESC;

--4. Genre Popularity
SELECT 
    g.[Name] AS Genre,
    COUNT(mg.MovieId) AS TotalMovies
FROM Genres g
LEFT JOIN MovieGenres mg ON g.Id = mg.GenreId
GROUP BY g.[Name]
ORDER BY TotalMovies DESC;

--5. Content Type Distribution
SELECT 
    ContentType,
    COUNT(Id) AS Total
FROM Movies
GROUP BY ContentType;

--6. Country Movie Distribution
SELECT 
    c.[Name] AS Country,
    COUNT(m.Id) AS TotalMovies
FROM Countries c
LEFT JOIN Movies m ON c.Id = m.CountryId
GROUP BY c.[Name]
ORDER BY TotalMovies DESC;
