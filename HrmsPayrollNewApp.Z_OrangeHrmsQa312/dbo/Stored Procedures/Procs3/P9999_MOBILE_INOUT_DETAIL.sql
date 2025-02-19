

 ---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_MOBILE_INOUT_DETAIL]
	@Emp_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@FromDate datetime,
	@ToDate datetime,
	@Branch_ID numeric = 0,
	@Cat_ID numeric = 0,
	@Grd_ID numeric = 0,
	@Type_ID numeric = 0,
	@Dept_ID numeric = 0,
	@Desig_ID numeric = 0,
	@Constraint varchar(MAX) = '',
	@TranType char(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


IF @TranType = 'L' --- For Mobile Attendance List
	BEGIN	
		DECLARE @RowNo INT  = 1
		DECLARE @Count INT = 0
		DECLARE @IO_Tran_DetailsID numeric(18,0)
		DECLARE @IO_Tran_ID numeric(18,0)
		DECLARE @IMEI_No varchar(50)
		DECLARE @Latitude varchar(50)
		DECLARE @Longitude varchar(50)
		DECLARE @Location varchar(50)
		DECLARE @Emp_Image varchar(50)
		DECLARE @Reason varchar(50)
		DECLARE @IODateTime datetime
		DECLARE @IO_Flag varchar(10)
		
		CREATE TABLE #MOBILE_INOUT
		(
			RowNo numeric(18,0),
			Cmp_ID numeric(18,0),
			Emp_ID numeric(18,0),
			In_IMEI_No varchar(50),
			In_Latitude varchar(50),
			In_Longitude varchar(50),
			In_Location varchar(50),
			In_Emp_Image varchar(50),
			In_Reason varchar(50),
			Out_IMEI_No varchar(50),
			Out_Latitude varchar(50),
			Out_Longitude varchar(50),
			Out_Location varchar(50),
			Out_Emp_Image varchar(50),
			Out_Reason varchar(50),
			ForDate datetime,
			InTime datetime,
			OutTime datetime
		)
		
		CREATE TABLE #Emp_Cons
		(      
			Emp_ID numeric ,     
			Branch_ID numeric,
			Increment_ID numeric    
		)
		
		EXEC SP_RPT_FILL_EMP_CONS @Cmp_ID,@FromDate,@ToDate,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint
		
		SELECT ROW_NUMBER() OVER(ORDER BY IO_Tran_DetailsID ASC) AS 'RowNo' ,MI.* 
		INTO #MobileData 
		FROM T9999_MOBILE_INOUT_DETAIL MI WITH (NOLOCK)
		INNER JOIN #Emp_Cons E ON MI.Emp_ID = E.Emp_ID
		WHERE MI.Emp_ID = @Emp_ID AND MI.Cmp_ID = @Cmp_ID 
		AND CAST(CAST(IO_DATETime AS varchar(11)) AS datetime) >= @FromDate AND CAST(CAST(IO_DATETime AS varchar(11)) AS datetime) <= @ToDate
		ORDER BY IO_Tran_DetailsID ASC

		SELECT @Count = COUNT(*) 
		FROM T9999_MOBILE_INOUT_DETAIL MI WITH (NOLOCK)
		INNER JOIN #Emp_Cons E ON MI.Emp_ID = E.Emp_ID
		WHERE MI.Emp_ID = @Emp_ID AND MI.Cmp_ID = @Cmp_ID 
		AND CAST(CAST(IO_DATETime AS varchar(11)) AS datetime) >= @FromDate AND CAST(CAST(IO_DATETime AS varchar(11)) AS datetime) <= @ToDate

		IF @Count > 0
			BEGIN
				WHILE @RowNo <= @Count
					BEGIN
						SELECT @IO_Tran_DetailsID = IO_Tran_DetailsID, @IO_Tran_ID = IO_Tran_ID,@IODateTime = IO_Datetime,
						@IMEI_No = IMEI_No,@IO_Flag = In_Out_Flag,@Latitude = Latitude,@Longitude = Longitude,
						@Location = Location,@Emp_Image = Emp_Image,@Reason = Reason
						FROM #MobileData 
						WHERE RowNo = @RowNo
						
						IF @IO_Flag = 'I'
							BEGIN
								INSERT INTO #MOBILE_INOUT (RowNo,Cmp_ID,Emp_ID,In_IMEI_No,In_Latitude,
								In_Longitude,In_Location,In_Emp_Image,In_Reason,ForDate,InTime) 
								VALUES(@RowNo,@Cmp_ID,@Emp_ID,@IMEI_No,@Latitude,@Longitude,
								@Location,@Emp_Image,@Reason,CAST(@IODateTime AS varchar(11)), @IODateTime)
							END
						ELSE
							BEGIN
								IF NOT EXISTS (SELECT 1 FROM #MOBILE_INOUT WHERE OutTime IS NULL AND RowNo = (SELECT ISNULL(MAX(RowNo),0) FROM #MOBILE_INOUT))
									BEGIN
										INSERT INTO #MOBILE_INOUT (RowNo,Cmp_ID,Emp_ID,Out_IMEI_No,Out_Latitude,
										Out_Longitude,Out_Location,Out_Emp_Image,Out_Reason,ForDate,OutTime) 
										VALUES(@RowNo,@Cmp_ID,@Emp_ID,@IMEI_No,@Latitude,@Longitude,
										@Location,@Emp_Image,@Reason,CAST(@IODateTime AS varchar(11)),@IODateTime)
									END
								ELSE
									BEGIN
										UPDATE #MOBILE_INOUT SET Out_IMEI_No = @IMEI_No,Out_Latitude = @Latitude,Out_Longitude = @Longitude,
										Out_Location = @Location,Out_Emp_Image = @Emp_Image,Out_Reason = @Reason,OutTime = @IODateTime
										WHERE RowNo = (@RowNo - 1)
									END
							END
						SET @RowNo = @RowNo + 1
					END
			END
		
		SELECT MI.Cmp_ID,MI.Emp_ID,CONVERT(varchar(11),MI.ForDate,103) AS 'ForDate',
		--CONVERT(varchar(5),MI.InTime,108) AS 'In',CONVERT(varchar(5),MI.OutTime,108) AS 'Out',
		(CASE WHEN MI.InTime IS NULL THEN '' ELSE CONVERT(varchar(19),MI.InTime,121) END) AS 'InTime',
		(CASE WHEN MI.OutTime IS NULL THEN '' ELSE CONVERT(varchar(19),MI.OutTime,121) END) AS 'OutTime',
		
		SM.Shift_Name,SM.Shift_St_Time,SM.Shift_End_Time,
		(EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name) AS 'Emp_Name',dbo.F_Return_Hours_From_Date(MI.InTime,MI.OutTime) AS 'Duration',
		MI.In_Latitude,MI.In_Longitude,MI.Out_Latitude,MI.Out_Longitude
		
		FROM #MOBILE_INOUT MI
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MI.Emp_ID = EM.Emp_ID
		INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON SM.Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(MI.Cmp_ID,MI.Emp_ID,MI.ForDate)

		--WHERE MI.Emp_ID = @Emp_ID AND MI.Cmp_ID = @Cmp_ID AND
		--CAST(CAST(ForDate AS varchar(11)) AS datetime) >= @FromDate AND CAST(CAST(ForDate AS varchar(11)) AS datetime) <= @ToDate


		--SELECT InTime,OutTime, * 
		--FROM #MOBILE_INOUT
		--WHERE  Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND
		--CAST(CAST(ForDate AS varchar(11)) AS datetime) >= @FromDate AND CAST(CAST(ForDate AS varchar(11)) AS datetime) <= @ToDate
		DROP TABLE #MOBILE_INOUT
	
	END
ELSE IF @TranType = 'R' --- For Mobile Attendance Route
	BEGIN
		SELECT * FROM T9999_MOBILE_INOUT_DETAIL WITH (NOLOCK)
		WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND IO_Datetime BETWEEN @FromDate AND @ToDate
		ORDER BY IO_Datetime
	END
	
	
	
