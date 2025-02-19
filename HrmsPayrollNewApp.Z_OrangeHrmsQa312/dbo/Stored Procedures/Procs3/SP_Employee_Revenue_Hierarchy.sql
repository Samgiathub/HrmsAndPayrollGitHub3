

---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Revenue_Hierarchy]
	-- Add the parameters for the stored procedure here
	@Cmp_ID Numeric,
	@Emp_ID Numeric,
	@From_Date Datetime,
	@To_Date Datetime,
	@Bussiness_Level Numeric = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Delete From #Emp_Caption
	
	;WITH Q(CMP_ID,EMP_ID, R_EMP_ID, R_LEVEL,Alpha_Emp_Code,Emp_Full_NAME) AS
	(
		SELECT	EM.CMP_ID,EM.Emp_ID,CAST(0 AS NUMERIC) as R_Emp_ID, CAST(1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
			FROM
				T0080_EMP_MASTER EM WITH (NOLOCK) --ON EM.Emp_ID = RD.Emp_ID
			WHERE	EM.Emp_ID = @Emp_ID AND(EM.Emp_Left_Date IS NULL or EM.Emp_Left <> 'Y')
		UNION ALL
		SELECT	RD.CMP_ID,RD.Emp_ID,RD.R_Emp_ID, CAST(Q.R_LEVEL + 1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
			FROM	T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK)
				INNER JOIN V0090_EMP_REP_DETAIL_MAX EMP_SUP ON RD.EMP_ID = EMP_SUP.EMP_ID AND RD.EFFECT_DATE = EMP_SUP.EFFECT_DATE AND RD.Row_ID = EMP_SUP.Row_ID
				INNER JOIN Q ON RD.R_Emp_ID=Q.Emp_ID	
				INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = RD.Emp_ID
			--WHERE (EM.Emp_Left_Date IS NULL or EM.Emp_Left <> 'Y')
	)
	
	
	/*Getting all employees*/
	INSERT INTO #Emp_Caption
	SELECT	DISTINCT Q.*,0 as Segment_ID, BM.Branch_Name
	From	Q LEFT JOIN [OT_SalesMIS_26022018].dbo.SalesMIS_Revenue SR ON Q.Alpha_Emp_Code = SR.EmployeeeCode
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON Q.EMP_ID=E.EMP_ID
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON E.Branch_ID=BM.Branch_ID
			
			
	--Select * From #Emp_Caption order by R_LEVEL
			
	DECLARE @MAX_ROW_ID INT
	
	
	/*Inserting First Parent Employee*/
	SELECT DISTINCT	0 AS P_ID, @EMP_ID AS EMP_ID, CAST('' AS varchar(128)) AS CAPTION, 
			1 AS C_ID,
			--CAST(SUM(SR.TOTAL_BROKERAGE) AS numeric(18,2)) as Brokerage,
			CAST('' AS varchar(128)) AS SUB_BRANCH_CODE
	Into	#Emp_Sub_Branch
	From	#Emp_Caption EC LEFT JOIN [OT_SalesMIS_26022018].dbo.SalesMIS_Revenue SR ON  EC.Alpha_Emp_Code = SR.EmployeeeCode
	Where	TrxDt >= @From_Date and TrxDt <= @To_Date
	
	
	SELECT @MAX_ROW_ID = MAX(C_ID) FROM #Emp_Sub_Branch
	IF @MAX_ROW_ID IS NULL
		SET @MAX_ROW_ID = 0
		

	/*Inserting All Branches where Employee worked*/
	Insert INTO #Emp_Sub_Branch
	SELECT	1 AS P_ID, 0 AS EMP_ID, SR.SUB_BRANCH_NAME AS CAPTION, 
			ROW_NUMBER() OVER(ORDER BY SUB_BRANCH_CODE) + @MAX_ROW_ID AS C_ID,
			--SUM(SR.TOTAL_BROKERAGE) as Brokerage,
			SR.SUB_BRANCH_CODE	
	From	#Emp_Caption EC LEFT JOIN [OT_SalesMIS_26022018].dbo.SalesMIS_Revenue SR
	ON  EC.Alpha_Emp_Code = SR.EmployeeeCode 
	Where TrxDt >= @From_Date and TrxDt <= @To_Date --AND NOT EXISTS(SELECT 1 FROM #Emp_Downline ESB WHERE ESB.SUB_BRANCH_CODE = SR.SUB_BRANCH_CODE)
	group by SUB_BRANCH_CODE,SR.Sub_Branch_Name
	
	
	SELECT @MAX_ROW_ID = MAX(C_ID) FROM #Emp_Sub_Branch
	IF @MAX_ROW_ID IS NULL
		SET @MAX_ROW_ID = 0
		
	/*Inserting All Branches where Employee not worked*/
	Insert INTO #Emp_Sub_Branch
	SELECT	1 AS P_ID, 0 AS EMP_ID, EC.EM_Branch AS CAPTION, 
			ROW_NUMBER() OVER(ORDER BY EC.EM_Branch) + @MAX_ROW_ID AS C_ID,
			--0 as Brokerage,
			EC.EM_Branch AS SUB_BRANCH_CODE	
	From	#Emp_Caption EC 	
	WHERE	NOT EXISTS(SELECT 1 FROM #Emp_Sub_Branch ESB WHERE ESB.CAPTION = EC.EM_Branch)
			--AND NOT EXISTS(SELECT 1 FROM #Emp_Downline ED WHERE ED.CAPTION = EC.EM_Branch)
	group by EC.EM_Branch
	

	SELECT @MAX_ROW_ID = MAX(C_ID) FROM #Emp_Sub_Branch
	IF @MAX_ROW_ID IS NULL
		SET @MAX_ROW_ID = 0
	
	/*Inserting All Employee worked*/
	Insert INTO #Emp_Sub_Branch
	SELECT	ESB.C_ID AS P_ID ,
			EC.EMP_ID,
			EC.Emp_Full_NAME as EmployeeeCode,			
			--SUB_BRANCH_CODE +'' + Cast(EC.EMp_ID AS varchar(10)) as C_ID,
			ROW_NUMBER() OVER(ORDER BY SR.SUB_BRANCH_CODE,EC.ROW_ID) + @MAX_ROW_ID AS C_ID,
			--EC.ROW_ID AS C_ID,
			--SUM(SR.TOTAL_BROKERAGE) as Brokerage,
			SR.SUB_BRANCH_CODE
	From	#Emp_Caption EC 
			LEFT JOIN [OT_SalesMIS_26022018].dbo.SalesMIS_Revenue SR ON EC.Alpha_Emp_Code = SR.EmployeeeCode
			INNER JOIN #Emp_Sub_Branch ESB ON SR.SUB_BRANCH_CODE=ESB.SUB_BRANCH_CODE		
	Where	TrxDt >= @From_Date and TrxDt <= @To_Date
	group by SR.SUB_BRANCH_CODE,EC.EMp_ID,EC.Emp_Full_NAME, ROW_ID,ESB.C_ID
	
	SELECT @MAX_ROW_ID = MAX(C_ID) FROM #Emp_Sub_Branch
	IF @MAX_ROW_ID IS NULL
		SET @MAX_ROW_ID = 0
		
	/*Inserting All Employee not worked*/
	Insert INTO #Emp_Sub_Branch
	SELECT	ESB.C_ID AS P_ID ,
			EC.EMP_ID,
			EC.Emp_Full_NAME as EmployeeeCode,			
			ROW_NUMBER() OVER(ORDER BY EC.EM_Branch,EC.ROW_ID) + @MAX_ROW_ID AS C_ID,
			--0 as Brokerage,
			EC.EM_Branch
	From	#Emp_Caption EC 	
			INNER JOIN #Emp_Sub_Branch ESB ON EC.EM_Branch=ESB.CAPTION
	WHERE	NOT EXISTS(SELECT 1 FROM #Emp_Sub_Branch ESB WHERE ESB.EMP_ID = EC.EMP_ID)
	
	Update ESB
		SET ESB.CAPTION = EM.Emp_Full_Name
	From #Emp_Sub_Branch ESB 
	INNER JOIN T0080_EMP_MASTER EM ON ESB.Emp_ID = EM.Emp_ID
	Where P_ID = 0	
	
	
	;WITH R(P_ID,C_ID,NAME,ORDER_CODE,C_LEVEL,EMP_ID,SUB_BRANCH_CODE) AS
	(
		SELECT T1.P_ID,T1.C_ID,T1.CAPTION,CAST(RIGHT(REPLICATE(N'0', 5) + CAST(C_ID AS varchar(5)), 5) AS varchar(50)) AS ORDER_CODE,CAST(1 AS INT) AS C_LEVEL ,T1.EMP_ID,T1.SUB_BRANCH_CODE
			FROM	#Emp_Sub_Branch T1
		WHERE	P_ID = 0
		UNION ALL
		SELECT T2.P_ID,T2.C_ID,T2.CAPTION,CAST(R.ORDER_CODE  + RIGHT(REPLICATE(N'0', 5) +  CAST(T2.C_ID AS varchar(5)), 5) AS VARCHAR(50)) AS ORDER_CODE,CAST(R.C_LEVEL + 1 AS INT) AS C_LEVEL,T2.EMP_ID,T2.SUB_BRANCH_CODE
		FROM	#Emp_Sub_Branch T2 INNER JOIN R ON T2.P_ID=R.C_ID
	)
	
	INSERT INTO #Emp_Downline(Alpha_Emp_Code,Caption,Emp_ID,R_Level,P_ID,SUB_BRANCH_CODE,Emp_Group_ID)
	Select  EM.Alpha_Emp_Code,
				REPLICATE(N' ', C_LEVEL * 5) + (Case When Isnull(EM.Alpha_Emp_Code,'') <> '' 
						THEN  EM.Alpha_Emp_Code + ' - ' +  NAME 
					ELSE 
						   NAME 
				END)  as CAPTION,R.EMP_ID,
		   C_LEVEL,P_ID,SUB_BRANCH_CODE,@Emp_ID From R 
	LEFT JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON R.EMP_ID = EM.Emp_ID
	ORDER BY ORDER_CODE
	
	--Select * From #Emp_Downline
	
	
END

