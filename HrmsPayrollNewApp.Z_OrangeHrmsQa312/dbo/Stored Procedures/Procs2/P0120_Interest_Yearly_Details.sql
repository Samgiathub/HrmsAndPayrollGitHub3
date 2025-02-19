


-- =============================================
-- Author:		<Gadriwala Muslim >
-- Create date: <17/12/2014,,>
-- Description:	<Interest Percentage Yearly change as per Effective date>
-- =============================================
CREATE PROCEDURE [dbo].[P0120_Interest_Yearly_Details]
	 @Tran_Id numeric(18,0)	output
    ,@Cmp_ID numeric(18,0)
    ,@Emp_ID numeric(18,0)
    ,@Loan_ID numeric(18,0)
    ,@Loan_Apr_ID numeric(18,0)
    ,@Effective_Date datetime
    ,@InterestPerYearly numeric(18,2)
    
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
			IF exists(select 1 from T0120_Interest_Yearly_Details WITH (NOLOCK) where Emp_ID = @Emp_ID and Loan_id = @Loan_ID and Loan_apr_id = @Loan_Apr_ID and Tran_Id = @Tran_Id)
					begin
								Update T0120_Interest_Yearly_Details
								set  Effective_date = @Effective_Date,
									Interest_Per_Yearly = @InterestPerYearly
								where Emp_ID = @Emp_ID and Loan_id  = @Loan_ID and Tran_Id = @Tran_Id
								
					end
			else
					begin
								select @Tran_ID = isnull(max(tran_ID),0) + 1 from T0120_Interest_Yearly_Details WITH (NOLOCK)
								Insert into T0120_Interest_Yearly_Details(Tran_Id,cmp_ID,Emp_ID,Loan_id,Loan_apr_id,Effective_date,Interest_Per_Yearly) 
								values(@Tran_Id,@Cmp_ID,@Emp_ID,@Loan_ID,@Loan_apr_ID,@Effective_Date,@InterestPerYearly)
					end	
END

