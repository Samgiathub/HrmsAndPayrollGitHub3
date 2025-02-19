
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_CANTEEN_REMOVE_IO_GAP] 
	@Cmp_ID Numeric(18,0),
	@From_Date DateTime,
	@To_Date DateTime	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
    if (OBJECT_ID('tempdb..#TEMP') IS NULL)
		CREATE TABLE #TEMP(RowID BigInt,Emp_ID Numeric(18,0),Cmp_ID Numeric(18,0),Cnt_ID Numeric(18,0),From_Time DateTime,To_Time DateTime,Effective_Date DateTime,Amount Numeric(18,0),IO_DateTime DateTime)
	
	
		
	DELETE FROM #TEMP WHERE (IO_DateTime NOT BETWEEN @From_Date AND @To_Date) -- AND (IO_DateTime NOT Between From_Time AND To_Time)
					
	DELETE FROM #TEMP WHERE (IO_DateTime NOT Between From_Time AND To_Time)	
				
	DELETE FROM #TEMP WHERE Effective_Date > IO_DateTime

	DELETE FROM #TEMP WHERE Effective_Date <> (Select Max(Effective_Date) FROM #TEMP T
					WHERE T.Emp_ID=#TEMP.Emp_ID AND T.IO_DateTime=#TEMP.IO_DateTime AND T.IP_Address=#TEMP.IP_Address)
					--Removed Company ID Joining when IN-OUT is downloading from one company for another company
					--WHERE T.Cmp_Id=#TEMP.Cmp_Id AND T.Emp_ID=#TEMP.Emp_ID AND T.IO_DateTime=#TEMP.IO_DateTime AND T.IP_Address=#TEMP.IP_Address) 


		
	DECLARE @MaxGapLimit Numeric(18,0);
	SET @MaxGapLimit = 0;
	
	SELECT	@MaxGapLimit=Cast(Setting_Value As Numeric(18,0)) 
	FROM	T0040_SETTING WITH (NOLOCK)
	WHERE	Setting_Name='Maximum gap between two canteen punch (In minutes)' AND
			IsNull(Setting_Value,'') <> '' AND Cmp_ID=@Cmp_ID
	
	

	IF (@MaxGapLimit =0)
		RETURN;
		
	
	
	UPDATE	#TEMP 
	SET		RowID=T.R_ID
	FROM	(SELECT ROW_NUMBER() OVER (PARTITION BY Emp_ID ORDER BY Cmp_ID,Emp_ID,IO_DATETIME) As R_ID,RowID
			FROM #TEMP) T
	WHERE	#TEMP.RowID=T.RowID
	
	
	
	DECLARE @RowID BigInt;
	
	;WITH TBL1(R_ID,RowID, Emp_ID, IO_DATETIME,IP_Address) AS
	(
		SELECT ROW_NUMBER() OVER (PARTITION BY Emp_ID Order By IO_DateTime) R_ID, RowID, Emp_ID, IO_DATETIME,IP_Address
		FROM #TEMP D
		--WHERE CMP_ID=@Cmp_ID 
	)		
	SELECT  TBL1.*,TBL2.RowID As RowID2,TBL2.IO_DATETIME AS LAST_IO_DATETIME
	INTO	#GAP
	FROM	TBL1 LEFT OUTER JOIN (
					SELECT ROW_NUMBER() OVER (PARTITION BY Emp_ID Order By IO_DateTime) R_ID, D1.RowID, D1.Emp_ID, D1.IO_DATETIME,IP_Address
					FROM #TEMP D1
					--WHERE D1.CMP_ID=@Cmp_ID 
			) TBL2 ON TBL1.Emp_ID=TBL2.Emp_ID AND TBL1.R_ID=(TBL2.R_ID-1) AND TBL1.IP_Address=TBL2.IP_Address
	Order by TBL1.Emp_ID, TBL1.R_ID
	
	Select @RowID=R_ID FROM #GAP WHERE DATEDIFF(n,IO_DATETIME,LAST_IO_DATETIME) BETWEEN 0 AND @MaxGapLimit
	WHILE (IsNull(@RowID,0) > 0) BEGIN		
		--Modified by Nimesh on 06-Jan-2016 (Employee wise does not working)
		--DELETE FROM #TEMP WHERE RowID IN (SELECT R_ID FROM #GAP WHERE DATEDIFF(n,IO_DATETIME,LAST_IO_DATETIME) BETWEEN 0 AND @MaxGapLimit)
		DELETE #TEMP FROM #TEMP T INNER JOIN 
			(SELECT R_ID, EMP_ID FROM #GAP WHERE DATEDIFF(n,IO_DATETIME,LAST_IO_DATETIME) BETWEEN 0 AND @MaxGapLimit) G ON T.RowID=G.R_ID AND T.Emp_ID=G.EMP_ID
		
		--DELETE FROM #GAP WHERE R_ID IN (SELECT R_ID FROM #GAP WHERE DATEDIFF(n,IO_DATETIME,LAST_IO_DATETIME) BETWEEN 0 AND @MaxGapLimit)
		DELETE #GAP FROM #GAP G1 INNER JOIN 
			(SELECT R_ID, EMP_ID FROM #GAP WHERE DATEDIFF(n,IO_DATETIME,LAST_IO_DATETIME) BETWEEN 0 AND @MaxGapLimit) G2 ON G1.R_ID=G2.R_ID AND G1.Emp_ID=G2.EMP_ID
		
		SET @RowID = 0;
		Select @RowID=R_ID FROM #GAP WHERE DATEDIFF(n,IO_DATETIME,LAST_IO_DATETIME) BETWEEN 0 AND @MaxGapLimit
		
	END 
END


