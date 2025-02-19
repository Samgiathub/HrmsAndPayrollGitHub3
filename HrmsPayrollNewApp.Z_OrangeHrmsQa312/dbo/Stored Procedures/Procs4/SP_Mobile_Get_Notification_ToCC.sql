
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_Get_Notification_ToCC] 
	@Emp_ID	NUMERIC(18,0),
	@Cmp_ID	NUMERIC(18,0),
	@Module_Name NVARCHAR(MAX),
	@Flag TINYINT = 1, -- Flag will be 0, If Employee will be in CC . Flag will be 1, If Employee will be in To Flag will be 2, If Employee will not in To not in CC
	@Leave_ID NUMERIC(18,0) = 0,-- For Five Level Leave Approval 
	@Rpt_Level TINYINT = 0, -- For Five Level Leave Approval 
	@Final_Approval TINYINT = 1 -- For Five Level Leave Approval
	--@DeviceID nvarchar(MAX) OUTPUT
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
CREATE TABLE #Temp_To (Output_To Varchar(max))
CREATE TABLE #Temp_CC (Output_CC VARCHAR(MAX))
CREATE TABLE #Temp_Emp(Output_Emp VARCHAR(MAX))
CREATE TABLE #Rpt_branch_manager(Emp_ID NUMERIC(18,0))

DECLARE @EMAIL_NTF_SENT TINYINT
DECLARE @To_Manager TINYINT
DECLARE @To_Hr TINYINT
DECLARE @To_Account TINYINT
DECLARE @Other_Email VARCHAR(MAX)
DECLARE @Is_Manager_CC TINYINT
DECLARE @Is_HR_CC TINYINT
DECLARE @Is_Account_CC TINYINT
DECLARE @hremail INT

SET @hremail = 0
	

SELECT @EMAIL_NTF_SENT = EMAIL_NTF_SENT,@To_Manager = To_Manager,@To_Hr = To_Hr,@To_Account = To_Account,@Other_Email = Other_Email,
@Is_Manager_CC = Is_Manager_CC,@Is_HR_CC = Is_HR_CC,@Is_Account_CC = Is_Account_CC
FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK)
WHERE CMP_ID = @Cmp_ID AND EMAIL_TYPE_NAME = @Module_Name
	
IF @EMAIL_NTF_SENT = 1
	BEGIN
		--SELECT @To_Manager=To_Manager, @To_Hr=To_Hr, @To_Account=To_Account, @Other_Email=Other_Email, 
		--		   @Is_Manager_CC=Is_Manager_CC, @Is_HR_CC=Is_HR_CC, @Is_Account_CC=Is_Account_CC
		--				From T0040_EMAIL_NOTIFICATION_CONFIG Where CMP_ID = @Cmp_ID And EMAIL_TYPE_NAME = @Module_Name

			--If @To_Manager = 1
			--	Begin
			--		If @Is_Manager_CC = 1
			--			insert into #Temp_CC
			--				Select distinct(Work_Email)  From T0080_EMP_MASTER where Emp_ID IN (
			--						Select R_Emp_ID from T0090_EMP_REPORTING_DETAIL Where Emp_ID = @Emp_ID Union
			--						Select Emp_Superior From T0080_EMP_MASTER Where Emp_ID = @Emp_ID) and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE()
			--		Else
			--			insert into #Temp_To 
			--				Select distinct(Work_Email) From T0080_EMP_MASTER where Emp_ID IN (
			--						Select R_Emp_ID from T0090_EMP_REPORTING_DETAIL Where Emp_ID = @Emp_ID Union
			--						Select Emp_Superior From T0080_EMP_MASTER Where Emp_ID = @Emp_ID) and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE()
			--	End
				
			-- =====================================================================
			
		DECLARE @Is_Rm TINYINT
		DECLARE @Is_Bm TINYINT
		DECLARE @Emp_Branch NUMERIC
		DECLARE @Is_HOD TINYINT
		DECLARE @Emp_Dept NUMERIC(18,0)
		DECLARE @Is_Hr	TINYINT
		DECLARE @Scheme_Id NUMERIC(18,0)
		DECLARE @Is_PRM TINYINT
		
		SET @Is_Rm = 0
		SET @Is_Bm = 0
		SET @Is_HOD = 0
		SET @Is_Hr = 0
		SET @Scheme_Id = 0
		SET @Is_PRM = 0
			
		SELECT @Emp_Branch = IC.Branch_ID,@Emp_Dept = IC.Dept_ID
		FROM T0095_INCREMENT IC WITH (NOLOCK)
		INNER JOIN
		(
			SELECT MAX(Increment_effective_Date) AS 'For_Date',Emp_ID 
			FROM T0095_INCREMENT WITH (NOLOCK)
			WHERE Increment_Effective_date <= GETDATE() AND Cmp_ID = @Cmp_ID
			GROUP BY Emp_ID
		) Qry on IC.Emp_ID = Qry.Emp_ID AND IC.Increment_Effective_Date = Qry.For_Date
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON IC.Emp_ID = EM.Emp_ID	
		WHERE EM.Emp_ID = @Emp_ID
		
		IF @To_Manager = 1
			BEGIN
				DECLARE @App_Emp_ID NUMERIC(18,0)
				SET @App_Emp_ID = 0

				IF (@Module_Name = 'Leave Application' OR @Module_Name = 'Leave Approval') AND @Final_Approval = 0
					BEGIN
						IF EXISTS 
								(
									SELECT App_Emp_ID 
									FROM T0050_Scheme_Detail WITH (NOLOCK)
									WHERE Rpt_Level = (@Rpt_Level + 1) 
									AND Scheme_Id = 
									(
										SELECT DISTINCT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
										INNER JOIN T0050_Scheme_Detail T1 WITH (NOLOCK) ON QES.Scheme_ID = T1.Scheme_Id 
										INNER JOIN
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID 
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID And Type = 'Leave'
											GROUP BY Emp_ID 
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND Type = 'Leave'
										AND @Leave_ID IN 
										(
											SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')
										)
									) AND @Leave_ID IN (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#'))
								)
							BEGIN
							
								SELECT @App_Emp_ID = App_Emp_ID,@Is_Rm = Is_RM ,@Is_Bm = Is_BM,@Scheme_Id = Scheme_Id 
								FROM T0050_Scheme_Detail WITH (NOLOCK)
								WHERE Rpt_Level = (@Rpt_Level + 1)
								AND Scheme_Id = 
								(
									SELECT DISTINCT QES.Scheme_ID 
									FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
									INNER JOIN T0050_Scheme_Detail T1 WITH (NOLOCK) ON QES.Scheme_ID = T1.Scheme_Id 
									INNER JOIN 
									(
										SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
										FROM T0095_EMP_SCHEME WITH (NOLOCK)
										WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Leave'
										GROUP BY Emp_ID
									) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Leave'
									AND @Leave_ID IN 
									(
										SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')
									)
								) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')) 
											
								
								IF @App_Emp_ID = 0 AND @Is_Rm = 1 AND @Rpt_Level = 0
									BEGIN					
										INSERT INTO #Rpt_branch_manager
										SELECT R_Emp_ID 
										FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
										INNER JOIN 
										(
											SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
											FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
											WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
											GROUP by Emp_ID
										) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
										WHERE ERD.Emp_ID = @Emp_ID
									end
								ELSE IF @App_Emp_ID = 0 AND @is_Bm =1 --and @Rpt_Level = 0
									BEGIN
										INSERT INTO #Rpt_branch_manager
										SELECT Emp_id 
										FROM T0095_MANAGERS WITH (NOLOCK)
										WHERE Effective_Date = 
										(
											SELECT MAX(Effective_Date) 
											FROM T0095_MANAGERS WITH (NOLOCK)
											WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
										) AND branch_id = @Emp_Branch
									END
							END
					END
					
					IF @Is_Manager_CC = 1
						BEGIN
							IF (@Module_Name = 'Leave Application' OR @Module_Name = 'Leave Approval') AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT emp_id from #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END
							ELSE IF @Module_Name <> 'Leave Application' AND @Module_Name <> 'Leave Approval'  AND @Module_Name <> 'Loan Application' 
									AND @Module_Name <> 'Loan Approval' AND @Module_Name <> 'Attendance Regularization' AND @Module_Name <> 'Attendance Regularization Approve'
									AND @Module_Name <> 'Travel Application' AND @Module_Name <> 'Reimbursement\Claim Application' 
									AND @Module_Name <> 'Reimbursement\Claim Approval' AND @Module_Name <> 'Claim Application'	AND @Module_Name <> 'Pre-CompOff Application' 
									AND @Module_Name <> 'Pre-CompOff Approval' AND @Module_Name <> 'Employee Probation' AND @Module_Name <> 'Employee Training'
									AND @Module_Name <> 'Exit Approval' AND @Module_Name <> 'Clearance Approval' AND @Module_Name <> 'GatePass' AND @Module_Name <> 'Employee Increment Application' 
									AND @Module_Name <> 'Employee Increment Approval' AND @Module_Name <> 'Recruitment Request' AND @Module_Name <> 'Optional Holiday Application'
									AND @Module_Name <> 'Optional Holiday Approval'
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
									WHERE EM.Emp_ID IN 
									(
										SELECT R_Emp_ID 
										FROM  T0090_EMP_REPORTING_DETAIL ERD  WITH (NOLOCK)
										INNER JOIN
										(
											SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
											FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
											WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
											GROUP by Emp_ID 
										) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
										WHERE ERD.Emp_ID = @Emp_ID
										
										UNION
										
										SELECT Emp_Superior  
										FROM T0080_EMP_MASTER WITH (NOLOCK)
										WHERE Emp_ID = @Emp_ID
									) AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
								END
						END
					ELSE
						BEGIN
							IF (@Module_Name = 'Leave Application' OR @Module_Name = 'Leave Approval') AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_To
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_id FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
										
								END
							ELSE IF @Module_Name <> 'Leave Application' AND @Module_Name <> 'Leave Approval' AND @Module_Name <> 'Loan Application' 
									AND @Module_Name <> 'Loan Approval' AND @Module_Name <> 'Attendance Regularization' 
									AND @Module_Name <> 'Attendance Regularization Approve' AND @Module_Name <> 'Travel Application' 
									AND @Module_Name <> 'Reimbursement\Claim Application' AND @Module_Name <> 'Reimbursement\Claim Approval'
									AND @Module_Name <> 'Travel Settlement Application' AND @Module_Name <> 'Claim Application'
									AND @Module_Name <> 'Change Request Application' AND @Module_Name <> 'Change Request Approval'
									AND @Module_Name <> 'Pre-CompOff Application' AND @Module_Name <> 'Pre-CompOff Approval' 
									AND @Module_Name <> 'Employee Probation'  AND @Module_Name <> 'Employee Training'
									AND @Module_Name <> 'Exit Approval'  AND @Module_Name <> 'Clearance Approval'
									AND @Module_Name <> 'GatePass' AND @Module_Name <> 'Recruitment Request'
									AND @Module_Name <> 'Employee Increment Application' AND @Module_Name <> 'Employee Increment Approval'
									AND @Module_Name <> 'Optional Holiday Application' AND @Module_Name <> 'Optional Holiday Approval'
									AND @Module_Name <> 'Pass Responsibility'
								BEGIN
									INSERT INTO #Temp_To 
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
									WHERE EM.Emp_ID IN 
									(
										SELECT R_Emp_ID 
										FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
										INNER JOIN 
										(
											SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
											FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
											WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
											GROUP BY Emp_ID
										) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
										WHERE ERD.Emp_ID = @Emp_ID
									) AND ISNULL(Emp_Left_Date,GETDATE()+1) > GETDATE()	AND EIM.Is_Active = 1
								END
						END
					IF (@Module_Name = 'Loan Application' OR @Module_Name = 'Loan Approval') AND @Final_Approval = 0
						BEGIN
							IF EXISTS 
									(
										SELECT App_Emp_ID 
										FROM T0050_Scheme_Detail  WITH (NOLOCK)
										WHERE Rpt_Level = (@Rpt_Level + 1)
										AND Scheme_Id = 
										(
											SELECT DISTINCT QES.Scheme_ID 
											FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
											INNER JOIN T0050_Scheme_Detail T1 WITH (NOLOCK) ON QES.Scheme_ID = T1.Scheme_Id 
											INNER JOIN
											(
												SELECT MAX(Effective_Date) AS 'Effect_Date',Emp_ID 
												FROM T0095_EMP_SCHEME WITH (NOLOCK)
												WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Loan'
												GROUP BY Emp_ID 
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effect_Date = QES.Effective_Date AND Type = 'Loan'
											WHERE @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(T1.Leave, '#'))
										) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#'))
									)
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID ,@Is_Rm = Is_RM ,@Is_Bm = Is_BM 
									FROM T0050_Scheme_Detail WITH (NOLOCK)
									WHERE Rpt_Level = (@Rpt_Level + 1)
									AND Scheme_Id = 
									(
										SELECT DISTINCT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
										INNER JOIN T0050_Scheme_Detail T1 WITH (NOLOCK) ON QES.Scheme_ID = T1.Scheme_Id 
										INNER JOIN 
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID 
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Loan'
											GROUP BY Emp_ID 
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND Type = 'Loan'
										WHERE @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(T1.Leave, '#'))
									) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')) 
																			
									IF @App_Emp_ID = 0 AND @Is_Rm = 1 AND @Rpt_Level = 0
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
												FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
												GROUP BY Emp_ID
											) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
											WHERE ERD.Emp_ID = @Emp_ID
										END
									ELSE IF @App_Emp_ID = 0 AND @Is_Bm =1 
										BEGIN							
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_MANAGERS WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS  WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END
								END
						END
					IF @Is_Manager_CC = 1
						BEGIN
							IF (@Module_Name = 'Loan Application' OR @Module_Name = 'Loan Approval') AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID)
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END
						END		
					ELSE
						BEGIN
							IF (@Module_Name = 'Loan Application' OR @Module_Name = 'Loan Approval') AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_To
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								End
							End
					IF (@Module_Name = 'Attendance Regularization' OR @Module_Name = 'Attendance Regularization Approve') AND @Final_Approval = 0
						BEGIN
							IF EXISTS 
									(
										SELECT App_Emp_ID 
										FROM T0050_Scheme_Detail WITH (NOLOCK)
										WHERE Rpt_Level = (@Rpt_Level + 1)
										AND Scheme_Id = 
										(	
											SELECT QES.Scheme_ID 
											FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
											INNER JOIN
											(
												SELECT MAX(effective_date) AS effective_date,emp_id 
												FROM T0095_EMP_SCHEME IES WITH (NOLOCK)
												WHERE IES.effective_date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Attendance Regularization'
												GROUP BY emp_id 
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND Type = 'Attendance Regularization'
										) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#'))
									)
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID,@Is_Rm = Is_RM,@Is_Bm = Is_BM 
									FROM T0050_Scheme_Detail WITH (NOLOCK)
									WHERE Rpt_Level = (@Rpt_Level + 1)
									AND Scheme_Id = 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
										INNER JOIN
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Attendance Regularization'
											GROUP BY Emp_ID 
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Attendance Regularization'
									) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')) 
																			
									IF @App_Emp_ID = 0 AND @Is_Rm = 1 AND @Rpt_Level = 0
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
												FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
												GROUP BY Emp_ID 
											) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
											WHERE ERD.Emp_ID = @Emp_ID
										End
									Else IF @App_Emp_ID = 0  and @Is_Bm =1 
										BEGIN							
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_MANAGERS WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END 
								END
						END
					IF @Is_Manager_CC = 1
						BEGIN
							IF (@Module_Name = 'Attendance Regularization' OR @Module_Name = 'Attendance Regularization Approve') AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1						
								END
						END		
					ELSE
						BEGIN
							IF (@Module_Name = 'Attendance Regularization' OR @Module_Name = 'Attendance Regularization Approve') AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_To
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END
							END
					IF @Module_Name = 'Travel Application' AND @Final_Approval = 0
						BEGIN
							IF EXISTS 
									(
										SELECT App_Emp_ID 
										FROM T0050_Scheme_Detail  WITH (NOLOCK)
										WHERE Rpt_Level = (@Rpt_Level + 1)							
										AND Scheme_Id = 
										(
											SELECT QES.Scheme_ID 
											FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
											INNER JOIN
											(
												SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
												FROM T0095_EMP_SCHEME WITH (NOLOCK)
												WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Travel'
												GROUP BY Emp_ID 
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date And Type = 'Travel'
										) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')))
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID ,@Is_Rm = Is_RM ,@Is_Bm = Is_BM 
									FROM T0050_Scheme_Detail WITH (NOLOCK)
									WHERE Rpt_Level = (@Rpt_Level + 1)
									AND Scheme_Id = 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
										INNER JOIN 
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											where Effective_Date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Travel'
											GROUP by Emp_ID
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date And Type = 'Travel'
									) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')) 
																		
									IF @App_Emp_ID = 0 AND @Is_Rm = 1 AND @Rpt_Level = 0
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM T0090_EMP_REPORTING_DETAIL ERD  WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
												FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												WHERE Effect_Date <= getdate() AND Emp_ID = @Emp_ID
												GROUP BY Emp_ID
											) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
											WHERE ERD.Emp_ID = @Emp_ID
										END
									ELSE IF @App_Emp_ID = 0 AND @Is_Bm =1 
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_MANAGERS WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END
								END
						END
					
					IF @Module_Name = 'Travel Settlement Application' And @Final_Approval = 0
						BEGIN
							IF EXISTS 
									(
										SELECT App_Emp_ID 
										FROM T0050_Scheme_Detail WITH (NOLOCK)
										WHERE Rpt_Level = (@Rpt_Level + 1)
										AND Scheme_Id = 
										(
											SELECT QES.Scheme_ID 
											FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
												FROM T0095_EMP_SCHEME WITH (NOLOCK)
												WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Travel Settlement'
												GROUP BY Emp_ID
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND Type = 'Travel Settlement'
										) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#'))
									)
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID,@Is_Rm = Is_RM,@Is_Bm = Is_BM,@Is_HOD = Is_HOD 
									FROM T0050_Scheme_Detail WITH (NOLOCK)
									WHERE Rpt_Level = (@Rpt_Level + 1)
									AND Scheme_Id = 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
										INNER JOIN 
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID 
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Travel Settlement'
											GROUP BY Emp_ID
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND Type = 'Travel Settlement'
									) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')) 
																
									If @App_Emp_ID = 0 AND @Is_Rm = 1 AND @Rpt_Level = 0
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) 
											INNER JOIN 
											(
												SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID 
												FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
												GROUP by Emp_ID
											) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
											WHERE ERD.Emp_ID = @Emp_ID
										END
									ELSE IF @App_Emp_ID = 0 AND @Is_Bm = 1 
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_MANAGERS WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS  WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END 
									ELSE IF @App_Emp_ID = 0 AND @Is_HOD = 1
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_Department_Manager WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_Department_Manager WITH (NOLOCK)
												WHERE Dept_ID = @Emp_Dept AND Effective_Date <= GETDATE()
											) AND Dept_Id = @Emp_Dept
										END
								END
						END
					IF @Module_Name = 'Claim Application' AND @Final_Approval = 0
						BEGIN
							IF EXISTS 
									(
										SELECT App_Emp_ID 
										FROM T0050_Scheme_Detail WITH (NOLOCK)
										WHERE Rpt_Level = (@Rpt_Level + 1)
										AND Scheme_Id IN 
										(
											SELECT QES.Scheme_ID 
											FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID 
												FROM T0095_EMP_SCHEME WITH (NOLOCK)
												WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Claim'
												GROUP by Emp_ID
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND Type = 'Claim'
										) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#'))
									)
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID,@Is_Rm = Is_RM,@Is_Bm = Is_BM 
									FROM T0050_Scheme_Detail WITH (NOLOCK)
									WHERE Rpt_Level = (@Rpt_Level + 1)
									AND Scheme_Id IN 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK) 
										INNER JOIN 
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID 
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Claim'
											GROUP BY Emp_ID 
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND Type = 'Claim'
									) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')) 
									
									IF @App_Emp_ID = 0  AND @Is_Rm = 1 AND @Rpt_Level = 0
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) 
											INNER JOIN 
											(
												SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID												
												FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
												GROUP by Emp_ID
											) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
											WHERE ERD.Emp_ID = @Emp_ID
										END
									ELSE IF @App_Emp_ID = 0 AND @Is_Bm = 1 
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_MANAGERS WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END
								END
						END
					IF @Is_Manager_CC = 1
						BEGIN
							IF @Module_Name = 'Travel Application' AND @Final_Approval = 0 OR @Module_Name = 'Claim Application' AND @Final_Approval = 0 OR @Module_Name = 'Travel Settlement Application' AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END
						END	
					ELSE IF @To_Manager=1 
						BEGIN		
							IF @Module_Name = 'Travel Application' AND @Final_Approval = 0 OR @Module_Name = 'Claim Application' AND @Final_Approval = 0 OR @Module_Name = 'Travel Settlement Application' AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_To
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END
						END
					ELSE
						BEGIN
							IF @Module_Name = 'Travel Application' AND @Final_Approval = 0 OR @Module_Name = 'Claim Application' AND @Final_Approval = 0 OR @Module_Name = 'Travel Settlement Application' AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_To
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END
							END
					IF (@Module_Name = 'Change Request Application' OR @Module_Name = 'Change Request Approval') AND @Final_Approval = 0
						BEGIN
							IF EXISTS 
									(
										SELECT App_Emp_ID 
										FROM T0050_Scheme_Detail WITH (NOLOCK)
										WHERE Rpt_Level = (@Rpt_Level + 1)
										AND Scheme_Id = 
										(
											SELECT QES.Scheme_ID  
											FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
											INNER JOIN
											(
												SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
												FROM T0095_EMP_SCHEME WITH (NOLOCK)
												WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Change Request'
												GROUP BY Emp_ID
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Change Request'
										) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#'))
									)
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID ,@Is_Rm = Is_RM,@Is_Bm = Is_BM 
									FROM T0050_Scheme_Detail WITH (NOLOCK)
									WHERE Rpt_Level = (@Rpt_Level + 1)
									AND Scheme_Id = 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
										INNER JOIN 
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID 
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Change Request'
											GROUP BY Emp_ID 
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND Type = 'Change Request'
									) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')) 
																	
									IF @App_Emp_ID = 0 AND @Is_Rm = 1 AND @Rpt_Level = 0
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID 
												FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
												GROUP BY Emp_ID 
											) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
											WHERE ERD.Emp_ID = @Emp_ID
										END
									ELSE IF @App_Emp_ID = 0 AND @Is_Bm =1 
										BEGIN							
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_MANAGERS  WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END 												
								END
						END
						
						IF @Is_Manager_CC = 1
							BEGIN
								IF (@Module_Name = 'Change Request Application' OR @Module_Name = 'Change Request Approval') AND @Final_Approval = 0
									BEGIN
										INSERT INTO #Temp_CC
										SELECT DISTINCT(EIM.DeviceID) 
										FROM T0080_EMP_MASTER EM WITH (NOLOCK)
										INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
										WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
									END
							END				
						ELSE
							BEGIN
								IF (@Module_Name = 'Change Request Application' OR @Module_Name = 'Change Request Approval') AND @Final_Approval = 0
									BEGIN									
										INSERT INTO #Temp_To
										SELECT DISTINCT(EIM.DeviceID) 
										FROM T0080_EMP_MASTER EM WITH (NOLOCK)
										INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
										WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
									END
							END
					IF (@Module_Name = 'Reimbursement\Claim Application' OR @Module_Name = 'Reimbursement\Claim Approval') AND @Final_Approval = 0
						BEGIN
							IF EXISTS 
									(
										SELECT App_Emp_ID 
										FROM T0050_Scheme_Detail WITH (NOLOCK)
										WHERE Rpt_Level = (@Rpt_Level + 1)
										AND Scheme_Id = 
										(
											SELECT QES.Scheme_ID 
											FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID 
												FROM T0095_EMP_SCHEME WITH (NOLOCK)
												WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Reimbursement'
												GROUP BY Emp_ID 
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND Type = 'Reimbursement'
										) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#'))
									)
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID , @Is_Rm = Is_RM ,@Is_Bm = Is_BM 
									FROM T0050_Scheme_Detail  WITH (NOLOCK)
									WHERE Rpt_Level = (@Rpt_Level + 1)
									AND Scheme_Id = 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES  WITH (NOLOCK)
										INNER JOIN 
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID 
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Reimbursement'
											GROUP BY Emp_ID 
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND Type = 'Reimbursement'
									) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')) 
																	
									IF @App_Emp_ID = 0 AND @is_Rm = 1 AND @Rpt_Level = 0
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM T0090_EMP_REPORTING_DETAIL ERD  WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
												FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
												GROUP BY Emp_ID
											) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
											WHERE ERD.Emp_ID = @Emp_ID
										END
									ELSE IF @App_Emp_ID = 0 AND @Is_Bm =1 
										BEGIN							
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_MANAGERS WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END 
								END
						END
						
					IF @Is_Manager_CC = 1
						BEGIN
							IF (@Module_Name = 'Reimbursement\Claim Application' OR @Module_Name = 'Reimbursement\Claim Approval') AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END
						END				
					ELSE
						BEGIN
							IF (@Module_Name = 'Reimbursement\Claim Application' OR @Module_Name = 'Reimbursement\Claim Approval') AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_To
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT emp_id FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END
							END
								
					IF (@Module_Name = 'KPI Manager Approved' OR @Module_Name = 'KPI Manager Approved') AND @Final_Approval = 0
						BEGIN
							IF EXISTS 
									(
										SELECT App_Emp_ID 
										FROM T0050_Scheme_Detail WITH (NOLOCK)
										WHERE Rpt_Level = (@Rpt_Level + 1)
										AND Scheme_Id = 
										(
											SELECT QES.Scheme_ID 
											FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
											INNER JOIN
											(
												SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID 
												FROM T0095_EMP_SCHEME WITH (NOLOCK)
												WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'KPI Manager Approved'
												GROUP BY Emp_ID 
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND Type = 'KPI Manager Approved'
										) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#'))
									)
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID , @Is_Rm = Is_RM ,@Is_Bm = Is_BM 
									FROM T0050_Scheme_Detail WITH (NOLOCK) 
									WHERE Rpt_Level = (@Rpt_Level + 1)
									AND Scheme_Id = 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
										INNER JOIN
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'KPI Manager Approved'
											GROUP BY Emp_ID 
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND Type = 'KPI Manager Approved'
									) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')) 
																			
									IF @App_Emp_ID = 0 AND @Is_Rm = 1 AND @Rpt_Level = 0
										BEGIN												
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID
										END
									ELSE IF @App_Emp_ID = 0 AND @Is_Bm = 1 
										BEGIN							
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_MANAGERS WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END 
								END
						END
						
					IF @Is_Manager_CC = 1
						BEGIN
							IF (@Module_Name = 'KPI Manager Approved' OR @Module_Name = 'KPI Manager Approved') AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								End
						END
					ELSE
						BEGIN
							IF (@Module_Name = 'KPI Manager Approved' OR @Module_Name = 'KPI Manager Approved') AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_To
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END
						END
								
					IF (@Module_Name = 'KPIRating Manager Approved' OR @Module_Name = 'KPIRating Manager Approved') AND @Final_Approval = 0
						BEGIN
							IF EXISTS 
									(
										SELECT App_Emp_ID 
										FROM T0050_Scheme_Detail WITH (NOLOCK) 
										WHERE Rpt_Level = (@Rpt_Level + 1)
										AND Scheme_Id = 
										(
											SELECT QES.Scheme_ID 
											FROM T0095_EMP_SCHEME QES  WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID 
												FROM T0095_EMP_SCHEME WITH (NOLOCK)
												WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'KPIRating Manager Approved'
												GROUP BY Emp_ID 
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND Type = 'KPIRating Manager Approved'
										) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#'))
									)
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID ,@Is_Rm = Is_RM ,@Is_Bm = Is_BM 
									FROM T0050_Scheme_Detail WITH (NOLOCK)
									WHERE Rpt_Level = (@Rpt_Level + 1)
									AND Scheme_Id = 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK) 
										INNER JOIN 
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'KPIRating Manager Approved'
											GROUP BY Emp_ID 
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND Type = 'KPIRating Manager Approved'
									) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')) 
																			
									IF @App_Emp_ID = 0 AND @Is_Rm = 1 AND @Rpt_Level = 0
										BEGIN 
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
											WHERE Emp_ID = @Emp_ID
										END
									ELSE IF @App_Emp_ID = 0 AND @Is_Bm =1 
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_MANAGERS  WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END
								END
						END
						
					IF @Is_Manager_CC = 1
						BEGIN
							IF (@Module_Name = 'KPIRating Manager Approved' OR @Module_Name = 'KPIRating Manager Approved') AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER  EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END
						END				
					ELSE
						BEGIN
							IF (@Module_Name = 'KPIRating Manager Approved' OR @Module_Name = 'KPIRating Manager Approved') AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_To
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID from #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END

						END
					
					IF (@Module_Name = 'Recruitment Request' OR @Module_Name = 'Recruitment Request') AND @Final_Approval = 0
						BEGIN
							IF EXISTS 
									(
										SELECT App_Emp_ID 
										FROM T0050_Scheme_Detail WITH (NOLOCK)
										WHERE Rpt_Level = (@Rpt_Level + 1)
										AND Scheme_Id = 
										(
											SELECT QES.Scheme_ID 
											FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
												FROM T0095_EMP_SCHEME WITH (NOLOCK)
												WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Recruitment Request'
												GROUP BY Emp_ID 
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND Type = 'Recruitment Request'
										) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#'))
									)
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID ,@Is_Rm = Is_RM ,@Is_Bm = Is_BM ,@Is_HOD = Is_HOD,@Is_Hr=Is_HR 
									FROM T0050_Scheme_Detail WITH (NOLOCK)
									WHERE Rpt_Level = (@Rpt_Level + 1)
									AND Scheme_Id = 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
										INNER JOIN 
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID 
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Recruitment Request'
											GROUP BY Emp_ID 
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND Type = 'Recruitment Request'
									) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')) 
										
									If @App_Emp_ID = 0 AND @Is_Rm = 1 AND @Rpt_Level = 0
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
											WHERE Emp_ID = @Emp_ID
										END
									ELSE IF @App_Emp_ID = 0 AND @Is_Bm = 1 
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_MANAGERS WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END 
									ELSE IF @App_Emp_ID = 0 AND @Is_HOD = 1
										BEGIN 
											INSERT INTO #Rpt_branch_manager																				
											SELECT Emp_id 
											FROM T0095_Department_Manager WITH (NOLOCK) 
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_Department_Manager WITH (NOLOCK)
												WHERE Dept_ID = @Emp_Dept AND Effective_Date <= GETDATE()
											) AND Dept_Id = @Emp_Dept										
										END	
									ELSE IF @App_Emp_ID = 0 AND @Is_HR = 1
										BEGIN 
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0011_LOGIN WITH (NOLOCK)
											WHERE Is_Active =1 AND 
											CAST(@emp_branch AS VARCHAR(18)) IN (CASE Branch_id_multi WHEN '0' THEN Branch_id_multi ELSE (SELECT data FROM dbo.Split(Branch_id_multi,'#')) END ) 
											SET @hremail = 1											
										END				
								END
						END
					
					IF @Is_Manager_CC = 1
						BEGIN 
							IF @hremail = 1
								BEGIN								
									If (@Module_Name = 'Recruitment Request' OR @Module_Name = 'Recruitment Request') AND @Final_Approval = 0
										BEGIN
											INSERT INTO #Temp_CC
											SELECT DISTINCT(EIM.DeviceID) 
											FROM T0080_EMP_MASTER EM WITH (NOLOCK)
											INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
											WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
												
											INSERT INTO #Temp_CC
											SELECT DISTINCT(EIM.DeviceID) 
											FROM T0011_LOGIN LM WITH (NOLOCK)
											INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON LM.Emp_ID = EIM.Emp_ID
											WHERE LM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager) AND EIM.Is_Active = 1
										END
								END
							ELSE								
								BEGIN								
									IF (@Module_Name = 'Recruitment Request' OR @Module_Name = 'Recruitment Request') AND @Final_Approval = 0
										BEGIN
											INSERT INTO #Temp_CC
											SELECT DISTINCT(EIM.DeviceID) 
											FROM T0080_EMP_MASTER EM WITH (NOLOCK)
											INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
											WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
										END
								END
						END				
					ELSE
						BEGIN 
							IF @hremail = 1
								BEGIN
									IF (@Module_Name = 'Recruitment Request' Or @Module_Name = 'Recruitment Request') And @Final_Approval = 0
										BEGIN
											INSERT INTO #Temp_To
											SELECT DISTINCT(EIM.DeviceID) 
											FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
											INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
											WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
											
											INSERT INTO #Temp_CC
											SELECT DISTINCT(EIM.DeviceID) 
											FROM T0011_LOGIN LM WITH (NOLOCK)
											INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON LM.Emp_ID = EIM.Emp_ID
											WHERE LM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)  AND EIM.Is_Active = 1
										END
								END
							ELSE
								BEGIN
								IF (@Module_Name = 'Recruitment Request' OR @Module_Name = 'Recruitment Request') AND @Final_Approval = 0
									BEGIN
										INSERT INTO #Temp_To
										SELECT DISTINCT(EIM.DeviceID) 
										FROM T0080_EMP_MASTER EM WITH (NOLOCK)
										INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
										WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
									END
								END
						END
								
					IF (@Module_Name = 'Candidate Approval Level' OR @Module_Name = 'Candidate Approval Level') AND @Final_Approval = 0
						BEGIN
							IF EXISTS 
									(
										SELECT App_Emp_ID 
										FROM T0050_Scheme_Detail WITH (NOLOCK)
										WHERE Rpt_Level = (@Rpt_Level + 1)
										AND Scheme_Id = 
										(
											SELECT QES.Scheme_ID 
											FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
												FROM T0095_EMP_SCHEME WITH (NOLOCK)
												WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Candidate Approval'
												GROUP BY Emp_ID 
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date And Type = 'Candidate Approval'
										) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#'))
									)
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID , @Is_Rm = Is_RM ,@Is_Bm = Is_BM,@Is_hod = Is_HOD,@Is_hr = Is_HR 
									FROM T0050_Scheme_Detail WITH (NOLOCK)
									WHERE Rpt_Level = (@Rpt_Level + 1)
									AND Scheme_Id = 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
										INNER JOIN 
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Candidate Approval'
											GROUP BY Emp_ID 
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND Type = 'Candidate Approval'
									) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')) 
																			
									IF @App_Emp_ID = 0  AND @Is_Rm = 1 AND @Rpt_Level = 0
										BEGIN												
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM  T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
											where Emp_ID = @Emp_ID
										END
									ELSE IF @App_Emp_ID = 0 AND @Is_Bm = 1 
										BEGIN							
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_MANAGERS WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END 
									ELSE IF @App_Emp_ID = 0 AND @Is_HOD =1
										BEGIN 
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_Department_Manager WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_Department_Manager WITH (NOLOCK)
												WHERE Dept_ID = @Emp_Dept AND Effective_Date <= GETDATE()
											) AND Dept_Id = @Emp_Dept										
										END	
									ELSE IF @App_Emp_ID = 0 AND @Is_HR = 1
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0011_LOGIN WITH (NOLOCK)
											WHERE Is_Active =1 AND 
											CAST(@emp_branch AS VARCHAR(18)) IN (CASE Branch_id_multi WHEN '0' THEN Branch_id_multi ELSE (SELECT data FROM dbo.Split(Branch_id_multi,'#')) END )
											SET @hremail =1
										END
								END
						END
						
					IF @Is_Manager_CC = 1
						BEGIN
							IF @hremail = 1
								BEGIN
									IF (@Module_Name = 'Candidate Approval Level' OR @Module_Name = 'Candidate Approval Level') AND @Final_Approval = 0
										BEGIN
											INSERT INTO #Temp_CC
											SELECT DISTINCT(EIM.DeviceID) 
											FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
											INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
											WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
											
											INSERT INTO #Temp_CC
											SELECT DISTINCT(EIM.DeviceID) 
											FROM T0011_LOGIN LM WITH (NOLOCK)
											INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON LM.Emp_ID = EIM.Emp_ID
											WHERE LM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager) AND EIM.Is_Active = 1
										END
								END	
							ELSE
								BEGIN
									IF (@Module_Name = 'Candidate Approval Level' OR @Module_Name = 'Candidate Approval Level') AND @Final_Approval = 0
										BEGIN
											INSERT INTO #Temp_CC
											SELECT DISTINCT(EIM.DeviceID) 
											FROM T0080_EMP_MASTER EM WITH (NOLOCK)
											INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
											WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
										END
								END
						END					
					ELSE
						BEGIN
							IF @hremail = 1
								BEGIN
									IF (@Module_Name = 'Candidate Approval Level' OR @Module_Name = 'Candidate Approval Level') AND @Final_Approval = 0
										BEGIN
											INSERT INTO #Temp_To
											SELECT DISTINCT(EIM.DeviceID) 
											FROM T0080_EMP_MASTER EM WITH (NOLOCK)
											INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
											WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
											
											INSERT INTO #Temp_CC
											SELECT DISTINCT(EIM.DeviceID) 
											FROM T0011_LOGIN LM WITH (NOLOCK) 
											INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON LM.Emp_ID = EIM.Emp_ID
											WHERE LM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager) AND EIM.Is_Active = 1
										END
								END
							ELSE
								BEGIN
									IF (@Module_Name = 'Candidate Approval Level' Or @Module_Name = 'Candidate Approval Level') And @Final_Approval = 0
										BEGIN
											INSERT INTO #Temp_To
											SELECT DISTINCT(EIM.DeviceID) 
											FROM T0080_EMP_MASTER EM WITH (NOLOCK)
											INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
											WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
										END
								END					
						END
				END
				IF (@Module_Name = 'Pre-CompOff Application' OR @Module_Name = 'Pre-CompOff Approval') AND @Final_Approval = 0
					BEGIN
						IF EXISTS 
								(
									SELECT App_Emp_ID 
									FROM T0050_Scheme_Detail WITH (NOLOCK)
									WHERE Rpt_Level = (@Rpt_Level + 1)
									AND Scheme_Id = 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
										INNER JOIN 
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID And Type = 'Pre-CompOff'
											GROUP BY Emp_ID 
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND Type = 'Pre-CompOff'
									) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18,0)) FROM dbo.Split(Leave, '#'))
								)
							BEGIN
								SELECT @App_Emp_ID = App_Emp_ID,@Is_Rm = Is_RM,@Is_Bm = Is_BM 
								FROM T0050_Scheme_Detail WITH (NOLOCK)
								WHERE Rpt_Level = (@Rpt_Level + 1)
								AND Scheme_Id = 
								(
									SELECT QES.Scheme_ID 
									FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
									INNER JOIN 
									(
										SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
										FROM T0095_EMP_SCHEME WITH (NOLOCK)
										WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Pre-CompOff'
										GROUP BY Emp_ID
									) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND Type = 'Pre-CompOff'
								) AND @Leave_ID IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')) 
												
										
								IF @App_Emp_ID = 0 AND @Is_Rm = 1 AND @Rpt_Level = 0
									BEGIN
										INSERT INTO #Rpt_branch_manager
										SELECT R_Emp_ID 
										FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
										INNER JOIN 
										(
											SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
											FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
											WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
											GROUP BY Emp_ID
										) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
										WHERE ERD.Emp_ID = @Emp_ID
									END
								ELSE IF @App_Emp_ID = 0 AND @Is_Bm = 1 
									BEGIN					
										INSERT INTO #Rpt_branch_manager
										SELECT Emp_id 
										FROM T0095_MANAGERS WITH (NOLOCK) 
										WHERE Effective_Date = 
										(
											SELECT MAX(Effective_Date) 
											FROM T0095_MANAGERS WITH (NOLOCK)
											WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
										) AND branch_id = @emp_branch
									END 
							END
					END
						
					IF @Is_Manager_CC = 1
						BEGIN
							IF (@Module_Name = 'Pre-CompOff Application' OR @Module_Name = 'Pre-CompOff Approval') AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID)
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END
						END				
					ELSE
						BEGIN
							IF (@Module_Name = 'Pre-CompOff Application' Or @Module_Name = 'Pre-CompOff Approval') And @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_To
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END
						END
					
					IF (@Module_Name = 'Exit Application' OR @Module_Name = 'Exit Approval') AND @Final_Approval = 0
						BEGIN
							IF EXISTS 
									(
										SELECT App_Emp_ID 
										FROM T0050_Scheme_Detail WITH (NOLOCK)
										WHERE Rpt_Level = (@Rpt_Level + 1)
										AND Scheme_Id = 
										(
											SELECT QES.Scheme_ID 
											FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
												FROM T0095_EMP_SCHEME WITH (NOLOCK)
												WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Exit'
												GROUP BY Emp_ID 
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND Type = 'Exit'
										)
									)
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID ,@Is_Rm = Is_RM ,@Is_Bm = Is_BM 
									FROM T0050_Scheme_Detail WITH (NOLOCK)
									WHERE Rpt_Level = (@Rpt_Level + 1)
									AND Scheme_Id = 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
										INNER JOIN 
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Exit'
											GROUP BY Emp_ID
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND Type = 'Exit'
									)
										
									IF @App_Emp_ID = 0 AND @Is_Rm = 1 AND @Rpt_Level = 0
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
												FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
												GROUP BY Emp_ID
											) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
											WHERE ERD.Emp_ID = @Emp_ID
										END
									ELSE IF @App_Emp_ID = 0 AND @Is_Bm = 1 
										BEGIN					
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_MANAGERS WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END 
								END
						END
						
						IF @Is_Manager_CC = 1
							BEGIN
								IF (@Module_Name = 'Exit Application' OR @Module_Name = 'Exit Approval') AND @Final_Approval = 0
									BEGIN
										INSERT INTO #Temp_CC
										SELECT DISTINCT(EIM.DeviceID) 
										FROM T0080_EMP_MASTER EM WITH (NOLOCK)
										INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
										WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
									END
							END				
						ELSE
							BEGIN
								IF (@Module_Name = 'Exit Application' or @Module_Name = 'Exit Approval') And @Final_Approval = 0
									BEGIN
										INSERT INTO #Temp_To
										SELECT DISTINCT(EIM.DeviceID) 
										FROM T0080_EMP_MASTER EM WITH (NOLOCK)
										INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
										WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
									END
							END
						
					IF (@Module_Name = 'Employee Probation' OR @Module_Name = 'Employee Training') AND @Final_Approval = 0
						BEGIN
							DECLARE @Probation_Type VARCHAR(50)
							SET @Probation_Type = ''
							
							IF @Module_Name = 'Employee Probation' 
								SET @Probation_Type  = 'Probation'
							ELSE
								SET @Probation_Type  = 'Trainee'
							
							IF EXISTS 
									( 
										SELECT App_Emp_ID 
										FROM T0050_Scheme_Detail WITH (NOLOCK) 
										WHERE Rpt_Level = (@Rpt_Level + 1)
										AND Scheme_Id = 
										(
											SELECT QES.Scheme_ID 
											FROM T0095_EMP_SCHEME QES WITH (NOLOCK) 
											INNER JOIN 
											(
												SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
												FROM T0095_EMP_SCHEME WITH (NOLOCK)
												WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND TYPE = @Probation_Type 
												GROUP BY Emp_ID
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND TYPE = @Probation_Type
										) 
									)
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID ,@Is_Rm = Is_RM ,@Is_Bm = Is_BM,@IS_PRM=IS_PRM 
									FROM T0050_Scheme_Detail WITH (NOLOCK)
									WHERE Rpt_Level = (@Rpt_Level + 1)
									AND Scheme_Id = 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
										INNER JOIN 
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND TYPE = @Probation_Type 
											GROUP BY Emp_ID
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND TYPE = @Probation_Type
									)
									
									IF @App_Emp_ID = 0 AND @Is_Rm = 1 AND @Rpt_Level = 0
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
												FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
												GROUP BY Emp_ID 
											) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
											WHERE ERD.Emp_ID = @Emp_ID
										END
									ELSE IF @App_Emp_ID = 0 AND @Is_Bm = 1 
										BEGIN							
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_MANAGERS WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END 
									ELSE IF @App_Emp_ID = 0 AND @IS_PRM = 1 
										BEGIN							
											INSERT INTO #Rpt_branch_manager
											SELECT Manager_Probation 
											FROM T0080_EMP_MASTER WITH (NOLOCK) 
											WHERE Emp_ID = @Emp_ID
										END 	
								END
								
								IF @Is_Manager_CC = 1
									BEGIN
										INSERT INTO #Temp_CC
										SELECT DISTINCT(EIM.DeviceID) 
										FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
										INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
										WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
									END				
								ELSE
									BEGIN
										INSERT INTO #Temp_To
										SELECT DISTINCT(EIM.DeviceID) 
										FROM T0080_EMP_MASTER EM WITH (NOLOCK)
										INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
										WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
									END							
						END
					
					IF (@Module_Name = 'GatePass') AND @Final_Approval = 0
						BEGIN
							IF EXISTS 
									(
										SELECT 1 FROM T0050_Scheme_Detail WITH (NOLOCK) 
										WHERE Rpt_Level = (@Rpt_Level + 1)
										AND Scheme_Id = 
										(
											SELECT QES.Scheme_ID 
											FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
												FROM T0095_EMP_SCHEME WITH (NOLOCK)
												WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND TYPE = 'GatePass'
												GROUP BY Emp_ID
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND TYPE = 'GatePass'
										)
									)
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID ,@Is_Rm = Is_RM ,@Is_Bm = Is_BM 
									FROM T0050_Scheme_Detail WITH (NOLOCK) 
									WHERE Rpt_Level = (@Rpt_Level + 1) AND 
									Scheme_Id = 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK)
										INNER JOIN 
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
											FROM T0095_EMP_SCHEME WITH (NOLOCK)
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND TYPE = 'GatePass'
											GROUP BY Emp_ID
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND TYPE = 'GatePass' 
									)
															
									IF @App_Emp_ID = 0 AND @Is_Rm = 1 AND @Rpt_Level = 0
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
												FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
												GROUP BY Emp_ID
											) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
											WHERE ERD.Emp_ID = @Emp_ID
										END
									ELSE IF @App_Emp_ID = 0 AND @Is_Bm =1 
										BEGIN					
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id 
											FROM T0095_MANAGERS WITH (NOLOCK) 
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS  WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END 
									END
							
							IF @Is_Manager_CC = 1
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END				
							ELSE
								BEGIN
									INSERT INTO #Temp_To
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END
						END
					
					IF (@Module_Name = 'Optional Holiday Application' OR @Module_Name = 'Optional Holiday Approval') AND @Final_Approval = 0
						BEGIN
							INSERT INTO #Rpt_branch_manager
							SELECT R_Emp_ID 
							FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
							INNER JOIN
							(
								SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
								FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
								WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
								GROUP BY Emp_ID 
							) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
							WHERE ERD.Emp_ID = @Emp_ID
						END
					IF (@Is_Manager_CC = 1 OR @To_Manager = 1)
						BEGIN
							IF (@Module_Name = 'Optional Holiday Application' OR @Module_Name = 'Optional Holiday Approval') AND @Final_Approval = 0
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK)
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								End
						End				
			
					IF (@Module_Name = 'Employee Increment Application' OR @Module_Name = 'Employee Increment Approval') AND @Final_Approval = 0
						BEGIN
							IF EXISTS 
									(
										SELECT 1 FROM T0050_Scheme_Detail WITH (NOLOCK)
										WHERE Rpt_Level = (@Rpt_Level + 1)
										AND Scheme_Id = 
										(
											SELECT QES.Scheme_ID 
											FROM T0095_EMP_SCHEME QES WITH (NOLOCK) 
											INNER JOIN
											(
												SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
												FROM T0095_EMP_SCHEME WITH (NOLOCK)
												WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND TYPE = 'Increment'
												GROUP BY Emp_ID
											) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND TYPE = 'Increment'
										)
									)
								BEGIN
									SELECT @App_Emp_ID = App_Emp_ID ,@Is_Rm = Is_RM ,@Is_Bm = Is_BM 
									FROM T0050_Scheme_Detail WITH (NOLOCK) 
									WHERE Rpt_Level = (@Rpt_Level + 1) 
									AND Scheme_Id = 
									(
										SELECT QES.Scheme_ID 
										FROM T0095_EMP_SCHEME QES WITH (NOLOCK) 
										INNER JOIN 
										(
											SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID 
											FROM T0095_EMP_SCHEME WITH (NOLOCK) 
											WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND TYPE = 'Increment'
											GROUP BY Emp_ID
										) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND TYPE = 'Increment' 
									)
															
									IF @App_Emp_ID = 0 AND @Is_Rm = 1 AND @Rpt_Level = 0
										BEGIN
											INSERT INTO #Rpt_branch_manager
											SELECT R_Emp_ID 
											FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
											INNER JOIN 
											(
												SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
												FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												WHERE Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
												GROUP BY Emp_ID 
											) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
											WHERE ERD.Emp_ID = @Emp_ID
										END
									ELSE IF @App_Emp_ID = 0  AND @is_Bm =1 
										BEGIN					
											INSERT INTO #Rpt_branch_manager
											SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
											WHERE Effective_Date = 
											(
												SELECT MAX(Effective_Date) 
												FROM T0095_MANAGERS WITH (NOLOCK)
												WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
											) AND branch_id = @emp_branch
										END 
									END
							
							
							IF @Is_Manager_CC = 1
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END				
							ELSE
								BEGIN
									INSERT INTO #Temp_To
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
									WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
								END
						END
			
					IF (@Module_Name = 'Weekoff Request Application') 
						BEGIN
							IF @Is_Manager_CC = 1
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
									WHERE EM.Emp_ID = @App_Emp_ID AND EIM.Is_Active = 1
								END				
							ELSE
								BEGIN
									INSERT INTO #Temp_To
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
									WHERE EM.Emp_ID = @App_Emp_ID AND EIM.Is_Active = 1
								END
						END
			
				CREATE TABLE #Email_Branch
				(
					Login_ID numeric(18,0),
					Branch_Id numeric(18,0)
				 )
				DECLARE @Branch_ID_Multi NVARCHAR(MAX)
				SET @Branch_ID_Multi = ''
				DECLARE @Login_Id NUMERIC(18,0)
				SET @Login_Id = 0
				
			IF @Rpt_Level = 0 OR @Final_Approval = 1
				BEGIN
					IF @To_Hr = 1
						BEGIN
							DECLARE CUREMAILHR CURSOR FOR 
							SELECT ISNULL(Branch_ID_multi,0) AS 'Branch_ID_multi',Login_Id 
							FROM T0011_LOGIN WITH (NOLOCK) 
							WHERE Cmp_ID = @Cmp_ID AND Is_HR = 1 AND Is_Active = 1
								
							OPEN CUREMAILHR
							FETCH NEXT FROM CUREMAILHR INTO @Branch_ID_Multi,@Login_Id
							
							WHILE @@FETCH_STATUS = 0
								BEGIN	
									INSERT INTO #Email_Branch
									SELECT @Login_ID,data
									FROM dbo.Split(@Branch_ID_Multi,',')
									WHERE (data = @emp_branch or data = 0) 
										   
									FETCH NEXT FROM CUREMAILHR INTO @Branch_ID_Multi,@Login_Id
								END
							CLOSE CUREMAILHR
							DEALLOCATE CUREMAILHR
						
							IF @Is_HR_CC = 1
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID) 
									FROM  T0011_LOGIN L WITH (NOLOCK) 
									INNER JOIN #Email_Branch EB ON EB.Login_ID = L.Login_ID 
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON L.Emp_ID = EIM.Emp_ID 
									WHERE L.Cmp_ID = @Cmp_ID AND Is_HR = 1 AND L.Is_Active = 1  AND (EB.Branch_ID = @emp_branch OR EB.Branch_ID = 0) AND EIM.Is_Active = 1 
								END
							ELSE
								BEGIN
									INSERT INTO #Temp_To
									SELECT DISTINCT(EIM.DeviceID)  
									FROM  T0011_LOGIN L WITH (NOLOCK) 
									INNER JOIN #Email_Branch EB ON EB.Login_ID = L.Login_ID 
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON L.Emp_ID = EIM.Emp_ID 
									WHERE L.Cmp_ID = @Cmp_ID AND Is_HR = 1 AND L.Is_Active = 1 AND (EB.Branch_ID = @emp_branch OR EB.Branch_ID = 0) AND EIM.Is_Active = 1
								END
						END
					SET @Branch_ID_Multi = ''
					DELETE FROM #Email_Branch
						
					IF @To_Account = 1	
						BEGIN
							DECLARE CUREMAILACC CURSOR FOR 
							SELECT ISNULL(Branch_ID_multi,0) AS 'Branch_ID_multi',Login_Id 
							FROM T0011_LOGIN WITH (NOLOCK) 
							WHERE Cmp_ID = @Cmp_ID AND Is_Accou = 1 AND Is_Active =1
								
							OPEN CUREMAILACC
							FETCH NEXT FROM CUREMAILACC INTO @Branch_ID_Multi,@Login_Id
							WHILE @@FETCH_STATUS = 0
								BEGIN
									INSERT INTO #Email_Branch
									SELECT @Login_ID,data
									FROM dbo.Split(@Branch_ID_Multi,',')
									WHERE (data = @emp_branch OR data = 0) 
									FETCH NEXT FROM CUREMAILACC INTO @Branch_ID_Multi,@Login_Id
								END
							CLOSE CUREMAILACC
							DEALLOCATE CUREMAILACC
							
							IF @Is_Account_CC = 1
								BEGIN
									INSERT INTO #Temp_CC
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0011_LOGIN L WITH (NOLOCK) 
									INNER JOIN #Email_Branch EB ON EB.Login_ID = L.Login_ID 
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON L.Emp_ID = EIM.Emp_ID 
									WHERE L.Cmp_ID = @Cmp_ID AND Is_Accou = 1 AND L.Is_Active = 1 AND (EB.Branch_ID = @emp_branch OR EB.Branch_ID = 0) AND EIM.Is_Active = 1
								END
							ELSE
								BEGIN
									INSERT INTO #Temp_To
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0011_LOGIN L WITH (NOLOCK) 
									INNER JOIN #Email_Branch EB ON EB.Login_ID = L.Login_ID 
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON L.Emp_ID = EIM.Emp_ID 
									WHERE L.Cmp_ID = @Cmp_ID AND Is_Accou = 1 AND L.Is_Active = 1 AND (EB.Branch_ID = @emp_branch OR EB.Branch_ID = 0) AND EIM.Is_Active = 1
								END
						END
						
						SET @Branch_ID_Multi = ''
						DELETE FROM #Email_Branch
						
						DECLARE CUREMAILHELPDESK CURSOR FOR 
						SELECT ISNULL(Branch_ID_multi,0) AS 'Branch_ID_multi',Login_Id 
						FROM T0011_LOGIN WITH (NOLOCK) 
						WHERE Cmp_ID = @Cmp_ID AND Travel_Help_Desk = 1 AND Is_Active = 1
								
						OPEN CUREMAILHELPDESK
						FETCH NEXT FROM CUREMAILHELPDESK INTO @Branch_ID_Multi,@Login_Id
						WHILE @@FETCH_STATUS = 0
							BEGIN
								INSERT INTO #Email_Branch
								SELECT @Login_ID,data
								FROM dbo.Split(@Branch_ID_Multi,',')
								WHERE (data = @emp_branch or data = 0) 
										   
								FETCH NEXT FROM CUREMAILHELPDESK INTO @Branch_ID_Multi,@Login_Id
							END
						CLOSE CUREMAILHELPDESK
						DEALLOCATE CUREMAILHELPDESK
							
						INSERT INTO #Temp_CC
						SELECT DISTINCT(EIM.DeviceID) 
						FROM T0011_LOGIN L WITH (NOLOCK) 
						INNER JOIN #Email_Branch EB ON EB.Login_ID = L.Login_ID 
						INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON L.Emp_ID = EIM.Emp_ID 
						WHERE L.Cmp_ID = @Cmp_ID AND Travel_Help_Desk = 1 AND L.Is_Active = 1 AND (EB.Branch_ID = @emp_branch OR EB.Branch_ID = 0) AND EIM.Is_Active = 1
				END
			
			IF @Other_Email <> ''
				BEGIN
					INSERT INTO #Temp_CC
					SELECT @Other_Email
				END
					
			IF (@Module_Name = 'Leave Application' OR @Module_Name = 'Leave Approval'  )
				BEGIN
					SELECT @scheme_id = QES.Scheme_ID 
					FROM T0095_EMP_SCHEME QES WITH (NOLOCK) 
					INNER JOIN T0050_Scheme_Detail T1 WITH (NOLOCK) ON QES.Scheme_ID = T1.Scheme_Id 
					INNER JOIN
					(
						SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID
						FROM T0095_EMP_SCHEME WITH (NOLOCK)
						WHERE Effective_Date <= GETDATE() AND Emp_ID = @Emp_ID AND Type = 'Leave'
						GROUP BY Emp_ID
					) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.Effective_Date = QES.Effective_Date AND Type = 'Leave'
					AND @Leave_ID IN (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#'))
				END
			
			IF @Final_Approval = 1
				BEGIN
					IF @Flag = 1
						BEGIN
							IF @Module_Name = 'Travel Application' AND @Flag = 1
								BEGIN
									INSERT INTO #Temp_CC 
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0011_LOGIN LM WITH (NOLOCK) 
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON LM.Emp_ID = EIM.Emp_ID 
									WHERE LM.Cmp_ID = @Cmp_ID AND Travel_Help_Desk = 1 AND LM.Is_Active = 1 AND EIM.Is_Active = 1
								END
							IF @Module_Name = 'Change Request Approval' AND @Flag = 1 AND @Leave_ID = 18
								BEGIN
									SELECT DISTINCT(EIM.DeviceID)
									FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE EM.Emp_ID = @Emp_ID  AND EIM.Is_Active = 1
									
									UNION ALL
									
									SELECT DISTINCT(EIM.DeviceID) 
									FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
									INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
									WHERE EM.Emp_ID IN (SELECT App_Emp_ID FROM T0050_Scheme_Detail WITH (NOLOCK) WHERE Scheme_Id = @scheme_id AND not_mandatory = 1) AND EIM.Is_Active = 1
								END
							
							INSERT INTO #Temp_To
							SELECT DISTINCT(EIM.DeviceID) 
							FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
							INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
							WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE()+1) > GETDATE() AND EIM.Is_Active = 1
							
							UNION ALL
								
							SELECT DISTINCT(EIM.DeviceID) 
							FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
							INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
							WHERE EM.Emp_ID IN (SELECT App_Emp_ID FROM T0050_Scheme_Detail WITH (NOLOCK) WHERE Scheme_Id = @scheme_id AND not_mandatory = 1) AND ISNULL(Emp_Left_Date,GETDATE()+1) > GETDATE() AND EIM.Is_Active = 1
						END
					ELSE IF @Flag = 0
						BEGIN
							INSERT INTO #Temp_CC
							SELECT DISTINCT(EIM.DeviceID) 
							FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
							INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
							WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE()+1) > GETDATE() AND EIM.Is_Active = 1
						END
					ELSE IF @Flag = 2					
						BEGIN
							INSERT INTO #Temp_Emp
							SELECT DISTINCT(EIM.DeviceID)  
							FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
							INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
							WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE()+1) > GETDATE() AND EIM.Is_Active = 1
						END
				END
			ELSE IF (@Module_Name = 'Leave Application' AND @Flag = 2)
				BEGIN
					INSERT INTO #Temp_Emp
					SELECT DISTINCT(EIM.DeviceID) 
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
					
					UNION ALL
					
					SELECT DISTINCT(EIM.DeviceID)
					FROM T0080_EMP_MASTER EM WITH (NOLOCK)
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID IN (SELECT App_Emp_ID FROM T0050_Scheme_Detail WITH (NOLOCK) WHERE Scheme_Id = @scheme_id AND not_mandatory = 1) AND ISNULL(Emp_Left_Date,GETDATE()+1) > GETDATE() AND EIM.Is_Active = 1
				END
			ELSE IF (@Module_Name = 'Loan Application' AND @Flag = 2)
				BEGIN
					INSERT INTO #Temp_To
					SELECT DISTINCT(EIM.DeviceID) 
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END
			ELSE IF (@Module_Name = 'Attendance Regularization' AND @Flag = 2)
				BEGIN
					INSERT INTO #Temp_Emp
					SELECT DISTINCT(EIM.DeviceID) 
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END
			ELSE IF (@Module_Name = 'Reimbursement\Claim Application' AND @Flag = 2)
				BEGIN
					INSERT INTO #Temp_To
					SELECT DISTINCT(EIM.DeviceID)  
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID 
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END
			ELSE IF (@Module_Name = 'Travel Application' AND @Flag = 1 OR @Flag = 0)
				BEGIN
					INSERT INTO #Temp_To
					SELECT DISTINCT(EIM.DeviceID)   
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END
			ELSE IF (@Module_Name = 'Change Request Application' AND @Flag = 2 OR @flag = 0 )
				BEGIN
					INSERT INTO #Temp_Emp
					SELECT DISTINCT(EIM.DeviceID)  
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END
			ELSE IF (@Module_Name = 'Claim Application' AND @Flag = 1 OR @flag = 0 )
				BEGIN
					INSERT INTO #Temp_To
					SELECT DISTINCT(EIM.DeviceID) 
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END	
			ELSE IF (@Module_Name = 'Travel Settlement Application' AND @Flag = 1 OR @flag = 0 )
				BEGIN
					INSERT INTO #Temp_To
					SELECT DISTINCT(EIM.DeviceID)  
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END
			ELSE IF (@Module_Name = 'KPI Manager Approved' AND @Flag = 2 OR @flag = 0 )
				BEGIN
					INSERT INTO #Temp_Emp
					SELECT DISTINCT(EIM.DeviceID) 
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END
			ELSE IF (@Module_Name = 'KPIRating Manager Approved' AND @Flag = 2 OR @flag = 0 )
				BEGIN
					INSERT INTO #Temp_Emp
					SELECT DISTINCT(EIM.DeviceID) 
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END
			ELSE IF (@Module_Name = 'Recruitment Request' AND @Flag = 2 OR @flag = 0 )
				BEGIN
					INSERT INTO #Temp_Emp
					SELECT DISTINCT(EIM.DeviceID) 
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END
			ELSE IF (@Module_Name = 'Candidate Approval Level' AND @Flag = 2 OR @flag = 0 )
				BEGIN
					INSERT INTO #Temp_Emp
					SELECT DISTINCT(EIM.DeviceID) 
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END	
			ELSE IF (@Module_Name = 'Pre-CompOff Application' OR @Module_Name = 'Pre-CompOff Approval' AND @Flag = 2 OR @flag = 0 )
				BEGIN
					INSERT INTO #Temp_Emp
					SELECT DISTINCT(EIM.DeviceID) 
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END	
			ELSE IF (@Module_Name = 'Attendance Regularization Approve' AND (@Flag = 2 OR @flag = 0) AND (@Rpt_Level = 0 OR @Final_Approval = 1))
				BEGIN
					INSERT INTO #Temp_Emp
					SELECT DISTINCT(EIM.DeviceID) 
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END
			ELSE IF (@Module_Name = 'Employee Probation' OR @Module_Name = 'Employee Training') AND (@Flag = 2 OR @flag = 0)
				BEGIN
					INSERT INTO #Temp_To
					SELECT DISTINCT(EIM.DeviceID) 
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END
			ELSE IF (@Module_Name = 'GatePass' AND (@Flag = 2 OR @flag = 0)	)
				BEGIN
					INSERT INTO #Temp_Emp
					SELECT DISTINCT(EIM.DeviceID) 
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END
			ELSE IF (@Module_Name = 'Employee Increment Application' AND @Flag = 2)
				BEGIN
					INSERT INTO #Temp_Emp
					SELECT DISTINCT(EIM.DeviceID) 
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1	 			
				END
			ELSE IF (@Module_Name = 'Exit Approval' AND @Flag = 2)
				BEGIN
					INSERT INTO #Temp_Emp
					SELECT DISTINCT(EIM.DeviceID) 
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EIM.Is_Active = 1
				END
			IF (@Module_Name = 'Timesheet Application' OR @Module_Name = 'Timesheet Approval') AND @Final_Approval = 0
				BEGIN
					IF @Flag = 1
						BEGIN
							INSERT INTO #Temp_To 
							SELECT DISTINCT(EIM.DeviceID) 
							FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
							INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
							WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EM.Cmp_ID = @Cmp_ID AND EIM.Is_Active = 1
						END
					ELSE IF @Flag = 0
						BEGIN
							INSERT INTO #Temp_CC 
							SELECT DISTINCT(EIM.DeviceID) 
							FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
							INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
							WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EM.Cmp_ID = @Cmp_ID  AND EIM.Is_Active = 1
						END
					ELSE IF @Flag = 2
						BEGIN
							INSERT INTO #Temp_Emp 
							SELECT DISTINCT(EIM.DeviceID) 
							FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
							INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
							WHERE EM.Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND EM.Cmp_ID = @Cmp_ID AND EIM.Is_Active = 1
						END
				END
		
		IF EXISTS( SELECT 1 FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK) WHERE CMP_ID = @Cmp_ID AND GETDATE() >= From_date AND GETDATE() <= To_date   )
			BEGIN
				INSERT INTO #Temp_To
				SELECT DISTINCT(EIM.DeviceID) 
				FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO MR WITH (NOLOCK) 
				INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MR.Pass_To_Emp_id = EM.Emp_ID
				INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
				WHERE MR.Cmp_id = @Cmp_ID AND (GETDATE() BETWEEN From_date AND To_date )
				AND ( MR.Manger_Emp_id IN ( SELECT Emp_ID FROM #Rpt_branch_manager ) OR MR.Manger_Emp_id = @App_Emp_ID ) AND EIM.Is_Active = 1
			END
		IF @Module_Name = 'Pass Responsibility'
			BEGIN
				INSERT INTO #Temp_To
				SELECT DISTINCT(EIM.DeviceID)
				FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO MR WITH (NOLOCK) 
				INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MR.Pass_To_Emp_id = EM.Emp_ID
				INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
				WHERE MR.Cmp_id = @Cmp_ID AND (GETDATE() BETWEEN MR.From_date AND MR.To_date ) AND (MR.Manger_Emp_id = @Emp_ID )  AND EIM.Is_Active = 1
				--ORDER BY MR.From_date DESC
			END
		
		IF (@Module_Name='Comp-Off Application' OR @Module_Name='Comp-Off Approval') 
			BEGIN
				IF EXISTS(SELECT 1 FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND (CONVERT(varchar(11),From_date,120)) = CONVERT(VARCHAR(11),GETDATE(),120) AND  CONVERT(VARCHAR(11),To_date,120) >= CONVERT(VARCHAR(11),GETDATE(),120))
					BEGIN
						DECLARE @Res_Emp_ID as numeric  = 0
						SELECT @Res_Emp_ID = C.S_Emp_ID 
						FROM T0100_CompOff_Application C WITH (NOLOCK) 
						INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON C.Emp_ID = E.Emp_ID 
						WHERE C.Emp_ID = @Emp_ID
						
						INSERT INTO #Temp_To
						SELECT DISTINCT(EIM.DeviceID)
						FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO R WITH (NOLOCK) 
						INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK)  ON R.Pass_To_Emp_id = E.Emp_ID
						INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON E.Emp_ID = EIM.Emp_ID
						WHERE Manger_Emp_id = @Res_Emp_ID AND ISNULL(Emp_Left_Date,GETDATE() + 1) > GETDATE() AND E.Cmp_ID = @Cmp_ID AND EIM.Is_Active = 1
						--ORDER BY R.Tran_id DESC
					END
			END
		
			IF NOT EXISTS(SELECT 1 FROM #Temp_To)
				BEGIN
					INSERT INTO #Temp_To
					SELECT DISTINCT(EIM.DeviceID)
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
					INNER JOIN T0095_Emp_IMEI_Details EIM WITH (NOLOCK) ON EM.Emp_ID = EIM.Emp_ID
					WHERE (EM.Emp_ID = @App_Emp_ID OR EM.Emp_ID IN (SELECT Emp_ID FROM #Rpt_branch_manager)) AND EIM.Is_Active = 1
				END
						
			 				
				SELECT DISTINCT(Output_To)  + ',' FROM #Temp_To WHERE Output_To <>  '' FOR XML PATH('') 
				
				SELECT DISTINCT(Output_CC) + ',' FROM #Temp_CC WHERE Output_CC <>  ''  FOR XML PATH('') 
				
				SELECT DISTINCT(Output_Emp) + ',' FROM #Temp_Emp WHERE Output_Emp <> '' FOR XML PATH('')
				
				--SET @DeviceID = (SELECT  DISTINCT(DeviceID) + ',' 
				--FROM
				--(
				--	SELECT Output_To AS 'DeviceID' FROM #TEMP_TO 
				--	UNION ALL
				--	SELECT Output_CC AS 'DeviceID' FROM #TEMP_CC
				--	UNION ALL
				--	SELECT Output_Emp AS 'DeviceID' FROM #Temp_Emp
				--) AS P  FOR XML PATH(''))
			 
		END
		
	--IF @EMAIL_NTF_SENT = 0
	--	BEGIN
	--		SELECT * FROM #Temp_To
	--		SELECT * FROM #Temp_CC
	--	END
		
		--SELECT * FROM #TEMP_TO 
		--SELECT * FROM #TEMP_CC
		--SELECT * FROM #Temp_Emp
		
		DROP TABLE #TEMP_TO
		DROP TABLE #TEMP_CC
		DROP TABLE #TEMP_EMP
		DROP TABLE #RPT_BRANCH_MANAGER		
		
 

RETURN

