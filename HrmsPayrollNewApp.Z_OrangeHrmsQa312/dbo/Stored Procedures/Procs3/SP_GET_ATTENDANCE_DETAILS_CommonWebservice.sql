

 
 -- Exec SP_GET_ATTENDANCE_DETAILS_CommonWebservice 'A5653',11,2020,'W#P#P#P#P#P#P#W#P#P#P#P#P#HO#W#HO#P#P#P#P##W##P#P#P#P#HO#W#P#',0
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[SP_GET_ATTENDANCE_DETAILS_CommonWebservice]
	@EMP_CODE varchar(50),
	@Month int,
	@Year int,
	@Att_Detail nvarchar(4000),
	@Login_Id Int
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Cmp_ID numeric(18,0)
DECLARE @Emp_ID numeric(18,0)
SELECT @Cmp_ID = Cmp_ID,@Emp_ID = Emp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code = @Emp_Code
--SELECT  Cmp_ID, Emp_ID FROM T0080_EMP_MASTER WHERE Alpha_Emp_Code = 'A5653'
--SET @Cmp_ID = (SELECT Cmp_ID FROM T0080_EMP_MASTER WHERE Alpha_Emp_Code = @Emp_Code)
IF @Cmp_ID IS NULL 
	BEGIN 
		SELECT 'Please Enter Valid Employee Code'
		RETURN 
	END

/* Previously it was  "Month(Month_End_Date)=@Month" but as Aphc is Working on Cutoff Date , we will allow last Month Attendance to be Synced */
	IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND month(Month_End_Date)= @Month + 1 and Year(Month_End_Date)=@Year)
		BEGIN
			SELECT 'Monthly salary Exists ' + ' Emp_Code='+@EMP_CODE +', Month='+cast(@Month as varchar)+', Year='+cast(@Year as varchar)
			RETURN
		END
	ELSE
		BEGIN
			EXEC P0170_EMP_ATTENDANCE_IMPORT @EMP_CODE,@Cmp_ID,@Month,@Year,@Att_Detail,'#################################',@Login_Id,0
		END
	
	
--IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND month(Month_End_Date)=@Month and Year(Month_End_Date)=@Year)
--	BEGIN
--		SELECT 'Monthly salary Exists ' + ' Emp_Code='+@EMP_CODE +', Month='+cast(@Month as varchar)+', Year='+cast(@Year as varchar)
--		RETURN
--	END
--ELSE
--	BEGIN
--		EXEC P0170_EMP_ATTENDANCE_IMPORT @EMP_CODE,@Cmp_ID,@Month,@Year,@Att_Detail,'#################################',@Login_Id,0
--	END
RETURN



