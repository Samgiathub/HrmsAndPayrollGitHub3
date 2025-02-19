

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_NightHaltSlip_GET]        
 @Cmp_ID   numeric        
,@From_Date  datetime        
,@To_Date   datetime        
,@Branch_ID  numeric        
,@Cat_ID   numeric         
,@Grd_ID   numeric        
,@Type_ID   numeric        
,@Dept_ID   numeric        
,@Desig_ID   numeric        
,@Emp_ID   numeric        
,@constraint  varchar(max)        
,@Sal_Type  numeric =0        
,@Salary_Cycle_id numeric = 0
,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 24072013
,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 24072013
,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 24072013
,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 01082013	
AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

          
 IF @Branch_ID = 0          
  set @Branch_ID = null        
          
 IF @Cat_ID = 0          
  set @Cat_ID = null        
        
 IF @Grd_ID = 0          
  set @Grd_ID = null        
        
 IF @Type_ID = 0          
  set @Type_ID = null        
        
 IF @Dept_ID = 0          
  set @Dept_ID = null        
        
 IF @Desig_ID = 0          
  set @Desig_ID = null        
       
 IF @Emp_ID = 0          
  set @Emp_ID = null  
  
  if  @Segment_Id   =0
   set @Segment_Id = null
   
   if  @Vertical_Id =0 
   set @Vertical_Id = NULL
   
  if @SubVertical_Id = 0
   set @SubVertical_Id = NULL
   
   if @SubBranch_Id =0 
   set @SubBranch_Id = null
 --Added By Gadriwala Muslim on 24072013
  if @Segment_Id = 0 
  set @Segment_Id = null
  IF @Vertical_Id= 0 
  set @Vertical_Id = null
  if @SubVertical_Id = 0 
  set @SubVertical_Id= Null
   If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 01082013
	set @SubBranch_Id = null	
	

Declare @With_Arear_Amount tinyint

Set @With_Arear_Amount = 0

--Hardik 03/06/2013 for With Arear Report for Golcha Group
If @Sal_Type = 3 
	Begin
		Set @With_Arear_Amount = 1
		Set @Sal_Type = 0
	End
    
    
    CREATE TABLE #Emp_Cons -- Ankit 06092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
    
  Declare @Sal_St_Date   Datetime    
  Declare @Sal_end_Date   Datetime  
  
  declare @manual_salary_Period as numeric(18,0) 
  
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0) -- Comment and added By rohit on 11022013
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0) -- Comment and added By rohit on 11022013
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End  
		
	if @Salary_Cycle_id > 0
		begin
			select @Sal_St_Date = Salary_st_date from T0040_Salary_Cycle_Master WITH (NOLOCK) where Tran_Id = @Salary_Cycle_id
		end  
       
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
	    -- Comment and added By rohit on 11022013
	   --set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
	   --set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
	   --set @From_Date = @Sal_St_Date
	   --Set @To_Date = @Sal_end_Date   
	   if @manual_salary_Period =0 
			Begin
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   Set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_End_Date  
			 end
		else
			begin
				select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)							   
			     Set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_End_Date    
			End	   

	End 

 Select 
 MAD.*,        
 ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Grd_Name,Comp_Name,Branch_Address,EMP_CODE,Type_Name,Dept_Name,Desig_Name
,BM.Branch_ID , Alpha_Emp_Code
,CM.Cmp_Name ,Cm.Cmp_Address
,BM.Branch_Name,VS.Vertical_Name  
,E.Emp_First_Name   --added jimit 12062015
  From (select * from T0120_NIGHT_HALT_APPROVAL WITH (NOLOCK)
		where Eff_Month <> 0 --or Eff_Year<>0 Commented By Jimit As Effect_Year is not 0
		) MAD Inner join       
  T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN         
   #Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join         
   ( select I.Increment_ID, I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join         
     ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 06092014 for Same Date Increment       
     where Increment_Effective_date <= @To_Date        
     and Cmp_ID = @Cmp_ID        
     group by emp_ID  ) Qry on        
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q         
    on E.Emp_ID = I_Q.Emp_ID  inner join        
     T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN        
     T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN        
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN        
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join         
     T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  left Join 
     T0010_COMPANY_MASTER CM WITH (NOLOCK) on E.cmp_id = CM.Cmp_Id left join 
     T0040_Vertical_Segment VS WITH (NOLOCK) on E.Vertical_ID = VS.Vertical_ID 
  WHERE 
  E.Cmp_ID = @Cmp_Id  
  and dbo.GET_MONTH_ST_DATE (mad.Eff_Month,mad.Eff_Year)>=@From_Date  and dbo.GET_MONTH_ST_DATE (mad.Eff_Month,mad.Eff_Year) <=@To_Date        
  
  order by mad.From_Date 
            
 RETURN         
  

