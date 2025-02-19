


---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Employee_Application_Records] 
	-- Add the parameters for the stored procedure here
	@Emp_ID INT,
	@PageNo		INT = 1,
	@OrderBy	Varchar(64) = 'Emp_Tran_ID DESC',
	@Str_Where      Varchar(Max) ='',
	@Item_Per_Page	INT = 50
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	
	 CREATE TABLE #tbl_Scheme
	 (
		Scheme_ID			INT,
		Rpt_Level           INT,
		Branch_ID              VARCHAR(MAX),
		Scheme_Name         Varchar(200),
		App_Emp_ID          INT
	 )  
	CREATE NONCLUSTERED INDEX Ix_tbl_Scheme_SchemeId on #tbl_Scheme (Scheme_ID,rpt_level)
	
	
IF @Emp_ID <> 0
BEGIN
		INSERT INTO #tbl_Scheme
		Select SD.Scheme_Id,SD.Rpt_Level,BM.BRANCH_ID as Branch_ID, SM.Scheme_Name,SD.App_Emp_ID As App_Emp_ID
		FROM	T0050_Scheme_Detail SD WITH (NOLOCK)
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) on sd.Cmp_Id = bm.Cmp_ID and (CHARINDEX('#' + CAST(BM.BRANCH_ID AS VARCHAR(10)) + '#', '#' + sd.Leave + '#') > 0)
			INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id 
	    WHERE	SM.Scheme_Type = 'Employee Application' AND SD.App_Emp_ID=@Emp_ID 
				
END
--ELSE
--  BEGIN
--	    INSERT INTO #tbl_Scheme
--		Select SD.Scheme_Id,SD.Rpt_Level,BM.BRANCH_ID as Branch_ID, SM.Scheme_Name,SD.App_Emp_ID As App_Emp_ID
--		FROM	T0050_Scheme_Detail SD 
--			INNER JOIN T0030_BRANCH_MASTER BM on sd.Cmp_Id = bm.Cmp_ID and (CHARINDEX('#' + CAST(BM.BRANCH_ID AS VARCHAR(10)) + '#', '#' + sd.Leave + '#') > 0)
--			INNER JOIN T0040_Scheme_Master SM ON SD.Scheme_Id = SM.Scheme_Id 
--	    WHERE	SM.Scheme_Type = 'Employee Application'
--END

	
	
	CREATE TABLE #tbl_EMP_MASTER_APP
	 (
		Emp_Tran_ID			BIGINT,
		Emp_Application_ID  INT,
		Rpt_Level           INT,
		Branch_ID           INT,
		Cmp_ID              INT,
		Grd_ID              INT,		
		Emp_Full_Name       VARCHAR(250),
		EMP_First_Name      VARCHAR(100),
		Ref_Emp_Tran_ID          INT,
		Approved_Emp_ID     INT,
		Approve_Status      CHAR(25),
		Approved_Date       DATETIME,
		Loc_ID              INT, 
		Alpha_Emp_Code      VARCHAR(20),
		Dept_ID				INT,
		Desig_ID			INT,
		Enroll_No           INT,
		Date_Of_Join        DATETIME,
		Emp_code            VARCHAR(20)
	 )  
	CREATE NONCLUSTERED INDEX Ix_tbl_EMP_MASTER_APP_Emp_Tran_Id on #tbl_EMP_MASTER_APP (Branch_ID,Rpt_Level)
	
    INSERT INTO #tbl_EMP_MASTER_APP
    SELECT  APP.Emp_Tran_ID,APP.Emp_Application_ID,APP.Rpt_Level,APP.Branch_ID,APP.Cmp_ID,APP.Grd_ID,App.Emp_Full_Name,
			App.Emp_First_Name,APP.Ref_Emp_Tran_ID,App.Approved_Emp_ID,
			(Case When APP.Approve_Status = 'P' 
				       Then 'Pending' 
				  When APP.Approve_Status = 'S' 
				       Then 'Submit' 
				  When APP.Approve_Status = 'V' 
				       Then 'Revert' 
				  When APP.Approve_Status = 'R' 
				       Then 'Reject'
				  When APP.Approve_Status = 'A' 
				       Then 'Final Approve'
		     END) as Approve_Status,APP.Approved_Date,App.Loc_ID,App.Alpha_Emp_Code,APP.Dept_ID,App.Desig_ID,App.Enroll_No,APP.Date_Of_Join
								,APP.Alpha_Emp_Code  as Emp_code
			
    FROM	T0060_EMP_MASTER_APP APP WITH (NOLOCK)
				INNER JOIN (SELECT	MAX(Emp_Tran_ID)  As Emp_Tran_ID, Emp_Application_ID 
							FROM	T0060_EMP_MASTER_APP APP1 WITH (NOLOCK)
							--WHERE	APP1.Approve_Status  <> 'P'
							GROUP BY APP1.Emp_Application_ID) AS APP1 ON APP.Emp_Tran_ID=APP1.Emp_Tran_ID AND APP.Emp_Application_ID=APP1.Emp_Application_ID									
				
    WHERE	APP.Is_Final_Approval=0 --AND (App.Status='S')
		 
	
	ALTER TABLE #tbl_EMP_MASTER_APP ADD Previous_Rpt_Level int
	
	UPDATE	T 
	SET		Previous_Rpt_Level  = T1.Rpt_Level
	FROM	#tbl_EMP_MASTER_APP T  
			INNER JOIN T0060_EMP_MASTER_APP T1 ON T.Ref_Emp_Tran_ID=T1.Emp_Tran_ID
		
			
		
	SELECT  TOP 0 EP.*,EM.Emp_Full_Name AS Applicant_Name,LM.Loc_name,GM.Grd_Name,BM.Branch_Name,DM.Dept_Name,DG.Desig_Name,CM.Cmp_Name
	INTO	#FINAL_RESULT
	FROM    #tbl_EMP_MASTER_APP EP
				INNER JOIN #tbl_Scheme  TS on TS.Branch_ID=EP.Branch_ID and TS.Rpt_Level=EP.Rpt_Level
				LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EP.Approved_Emp_ID
				LEFT JOIN T0001_LOCATION_MASTER LM WITH (NOLOCK) ON LM.Loc_ID = EP.Loc_ID
				LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID =EP.Grd_ID
				LEFT JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID =EP.Branch_ID
				LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.Dept_Id =EP.Dept_ID
				LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) ON DG.Desig_ID=EP.Desig_ID
				LEFT JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id =EP.Cmp_ID
		 
		--select * from #FINAL_RESULT
		
	IF IsNull(@Emp_ID,0) = 0 --For Admin 
	   BEGIN
		
				INSERT INTO	#FINAL_RESULT
				SELECT  EP.* ,Case When EP.Approved_Emp_ID = 0 Then 'Admin' Else EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name END AS Applicant_Name,LM.Loc_name,GM.Grd_Name,BM.Branch_Name,DM.Dept_Name,DG.Desig_Name,CM.Cmp_Name		
				FROM    #tbl_EMP_MASTER_APP EP
						LEFT OUTER JOIN #tbl_Scheme  TS on TS.Branch_ID=EP.Branch_ID and TS.Rpt_Level=EP.Rpt_Level
						--INNER JOIN T0060_EMP_MASTER_APP EMP on EMP.Emp_Tran_ID=EP.Ref_Emp_Tran_ID
						LEFT OUTER JOIN  T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EP.Approved_Emp_ID
						LEFT JOIN T0001_LOCATION_MASTER LM WITH (NOLOCK) ON LM.Loc_ID = EP.Loc_ID
						LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID =EP.Grd_ID
						LEFT JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID =EP.Branch_ID
						LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.Dept_Id =EP.Dept_ID
						LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) ON DG.Desig_ID=EP.Desig_ID
						LEFT JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id =EP.Cmp_ID
		END
	ELSE	
		BEGIN	
				
							
				INSERT INTO	#FINAL_RESULT
				SELECT  EP.*, Case When EP.Approved_Emp_ID = 0 Then 'Admin' Else EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name END AS Applicant_Name,LM.Loc_name,GM.Grd_Name,BM.Branch_Name,DM.Dept_Name,DG.Desig_Name,CM.Cmp_Name
				FROM    #tbl_EMP_MASTER_APP EP
							--INNER JOIN #tbl_Scheme  TS on TS.Branch_ID=EP.Branch_ID and ((TS.Rpt_Level=EP.Rpt_Level AND EP.Approve_Status <> 'Pending') or (TS.Rpt_Level=EP.Previous_Rpt_Level AND EP.Approve_Status = 'Pending') )
							INNER JOIN #tbl_Scheme  TS on TS.Branch_ID=EP.Branch_ID and ((TS.Rpt_Level=EP.Rpt_Level AND EP.Approve_Status <> 'Pending') or (TS.Rpt_Level=EP.Previous_Rpt_Level) )
							--INNER JOIN T0060_EMP_MASTER_APP EMP on EMP.Emp_Tran_ID=EP.Ref_Emp_Tran_ID
							LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EP.Approved_Emp_ID
							LEFT JOIN T0001_LOCATION_MASTER LM WITH (NOLOCK) ON LM.Loc_ID = EP.Loc_ID
							LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID =EP.Grd_ID
							LEFT JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID =EP.Branch_ID
							LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.Dept_Id =EP.Dept_ID
							LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) ON DG.Desig_ID=EP.Desig_ID
							LEFT JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id =EP.Cmp_ID
							
					
		END
	--SELECT  * FROM #FINAL_RESULT
	
	IF @Str_Where <> ''
	BEGIN
			SET @Str_Where='1=1 and ' + @Str_Where
	END
	ELSE
	BEGIN
			SET @Str_Where='1=1'
	END
	
	exec SP_GetPage @Items_Per_Page=@Item_Per_Page,@Page_No=@PageNo,
			@Select_Fields='Emp_Application_ID, Emp_Tran_ID,Emp_full_Name,Enroll_No,Date_Of_Join,Approved_Date, Applicant_Name,Loc_name,Grd_Name,Branch_Name,Dept_Name,Desig_Name,Emp_code,Cmp_Name,Cmp_ID,Branch_ID,Desig_ID,Dept_ID,Alpha_Emp_code,Approve_Status ',
			@From='#FINAL_RESULT',
			@Where=@Str_Where,@OrderBy=@OrderBy
	
	--DECLARE @SQL NVARCHAR(MAX)		
	--SET @SQL = ''
		 
         
END


