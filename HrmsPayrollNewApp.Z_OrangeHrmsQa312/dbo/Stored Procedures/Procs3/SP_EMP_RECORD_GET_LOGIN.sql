


---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_RECORD_GET_LOGIN]      
  @Cmp_ID  numeric      
 ,@From_Date  datetime      
 ,@To_Date  datetime       
 ,@Branch_ID  numeric   
 ,@Cat_ID  numeric 
 ,@Grd_ID  numeric 
 ,@Type_ID  numeric  
 ,@Dept_ID  numeric  
 ,@Desig_ID  numeric 
 ,@Emp_ID  numeric 
 ,@Constraint varchar(5000) = '' 
 ,@Emp_Search int=0     
 ,@St_Date datetime = NULL
 ,@End_Date datetime = NULL
 ,@BSegment_ID numeric		= 0		--Added By Gadriwala 21102013
 ,@Vertical_ID numeric		= 0		--Added By Gadriwala 21102013
 ,@subVertical_ID numeric	= 0		--Added By Gadriwala 21102013
 ,@subBranch_ID numeric		= 0		--Added By Gadriwala 21102013
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

      
 if @Branch_ID = 0      
  set @Branch_ID = null      
 if @Cat_ID = 0      
  set @Cat_ID = null      
         
 if @Type_ID = 0      
  set @Type_ID = null      
 if @Dept_ID = 0      
  set @Dept_ID = null      
 if @Grd_ID = 0      
  set @Grd_ID = null      
 if @Emp_ID = 0      
  set @Emp_ID = null      
        
 If @Desig_ID = 0      
  set @Desig_ID = null      
 
 if @BSegment_ID = 0 
  set @BSegment_ID = null    
 if @Vertical_ID = 0				--Added By Gadriwala 21102013
  set @Vertical_ID = null
 if @subVertical_ID = 0				--Added By Gadriwala 21102013
  set @subVertical_ID = null
 if @subBranch_ID  = 0				--Added By Gadriwala 21102013
  set @subBranch_ID = null       
             
       
       
 CREATE table #Emp_Cons 
 (      
  Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )      
         
       
 if @Constraint <> ''      
  begin      
   Insert Into #Emp_Cons      
   select  cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) from dbo.Split (@Constraint,'#')       
  end      
 else      
  begin      
        
    if isnull(@St_Date,0) = 0 or isnull(@end_date,0) = 0
		begin 
		
		
		   Insert Into #Emp_Cons      
		      select emp_id,branch_id,Increment_ID from V_Emp_Cons where 
		      cmp_id=@Cmp_ID 
		       and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   and ISNULL(Segment_ID,0) = ISNULL(@BSegment_ID,isnull(Segment_ID,0)) --Added By Gadriwala 21102013
		   and ISNULL(Vertical_ID,0) = ISNULL(@vertical_id,isnull(Vertical_ID,0))		--Added By Gadriwala 21102013
		   and ISNULL(SubVertical_ID,0) = ISNULL(@subVertical_ID,isnull(SubVertical_ID,0)) --Added By Gadriwala 21102013
		   and ISNULL(subBranch_ID,0) = ISNULL(@subBranch_ID,isnull(subBranch_ID,0)) --Added By Gadriwala 21102013
		  
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		      and Increment_Effective_Date <= @To_Date 
		      and 
                      ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date ))
						order by Emp_ID
			
			Delete From #Emp_Cons Where Increment_ID Not In	--Ankit 30012014
				(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
			Where Increment_effective_Date <= @to_date)			
	
		end
	else
		begin
		
		   Insert Into #Emp_Cons      
		      select emp_id,branch_id,Increment_ID from V_Emp_Cons where 
		      cmp_id=@Cmp_ID 
		       and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
		   and ISNULL(Segment_ID,0) = ISNULL(@BSegment_ID,isnull(Segment_ID,0)) --Added By Gadriwala 21102013
		   and ISNULL(Vertical_ID,0) = ISNULL(@vertical_id,isnull(Vertical_ID,0))		--Added By Gadriwala 21102013
		   and ISNULL(SubVertical_ID,0) = ISNULL(@subVertical_ID,isnull(SubVertical_ID,0)) --Added By Gadriwala 21102013
		   and ISNULL(subBranch_ID,0) = ISNULL(@subBranch_ID,isnull(subBranch_ID,0)) --Added By Gadriwala 21102013
		 
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)  
		      and Increment_Effective_Date <= @To_Date 
		      and 
                     ( isnull(Left_date,@to_date) = @to_date or 
					(@St_Date <= isnull(left_date,@St_Date)  and @end_date >= isnull(left_date,@end_date) ) OR (join_Date <= @End_Date and isnull(left_date,@To_Date) = @To_Date)  ) 
						order by Emp_ID
			
			Delete From #Emp_Cons Where Increment_ID Not In	--Ankit 30012014
				(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
				Where Increment_effective_Date <= @to_date)	
			
		end    
  end    
  
 SELECT   case @Emp_Search 
			when 0
				then 
				case when isnull(Emp_Full_Name,'')='' then login_name + ' (Admin)' else cast(Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name end  
			when 1
				then 
				case when isnull(Emp_Full_Name,'')='' then login_name + ' (Admin)' else cast(Alpha_Emp_Code as varchar) + ' - '+  Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+ Emp_Last_Name end
			when 2
				then 
				case when isnull(Emp_Full_Name,'')='' then login_name + ' (Admin)' else  cast(Alpha_Emp_Code as varchar) end
			when 3
				then 
				case when isnull(Emp_Full_Name,'')='' then login_name + ' (Admin)' else  Initial+SPACE(1)+ Emp_First_Name+SPACE(1)+ Emp_Second_Name+SPACE(2)+ Emp_Last_Name end
		   when 4
				 THEN case when isnull(Emp_Full_Name,'')='' then login_name + ' (Admin)' else
				 Emp_First_Name+SPACE(1)+ Emp_Second_Name+SPACE(2)+ Emp_Last_Name + ' - ' + cast(Alpha_Emp_Code as varchar) END
		  end as Emp_Full_Name,
					  dbo.T0011_LOGIN.Login_Name, dbo.T0011_LOGIN.Login_Password, dbo.T0011_LOGIN.Login_ID, dbo.T0011_LOGIN.Cmp_ID, dbo.T0080_EMP_MASTER.Branch_ID,		--Changed from Login to Employee Master by Ramiz on 05/01/2015 for Last Login Activity
                      dbo.T0080_EMP_MASTER.Emp_ID, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Last_Name, 
                      dbo.T0080_EMP_MASTER.Other_Email, dbo.T0080_EMP_MASTER.Work_Email, 
                      dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      dbo.T0040_GRADE_MASTER.Grd_Name, CAST(dbo.T0080_EMP_MASTER.Emp_code AS varchar(50)) 
                      + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS Emp_Full_Name_NEw, CAST(dbo.T0080_EMP_MASTER.Emp_code AS VARCHAR(50)) AS EMP_CODE, 
                      dbo.T0011_LOGIN.Is_Default, dbo.T0011_LOGIN.Email_ID AS HR_Email_ID, dbo.T0011_LOGIN.Email_ID_Accou AS Acc_Email_ID, 
                      dbo.T0080_EMP_MASTER.Emp_Superior, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0011_LOGIN.Is_HR, dbo.T0011_LOGIN.Is_Accou, 
                      dbo.T0080_EMP_MASTER.Emp_Left, dbo.T0011_LOGIN.Login_Alias
FROM         dbo.T0040_GRADE_MASTER WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0011_LOGIN WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK) ON dbo.T0011_LOGIN.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID ON 
                      dbo.T0040_GRADE_MASTER.Grd_ID = dbo.T0080_EMP_MASTER.Grd_ID
                  where T0011_LOGIN.cmp_id=@Cmp_ID
order by Emp_ID,Emp_Full_Name 
	  
 RETURN      
      
      
    

