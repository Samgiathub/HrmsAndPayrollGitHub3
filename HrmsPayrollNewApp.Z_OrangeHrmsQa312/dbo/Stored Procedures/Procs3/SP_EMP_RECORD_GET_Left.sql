


--SP_EMP_RECORD_GET 26,'01-jan-2009','31-jan-2009'
  ---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_RECORD_GET_Left] 
  @Cmp_ID  numeric  
 ,@From_Date  datetime  
 ,@To_Date  datetime   
 ,@Branch_ID  numeric   = 0  
 ,@Cat_ID  numeric  = 0  
 ,@Grd_ID  numeric = 0  
 ,@Type_ID  numeric  = 0  
 ,@Dept_ID  numeric  = 0  
 ,@Desig_ID  numeric = 0  
 ,@Emp_ID  numeric  = 0  
 ,@Constraint varchar(5000) = ''  
 ,@Emp_Search int= 0	 --Mukti(02062016)		
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
    
   
   
 Declare @Emp_Cons Table  
 (  
	  Emp_ID numeric , 
	 Branch_ID numeric
 )  
   
 if @Constraint <> ''  
  begin  
   Insert Into @Emp_Cons  
   select  cast(data  as numeric),cast(data  as numeric) from dbo.Split (@Constraint,'#')   
  end  
 else  
  begin  
     
     
   Insert Into @Emp_Cons  
  
   select I.Emp_Id,I.Branch_ID from T0095_Increment I WITH (NOLOCK) inner join   
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK) 
     where Increment_Effective_date <= @To_Date  
     and Cmp_ID = @Cmp_ID  
     group by emp_ID  ) Qry on  
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  
   Where Cmp_ID = @Cmp_ID   
   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))  
   and Branch_ID = isnull(@Branch_ID ,Branch_ID)  
   and Grd_ID = isnull(@Grd_ID ,Grd_ID)  
   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))  
   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))  
   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)   
    and I.Emp_ID in   
    ( select Emp_Id from  
    (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry  
    where cmp_ID = @Cmp_ID   and    
    (( @From_Date  >= join_Date  and  @From_Date <= left_date )   
    or ( @To_Date  >= join_Date  and @To_Date <= left_date )  
    or (Left_date is null and @To_Date >= Join_Date)  
    or @To_Date >= left_date  and  @From_Date <= left_date ))
   
     
  end    


  --Commented by Mukti(start)02062016      
  -- select I_Q.* ,E.Emp_Code, cast( E.Emp_Code as varchar) + ' - '+E.Emp_Full_Name as Emp_Full_Name,Emp_superior  
  --   ,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender  
  --   ,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address  
  --from T0080_EMP_MASTER E inner join   
    
  --  T0010_company_master Cm on E.Cmp_ID = Cm.Cmp_ID inner join  
  -- ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I inner join   
  --  ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment  
  --  where Increment_Effective_date <= @To_Date  
  --  and Cmp_ID = @Cmp_ID  
  --  group by emp_ID  ) Qry on  
  --   I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  ) I_Q   
  --  on E.Emp_ID = I_Q.Emp_ID  inner join  
  --   T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN  
  --   T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN  
  --   T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN  
  --   T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN   
  --   T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID   
  
  --WHERE E.Cmp_ID = @Cmp_Id   
  --  And E.Emp_ID in (select Emp_ID From @Emp_Cons) order by E.Emp_Code asc  
    
    --Added by Mukti(start)02062016
    SELECT   case @Emp_Search 
			when 0
				then cast( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
			when 1
				then  cast( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
			when 2
				then  cast( E.Alpha_Emp_Code as varchar)
			when 3
				then  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
			when 4
				then  e.Emp_First_Name + SPACE(1)+ e.Emp_Second_Name + SPACE(2)+ e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
			end as Emp_Full_Name,E.Emp_id,Dept_Name,Desig_Name,IS_Emp_FNF,Grd_Name,Branch_Name,Date_of_Join,le.left_Date,le.left_reason,I_Q.Branch_ID as Branch_id
				,E.Alpha_Emp_Code,Emp_superior,Gender,I_Q.CTC,I_Q.Grd_ID,I_Q.Desig_Id,I_Q.Dept_ID,Cat_Name,I_Q.Vertical_ID,I_Q.SubVertical_ID
			from T0080_EMP_MASTER E WITH (NOLOCK) inner join 
			T0100_left_emp le WITH (NOLOCK) ON E.emp_id = le.emp_ID inner join
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID,I.CTC from T0095_Increment I  WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id	 
				where Cmp_ID = @Cmp_ID) I_Q  --Changed by Hardik 09/09/2014 for Same Date Increment  'changed by Gadriwala Muslim 12012015
				on E.Emp_ID = I_Q.Emp_ID Left outer join				
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id Left outer join							
			T0030_CATEGORY_MASTER CM WITH (NOLOCK) ON I_Q.Cat_ID = CM.Cat_ID Left outer join
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID inner JOIN
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID and isnull(BM.IsActive,0)=1
		--	where le.left_date >= @From_date and le.left_Date <= @To_Date and 
			Where E.cmp_id=@cmp_id and E.Emp_Left='Y' 
		    and I_Q.Branch_ID = isnull(@Branch_ID ,I_Q.Branch_ID)
			and I_Q.Grd_ID = isnull(@Grd_ID ,I_Q.Grd_ID)
			and I_Q.Dept_ID = isnull(@Dept_ID ,I_Q.Dept_ID)
			--and isnull(I_Q.Dept_ID,0) = isnull(@Dept_ID ,isnull(I_Q.Dept_ID,0))
			and Isnull(I_Q.Type_ID,0) = isnull(@Type_ID ,Isnull(I_Q.Type_ID,0))
			and Isnull(I_Q.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I_Q.Desig_ID,0))
			and E.Emp_ID = isnull(@Emp_ID ,E.Emp_ID) 
			and le.Left_Reason <> 'Default Company Transfer'
			--Added By Jaina 6-10-2015 Start
			--and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') PB Where cast(PB.data as numeric)=Isnull(I_Q.Branch_ID,0))
			--and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=isnull(I_Q.Vertical_ID,0))
			--and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I_Q.SubVertical_ID,0))
			--and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I_Q.Dept_ID,0)) 
			--Added By Jaina 6-10-2015 End
			and Left_Date <=@To_Date		
			ORDER BY  --Added By Mukti Orderby clause 07/11/2014
			  Case @Emp_Search 
				When 3 Then
					e.Emp_First_Name
				When 4 Then
					e.Emp_First_Name
				Else
					Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
				When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
					Else e.Alpha_Emp_Code
				end
				
			end
			--Added by Mukti(end)02062016
 RETURN  
  
  


