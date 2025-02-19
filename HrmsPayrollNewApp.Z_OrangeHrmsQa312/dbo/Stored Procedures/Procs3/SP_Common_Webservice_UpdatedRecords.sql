

CREATE PROCEDURE [dbo].[SP_Common_Webservice_UpdatedRecords]
	@FROMDATE DATETIME,
	@TODATE DATETIME,
	@TYPE CHAR(1)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


IF @TYPE = 'R'
	BEGIN
		SELECT EM.Emp_Code,EM.Cmp_ID,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,EM.Date_Of_Birth,EM.Date_Of_Join,
		EM.Gender,EM.Work_Email,EM.Street_1,EM.City,EM.State,LM.Loc_name,EM.Mobile_No,BM.Branch_Name,DM.Desig_Code,
		DM.Desig_Name,TDM.Dept_Code,TDM.Dept_Name,TRM.Emp_Full_Name,BM.Branch_Code as Center_Code,CM.Center_Name, -- as per last discussed with rudra bhai cost center no and name has been replace with branch code / name on 02082019
		EM.System_Date,EM.System_Date_Join_left,EM.Emp_Left_Date,IC.System_date AS Increment_System_Date,RM.Effect_Date as Reporting_Effect_Date
		INTO #EmpData
		FROM T0080_EMP_MASTER EM WITH (NOLOCK)
		LEFT JOIN 
		(
		
			SELECT Increment_ID,Emp_ID,Cmp_ID,Branch_ID,Desig_ID,Dept_ID,Center_ID,SYSTEM_DATE
			FROM T0095_INCREMENT WITH (NOLOCK)
			WHERE CONVERT(DATE,System_Date) >= @FROMDATE AND CONVERT(DATE,System_Date) <= @TODATE AND INCREMENT_TYPE NOT IN ('JOINING','TRANSFER')
			
			
		) IC ON EM.Emp_ID = IC.Emp_ID
		LEFT JOIN 
		(
		
			SELECT Increment_ID,Emp_ID,Cmp_ID,Branch_ID,Desig_ID,Dept_ID,Center_ID,SYSTEM_DATE
			FROM T0095_INCREMENT WITH (NOLOCK)
			WHERE CONVERT(DATE,System_Date) >= @FROMDATE AND CONVERT(DATE,System_Date) <= @TODATE
			
		) ICN ON EM.Emp_ID = ICN.Emp_ID

		LEFT JOIN 
		(
			
			SELECT Increment_ID,I.Emp_ID,Cmp_ID,Branch_ID,Desig_ID,Dept_ID,Center_ID,SYSTEM_DATE
			From T0095_Increment I WITH (NOLOCK) Inner Join
			(Select Max(Increment_Effective_Date) As Max_Date,Emp_ID
			FROM T0095_INCREMENT WITH (NOLOCK)
			WHERE Increment_Effective_Date <= @TODATE
			Group By Emp_ID
			)Qry On I.Emp_Id=Qry.Emp_ID And I.Increment_Effective_Date = Qry.Max_Date
		) ICN1 ON EM.Emp_ID = ICN1.Emp_ID

		LEFT JOIN T0040_COST_CENTER_MASTER CM WITH (NOLOCK) ON Isnull(ICN.Center_ID,ICN1.Center_ID) = CM.Center_ID
		LEFT JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Isnull(ICN.Branch_ID,ICN1.Branch_ID) = BM.Branch_ID
		LEFT JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON Isnull(ICN.Desig_ID,ICN1.Desig_ID) = DM.Desig_ID
		LEFT JOIN T0040_DEPARTMENT_MASTER TDM WITH (NOLOCK) ON Isnull(ICN.Dept_ID,ICN1.Dept_ID) = TDM.Dept_ID 
		LEFT JOIN T0001_LOCATION_MASTER LM WITH (NOLOCK) ON EM.Loc_ID = LM.Loc_ID
		LEFT JOIN  
		(
			SELECT ER.Emp_ID, ER.Effect_Date, ER.R_Emp_ID
			FROM T0090_EMP_REPORTING_DETAIL ER WITH (NOLOCK)
			INNER JOIN 
			(
				SELECT	MAX(R2.Row_ID) AS 'ROW_ID',R2.Emp_ID
				FROM T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
				INNER JOIN 
				(
					SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
					FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
					--WHERE Effect_Date < @TODATE COMMENTED BY RAJPUT
					WHERE CONVERT(DATE,Effect_Date) BETWEEN @FROMDATE AND @TODATE
					GROUP BY Emp_ID
				 ) R3 ON R2.Emp_ID = R3.Emp_ID AND R2.Effect_Date = R3.Effect_Date
				 GROUP BY R2.Emp_ID
			) AS TER ON ER.Row_ID = TER.ROW_ID AND ER.Emp_ID = TER.Emp_ID
		) RM ON EM.Emp_ID = RM.Emp_ID
		LEFT JOIN T0080_EMP_MASTER TRM WITH (NOLOCK) ON RM.R_Emp_ID = TRM.Emp_ID
		ORDER BY EM.Emp_ID

		SELECT * FROM 
		
		(
		-- GET RECORDS OF DIRECT LEFT EMPLOYEE 
		SELECT Emp_Code AS 'EmployeeNo',Emp_First_Name AS 'FirstName',Emp_Second_Name AS 'MiddleName',Emp_Last_Name AS 'LastName',
		Date_Of_Birth AS 'DOB',Date_Of_Join AS 'DOJ',Gender AS 'Gender',Work_Email AS 'EmailID',Street_1 AS 'Address',City,
		State,Loc_name AS 'Country',Mobile_No AS 'Phone',Branch_Name AS 'Plant',Desig_Code AS 'DesignationCode',
		Desig_Name AS 'Designation',Dept_Code AS 'DepartmentCode',Dept_Name AS 'Department',Emp_Full_Name AS 'ImmediateSuperior',Center_Code AS 'CostCenterNo',
		'Y1' AS 'ActionCode','New Joining' AS 'ActionName',GETDATE() AS 'ActionDate', Cmp_ID as 'CompanyID'
		FROM #EmpData
		WHERE CONVERT(DATE,System_Date_Join_left) BETWEEN @FROMDATE AND @TODATE AND CONVERT(DATE,Emp_Left_Date) IS NULL 
		

		UNION ALL
		
		-- TAKE INCREMENT UPDATED RECORDS
		SELECT Emp_Code AS 'EmployeeNo',Emp_First_Name AS 'FirstName',Emp_Second_Name AS 'MiddleName',Emp_Last_Name AS 'LastName',
		Date_Of_Birth AS 'DOB',Date_Of_Join AS 'DOJ',Gender AS 'Gender',Work_Email AS 'EmailID',Street_1 AS 'Address',City,
		State,Loc_name AS 'Country',Mobile_No AS 'Phone',Branch_Name AS 'Plant',Desig_Code AS 'DesignationCode',
		Desig_Name AS 'Designation',Dept_Code AS 'DepartmentCode',Dept_Name AS 'Department',Emp_Full_Name AS 'ImmediateSuperior',Center_Code AS 'CostCenterNo',
		'Y8' AS 'ActionCode','Promotion' AS 'ActionName',GETDATE() AS 'ActionDate', Cmp_ID as 'CompanyID'
		FROM #EmpData
		WHERE CONVERT(DATE,Increment_System_Date) BETWEEN @FROMDATE AND @TODATE AND CONVERT(DATE,Increment_System_Date) IS NOT NULL 
		
		UNION ALL
		
		---- GET RECORDS OF ABSCONDING
		--SELECT Emp_Code AS 'EmployeeNo',Emp_First_Name AS 'FirstName',Emp_Second_Name AS 'MiddleName',Emp_Last_Name AS 'LastName',
		--Date_Of_Birth AS 'DOB',Date_Of_Join AS 'DOJ',Gender AS 'Gender',Work_Email AS 'EmailID',Street_1 AS 'Address',City,
		--State,Loc_name AS 'Country',Mobile_No AS 'Phone',Branch_Name AS 'Plant',Desig_Code AS 'DesignationCode',
		--Desig_Name AS 'Designation',Dept_Code AS 'DepartmentCode',Dept_Name AS 'Department',Emp_Full_Name AS 'ImmediateSuperior',Center_Name AS 'CostCenterNo',
		--'Y9' AS 'ActionCode','Separation' AS 'ActionName',GETDATE() AS 'ActionDate'
		--FROM #EmpData
		--WHERE CONVERT(DATE,Emp_Left_Date) BETWEEN @FROMDATE AND @TODATE AND CONVERT(DATE,Emp_Left_Date) IS NOT NULL
		
		--UNION ALL
		
		
	 	-- GET RECORDS OF RETURN FROM ABSCONDING
		SELECT Emp_Code AS 'EmployeeNo',Emp_First_Name AS 'FirstName',Emp_Second_Name AS 'MiddleName',Emp_Last_Name AS 'LastName',
		Date_Of_Birth AS 'DOB',Date_Of_Join AS 'DOJ',Gender AS 'Gender',Work_Email AS 'EmailID',Street_1 AS 'Address',City,
		State,Loc_name AS 'Country',Mobile_No AS 'Phone',Branch_Name AS 'Plant',Desig_Code AS 'DesignationCode',
		Desig_Name AS 'Designation',Dept_Code AS 'DepartmentCode',Dept_Name AS 'Department',Emp_Full_Name AS 'ImmediateSuperior',Center_Code AS 'CostCenterNo',
		'Z1' AS 'ActionCode','Separation' AS 'ActionName',GETDATE() AS 'ActionDate', Cmp_ID as 'CompanyID'
		FROM #EmpData
		WHERE CONVERT(DATE,System_Date_Join_left) BETWEEN @FROMDATE AND @TODATE AND CONVERT(DATE,Emp_Left_Date) IS NOT NULL
		

		UNION ALL
		
		-- GET RECORDS OF EMPLOYEE MASTER UPDATED
		SELECT Emp_Code AS 'EmployeeNo',Emp_First_Name AS 'FirstName',Emp_Second_Name AS 'MiddleName',Emp_Last_Name AS 'LastName',
		Date_Of_Birth AS 'DOB',Date_Of_Join AS 'DOJ',Gender AS 'Gender',Work_Email AS 'EmailID',Street_1 AS 'Address',City,
		State,Loc_name AS 'Country',Mobile_No AS 'Phone',Branch_Name AS 'Plant',Desig_Code AS 'DesignationCode',
		Desig_Name AS 'Designation',Dept_Code AS 'DepartmentCode',Dept_Name AS 'Department',Emp_Full_Name AS 'ImmediateSuperior',Center_Code AS 'CostCenterNo',
		'Z9' AS 'ActionCode','EditOAFlag' AS 'ActionName',GETDATE() AS 'ActionDate', Cmp_ID as 'CompanyID'
		FROM #EmpData
		WHERE CONVERT(DATE,System_Date) BETWEEN @FROMDATE AND @TODATE AND CONVERT(DATE,System_Date) <> CONVERT(DATE,System_Date_Join_left) 
		
		UNION ALL
		
		-- GET RECORDS OF REPORTING MANAGER UPDATED
		SELECT Emp_Code AS 'EmployeeNo',Emp_First_Name AS 'FirstName',Emp_Second_Name AS 'MiddleName',Emp_Last_Name AS 'LastName',
		Date_Of_Birth AS 'DOB',Date_Of_Join AS 'DOJ',Gender AS 'Gender',Work_Email AS 'EmailID',Street_1 AS 'Address',City,
		State,Loc_name AS 'Country',Mobile_No AS 'Phone',Branch_Name AS 'Plant',Desig_Code AS 'DesignationCode',
		Desig_Name AS 'Designation',Dept_Code AS 'DepartmentCode',Dept_Name AS 'Department',Emp_Full_Name AS 'ImmediateSuperior',Center_Code AS 'CostCenterNo',
		'Z9' AS 'ActionCode','EditOAFlag' AS 'ActionName',GETDATE() AS 'ActionDate', Cmp_ID as 'CompanyID'
		FROM #EmpData
		WHERE CONVERT(DATE,Reporting_Effect_Date) BETWEEN @FROMDATE AND @TODATE AND Reporting_Effect_Date IS NOT NULL AND CONVERT(DATE,System_Date) <> CONVERT(DATE,System_Date_Join_left) 
		
		) T
		ORDER BY T.EmployeeNo ASC
	END
ELSE
	BEGIN
		SELECT EM.Emp_code,EM.Cmp_ID,ER.For_Date,ER.In_Time,ER.Out_Time,ER.Duration,ER.Reason
		FROM T0150_EMP_INOUT_RECORD ER WITH (NOLOCK)
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ER.Emp_ID = EM.Emp_ID
		WHERE For_Date >= @FROMDATE AND For_Date <= @TODATE
	END

