

-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 07/09/2023
-- Description:	To Get the Total Distance of Particular Employee Live Tracking
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_LiveTracking_TotalDistance]
	@Cmp_ID NUMERIC(18,0),
	@Emp_ID NUMERIC(18,0),
	@Created_Date nvarchar(20) = ''	
AS
BEGIN
	
		SELECT 
		MAX(CASE WHEN RowNum = 1 THEN Origin_Location END) AS Origin_Location,
		MAX(CASE WHEN RowNum = TotalRows THEN Destination_Location END) AS Destination_Location,
		SUM(CASE WHEN CONVERT(varchar, Created_Date, 103) = CONVERT(varchar, @Created_Date, 103) THEN Distance_Km END) AS Distance_Km
		FROM
			(SELECT 
				Origin_Location, 
				Destination_Location, 
				Distance_Km, 
				Created_Date,
				ROW_NUMBER() OVER (ORDER BY LT_Id ASC) AS RowNum,
				COUNT(*) OVER () AS TotalRows
			FROM 
				T0060_Live_Tracking
			where Cmp_Id=@Cmp_ID and Emp_Id=@Emp_ID			
			and CONVERT(varchar, Created_Date, 103) = CONVERT(varchar, @Created_Date, 103)) AS T 
			--CONVERT(VARCHAR(10), Created_Date, 103) + ' '  + convert(VARCHAR(8), Created_Date, 14)
			--= CONVERT(VARCHAR(10), @Created_Date, 103) + ' '  + convert(VARCHAR(8), @Created_Date, 14)) AS T
			--CONVERT(varchar, Created_Date, 131) = CONVERT(varchar, @Created_Date, 131)) AS T

			

		--SELECT isnull(SUM(Distance_Km),0) AS Total_Distance_Km,Origin_Location,Destination_Location
		--FROM T0060_Live_Tracking
		--WHERE Cmp_Id = @Cmp_ID
		--AND Emp_Id = @Emp_ID
		--AND CONVERT(varchar, Created_Date, 103) = CONVERT(varchar, @Created_Date, 103)
		--group by Origin_Location,Destination_Location
	
END
