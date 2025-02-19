
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_FNF_RECORD_GET]  
  @Cmp_ID  numeric  
 ,@From_Date  datetime  
 ,@To_Date  datetime   
 --,@Branch_ID  numeric   = 0  
 --,@Cat_ID  numeric  = 0  
 --,@Grd_ID  numeric = 0  
 --,@Type_ID  numeric  = 0  
 --,@Dept_ID  numeric  = 0  
 --,@Desig_ID  numeric = 0
 ,@Branch_ID  varchar(max) = ''  
 ,@Cat_ID     varchar(max) = ''  
 ,@Grd_ID     varchar(max) = ''  
 ,@Type_ID    varchar(max) = ''  
 ,@Dept_ID    varchar(max) = ''  
 ,@Desig_ID   varchar(max) = '' 
 ,@Emp_ID  numeric  = 0  
 ,@Constraint varchar(MAX) = ''  
 ,@New_Join_emp numeric = 0   
 ,@Left_Emp  Numeric = 0  
 ,@Vertical_Id varchar(max)=''  --Added By Jaina 5-10-2015
 ,@SubVertical_Id varchar(max)=''   --Added By Jaina 5-10-2015
   
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
   
  CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
  exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'',@Vertical_Id,@SubVertical_Id,'',@New_Join_emp,@Left_Emp,0,'0',0,4  --Change By Jaina 5-10-2015

 /*	
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
    
   
    CREATE TABLE #Emp_Cons	-- Ankit 10092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
   
    EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0 ,0,@New_Join_emp,@Left_Emp
  */  
 --Declare @Emp_Cons Table  
 -- (  
 --  Emp_ID numeric  
 -- )  
   
 --if @Constraint <> ''  
 -- begin  
 --  Insert Into @Emp_Cons  
 --  select  cast(data  as numeric) from dbo.Split (@Constraint,'#')   
 -- end  
 --else   
 -- begin  
 --  Insert Into @Emp_Cons  
  
 --  select I.Emp_Id from T0095_Increment I inner join   
 --    ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment  
 --    where Increment_Effective_date <= @To_Date  
 --    and Cmp_ID = @Cmp_ID  
 --    group by emp_ID  ) Qry on  
 --    I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  
 --  Where Cmp_ID = @Cmp_ID   
 --  and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))  
 --  and Branch_ID = isnull(@Branch_ID ,Branch_ID)  
 --  and Grd_ID = isnull(@Grd_ID ,Grd_ID)  
 --  and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))  
 --  and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))  
 --  and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
 --  and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)   
 --  and I.Emp_ID in   
 --   ( select Emp_Id from  
 --   (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry  
 --   where cmp_ID = @Cmp_ID  )   
     
 -- end  
	
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime  
	
	If @Branch_ID = ''
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID 
			  --and Branch_ID = @Branch_ID 
			  and Branch_ID IN(select top 1 cast(data  as numeric) from dbo.Split (@Branch_ID,'#'))   
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date 
			  --and Branch_ID = @Branch_ID 
			  and Branch_ID IN(select top 1 cast(data  as numeric) from dbo.Split (@Branch_ID,'#'))
			  and Cmp_ID = @Cmp_ID)    
		End
       
	 if isnull(@Sal_St_Date,'') = ''    
		begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date    
		end     
	 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
		begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date    
		end     
	 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1    
		begin    
		   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
		   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
		   set @From_Date = @Sal_St_Date
		   Set @To_Date = @Sal_end_Date   
		End
	
	
    select I_Q.* ,E.Emp_Full_Name,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason,CM.cmp_logo,
    Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,@From_Date as From_Date ,@To_Date as To_Date  
        ,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,E.Mobile_No  
        ,E.Vertical_ID,E.SubVertical_ID  --Added By Jaina 7-10-2015
     from T0080_EMP_MASTER E WITH (NOLOCK) left outer join T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join  
      ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join   
        ( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  WITH (NOLOCK)  --Changed by Hardik 09/09/2014 for Same Date Increment
        where Increment_Effective_date <= @To_Date  
        and Cmp_ID = @Cmp_ID  
        group by emp_ID  ) Qry on  
        I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id  ) I_Q    --Changed by Hardik 09/09/2014 for Same Date Increment
       on E.Emp_ID = I_Q.Emp_ID  inner join  
        T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN  
        T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN  
        T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN  
        T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN   
        T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join   
        T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID  
  
     WHERE E.Cmp_ID = @Cmp_Id  And E.emp_ID in   
       --(select Emp_ID from T0200_Monthly_Salary where MOnth_St_Date >= @From_Date and Month_End_Date <= @To_Date and is_Fnf=1)-- Increment_Type='Increment')   
       --And E.Emp_ID in (select Emp_ID From @Emp_Cons) 
         (select Emp_ID from T0200_Monthly_Salary ms  WITH (NOLOCK) where  Month(ms.Month_End_Date) = Month(@To_Date) and Year(ms.Month_End_Date) = Year(@To_Date) and is_Fnf=1)-- Increment_Type='Increment')   
			And E.Emp_ID in (select Emp_ID From #Emp_Cons)  --Changed By Gadriwala 28112013
     
     Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
    --ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
    
 RETURN  
  
  
  

