


---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREate PROCEDURE [dbo].[P0120_HRMS_Induction_Details_Aswini-19092023]
 @Induction_ID		INT OUTPUT
,@Cmp_ID		INT
,@Emp_ID	VARCHAR(MAX)		
,@Schedule_Date	datetime
,@From_Time	datetime
,@To_Time	datetime
,@Dept_Id	INT	
,@Contact_Person_ID	VARCHAR(MAX)	
,@Tran_type	CHAR(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 

IF @Tran_type = 'I'
	BEGIN		
		SELECT @Induction_ID = isnull(max(Induction_ID),0) + 1  FROM T0120_HRMS_Induction_Details WITH (NOLOCK)	
		
		INSERT INTO T0120_HRMS_Induction_Details (Induction_ID,Cmp_ID,Emp_ID,Schedule_Date,From_Time,To_Time,Dept_Id,Contact_Person_ID)
		VALUES(@Induction_ID,@Cmp_ID,@Emp_ID,@Schedule_Date,@From_Time,@To_Time,@Dept_Id,@Contact_Person_ID)			
	END		
ELSE IF @Tran_type = 'U'
	BEGIN 		
		    UPDATE T0120_HRMS_Induction_Details 
			SET Emp_ID = @Emp_ID,
				Schedule_Date = @Schedule_Date,
				From_Time=@From_Time,
				To_Time=@To_Time,
				Dept_Id=@Dept_Id,
				Contact_Person_ID=@Contact_Person_ID
			WHERE Induction_ID = @Induction_ID AND Cmp_ID = @Cmp_Id
	END
ELSE IF @Tran_Type = 'D' 			
	BEGIN
		DELETE FROM T0120_HRMS_Induction_Details WHERE Induction_ID = @Induction_ID			
	END			
	--exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Asset Master',@OldValue,@Asset_ID,@User_Id,@IP_Address

RETURN




