


---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Graphics_Comapany_Gender_Detail]

	@Cmp_ID numeric(18,0),
	@Branch_ID  numeric(18,0),
	@Grd_ID numeric(18,0),
	@Dept_ID numeric(18,0),
	@from_Date datetime,
	@To_date datetime,
	@Flag Char = '0'
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	 
	 if @Branch_ID = 0
	  set @Branch_ID = null
	  
	  if @Grd_ID =0 
	   set @Grd_ID = null
	  
	  if @Dept_ID =0 
	   set @Dept_ID = null 
	 
	 Declare @Gender table
	 (
	      Cmp_ID numeric(18,0),
	      Male numeric(18,0),
          Female numeric(18,0),
	      Emp_left numeric(18,0)
	 )
	 
	 Insert into @Gender (Male,Female,Cmp_ID,Emp_left)
	 Select Count(Emp_ID) as Emp_ID,0,Cmp_ID,0 from T0080_emp_Master WITH (NOLOCK) where cmp_id=@Cmp_ID and Emp_left='N' and Gender='M'
	 and Date_Of_Join between @From_date AND @To_date	
	 
	   and Branch_ID = isnull(@Branch_ID ,Branch_ID) 
	    and Grd_ID = isnull(@grd_ID ,Grd_ID)  
	       and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
          group by Cmp_ID,Gender,Emp_left
	
          
      
         Declare @Female_Count as numeric(18,0)
	  Declare @Left_Count as numeric(18,0)
         Select   @Female_Count = Count(Emp_ID) from  T0080_emp_Master WITH (NOLOCK) where cmp_id=@Cmp_ID and Emp_left='N' and Gender='F'
            and Branch_ID = isnull(@Branch_ID ,Branch_ID) 
              and Grd_ID = isnull(@grd_ID ,Grd_ID) 
                and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
            and Date_Of_Join between @From_date AND @To_date	 

	 Select   @Left_Count = Count(Emp_ID) from  T0080_emp_Master WITH (NOLOCK) where cmp_id=@Cmp_ID and Emp_left='Y' 
	  and Branch_ID = isnull(@Branch_ID ,Branch_ID) 
	   and Grd_ID = isnull(@grd_ID ,Grd_ID) 
	     and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	  and Date_Of_Join between @From_date AND @To_date	

  
         Update @Gender
          set Female = @Female_Count
	

          Update @Gender
          set Emp_Left = @Left_Count
        
		if @Flag = '0'
			Begin
				Select * from @Gender
			End
         
         if @Flag = 'M'
			Begin
				Select Alpha_Emp_Code,Emp_Full_Name,CONVERT(varchar(11),Date_Of_Join,103) as Date_Of_Join ,Desig_Id,Dept_ID
				from T0080_emp_Master WITH (NOLOCK)
				where cmp_id=@Cmp_ID and Emp_left='N' and Gender='M'
				 and Date_Of_Join between @From_date AND @To_date
				 and Branch_ID = isnull(@Branch_ID ,Branch_ID) 
				 and Grd_ID = isnull(@grd_ID ,Grd_ID)  
				 and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) 
			End
		if @Flag = 'F'
			Begin
				Select Alpha_Emp_Code,Emp_Full_Name,CONVERT(varchar(11),Date_Of_Join,103) as Date_Of_Join,Desig_Id,Dept_ID
				from T0080_emp_Master WITH (NOLOCK)
				where cmp_id=@Cmp_ID and Emp_left='N' and Gender='F'
				 and Date_Of_Join between @From_date AND @To_date
				 and Branch_ID = isnull(@Branch_ID ,Branch_ID) 
				 and Grd_ID = isnull(@grd_ID ,Grd_ID)  
				 and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) 
			End
           
	RETURN


