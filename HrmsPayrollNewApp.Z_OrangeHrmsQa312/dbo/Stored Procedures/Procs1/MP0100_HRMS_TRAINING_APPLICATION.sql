

 ---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[MP0100_HRMS_TRAINING_APPLICATION]
	@Training_ID numeric(18,0),
	@Training_Desc varchar(150),
	@For_Date datetime,
	@Posted_Emp_ID numeric(18,0),
	@Skill_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Login_ID numeric(18,0),
	@Emp_ID varchar(255)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @ID Numeric(18,0)
	BEGIN
		EXEC P0100_HRMS_TRAINING_APPLICATION 0,@Training_ID,'',@Training_Desc,@For_Date,@Posted_Emp_ID,@Skill_ID,'',0,@Cmp_ID,@Login_ID,'I'
		
		IF @Emp_ID <> ''
			 select @Training_ID = MAX(Training_App_ID)  FROM T0100_HRMS_TRAINING_APPLICATION WITH (NOLOCK)
			BEGIN
				DECLARE EmpDetail_CURSOR CURSOR  Fast_forward FOR
				SELECT Data FROM dbo.Split (@Emp_ID,'#')
				OPEN EmpDetail_CURSOR
				FETCH NEXT FROM EmpDetail_CURSOR INTO @ID
				while @@fetch_status = 0
					BEGIN
						
						EXEC P0130_HRMS_TRAINING_EMPLOYEE_DETAIL 0,@Training_ID,NULL,@ID,0,@Cmp_ID,'I'
						 
						FETCH NEXT FROM EmpDetail_CURSOR INTO @ID
					END
				CLOSE EmpDetail_CURSOR
				DEALLOCATE EmpDetail_CURSOR
			END
	END
 

