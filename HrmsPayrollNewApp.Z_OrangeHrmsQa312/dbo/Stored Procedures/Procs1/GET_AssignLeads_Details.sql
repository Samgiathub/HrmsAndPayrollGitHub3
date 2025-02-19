

 ---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[GET_AssignLeads_Details]

@Emp_ID int
,@strWhere nvarchar(MAX)=''
,@strOrderBy nvarchar(100)=''

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN

	DECLARE @sqlQuery nvarchar(MAX)

	If Object_ID('tempdb..#EmpCons') is not null Drop table #EmpCons

	Create Table #EmpCons( Emp_ID Numeric )

	;WITH Q(CMP_ID,EMP_ID, R_EMP_ID, R_LEVEL,Alpha_Emp_Code,Emp_Full_NAME) AS
		(
			SELECT	EM.CMP_ID,EM.Emp_ID,CAST(0 AS NUMERIC) as R_Emp_ID, CAST(1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
			FROM T0080_EMP_MASTER EM WITH (NOLOCK)
			WHERE	EM.Emp_ID = @Emp_ID AND(EM.Emp_Left_Date IS NULL or EM.Emp_Left <> 'Y')
			
			UNION ALL
			
			SELECT	RD.CMP_ID,RD.Emp_ID,RD.R_Emp_ID, CAST(Q.R_LEVEL + 1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
			FROM T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK)
			INNER JOIN V0090_EMP_REP_DETAIL_MAX EMP_SUP ON RD.EMP_ID = EMP_SUP.EMP_ID AND RD.EFFECT_DATE = EMP_SUP.EFFECT_DATE AND RD.Row_ID = EMP_SUP.Row_ID
			INNER JOIN Q ON RD.R_Emp_ID=Q.Emp_ID	
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = RD.Emp_ID
		)

	Insert into #EmpCons
	SELECT EMP_ID FROM Q
	   
	SET @sqlQuery = 'SELECT TLA.Lead_App_ID, TLA.Cmp_ID, TLA.Emp_ID, ISNULL(TEM.Emp_Full_Name,'''') AS Emp_Full_Name, ISNULL(TLA.Cust_Name,'''') AS Cust_Name, ISNULL(TLA.Cust_Address,'''') AS Cust_Address'
		SET @sqlQuery += ', ISNULL(TLA.Cust_City,'''') AS Cust_City, ISNULL(TLA.Cust_State,'''') AS Cust_State, ISNULL(TLA.Cust_Pincode,0) AS Cust_Pincode'
		SET @sqlQuery += ', ISNULL(TLA.Cust_Mobile,0) AS Cust_Mobile, ISNULL(TLA.Cust_Email,'''') AS Cust_Email, ISNULL(TLA.Cust_PANNO,'''') AS Cust_PANNO'
		SET @sqlQuery += ', ISNULL(TLA.BackOfficeCode,'''') AS BackOfficeCode'
		SET @sqlQuery += ', ISNULL(TLA.Lead_Type_ID,0) AS Lead_Type_ID, ISNULL(TLT.Lead_Type_Name,'''') AS Lead_Type_Name'
		SET @sqlQuery += ', ISNULL(TLA.Lead_Product_ID,0) AS Lead_Product_ID, ISNULL(TLP.Lead_Product_Name,'''') AS Lead_Product_Name'
		SET @sqlQuery += ', ISNULL(TLA.Visit_Type_ID,0) AS Visit_Type_ID,ISNULL(TVT.Visit_Type_Name,'''') AS Visit_Type_Name'
		SET @sqlQuery += ', ISNULL(TLA.Lead_Status_ID,0) AS Lead_Status_ID, ISNULL(TLS.Lead_Status_Name,'''') AS Lead_Status_Name'
		SET @sqlQuery += ', (CASE WHEN ISNULL(TLA.Visit_Date,'''') = ''1900-01-01 00:00.000'' THEN '''' ELSE CONVERT(VARCHAR(11),TLA.Visit_Date,103) END) AS Visit_Date'
		SET @sqlQuery += ', (CASE WHEN ISNULL(TLA.Follow_Up_Date,'''') = ''1900-01-01 00:00.000'' THEN '''' ELSE CONVERT(VARCHAR(11),TLA.Follow_Up_Date,103) END) AS Follow_Up_Date'
		SET @sqlQuery += ', ISNULL(TLA.Follow_Date_History,'''') AS Follow_Date_History'
		SET @sqlQuery += ', ISNULL(TLA.Remarks,'''') AS Remarks, ISNULL(TLA.Collected_Amt,0) AS Collected_Amt'
		SET @sqlQuery += ', CONVERT(VARCHAR(11),TLA.Modify_Date,103) AS Modify_Date, ISNULL(TLA.Modify_By,'''') AS Modify_By'
		SET @sqlQuery += ', ISNULL(TLA.Assign_TO,0) AS Assign_TO, ISNULL(TLA.Reg_HeadID,0) AS Reg_HeadID'		

	IF (ISNULL(@strOrderBy,'')<>'' )
		SET @sqlQuery += ',ROW_NUMBER() OVER(ORDER BY ' + @strOrderBy + ') AS ''Row_Number'''
	ELSE 
		SET @sqlQuery += ',ROW_NUMBER() OVER(ORDER BY TLA.Lead_App_ID) AS ''Row_Number'''
		
	SET @sqlQuery += ' FROM T0501_Lead_Application TLA'
	SET @sqlQuery += ' LEFT JOIN T0500_Lead_Type TLT ON TLA.Lead_Type_ID = TLT.Lead_Type_ID'
	SET @sqlQuery += ' LEFT JOIN T0500_Lead_Product TLP ON TLA.Lead_Product_ID = TLP.Lead_Product_ID'
	SET @sqlQuery += ' LEFT JOIN T0500_Lead_Visit_Type TVT ON TLA.Visit_Type_ID = TVT.Visit_Type_ID'
	SET @sqlQuery += ' LEFT JOIN T0500_Lead_Status TLS ON TLA.Lead_Status_ID = TLS.Lead_Status_ID'
	SET @sqlQuery += ' INNER JOIN #EmpCons EMH ON EMH.Emp_ID = TLA.Emp_ID'
	SET @sqlQuery += ' LEFT JOIN T0080_EMP_MASTER TEM ON TLA.Emp_ID = TEM.Emp_ID'
	SET @sqlQuery += ' WHERE TLA.Lead_Status_ID = 1 AND '
	
	IF(ISNULL(@strWhere,'') <> '')
		SET @sqlQuery += @strWhere
	
	--IF(ISNULL(@strWhere,'') <> '')
	--	SET @sqlQuery += ' WHERE ' + @strWhere
	
	if (isnull(@strOrderBy,'')<>'' )
		SET @sqlQuery += ' Order By '+ @strOrderBy
		
	PRINT(@sqlQuery)
	EXEC(@sqlQuery)
	 
END

