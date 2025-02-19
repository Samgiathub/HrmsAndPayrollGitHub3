---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_CompOff]
	@Compoff_App_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(18,0),
	@SEmp_ID numeric(18,0),
	@ForDate Datetime,
	@Extra_Work_Date DATETIME,
	@Extra_Work_Hours VARCHAR(50),
	@Extra_Work_Reason VARCHAR(255),
	@Sanctioned_Hours VARCHAR(50),
	@CompOff_Type varchar(50),
	@IMEINo varchar(50),
	@OT_Type int,
	@Login_ID numeric(18,0),
	@Email varchar(50),
	@ContactNo varchar(50),
	@Approval_Status varchar(10),
	@Approval_Comments  VARCHAR(255),
	@Type Char(2),
	@Result VARCHAR(100) OUTPUT
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--DECLARE @ForDate Datetime

--SET @ForDate = CAST(GETDATE() AS varchar(11))
  
   
--IF @Type <> 'A' OR @Type <> 'I' -- Commented by Hardik 26/11/2019 as this #Table is not required for anyother Type which is confirmed by Ankita so no need to execute this query for other types
IF @Type = 'O' 
	BEGIN
		CREATE TABLE #CompOff_OT_Auto
		(
			CompOff_Tran_ID			numeric,
			Cmp_ID					numeric,
			Emp_ID					numeric,
			Branch_ID				numeric,
			For_Date				DATETIME,
			Shift_Hours				varchar(2000),
			Working_Hour			varchar(2000),
			Actual_Worked_Hrs       varchar(2000),
			OT_Hour					varchar(2000),
			In_Time_Actual			nvarchar(8),
			Out_Time_Actual         nvarchar(8),
			Is_Editable				tinyint,
			DayFlag					varchar(5),
			Application_Status		varchar(10),
			CompOff_Days			numeric(18,2)
		)
		EXEC GET_Applicable_Working_Date_For_CompOff @Cmp_ID = @Cmp_ID,@Branch_ID = 0,@Emp_ID = @Emp_ID,@For_Date = @ForDate,@constraint = '',@Sanctioned_Hours = '',@Search_Flag = 0,@with_table = 1
	END
IF @Type = 'O' -- For Get Over Time Date List for Comp-Off
	BEGIN
		SELECT * FROM #CompOff_OT_Auto
	END
ELSE IF @Type = 'I' -- For Comp-Off Application
	BEGIN
		BEGIN TRY
			EXEC P0100_COMPOFF_APPLICATION @Compoff_App_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@S_Emp_ID = @SEmp_ID,
			@CompOff_App_Date = @ForDate,@Extra_Work_Date = @Extra_Work_Date,@Extra_Work_Hours = @Extra_Work_Hours,
			@Application_Status = 'P',@Extra_Work_Reason = @Extra_Work_Reason,@Login_ID = @Login_ID,
			@System_Date = @ForDate,@Trans_Type='Insert',@CompOff_Type = @CompOff_Type,@User_Id = @Login_ID,
			@IP_Address = @IMEINo,@OT_Type = @OT_Type
			
			SET @Result = 'Comp-Off Application Done Successfully#True#'+ CAST(@Compoff_App_ID AS varchar(11)) 
			
		END TRY
		BEGIN CATCH  
			SET @Result = ERROR_MESSAGE() + '#False#'
		END CATCH
	END
IF @Type = 'E' -- For Get Comp-Off Application Details
	BEGIN
		SELECT VCA.Compoff_App_ID,VCA.Dept_ID,VCA.Emp_ID,VCA.S_Emp_ID,VCA.Emp_Full_Name,VCA.Mobile_No,VCA.Work_Email,
		VCA.Other_Email,VCA.Extra_Work_Date,VCA.Extra_Work_Hours,VCA.Extra_Work_Reason,VCA.Application_Status,
		VCA.Application_Date,VCA.Desig_Id,VCA.Branch_ID,VCA.Grd_ID,VCA.Alpha_Emp_Code,VCA.Sanctioned_Hours,VCA.Approve_Comments, --addedbyRonakb111223
		ISNULL(VCA.COMPOFF_TYPE,'') AS 'COMPOFF_TYPE'--,CO.COMPOFF_DAYS
		FROM V0110_COMPOFF_APPLICATION_DETAIL VCA
		--INNER JOIN #CompOff_OT_Auto CO ON VCA.Extra_Work_Date = CO.For_Date  -- Commented by Hardik 26/11/2019 as this #Table is not required for anyother Type which is confirmed by Ankita so no need to execute this query for other types
		WHERE COMPOFF_APP_ID = @COMPOFF_APP_ID --AND CMP_ID = @CMP_ID
	END
IF @Type = 'P' -- For Get Comp-Off Pending Application List
	BEGIN
		SELECT VC.Compoff_App_ID,VC.Emp_ID,VC.Emp_Full_Name,VC.Extra_Work_Date,VC.Extra_Work_Hours,VC.Application_Status,
		VC.SENIOR_EMPLOYEE,VC.Emp_First_Name,VC.Emp_code,VC.Branch_Name,VC.Desig_Name,VC.Alpha_Emp_Code,VC.Extra_Work_Reason,
		VC.CompOff_Type,VC.OT_Type--,CO.CompOff_Days
		FROM  V0110_COMPOFF_APPLICATION_DETAIL VC
		--INNER JOIN #CompOff_OT_Auto CO ON VC.Extra_Work_Date = CO.For_Date  -- Commented by Hardik 26/11/2019 as this #Table is not required for anyother Type which is confirmed by Ankita so no need to execute this query for other types
		INNER JOIN
		(
			SELECT ERD.EMP_ID
			FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) 
			INNER JOIN 
			(
				SELECT MAX(EFFECT_DATE) AS EFFECT_DATE,EMP_ID 
				FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
				WHERE ERD1.EFFECT_DATE <= GETDATE() AND EMP_ID IN 
				(
					SELECT EMP_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
					WHERE R_EMP_ID = @Emp_ID
				) GROUP BY EMP_ID 
			) TBL1 ON TBL1.EMP_ID = ERD.EMP_ID AND TBL1.EFFECT_DATE = ERD.EFFECT_DATE 
			WHERE ERD.R_EMP_ID = @Emp_ID 
		) QRY ON VC.EMP_ID = QRY.EMP_ID
		WHERE VC.APPLICATION_STATUS = 'P'
		ORDER BY VC.COMPOFF_APP_ID ASC
	END
ELSE IF @Type = 'A' -- For Comp-Off Approval
	BEGIN
	
		DECLARE @CompOff_Approval_ID numeric(18,0)
		BEGIN TRY
			
			Declare @Apr_status varchar(10)

			EXEC P0120_COMPOFF_APPROVAL @CompOff_Approval_ID OUTPUT,@CompOff_Application_ID = @Compoff_App_ID,@Cmp_ID = @Cmp_ID,
			@Emp_ID = @Emp_ID,@S_Emp_ID = @SEmp_ID,@Extra_Work_Date = @Extra_Work_Date,@Approval_Date = @ForDate,
			@Extra_Work_Hours = @Extra_Work_Hours,@Sanctioned_Hours = @Sanctioned_Hours,@Approval_Status = @Approval_Status,
			@Extra_Work_Reason = @Extra_Work_Reason,@Approval_Comments = @Approval_Comments,@Contact_No = @ContactNo,
			@Email_ID = @Email,@Login_ID = @Login_ID,@System_Date = @ForDate,@Tran_type = 'I',@User_Id = @Login_ID,@IP_Address = @IMEINo
			

			select @Apr_status = Approve_Status from T0120_CompOff_Approval where CompOff_Appr_ID = @CompOff_Approval_ID

			
				IF @CompOff_Approval_ID <> 0
				Begin
						If(@Apr_status = 'A')
						Begin 
								SET @Result = 'Comp-Off Approved Successfully#True#'+ CAST(@CompOff_Approval_ID AS VARCHAR(11))			
						End
						Else
						Begin 
								SET @Result = 'Comp-Off Rejected Successfully#True#'+ CAST(@CompOff_Approval_ID AS VARCHAR(11))
						End
				End

			
			
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE() + '#False#'
		END CATCH
	END
ELSE IF @Type = 'S' -- For Comp-Off Application Status
	BEGIN
		SELECT VC.Compoff_App_ID,VC.Emp_ID,VC.Emp_Full_Name,VC.Extra_Work_Date,VC.Extra_Work_Hours,
		VC.SENIOR_EMPLOYEE,VC.Emp_First_Name,VC.EMP_CODE,VC.BRANCH_NAME,VC.DESIG_NAME,VC.ALPHA_EMP_CODE,
		VC.Extra_Work_Reason,VC.CompOff_Type,VC.OT_Type,--CO.CompOff_Days,
		(CASE WHEN VC.Application_Status = 'P' THEN 'PENDING' ELSE CASE WHEN VC.Application_Status = 'A' THEN 'APPROVED' ELSE 'REJECTED' END END) AS 'Application_Status'
		FROM V0110_COMPOFF_APPLICATION_DETAIL VC
		--INNER JOIN #COMPOFF_OT_AUTO CO ON VC.EXTRA_WORK_DATE = CO.FOR_DATE  -- Commented by Hardik 26/11/2019 as this #Table is not required for anyother Type which is confirmed by Ankita so no need to execute this query for other types
		WHERE VC.Cmp_ID = @Cmp_ID AND VC.Emp_ID = @Emp_ID AND Extra_Work_Date >= @ForDate AND Extra_Work_Date <= @Extra_Work_Date --and Application_Status = 'P'
		ORDER BY VC.Compoff_App_ID ASC
	END
	ELSE IF @Type = 'D' -- For Comp-Off Application Delete
	BEGIN
		if Exists(Select CompOff_App_ID  from T0120_CompOff_Approval WITH (NOLOCK) Where CompOff_App_ID =@Compoff_App_ID and Cmp_ID=@Cmp_ID )
		BEGIN

			Set @Compoff_App_ID = 0
			 set @Result = 'Refrence exist can not delete !!'
			RETURN 
		End
	ELSE
		Begin

				

				Delete From T0100_CompOff_Application Where Compoff_App_ID = @Compoff_App_ID --For Hard Delete

				  set @Result = 'Record deleted succefully !!'

		End
	end  
	--Added by Yogesh on 24042023
	ELSE IF @Type = 'DE' -- For Comp-Off Application Delete
	BEGIN
	select @Cmp_ID,@Compoff_App_ID
		if Exists(Select CompOff_App_ID  from T0120_CompOff_Approval WITH (NOLOCK) Where CompOff_App_ID =@Compoff_App_ID and Cmp_ID=@Cmp_ID )
		BEGIN
		select 123
		    Delete From T0120_CompOff_Approval Where Compoff_App_ID = @Compoff_App_ID --For Hard Delete
			Update T0100_CompOff_Application set Application_Status='P' where Compoff_App_ID = @Compoff_App_ID
			 
			 set @Result = 'Record deleted succefully !!'
			
		End
	
	end  
	IF @Type = 'AL' -- For Get Comp-Off Pending Application List
	BEGIN
	
		SELECT VC.Compoff_App_ID,VC.Emp_ID,VC.Emp_Full_Name,VC.Extra_Work_Date,VC.Extra_Work_Hours,VC.Application_Status,
		VC.SENIOR_EMPLOYEE,VC.Emp_First_Name,VC.Emp_code,VC.Branch_Name,VC.Desig_Name,VC.Alpha_Emp_Code,VC.Extra_Work_Reason,
		VC.CompOff_Type,VC.OT_Type--,CO.CompOff_Days
		FROM  V0110_COMPOFF_APPLICATION_DETAIL VC
		--INNER JOIN #CompOff_OT_Auto CO ON VC.Extra_Work_Date = CO.For_Date  -- Commented by Hardik 26/11/2019 as this #Table is not required for anyother Type which is confirmed by Ankita so no need to execute this query for other types
		INNER JOIN
		(
			SELECT ERD.EMP_ID
			FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) 
			INNER JOIN 
			(
				SELECT MAX(EFFECT_DATE) AS EFFECT_DATE,EMP_ID 
				FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
				WHERE ERD1.EFFECT_DATE <= GETDATE() AND EMP_ID IN 
				(
					SELECT EMP_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
					WHERE R_EMP_ID = @Emp_ID
				) GROUP BY EMP_ID 
			) TBL1 ON TBL1.EMP_ID = ERD.EMP_ID AND TBL1.EFFECT_DATE = ERD.EFFECT_DATE 
			WHERE ERD.R_EMP_ID = @Emp_ID 
		) QRY ON VC.EMP_ID = QRY.EMP_ID
		WHERE VC.APPLICATION_STATUS = 'A'
		ORDER BY VC.COMPOFF_APP_ID ASC
	END
	IF @Type = 'RL' -- For Get Comp-Off Pending Application List
	BEGIN
	
		SELECT VC.Compoff_App_ID,VC.Emp_ID,VC.Emp_Full_Name,VC.Extra_Work_Date,VC.Extra_Work_Hours,VC.Application_Status,
		VC.SENIOR_EMPLOYEE,VC.Emp_First_Name,VC.Emp_code,VC.Branch_Name,VC.Desig_Name,VC.Alpha_Emp_Code,VC.Extra_Work_Reason,
		VC.CompOff_Type,VC.OT_Type--,CO.CompOff_Days
		FROM  V0110_COMPOFF_APPLICATION_DETAIL VC
		--INNER JOIN #CompOff_OT_Auto CO ON VC.Extra_Work_Date = CO.For_Date  -- Commented by Hardik 26/11/2019 as this #Table is not required for anyother Type which is confirmed by Ankita so no need to execute this query for other types
		INNER JOIN
		(
			SELECT ERD.EMP_ID
			FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) 
			INNER JOIN 
			(
				SELECT MAX(EFFECT_DATE) AS EFFECT_DATE,EMP_ID 
				FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
				WHERE ERD1.EFFECT_DATE <= GETDATE() AND EMP_ID IN 
				(
					SELECT EMP_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
					WHERE R_EMP_ID = @Emp_ID
				) GROUP BY EMP_ID 
			) TBL1 ON TBL1.EMP_ID = ERD.EMP_ID AND TBL1.EFFECT_DATE = ERD.EFFECT_DATE 
			WHERE ERD.R_EMP_ID = @Emp_ID 
		) QRY ON VC.EMP_ID = QRY.EMP_ID
		WHERE VC.APPLICATION_STATUS = 'R'
		ORDER BY VC.COMPOFF_APP_ID ASC
	END
	--Added by Yogesh on 24042023 END
