


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_EMP_INOUT]
	@Cmp_ID    numeric        
	,@From_Date   datetime        
	,@To_Date    datetime         
	,@Branch_ID   numeric        
	,@Cat_ID    numeric         
	,@Grd_ID    numeric        
	,@Type_ID    numeric        
	,@Dept_ID    numeric        
	,@Desig_ID    numeric        
	,@Emp_ID    numeric        
	,@constraint   varchar(MAX)        
	,@Return_Record_set numeric = 1 
	,@StrWeekoff_Date varchar(Max)  =''
	,@Is_Split_Shift_Req tinyint = 0
	,@PBranch_ID	varchar(MAX)= '' --Added By Jaina 25-09-2015
	,@PVertical_ID	varchar(MAX)= '' --Added By Jaina 25-09-2015
	,@PSubVertical_ID	varchar(MAX)= '' --Added By Jaina 25-09-2015
	,@PDept_ID varchar(MAX)=''  --Added By Jaina 25-09-2015
	,@Late_SP tinyint = 0 -- Added by Gadriwala Muslim 28102015
	,@Call_For_Leave_Cancel numeric(18,2) = 0 --Added By Jaina 05-08-2016
	,@Reload_InOut BIT = 1
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	
	Declare @Sal_St_Date	Datetime
	Declare @Sal_end_Date   Datetime 
	Declare @OutOf_Days		NUMERIC 
	Declare @manual_salary_period as numeric(18,0) 

    IF @Branch_ID = 0  
		SET @Branch_ID = null
				
	IF @Emp_ID = 0  
		SET @Emp_ID = null
				
				
	IF @Branch_ID is null
		begin
			select @Branch_ID  = Branch_ID 
			from dbo.T0095_Increment EI WITH (NOLOCK)
			where Increment_ID in (select max(Increment_ID) as Increment_ID from dbo.T0095_Increment WITH (NOLOCK) where Increment_Effective_date <= @To_Date  
			and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID) 
			and Emp_ID = @Emp_ID	-- Ankit 12092014 for Same Date Increment
		End

	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @To_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End 
		
		
	if isnull(@Sal_St_Date,'') = ''    
		  begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			   set @OutOf_Days = @OutOf_Days			  			   
		  end  
		     
	 else if day(@Sal_St_Date) =1
		  begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			   set @OutOf_Days = @OutOf_Days    	         			   
		  end
		  		  
	else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
		  begin   
			if @manual_salary_period = 0 
			   begin
					set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
					set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
					set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
			   
					Set @From_Date = @Sal_St_Date
					Set @To_Date = @Sal_End_Date 			        
			   end 
			else
				begin
					select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)
					set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
					Set @From_Date = @Sal_St_Date
					Set @To_Date = @Sal_End_Date 				    				    
				end   
		  end
		  
	exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@constraint=@constraint,@Return_Record_set=1,@PBranch_ID=@PBranch_ID,@PVertical_ID=@PVertical_ID,@PSubVertical_ID=@PSubVertical_ID,@PDept_ID=@PDept_ID	

END

