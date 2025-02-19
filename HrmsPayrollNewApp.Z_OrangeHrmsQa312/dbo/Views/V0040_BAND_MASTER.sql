




CREATE VIEW [dbo].[V0040_BAND_MASTER]
AS
SELECT [BandId],Bandcode ,[BandName],SortingNo ,[IsActive],Cmp_ID,IsActiveEffDate
FROM [tblBandMaster] With (Nolock)
