
IF OBJECT_ID('tempdb..#Area') IS NOT NULL DROP TABLE #reportlist
CREATE TABLE dbo.#Area(
   AreaID int NOT NULL,
   AreaName varchar(100) NOT NULL,
   ParentAreaID int NULL,
   AreaType varchar(20) NOT NULL
CONSTRAINT PK_Area PRIMARY KEY CLUSTERED 
( AreaID ASC
) ON [PRIMARY])
GO

INSERT INTO #Area(AreaID,AreaName,ParentAreaID,AreaType)
VALUES(1, 'Canada', null, 'Country')
 
INSERT INTO #Area(AreaID,AreaName,ParentAreaID,AreaType)
VALUES(2, 'United States', null, 'Country')
 
INSERT INTO #Area(AreaID,AreaName,ParentAreaID,AreaType)
VALUES(3, 'Saskatchewan', 1, 'State')
 
INSERT INTO #Area(AreaID,AreaName,ParentAreaID,AreaType)
VALUES(4, 'Saskatoon', 3, 'City')
 
INSERT INTO #Area(AreaID,AreaName,ParentAreaID,AreaType)
VALUES(5, 'Florida', 2, 'State')
 
INSERT INTO #Area(AreaID,AreaName,ParentAreaID,AreaType)
VALUES(6, 'Miami', 5, 'City')

select * from #Area
where AreaType = 'City'

SELECT * FROM #Area

;WITH AreasCTE AS
( 
--anchor select, start with the country of Canada, which will be the root element for our search
SELECT AreaID, AreaName, ParentAreaID, AreaType
FROM #Area 
WHERE AreaName = 'Canada'
UNION ALL
--recursive select, recursive until you reach a leaf (an Area which is not a parent of any other area)
SELECT a.AreaID, a.AreaName, a.ParentAreaID, a.AreaType 
FROM #Area a 
INNER JOIN AreasCTE s ON a.ParentAreaID = s.AreaID 
) 

SELECT * FROM AreasCTE