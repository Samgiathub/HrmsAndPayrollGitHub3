

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_LOAN_INTEREST_PAYMENT]
	@CMP_ID			NUMERIC ,
	@EMP_ID			NUMERIC,
	@From_Date		Datetime,
	@To_Date		DATETIME,
	@SALARY_TRAN_ID	NUMERIC,
	@Is_Fnf NUMERIC = 0
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Loan_Id			as NUMERIC
	DECLARE @Pending_Loan		as NUMERIC(27,5)
	DECLARE @Loan_Inst			as NUMERIC(27,5)
	DECLARE @Loan_Inst_Amount	as NUMERIC(27,5)
	DECLARE @Loan_Payment_Id	as NUMERIC
	DECLARE @TotalInst_Amount	as NUMERIC(27,5)
	DECLARE @TotLoan_Closing	as NUMERIC(27,5)
	DECLARE @Interest_Percent	as NUMERIC(10,5)
	DECLARE @Loan_Apr_ID		as NUMERIC
	DECLARE @Loan_apr_Deduct_From_sal NUMERIC
	DECLARE @Return_Amount		as NUMERIC(27,5)
	DECLARE @Loan_Apr_Amount	as NUMERIC(27,5)
	DECLARE @Pre_Approval_Id	as NUMERIC
	DECLARE @Pre_Payment_Id		as NUMERIC
	DECLARE @Deduction_Type		as VARCHAR(20)
	
	Declare @Desig_ID numeric(18,0)					  --Added by Gadriwala Muslim 26122014

	Declare @Is_First_Ded_Priciple_Amt as numeric(18,0) 
	Declare @Loan_Int_Install_Amount as numeric(18,0)


	DECLARE @Loan_Interest_Amount	 NUMERIC(27,2)
	DECLARE @Interest_Type			 VARCHAR(20)
	DECLARE @Loan_Apr_Date			 DATETIME 

---Test Loan
	Declare @MonthDays As Numeric
	Declare @LoanDays As Numeric
	Declare @Branch_ID_Temp As Numeric
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime   
	Declare @Month_St_Date  Datetime
	Declare @Month_End_Date  Datetime
	Declare @Last_Closing_Balance Numeric
	Declare @Loan_Apr_Pending_Int_Amount Numeric(18,2)

	Set @MonthDays = 0
	Set @LoanDays = 0
	Set @Branch_ID_Temp = 0
	

	--SET @Interest_Type			='REDUCING'
	SET @Interest_Percent		= 0.0
	set @Loan_Interest_Amount	=0.0
	set @Pending_Loan			= 0.0
	set @TotLoan_Closing		= 0.0
	set @TotalInst_Amount		= 0.0
	set @Loan_Apr_Amount		= 0.0
	set @Loan_Payment_Id		= 0

	set @Return_Amount			= 0.0
	set @Loan_Apr_Amount		=0.0
	SET @Pre_Approval_Id		= 0
	SET @Pre_Payment_Id			= 0
	SET @Loan_Inst				= 0
	SET @Deduction_Type			=''
	Set @Loan_Apr_Pending_Int_Amount = 0.0
	
	set @Desig_ID = 0 --Added by Gadriwala Muslim 26122014
	
	Set @Is_First_Ded_Priciple_Amt = 0
	Set @Loan_Int_Install_Amount = 0
	Begin
			set @Loan_Payment_Id = 0
			
			declare curLoan cursor for
				select LA.loan_id,La.Loan_Apr_ID,la.Loan_Int_Installment_Amount
				 ,la.No_of_Inst_Loan_Amt ,Loan_Apr_Date,la.Deduction_Type
				 ,ISNULL(LM.Is_Principal_First_than_Int,0),Loan_Apr_Intrest_Per,Loan_Apr_Pending_Int_Amount
				 from T0120_loan_approval la WITH (NOLOCK) inner JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) ON LM.Loan_ID = la.Loan_ID
				 where la.emp_id = @emp_id and la.Cmp_ID = @Cmp_ID
				 and FLOOR(la.Loan_Apr_Pending_Int_Amount) > 0 and FLOOR(la.Loan_Apr_Pending_Amount) = 0 and Isnull(Installment_Start_Date,Loan_Apr_Date) <= @To_Date and Loan_Apr_Status='A'
				 	and LM.Is_Principal_First_than_Int = 1 and la.Loan_Int_Installment_Amount > 0 and ( @Is_Fnf = 0 or @Is_Fnf = 1)
					order by La.Loan_apr_ID
					
		    open curLoan		
			fetch next from curLoan into @Loan_Id,@Loan_Apr_ID,@Loan_Int_Install_Amount,@Loan_Inst,@Loan_Apr_Date,@Deduction_Type,@Interest_Type,@Interest_Percent,@Loan_Apr_Pending_Int_Amount
			while @@fetch_status = 0
				begin				
				
				
				set @Month_St_Date = @From_Date  -- Added by Gadriwala Muslim 26122014
				set @Month_End_Date = @To_Date -- Added by Gadriwala Muslim 26122014

				
					
					Select @Branch_ID_Temp = Branch_ID,@desig_ID = Desig_Id From T0095_Increment I WITH (NOLOCK) inner join     
					   (select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  WITH (NOLOCK)   --Changed by Hardik 09/09/2014 for Same Date Increment
					   where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
					   I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID  --Changed by Hardik 09/09/2014 for Same Date Increment
	  
					Select @Sal_St_Date = Sal_st_Date 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID_Temp    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID_Temp and Cmp_ID = @Cmp_ID)    


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
							   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@From_Date) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
							   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 

							   Set @Month_St_Date = @Sal_St_Date
							   Set @Month_End_Date = @Sal_End_Date    
						  end

					Set @MonthDays = DATEDIFF(d,@Month_St_Date,@Month_End_Date)+1

					Set @LoanDays = DATEDIFF(d,@Loan_Apr_Date,@Month_End_Date) + 1
				
					BEGIN
						if @Is_Fnf = 1
							EXEC P0210_MONTHLY_LOAN_PAYMENT_INSERT 0,@Loan_Apr_ID,@Cmp_Id,@Salary_Tran_ID,0,'',@To_Date,'','','','',@Loan_Apr_Pending_Int_Amount,@Interest_Percent,0,1	
						Else
							EXEC P0210_MONTHLY_LOAN_PAYMENT_INSERT 0,@Loan_Apr_ID,@Cmp_Id,@Salary_Tran_ID,0,'',@To_Date,'','','','',@Loan_Int_Install_Amount,@Interest_Percent,0,1	
					END						
						Fetch Next From curLoan into @Loan_Id,@Loan_Apr_ID,@Loan_Int_Install_Amount,@Loan_Inst,@Loan_Apr_Date,@Deduction_Type,@Interest_Type,@Interest_Percent,@Loan_Apr_Pending_Int_Amount
			 END 			
			close curLoan
			deallocate curLoan
	End
RETURN




