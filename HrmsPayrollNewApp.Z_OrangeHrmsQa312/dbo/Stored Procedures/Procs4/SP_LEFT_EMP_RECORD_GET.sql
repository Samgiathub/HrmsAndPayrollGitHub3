

---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_LEFT_EMP_RECORD_GET]
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
 
 
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON   
       
      
 IF @Branch_ID = 0      
  SET @Branch_ID = null      
 IF @Cat_ID = 0      
  SET @Cat_ID = null      
 IF @Type_ID = 0      
  SET @Type_ID = null      
 IF @Dept_ID = 0      
  SET @Dept_ID = null      
 IF @Grd_ID = 0      
  SET @Grd_ID = null      
 IF @Emp_ID = 0      
  SET @Emp_ID = null      
 IF @Desig_ID = 0      
  SET @Desig_ID = null      
     
     Begin    
		
			select Distinct(E.Emp_ID),
					case @Emp_Search
					when 0
					     then CAST(Alpha_Emp_Code AS varchar) +	'-' +Emp_Full_Name
					when 1
					    then cast(Alpha_Emp_Code as varchar) + ' - '+ Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name
					when 2
						then  cast(Alpha_Emp_Code as varchar)
					when 3
						then  Initial+SPACE(1)+ Emp_First_Name+SPACE(1)+ Emp_Second_Name+SPACE(2)+Emp_Last_Name
					when 4
						then  Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name + ' - ' + cast(Alpha_Emp_Code as varchar)	
							end as Emp_Full_Name
					 ,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior      
					 ,E.Emp_Full_Name as Emp_Full_Name_Only,Dept_Name,Desig_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
					 ,BM.Comp_Name,BM.Branch_Address,E.Emp_Left      
					 ,I_Q.*
			from T0080_EMP_MASTER E WITH (NOLOCK)
				Left Outer join (
									Select MAX(Left_Date)Left_Date,Emp_ID 
										From T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)
									Where Cmp_ID = @Cmp_ID 
									Group by Emp_Id
								) Qry on E.Emp_ID = Qry.Emp_ID 
				Inner Join ( 
								select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
									from T0095_Increment I WITH (NOLOCK)
								inner join ( 
												select max(Increment_effective_Date) as For_Date , Emp_ID 
													from T0095_Increment WITH (NOLOCK)
												where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
												group by emp_ID  
											) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 
							) I_Q on E.Emp_ID = I_Q.Emp_ID 
				Left outer join T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
				Left outer join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
				INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
				inner JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
			Where E.cmp_id=@cmp_id 
		    and I_Q.Branch_ID = isnull(@Branch_ID ,I_Q.Branch_ID)
			and I_Q.Grd_ID = isnull(@Grd_ID ,I_Q.Grd_ID)
			and isnull(I_Q.Dept_ID,0) = isnull(@Dept_ID ,isnull(I_Q.Dept_ID,0))
			and Isnull(I_Q.Type_ID,0) = isnull(@Type_ID ,Isnull(I_Q.Type_ID,0))
			and Isnull(I_Q.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I_Q.Desig_ID,0))
			and E.Emp_ID = isnull(@Emp_ID ,E.Emp_ID) 
			and Left_Date <=@To_Date
			and E.Emp_Left = 'Y'
			ORDER BY  E.Emp_ID
			
				
	 End	 
