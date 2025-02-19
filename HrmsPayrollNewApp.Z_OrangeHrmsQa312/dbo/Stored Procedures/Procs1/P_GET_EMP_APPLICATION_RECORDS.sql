
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_GET_EMP_APPLICATION_RECORDS] 
	-- Add the parameters for the stored procedure here
	@Emp_ID     INT=0,
	@PageNo		INT = 1,
	@OrderBy	Varchar(64) = 'Emp_Tran_ID DESC',
	@Str_Where      Varchar(Max) ='',
	@Item_Per_Page	INT = 50,
	@Status		Varchar(64) = 'P,S'
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	CREATE TABLE #Status (ID INT, AprStatus Varchar(16))
	INSERT INTO #Status SELECT ID, DATA FROM dbo.Split(@Status, ',') T
	
	Update	#Status
	SET		AprStatus  =Case AprStatus When 'Approved' Then 'A'
										When 'Rejected' Then 'R'
										When 'Submitted' Then 'S'
										When 'Revert' Then 'V'
										When 'Submitted' Then 'S'
										When 'Final Approved' Then 'F'
										When 'Pending' Then 'P'
										When 'InProcess' Then 'I'
										Else AprStatus End 

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
		Emp_code            VARCHAR(20),
		ActualStatus		Char(1),
		Approve_Emp_ID		INT,
		Status_Color        VARCHAR(20)
	 )  
	CREATE NONCLUSTERED INDEX Ix_tbl_EMP_MASTER_APP_Emp_Tran_Id on #tbl_EMP_MASTER_APP (Branch_ID,Rpt_Level)
	
	
    INSERT INTO #tbl_EMP_MASTER_APP
    SELECT  APP.Emp_Tran_ID,APP.Emp_Application_ID,APP.Rpt_Level,APP.Branch_ID,APP.Cmp_ID,APP.Grd_ID,App.Emp_Full_Name,
			App.Emp_First_Name,APP.Ref_Emp_Tran_ID,App.Approved_Emp_ID,
			(Case When APP.Approve_Status = 'P' 
				       Then 'Pending' 
				  When APP.Approve_Status = 'S' 
				       Then 'Submitted' 
				  When APP.Approve_Status = 'V' 
				       Then 'Revert' 
				  When APP.Approve_Status = 'R' 
				       Then 'Rejected'
				  When APP.Approve_Status = 'A' AND app.Is_Final_Approval=1
				       Then 'Final Approved'
				  ELSE
						'Pending' --InProcess
		     END) as Approve_Status,
		      
		     APP.Approved_Date,App.Loc_ID,App.Alpha_Emp_Code,APP.Dept_ID,App.Desig_ID,App.Enroll_No,APP.Date_Of_Join
								,APP.Alpha_Emp_Code  as Emp_code, APP.Approve_Status As ActualStatus, APP.Approved_Emp_ID,
			(Case When APP.Approve_Status = 'P' 
							   Then 'cls_pending' 
						  When APP.Approve_Status = 'S' 
							   Then 'cls_submit' 
						  When APP.Approve_Status = 'V' 
							   Then 'cls_revret' 
						  When APP.Approve_Status = 'R' 
							   Then 'cls_reject'
						  When APP.Approve_Status = 'A' AND app.Is_Final_Approval=1
							   Then 'cls_approve'
						  ELSE
								'cls_pending' -- Pending
			END) as Status_Color										
    FROM	T0060_EMP_MASTER_APP APP  WITH (NOLOCK)      
			INNER JOIN (SELECT	MAX(Emp_Tran_ID)  As Emp_Tran_ID, Emp_Application_ID 
						FROM	T0060_EMP_MASTER_APP APP1 WITH (NOLOCK)
						GROUP BY APP1.Emp_Application_ID) AS APP1 ON APP.Emp_Tran_ID=APP1.Emp_Tran_ID AND APP.Emp_Application_ID=APP1.Emp_Application_ID													
						
						--WHERE	(APP.Rpt_Level in (0,1) and (APP.Rpt_Level != 2 AND ( APP.Approve_Status='P' or APP.Approve_Status='S' )) ) AND APP.Is_Final_Approval=0
    WHERE	(APP.Rpt_Level in (0,1) OR (APP.Rpt_Level = 2 AND APP.Approve_Status='P')) AND APP.Is_Final_Approval=0
    --select  * from #tbl_EMP_MASTER_APP
    
    DELETE	T From	#tbl_EMP_MASTER_APP  T LEFT OUTER JOIN #Status S ON T.ActualStatus = S.AprStatus
    WHERE	S.ID IS NULL
    
    
     IF EXISTS(SELECT 1 FROM #Status WHERE AprStatus='I')
		BEGIN
		
		    INSERT INTO #tbl_EMP_MASTER_APP
			SELECT  APP.Emp_Tran_ID,APP.Emp_Application_ID,APP.Rpt_Level,APP.Branch_ID,APP.Cmp_ID,APP.Grd_ID,App.Emp_Full_Name,
					App.Emp_First_Name,APP.Ref_Emp_Tran_ID,App.Approved_Emp_ID,
					(Case When APP.Approve_Status = 'P' 
							   Then 'Pending' 
						  When APP.Approve_Status = 'S' 
							   Then 'Submitted' 
						  When APP.Approve_Status = 'V' 
							   Then 'Revert' 
						  When APP.Approve_Status = 'R' 
							   Then 'Rejected'
						  When APP.Approve_Status = 'A' AND app.Is_Final_Approval=1
							   Then 'Final Approved'
						  ELSE
								'Pending' --InProcess
					 END) as Approve_Status,
					 APP.Approved_Date,App.Loc_ID,App.Alpha_Emp_Code,APP.Dept_ID,App.Desig_ID,App.Enroll_No,APP.Date_Of_Join,
					 APP.Alpha_Emp_Code  as Emp_code, APP.Approve_Status As ActualStatus, APP.Approved_Emp_ID,
										
					  (Case When APP.Approve_Status = 'P' 
							   Then 'cls_pending' 
						  When APP.Approve_Status = 'S' 
							   Then 'cls_submit' 
						  When APP.Approve_Status = 'V' 
							   Then 'cls_revret' 
						  When APP.Approve_Status = 'R' 
							   Then 'cls_reject'
						  When APP.Approve_Status = 'A' AND app.Is_Final_Approval=1
							   Then 'cls_approve'
						  ELSE
								'cls_pending' -- Pending
					 END) as Status_Color												
			FROM	T0060_EMP_MASTER_APP APP  WITH (NOLOCK)      
					INNER JOIN (SELECT	MAX(Emp_Tran_ID)  As Emp_Tran_ID, Emp_Application_ID 
								FROM	T0060_EMP_MASTER_APP APP1 WITH (NOLOCK)
								GROUP BY APP1.Emp_Application_ID) AS APP1 ON APP.Emp_Tran_ID=APP1.Emp_Tran_ID AND APP.Emp_Application_ID=APP1.Emp_Application_ID													
			WHERE	APP.Is_Final_Approval = 0 AND APP.Rpt_Level > 1
					 AND NOT (APP.Rpt_Level=2 AND App.Approve_Status='P')
		
		END
    
    IF EXISTS(SELECT 1 FROM #Status WHERE AprStatus='F')
		BEGIN
			INSERT INTO #tbl_EMP_MASTER_APP
			SELECT  APP.Emp_Tran_ID,APP.Emp_Application_ID,APP.Rpt_Level,APP.Branch_ID,APP.Cmp_ID,APP.Grd_ID,App.Emp_Full_Name,
					App.Emp_First_Name,APP.Ref_Emp_Tran_ID,App.Approved_Emp_ID,
					(Case When APP.Approve_Status = 'P' 
							   Then 'Pending' 
						  When APP.Approve_Status = 'S' 
							   Then 'Submitted' 
						  When APP.Approve_Status = 'V' 
							   Then 'Revert' 
						  When APP.Approve_Status = 'R' 
							   Then 'Rejected'
						  When APP.Approve_Status = 'A' AND app.Is_Final_Approval=1
							   Then 'Final Approved'
						  ELSE
								'Pending' -- InProcess
					 END) as Approve_Status,					
					 APP.Approved_Date,App.Loc_ID,App.Alpha_Emp_Code,APP.Dept_ID,App.Desig_ID,App.Enroll_No,APP.Date_Of_Join,
					 APP.Alpha_Emp_Code  as Emp_code, APP.Approve_Status As ActualStatus, APP.Approved_Emp_ID,
					 (Case When APP.Approve_Status = 'P' 
							   Then 'cls_pending' 
						  When APP.Approve_Status = 'S' 
							   Then 'cls_submit' 
						  When APP.Approve_Status = 'V' 
							   Then 'cls_revret' 
						  When APP.Approve_Status = 'R' 
							   Then 'cls_reject'
						  When APP.Approve_Status = 'A' AND app.Is_Final_Approval=1
							   Then 'cls_approve'
						  ELSE
								'cls_pending' -- Pending
					 END) as Status_Color			
			FROM	T0060_EMP_MASTER_APP APP WITH (NOLOCK)   
					INNER JOIN (SELECT	MAX(Emp_Tran_ID)  As Emp_Tran_ID, Emp_Application_ID 
								FROM	T0060_EMP_MASTER_APP APP1 WITH (NOLOCK)
								GROUP BY APP1.Emp_Application_ID) AS APP1 ON APP.Emp_Tran_ID=APP1.Emp_Tran_ID AND APP.Emp_Application_ID=APP1.Emp_Application_ID													
			WHERE	APP.Is_Final_Approval=1    
		END
			
		 
	--SELECT  *  FROM #tbl_EMP_MASTER_APP
	
	--ALTER TABLE #tbl_EMP_MASTER_APP ADD Previous_Rpt_Level int
	
	--UPDATE	T 
	--SET		Previous_Rpt_Level  = T1.Rpt_Level
	--FROM	#tbl_EMP_MASTER_APP T  
	--		INNER JOIN T0060_EMP_MASTER_APP T1 ON T.Ref_Emp_Tran_ID=T1.Emp_Tran_ID
	
	--/*If record is saved by previous level Employee(Approver or Applicant) then status should be pending always*/
	--UPDATE	T
	--SET		Approve_Status = 'Pending'
	--FROM	#tbl_EMP_MASTER_APP T	
	--		INNER JOIN #tbl_Scheme  TS on TS.Branch_ID=T.Branch_ID and T.Rpt_Level = TS.Rpt_Level 
	--WHERE	Approve_Emp_ID <> @Emp_ID
		
		
	SELECT  TOP 0 EP.*,EM.Emp_Full_Name AS Applicant_Name,LM.Loc_name,GM.Grd_Name,BM.Branch_Name,
			DM.Dept_Name,DG.Desig_Name,CM.Cmp_Name, Cast(0 As Bit) As IsDisabled
	INTO	#FINAL_RESULT
	FROM    #tbl_EMP_MASTER_APP EP
			LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EP.Approved_Emp_ID
			LEFT JOIN T0001_LOCATION_MASTER LM WITH (NOLOCK) ON LM.Loc_ID = EP.Loc_ID
			LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID =EP.Grd_ID
			LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.Dept_Id =EP.Dept_ID
			LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) ON DG.Desig_ID=EP.Desig_ID
			LEFT JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id =EP.Cmp_ID
			LEFT JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID =EP.Branch_ID
		 
		
	--	--select * from #FINAL_RESULT
		
	--IF IsNull(@Emp_ID,0) = 0 --For Admin 
	--   BEGIN
		
				INSERT INTO	#FINAL_RESULT
				SELECT  EP.* ,
						Case When EP.Approved_Emp_ID = 0 
								Then 'Admin' 
								Else EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name 
							  END AS Applicant_Name,
					    LM.Loc_name,GM.Grd_Name,BM.Branch_Name,DM.Dept_Name,DG.Desig_Name,CM.Cmp_Name	,
						Case When Approve_Status = 'Pending' Then  0 Else 1 End IsDisabled	
				FROM    #tbl_EMP_MASTER_APP EP
						LEFT OUTER JOIN  T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EP.Approved_Emp_ID
						LEFT JOIN T0001_LOCATION_MASTER LM WITH (NOLOCK) ON LM.Loc_ID = EP.Loc_ID
						LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID =EP.Grd_ID
						LEFT JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID =EP.Branch_ID
						LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.Dept_Id =EP.Dept_ID
						LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) ON DG.Desig_ID=EP.Desig_ID
						LEFT JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id =EP.Cmp_ID
	--	END
	--ELSE	
	--	BEGIN	
				
	--			INSERT INTO	#FINAL_RESULT
	--			SELECT  EP.*, 
	--					Case When EP.Approved_Emp_ID = 0 
	--							 Then 'Admin' 
	--							 Else EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name 
	--					     END AS Applicant_Name,
	--					LM.Loc_name,GM.Grd_Name,BM.Branch_Name,DM.Dept_Name,DG.Desig_Name,CM.Cmp_Name,
	--					Case When Approve_Status = 'Pending' Then  1 Else 0 End IsDisabled
	--			FROM    #tbl_EMP_MASTER_APP EP
	--						--INNER JOIN #tbl_Scheme  TS on TS.Branch_ID=EP.Branch_ID and ((TS.Rpt_Level=EP.Rpt_Level AND EP.Approve_Status <> 'Pending') or (TS.Rpt_Level=EP.Previous_Rpt_Level AND EP.Approve_Status = 'Pending') )
	--						INNER JOIN #tbl_Scheme  TS on TS.Branch_ID=EP.Branch_ID and ((TS.Rpt_Level=EP.Rpt_Level AND EP.ActualStatus <> 'P') or (TS.Rpt_Level=EP.Previous_Rpt_Level) )
	--						--INNER JOIN T0060_EMP_MASTER_APP EMP on EMP.Emp_Tran_ID=EP.Ref_Emp_Tran_ID
	--						LEFT OUTER JOIN T0080_EMP_MASTER EM ON EM.Emp_ID = EP.Approved_Emp_ID
	--						LEFT JOIN T0001_LOCATION_MASTER LM ON LM.Loc_ID = EP.Loc_ID
	--						LEFT JOIN T0040_GRADE_MASTER GM ON GM.Grd_ID =EP.Grd_ID
	--						LEFT  JOIN T0030_BRANCH_MASTER BM ON BM.Branch_ID =EP.Branch_ID
	--						LEFT JOIN T0040_DEPARTMENT_MASTER DM ON DM.Dept_Id =EP.Dept_ID
	--						LEFT JOIN T0040_DESIGNATION_MASTER DG ON DG.Desig_ID=EP.Desig_ID
	--						LEFT JOIN T0010_COMPANY_MASTER CM ON CM.Cmp_Id =EP.Cmp_ID
							
					
	--	END
	
	
	IF @Str_Where <> ''
	BEGIN
			SET @Str_Where='1=1 and ' + @Str_Where
	END
	ELSE
	BEGIN
			SET @Str_Where='1=1'
	END
	
	exec SP_GetPage @Items_Per_Page=@Item_Per_Page,@Page_No=@PageNo,
			@Select_Fields='Emp_Application_ID, Emp_Tran_ID,Emp_full_Name,Enroll_No,Date_Of_Join,Approved_Date, Applicant_Name,Loc_name,Grd_Name,Branch_Name,Dept_Name,Desig_Name,Emp_code,Cmp_Name,Cmp_ID,Branch_ID,Desig_ID,Dept_ID,Alpha_Emp_code,Approve_Status,IsDisabled,Status_Color ',
			@From='#FINAL_RESULT',
			@Where=@Str_Where,@OrderBy=@OrderBy
	
	--DECLARE @SQL NVARCHAR(MAX)		
	--SET @SQL = ''
		 
         
END


