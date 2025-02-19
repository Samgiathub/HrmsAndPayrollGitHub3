
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_AttendanceRegularization_Approve]

	@IO_Tran_Id numeric(18),
	@Emp_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
    @For_Date datetime,
    @Reason varchar(500),
    @Half_Full_Day Varchar(20),
    @Is_Cancel_Late_In int,
    @Is_Cancel_Early_Out int,
    @In_Date_Time datetime,
    @Out_Date_Time datetime,
    @Is_Approve tinyint = 0,
    @Sup_Comment varchar(max) = '',
    @S_Emp_ID numeric(18,0),
    @Rpt_Level int,
    @Final_Approve int,
    @Is_Fwd_Leave_Rej int,
    @Approval_Status varchar(20),
    @Type char(1),
    @Result varchar(255) OUTPUT

AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Tran_ID Numeric(18,0)
					 

IF @Type = 'I'
	BEGIN
		BEGIN TRY
			IF @Final_Approve = 1 OR (@Is_Fwd_Leave_Rej=0 AND @Approval_Status = 'R') 
				BEGIN
					
					EXEC UPDATE_EMP_INOUT_RECORD @IO_Tran_Id = @IO_Tran_Id,@Emp_ID = @Emp_ID,@Cmp_Id = @Cmp_ID,
					@Sup_Comment = @Sup_Comment,@Approved = @Approval_Status,@Is_Cancel_Late_In = @Is_Cancel_Late_In,
					@Is_Cancel_Early_Out = @Is_Cancel_Early_Out,@Half_Full_day_Manager = @Half_Full_Day,
					@In_Date_Time = @In_Date_Time,@Out_Date_Time = @Out_Date_Time
				END
			
			EXEC P0115_AttendanceRegul_Level_Approval @Tran_ID OUTPUT,@IO_Tran_Id = @IO_Tran_Id,@Emp_ID = @Emp_ID,
			@Cmp_ID = @Cmp_ID,@Sup_Comment=@Sup_Comment,@Is_Cancel_Late_In=@Is_Cancel_Late_In,@Is_Cancel_Early_Out=@Is_Cancel_Early_Out,
			@Half_Full_day_Manager = @Half_Full_Day,@In_Date_Time=@In_Date_Time,@Out_Date_Time=@Out_Date_Time,
			@Chk_By_Superior = @Is_Approve,@S_Emp_ID = @S_Emp_ID,@Rpt_Level = @Rpt_Level
			
			IF @Tran_ID <> 0
				BEGIN
					IF @Approval_Status = 'R'
						BEGIN
							SET @Result = 'Attendance Regularization Rejected Successfully:True'
						END
					ELSE
						BEGIN
							SET @Result = 'Attendance Regularization Approved Successfully:True'
						END
				
				END
				
			
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+':False'
		END CATCH
	END

