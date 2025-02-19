




CREATE PROCEDURE [dbo].[P_EMP_FOR_FNF_ALLOWANCE]
	 @Tran_ID as numeric
	,@Emp_ID as numeric
	,@Cmp_ID as numeric
	,@From_date as datetime
	,@To_date as datetime
	,@AD_ID as numeric
	,@Amount as numeric(12,2)
	,@AD_Flag varchar(1)
	,@tran_type varchar(1)
	,@Comments nvarchar(500) = ''  --Added by Jaina 27-06-2017
	
	
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON



	     Declare @Branch_ID numeric
		 Declare @Sal_St_Date   Datetime    
		 Declare @Sal_end_Date   Datetime
		 Declare @Left_Date		Datetime
		 
	-- Added by rohit For Fnf Generate for Next Month on 13062013
	Declare @check_month_End_Date Datetime
	set @check_month_End_Date = @To_date
	-- Ended by rohit on 13062013   
		
		select @Branch_ID = Branch_ID
		From T0095_Increment I WITH (NOLOCK) inner join     
		 ( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)    --Changed by Hardik 09/09/2014 for Same Date Increment
		 where Increment_Effective_date <= @To_date    
		 and Cmp_ID = @Cmp_ID    
		 group by emp_ID) Qry on    
		 I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id     --Changed by Hardik 09/09/2014 for Same Date Increment
	  Where I.Emp_ID = @Emp_ID    
  
	select @left_Date = Emp_Left_Date from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_Id

 declare @manual_salary_period as numeric(18,0)
 set @manual_salary_period = 0
 
  declare @is_salary_cycle_emp_wise as tinyint -- added by mitesh on 03072013
   set @is_salary_cycle_emp_wise = 0
   
   select @is_salary_cycle_emp_wise = isnull(Setting_Value,0) from dbo.T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name = 'Salary Cycle Employee Wise'
   
   
   
	if @is_salary_cycle_emp_wise = 1
		begin
			declare @Salary_Cycle_id as numeric
			set @Salary_Cycle_id  = 0
			
			SELECT @Salary_Cycle_id = salDate_id from dbo.T0095_Emp_Salary_Cycle WITH (NOLOCK) where emp_id = @Emp_Id AND effective_date in
			(SELECT max(effective_date) as effective_date from dbo.T0095_Emp_Salary_Cycle WITH (NOLOCK)
			where emp_id = @Emp_Id AND effective_date <=  @To_Date
			GROUP by emp_id)
			
			SELECT @Sal_St_Date = SALARY_ST_DATE FROM dbo.t0040_salary_cycle_master WITH (NOLOCK) where tran_id = @Salary_Cycle_id
			
		end
	else
		begin
			If @Branch_ID is null
				Begin 
					select Top 1 @Sal_St_Date  = Sal_st_Date 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_date and Cmp_ID = @Cmp_ID)    
				End
			Else
				Begin
					select @Sal_St_Date  =Sal_st_Date 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
				End 
		END
   
   
    if @Left_Date >= @check_month_End_Date  
		begin
			if day(@Sal_St_Date) > 1    -- Added by mitesh on 14/03/2012 for 26 salary period getting problem
				begin
					if day(@left_date) >= day(@Sal_St_Date) 
						begin
							if month(@left_date) = 12
								begin
									--set @Month_St_Date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@left_date))) as nvarchar) + '/' + cast((YEAR(@left_date) + 1) as nvarchar) as datetime)
									set @From_date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@left_date))) as nvarchar) + '/' + cast((YEAR(@left_date) + 1) as nvarchar) as datetime)
								end
							else
								begin
									set @From_date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@left_date))) as nvarchar) + '/' + cast(YEAR(@left_date) as nvarchar) as datetime)
								end
						end
					else if day(@To_date) > day(@Sal_St_Date)
						begin
							set @From_date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@From_date))) as nvarchar) + '/' + cast(YEAR(@From_date) as nvarchar) as datetime)
						end
				
				end
			End	
   
	 if isnull(@Sal_St_Date,'') = ''    
		  begin    
			   set @From_date  = @From_date   
			   set @To_date = @To_date    
			   
		  end     
	 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
		  begin    
			   set @From_date  = @From_date     
			   set @To_date = @To_date    
			   	         
		  end     
	 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
		  begin    
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
			   			   
			   Set @From_date = @Sal_St_Date
			   Set @To_date = @Sal_End_Date    
		  end
	
	
	
	If @tran_type  = 'I'
		Begin
			
			SELECT @Tran_Id = ISNULL(MAX(Tran_ID),0) + 1 FROM dbo.EMP_FOR_FNF_ALLOWANCE WITH (NOLOCK)  
			
			if exists ( Select Tran_id from EMP_FOR_FNF_ALLOWANCE WITH (NOLOCK) where Emp_id = @Emp_id and AD_Flag = @AD_Flag and AD_Id = @AD_Id and For_Date = @From_date)
				begin
					
					select @Tran_ID = Tran_id from EMP_FOR_FNF_ALLOWANCE WITH (NOLOCK) where Emp_id = @Emp_id and AD_Flag = @AD_Flag and AD_Id = @AD_Id and For_Date = @From_date
					
					UPDATE   EMP_FOR_FNF_ALLOWANCE
						SET   Amount = @Amount, Comments=@Comments   --Added by Jaina 27-06-2017 							 
					where Tran_Id = @Tran_Id and Emp_id = @Emp_id and AD_Flag = @AD_Flag and AD_Id = @AD_Id and For_Date = @From_date
					
				end
			else
				begin
					
					INSERT INTO EMP_FOR_FNF_ALLOWANCE
                      (Tran_Id, Cmp_id, Emp_id, AD_Id, For_Date, Amount, AD_Flag,Comments)
					VALUES     (@Tran_Id,@Cmp_id,@Emp_id,@AD_Id,@From_date,@Amount,@AD_Flag,@Comments)
						
				end

      
		End
	Else if @Tran_Type = 'U'
		begin
		
			UPDATE   EMP_FOR_FNF_ALLOWANCE
			    SET   Amount = @Amount, Comments=@Comments   --Added by Jaina 27-06-2017                      
             where Tran_Id = @Tran_Id and Emp_id = @Emp_id and AD_Flag = @AD_Flag and AD_Id = @AD_Id and For_Date = @From_date

		end
	Else if @Tran_Type = 'D'
		begin
		
			delete from EMP_FOR_FNF_ALLOWANCE where Tran_Id = @Tran_Id and Cmp_id = @Cmp_id and Emp_id = @Emp_id
				
		end

	RETURN




