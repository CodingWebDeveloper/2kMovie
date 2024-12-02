CREATE DATABASE TwoKMovie;
GO
USE TwoKMovie;
GO
CREATE TABLE Roles (
 Id INT IDENTITY(1,1) PRIMARY KEY,
 [Name] NVARCHAR(50) NOT NULL,
);

CREATE TABLE Users (
 Id INT IDENTITY(1,1) PRIMARY KEY,
 [NAME] NVARCHAR(255) NOT NULL,
 Email NVARCHAR(255) NOT NULL,
 [Password] NVARCHAR(255) NOT NULL,
 RoleId INT NOT NULL,
 FOREIGN KEY (RoleId) REFERENCES Roles(Id),
);

CREATE TABLE Countries (
 Id INT IDENTITY(1,1) PRIMARY KEY,
 [Name] NVARCHAR(255) NOT NULL,
);

CREATE TABLE Generes (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[Name] NVARCHAR(255) NOT NULL,
);

CREATE TABLE Movies (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Title NVARCHAR(255) NOT NULL,
	[Description] NVARCHAR(526) NOT NULL,
	ReleaseDate DATETIME NOT NULL,
	Duration INT NOT NULL,
	ContentType NVARCHAR(255) NOT NULL CHECK(ContentType IN('Movie', 'TV-Series')) DEFAULT 'Movie',
	CountryId INT NOT NULL,
	FOREIGN KEY (CountryId) REFERENCES Countries(Id),
);

CREATE TABLE Actors (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[Name] NVARCHAR(255) NOT NULL,
);

CREATE TABLE MovieActors (
	MovieId INT NOT NULL,
	ActorId INT NOT NULL,
	FOREIGN KEY (MovieId) REFERENCES Movies(Id),
	FOREIGN KEY (ActorId) REFERENCES Actors(Id),
	PRIMARY KEY (MovieId, ActorId)
);

CREATE TABLE Genres (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[Name] NVARCHAR(255) NOT NULL,
);

CREATE TABLE MovieGenres (
	MovieId INT NOT NULL,
	GenreId INT NOT NULL,
	FOREIGN KEY (MovieId) REFERENCES Movies(Id),
	FOREIGN KEY (GenreId) REFERENCES Genres(Id),
	PRIMARY KEY (MovieId, GenreId)
);

CREATE TABLE Rating (
	MovieId INT NOT NULL,
	UserId INT NOT NULL,
	Rating INT NOT NULL CHECK(Rating IN(1,2,3,4,5,6,7,8,9,10)) DEFAULT 1,
	[Date] DATETIME NOT NULL DEFAULT GETDATE(),
	FOREIGN KEY (MovieId) REFERENCES Movies(Id),
	FOREIGN KEY (UserId) REFERENCES Users(Id),
	PRIMARY KEY (MovieId, UserId)
);

CREATE TABLE Seasons (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Title VARCHAR(255) NOT NULL,
	MovieId INT NOT NULL,
	FOREIGN KEY (MovieId) REFERENCES Movies(Id)
);

CREATE TABLE Episodes (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Title VARCHAR(255) NOT NULL,
	SeasonId INT NOT NULL,
	FOREIGN KEY (SeasonId) REFERENCES Seasons(Id)
);

CREATE TABLE [Servers] (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[Name] VARCHAR(255) NOT NULL,
	[Url] VARCHAR(255) NOT NULL,
	EpisodeId INT,
	MovieId INT,
	FOREIGN KEY (MovieId) REFERENCES Movies(Id),
	FOREIGN KEY (EpisodeId) REFERENCES Episodes(Id)
);

CREATE PROCEDURE AddMovieWithDetails
    @Title NVARCHAR(255),
    @Description NVARCHAR(255),
    @ReleaseDate DATETIME,
    @Duration INT,
    @ContentType NVARCHAR(255),
    @CountryId INT,
    @ActorIds NVARCHAR(MAX),
    @GenreIds NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert the movie
        INSERT INTO Movies (Title, [Description], ReleaseDate, Duration, ContentType, CountryId)
        VALUES (@Title, @Description, @ReleaseDate, @Duration, @ContentType, @CountryId);

        DECLARE @MovieId INT = SCOPE_IDENTITY();

        -- Insert into MovieActors
        DECLARE @ActorId NVARCHAR(50);
        WHILE LEN(@ActorIds) > 0
        BEGIN
            SET @ActorId = LEFT(@ActorIds, CHARINDEX(',', @ActorIds + ',') - 1);
            INSERT INTO MovieActors (MovieId, ActorId) VALUES (@MovieId, CAST(@ActorId AS INT));
            SET @ActorIds = STUFF(@ActorIds, 1, CHARINDEX(',', @ActorIds + ','), '');
        END;

        -- Insert into MovieGenres
        DECLARE @GenreId NVARCHAR(50);
        WHILE LEN(@GenreIds) > 0
        BEGIN
            SET @GenreId = LEFT(@GenreIds, CHARINDEX(',', @GenreIds + ',') - 1);
            INSERT INTO MovieGenres (MovieId, GenreId) VALUES (@MovieId, CAST(@GenreId AS INT));
            SET @GenreIds = STUFF(@GenreIds, 1, CHARINDEX(',', @GenreIds + ','), '');
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

CREATE FUNCTION GetAverageRating(@MovieId INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @AverageRating FLOAT;
    SELECT @AverageRating = AVG(CAST(Rating AS FLOAT))
    FROM Rating
    WHERE MovieId = @MovieId;

    RETURN ISNULL(@AverageRating, 0); -- Return 0 if no ratings exist
END;

CREATE TRIGGER AddServersForMovies
ON Movies
AFTER INSERT
AS
BEGIN
    -- Add Servers for Movies
    INSERT INTO Servers ([Name], [Url], MovieId)
    SELECT 
        ServerNames.Name, 
        '', -- Placeholder for URL, update later
        INSERTED.Id AS MovieId
    FROM 
        (VALUES ('Upcloud'), ('MegaCloud'), ('MixDrop')) AS ServerNames(Name)
    CROSS JOIN INSERTED;
END;

CREATE TRIGGER AddServersForEpisodes
ON Episodes
AFTER INSERT
AS
BEGIN
    -- Add Servers for Episodes
    INSERT INTO Servers ([Name], [Url], EpisodeId)
    SELECT 
        ServerNames.Name, 
        '', -- Placeholder for URL, update later
        INSERTED.Id AS EpisodeId
    FROM 
        (VALUES ('Upcloud'), ('MegaCloud'), ('MixDrop')) AS ServerNames(Name)
    CROSS JOIN INSERTED;
END;

INSERT INTO Roles ([Name]) 
VALUES ('Admin'), ('User');

INSERT INTO Countries ([Name]) 
VALUES ('United States'), ('Canada'), ('India'), ('United Kingdom'), ('Germany'), ('France'), ('Japan'), ('China'), ('Australia'), ('Italy');

INSERT INTO Genres ([Name]) 
VALUES ('Action'), ('Comedy'), ('Drama'), ('Horror'), ('Sci-Fi'), ('Romance'), ('Thriller'), ('Adventure'), ('Documentary'), ('Fantasy');


INSERT INTO Users ([Name], Email, [Password], RoleId)
VALUES 
('Alex Carter', 'alex.carter@gmail.com', 'password123', 1),
('Jordan Smith', 'jordan.smith@gmail.com', 'password123', 2),
('Taylor Brooks', 'taylor.brooks@gmail.com', 'password123', 2),
('Morgan Riley', 'morgan.riley@gmail.com', 'password123', 2),
('Casey Miller', 'casey.miller@gmail.com', 'password123', 2),
('Jamie Hunter', 'jamie.hunter@gmail.com', 'password123', 2),
('Quinn Parker', 'quinn.parker@gmail.com', 'password123', 2),
('Drew Cameron', 'drew.cameron@gmail.com', 'password123', 2),
('Sydney Logan', 'sydney.logan@gmail.com', 'password123', 2),
('Reese Morgan', 'reese.morgan@gmail.com', 'password123', 2);


INSERT INTO Movies (Title, [Description], ReleaseDate, Duration, ContentType, CountryId)
VALUES 
('Avengers: Endgame', 'The final showdown of the Avengers.', '2019-04-26', 181, 'Movie', 1),
('Inception', 'A thief who steals corporate secrets through dream-sharing.', '2010-07-16', 148, 'Movie', 2),
('The Dark Knight', 'Batman battles the Joker.', '2008-07-18', 152, 'Movie', 1),
('Parasite', 'A poor family infiltrates a wealthy household.', '2019-05-30', 132, 'Movie', 4),
('The Matrix', 'A computer hacker learns the truth about reality.', '1999-03-31', 136, 'Movie', 5),
('La La Land', 'A jazz musician falls in love with an aspiring actress.', '2016-12-09', 128, 'Movie', 6),
('Titanic', 'A love story set on the doomed ship.', '1997-12-19', 195, 'Movie', 1),
('Black Panther', 'Challa returns to Wakanda to assume the throne.', '2018-02-16', 134, 'Movie', 1),
('Interstellar', 'A team of explorers travels through a wormhole.', '2014-11-07', 169, 'Movie', 2),
('Joker', 'An exploration of the origins of the Joker.', '2019-10-04', 122, 'Movie', 1),
('From', 'Unravel the mystery of a nightmarish town in middle America that traps all those who enter. As the unwilling residents fight to keep a sense of normalcy and search for a way out, they must also survive the threats of the surrounding forest   including the terrifying creatures that come out when the sun goes down.', '2022-02-20', 45, 'TV-Series', 1);

INSERT INTO Actors ([Name])
VALUES 
-- Avengers: Endgame Cast
('Robert Downey Jr.'), ('Chris Evans'), ('Mark Ruffalo'), ('Chris Hemsworth'), ('Scarlett Johansson'), ('Jeremy Renner'),

-- Inception Cast
('Leonardo DiCaprio'), ('Joseph Gordon-Levitt'), ('Elliot Page'), ('Tom Hardy'),

-- The Dark Knight Cast
('Christian Bale'), ('Heath Ledger'), ('Aaron Eckhart'), ('Maggie Gyllenhaal'),

-- Parasite Cast (Top South Korean Actors)
('Song Kang-ho'), ('Choi Woo-shik'), ('Park So-dam'), ('Lee Sun-kyun'),

-- The Matrix Cast
('Keanu Reeves'), ('Laurence Fishburne'), ('Carrie-Anne Moss'), ('Hugo Weaving'),

-- Titanic Cast
('Leonardo DiCaprio'), ('Kate Winslet'), ('Billy Zane'),

-- Interstellar Cast
('Matthew McConaughey'), ('Anne Hathaway'), ('Jessica Chastain'), ('Michael Caine'),

-- Black Panther Cast
('Chadwick Boseman'), ('Michael B. Jordan'), ('Lupita Nyong'), ('Danai Gurira'),

-- Joker Cast
('Joaquin Phoenix'), ('Robert De Niro'), ('Zazie Beetz'),

-- La La Land Cast
('Ryan Gosling'), ('Emma Stone'),
-- From Cast
('Harold Perrineau'), ('Eion Bailey');


INSERT INTO MovieActors (MovieId, ActorId)
VALUES 
-- Avengers: Endgame (MovieId = 1)
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6),

-- Inception (MovieId = 2)
(2, 7), (2, 8), (2, 9), (2, 10),

-- The Dark Knight (MovieId = 3)
(3, 11), (3, 12), (3, 13), (3, 14),

-- Parasite (MovieId = 4)
(4, 15), (4, 16), (4, 17), (4, 18),

-- The Matrix (MovieId = 5)
(5, 19), (5, 20), (5, 21), (5, 22),

-- Titanic (MovieId = 6)
(6, 7), (6, 23), (6, 24),

-- Interstellar (MovieId = 7)
(7, 25), (7, 26), (7, 27), (7, 28),

-- Black Panther (MovieId = 8)
(8, 29), (8, 30), (8, 31), (8, 32),

-- Joker (MovieId = 9)
(9, 33), (9, 34), (9, 35),

-- La La Land (MovieId = 10)
(10, 36), (10, 37),
-- From (MovieId = 11)
 (11, 38), (11, 39);


INSERT INTO MovieGenres (MovieId, GenreId)
VALUES 
(1, 1), (1, 7), -- Avengers: Endgame (Action, Thriller)
(2, 5), -- Inception (Sci-Fi)
(3, 3), (3, 7), -- The Dark Knight (Drama, Thriller)
(4, 3), -- Parasite (Drama)
(5, 5), -- The Matrix (Sci-Fi)
(6, 6), -- La La Land (Romance)
(7, 6), -- Titanic (Romance)
(8, 1), (8, 7), -- Black Panther (Action, Thriller)
(9, 5), (9, 8), -- Interstellar (Sci-Fi, Adventure)
(10, 3), -- Joker (Drama)
(11, 3);

INSERT INTO Rating (MovieId, UserId, Rating)
VALUES 
(1, 1, 10), (2, 2, 9), (3, 3, 9), (4, 4, 8), 
(5, 5, 10), (6, 6, 8), (7, 7, 9), (8, 8, 9),
(9, 9, 10), (10, 10, 8), (11, 2, 10),
(1, 3, 8),
(1, 4, 9),
(2, 5, 10),
(2, 6, 7),
(3, 7, 9),
(3, 8, 10),
(4, 9, 7),
(4, 10, 9),
(5, 1, 10),
(5, 2, 9),
(6, 3, 8),
(6, 4, 10),
(7, 5, 10),
(7, 6, 9),
(8, 7, 8),
(8, 9, 9),
(9, 10, 10),
(10, 1, 8),
(10, 2, 9),
(11, 3, 9),
(11, 4, 7);

INSERT INTO Seasons (Title, MovieId)
VALUES 
('Season 1', 11),
('Season 2', 11);

INSERT INTO Episodes (Title, SeasonId)
VALUES 
('Episode 1: Long Day''s Journey Into Night', 1),
('Episode 2: The Way Thins Are Now', 1),
('Episode 1: Strangers in a Strange Land', 2),
('Episode 2: The Kindness of Strangers', 2);

INSERT INTO [Servers]([Name], [Url], [EpisodeId], [MovieId])
VALUES 
	('UpCloud', 'http://upcloud/avengers-endgame', NULL, 1),
	('MegaCloud', 'http://megacloud/avengers-endgame', NULL, 1),
	('MixDrop', 'http://mixdrop/avengers-endgame', NULL, 1),
	('UpCloud', 'http://upcloud/inception', NULL, 2),
	('MegaCloud', 'http://megacloud/the-dark-night', NULL, 3),
	('MixDrop', 'http://mixdrop/the-dark-night', NULL, 3),
	('MegaCloud', 'http://megacloud/parasite', NULL, 4),
	('MixDrop', 'http://mixdrop/parasite', NULL, 4),
	('MegaCloud', 'http://megacloud/the-matrix', NULL, 5),
	('MixDrop', 'http://mixdrop/the-matrix', NULL, 5),
	('MegaCloud', 'http://megacloud/from&season=1&ep=1', 1, NULL),
	('MixDrop', 'http://mixdrop/from&season=1&ep=1', 1,  NULL),
	('MegaCloud', 'http://megacloud/from&season=1&ep=2', 2, NULL),
	('MixDrop', 'http://mixdrop/from&season=1&ep=2', 2,  NULL);
	
-- Function
SELECT
    m.Id,
    m.Title,
    m.[Description],
    m.ReleaseDate,
    m.Duration,
    m.ContentType,
    dbo.GetAverageRating(m.Id) AS AvgRating
FROM 
    Movies m

-- Procedure
 EXEC AddMovieWithDetails 
    @Title = 'Deadpool & Wolverine',
    @Description = 'A listless Wade Wilson toils away in civilian life with his days as the morally flexible mercenary, Deadpool, behind him. But when his homeworld faces an existential threat, Wade must reluctantly suit-up again with an even more reluctant Wolverine.',
    @ReleaseDate = '2024-07-24',
    @Duration = 127,
    @ContentType = 'Movie',
    @CountryId = 1,
    @ActorIds = '2,',
    @GenreIds = '1,2,5';

