


-- =============================================
-- Author:		<Gadriwala Muslim >
-- Create date: <10/04/2015>
-- Description:	<Get Interest Subsidy Recover Amount If Employee Left Before Subsidy Bond Date>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[GET_Interest_Subsidy_Recover_Amount]
@cmp_ID numeric(18,0),
@Emp_ID numeric(18,0),
@Emp_Left_Date datetime
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	Declare @Loan_Id as numeric(18,0)
	Declare @Loan_Apr_ID as numeric(18,0)
	Declare @Loan_Name as varchar(200)
	Declare @Loan_Apr_date as datetime
	
	Declare @Subsidy_Bond_Months as datetime
	Declare @Installment_Start_Date as datetime
	Declare @Bond_Last_Date as datetime
	Declare @Recover_Amount as numeric(18,2)
	Declare @subsidy_Opening_Amount as numeric(18,2) -- added by Gadriwala Muslim 11062015

	set @Loan_Id = 0
	set @Loan_Apr_ID = 0
	set @Loan_Name = ''
	set @Loan_Apr_date = null
	
	set @Subsidy_Bond_Months = 0
	set @Installment_Start_Date = null
	set @Bond_Last_Date = null
	set @Recover_Amount = 0
	set @subsidy_Opening_Amount = 0 -- added by Gadriwala Muslim 11062015

	
	Declare curSubsidy Cursor for 
	SELECT  dateadd(M,isnull(Subsidy_bond_Days,0),isnull(Actual_subsidy_start_date,Loan_Apr_Date)) as Bond_Last_Date,
		    Installment_Start_Date,Loan_ID,Loan_Apr_ID,Loan_Name,Opening_subsidy_amount 
    FROM V0120_LOAN_APPROVAL 
    where Is_Interest_Subsidy_Limit = 1 
		and Emp_ID = @Emp_ID and cmp_ID = @cmp_ID and isnull(subsidy_Bond_Days,0) > 0
		
    create table #Emp_Subsidy_Recover
    (
		emp_ID numeric(18,0),
		Loan_Name varchar(200),
		Loan_Start_Date datetime,
		Bond_Last_Date datetime,
		Recover_Amount numeric(18,2)
    )
    
    Open curSubsidy 
     fetch next from cursubsidy into @Bond_Last_Date,@Installment_Start_Date,@Loan_Id,@Loan_Apr_ID,@Loan_Name,@subsidy_Opening_Amount
		while @@FETCH_STATUS = 0 
			begin
					
					if @Bond_Last_Date > @Emp_Left_Date  
						begin	
							   select @Recover_Amount = Isnull(Sum(Interest_subsidy_Amount),0) from dbo.T0210_Monthly_Loan_Payment LP WITH (NOLOCK)
							   Where LP.Loan_Payment_Date <= @Emp_Left_Date and Loan_Apr_ID = @Loan_Apr_ID and LP.Cmp_ID = @cmp_ID  
							   
							    set @Recover_Amount = @subsidy_Opening_Amount +  @Recover_Amount -- added by Gadriwala Muslim 11062015
							    
							   Insert into #Emp_Subsidy_Recover 
							   select @Emp_ID,@Loan_Name,@Installment_Start_Date,@Bond_Last_Date,@Recover_Amount
						end
			fetch next from cursubsidy into @Bond_Last_Date,@Installment_Start_Date,@Loan_Id,@Loan_Apr_ID,@Loan_Name,@subsidy_Opening_Amount 
			end
    close curSubsidy
    Deallocate curSubsidy
    
    Declare @Total_Recover_Amount as numeric(18,2)
    set @Total_Recover_Amount = 0
    
    select	@Total_Recover_Amount = sum(Recover_Amount) 
	from #Emp_Subsidy_Recover Group by emp_ID
	
    select	emp_ID,
			Loan_Name,
			Convert(varchar(20),Loan_Start_Date,103) as Loan_Start_Date ,
			CONVERT(varchar(20),Bond_Last_Date,103) as Bond_Last_Date,
			Recover_Amount, 
			@Total_Recover_Amount  as Total_Recover_Amount
	from #Emp_Subsidy_Recover 
	
		  

END

