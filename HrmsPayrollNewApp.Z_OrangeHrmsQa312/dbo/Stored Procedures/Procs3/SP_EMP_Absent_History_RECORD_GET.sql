
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_Absent_History_RECORD_GET]      
     @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(5000)
	,@Report_For	varchar(50) = 'Absent History'	
	,@Type			numeric = 0           
AS   

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @Export_type as varchar(max)
	
	print convert(varchar(20), getdate(), 114) + ' : Step 1'
	
	declare @eval as varchar(max) 
	
	declare @Salary_Cycle_id numeric 
	Declare @Sal_St_Date   Datetime        
	Declare @Sal_end_Date   Datetime      
	declare @manual_salary_Period as numeric(18,0)  
	Declare @Month_St_Date datetime    
    declare @Month_End_Date datetime    
    
    set @Month_St_Date = @From_Date   
	set @Month_End_Date = @To_Date    
	
	declare @OutOf_Days numeric(18,2)    
	set @OutOf_Days = datediff(d,@From_Date,@To_date) + 1    
  
	SET @eval= ''
	SET @Export_type = ''
	SET @Salary_Cycle_id = 0
	
   select @Branch_ID = isnull(Branch_ID,0) from T0095_INCREMENT WITH (NOLOCK) where  Emp_ID = @Emp_ID and  Increment_Effective_Date = (
   SELECT max(Increment_Effective_Date) as effective_date from T0095_INCREMENT  WITH (NOLOCK)   
					where emp_id =@Emp_ID AND Increment_Effective_Date <=  @Month_End_Date    
					GROUP by emp_id
   )
   
  
	IF @Branch_ID = 0 
		SET @Branch_ID = NULL
	
	set @manual_salary_Period = 0  
	declare @is_salary_cycle_emp_wise as tinyint   
	set @is_salary_cycle_emp_wise = 0    
	
	select @is_salary_cycle_emp_wise = isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name = 'Salary Cycle Employee Wise'    
    
   if @is_salary_cycle_emp_wise = 1    
	    BEGIN  
			 if isnull(@Salary_Cycle_id,0) = 0
				begin
					 set @Salary_Cycle_id  = 0         
				     SELECT @Salary_Cycle_id = salDate_id from T0095_Emp_Salary_Cycle WITH (NOLOCK) where  emp_id = @Emp_ID AND effective_date in    
					(SELECT max(effective_date) as effective_date from T0095_Emp_Salary_Cycle  WITH (NOLOCK)   
					where emp_id =@Emp_ID AND effective_date <=  @Month_End_Date    
					GROUP by emp_id)          
				end
				SELECT @Sal_St_Date = SALARY_ST_DATE FROM t0040_salary_cycle_master WITH (NOLOCK) where tran_id = @Salary_Cycle_id   
		END  
   ELSE  
		 BEGIN  
			  If @Branch_ID is null    
			     Begin     
					select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0)    
					from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID        
					and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Cmp_ID = @Cmp_ID)        
			     End    
			  Else    
				Begin   
					select @Sal_St_Date  = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0)  
					from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID        
					and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)        
				End       
		  END  
        
        
			if isnull(@Sal_St_Date,'') = ''        
			begin         
					  set @From_Date  = @Month_St_Date         
				      set @To_Date = @Month_End_Date        
					  set @OutOf_Days = @OutOf_Days      
			end         
			else if day(@Sal_St_Date) =1 
			begin        
					  set @From_Date  = @Month_St_Date         
					  set @To_Date = @Month_End_Date        
				      set @OutOf_Days = @OutOf_Days     
			end         
			else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1       
			begin             
					if @manual_salary_Period = 0     
					Begin       
				        set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Month_St_Date) )as varchar(10)) as smalldatetime)        
						set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))     
						set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1    
						Set @From_Date = @Sal_St_Date    
						Set @To_Date = @Sal_End_Date     
					end    
				    else    
					begin       
						select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)                  
						Set @From_Date = @Sal_St_Date    
						Set @To_Date = @Sal_End_Date        
						set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1       
					End     
			End     
 

		
   CREATE table #Att_Muster_with_shift
				  (
						Emp_Id		numeric , 
						Cmp_ID		numeric,
						For_Date	datetime,
						Status		varchar(10),
						Leave_Count	numeric(5,1),
						WO_HO		varchar(3),
						Status_2	varchar(10),
						Row_ID		numeric ,
						WO_HO_Day	numeric(3,1) default 0,
						P_days		numeric(5,1) default 0,
						A_days		numeric(5,1) default 0,
						Join_Date	Datetime default null,
						Left_Date	Datetime default null,
						GatePass_Days numeric(18,2) default 0, --Added by Gadriwala Muslim 07042015
						Late_deduct_Days numeric(18,2) default 0,  --Added by Gadriwala Muslim 07042015
						Early_deduct_Days numeric(18,2) default 0,  --Added by Gadriwala Muslim 07042015
						shift_id	numeric
				  )
 
	insert into #Att_Muster_with_shift
	Exec SP_RPT_EMP_ATTENDANCE_MUSTER_GET @cmp_ID,@From_Date,@To_Date,@Branch_ID,@cat_ID,@grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,@Report_For,@export_type,@Type
	
	--added by Prapti for mobile Leave Application (25/08/2022)
	Drop Table IF Exists ##Privious_month_Record
	select Replace(Convert(varchar(25),For_Date,103),' ','/') as For_Date, 'AB-' + Convert(varchar(25),A_Days) as Status ,SUBSTRING(DATENAME(weekday, For_Date),1,3) as wday  into ##Privious_month_Record from #Att_Muster_with_shift


	select Replace(Convert(varchar(25),For_Date,103),' ','/') as For_Date, 'AB-' + Convert(varchar(25),A_Days) as Status ,SUBSTRING(DATENAME(weekday, For_Date),1,3) as wday  from #Att_Muster_with_shift

	
	
 RETURN      
      
      
      

