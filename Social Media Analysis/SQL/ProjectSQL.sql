-- Platform Table
CREATE TABLE Platform (
    PlatformID INT AUTO_INCREMENT PRIMARY KEY,
    PlatformName VARCHAR(20) NOT NULL
);

-- Post Table
CREATE TABLE Post (
    PostID VARCHAR(40) PRIMARY KEY,
    PlatformID INT, -- References Platform table
    PostType TEXT,
    PostContent TEXT,
    PostTimeStamp DATETIME,
    FOREIGN KEY (PlatformID) REFERENCES Platform(PlatformID)
);

-- Engagement Table
CREATE TABLE Engagement (
    EngagementID INT AUTO_INCREMENT PRIMARY KEY,
    PostID VARCHAR(40), -- References Post table
    Likes INT,
    Comments INT,
    Shares INT,
    Impressions INT,
    Reach INT,
    EngagementRate FLOAT,
    EngagementRateNormalized FLOAT,
    FOREIGN KEY (PostID) REFERENCES Post(PostID)
);

-- Sentiment Table
CREATE TABLE Sentiment (
    SentimentID INT AUTO_INCREMENT PRIMARY KEY,
    PostID VARCHAR(40), -- References Post table
    Sentiment FLOAT,
    SentimentCategory TEXT,
    FOREIGN KEY (PostID) REFERENCES Post(PostID)
);

-- Time Table
CREATE TABLE Time (
    TimeID INT AUTO_INCREMENT PRIMARY KEY,
    PostID VARCHAR(40), -- References Post table
    Date DATE, -- Direct reference to FullDate in Date table
    WeekdayType VARCHAR(20),
    Time VARCHAR(30),
    TimePeriods VARCHAR(30),
    Hour INT,
    TimeOfDay VARCHAR(20),
    FOREIGN KEY (PostID) REFERENCES Post(PostID)
);

-- Date Table
CREATE TABLE Date (
    DateID INT AUTO_INCREMENT PRIMARY KEY,
    FullDate DATE UNIQUE, -- Unique date
    Year INT,
    Month INT,
    MonthName VARCHAR(20),
    Day INT,
    DayName VARCHAR(20),
    Week INT,
    Quarter INT,
    IsWeekend BOOLEAN
);

-- Demographics Table
CREATE TABLE Demographics (
    DemographicID INT AUTO_INCREMENT PRIMARY KEY,
    PostID VARCHAR(40), -- References Post table
    AudienceAge INT,
    AgeGroup VARCHAR(20),
    AudienceGender VARCHAR(20),
    AudienceLocation VARCHAR(100),
    AudienceContinent VARCHAR(50),
    AudienceInterests TEXT,
    FOREIGN KEY (PostID) REFERENCES Post(PostID)
);

INSERT INTO Platform (PlatformName)
VALUES 
('Facebook'),
('Instagram'),
('LinkedIn'),
('Twitter');

INSERT INTO Post (PostID, PlatformID, PostType, PostContent, PostTimeStamp)
SELECT DISTINCT
    `Post ID`,
    CASE 
        WHEN `Platform_Facebook` = 1 THEN 1
        WHEN `Platform_Instagram` = 1 THEN 2
        WHEN `Platform_LinkedIn` = 1 THEN 3
        WHEN `Platform_Twitter` = 1 THEN 4
    END AS PlatformID,
    `Post Type`,
    `Post Content`,
    STR_TO_DATE(`Post Timestamp`, '%d/%m/%Y %H:%i') AS PostTimeStamp
FROM `first`;

INSERT INTO Date (FullDate, Year, Month, MonthName, Day, DayName, Week, Quarter, IsWeekend)
SELECT DISTINCT
    STR_TO_DATE(`Date`, '%d/%m/%Y %H:%i') AS FullDate,
    YEAR(STR_TO_DATE(`Date`, '%d/%m/%Y %H:%i')) AS Year,
    MONTH(STR_TO_DATE(`Date`, '%d/%m/%Y %H:%i')) AS Month,
    MONTHNAME(STR_TO_DATE(`Date`, '%d/%m/%Y %H:%i')) AS MonthName,
    DAY(STR_TO_DATE(`Date`, '%d/%m/%Y %H:%i')) AS Day,
    DAYNAME(STR_TO_DATE(`Date`, '%d/%m/%Y %H:%i')) AS DayName,
    WEEK(STR_TO_DATE(`Date`, '%d/%m/%Y %H:%i')) AS Week,
    QUARTER(STR_TO_DATE(`Date`, '%d/%m/%Y %H:%i')) AS Quarter,
    CASE WHEN DAYOFWEEK(STR_TO_DATE(`Date`, '%d/%m/%Y %H:%i')) IN (1, 7) THEN TRUE ELSE FALSE END AS IsWeekend
FROM `first`;

INSERT INTO Time (PostID, Date, WeekdayType, Time, TimePeriods, Hour, TimeOfDay)
SELECT DISTINCT
    `Post ID`,
    STR_TO_DATE(`Date`, '%d/%m/%Y %H:%i') AS Date, -- Correctly formatted Date
    `Weekday Type`,
    `Time`,
    `Time Periods`,
    `Hour`,
    `time_of_day`
FROM `first`;

INSERT INTO Engagement (PostID, Likes, Comments, Shares, Impressions, Reach, EngagementRate, EngagementRateNormalized)
SELECT
    `Post ID`,
    `Likes`,
    `Comments`,
    `Shares`,
    `Impressions`,
    `Reach`,
    `Engagement Rate`,
    `Engagement Rate Normalized`
FROM `first`;

INSERT INTO Sentiment (PostID, Sentiment, SentimentCategory)
SELECT DISTINCT
    `Post ID`,
    `Sentiment`,
    `Sentiment Category`
FROM `first`;


INSERT INTO Demographics (PostID, AudienceAge, AgeGroup, AudienceGender, AudienceLocation, AudienceContinent, AudienceInterests)
SELECT DISTINCT
    `Post ID`,
    `Audience Age`,
    `Age Group`,
    `Audience Gender`,
    `Audience Location`,
    `Audience Continent`,
    `Audience Interests`
FROM `first`;

SELECT 
    p.PlatformName,
    po.PostType,
    AVG(e.EngagementRate) AS AvgEngagementRate,
    COUNT(po.PostID) AS TotalPosts
FROM Post po
JOIN Platform p ON po.PlatformID = p.PlatformID
JOIN Engagement e ON po.PostID = e.PostID
GROUP BY p.PlatformName, po.PostType
ORDER BY AvgEngagementRate DESC;

SELECT 
    po.PostID,
    po.PostContent,
    e.EngagementRate,
    p.PlatformName
FROM Post po
JOIN Engagement e ON po.PostID = e.PostID
JOIN Platform p ON po.PlatformID = p.PlatformID
ORDER BY e.EngagementRate DESC
LIMIT 10;

SELECT 
    p.PlatformName,
    d.AgeGroup,
    d.AudienceGender,
    COUNT(d.PostID) AS TotalPosts
FROM Demographics d
JOIN Post po ON d.PostID = po.PostID
JOIN Platform p ON po.PlatformID = p.PlatformID
GROUP BY p.PlatformName, d.AgeGroup, d.AudienceGender
ORDER BY p.PlatformName, d.AgeGroup, d.AudienceGender;

SELECT 
    DATE_FORMAT(d.FullDate, '%Y-%m') AS Month,
    SUM(e.Likes) AS TotalLikes,
    SUM(e.Comments) AS TotalComments,
    SUM(e.Shares) AS TotalShares,
    AVG(e.EngagementRate) AS AvgEngagementRate
FROM Engagement e
JOIN Post po ON e.PostID = po.PostID
JOIN Time t ON po.PostID = t.PostID
JOIN Date d ON t.Date = d.FullDate
GROUP BY DATE_FORMAT(d.FullDate, '%Y-%m')
ORDER BY Month;

SELECT 
    p.PlatformName,
    s.SentimentCategory,
    COUNT(s.PostID) AS TotalPosts,
    AVG(s.Sentiment) AS AvgSentimentScore
FROM Sentiment s
JOIN Post po ON s.PostID = po.PostID
JOIN Platform p ON po.PlatformID = p.PlatformID
GROUP BY p.PlatformName, s.SentimentCategory
ORDER BY p.PlatformName, AvgSentimentScore DESC;

SELECT 
    t.TimeOfDay,
    AVG(e.EngagementRate) AS AvgEngagementRate,
    SUM(e.Likes) AS TotalLikes,
    SUM(e.Comments) AS TotalComments
FROM Engagement e
JOIN Post po ON e.PostID = po.PostID
JOIN Time t ON po.PostID = t.PostID
GROUP BY t.TimeOfDay
ORDER BY AvgEngagementRate DESC;
