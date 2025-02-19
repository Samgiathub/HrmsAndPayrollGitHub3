

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_CALCULATE_CANTEEN_DEDUCTION_CERA] 
	@Cmp_ID Numeric(18,0),
	@Emp_ID Numeric(18,0),
	@From_Date DateTime,
	@To_Date DateTime,
	@Canteen_Amount Numeric(18,2) Output
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Canteen_Device_Amount AS  Numeric(18,2)
	DECLARE @Canteen_NFC_Amount AS  Numeric(18,2)
	SET @Canteen_Device_Amount = 0
	SET @Canteen_NFC_Amount = 0
	SET @From_Date = CONVERT(DateTime,CONVERT(Char(10), @From_Date, 103), 103);
	SET @To_Date= CONVERT(DateTime,CONVERT(Char(10), @To_Date, 103) + ' 23:59:59', 103);

	
	DECLARE @Enroll_No Numeric(18,0);
	--SELECT Top 1 @Enroll_No=Enroll_No From T0080_EMP_MASTER E Where E.Cmp_ID=@Cmp_ID AND E.Emp_ID=@Emp_ID
	declare @grade Numeric(18,0);

	
	--  isnull(old_ref_no,Enroll_No) COMMENTED BY RAJPUT ON 10092018
	SELECT Top 1 @Enroll_No= CASE WHEN  isnull(old_ref_no,'') = '' THEN Enroll_No ELSE Old_Ref_No END, @grade = I.Grd_ID From T0080_EMP_MASTER E WITH (NOLOCK)
	inner join  T0095_Increment I WITH (NOLOCK) on E.Emp_ID = I.Emp_ID -- isnull(old_ref_no,Enroll_No) old_ref_no take as enroll_no Added by rajput on 20082018
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
		

	--Filtering data according to T9999_DEVICE_INOUT_DETAIL entries
	--SELECT	Cast(0 As Bigint) As RowID,T.*,I.IO_DateTime
	--INTO	#TEMP 
	--FROM	(#CANTEEN T INNER JOIN T9999_DEVICE_INOUT_DETAIL I ON I.Cmp_ID=T.Cmp_Id)
	--		INNER JOIN T0040_IP_MASTER IP ON I.Cmp_ID=IP.Cmp_ID AND I.IP_Address=IP.IP_ADDRESS 
	--WHERE	I.Enroll_No=@Enroll_No AND T.Effective_Date <= I.IO_DateTime AND I.Cmp_ID=@Cmp_ID
	--		--AND (Cast(CONVERT(varchar(5), I.IO_DateTime, 108) As DateTime) Between T.From_Time AND T.To_Time)
	--		AND (I.In_Out_flag=10 OR I.IP_Address='Canteen' OR IP.Device_No >= 200) 
	
	SELECT	ROW_NUMBER() OVER(ORDER BY I.IO_TRAN_ID) As RowID,T.*,I.IO_DateTime,I.IP_Address,IP.Device_No, IP.Device_Name
	INTO	#TEMP 
	FROM	T9999_DEVICE_INOUT_DETAIL I WITH (NOLOCK) 
			inner JOIN T0040_IP_MASTER IP WITH (NOLOCK) ON I.Cmp_ID=IP.Cmp_ID AND I.IP_Address=IP.IP_ADDRESS 
			left JOIN #CANTEEN T  ON I.Cmp_ID=T.Cmp_Id and ip.ip_id = T.ip_id
	WHERE	I.Enroll_No=@Enroll_No and T.grd_id =@grade  AND T.Effective_Date <= I.IO_DateTime AND I.Cmp_ID=@Cmp_ID
			--AND (Cast(CONVERT(varchar(5), I.IO_DateTime, 108) As DateTime) Between T.From_Time AND T.To_Time)
			AND (I.In_Out_flag=10 OR I.IP_Address='Canteen' OR IP.Device_No >= 200 Or isnull(Ip.Is_Canteen,0) = 1) 
	
	
	SELECT	ROW_NUMBER() OVER(ORDER BY I.TRAN_ID) AS ROWID,(isnull(T.AMOUNT,0) * isnull(I.QUANTITY,0)) AS AMOUNT,I.CANTEEN_PUNCH_DATETIME,I.DEVICE_IP,isnull(I.QUANTITY,0) as QUANTITY
	INTO	#CANTEEN_NFC_PUNCH
	FROM	T0150_EMP_CANTEEN_PUNCH I WITH (NOLOCK)
			inner join T0050_CANTEEN_MASTER CMM WITH (NOLOCK) on i.Canteen_ID = CMM.Cnt_Id
			INNER JOIN T0040_IP_MASTER IP WITH (NOLOCK) ON I.CMP_ID=IP.CMP_ID and cmm.Ip_Id = ip.IP_ID  --AND I.DEVICE_IP=IP.IP_ADDRESS 
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID = I.EMP_ID
			INNER JOIN #CANTEEN T  ON I.CMP_ID=T.CMP_ID AND IP.IP_ID = T.IP_ID and t.Cnt_Id = cmm.Cnt_Id and t.grd_id = @GRADE
	WHERE	T.GRD_ID =@GRADE  AND T.EFFECTIVE_DATE <= I.CANTEEN_PUNCH_DATETIME AND i.Emp_ID = @Emp_ID and
			I.CANTEEN_PUNCH_DATETIME BETWEEN @FROM_DATE AND @TO_DATE AND 
			I.CMP_ID=@CMP_ID AND (I.FLAG in ('Mobile','Manually(Mobile)') OR I.REASON in ('Mobile','Manually(Mobile)') OR IP.DEVICE_NO >= 200) AND IP.IS_CANTEEN =1
	
	--CREATE table #TEMP ADD ID_X BIGINT IDENTITY;
			
	--Updating From_Time and To_Time for night shift
	--UPDATE	#TEMP
	--SET		From_Time = ((Case When (DateDiff(n, Cast(Cast(IO_DateTime As Date) AS DateTime), IO_DateTime) < 720 AND From_Time > To_Time )  
	--				THEN DateAdd(d,-1,From_Time) 
	--			ELSE
	--				From_Time 
	--			END
	--		) + CAST(IO_DateTime As Date)),
	--		To_Time = ((Case When (DateDiff(n, Cast(Cast(IO_DateTime As Date) AS DateTime), IO_DateTime) > 720 AND From_Time > To_Time )  
	--				THEN DateAdd(d,1,To_Time) 
	--			ELSE
	--				To_Time
	--			END
	--		) + CAST(IO_DateTime As Date))	


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
	
	-- GETTING SUM OF NFC PUNCH AMOUNT
	SELECT @Canteen_NFC_Amount = SUM(AMOUNT)
	FROM #CANTEEN_NFC_PUNCH
	
	
	--Getting sum of Amount
	SELECT	@Canteen_Device_Amount = SUM(Amount)
	FROM	#TEMP T1	
	
	SET @CANTEEN_AMOUNT = ISNULL(@CANTEEN_DEVICE_AMOUNT,0) + ISNULL(@CANTEEN_NFC_AMOUNT,0)
	
	--Should not be null 		
	IF (@Canteen_Amount IS NULL)
		SET @Canteen_Amount = 0;
END


