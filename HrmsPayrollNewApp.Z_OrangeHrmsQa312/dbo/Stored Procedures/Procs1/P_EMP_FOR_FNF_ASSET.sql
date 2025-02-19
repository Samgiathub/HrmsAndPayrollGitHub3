
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_EMP_FOR_FNF_ASSET]
	 @Tran_ID as numeric
	,@Emp_ID as numeric
	,@Cmp_ID as numeric
	,@Month_St_Date as datetime
	,@Month_End_Date as datetime
	,@Installment_Amount as numeric(18,2)
	,@Issue_Amount as numeric(18,2)
	,@AssetM_ID as numeric(18,0)
	,@Asset_Approval_ID as numeric(18,0)
	,@Sal_Tran_ID as numeric(18,0)
	,@tran_type varchar(1)
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Asset_Closing as numeric(18,2)
	DECLARE @Asset_Closing1 as numeric(18,2)
	DECLARE @Asset_Tran_ID as numeric(18,0)
	Declare @Branch_ID numeric
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime
	Declare @Left_Date		Datetime
--	Declare @Month_St_Date   Datetime    
	--Declare @Month_End_Date   Datetime
	
	If @tran_type  = 'I'
		Begin
		select @left_Date = Emp_Left_Date from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_Id
		
		Declare @check_month_End_Date Datetime
	set @check_month_End_Date = @month_End_Date
	
		If @Left_Date >= @Month_St_Date and @Left_Date <= @Month_End_Date
			Begin
				Set @check_month_End_Date = @Left_Date
			End

		
			select @Branch_ID = Branch_ID
		From T0095_Increment I WITH (NOLOCK) inner join     
		 ( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)    --Changed by Hardik 09/09/2014 for Same Date Increment
		 where Increment_Effective_date <= @Month_End_Date    
		 and Cmp_ID = @Cmp_ID    
		 group by emp_ID) Qry on    
		 I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id     --Changed by Hardik 09/09/2014 for Same Date Increment
	  Where I.Emp_ID = @Emp_ID    
  
	
			
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
			(SELECT max(effective_date) as effective_date from dbo.T0095_Emp_Salary_Cycle  WITH (NOLOCK)
			where emp_id = @Emp_Id AND effective_date <=  @Month_End_Date
			GROUP by emp_id)
			
			SELECT @Sal_St_Date = SALARY_ST_DATE FROM dbo.t0040_salary_cycle_master WITH (NOLOCK) where tran_id = @Salary_Cycle_id
			
		end
	else
		begin
			If @Branch_ID is null
				Begin 
					select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) -- added By rohit on 11022013
					  from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
					  and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Cmp_ID = @Cmp_ID)    
				End
			Else
				Begin
					select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) -- added By rohit on 11022013
					  from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
					  and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
				End
		end	 
	
	if @Left_Date >= @check_month_End_Date  
	begin
	if day(@Sal_St_Date) > 1    -- Added by mitesh on 14/03/2012 for 26 salary period getting problem
		begin
			if day(@left_date) >= day(@Sal_St_Date) 
				begin
					if month(@left_date) = 12
						begin
							--set @Month_St_Date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@left_date))) as nvarchar) + '/' + cast((YEAR(@left_date) + 1) as nvarchar) as datetime)
							set @Month_St_Date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@left_date))) as nvarchar) + '/' + cast((YEAR(@left_date) + 1) as nvarchar) as datetime)
						end
					else
						begin
							set @Month_St_Date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@left_date))) as nvarchar) + '/' + cast(YEAR(@left_date) as nvarchar) as datetime)
						end
				end
			else if day(@Month_End_Date) > day(@Sal_St_Date)
				begin
					set @Month_St_Date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@Month_St_Date))) as nvarchar) + '/' + cast(YEAR(@Month_St_Date) as nvarchar) as datetime)
				end
				
		end
	 end
	 
	 

if isnull(@Sal_St_Date,'') = ''    
	  begin    
		   set @Month_St_Date  = @Month_St_Date     
		   set @Month_End_Date = @Month_End_Date    
	  end     
 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
	  begin    
		   set @Month_St_Date  = @Month_St_Date     
		   set @Month_End_Date = @Month_End_Date    
		     
	  end     
 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
	  begin    
		   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Month_St_Date) )as varchar(10)) as smalldatetime)    
		   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
		   
		   Set @Month_St_Date = @Sal_St_Date
		   Set @Month_End_Date = @Sal_End_Date    
		  
	  end
			SELECT @Asset_Closing = ISNULL(SUM(Asset_Closing),0) from dbo.t0140_Asset_transaction  AT WITH (NOLOCK) INNER JOIN       
			(SELECT MAX(FOR_DATE) AS FOR_dATE , AssetM_ID ,EMP_ID from dbo.t0140_Asset_transaction  WITH (NOLOCK) WHERE  CMP_ID = @CMP_ID      
			AND FOR_DATE <= @Month_End_Date and AssetM_Id = @AssetM_Id and Emp_Id=@Emp_Id
			GROUP BY EMP_id ,AssetM_ID ) AS QRY  ON QRY.AssetM_ID  = AT.AssetM_ID      
			AND QRY.FOR_DATE = AT.FOR_DATE AND QRY.EMP_ID = AT.EMP_ID and AT.Emp_ID=@Emp_ID and AT.assetM_Id=@AssetM_ID and AT.ASSET_CLOSING > 0
									 
							set @Asset_Closing1=0
							set @Asset_Closing1=@Asset_Closing-@Installment_Amount
							
								
				 if @Issue_Amount >0 and @Asset_Closing > 0 
					begin
					
								--select @Asset_Tran_ID = isnull(max(Asset_Tran_ID),0) + 1  from T0140_Asset_Transaction
								--insert into T0140_Asset_Transaction(Asset_Tran_ID,Asset_Approval_ID,Cmp_ID,Emp_Id,AssetM_ID,Asset_Opening,Issue_Amount,Receive_Amount,Asset_Closing,For_Date,Sal_Tran_ID)
								--values(@Asset_Tran_ID,@Asset_Approval_ID,@Cmp_ID,@Emp_ID,@AssetM_ID,@Asset_Closing,@Issue_Amount,@Installment_Amount,@Asset_Closing1,@Month_End_Date,@Sal_Tran_ID)
					
					if not exists(select 1 from T0140_ASSET_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_ID and AssetM_ID=@AssetM_ID and FOR_DATE=@Month_End_Date and Asset_Approval_ID=@Asset_Approval_ID)
						begin
								select @Asset_Tran_ID = isnull(max(Asset_Tran_ID),0) + 1  from T0140_Asset_Transaction WITH (NOLOCK)
								insert into T0140_Asset_Transaction(Asset_Tran_ID,Asset_Approval_ID,Cmp_ID,Emp_Id,AssetM_ID,Asset_Opening,Issue_Amount,Receive_Amount,Asset_Closing,For_Date,Sal_Tran_ID)
								values(@Asset_Tran_ID,@Asset_Approval_ID,@Cmp_ID,@Emp_ID,@AssetM_ID,@Asset_Closing,@Issue_Amount,@Installment_Amount,@Asset_Closing1,@Month_End_Date,@Sal_Tran_ID)
						end
			    	else
						begin
								update T0140_Asset_Transaction
								set Receive_Amount=@Installment_Amount,
								Asset_closing=@Asset_Closing1,
								sal_tran_id=Sal_Tran_ID
								where cmp_id=@cmp_id and Asset_Approval_ID=@Asset_Approval_ID and AssetM_ID=@AssetM_ID and FOR_DATE=@Month_End_Date 
						end
					end
					
		End
	--Else if @Tran_Type = 'U'
	--	begin
		
		
	--	end
	--Else if @Tran_Type = 'D'
	--	begin
		
	--		--delete from EMP_FOR_FNF_ALLOWANCE where Tran_Id = @Tran_Id and Cmp_id = @Cmp_id and Emp_id = @Emp_id
				
	--	end

	RETURN




