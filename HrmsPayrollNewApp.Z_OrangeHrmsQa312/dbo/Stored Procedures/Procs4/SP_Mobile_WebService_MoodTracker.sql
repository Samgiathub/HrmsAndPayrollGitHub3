
---10/3/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_WebService_MoodTracker]
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(18,0),
	@Month Numeric(18,0),
	@Year Numeric(18,0),
	@Activity numeric(18,0) = 0,
	@MoodDetails Varchar(100) = '',
	@Type char(1),
	@Result varchar(100) OUTPUT --D:\SatishWorking\Working_Task\Task-110-Mood-Tracker
AS	
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Type = 'I'
	BEGIN
					insert into T0050_Mood_Activity_Transaction values (@Emp_ID,@Cmp_ID,@Activity,@MoodDetails,Getdate())
					SET @Result = 'Record Insert Successfully#True#'
					SELECT @Result
	END
	ELSE IF @Type = 'S'
	BEGIN
		--SELECT T.Cmp_Id,T.Emp_Id,Mood_Activity_Id,Mood_Details 
		--FROM T0050_Mood_Activity_Transaction T INNER JOIN 
		--					(SELECT Max(System_Date) as SystemDate,Cmp_Id,Emp_Id 
		--					  FROM T0050_Mood_Activity_Transaction
		--					  Where Emp_Id = @Emp_ID and Cmp_Id = @Cmp_ID
		--					  GROUP  BY emp_id,Cmp_Id
		--					)s on T.Emp_Id = s.Emp_Id and T.Cmp_Id = s.Cmp_Id and t.System_Date = s.SystemDate

		SELECT Cmp_Id,Emp_Id,Mood_Activity_Id,Mood_Details,System_Date 
		FROM T0050_Mood_Activity_Transaction WITH (NOLOCK) Where Emp_Id = @Emp_ID and Cmp_Id = @Cmp_ID and MONTH(System_Date) = @Month and YEAR(System_Date) = @Year
		order by Mood_Activity_Id desc

	END
END


