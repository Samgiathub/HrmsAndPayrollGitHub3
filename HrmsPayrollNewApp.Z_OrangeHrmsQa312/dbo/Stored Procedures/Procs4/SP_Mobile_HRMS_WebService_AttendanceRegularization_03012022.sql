CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_AttendanceRegularization_03012022]
	@IO_Tran_Id numeric(18),
	@Emp_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Month int,
	@Year int,
    @For_Date datetime,
    @Reason varchar(500),
    @Half_Full_Day Varchar(20),
    @Is_Cancel_Late_In int,
    @Is_Cancel_Early_Out int,
    @In_Date_Time datetime = null,
    @Out_Date_Time datetime,
    @Is_Approve tinyint = 0,
    @Other_Reason varchar(max) = '',
    @IMEINo varchar(50),
    @S_Emp_ID numeric(18,0),
    @Rpt_Level int,
    @Final_Approve int,
    @Is_Fwd_Leave_Rej int,
    @Approval_Status varchar(20),
    @Type char(1),
    @Result VARCHAR(100) OUTPUT
AS

SET NOCOUNT ON		
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

--DECLARE @IO_Tran_Id numeric(18,0)
DECLARE @Ip_Address varchar(50)
DECLARE @StartDate datetime  
DECLARE @EndDate datetime
DECLARE @BranchID numeric(18,0)
DECLARE @Setting_Value int

IF @IMEINo <> ''
	BEGIN
		SET @Ip_Address = 'Mobile(' + @IMEINo + ')'
	END

IF @Type = 'S'     
	BEGIN
		SET @StartDate = CONVERT(datetime, CAST(@Month as varchar) + '/01/' + CAST(@Year as varchar))  
		SET @EndDate = DATEADD(month, 1, CONVERT(datetime, CAST(@Month as varchar)+ '/01/' + CAST(@Year as varchar))) -1
		
		SELECT @BranchID = TIC.Branch_ID
		FROM T0095_INCREMENT TIC WITH (NOLOCK)
		INNER JOIN
		(
			SELECT MAX(IC.Increment_ID) AS 'Increment_ID' FROM T0095_INCREMENT IC WITH (NOLOCK)
			INNER JOIN
			(
				SELECT MAX(Increment_Effective_Date) AS 'Increment_Effective_Date',Emp_ID 
				FROM T0095_INCREMENT  WITH (NOLOCK)
				WHERE Emp_ID = @Emp_ID
				GROUP BY Emp_ID
			) TP ON IC.Increment_Effective_Date = TP.Increment_Effective_Date AND IC.Emp_ID = TP.Emp_ID
		) TTP ON TIC.Increment_ID = TTP.Increment_ID
		
	

		EXEC SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET @Cmp_ID = @Cmp_ID,@From_Date = @StartDate,@To_Date = @EndDate,
		@Branch_ID = @BranchID,@Cat_ID = 0,@Grd_ID = 0,@Type_ID = 0,@Dept_ID = 0,@Desig_ID = 0,@Emp_ID = @Emp_ID,
		@Constraint='',@Report_for='IN-OUT',@Graph_flag = '',@ReloadData = 1 -- Changed by Niraj (03012022)
		
		SELECT Month_St_Date,ISNULL(Cutoff_Date,Month_End_Date) as Month_End_Date 
		FROM T0200_MONTHLY_SALARY  WITH (NOLOCK)
		WHERE MONTH(Month_End_Date)= MONTH(@StartDate) AND YEAR(Month_End_Date) = YEAR(@StartDate) AND Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID 
		
		SELECT TOP 1 ISNULL(Inout_Days,0) Setting_Value,Attndnc_Reg_Max_Cnt,Sal_St_Date
		FROM T0040_General_Setting  WITH (NOLOCK)
		WHERE Cmp_Id = @Cmp_ID AND Branch_id = @BranchID AND For_Date = 
		(
			SELECT MAX(For_Date) 
			FROM T0040_GENERAL_SETTING  WITH (NOLOCK)
			WHERE For_Date <=GETDATE() AND Cmp_ID = @Cmp_ID AND Branch_id = @BranchID
		)
			SELECT *
			FROM T0040_SETTING WITH (NOLOCK) 
			WHERE Setting_Name = 'Allow Employee to Regularize the Attendance even In & Out is missing' AND Cmp_ID = @Cmp_ID
	END
ELSE IF @Type = 'I' --- Attendance Regularize Applicaiton
	BEGIN
		DECLARE @strIntime varchar(50)
		DECLARE @strOuttime varchar(50)
		
		DECLARE @ShiftIntime varchar(50)
		DECLARE @ShiftOuttime varchar(50)
		
		SET @strIntime = CONVERT(varchar(11),@For_Date,103) +' ' + CONVERT(varchar(11),@In_Date_Time,108)
		SET @strOuttime = CONVERT(varchar(11),@For_Date,103) + ' '+CONVERT(varchar(11),@Out_Date_Time,108)
		
		SELECT @ShiftIntime = Shift_St_Time,@ShiftOuttime = Shift_End_Time 
		FROM T0040_SHIFT_MASTER  WITH (NOLOCK)
		WHERE Shift_ID = (dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,@Emp_ID,@For_Date))
		
		IF @ShiftIntime > @ShiftOuttime
			BEGIN
				SET @In_Date_Time = CONVERT(datetime,@strIntime,103)
				SET @Out_Date_Time = DATEADD(d,1,CONVERT(datetime,@strOuttime,103))
			END
		ELSE
			BEGIN
				SET @In_Date_Time = CONVERT(datetime,@strIntime,103)
				SET @Out_Date_Time = CONVERT(datetime,@strOuttime,103)
			END 
		
		
		SET @In_Date_Time = CONVERT(datetime,@strIntime,103)
		SET @Out_Date_Time = CONVERT(datetime,@strOuttime,103)
		
 		EXEC P0150_EMP_INOUT_RECORD_HOME @IO_Tran_Id OUTPUT,@Emp_ID = @Emp_ID,@Cmp_Id = @Cmp_ID,@For_Date = @For_Date,
 		@Reason = @Reason,@Half_Full_Day = @Half_Full_Day,@Ip_Address = @Ip_Address,@Is_Cancel_Late_In = @Is_Cancel_Late_In,
 		@Is_Cancel_Early_Out = @Is_Cancel_Early_Out,@In_Date_Time = @In_Date_Time,@Out_Date_Time = @Out_Date_Time,
 		@Is_Approve = @Is_Approve,@Other_Reason = @Other_Reason
		
 			SET @Result = 'Attendance Regularization Applied Successfully#True#'+ CAST(@IO_Tran_Id AS varchar)
			SELECT @Result
 	END
ELSE IF @Type = 'O' -- All Employee Attendance
	BEGIN
		EXEC SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET @Cmp_ID = @Cmp_ID,@From_Date = @In_Date_Time,@To_Date = @Out_Date_Time,
		@Branch_ID = 0,@Cat_ID = 0,@Grd_ID = 0,@Type_ID = 0,@Dept_ID = 0,@Desig_ID = 0,@Emp_ID = 0,
		@Constraint='',@Report_for='IN-OUT',@Graph_flag = '',@ReloadData = 1
	
	END
ELSE IF @Type = 'T' -- My Team Attendance
	BEGIN
		DECLARE @Constraint varchar(MAX)
		
		--SET @Constraint = (SELECT  DISTINCT(CONVERT(NVARCHAR,ERD.Emp_ID)) + ','  
		--FROM T0090_EMP_REPORTING_DETAIL ERD 
		--INNER JOIN 
		--(
		--	SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID 
		--	FROM T0090_EMP_REPORTING_DETAIL
		--	WHERE Effect_Date <= GETDATE() AND 
		--	Emp_ID IN 
		--	(
		--		SELECT Emp_ID 
		--		FROM T0090_EMP_REPORTING_DETAIL
		--		WHERE R_Emp_ID = @Emp_ID
		--	) 
		--	GROUP BY Emp_ID 
		--) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date 
		--INNER JOIN T0080_EMP_MASTER EM ON ERD.Emp_ID = EM.Emp_ID
		--WHERE ERD.R_Emp_ID = @Emp_ID AND (ISNULL(EM.Emp_Left,'N') = 'N' OR (EM.Emp_Left = 'Y' AND EM.Emp_Left_Date > GETDATE()))
		--FOR XML PATH (''))
		
		
		--SET @Constraint = REPLACE(SUBSTRING(@Constraint,1,len(@Constraint)- 1),',','#')
		--SELECT @Constraint
		
		--SET @Constraint = REPLACE((SELECT dbo.F_GET_DOWNLINE_EMPLOYEES_XML(@Emp_ID,NULL) AS EMP_ID),',','#')
		
		--SET @Constraint = CAST(@Emp_ID as varchar) + '#' + @Constraint
		--SELECT @Constraint
		
		
		SELECT	@Constraint = REPLACE(REPLACE(STUFF((SELECT '#' + QUOTENAME(RD.EMP_ID) 
		FROM T0090_EMP_REPORTING_DETAIL RD  WITH (NOLOCK)
		INNER JOIN 
		(
			SELECT MAX(EFFECT_DATE) AS EFFECT_DATE,EMP_ID FROM T0090_EMP_REPORTING_DETAIL  WITH (NOLOCK)
			WHERE EFFECT_DATE <= GETDATE()
			GROUP BY EMP_ID
		) AS EMP_SUP
		ON RD.EMP_ID = EMP_SUP.EMP_ID AND RD.EFFECT_DATE = EMP_SUP.EFFECT_DATE
		INNER JOIN T0080_EMP_MASTER EM  WITH (NOLOCK) ON RD.Emp_ID = EM.Emp_ID
		WHERE RD.R_EMP_ID = @Emp_ID AND (EM.Emp_Left = 'N' OR  (EM.Emp_Left = 'Y' AND ISNULL(EM.Emp_Left_Date,GETDATE()) > GETDATE()))
		GROUP BY RD.EMP_ID 
		ORDER BY RD.EMP_ID  
		FOR XML PATH(''),TYPE).value('.', 'NVARCHAR(MAX)') ,1,1,''),']',''),'[','')
		
		IF @Constraint <> ''
			BEGIN
				SET @Constraint = @Constraint + '#'+CAST(@Emp_ID AS varchar(5))
			END
		ELSE
			BEGIN
				SET @Constraint = @Emp_ID
			END
		
		
		EXEC P_In_Out_Regularization @Cmp_ID = @Cmp_ID,@From_Date = @In_Date_Time,@To_Date = @Out_Date_Time,
		@Branch_ID = 0,@Cat_ID = 0,@Grd_ID = 0,@Type_ID = 0,@Dept_ID = 0,@Desig_ID = 0,@Emp_ID = 0,
		@Constraint = @Constraint,@Report_for = 'BulkRegularization_Mobile',@Segment_Id =0,@SubBranch_ID =0,@Vertical_Id =0,@SubVertical_ID =0,@Shift_ID=0

		--EXEC SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET @Cmp_ID = @Cmp_ID,@From_Date = @In_Date_Time,@To_Date = @Out_Date_Time,
		--@Branch_ID = 0,@Cat_ID = 0,@Grd_ID = 0,@Type_ID = 0,@Dept_ID = 0,@Desig_ID = 0,@Emp_ID = 0,
		--@Constraint = @Constraint,@Report_for='IN-OUT',@Graph_flag = '',@ReloadData = 1
	
	END
ELSE IF @Type = 'P' --- Attendance Regularize Applicaiton Pending Record
	BEGIN
		EXEC SP_GET_ATTENDANCEREGU_APPLICATION_RECORDS @Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@Rpt_level=0,@Constrains=N'Chk_By_Superior = 0',@Type=0
	END
ELSE IF @Type = 'E' --- Attendance Regularize Applicaiton Record
	BEGIN
		--EXEC SP_GET_ATTENDANCEREGU_APPLICATION_RECORDS @Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@Rpt_level=0,@Constrains=N'Chk_By_Superior = 0',@Type=0
		-- Old Logic Commented by deepal 27/10/2020
		
		--SELECT EMP_ID,IN_TIME,REASON,OTHER_REASON,IO_TRAN_ID,EMP_FULL_NAME,CONVERT(VARCHAR(11),FOR_DATE,105)AS FOR_DATE
		--,OUT_TIME,EMP_NAME,IS_CANCEL_LATE_IN,IS_CANCEL_EARLY_OUT,HALF_FULL_DAY,CMP_ID ,Actual_In_Time,	Actual_Out_Time
		--FROM VIEW_LATE_EMP 
		--WHERE  IO_TRAN_ID=@IO_TRAN_ID
		
		--SELECT FOR_DATE,REASON,CHK_BY_SUPERIOR AS APPLICATION_STATUS, 0 AS RPT_LEVEL, APP_DATE AS SYSTEM_DATE,IN_TIME,OUT_TIME,Actual_In_Time,	Actual_Out_Time
		--FROM VIEW_LATE_EMP 
		--WHERE IO_TRAN_ID = @IO_TRAN_ID 
		
		--UNION 
		
		--SELECT FOR_DATE, S_COMMENT,CHK_BY_SUPERIOR AS APPROVAL_STATUS, RPT_LEVEL, SYSTEM_DATE,IN_TIME,OUT_TIME 
		--FROM T0115_ATTENDANCEREGU_LEVEL_APPROVAL WITH (NOLOCK) 
		--WHERE IO_TRAN_ID = @IO_TRAN_ID 
		--ORDER BY RPT_LEVEL
		-- Old Logic Commented by deepal 27/10/2020
		
				Select top 1  EMP_ID,	IN_TIME,	REASON,	OTHER_REASON,	IO_TRAN_ID	,EMP_FULL_NAME	,FOR_DATE,	OUT_TIME,	
				EMP_NAME,	IS_CANCEL_LATE_IN,	IS_CANCEL_EARLY_OUT,	HALF_FULL_DAY,	
				CMP_ID,	Actual_In_Time,	Actual_Out_Time,	APPLICATION_STATUS,	RPT_LEVEL,	SYSTEM_DATE
			from (
				SELECT EMP_ID,IN_TIME
				--,FOR_DATE
				,REASON,OTHER_REASON,IO_TRAN_ID,EMP_FULL_NAME,CONVERT(VARCHAR(11),FOR_DATE,105)AS FOR_DATE,OUT_TIME
				,EMP_NAME,IS_CANCEL_LATE_IN,IS_CANCEL_EARLY_OUT,HALF_FULL_DAY,CMP_ID,Actual_In_Time,	Actual_Out_Time
				,CHK_BY_SUPERIOR AS APPLICATION_STATUS, 0 AS RPT_LEVEL, APP_DATE AS SYSTEM_DATE
				FROM VIEW_LATE_EMP 
				WHERE IO_TRAN_ID =  @IO_TRAN_ID   
				UNION 
				SELECT E.EMP_ID,IN_TIME
				--,FOR_DATE
				, S_COMMENT,NULL as OTHER_REASON,IO_TRAN_ID,e.EMP_FULL_NAME,CONVERT(VARCHAR(11),FOR_DATE,105)AS FOR_DATE
				,OUT_TIME,E.Emp_Full_Name,IS_CANCEL_LATE_IN,IS_CANCEL_EARLY_OUT,HALF_FULL_DAY,a.Cmp_ID,IN_TIME as Actual_In_Time, OUT_TIME as	Actual_Out_Time
				,CHK_BY_SUPERIOR AS APPROVAL_STATUS, RPT_LEVEL, A.SYSTEM_DATE
				FROM T0115_ATTENDANCEREGU_LEVEL_APPROVAL A WITH (NOLOCK) 
				 inner join T0080_EMP_MASTER E on a.Emp_ID = E.Emp_ID
				WHERE IO_TRAN_ID =  @IO_TRAN_ID   
			) d1 order by RPT_LEVEL desc

				SELECT EMP_ID,IN_TIME,REASON,OTHER_REASON,IO_TRAN_ID,EMP_FULL_NAME,CONVERT(VARCHAR(11),FOR_DATE,105)AS FOR_DATE
			,OUT_TIME,EMP_NAME,IS_CANCEL_LATE_IN,IS_CANCEL_EARLY_OUT,HALF_FULL_DAY,CMP_ID ,Actual_In_Time,	Actual_Out_Time
			FROM VIEW_LATE_EMP where 1=0
			--	WHERE  IO_TRAN_ID=@IO_TRAN_ID
	END
ELSE IF @Type = 'A' --- Attendance Regularize Approve / Reject
	BEGIN
		
		DECLARE @Tran_ID Numeric(18,0)
		if @In_Date_Time is null
		BEGIN
			SELECT @In_Date_Time = Shift_St_Time
			from T0080_EMP_MASTER E inner join T0040_SHIFT_MASTER S on E.Shift_ID = S.Shift_ID where E.Emp_ID = @Emp_ID
		END
		if @Out_Date_Time is null
		BEGIN
			SELECT @Out_Date_Time = Shift_End_Time
			from T0080_EMP_MASTER E inner join T0040_SHIFT_MASTER S on E.Shift_ID = S.Shift_ID where E.Emp_ID = @Emp_ID
		END
		SET @In_Date_Time = CAST((CAST(@For_Date AS varchar(11)) + ' ' + CONVERT(VARCHAR(5),@In_Date_Time,108)) AS DATETIME)
		SET @Out_Date_Time = CAST((CAST(@For_Date AS varchar(11)) + ' ' + CONVERT(VARCHAR(5),@Out_Date_Time,108)) AS DATETIME)
		--SET @In_Date_Time = ''
		--SET @Out_Date_Time = ''
		
		--SELECT @In_Date_Time,@Out_Date_Time

		BEGIN TRY
			IF @Final_Approve = 1 OR (@Is_Fwd_Leave_Rej=0 AND @Approval_Status = 'R') 
				BEGIN
					EXEC UPDATE_EMP_INOUT_RECORD @IO_Tran_Id = @IO_Tran_Id,@Emp_ID = @Emp_ID,@Cmp_Id = @Cmp_ID,
					@Sup_Comment = @Other_Reason,@Approved = @Approval_Status,@Is_Cancel_Late_In = @Is_Cancel_Late_In,
					@Is_Cancel_Early_Out = @Is_Cancel_Early_Out,@Half_Full_day_Manager = @Half_Full_Day
					,@In_Date_Time = @In_Date_Time,@Out_Date_Time = @Out_Date_Time
				END
			
			EXEC P0115_AttendanceRegul_Level_Approval @Tran_ID OUTPUT,@IO_Tran_Id = @IO_Tran_Id,@Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,
			@Sup_Comment = @Other_Reason,@Is_Cancel_Late_In = @Is_Cancel_Late_In,@Is_Cancel_Early_Out = @Is_Cancel_Early_Out,
			@Half_Full_day_Manager = @Half_Full_Day,@In_Date_Time = @In_Date_Time,@Out_Date_Time = @Out_Date_Time,
			@Chk_By_Superior = @Is_Approve,@S_Emp_ID = @S_Emp_ID,@Rpt_Level = @Rpt_Level,@For_Date=@For_Date
			
			IF @Tran_ID <> 0
				BEGIN
					IF @Approval_Status = 'R'
						BEGIN
							SET @Result = 'Attendance Regularize Rejected#True#'+ CAST(@IO_Tran_Id AS varchar)
						END
					ELSE
						BEGIN
							SET @Result = 'Attendance Regularize Approved#True#'+ CAST(@IO_Tran_Id AS varchar)
						END
				--SELECT @Result
				END
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+'#False#'
			--SELECT @Result
		END CATCH
	END

RETURN

