
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
Create PROCEDURE [dbo].[P0050_CALCULATE_CANTEEN_DEDUCTION_Backpubyronakk31012023] 
	@CMP_ID NUMERIC(18,0),
	@EMP_ID NUMERIC(18,0),
	@FROM_DATE DATETIME,
	@TO_DATE DATETIME,
	@CANTEEN_AMOUNT NUMERIC(18,2) OUTPUT
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	SET @From_Date = CONVERT(DateTime,CONVERT(Char(10), @From_Date, 103), 103);
	SET @To_Date= CONVERT(DateTime,CONVERT(Char(10), @To_Date, 103) + ' 23:59:59', 103);

	
	DECLARE @Enroll_No Numeric(18,0);
	declare @grade Numeric(18,0);
	
	SELECT Top 1 @Enroll_No=Enroll_No, @grade = I.Grd_ID From T0080_EMP_MASTER E WITH (NOLOCK) inner join  T0095_Increment I WITH (NOLOCK) on E.Emp_ID = I.Emp_ID
	inner join     
   (select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)    
   where Increment_Effective_date <= @to_date and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_id group by emp_ID) Qry on    
   I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
   Where I.Emp_ID = @Emp_ID   and  E.Cmp_ID=@Cmp_ID 
	
	
	--Retrieving Canteen Details in Temp table.
	SELECT	@Emp_ID As Emp_ID,M.Cmp_Id,M.Cnt_ID,CAST(From_Time As DateTime) As From_Time, Cast(To_Time As DateTime) As To_Time,
			Effective_Date,Amount,grd_id,Ip_id
	INTO	#CANTEEN
	FROM	T0050_CANTEEN_MASTER M WITH (NOLOCK) INNER JOIN T0050_CANTEEN_DETAIL D WITH (NOLOCK) ON M.Cmp_Id=D.Cmp_Id AND M.Cnt_Id=D.Cnt_Id			
	WHERE	D.Effective_Date <= @To_Date and grd_id =@grade 
		

	
	SELECT	ROW_NUMBER() OVER(ORDER BY I.IO_TRAN_ID) As RowID,T.*,I.IO_DateTime,I.IP_Address,IP.Device_No, IP.Device_Name
	INTO	#TEMP 
	FROM	T9999_DEVICE_INOUT_DETAIL I  WITH (NOLOCK)
			inner JOIN T0040_IP_MASTER IP WITH (NOLOCK) ON I.IP_Address=IP.IP_ADDRESS 
			left JOIN #CANTEEN T  ON ip.ip_id = T.ip_id AND T.Effective_Date <= I.IO_DateTime 
	WHERE	I.Enroll_No=@Enroll_No and T.grd_id =@grade  ---AND I.Cmp_ID=@Cmp_ID			
			AND (I.In_Out_flag=10 OR I.IP_Address='Canteen' OR IP.Device_No >= 200 Or isnull(Ip.Is_Canteen,0) = 1) 
			AND (I.IO_DateTime BETWEEN @From_Date AND @To_Date)
			
	--Updating From_Time and To_Time for night shift
	UPDATE	#TEMP
	SET		From_Time = ((Case When (DateDiff(n, Cast(Cast(IO_DateTime As Date) AS DateTime), IO_DateTime) < 720 AND From_Time > To_Time )  
					THEN DateAdd(d,-1,From_Time) 
				ELSE
					From_Time 
				END
			) + CONVERT(DATETIME, CONVERT(CHAR(10),IO_DateTime, 103), 103)),
			To_Time = ((Case When (DateDiff(n, Cast(Cast(IO_DateTime As Date) AS DateTime), IO_DateTime) > 720 AND From_Time > To_Time )  
					THEN DateAdd(d,1,To_Time) 
				ELSE
					To_Time
				END
			) + CONVERT(DATETIME, CONVERT(CHAR(10),IO_DateTime, 103), 103))		
	

	--Removing GAP between two In-Out Detail which is less than 5 minutes
	exec P0050_CANTEEN_REMOVE_IO_GAP @Cmp_ID, @From_Date, @To_Date
	

	--Getting sum of Amount
	SELECT	@Canteen_Amount = SUM(Amount) 
	FROM	#TEMP T1	
	
	--Should not be null 		
	IF (@Canteen_Amount IS NULL)
		SET @Canteen_Amount = 0;
END

						
