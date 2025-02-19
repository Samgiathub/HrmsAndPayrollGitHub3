
--exec P0210_Final_Retaining_Payment @Emp_ID = 12345, @Cmp_ID =120, @For_Date=''

CREATE PROCEDURE [dbo].[P0210_Final_Retaining_Payment]
     @Emp_ID	numeric(18, 0)
	,@Cmp_ID	numeric(18, 0)
	,@For_Date	datetime
	,@Hours	numeric(18, 2) = 0
	,@Retain_Amount	Numeric(18,2) = 0
	,@Esic	Numeric(18,2) = 0
	,@Net_Amount	numeric(18,2) = 0
	,@Ad_Id numeric(18,0)=0
	,@Modify_Date Datetime 
	,@tran_type varchar(1)
	,@Amount numeric(18,2) = 0
	,@Tds Numeric(18,2)=0
	,@PF_Amount Numeric(18,2)=0
	--,@str_LoanDetail Varchar(max) = ''
	,@Working_Days numeric(18,2) = 0 
	,@Calculate_On numeric(18,2) = 0  
	,@Ret_Tran_Id integer =0
	,@tran_id numeric(18, 0) =0 output
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--Added by nilesh patel on 07012017 --Start
	Declare @Pay_Tran_ID Numeric(18,0)
	Set @Pay_Tran_ID = 0 

	Declare @Branch_ID Numeric(18,0)
	Set @Branch_ID = 0

	Declare @Manual_Salary_Period Numeric(18,0)
	Set @Manual_Salary_Period = 0

	Declare @Sal_St_Date Datetime
	Declare @Sal_End_Date Datetime
	Declare @Month_St_Date Datetime
	Declare @Month_End_Date Datetime

		Select @Branch_ID = I_Q.Branch_ID  From T0080_EMP_MASTER EM WITH (NOLOCK)
		INNER JOIN (	Select I.Emp_Id,Branch_ID
						from T0095_Increment I WITH (NOLOCK) inner join 
							(
								SELECT MAX(Increment_ID) as Increment_ID , MI.Emp_ID  FROM T0095_INCREMENT MI WITH (NOLOCK) INNER join
								(	
									Select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
									Where Increment_Effective_date <= @For_Date
									And Emp_ID = @Emp_ID
									And Cmp_ID = @Cmp_ID 
									Group by emp_ID  
								) Qry on
								MI.Emp_ID = Qry.Emp_ID and MI.Increment_effective_Date = Qry.For_Date 
								GROUP BY MI.Emp_ID
							) As I_Q_1 
						 On I.Increment_ID = I_Q_1.Increment_ID AND I_Q_1.Emp_ID = I.Emp_ID 
					) I_Q
		ON I_Q.Emp_ID = EM.Emp_ID
		Where EM.EMp_ID = @Emp_ID

		--select @Manual_Salary_Period = Manual_Salary_Period,@Sal_St_Date = Sal_St_Date
		--			from T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@Branch_ID and For_date = (select max(for_date) From T0040_General_Setting  WITH (NOLOCK)    
		--			where Cmp_ID = @Cmp_ID and For_Date <=@For_Date and Branch_ID =@Branch_ID)  

		if isnull(@Sal_St_Date,'') = ''    
			begin    
				set @Month_St_Date  = dbo.GET_MONTH_ST_DATE(Month(@For_date),year(@For_date))     
				set @Month_End_Date = dbo.GET_MONTH_END_DATE(Month(@For_date),year(@For_date))  
			end     
		else if day(@Sal_St_Date) =1    
			begin    
					
				set @Month_St_Date  = dbo.GET_MONTH_ST_DATE(Month(@For_date),year(@For_date))      
				set @Month_End_Date = dbo.GET_MONTH_END_DATE(Month(@For_date),year(@For_date))  	       
					 
			end     
		else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
			begin    			   
				if @manual_salary_period = 0 
					begin
						set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@For_date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@For_date) )as varchar(10)) as smalldatetime)    
						set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
					   
						Set @Month_St_Date = @Sal_St_Date
						Set @Month_End_Date = @Sal_End_Date 
						Set @For_Date = @Sal_End_Date
					end 
				else
					begin
						select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@Month_St_Date) and YEAR=year(@Month_St_Date)
						Set @Month_St_Date = @Sal_St_Date
						Set @Month_End_Date = @Sal_End_Date 
						Set @For_Date = @Sal_End_Date
					end
				  end

	--Added by nilesh patel on 07012017 --End
	If @tran_type  = 'I' 
		Begin
			
		--	if exists (select emp_id from T0210_Final_Retaining_Payment WITH (NOLOCK) where Emp_ID =@Emp_ID and month(For_Date) = month(@For_Date) and YEAR(For_date) = YEAR(@For_Date) and isnull(Ad_id,0) = @ad_id)
		--		begin	
		--			delete from T0210_Final_Retaining_Payment where Emp_ID =@Emp_ID and month(For_Date) = month(@For_Date) and YEAR(For_date) = YEAR(@For_Date) and isnull(Ad_id,0) = @ad_id
		--		end
				
		--			INSERT INTO T0210_Final_Retaining_Payment
		--					  (Cmp_Id,Emp_Id,For_Date,Hours,Retain_Amount,Esic,Net_Amount,Ad_Id,Modify_Date,Comp_Esic,TDS,PF,Working_Days,Calculate_On,Ret_Tran_Id)
		--			VALUES     (@Cmp_Id,@Emp_Id,@For_Date,@Hours,@Retain_Amount,@Esic,@Net_Amount,@Ad_Id,@Modify_Date,@Amount,@Tds,@PF_Amount,@Working_Days,@Calculate_On,@Ret_Tran_Id)
					
		--			Select @Pay_Tran_ID = Tran_Id From T0210_Final_Retaining_Payment WITH (NOLOCK)
		--			Where Emp_Id = @Emp_Id and Month(For_Date) = Month(@Month_End_Date) and YEAR(For_Date) = YEAR(@Month_End_Date) and Ad_Id = @Ad_Id
		--End
		if exists (select emp_id from T0210_Final_Retaining_Payment WITH (NOLOCK) where Emp_ID =@Emp_ID and isnull(Ad_id,0) = @ad_id and Cmp_Id =@Cmp_ID)
				begin	
					delete from T0210_Final_Retaining_Payment where Emp_ID =@Emp_ID and isnull(Ad_id,0) = @ad_id and Cmp_Id =@Cmp_ID
				end
				
					INSERT INTO T0210_Final_Retaining_Payment
							  (Cmp_Id,Emp_Id,For_Date,Hours,Retain_Amount,Esic,Net_Amount,Ad_Id,Modify_Date,Comp_Esic,TDS,PF,Working_Days,Calculate_On,Ret_Tran_Id)
					VALUES     (@Cmp_Id,@Emp_Id,@For_Date,@Hours,@Retain_Amount,@Esic,@Net_Amount,@Ad_Id,@Modify_Date,@Amount,@Tds,@PF_Amount,@Working_Days,@Calculate_On,@Ret_Tran_Id)
					
					Select @Pay_Tran_ID = Tran_Id From T0210_Final_Retaining_Payment WITH (NOLOCK)
					Where Emp_Id = @Emp_Id and Cmp_Id =@Cmp_ID and Ad_Id = @Ad_Id
								
		
		End
	Else if @Tran_Type = 'U' 
		begin
			UPDATE    T0210_Final_Retaining_Payment
			SET    Hours=@Hours ,Retain_Amount = @Retain_Amount,Esic= @Esic 
			,Net_Amount=@Net_Amount,Ad_Id=@Ad_Id,Modify_Date=@Modify_Date
			,Comp_Esic=@Amount
			,TDS = @Tds
			,PF = @PF_Amount
			,Working_Days = @Working_Days --Added by Jaina 09-08-2017
			,Calculate_On = @Calculate_On,
			Ret_Tran_Id=@Ret_Tran_Id
			where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID And For_Date = @For_Date      				
		end
	Else if @Tran_Type = 'D' 
		begin
			Declare @Sal_Month Numeric
			Set @Sal_Month = 0
			Declare @Sal_Year Numeric
			Set @Sal_Year = 0

			If Month(@For_Date) = 12
				Begin
					Set @Sal_Month = 1
					Set @Sal_Year = Year(@For_Date) + 1
				End
			Else
				Begin
					Set @Sal_Month = Month(@For_Date) + 1
					Set @Sal_Year = Year(@For_Date)
				End
			
			if exists(SELECT 1 From T0210_Final_Retaining_Payment WITH (NOLOCK) Where Month(For_Date) = @Sal_Month AND Year(For_Date) = @Sal_Year AND Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID)
				BEGIN
					RAISERROR ('Next Month Payment Process Exists So You Can not Delete it.',16,1)
					--set @Tran_ID = -1
					return
				End
			--Added by Jaina 16-09-2017
			if exists(SELECT 1 FROM MONTHLY_EMP_BANK_PAYMENT WITH (NOLOCK) where Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_Id And Ad_Id=@ad_id
						AND MONTH(For_Date)=MONTH(@For_Date) AND YEAR(For_Date)=YEAR(@For_Date))
			BEGIN
					RAISERROR ('Payment Process Exists So You Can not Delete it.',16,1)
					return
			END	
			Select @Pay_Tran_ID = Tran_Id From T0210_Final_Retaining_Payment WITH (NOLOCK) where Emp_ID = @Emp_ID and Ret_Tran_Id = @Ret_Tran_Id and isnull(Ad_id,0) = @ad_id
			DELETE 	from T0210_Final_Retaining_Payment where Emp_ID = @Emp_ID and tran_id=@tran_id  and isnull(Ad_id,0) = @ad_id and Ret_Tran_Id= @Ret_Tran_Id
			
		end


	RETURN




	   
  




  









	 


