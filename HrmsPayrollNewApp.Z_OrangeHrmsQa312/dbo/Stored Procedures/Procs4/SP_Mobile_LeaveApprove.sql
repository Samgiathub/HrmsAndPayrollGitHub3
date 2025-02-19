

CREATE PROCEDURE [dbo].[SP_Mobile_LeaveApprove]
	@Leave_Approval_ID numeric,
	@Leave_Application_ID numeric,
	@Leave_ID numeric,
	@Emp_ID numeric,
	@Approval_Date datetime,
	@From_Date datetime,
	@TO_Date datetime,
	@Leave_Period decimal(18,2),
	@Leave_AssignAs varchar(15),
	@Leave_Reason  VARCHAR(100),
	@Half_Leave_Date DATETIME = NULL,
	@Approval_Status char(1),
	@Approval_Comments varchar(250),
	@Final_Approve int,
	@Is_Fwd_Leave_Rej int,
	@Rpt_Level int,
	@SEmp_ID numeric(18,0),
	@Intime datetime,
	@Outtime datetime,
	@Login_ID numeric,
	@Type Char(1),
	@Result varchar(255) OUTPUT
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

DECLARE @Cmp_ID NUMERIC(18,0)
DECLARE @System_Date DATETIME  
DECLARE @Row_ID NUMERIC(18,0)
DECLARE @IsBackdate TINYINT = 0
DECLARE @strLeaveCompOff_Dates VARCHAR(MAX) = ''



IF @Type = 'I'
	BEGIN
		
		
	
		IF @Half_Leave_Date = '' OR @Half_Leave_Date IS NULL
			BEGIN
				SET @Half_Leave_Date = '1900-01-01 00:00:00'
			END
		
		SET @System_Date = (SELECT CAST(GETDATE()AS VARCHAR(11)))  
		SET @Cmp_ID = (SELECT Cmp_ID FROM T0100_LEAVE_APPLICATION WITH (NOLOCK) WHERE Leave_Application_ID = @Leave_Application_ID)  
		
		SELECT @strLeaveCompOff_Dates = LEAVE_COMPOFF_DATES FROM T0110_LEAVE_APPLICATION_DETAIL WITH (NOLOCK)  WHERE LEAVE_APPLICATION_ID = @Leave_Application_ID
		
		IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE (@From_Date BETWEEN Month_St_Date AND ISNULL(CutOff_Date, Month_End_Date) OR @To_Date BETWEEN Month_St_Date AND ISNULL(CutOff_Date, Month_End_Date)) AND Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID)
			BEGIN
				SET	@IsBackdate = 1
			END
			
		BEGIN TRY
			BEGIN TRANSACTION LA	
				IF @Final_Approve = 1 OR (@Is_Fwd_Leave_Rej = 0 AND @Approval_Status = 'R') 
					BEGIN
					
						EXEC P0120_LEAVE_APPROVAL @Leave_Approval_ID = @Leave_Approval_ID OUTPUT,
						@Leave_Application_ID = @Leave_Application_ID,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@S_Emp_ID = @SEmp_ID,
						@Approval_Date = @Approval_Date,@Approval_Status = @Approval_Status,@Approval_Comments = @Approval_Comments,
						@Login_ID = @Login_ID,@System_Date = @System_Date,@tran_type = 'Insert',@User_Id = @Login_ID,@IP_Address = 'Mobile',
						@Is_Backdated_App = @IsBackdate
						
						EXEC P0130_LEAVE_APPROVAL_DETAIL @Row_ID OUTPUT,@Leave_Approval_ID = @Leave_Approval_ID,@Cmp_ID = @Cmp_ID,
						@Leave_ID = @Leave_ID,@From_Date = @From_Date,@To_Date = @TO_Date,@Leave_Period = @Leave_Period,@Leave_Assign_As = @Leave_AssignAs,
						@Leave_Reason = @Leave_Reason,@Login_ID = @Login_ID,@System_Date = @Approval_Date,@Is_import = 0,@tran_type = 'I',
						@M_Cancel_WO_HO = '0',@Half_Leave_Date = @Half_Leave_Date,@User_Id = @Login_ID,@IP_Address = 'Mobile',@Leave_Out_Time = @Outtime,
						@Leave_In_Time = @Intime,@NightHalt = 0,@strLeaveCompOff_Dates = @strLeaveCompOff_Dates,@Half_Payment = 0,@Warning_flag = 0,@Rules_Violate = 0  
					END

				EXEC P0115_Leave_Level_Approval @Leave_Approval_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Leave_Application_ID = @Leave_Application_ID,
				@Emp_ID = @Emp_ID,@Leave_ID = @Leave_ID,@From_Date = @From_Date,@To_Date = @TO_Date,@Leave_Period = @Leave_Period,
				@Leave_Assign_As = @Leave_AssignAs,@Leave_Reason = @Leave_Reason,@M_Cancel_WO_HO = 0,@Half_Leave_Date = @Half_Leave_Date,
				@S_Emp_ID = @SEmp_ID,@Approval_Date = @Approval_Date,@Approval_Status = @Approval_Status,@Approval_Comments = @Approval_Comments,
				@Rpt_Level = @Rpt_Level,@Tran_Type = 'I',@is_arrear = 0,@arrear_month = 0,@arrear_year = 0,@is_Responsibility_pass = 0,
				@Responsible_Emp_id = 0,@Leave_Out_Time = @Outtime,@Leave_In_Time = @Intime,@Leave_CompOff_Dates = '',@Half_Payment = 0
				
				IF @Leave_Approval_ID <> 0
					BEGIN
						IF @Approval_Status = 'R'
							BEGIN
								SET @Result = 'Leave Application Rejected Successfully:True'
							END
						ELSE
							BEGIN
								SET @Result = 'Leave Application Approve Successfully:True'
							END
					END
				
				COMMIT TRANSACTION LA
		END TRY
		BEGIN CATCH
			SET @Result = REPLACE(ERROR_MESSAGE(),'@@','') + ':False'
			ROLLBACK TRANSACTION LA
			RETURN
		END CATCH
	END
ELSE IF @Type = 'S'
	BEGIN
		SELECT (EM.Alpha_Emp_Code + ' ' + EM.Initial + ' ' + EM.Emp_First_Name + ' ' + ISNULL(EM.Emp_Last_Name,'')) AS 'EmployeeFullName',
		(EM.Emp_First_Name+' '+ EM.Emp_Last_Name)as 'EmployeeName',LA.Emp_ID,LA.Cmp_ID,LA.S_Emp_ID,LA.Leave_Application_ID,
		CONVERT(VARCHAR(20),LA.Application_Date,103) AS 'Application_Date',LA.Application_Code,LA.Application_Status,LA.Application_Comments,LAD.Leave_ID,
		CONVERT(VARCHAR(20),LAD.From_Date,103) AS 'FromDate',CONVERT(VARCHAR(20),LAD.To_Date,103) AS 'ToDate',
		LAD.Leave_Period,LAD.Leave_Assign_As,CONVERT(VARCHAR(20),LAD.Half_Leave_Date,103) AS 'Half_Leave_Date' ,LAD.Leave_Reason,LAD.NightHalt,
		CONVERT(VARCHAR(5),LAD.leave_Out_time,108) AS 'leave_Out_time',CONVERT(VARCHAR(5),LAD.leave_In_time,108) AS 'leave_In_time',
		LAD.Leave_App_Doc,LAD.Leave_CompOff_Dates
		
		FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
		INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID = LAD.Leave_Application_ID 
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LA.Emp_ID = EM.Emp_ID 
		WHERE LA.Leave_Application_ID = @Leave_Application_ID
		
		
		
		SELECT CONVERT(VARCHAR(20),From_Date,103) AS 'From_Date',CONVERT(VARCHAR(20),To_Date,103) AS 'To_Date',Leave_Period,
		Leave_Reason AS 'Comment', Application_Status,CONVERT(VARCHAR(20),System_Date,103) AS 'System_Date' , 'Application' As 'Rpt_Level'
		FROM V0110_LEAVE_APPLICATION_DETAIL 
		WHERE Leave_Application_ID = @Leave_Application_ID 
		
		UNION 
		
		SELECT CONVERT(VARCHAR(20),From_Date,103) AS 'From_Date',CONVERT(VARCHAR(20),To_Date,103) AS 'To_Date',Leave_Period,
		Approval_Comments AS 'Comment',Approval_Status, CONVERT(VARCHAR(20),System_Date,103) AS 'System_Date',
		(CASE WHEN Rpt_Level = 1 THEN 'First' ELSE (CASE WHEN Rpt_Level = 2 THEN 'Second' ELSE ( CASE WHEN Rpt_Level = 3 THEN 'Third' ELSE (CASE WHEN Rpt_Level = 4 THEN 'Fourth' ELSE 'Fifth' END) END ) END) END ) AS 'Rpt_Level'
		
		FROM T0115_Leave_Level_Approval WITH (NOLOCK)
		WHERE Leave_Application_ID = @Leave_Application_ID 
	
		ORDER BY Rpt_Level
	END

RETURN

