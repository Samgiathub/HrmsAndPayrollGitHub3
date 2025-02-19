


---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_LEAVE_ALL_Details]  
 @CMP_ID  NUMERIC ,  
 @EMP_ID  NUMERIC ,  
 @FOR_DATE DATETIME = null ,  
 @Leave_Application numeric(18,0) = 0, 
 @Leave_Encash_App_ID numeric(18,0) = 0,
 @RecordSet tinyint = 0
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	begin
		if (@RecordSet = 0 OR @RecordSet = 1)	--To get employee details(Email,Superior,etc)
			Select	Emp_full_name,Grd_id,Emp_Superior,P_Other_Mail,Other_Email,Work_Email,Emp_Full_Name_Superior,Emp_ID,Branch_ID,Desig_ID,Mobile_No,Dept_ID 
			from	V0080_Employee_master 
			where emp_Id = @EMP_ID and cmp_id = @CMP_ID
			
		if (@RecordSet = 0 OR @RecordSet = 2)	--To get leave closing 
			EXEC SP_LEAVE_CLOSING_AS_ON_DATE @CMP_ID,@EMP_ID,@FOR_DATE,@Leave_Application,@Leave_Encash_App_ID
		
		if (@RecordSet = 0 OR @RecordSet = 3)	--To get leave closing 
			EXEC SP_LEAVE_CLOSING_AS_ON_DATE_ALL @CMP_ID,@EMP_ID,@FOR_DATE,@Leave_Application,@Leave_Encash_App_ID
		
		if (@RecordSet = 0 OR @RecordSet = 4)	--To get last 3 leave details
			Select	top 3 LA.Emp_Full_Name,LA.Leave_Name,From_Date,To_Date 
			from	V0120_Leave_Approval LA  
					Left outer join (select sum(leave_Period) as Leave_Period,Leave_Approval_ID,Is_Approve 
									from	V0150_LEAVE_CANCELLATION 
									where	is_Approve = 1 
									group by Leave_Approval_id,Is_Approve
									) LC on LC.Leave_Approval_ID = LA.Leave_Approval_ID and LC.Leave_period = LA.Leave_Period 
			where	Approval_Status='A' and LA.Emp_ID=@EMP_ID and isnull(LC.Is_Approve,0) = 0 
			order by From_Date desc
			
		if (@RecordSet = 0 OR @RecordSet = 5)	-- TO GET PENDING LEAVE DETAILS LAST ONE MONTH ADDED BY RAJPUT ON 16042018
			
			IF EXISTS(SELECT 1 FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@CMP_ID AND Setting_Name='Display Pending Leave Application List in Leave Approval' AND Setting_Value='1')
			BEGIN	 
				 SELECT EMP_FULL_NAME,LEAVE_NAME,FROM_DATE,TO_DATE,(cast(LEAVE_PERIOD as varchar(128)) + ' ' + (CASE WHEN APPLY_HOURLY = 1 THEN 'hour(S)' ELSE 'day(s)' END)) as LEAVE_PERIOD,LEAVE_ASSIGN_AS
				 FROM V0110_LEAVE_APPLICATION_DETAIL WHERE EMP_ID=@EMP_ID AND FROM_DATE>=ISNULL(DATEADD(MONTH, -1, DATEADD(DAY, 1 - DAY(@FOR_DATE),  @FOR_DATE)),DATEADD(MONTH, -1, DATEADD(DAY, 1 - DAY( GETDATE()),  GETDATE()))) AND APPLICATION_STATUS = 'P' 
				 ORDER BY FROM_DATE DESC
			END
	End
