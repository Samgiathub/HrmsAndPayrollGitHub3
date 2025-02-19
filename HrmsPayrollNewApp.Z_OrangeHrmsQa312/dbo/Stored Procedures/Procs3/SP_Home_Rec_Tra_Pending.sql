


---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_Home_Rec_Tra_Pending]

	@Cmp_ID numeric(18,0),
	@S_Emp_ID numeric(18,0)
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Rec table
	(
	   List varchar(50),
	   Count1 numeric(18,2)
	)
	
	   insert into @Rec (List,Count1)
      
		 Select 'Recruitment',count(Resume_ID) as count1 from V0055_HRMS_Interview_Schedule where cmp_id=@Cmp_ID
       and  S_Emp_ID = @S_Emp_ID and Status =0
       
       
	
	     insert into @Rec (List,Count1)
	Select 'Training',count(Emp_ID) as count1 from V0130_HRMS_Traininig_Feedback_Super_Details where cmp_id=@Cmp_ID
       and  Posted_Emp_ID = @S_Emp_ID and Apr_Status ='A'
       
       Select * from @Rec
	
	RETURN




