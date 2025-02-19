CREATE PROCEDURE [dbo].[P_Exit_Details]
	 @Cmp_Id		NUMERIC  
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID		VARCHAR(MAX) = ''	
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) 
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max) 
	,@Desig_ID		varchar(Max) 
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  varchar(Max) = ''	
	,@Vertical_Id varchar(Max) = ''	 
	,@SubVertical_Id varchar(Max) = ''	
	,@SubBranch_Id varchar(Max) = ''	
	,@Bank_ID varchar(max) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID		NUMERIC ,     
	   Branch_ID	NUMERIC,
	   Increment_ID NUMERIC    
	 )              
	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'',0,0,@Bank_ID    
		
			CREATE TABLE #EMP_EXIT_DETAILS
			(				
				Emp_Id NUMERIC,
				cmp_Id	NUMERIC,
				Company_Name VARCHAR(150), 				
				Alpha_Emp_Code VARCHAR(20),
				Emp_Full_name VARCHAR(150),
				City VARCHAR(100),
				[State] VARCHAR(100),
				Branch_Name VARCHAR(200),
				Branch_Code VARCHAR(100),
				Designation VARCHAR(100),
				Department VARCHAR(100),
				Date_Of_Join VARCHAR(25),
				Group_Joining_Date VARCHAR(25),
				Reporting_Manager_Name VARCHAR(150),
				Reporting_Manager_Code VARCHAR(50),
				Date_Of_Birth VARCHAR(25),
				Application_Date VARCHAR(25), -- Added By Sajid 11-04-2022
				Resignation_date VARCHAR(25),				
				Last_Working_Date VARCHAR(25),
				FNF_Status 	CHAR(5),
				FNF_Date VARCHAR(25)				
			)
			
		INSERT Into #EMP_EXIT_DETAILS					
		SELECT DISTINCT EA.emp_id,CM.Cmp_Id,CM.Cmp_Name,EI.Alpha_Emp_Code,EI.Emp_Full_Name,EI.Present_City,EI.Present_State,
			   EI.Branch_Name,BM.Branch_Code,EI.Desig_Name,EI.Dept_Name,CONVERT(VARCHAR(15),EI.Date_Of_Join,103),CONVERT(VARCHAR(15),EI.GroupJoiningDate,103),
			   EM.Emp_Full_Name,EM.Alpha_Emp_Code,CONVERT(VARCHAR(15),EI.Date_Of_Birth,103)
			   ,CONVERT(VARCHAR(15),EA.Application_Date,103)  -- Added By Sajid 11-04-2022
			   ,CONVERT(VARCHAR(15),EA.resignation_date,103),
			   CONVERT(VARCHAR(15),EA.last_date,103),CASE WHEN Is_FNF=1 THEN 'YES' ELSE 'NO' END,CONVERT(VARCHAR(15),Sal_Generate_Date,103)
		FROM dbo.T0200_Emp_ExitApplication EA	WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON EA.Emp_ID = EC.Emp_ID INNER JOIN
			dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id=EA.cmp_id INNER JOIN
			V0080_EMP_MASTER_INCREMENT_GET EI ON EI.Emp_ID=EA.emp_id INNER JOIN
			T0030_BRANCH_MASTER BM WITH (NOLOCK) on bm.Branch_ID=ei.Branch_ID INNER JOIN			
			T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID=EI.Emp_Superior LEFT JOIN
			T0300_Exit_Clearance_Approval CA WITH (NOLOCK) ON CA.Emp_ID=EA.emp_id	LEFT JOIN
			T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Emp_ID=EA.emp_id AND ISNULL(MS.Is_FNF,0)=1
		WHERE EA.Cmp_ID = @Cmp_ID
	
	
		SELECT EA.Emp_id,EA.RPT_Level,EM.Alpha_Emp_Code+'-'+EM.Emp_Full_Name AS Sup_Name,
		CONVERT(VARCHAR(15),EA.Approval_date,103) AS Scheme_ApprovalDate,ea.Feedback
		INTO #Scheme_Table
		FROM #EMP_EXIT_DETAILS ED		
		INNER JOIN T0300_Emp_Exit_Approval_Level EA WITH (NOLOCK) ON ED.emp_id=EA.Emp_id --and EA.RPT_Level=@RPT_Level 
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID=EA.S_Emp_Id 	
			
		SELECT DISTINCT CA.Emp_ID,CA.Exit_ID,CONVERT(VARCHAR(15),CA.Approval_Date,103) as Clearance_ApprovalDate,
		CA.Remarks,CASE WHEN ca.Noc_Status='P' THEN 'Pending' ELSE 'Approved' END AS Noc_Status,
	    EM.Alpha_Emp_Code+'-'+EM.Emp_Full_Name AS Clearance_Appr_By,
	    sum(ISNULL(ECD.Recovery_Amt,0))Recovery_Amt,EM.Dept_Name
		INTO #CLEARANCE_DETAILS
		FROM #EMP_EXIT_DETAILS EA	INNER JOIN	
			 T0300_Exit_Clearance_Approval CA WITH (NOLOCK) ON CA.Emp_ID=EA.emp_id LEFT JOIN
			 V0080_EMP_MASTER_INCREMENT_GET EM ON EM.Emp_ID=CA.Updated_By left JOIN
			 T0350_Exit_Clearance_Approval_Detail ECD WITH (NOLOCK) ON ECD.Approval_id=CA.Approval_Id
		WHERE EA.Cmp_ID = @Cmp_ID and CA.Noc_Status<>'P'
		GROUP BY CA.Emp_ID,CA.Exit_ID,CA.Approval_Date,CA.Remarks,EM.Emp_Full_name,Noc_Status,
		EM.Dept_Name,EM.Alpha_Emp_Code
		ORDER by CA.Emp_ID

		CREATE TABLE #LABEL
		(	
			EMP_ID INT,
			LABEL VARCHAR(500),
			VALUE VARCHAR(500),
			Department VARCHAR(500)
		)
		INSERT INTO #LABEL
		SELECT 	ed.emp_id,'Exit_Approved_By_Level(1)',Sup_Name,''		
		FROM #Scheme_Table TD
		INNER JOIN #EMP_EXIT_DETAILS ED ON ED.Emp_Id=TD.EMP_ID
		WHERE RPT_LEVEL=1		
				
		INSERT INTO #LABEL
		SELECT 	ed.emp_id,'Exit_Approved_By_Level(2)',Sup_Name,''		
		FROM #Scheme_Table TD
		INNER JOIN #EMP_EXIT_DETAILS ED ON ED.Emp_Id=TD.EMP_ID
		WHERE RPT_LEVEL=2	
		
		INSERT INTO #LABEL
		SELECT 	ed.emp_id,'Exit_Approved_By_Level(3)',Sup_Name,''		
		FROM #Scheme_Table TD
		INNER JOIN #EMP_EXIT_DETAILS ED ON ED.Emp_Id=TD.EMP_ID
		WHERE RPT_LEVEL=3	
		
		INSERT INTO #LABEL
		SELECT 	ed.emp_id,'Exit_Approved_By_Level(4)',Sup_Name,''		
		FROM #Scheme_Table TD
		INNER JOIN #EMP_EXIT_DETAILS ED ON ED.Emp_Id=TD.EMP_ID
		WHERE RPT_LEVEL=4	
		
		INSERT INTO #LABEL
		SELECT 	ed.emp_id,'Exit_Approved_By_Level(5)',Sup_Name,''		
		FROM #Scheme_Table TD
		INNER JOIN #EMP_EXIT_DETAILS ED ON ED.Emp_Id=TD.EMP_ID
		WHERE RPT_LEVEL=5	
		
		INSERT INTO #LABEL
		SELECT 	ed.emp_id,'Exit_Approval_Date(1)',Scheme_ApprovalDate,''		
		FROM #Scheme_Table TD
		INNER JOIN #EMP_EXIT_DETAILS ED ON ED.Emp_Id=TD.EMP_ID
		WHERE RPT_LEVEL=1	
		
		INSERT INTO #LABEL
		SELECT 	ed.emp_id,'Exit_Approval_Date(2)',Scheme_ApprovalDate,''		
		FROM #Scheme_Table TD
		INNER JOIN #EMP_EXIT_DETAILS ED ON ED.Emp_Id=TD.EMP_ID
		WHERE RPT_LEVEL=2	
		
		INSERT INTO #LABEL
		SELECT 	ed.emp_id,'Exit_Approval_Date(3)',Scheme_ApprovalDate,''		
		FROM #Scheme_Table TD
		INNER JOIN #EMP_EXIT_DETAILS ED ON ED.Emp_Id=TD.EMP_ID
		WHERE RPT_LEVEL=3	
		
		INSERT INTO #LABEL
		SELECT 	ed.emp_id,'Exit_Approval_Date(4)',Scheme_ApprovalDate,''		
		FROM #Scheme_Table TD
		INNER JOIN #EMP_EXIT_DETAILS ED ON ED.Emp_Id=TD.EMP_ID
		WHERE RPT_LEVEL=4	
		
		INSERT INTO #LABEL
		SELECT 	ed.emp_id,'Exit_Approval_Date(5)',Scheme_ApprovalDate,''		
		FROM #Scheme_Table TD
		INNER JOIN #EMP_EXIT_DETAILS ED ON ED.Emp_Id=TD.EMP_ID
		WHERE RPT_LEVEL=5	
		
		INSERT INTO #LABEL
		SELECT emp_id,'Clearance_Approved_By',TD.Clearance_Appr_By,TD.DEPT_NAME		
		FROM #CLEARANCE_DETAILS TD 	WHERE ISNULL(TD.DEPT_NAME,'') <>''
	
		INSERT INTO #LABEL
--		SELECT EMP_ID,TD.DEPT_NAME+'_Clearance_Approval_Date(' +cast(ROW_NUMBER() OVER (ORDER BY TD.DEPT_NAME)as VARCHAR(10))+')',
		SELECT EMP_ID,'Clearance_Approval_Date',Clearance_ApprovalDate,TD.DEPT_NAME		
		FROM #CLEARANCE_DETAILS TD 	
		
		--INSERT INTO #LABEL
		--SELECT EMP_ID,TD.DEPT_NAME+'_Recovery_Amount(' +cast(ROW_NUMBER() OVER (ORDER BY TD.DEPT_NAME)as VARCHAR(10))+')',Recovery_Amt
		--FROM #CLEARANCE_DETAILS TD 		
			
		SELECT DISTINCT LABEL INTO #LABEL_LIST FROM #LABEL 
		DECLARE @cols1 VARCHAR(MAX)	
		DECLARE @query VARCHAR(MAX)
		
		SELECT @cols1 = COALESCE(@cols1 + ',[' + cast(Label as varchar) + ']','[' + cast(Label as varchar)+ ']')
		FROM #LABEL_LIST
				
			
		--select @cols1
		--SELECT * FROM #LABEL_LIST
		--SELECT * FROM #Scheme_Table '' as mobileno
			SET @query = 'SELECT *
						FROM (
							SELECT DISTINCT ED.Emp_Id,Company_Name,Alpha_Emp_Code,ED.Emp_Full_name,city,State,
								   Branch_Name,Branch_Code,Designation,ED.Department,
								   Reporting_Manager_Code,Reporting_Manager_Name
								   ,Application_Date,Resignation_date,
								   Last_Working_Date,LB1.Label,value,FNF_Status,FNF_Date,'''' as Mobile_No
							from #EMP_EXIT_DETAILS ED							
							INNER JOIN #LABEL LB ON LB.EMP_ID=ED.EMP_ID
							inner join #LABEL_LIST LB1 ON LB.LABEL=LB1.LABEL			   
							) as s
						PIVOT
						(						 
							Max(value)
							FOR [Label]  IN (' + @cols1 + ') 						
						)AS T1'
						--PIVOT
						--(						 
						--	Max(Clearance_Appr_By)
						--	FOR [Label]  IN (' + @cols1 + ') 						
						--)AS T2'
						
						--print @query
		EXEC(@query)
	
		--SELECT distinct Company_Name,Employee_Code,Employee_Name,city,State,Branch_Name,Branch_Code,Designation,Department,
	 --   Reporting_Manager_Code,Reporting_Manager_Name,Resignation_date,RM1_APPROVAL_DATE,Last_Working_Date,
	 --   TD.Clearance_ApprovalDate AS Clearance_Approval_Date,ISNULL(Clearance_Approved_By,'')AS Clearance_Approved_By,Recovery_Amt,
	 --   TD.Remarks AS Clearance_Remarks	
		--FROM #EMP_EXIT_DETAILS ED		
		--CROSS join #CLEARANCE_DETAILS TD 
		
END

