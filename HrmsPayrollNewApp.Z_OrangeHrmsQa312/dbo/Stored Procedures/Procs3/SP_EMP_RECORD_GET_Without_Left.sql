


---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_RECORD_GET_Without_Left]      
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
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		      and Increment_Effective_Date <= @To_Date 
		     
						order by Emp_ID
						
			delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment WITH (NOLOCK)
				where  Increment_effective_Date <= @to_date
				group by emp_ID)
				
		 --  select I.Emp_Id,I.Branch_ID from T0095_Increment I inner join       
			-- ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment      
			-- where Increment_Effective_date <= @To_Date      
			-- and Cmp_ID = @Cmp_ID      
			-- group by emp_ID  ) Qry on      
			-- I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date      
		 --  Where Cmp_ID = @Cmp_ID       
		 --  and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		 --  and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		 --  and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		 --  and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		 --  and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		 --  and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
		 --  and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)       
		 --  and I.Emp_ID in       
			--( select Emp_Id from      
			--(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry      
			--where cmp_ID = @Cmp_ID   and        
			--(( @From_Date  >= join_Date  and  @From_Date <= left_date )       
			--or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
			--or Left_date is null and @To_Date >= Join_Date)      
			--or @To_Date >= left_date  and  @From_Date <= left_date )   
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
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)  
		      and Increment_Effective_Date <= @To_Date 
		     
						order by Emp_ID
						
			delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment WITH (NOLOCK)
				where  Increment_effective_Date <= @to_date
				group by emp_ID)

			

		end    
  end    
  
  Declare @Show_Left_Employee_for_Salary as tinyint
  Set @Show_Left_Employee_for_Salary = 0
  
  Select @Show_Left_Employee_for_Salary = Isnull(Setting_Value,0) 
  From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Setting_Name like 'Show Left Employee for Salary'
  
   If @Show_Left_Employee_for_Salary = 0 
		Begin
    
		   Select I_Q.* ,E.Emp_Code, 
		   case @Emp_Search 
			when 0
				then cast( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
			when 1
				then  cast( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
			when 2
				then  cast( E.Alpha_Emp_Code as varchar)
			when 3
				then  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
			when 5
				then   e.Emp_Last_Name+' - '+e.Emp_First_Name
			when 4
				then  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
			end as Emp_Full_Name
		   ,Lo.Login_ID,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior      
			 ,E.Emp_Full_Name as Emp_Full_Name_Only,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
			 ,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left      
		  from T0080_EMP_MASTER E WITH (NOLOCK) inner join           
			T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID  inner join        
		   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join       
			( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)     
			where Increment_Effective_date <= @To_Date      
			and Cmp_ID = @Cmp_ID      
			group by emp_ID  ) Qry on      
			 I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  ) I_Q       
			on E.Emp_ID = I_Q.Emp_ID  inner join      
			 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN      
			 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN      
			 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN      
			 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN       
			 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID INNER JOIN     
			 T0011_Login LO  WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id      
		  WHERE E.Cmp_ID = @Cmp_Id   And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
		
		   ORDER BY 
			  Case @Emp_Search 
				When 3 Then
					e.Emp_First_Name
				When 4 Then
					e.Emp_First_Name
				Else
					 Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
					--RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
				End
		End				
	Else
		Begin
		   Select I_Q.* ,E.Emp_Code, 
		   case @Emp_Search 
			when 0
				then cast( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
			when 1
				then  cast( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
			when 2
				then  cast( E.Alpha_Emp_Code as varchar)
			when 3
				then  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
			when 4
				then  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
			end as Emp_Full_Name
		 ,Lo.Login_ID,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior      
			 ,E.Emp_Full_Name as Emp_Full_Name_Only,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
			 ,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left      
		  from T0080_EMP_MASTER E WITH (NOLOCK) inner join           
			T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID left outer join          
			T0100_LEFT_EMP EL WITH (NOLOCK) on E.Emp_Id=EL.Emp_Id inner join        
		   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join       
			( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)     
			where Increment_Effective_date <= @To_Date      
			and Cmp_ID = @Cmp_ID      
			group by emp_ID  ) Qry on      
			 I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  ) I_Q       
			on E.Emp_ID = I_Q.Emp_ID  inner join      
			 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN      
			 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN      
			 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN      
			 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN       
			 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID INNER JOIN     
			 T0011_Login LO WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id      
		  WHERE E.Cmp_ID = @Cmp_Id   And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
		   ORDER BY 
			  Case @Emp_Search 
				When 3 Then
					e.Emp_First_Name
				When 4 Then
					e.Emp_First_Name
				Else
					Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
					--RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
				End
		  
		End	
			
   
   
 RETURN


