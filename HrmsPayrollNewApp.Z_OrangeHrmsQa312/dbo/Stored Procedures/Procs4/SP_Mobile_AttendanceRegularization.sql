

CREATE PROCEDURE [dbo].[SP_Mobile_AttendanceRegularization]
    @IO_Tran_Id numeric(18) OUTPUT,
	@Emp_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Month int,
	@Year int,
    @For_Date datetime,
    @Reason varchar(500),
    @Half_Full_Day Varchar(20),
    @Is_Cancel_Late_In int,
    @Is_Cancel_Early_Out int,
    @In_Date_Time datetime,
    @Out_Date_Time datetime,
    @Is_Approve tinyint = 0,
    @Other_Reason varchar(max) = '',
    @Type char(1)
   
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

DECLARE @StartDate datetime  
DECLARE @EndDate datetime
DECLARE @BranchID numeric(18,0)

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
				FROM T0095_INCREMENT WITH (NOLOCK) 
				WHERE Emp_ID = @Emp_ID
				GROUP BY Emp_ID
			) TP ON IC.Increment_Effective_Date = TP.Increment_Effective_Date AND IC.Emp_ID = TP.Emp_ID
		) TTP ON TIC.Increment_ID = TTP.Increment_ID

		EXEC SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET @Cmp_ID=@Cmp_ID,@From_Date=@StartDate,@To_Date=@EndDate,@Branch_ID=@BranchID,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID =@Emp_ID,@Constraint='',@Report_for='Mobile In-Out'
		
		--SELECT @StartDate
		SELECT Month_St_Date,ISNULL(Cutoff_Date,Month_End_Date) as Month_End_Date 
		FROM T0200_MONTHLY_SALARY WITH (NOLOCK) 
		WHERE MONTH(Month_End_Date)= MONTH(@StartDate) AND YEAR(Month_End_Date) = YEAR(@StartDate) AND Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID 
		
		--SELECT @BranchID
		
		SELECT TOP 1 ISNULL(Inout_Days,0) Setting_Value FROM T0040_General_Setting 
		WHERE Cmp_Id=@Cmp_ID AND Branch_id =@BranchID AND For_Date = (
		SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=GETDATE() AND Cmp_ID = @Cmp_ID AND Branch_id = @BranchID)

	END
ELSE IF @Type = 'I'
	BEGIN
	 
	-- SET @IO_Tran_Id = 0
 	EXEC P0150_EMP_INOUT_RECORD_HOME @IO_Tran_Id OUTPUT,@Emp_ID,@Cmp_ID,@For_Date,@Reason,@Half_Full_Day,'Mobile',@Is_Cancel_Late_In,@Is_Cancel_Early_Out,@In_Date_Time,@Out_Date_Time,@Is_Approve,@Other_Reason
		 
		 --sELECT @@identity as id
 	SELECT @IO_Tran_Id
 
	END
	
ELSE IF @Type = 'E' -- Attendance Regularization Details
	BEGIN
		SELECT @Emp_ID = Emp_ID,@For_Date = For_Date FROM View_Late_Emp 
		WHERE IO_Tran_Id = @IO_Tran_Id
	
	
		SELECT Emp_ID,In_Time,Reason,Other_Reason,IO_Tran_Id,Emp_Full_Name,CONVERT(VARCHAR(11),For_Date,103) As 'For_date',
		Out_Time,Emp_Name,Is_Cancel_Late_In,Is_Cancel_Early_Out,Half_Full_Day,Cmp_ID 
		FROM View_Late_Emp 
		WHERE IO_Tran_Id = @IO_Tran_Id
		
		SELECT SM.Shift_St_Time,SM.Shift_End_Time,SM.Shift_Name,Q_W.* 
		FROM T0040_SHIFT_MASTER SM WITH (NOLOCK)
		RIGHT OUTER JOIN 
		(
			SELECT Q.Emp_ID,Q1.For_Date, Q1.Shift_ID
			FROM T0100_EMP_SHIFT_DETAIL Q1 WITH (NOLOCK)
			INNER JOIN 
			(
				SELECT MAX(For_Date) AS 'For_Date',Emp_ID 
				FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
				WHERE For_Date <= @For_Date AND Emp_ID = @Emp_ID 
				GROUP BY Emp_ID 
			)Q ON Q1.Emp_ID = Q.Emp_ID AND Q1.For_Date = Q.For_Date
		)Q_W ON SM.Shift_ID = Q_w.Shift_ID
		
		SELECT For_Date,Reason,Chk_By_Superior AS 'Application_Status', 0 AS 'Rpt_Level', App_Date As 'System_Date',In_Time,Out_Time 
		FROM View_Late_Emp 
		WHERE IO_Tran_Id = @IO_Tran_Id 
		
		UNION 
		
		SELECT For_date,S_Comment,Chk_By_Superior As 'Approval_Status',Rpt_Level,System_Date,In_Time,Out_Time 
		From T0115_AttendanceRegu_Level_Approval WITH (NOLOCK)
		Where IO_Tran_Id = @IO_Tran_Id 
		Order By Rpt_Level

	END
ELSE IF @Type = 'T' -- For Team Member List
	BEGIN
		EXEC SP_GET_DIRECT_INDIRECT_DOWNLINE_ESS @Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID	
	END
RETURN

