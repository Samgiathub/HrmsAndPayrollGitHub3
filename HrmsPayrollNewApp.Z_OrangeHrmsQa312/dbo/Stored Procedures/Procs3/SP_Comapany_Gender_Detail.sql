



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Comapany_Gender_Detail]

	@Cmp_ID numeric(18,0)
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	 
	 
	 Declare @Gender table
	 (
	      Cmp_ID numeric(18,0),
	      Male numeric(18,0),
              Female numeric(18,0),
	      Emp_left numeric(18,0)
	 )
	 
	 Insert into @Gender (Male,Female,Cmp_ID,Emp_left)
	 Select Count(Emp_ID) as Emp_ID,0,Cmp_ID,0 from T0080_emp_Master WITH (NOLOCK) where cmp_id=@Cmp_ID and Emp_left='N' and Gender='M'
          group by Cmp_ID,Gender,Emp_left
	
          
      
         Declare @Female_Count as numeric(18,0)
	  Declare @Left_Count as numeric(18,0)
         Select   @Female_Count = Count(Emp_ID) from  T0080_emp_Master WITH (NOLOCK) where cmp_id=@Cmp_ID and Emp_left='N' and Gender='F'

	 Select   @Left_Count = Count(Emp_ID) from  T0080_emp_Master WITH (NOLOCK) where cmp_id=@Cmp_ID and Emp_left='Y' 

  
         Update @Gender
          set Female = @Female_Count
	

          Update @Gender
          set Emp_Left = @Left_Count
        

         Select * from @Gender
           
	RETURN




