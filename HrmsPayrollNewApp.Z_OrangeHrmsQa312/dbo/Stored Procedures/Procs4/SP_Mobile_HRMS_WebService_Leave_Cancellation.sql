CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Leave_Cancellation]
	@Tran_ID numeric(18,0),
	@Emp_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Leave_Application_ID numeric(18,0),
	@Leave_Approval_ID numeric(18,0),
	@Leave_ID numeric(18,0),
	@For_date datetime,
	@Leave_period numeric(18,2),
	@Actual_Leave_period numeric(18,2),
	@Day_Type varchar(50),
	@Comment varchar(100),
	@Login_ID numeric,
	@Compoff_Work_Date varchar(MAX),
	@IMEINo Varchar(100),
	@AEmp_ID numeric(18,0), 
	@MComment varchar(100),
	@Is_Approve int,
	@Type Char(1),
	@Result varchar(255) OUTPUT
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

--DECLARE @Tran_id numeric(18,0)
DECLARE @Request_Date datetime
DECLARE @EmpIDS as varchar(MAX)

SET @Request_Date = CAST(GETDATE() AS varchar(11))


IF @Type = 'I' -- For Leave Cancellation Application
	BEGIN
		BEGIN TRY
			EXEC P0150_LEAVE_CANCELLATION @Tran_id = @Tran_ID output,@Cmp_id = @Cmp_ID,@Emp_id = @Emp_ID,@Leave_Approval_id = @Leave_Approval_ID,
			@For_date = @For_date,@Leave_period = @Leave_period,@Is_Approve = @Is_Approve,@Leave_id = @Leave_ID,@Request_Date = @Request_Date,
			@tran_type='Insert',@Comment = @Comment,@MComment = @MComment,@AEmp_id = @AEmp_ID,@Day_Type = @Day_Type,@Actual_Leave_period = @Actual_Leave_period,
			@Compoff_Work_Date = @Compoff_Work_Date,@User_Id = @Login_ID,@IP_Address = @IMEINo
			
			--SELECT 'Leave Cancellation Application Done'
			SET @Result =  'Leave Cancellation Application Done#True#' + CAST(@Tran_id AS varchar(11))
			--SELECT * FROM V0150_LEAVE_CANCELLATION WHERE Tran_id = @Tran_id
			
			SELECT @Result
			
			SELECT	LC.Tran_id, LC.Leave_Approval_ID,LC.Emp_ID,LC.Leave_ID,LC.Cmp_ID ,LC.Emp_Full_Name,LC.Alpha_Emp_Code,(LC.Alpha_Emp_Code + ' - ' + LC.Emp_Full_Name) AS 'Emp_Name',
			LC.Leave_Name,CONVERT(varchar(11),LAD.From_Date,103) AS 'From_Date',CONVERT(varchar(11),LAD.To_Date,103) AS 'To_Date',
			LAD.Leave_Period as 'No_of_Days',CONVERT(varchar(11),LC.For_date,103) AS 'For_date', CAST(LC.LEAVE_PERIOD AS VARCHAR(5)) + ' - ' + LC.Day_type AS 'Cancel_Leave_Period',
			(CASE WHEN LAD.Half_Leave_Date = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(11),LAD.Half_Leave_Date,103) END) AS 'Half_Leave_Date',
			(CASE WHEN LAD.leave_In_time = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(5),LAD.leave_In_time,108) END) AS 'Leave_In_Time',
			(CASE WHEN LAD.leave_Out_time = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(5),LAD.leave_Out_time,108) END) AS 'Leave_Out_Time',
			LC.Comment AS 'Cancel_Reason',LAD.Leave_Assign_As,CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,CM.Image_file_Path,CM.Image_name
			FROM V0150_LEAVE_CANCELLATION LC
			INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LAD.Leave_Approval_ID = LC.Leave_Approval_id
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LC.Emp_ID = EM.Emp_ID
			INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON LC.Cmp_ID = CM.Cmp_Id
			WHERE LC.Is_Approve = 0 AND LC.Tran_ID = @Tran_ID
			
			EXEC SP_Mobile_Get_Notification_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Cancel Leave Application',
			@Flag = 2,@Leave_ID = @Leave_ID,@Rpt_Level = 0,@Final_Approval = 0
			
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE() +'#False#'
			SELECT @Result
		END CATCH
	END
ELSE IF @Type = 'L' -- For Leave Cancellation Application List
	BEGIN
	--set @EmpIDS=''
		SELECT @EmpIDS = dbo.F_GET_DOWNLINE_EMPLOYEES_XML(@Emp_ID,@Request_Date)
		
		IF @EmpIDS = '' 
			BEGIN
			
				SET @EmpIDS = @Emp_ID
			END
			
		--SELECT VL.Tran_Id, VL.Cmp_ID,VL.Emp_ID,ISNULL(VL.Leave_Approval_ID,0) as Leave_Approval_ID,VL.Leave_ID, --here add isnull condition for details level approvlas
		--CONVERT(VARCHAR(11),FOR_DATE,103) AS 'For_Date',
		--IS_APPROVE,MCOMMENT,A_EMP_ID, Leave_Name,case when Leave_Application_ID = '' then 0 else Leave_Application_ID end as Leave_Application_ID,Alpha_Emp_code,Emp_Full_Name,S_EMP_FULL_NAME,
		--CONVERT(VARCHAR(11),FROM_DATE,103) AS 'From_Date',CONVERT(VARCHAR(11),TO_DATE,103) AS 'to_date',
		--Leave_Period,(CASE WHEN APPLY_HOURLY = 1 THEN 'HOUR(S)' ELSE 'DAY(S)' END) AS 'Leave_Type',
		--Default_Short_Name 
		--FROM V0150_LEAVE_CANCELLATION_APPROVAL_MAIN VL
		--INNER JOIN
		--(SELECT Data FROM dbo.Split(@EmpIDS,',')
		--) E ON VL.Emp_ID = E.Data
		--WHERE  IS_APPROVE = 0 --AND Emp_Id IN (@EmpIDS)
		--ORDER BY For_Date DESC

		--select @EmpIDS

		SELECT VL.Tran_Id, VL.Cmp_ID,VL.Emp_ID,ISNULL(VL.Leave_Approval_ID,0) as Leave_Approval_ID,VL.Leave_ID, --here add isnull condition for details level approvlas
		CONVERT(VARCHAR(11),FOR_DATE,103) AS 'For_Date',
		IS_APPROVE,MCOMMENT,A_EMP_ID, Leave_Name,case when Leave_Application_ID = '' then 0 else Leave_Application_ID end as Leave_Application_ID,Alpha_Emp_code,Emp_Full_Name,S_EMP_FULL_NAME,
		CONVERT(VARCHAR(11),FROM_DATE,103) AS 'From_Date',CONVERT(VARCHAR(11),TO_DATE,103) AS 'to_date',
		ISnull(Leave_Period,'0.00') as Leave_Period,(CASE WHEN APPLY_HOURLY = 1 THEN 'HOUR(S)' ELSE 'DAY(S)' END) AS 'Leave_Type',
		Default_Short_Name 
		FROM V0150_LEAVE_CANCELLATION_APPROVAL_MAIN VL
		INNER JOIN
		(SELECT Data FROM dbo.Split(@EmpIDS,',')
		) E ON VL.Emp_ID = E.Data
		WHERE  IS_APPROVE = 0 --AND s_Emp_id =@Emp_ID
		ORDER BY For_Date DESC

	END
ELSE IF @Type = 'E' -- For Leave Approval Details
	BEGIN
		--SELECT VLA.Leave_Application_ID,VLA.Leave_Approval_ID,VLT.Leave_Tran_ID,VLA.Emp_ID,VLA.Emp_Full_Name,
		--VLA.S_emp_Full_Name,VLA.Leave_ID,VLA.Leave_Name,VLA.Approval_Status,VLT.For_Date,VLT.Leave_Used_Comp,
		--VLT.Leave_Used,VLA.Leave_Period,VLA.Leave_Reason,CASE WHEN Apply_Hourly = 1 THEN 'hour(s)' ELSE 'day(s)' END AS 'Leave_Type',
		--VLA.Default_Short_Name,VLA.Leave_Assign_As,VLA.Approval_Comments,VLA.Approval_Date
		--FROM V0120_LEAVE_APPROVAL VLA
		--INNER JOIN V0140_LEAVE_TRANSACTION VLT ON VLA.Leave_ID = VLT.Leave_ID AND VLA.Emp_ID = VLT.Emp_ID 

		--WHERE ISNULL(VLA.Default_Short_Name,'') <> 'COPH' AND ISNULL(VLA.Default_Short_Name,'') <> 'COND' AND VLA.Emp_Id = @Emp_ID AND (Approval_Status = 'A') 
		--AND VLA.Leave_Application_ID = @Leave_Application_ID AND VLA.Leave_Approval_ID = @Leave_Approval_ID AND Leave_Used >= 0 AND VLT.Leave_ID = @Leave_ID AND VLT.For_Date >= VLA.From_Date AND VLT.For_Date <= VLA.To_Date
		
		SELECT DISTINCT VLA.Leave_Application_ID,VLA.Leave_Approval_ID,VLA.From_Date,VLA.To_Date,VLA.Leave_Period,
		VLA.Leave_Name,
		(CASE WHEN VLT.Leave_Used = 1 THEN 'Full Day' ELSE VLA.Leave_Assign_As END) AS 'Leave_Assign_As',
		VLA.Approval_Comments, VLT.For_Date,VLT.Leave_Used,
		ISNULL(VLC.Tran_id,0) AS 'Tran_ID',ISNULL(VLC.Is_Approve,0) AS 'Is_Approve',
		ISNULL(VLT.Leave_Used,0.0) AS 'Actual_Leave_Day',ISNULL(VLC.Leave_period,0) AS 'LEAVE_CANCEL_PERIOD',
		--(ISNULL(VLT.Leave_Used,0) - ISNULL(VLC.Leave_period,0)) AS 'REMAIN_LEAVE_PERIOD', 
		ISNULL((ISNULL(VLC.Actual_Leave_Day,0.0)-(
			SELECT SUM(leave_period) 
			FROM V0150_LEAVE_CANCELLATION LV
			WHERE LV.Leave_Approval_id = VLC.Leave_Approval_id and LV.For_date = VLC.For_date 
			GROUP BY For_date,Emp_Id,Leave_Approval_id
		)),VLT.Leave_Used) AS 'REMAIN_LEAVE_PERIOD', 
		(CASE WHEN ISNULL(VLC.Day_type,'') = '' THEN CASE WHEN VLT.Leave_Used = 1 THEN 'Full Day' ELSE VLA.Leave_Assign_As END ELSE CASE WHEN VLC.Day_type = 'First Half' THEN 'Second Half' ELSE CASE WHEN VLC.Day_type = 'Second Half' THEN 'First Half' ELSE VLA.Leave_Assign_As END END END) AS 'REMAIN_DAY',
		ISNULL(VLC.Day_type,CASE WHEN VLT.Leave_Used = 1 THEN 'Full Day' ELSE VLA.Leave_Assign_As END) AS 'Day_Type',ISNULL(VLC.Comment,VLA.Approval_Comments) AS 'Comment',
		ISNULL(VLC.MComment,'') AS 'MComment',
		(CASE WHEN ISNULL(VLC.Tran_id,0) = 0 THEN '' ELSE CASE WHEN ISNULL(VLC.Is_Approve,0) = 0 THEN 'Pending' ELSE 'Approve' END END ) AS 'APPSTATUS' 

		FROM V0120_LEAVE_APPROVAL VLA
		INNER JOIN V0140_LEAVE_TRANSACTION VLT ON VLA.Leave_ID = VLT.Leave_ID AND VLT.For_Date BETWEEN VLA.From_Date AND VLA.To_Date AND VLT.Emp_ID = @Emp_ID
		LEFT JOIN T0150_LEAVE_CANCELLATION VLC WITH (NOLOCK) ON VLA.Leave_Approval_ID = VLC.Leave_Approval_id AND VLT.For_Date = VLC.For_date
		WHERE VLA.Leave_Approval_ID = @Leave_Approval_ID
		--SELECT DISTINCT VLA.Leave_Application_ID,VLA.Leave_Approval_ID,VLA.From_Date,VLA.To_Date,VLA.Leave_Period,
		--VLA.Leave_Name,VLA.Leave_Assign_As,VLA.Approval_Comments, VLT.For_Date,VLT.Leave_Used,
		--ISNULL(VLC.Tran_id,0) AS 'Tran_ID',ISNULL(VLC.Is_Approve,0) AS 'Is_Approve',
		--ISNULL(VLC.Actual_Leave_Day,VLT.Leave_Used) AS 'Actual_Leave_Day',ISNULL(VLC.Leave_period,0) AS 'LEAVE_CANCEL_PERIOD',
		--(ISNULL(VLC.Actual_Leave_Day,VLT.Leave_Used) - ISNULL(VLC.Leave_period,0)) AS 'REMAIN_LEAVE_PERIOD', 
		--(CASE WHEN ISNULL(VLC.Day_type,'') = '' THEN VLA.Leave_Assign_As ELSE CASE WHEN VLC.Day_type = 'First Half' THEN 'Second Half' ELSE CASE WHEN VLC.Day_type = 'Second Half' THEN 'First Half' ELSE VLA.Leave_Assign_As END END END) AS 'REMAIN_DAY',
		--ISNULL(VLC.Day_type,VLA.Leave_Assign_As) AS 'Day_Type',ISNULL(VLC.Comment,VLA.Approval_Comments) AS 'Comment',
		--ISNULL(VLC.MComment,'') AS 'MComment',
		--(CASE WHEN ISNULL(VLC.Tran_id,0) = 0 THEN '' ELSE CASE WHEN ISNULL(VLC.Is_Approve,0) = 0 THEN 'Pending' ELSE 'Approve' END END ) AS 'APPSTATUS' 

		--FROM V0120_LEAVE_APPROVAL VLA
		--INNER JOIN V0140_LEAVE_TRANSACTION VLT ON VLA.Leave_ID = VLT.Leave_ID AND VLT.For_Date BETWEEN VLA.From_Date AND VLA.To_Date
		--LEFT JOIN T0150_LEAVE_CANCELLATION VLC ON VLA.Leave_Approval_ID = VLC.Leave_Approval_id AND VLT.For_Date = VLC.For_date
		--WHERE VLA.Leave_Approval_ID = @Leave_Approval_ID
	END
ELSE IF @Type = 'D' -- For Leave Cancellation Application Details
	BEGIN
		SELECT case when Leave_Application_ID = '' then 0 else Leave_Application_ID end as Leave_Application_ID,ISNULL(Leave_Approval_ID,0) as Leave_Approval_ID,Tran_ID,Emp_ID,Leave_ID,For_date,leave_period_app,
		Is_Approve,Comment,Request_Date,MComment,A_Emp_ID,Day_Type,Actual_Leave_Day,Leave_Name, 
		Leave_Period,From_Date,To_Date,(CASE WHEN Apply_Hourly = 1 THEN 'Hour(s)' ELSE 'Day(s)' END) AS 'Leave_Type',
		'' AS 'CompoffDates'
		FROM V0150_LEAVE_CANCELLATION_APPROVAL
		WHERE  Emp_ID = @Emp_ID  and Leave_ID  = @Leave_ID and Leave_Approval_ID = @Leave_Approval_ID 
		ORDER BY  For_Date
	END
ELSE IF @Type = 'A' --- Leave Cancellation Approval
	BEGIN
		BEGIN TRY
		
			--SELECT @Tran_id = Tran_id FROM T0150_LEAVE_CANCELLATION WHERE For_date = @For_date AND Leave_Approval_id = @Leave_Approval_ID AND Leave_id = @Leave_ID
			--SELECT @Tran_id
			
			EXEC P0150_LEAVE_CANCELLATION @Tran_id = @Tran_ID OUTPUT,@Cmp_id = @Cmp_ID,@Emp_id = @Emp_ID,@Leave_Approval_id = @Leave_Approval_ID,@For_date = @For_date,
			@Leave_period = @Leave_period,@Is_Approve = @Is_Approve,@Leave_id = @Leave_ID,@Request_Date = @Request_Date,@tran_type='Update',
			@Comment = @Comment,@MComment = @MComment,@AEmp_id = @AEmp_ID,@Day_Type = @Day_Type,@Actual_Leave_period = @Actual_Leave_period,
			@Compoff_Work_Date = @Compoff_Work_Date,@User_Id = @Login_ID,@IP_Address = @IMEINo
			
			SET @Result =  'Leave Cancellation Approval Done#True#' + CAST(@Tran_id AS varchar(11))			
			
			SELECT @Result as Result
			
			SELECT	LC.Tran_id,LC.Leave_Approval_ID,LC.Emp_ID,LC.Leave_ID,LC.Cmp_ID ,LC.Emp_Full_Name,LC.Alpha_Emp_Code,(LC.Alpha_Emp_Code + ' - ' + LC.Emp_Full_Name) AS 'Emp_Name',
			LC.Leave_Name,CONVERT(varchar(11),LAD.From_Date,103) AS 'From_Date',CONVERT(varchar(11),LAD.To_Date,103) AS 'To_Date',
			LAD.Leave_Period as 'No_of_Days',CONVERT(varchar(11),LC.For_date,103) AS 'For_date', CAST(LC.LEAVE_PERIOD AS VARCHAR(5)) + ' - ' + LC.Day_type AS 'Cancel_Leave_Period',
			(CASE WHEN LAD.Half_Leave_Date = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(11),LAD.Half_Leave_Date,103) END) AS 'Half_Leave_Date',
			(CASE WHEN LAD.leave_In_time = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(5),LAD.leave_In_time,108) END) AS 'Leave_In_Time',
			(CASE WHEN LAD.leave_Out_time = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(5),LAD.leave_Out_time,108) END) AS 'Leave_Out_Time',
			LC.Comment + ';<br /> ( Managers Comments:- ' +  LC.MComment + ' )' AS 'Cancel_Reason',LAD.Leave_Assign_As,CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,CM.Image_file_Path,CM.Image_name
			FROM V0150_LEAVE_CANCELLATION LC
			INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LAD.Leave_Approval_ID = LC.Leave_Approval_id
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LC.Emp_ID = EM.Emp_ID
			INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON LC.Cmp_ID = CM.Cmp_Id
			WHERE  LC.Tran_ID = @Tran_ID
		

			EXEC SP_Mobile_Get_Notification_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Cancel Leave Approval',
			@Flag = 2,@Leave_ID = @Leave_ID,@Rpt_Level = 0,@Final_Approval = 1
			
			
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE() +'#False#'
			SELECT @Result
		END CATCH
	END
