﻿
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_CANTEEN_PUNCH_DETAIL_CERA]
	@Cmp_ID			NUMERIC(18,0)	
	,@From_Date		DATETIME
	,@To_Date		DATETIME	
	,@Branch_ID		VARCHAR(MAX) = ''
	,@Cat_ID		VARCHAR(MAX) = ''
	,@Grd_ID		VARCHAR(MAX) = ''
	,@Type_ID		VARCHAR(MAX) = ''
	,@Dept_ID		VARCHAR(MAX) = ''
	,@Desig_ID		VARCHAR(MAX) = ''
	,@Emp_ID		NUMERIC  = 0
	,@Constraint	VARCHAR(MAX)	= ''
	,@Salary_Cycle_id	NUMERIC		= NULL
	,@Segment_Id	VARCHAR(MAX)		= ''	
	,@Vertical_Id	VARCHAR(MAX)		= ''	 
	,@SubVertical_Id	VARCHAR(MAX)	= ''	
	,@SubBranch_Id	VARCHAR(MAX)		= ''
	,@CanteenDetail VARCHAR(MAX)	= ''
	,@DeviceIPs		VARCHAR(MAX)	= ''
	,@flag int = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    SET @From_Date = CONVERT(DATETIME,CONVERT(CHAR(10), @From_Date, 103), 103);
	SET @To_Date= CONVERT(DATETIME,CONVERT(CHAR(10), @To_Date, 103) + ' 23:59:59', 103);
	
	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	) 
	
	INSERT INTO #Emp_Cons
	SELECT EM.EMP_ID,B.BRANCH_ID,B.INCREMENT_ID
	FROM T0080_EMP_MASTER EM WITH (NOLOCK)
	LEFT OUTER JOIN
				(
					SELECT	EMP_ID,I.CMP_ID,I.INCREMENT_ID,I.Branch_ID
									FROM	T0095_INCREMENT I WITH (NOLOCK)
									WHERE	I.INCREMENT_ID =(
																SELECT	TOP 1 INCREMENT_ID
																FROM	T0095_INCREMENT I1 WITH (NOLOCK)
																WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID
																ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
															)
				) AS B ON B.EMP_ID = EM.EMP_ID AND B.CMP_ID=EM.CMP_ID
	 WHERE  EM.EMP_LEFT='N'
	
	--EXEC dbo.SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,1,0,'0',0,0    
	
	
	if(isnull(@flag,0) = 1)
	
		BEGIN
			
				DECLARE @CMP_NAME AS VARCHAR(128)
				DECLARE @CMP_ADDRESS AS VARCHAR(500)
				SET @CMP_NAME = ''
				SET @CMP_ADDRESS = ''
				
				SELECT @CMP_NAME = CMP_NAME,@CMP_ADDRESS = CMP_ADDRESS
				FROM T0010_COMPANY_MASTER WITH (NOLOCK)
				WHERE CMP_ID = @CMP_ID
				
				SELECT		T.HOUR,@CMP_NAME AS CMP_NAME,@CMP_ADDRESS AS CMP_ADDRESS,@FROM_DATE AS FROM_DATE , @TO_DATE AS TO_DATE,
							T.EMP_FULL_NAME,SYSTEM_DATE AS CANTEEN_PUNCH_DATETIME,T.CNT_NAME,T.TOTAL,T.STATUS FROM 
				(
				SELECT		--CMP.CMP_NAME,CMP.CMP_ADDRESS,
							@FROM_DATE AS FROM_DATE , @TO_DATE AS TO_DATE,
							TEM.EMP_FULL_NAME,CAST(ECP.SYSTEM_DATE AS DATE) AS SYSTEM_DATE
							,CM.CNT_NAME,
							--CAST(DATEPART(HOUR, ECP.SYSTEM_DATE) AS VARCHAR) + ':00' AS 'HOUR',
							(convert(varchar, CAST(ECP.SYSTEM_DATE AS DATE), 112) + '' + CAST(ISNULL(ECP.CANTEEN_TRANSACTIONID,0) AS VARCHAR(50))) as 'HOUR',
							SUM(ECP.QUANTITY) AS TOTAL,'SYNC SUCCESSFULLY' AS [STATUS]
				FROM		T0150_EMP_CANTEEN_PUNCH ECP WITH (NOLOCK) INNER JOIN T0050_CANTEEN_MASTER CM WITH (NOLOCK) ON ECP.CANTEEN_ID = CM.CNT_ID
							INNER JOIN #Emp_Cons EC ON ECP.Emp_ID = EC.Emp_ID 
							LEFT JOIN T0011_LOGIN TL WITH (NOLOCK) ON ECP.USER_ID = TL.LOGIN_ID
							LEFT JOIN T0080_EMP_MASTER TEM WITH (NOLOCK) ON TL.EMP_ID = TEM.EMP_ID
							LEFT JOIN DBO.T0010_COMPANY_MASTER CMP WITH (NOLOCK) ON ECP.CMP_ID = CMP.CMP_ID 
				WHERE		--ECP.CMP_ID = @CMP_ID AND 
							ECP.FLAG ='Mobile' and  ECP.Reason = 'Mobile' AND 
							ECP.Canteen_Punch_Datetime BETWEEN @FROM_DATE AND @TO_DATE
				GROUP BY	ISNULL(ECP.CANTEEN_TRANSACTIONID,0),CAST(ECP.SYSTEM_DATE AS DATE),
							--ECP.DEVICE_IP,
							--DATEPART(HOUR,ECP.SYSTEM_DATE),
							CM.CNT_NAME,TEM.EMP_FULL_NAME--,CMP.CMP_NAME,CMP.CMP_ADDRESS
							--DATEPART(HOUR,CANTEEN_PUNCH_DATETIME),

				UNION ALL  
				
							
				SELECT		--CMP.CMP_NAME,CMP.CMP_ADDRESS,
							@FROM_DATE AS FROM_DATE , @TO_DATE AS TO_DATE,
							TEM.EMP_FULL_NAME,CAST(ECP.SYSTEM_DATE AS DATE) AS SYSTEM_DATE
							,CM.CNT_NAME,
							--CAST(DATEPART(HOUR, ECP.SYSTEM_DATE) AS VARCHAR) + ':00' AS 'HOUR',
							(convert(varchar, CAST(ECP.SYSTEM_DATE AS DATE), 112) + '' + CAST(ISNULL(ECP.CANTEEN_TRANSACTIONID,0) AS VARCHAR(50))) as 'HOUR',
							SUM(ECP.QUANTITY) AS TOTAL,'SYNC FAILED' AS [STATUS]
				FROM		T0150_EMP_CANTEEN_PUNCH_ERROR_LOGS ECP WITH (NOLOCK) INNER JOIN T0050_CANTEEN_MASTER CM WITH (NOLOCK) ON ECP.CANTEEN_ID = CM.CNT_ID
							INNER JOIN #Emp_Cons EC ON ECP.Emp_ID = EC.Emp_ID 
							LEFT JOIN T0011_LOGIN TL WITH (NOLOCK) ON ECP.USER_ID = TL.LOGIN_ID
							LEFT JOIN T0080_EMP_MASTER TEM WITH (NOLOCK) ON TL.EMP_ID = TEM.EMP_ID
							LEFT JOIN DBO.T0010_COMPANY_MASTER CMP WITH (NOLOCK) ON ECP.CMP_ID = CMP.CMP_ID 
				WHERE		--ECP.CMP_ID = @CMP_ID AND 
							ECP.FLAG='Mobile' AND 
							ECP.Canteen_Punch_Datetime BETWEEN @FROM_DATE AND @TO_DATE
				GROUP BY	ISNULL(ECP.CANTEEN_TRANSACTIONID,0),CAST(ECP.SYSTEM_DATE as date),
							--,ECP.DEVICE_IP,
							--DATEPART(hour,ECP.SYSTEM_DATE),
							CM.CNT_NAME,TEM.EMP_FULL_NAME--,CMP.CMP_NAME,CMP.CMP_ADDRESS
							--DATEPART(hour,Canteen_Punch_datetime),
						
				 ) T ORDER BY SYSTEM_DATE,[HOUR],EMP_FULL_NAME ASC
		
		
		--SELECT		CMP.CMP_NAME,CMP.CMP_ADDRESS,@FROM_DATE AS FROM_DATE , @TO_DATE AS TO_DATE,
		--			TEM.EMP_FULL_NAME,CAST(CANTEEN_PUNCH_DATETIME AS DATE) AS CANTEEN_PUNCH_DATETIME
		--			,CM.CNT_NAME,
		--			--CAST(DATEPART(HOUR, ECP.SYSTEM_DATE) AS VARCHAR) + ':00' AS 'HOUR',
		--			SUM(ECP.QUANTITY) AS TOTAL,'SYNC SUCCESSFULLY' AS [STATUS]
		--FROM		T0150_EMP_CANTEEN_PUNCH ECP INNER JOIN T0050_CANTEEN_MASTER CM ON ECP.CANTEEN_ID = CM.CNT_ID
		--			INNER JOIN #Emp_Cons EC ON ECP.Emp_ID = EC.Emp_ID 
		--			LEFT JOIN T0011_LOGIN TL ON ECP.USER_ID = TL.LOGIN_ID
		--			LEFT JOIN T0080_EMP_MASTER TEM ON TL.EMP_ID = TEM.EMP_ID
		--			LEFT JOIN DBO.T0010_COMPANY_MASTER CMP ON ECP.CMP_ID = CMP.CMP_ID 
		--WHERE		ECP.CMP_ID = @CMP_ID AND ECP.FLAG='Mobile' and ECP.Reason='Mobile' AND 
		--			ECP.CANTEEN_PUNCH_DATETIME BETWEEN @FROM_DATE AND @TO_DATE
		--GROUP BY	ISNULL(ECP.CANTEEN_TRANSACTIONID,0),CAST(CANTEEN_PUNCH_DATETIME AS DATE),
		--			--ECP.DEVICE_IP,
		--			--DATEPART(HOUR,ECP.SYSTEM_DATE),
		--			CM.CNT_NAME,TEM.EMP_FULL_NAME,CMP.CMP_NAME,CMP.CMP_ADDRESS
		--			--DATEPART(HOUR,CANTEEN_PUNCH_DATETIME),

		--UNION ALL  
		
					
		--SELECT		CMP.CMP_NAME,CMP.CMP_ADDRESS,@FROM_DATE AS FROM_DATE , @TO_DATE AS TO_DATE,
		--			TEM.EMP_FULL_NAME,CAST(CANTEEN_PUNCH_DATETIME AS DATE) AS CANTEEN_PUNCH_DATETIME
		--			,CM.CNT_NAME,
		--			--CAST(DATEPART(HOUR, ECP.SYSTEM_DATE) AS VARCHAR) + ':00' AS 'HOUR',
		--			SUM(ECP.QUANTITY) AS TOTAL,'SYNC FAILED' AS [STATUS]
		--FROM		T0150_EMP_CANTEEN_PUNCH_ERROR_LOGS ECP INNER JOIN T0050_CANTEEN_MASTER CM ON ECP.CANTEEN_ID = CM.CNT_ID
		--			INNER JOIN #Emp_Cons EC ON ECP.Emp_ID = EC.Emp_ID 
		--			LEFT JOIN T0011_LOGIN TL ON ECP.USER_ID = TL.LOGIN_ID
		--			LEFT JOIN T0080_EMP_MASTER TEM ON TL.EMP_ID = TEM.EMP_ID
		--			LEFT JOIN DBO.T0010_COMPANY_MASTER CMP ON ECP.CMP_ID = CMP.CMP_ID 
		--WHERE		ECP.CMP_ID = @CMP_ID AND ECP.FLAG='Mobile' AND 
		--			ECP.CANTEEN_PUNCH_DATETIME BETWEEN @FROM_DATE AND @TO_DATE
		--GROUP BY	ISNULL(ECP.CANTEEN_TRANSACTIONID,0),CAST(Canteen_Punch_datetime as date),
		--			--,ECP.DEVICE_IP,
		--			--DATEPART(hour,ECP.SYSTEM_DATE),
		--			CM.CNT_NAME,TEM.EMP_FULL_NAME,CMP.CMP_NAME,CMP.CMP_ADDRESS
		--			--DATEPART(hour,Canteen_Punch_datetime),
				
			
				
		end
	else
		begin
		
			SELECT  CP.Canteen_Punch_Datetime, CASE WHEN CP.Flag = 'A' THEN 'Newly added' WHEN CP.Flag='Mobile' then 'Mobile' ELSE 'Deleted' END AS Flag,CP.Device_IP, EM.Alpha_Emp_Code + ' - ' + EM.EMP_FULL_NAME as Reason,CP.[User_ID],CP.System_Date,
						CONVERT(DATETIME,CONVERT(VARCHAR(10),CP.Canteen_Punch_Datetime,111)) AS For_Date,dbo.F_GET_AMPM(CP.Canteen_Punch_Datetime) AS Punch_Time,L.Login_Name,
						EM.Emp_Id,EM.Emp_Code,TEM.Alpha_Emp_Code,TEM.Emp_Full_Name,EM.Emp_First_Name,EM.Gender,EM.Date_Of_Join,
						DM.Dept_ID,DM.Dept_Name,DGM.Desig_ID,DGM.Desig_Name,GM.Grd_ID,GM.Grd_Name,
						ETM.[Type_ID],ETM.[Type_Name],BM.Branch_Name,BM.Branch_Address,BM.Comp_Name,BM.Branch_ID,
						CM.Cmp_Id,CM.Cmp_Address,CM.Cmp_Name,
						I.Vertical_ID,VS.Vertical_Name,I.SubVertical_ID,SV.SubVertical_Name,SB.SubBranch_Name,BS.Segment_Name,
						@From_Date AS From_Date , @To_Date AS To_Date
				FROM	dbo.T0150_EMP_CANTEEN_PUNCH CP WITH (NOLOCK) INNER JOIN
						#Emp_Cons EC ON CP.Emp_ID = EC.Emp_ID INNER JOIN
						dbo.T0080_EMP_MASTER EM WITH (NOLOCK) ON CP.Emp_ID = EM.Emp_ID INNER JOIN
						dbo.T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID = I.Increment_ID INNER JOIN
						dbo.T0011_LOGIN L WITH (NOLOCK) ON CP.User_ID = L.Login_ID INNER JOIN
						dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.Dept_Id = DM.Dept_Id INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.BRANCH_ID = BM.BRANCH_ID  INNER JOIN 
						dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CP.CMP_ID = CM.CMP_ID LEFT OUTER JOIN
						dbo.T0050_SubBranch SB WITH (NOLOCK) ON I.subBranch_ID = SB.SubBranch_ID LEFT OUTER JOIN
						dbo.T0040_Business_Segment BS WITH (NOLOCK) ON I.Segment_ID = BS.Segment_ID LEFT OUTER JOIN
						dbo.T0040_Vertical_Segment VS WITH (NOLOCK) ON I.Vertical_ID = VS.Vertical_ID LEFT OUTER JOIN
						dbo.T0050_SubVertical SV WITH (NOLOCK) ON I.SubVertical_ID = SV.SubVertical_ID
						LEFT JOIN T0080_EMP_MASTER TEM WITH (NOLOCK) ON L.EMP_ID = TEM.EMP_ID
				WHERE BM.Cmp_ID = @Cmp_ID
					AND CP.Canteen_Punch_Datetime BETWEEN @From_Date AND @To_Date
				ORDER BY (
							CASE WHEN ISNUMERIC(EM.Alpha_Emp_Code) = 1 
									THEN RIGHT(REPLICATE('0',21) + EM.Alpha_Emp_Code, 20)
								WHEN ISNUMERIC(EM.Alpha_Emp_Code) = 0 
									THEN LEFT(EM.Alpha_Emp_Code + REPLICATE('',21), 20)
								ELSE 
									EM.Alpha_Emp_Code
							END
						), CP.Canteen_Punch_Datetime
						
						
				
		end
	
	

END


