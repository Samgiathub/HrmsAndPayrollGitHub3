



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_emp_Membership_Detail] 

  @Membership_ID numeric(18,0) output,
  @Cmp_ID numeric(18,0),
  @Emp_ID numeric(18,0),
  @Membership_Date dateTime,
  @Relation_Employee numeric(18,0),
  @Tran_type char(1)
 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  if @Tran_Type ='I' 
  
		Begin 

		select @Membership_ID = isnull(max(Membership_ID),0) + 1 from T0090_Emp_Membership_Detail WITH (NOLOCK)
		
			insert into T0090_Emp_Membership_Detail(Membership_ID,Emp_ID,Cmp_ID,Membership_Date,Relation_Employee)
			values(@Membership_ID,@Emp_ID,@Cmp_ID,@Membership_Date,@Relation_Employee)
			
		End	
			
			  
		
  Else if @Tran_Type='U'
  
     Begin 
			Update T0090_Emp_Membership_Detail
			
					set Membership_ID =@Membership_ID,
						Emp_ID=@Emp_ID,
						Cmp_ID=@Cmp_ID,
						Membership_Date=@Membership_Date,
						Relation_Employee=@Relation_Employee
						 where Membership_ID=@Membership_ID
						
						
     end

			
  Else if @Tran_Type='D'
	
	Delete from T0090_Emp_Membership_Detail where Membership_ID=@Membership_ID
 
	
	RETURN

   
	RETURN




