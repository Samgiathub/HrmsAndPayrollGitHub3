---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_CANTEEN_DEDUCTION] 
	@Cmp_ID Numeric(18,0)	
	,@From_Date DateTime
	,@To_Date DateTime	
	,@Branch_ID		varchar(Max) = ''
	,@Cat_ID		varchar(Max) = ''
	,@Grd_ID		varchar(Max) = ''
	,@Type_ID		varchar(Max) = ''
	,@Dept_ID		varchar(Max) = ''
	,@Desig_ID		varchar(Max) = ''
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  varchar(Max) = ''	
	,@Vertical_Id varchar(Max) = ''	 
	,@SubVertical_Id varchar(Max) = ''	
	,@SubBranch_Id varchar(Max) = ''
	,@CanteenDetail varchar(Max) = ''
	,@DeviceIPs varchar(Max) = ''
	,@Is_EmailReport Int =0        ---------- Add by Jignesh Patel 12-Oct-2021--------
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	SET @From_Date = CONVERT(DateTime,CONVERT(Char(10), @From_Date, 103), 103);
	SET @To_Date= CONVERT(DateTime,CONVERT(Char(10), @To_Date, 103) + ' 23:59:59', 103);

	
	CREATE table #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	) 

	IF @Constraint = '' AND @EMP_ID > 0
		SET @Constraint = CAST(@EMP_ID AS VARCHAR(10))
	
	EXEC dbo.SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,'1900-01-01',@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'0',0,0    
	
	
	DELETE E FROM #Emp_Cons E INNER JOIN  T0080_EMP_MASTER EM ON E.Emp_ID=EM.Emp_ID
	WHERE ISNULL(EM.Enroll_No,0) = 0

		
	Alter Table  #Emp_Cons ADD Enroll_NO Numeric(18,0);
	
	--Update #Emp_Cons SET Enroll_No=T.Enroll_No
	--FROM T0080_EMP_MASTER T WHERE #Emp_Cons.Emp_ID=T.Emp_ID AND T.Cmp_ID=@Cmp_ID
	
	Alter Table  #Emp_Cons ADD grade Numeric(18,0);
	
	Update #Emp_Cons SET Enroll_NO= case when isnull(E.Old_Ref_No,'') = '' then isnull(E.Enroll_No,0) else  ISNULL(E.Old_Ref_No,0) end,grade=I.grd_id
		From T0080_EMP_MASTER E inner join  T0095_Increment I  on E.Emp_ID = I.Emp_ID
		inner join     
		(select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)    
		where Increment_Effective_date <= @to_date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
		I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
		 WHERE #Emp_Cons.Emp_ID=E.Emp_ID AND E.Cmp_ID=@Cmp_ID
	
	
	
	--Retrieving Canteen Details in Temp table.
	SELECT	distinct M.Cmp_Id,M.Cnt_ID,CAST(From_Time As DateTime) As From_Time, Cast(To_Time As DateTime) As To_Time,
			D.Effective_Date,Amount,D.grd_id,Ip_id 
			,D.Subsidy_Amount,D.Total_Amount --added by  chetan 06122017
	INTO	#CANTEEN
	FROM	dbo.T0050_CANTEEN_MASTER M WITH (NOLOCK) 
	INNER JOIN T0050_CANTEEN_DETAIL D WITH (NOLOCK) ON  M.Cnt_Id=D.Cnt_Id	and M.Cmp_Id=D.Cmp_Id
	inner Join (SELECT Max(Effective_Date) AS Effective_Date,grd_id, Cnt_Id 
				FROM   T0050_CANTEEN_DETAIL 
				WHERE  Effective_Date <=@To_Date AND cmp_id = @Cmp_ID 
				GROUP  BY Cnt_Id,grd_id 
				) DM on  DM.Effective_Date = D.Effective_Date and DM.Cnt_Id=D.Cnt_Id	--Added by ronakk 31012023
	WHERE	D.Effective_Date <= @To_Date AND M.Cmp_ID=@Cmp_ID
	
	
	--Filtering Canteen Details
	IF (@CanteenDetail <> '' AND @CanteenDetail <> '0')
	BEGIN
		--DELETE FROM #CANTEEN WHERE Cnt_Id NOT IN (SELECT CAST(data as Numeric(18,0)) FROM dbo.Split(@CanteenDetail, '#'))
		--DELETE FROM #CANTEEN WHERE Cnt_Id <> CAST(@CanteenDetail as Numeric(18,2))
		DELETE FROM #CANTEEN WHERE Cnt_Id NOT IN (select Data from dbo.Split(@CanteenDetail, ','))   --added by chetan for multiple canteen detail
	END	
	

	--Filtering data according to T9999_DEVICE_INOUT_DETAIL entries
	--SELECT	Cast(0 As Bigint) As RowID,E.Emp_ID,T.*,I.IO_DateTime,I.IP_Address,IP.Device_No, IP.Device_Name
	--INTO	#TEMP 
	--FROM	((#CANTEEN T INNER JOIN T9999_DEVICE_INOUT_DETAIL I ON I.Cmp_ID=T.Cmp_Id)
	--		INNER JOIN #Emp_Cons E ON I.Enroll_No=E.Enroll_No)
	--		INNER JOIN T0040_IP_MASTER IP ON I.Cmp_ID=IP.Cmp_ID AND I.IP_Address=IP.IP_ADDRESS
	--WHERE	T.Effective_Date <= I.IO_DateTime AND I.Cmp_ID=@Cmp_ID 
	--		AND (I.In_Out_flag=10 OR I.IP_Address='Canteen' OR IP.Device_No >= 200) 
	--		AND (I.IO_DateTime BETWEEN @From_Date AND @To_Date)


	-- Commented by Hardik on 13/07/2020 for Cera as Punch not getting deleted.. so remove Row_Number to IO_Tran_ID
	--SELECT	ROW_NUMBER() OVER(ORDER BY I.IO_Tran_ID) As RowID,E.Emp_ID,T.*,I.IO_DateTime,I.IP_Address,IP.Device_No, IP.Device_Name,I.IO_Tran_ID
	SELECT	I.IO_Tran_ID As RowID,E.Emp_ID,T.*,I.IO_DateTime,I.IP_Address,IP.Device_No, IP.Device_Name,I.IO_Tran_ID
	INTO	#TEMP 
	FROM	dbo.T9999_DEVICE_INOUT_DETAIL I  WITH (NOLOCK)
			inner JOIN T0040_IP_MASTER IP WITH (NOLOCK) ON I.IP_Address=IP.IP_ADDRESS AND IP.Cmp_ID=@CMP_ID
			INNER JOIN #Emp_Cons E ON I.Enroll_No=E.Enroll_No 
			INNER JOIN #CANTEEN T ON E.grade = T.grd_id  and ip.Ip_Id = T.Ip_Id
	WHERE	--T.Effective_Date <= I.IO_DateTime AND 
			--I.Cmp_ID=@Cmp_ID AND
			(I.In_Out_flag=10 OR I.IP_Address='Canteen' OR IP.Device_No >= 200) 
			AND (I.IO_DateTime BETWEEN @From_Date AND @To_Date) AND T.CMP_ID = @CMP_ID
			
			
	
	-- MOBILE PUNCH 
	-- Commented by Hardik on 13/07/2020 for Cera as Punch not getting deleted.. so remove Row_Number to Tran_ID
	--SELECT	ROW_NUMBER() OVER(ORDER BY I.Tran_ID) As RowID,E.Emp_ID,T.*,
	SELECT	I.Tran_ID As RowID,E.Emp_ID,T.*,
	I.CANTEEN_PUNCH_DATETIME AS IO_DateTime,I.USER_ID,
	I.QUANTITY,Reason
	INTO	#MOBILE_NFC_CANTEEN_INOUT
	FROM	dbo.T0150_EMP_CANTEEN_PUNCH I WITH (NOLOCK) 
			INNER JOIN #Emp_Cons E ON I.EMP_ID=E.EMP_ID 
			INNER JOIN DBO.T0050_CANTEEN_MASTER CM WITH (NOLOCK) ON CM.CNT_ID = I.CANTEEN_ID
			INNER JOIN T0040_IP_MASTER IP WITH (NOLOCK) ON CM.IP_ID = IP.IP_ID
			INNER JOIN #CANTEEN T ON E.GRADE=T.GRD_ID AND I.CANTEEN_ID = T.CNT_ID  AND IP.IP_ID = T.ip_id
	WHERE	(I.FLAG in ('Mobile','Manually(Mobile)') OR I.REASON in ('Mobile','Manually(Mobile)') AND IP.Device_No >= 200) AND 
			--(I.CANTEEN_PUNCH_DATETIME BETWEEN @From_Date AND @To_Date)
			I.CMP_ID = @CMP_ID AND
			I.CANTEEN_PUNCH_DATETIME>=@From_Date AND I.CANTEEN_PUNCH_DATETIME<= @To_Date
			
			
	
	--Filtering Records as per Selected Device IP
	IF (@DeviceIPs <> '' AND @DeviceIPs <> '0')
	BEGIN
		--DELETE FROM #TEMP WHERE IP_Address NOT IN (SELECT data FROM dbo.Split(@DeviceIPs, '#'))
		DELETE FROM #TEMP WHERE IP_Address <> @DeviceIPs
	END	
	
	
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
			) + CONVERT(DATETIME,CONVERT(CHAR(10),IO_DateTime, 103), 103)),
			To_Time = ((Case When (DateDiff(n, Cast(Cast(IO_DateTime As Date) AS DateTime), IO_DateTime) > 720 AND From_Time > To_Time )  
					THEN DateAdd(d,1,To_Time) 
				ELSE
					To_Time
				END
			) + CONVERT(DATETIME,CONVERT(CHAR(10),IO_DateTime, 103), 103))

	SELECT	E.Emp_Id,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_Full_Name,E.Emp_First_Name,E.Gender,E.Date_Of_Join,E.Cat_ID,
			DM.Dept_ID,DM.Dept_Name,DGM.Desig_ID,DGM.Desig_Name,GM.Grd_ID,GM.Grd_Name,
			ETM.[Type_ID],ETM.[Type_Name],BM.Branch_Name,BM.Branch_Address,BM.Comp_Name,BM.Branch_ID,
			CM.Cmp_Id,CM.Cmp_Address,CM.Cmp_Name,CT.IO_DateTime,(CT.Amount * CT.QUANTITY) as Amount,CT.From_Time,CT.To_Time,C.Cnt_Name,
			I_Q.Vertical_ID,I_Q.Vertical_Name,I_Q.SubVertical_ID,I_Q.SubVertical_Name,'MOBILE' AS IP_Address,201 AS Device_No,ISNULL(TEM.Emp_Full_Name,'') AS Device_Name
			,CONVERT(DATETIME,CONVERT(VARCHAR(10), CT.IO_DateTime, 111)) AS For_Date,CT.ROWID AS IO_Tran_ID,dbo.F_GET_AMPM(CT.IO_DateTime) AS In_Time	--Ankit 04032016
			,Ct.Reason As Reason	
			,CT.Subsidy_Amount,CT.Total_Amount,C.Cnt_Id,CT.QUANTITY--added by chetan 06122017
	INTO	#RPT_MOBILE_NFC_CANTEEN
	FROM	dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
			(
				SELECT	I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Bank_ID,Inc_Bank_AC_No,
						I.Vertical_ID,I.SubVertical_ID,V.Vertical_Name,SV.SubVertical_Name
				FROM	dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN 
						(
							SELECT	MAX(Increment_ID) AS Increment_ID , Emp_ID FROM dbo.T0095_Increment WITH (NOLOCK)
							WHERE	Increment_Effective_date <= @To_Date
									AND Cmp_ID = @Cmp_ID 
							GROUP BY emp_ID
						) Qry ON
						I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID
						LEFT OUTER JOIN dbo.T0040_Vertical_Segment V WITH (NOLOCK) ON I.Cmp_ID=V.Cmp_ID And I.Vertical_ID=V.Vertical_ID			
						LEFT OUTER JOIN dbo.T0050_SubVertical SV WITH (NOLOCK) ON I.Cmp_ID=SV.Cmp_ID AND I.SubVertical_ID=SV.SubVertical_ID
			) I_Q ON E.Emp_ID = I_Q.Emp_ID  INNER JOIN 
				dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
				dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
				dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
				dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
				dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
				dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID Inner Join
				#Emp_Cons EC on E.Emp_ID = EC.Emp_ID INNER JOIN 
				#MOBILE_NFC_CANTEEN_INOUT CT ON CT.EMP_ID=E.EMP_ID
				LEFT JOIN dbo.T0050_CANTEEN_MASTER C WITH (NOLOCK) ON CT.Cnt_Id=C.Cnt_Id -- AND CT.Cmp_Id=C.Cmp_Id  --Removed by Nimesh on 11-Jan-2016 (Company Join is not required when In-Out is downloading from one company for another company)
				LEFT JOIN T0011_LOGIN TL WITH (NOLOCK) ON CT.USER_ID = TL.LOGIN_ID
				LEFT JOIN T0080_EMP_MASTER TEM WITH (NOLOCK) ON TL.EMP_ID = TEM.EMP_ID
				
	WHERE	E.Cmp_ID = @Cmp_Id 
	ORDER BY (
				Case	When IsNumeric(e.Alpha_Emp_Code) = 1 
							THEN Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
						WHEN IsNumeric(e.Alpha_Emp_Code) = 0 
							THEN Left(e.Alpha_Emp_Code + Replicate('',21), 20)
						ELSE 
							e.Alpha_Emp_Code
				END
			), CT.IO_DateTime
	
	--Removing GAP between two In-Out Detail which is less than 5 minutes
	exec dbo.P0050_CANTEEN_REMOVE_IO_GAP @Cmp_ID, @From_Date, @To_Date
	
	

	SELECT	E.Emp_Id,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_Full_Name,E.Emp_First_Name,E.Gender,E.Date_Of_Join,E.Cat_ID,
			DM.Dept_ID,DM.Dept_Name,DGM.Desig_ID,DGM.Desig_Name,GM.Grd_ID,GM.Grd_Name,
			ETM.[Type_ID],ETM.[Type_Name],BM.Branch_Name,BM.Branch_Address,BM.Comp_Name,BM.Branch_ID,
			CM.Cmp_Id,CM.Cmp_Address,CM.Cmp_Name,CT.IO_DateTime,CT.Amount,CT.From_Time,CT.To_Time,C.Cnt_Name,
			I_Q.Vertical_ID,I_Q.Vertical_Name,I_Q.SubVertical_ID,I_Q.SubVertical_Name,CT.IP_Address,CT.Device_No,CT.Device_Name
			,CONVERT(DATETIME,CONVERT(VARCHAR(10), CT.IO_DateTime, 111)) AS For_Date,CT.IO_Tran_ID,dbo.F_GET_AMPM(CT.IO_DateTime) AS In_Time	--Ankit 04032016
			,'' As Reason	
			,CT.Subsidy_Amount,CT.Total_Amount,C.Cnt_Id,0 as QUANTITY--added by chetan 06122017
	INTO #RPT
	FROM	dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
			(
				SELECT	I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Bank_ID,Inc_Bank_AC_No,
						I.Vertical_ID,I.SubVertical_ID,V.Vertical_Name,SV.SubVertical_Name
				FROM	dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN 
						(
							SELECT	MAX(Increment_ID) AS Increment_ID , Emp_ID FROM dbo.T0095_Increment WITH (NOLOCK)
							WHERE	Increment_Effective_date <= @To_Date
									AND Cmp_ID = @Cmp_ID 
							GROUP BY emp_ID
						) Qry ON
						I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID
						LEFT OUTER JOIN dbo.T0040_Vertical_Segment V WITH (NOLOCK) ON I.Cmp_ID=V.Cmp_ID And I.Vertical_ID=V.Vertical_ID			
						LEFT OUTER JOIN dbo.T0050_SubVertical SV WITH (NOLOCK) ON I.Cmp_ID=SV.Cmp_ID AND I.SubVertical_ID=SV.SubVertical_ID
			) I_Q ON E.Emp_ID = I_Q.Emp_ID  INNER JOIN 
				dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
				dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
				dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
				dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
				dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
				dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID Inner Join
				#Emp_Cons EC on E.Emp_ID = EC.Emp_ID INNER JOIN 
				#TEMP CT ON CT.Emp_ID=E.Emp_ID left JOIN
				dbo.T0050_CANTEEN_MASTER C WITH (NOLOCK) ON CT.Cnt_Id=C.Cnt_Id -- AND CT.Cmp_Id=C.Cmp_Id  --Removed by Nimesh on 11-Jan-2016 (Company Join is not required when In-Out is downloading from one company for another company)
	WHERE	E.Cmp_ID = @Cmp_Id 
	ORDER BY (
				Case	When IsNumeric(e.Alpha_Emp_Code) = 1 
							THEN Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
						WHEN IsNumeric(e.Alpha_Emp_Code) = 0 
							THEN Left(e.Alpha_Emp_Code + Replicate('',21), 20)
						ELSE 
							e.Alpha_Emp_Code
				END
			), CT.IO_DateTime
	

	------------- Add By Jignesh Patel 12-Oct-2021-----------(Canteen Report HTML Email Trigger Daily Bases)
	If @Is_EmailReport =1
	Begin
				select 
			Device_No,Device_Name,IP_Address, Cnt_Name, Count(Emp_ID) As TotalCount, Sum(Amount) As Amount
			,sum(Subsidy_Amount) As Subsidy_Amount,sum(Total_Amount) As Total_Amount--added by chetan 08122017 add subsidy and total amount summary
			Into #tblEmailData
			FROM	#RPT	
			GROUP BY IP_Address, Cnt_Name,Device_No,Device_Name
			UNION ALL
			SELECT Device_No,Device_Name,IP_Address, Cnt_Name, sum(QUANTITY) As TotalCount, Sum(Amount) As Amount
			,sum(Subsidy_Amount) As Subsidy_Amount,sum(Total_Amount) As Total_Amount--added by chetan 08122017 add subsidy and total amount summary
			FROM	#RPT_MOBILE_NFC_CANTEEN	
			GROUP BY IP_Address, Cnt_Name,Device_No,Device_Name

			
			Declare @tableHTML varchar(max)

			SET @tableHTML  = 
			N'<H2>Canteen Deduction Report</H2>' +
			N'<table border="1">' +
			N'<tr><th>Device No</th>' +
			N'<th>Device Name</th>' +
			N'<th>IP Address</th>' +
			N'<th>Canteen Name</th>' +
			N'<th>TotalCount</th>' +
			N'<th>Amount</th>' +
			N'<th>Subsidy Amount</th>' +
			N'<th>Total Amount</th>'  +
			'</tr>' +
			cast((
			select 
			td= Device_No  , '',
			 td= Device_Name  ,'' ,
			 td=IP_Address  ,'',
			 td= Cnt_Name   ,'',
			 td= TotalCount  ,'',
			 td=Amount  ,'',
			 td=Subsidy_Amount   ,'',
			 td=Total_Amount  ,''
			 from #tblEmailData
			FOR XML path('tr'),  TYPE
			) AS NVARCHAR(MAX) ) 
			+ N'</table>' ;
			
			select @tableHTML
		  
	Return
	End
	------------------------------- End -----------------------------------




	Select  Emp_ID, Alpha_Emp_Code,Emp_Full_Name,cast(IO_DateTime as Date) as For_Date,In_Time,IP_Address,Cnt_Name,Reason ,IO_Tran_Id,Branch_ID,Vertical_ID,Dept_ID into #RPTTmp
	from (
	SELECT * FROM #RPT
	UNION ALL
	SELECT * FROM #RPT_MOBILE_NFC_CANTEEN) Qry Order by IO_DateTime asc

	Select Distinct  Emp_ID, Alpha_Emp_Code,Emp_Full_Name,For_Date,In_Time,IP_Address,Cnt_Name,Reason ,IO_Tran_Id,Branch_ID,Vertical_ID,Dept_ID  from #RPTTmp order BY   For_Date ,IO_Tran_ID  --here branch_id and vertical_id added by aswini 09/1/2024
	
	SELECT	Device_No,Device_Name,IP_Address, Cnt_Name, Count(Emp_ID) As TotalCount, Sum(Amount) As Amount
	,sum(Subsidy_Amount) As Subsidy_Amount,sum(Total_Amount) As Total_Amount--added by chetan 08122017 add subsidy and total amount summary
	FROM	#RPT	
	GROUP BY IP_Address, Cnt_Name,Device_No,Device_Name
	UNION ALL
	SELECT Device_No,Device_Name,IP_Address, Cnt_Name, sum(QUANTITY) As TotalCount, Sum(Amount) As Amount
	,sum(Subsidy_Amount) As Subsidy_Amount,sum(Total_Amount) As Total_Amount--added by chetan 08122017 add subsidy and total amount summary
	FROM	#RPT_MOBILE_NFC_CANTEEN	
	GROUP BY IP_Address, Cnt_Name,Device_No,Device_Name

	
	--Fill Employee DDL In Employee Canteen Punch Page	--Ankit 05032016
	SELECT E.Emp_ID,Alpha_Emp_Code, Alpha_Emp_Code + ' - ' + Emp_Full_Name As Emp_Full_Name,Em.Branch_ID,Em.Vertical_ID,Em.Dept_ID  ---here branch_id,vertical_id added by aswini 09/01/2024
	FROM #Emp_Cons E INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON E.Emp_ID=EM.Emp_ID;

END
