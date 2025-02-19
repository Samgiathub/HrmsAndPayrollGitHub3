
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_FNF_Loan_Interest_Calcultion]
	  @Cmp_ID Numeric
	 ,@From_Date Datetime
	 ,@To_Date Datetime
	 ,@Emp_ID Numeric
AS

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Loan_Apr_ID Numeric(18,0)
	DECLARE @Loan_Apr_Pending_Amount Numeric(18,2)
	DECLARE @Loan_Apr_Pending_Int_Amount Numeric(18,2)
	DECLARE @Loan_Apr_Intrest_Per Numeric(18,2)
	DECLARE @Is_First_Ded_Priciple_Amt Numeric(18,0)
	DECLARE @undeduct_interest_Amount Numeric(18,2)

	DECLARE @TotLoan_Closing Numeric(18,2)
	DECLARE @Loan_Apr_Amount Numeric(18,2)
	DECLARE @Branch_ID_Temp Numeric(18,0)
	DECLARE @MonthDays Numeric(18,0)
	DECLARE @Interest_Type Varchar(100)
	Declare @Pre_Loan_Interest_Amount  Numeric(22,2)
	DECLARE @Loan_Interest_Amount Numeric(18,2)
	DECLARE @Final_Interest_Amount Numeric(18,2)
	DECLARE @Loan_Name Varchar(200)
	DECLARE @Loan_ID Numeric(18,0)



	Set @Loan_Apr_ID = 0
	Set @Loan_Apr_Pending_Amount = 0
	Set @Loan_Apr_Pending_Int_Amount = 0
	Set @Loan_Apr_Intrest_Per = 0
	Set @Is_First_Ded_Priciple_Amt = 0
	Set @undeduct_interest_Amount = 0
	Set @TotLoan_Closing = 0
	Set @Loan_Apr_Amount = 0
	Set @Branch_ID_Temp = 0
	Set @MonthDays = 0
	Set @Interest_Type = 0
	Set @Pre_Loan_Interest_Amount  = 0
	Set @Loan_Interest_Amount = 0

	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime
	DECLARE @Month_St_Date Datetime
	DECLARE @Month_End_Date Datetime
	DECLARE @Last_Loan_Payment Datetime
BEGIN
		declare curLoan cursor for
		SELECT LA.Loan_Apr_ID,LA.Loan_Apr_Amount,LA.Loan_Apr_Pending_Amount,LA.Loan_Apr_Pending_Int_Amount,LA.Loan_Apr_Intrest_Per,LM.Is_Principal_First_than_Int,LM.Loan_Interest_Type,LM.Loan_Name,LA.Loan_ID
		FROM T0120_LOAN_APPROVAL LA WITH (NOLOCK) INNER JOIN T0040_LOAN_MASTER LM  WITH (NOLOCK)
		ON LA.Loan_ID = LM.Loan_ID
		where Emp_ID = @Emp_ID AND (Loan_Apr_Pending_Amount > 0 OR LA.Loan_Apr_Pending_Int_Amount > 0) and LA.Cmp_ID = @Cmp_ID
		open curLoan		
		fetch next from curLoan into @Loan_Apr_ID,@Loan_Apr_Amount,@Loan_Apr_Pending_Amount,@Loan_Apr_Pending_Int_Amount,@Loan_Apr_Intrest_Per,@Is_First_Ded_Priciple_Amt,@Interest_Type,@Loan_Name,@Loan_ID
			while @@fetch_status = 0
				begin
					
					if @Is_First_Ded_Priciple_Amt = 1 and @Loan_Apr_Pending_Amount > 0 
						Begin
							Select @undeduct_interest_Amount = isnull(SUM(interest_Amount),0) from T0210_Monthly_Loan_payment WITH (NOLOCK) where 
							Cmp_ID = @Cmp_ID and Loan_Apr_ID =@Loan_Apr_ID  and Loan_payment_Date <=  @To_Date
						End
						
						set @Month_St_Date = @From_Date
						set @Month_End_Date = @To_Date
						
						
						Select @TotLoan_Closing = isnull(sum(Loan_Pay_Amount),0) from T0210_Monthly_Loan_payment WITH (NOLOCK) where 
						Cmp_ID = @Cmp_ID and Loan_Apr_ID =@Loan_Apr_ID and Loan_payment_Date <=  @To_Date
						
						Select @Last_Loan_Payment = Max(Loan_Payment_Date) from T0210_Monthly_Loan_payment WITH (NOLOCK) where 
						Cmp_ID = @Cmp_ID and Loan_Apr_ID =@Loan_Apr_ID and Loan_payment_Date <=  @To_Date
						
						DECLARE @Loan_Closing as numeric(18,0)
						SET @Loan_Closing = @Loan_Apr_Amount - @TotLoan_Closing
						
						Select @Branch_ID_Temp = Branch_ID From T0095_Increment I WITH (NOLOCK) inner join     
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
						

						If @Interest_Type = 'Reducing'
							Begin	
								Set @Loan_Interest_Amount = ((isnull(@Pre_Loan_Interest_Amount + ((@Loan_Closing * @Loan_Apr_Intrest_Per / 100)/12),0))*@MonthDays)/DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,@Month_End_Date),0))) 
							End
						Else
							Begin
								Set @Loan_Interest_Amount = ((isnull(@Pre_Loan_Interest_Amount + ((@Loan_Apr_Amount * @Loan_Apr_Intrest_Per / 100)/12),0))*@MonthDays)/DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,@Month_End_Date),0))) 
							End
						if @Is_First_Ded_Priciple_Amt = 0
							Set @Final_Interest_Amount = @Loan_Interest_Amount
						else if @Is_First_Ded_Priciple_Amt = 1 and @Loan_Apr_Pending_Amount > 0
							Set @Final_Interest_Amount = @Loan_Interest_Amount + @undeduct_interest_Amount
						else if @Is_First_Ded_Priciple_Amt = 1 and @Loan_Apr_Pending_Amount = 0 and @Loan_Apr_Pending_Int_Amount > 0 
							Set @Final_Interest_Amount = @Loan_Apr_Pending_Int_Amount
						INSERT INTO #tempLaon VALUES(@Loan_ID,@Loan_Name,@Last_Loan_Payment,@Loan_Apr_Pending_Amount,@Final_Interest_Amount,@Is_First_Ded_Priciple_Amt,@Loan_Apr_ID)
					fetch next from curLoan into @Loan_Apr_ID,@Loan_Apr_Amount,@Loan_Apr_Pending_Amount,@Loan_Apr_Pending_Int_Amount,@Loan_Apr_Intrest_Per,@Is_First_Ded_Priciple_Amt,@Interest_Type,@Loan_Name,@Loan_ID
				End
		close curLoan
		deallocate curLoan	
END

