


CREATE PROCEDURE [dbo].[P0140_Loan_Transaction]
   @Cmp_ID  numeric(18,0)	
   ,@Emp_Code  numeric(18,0)	
  , @Loan_Name	 varchar(20)
   ,@For_Date DateTime
   ,@Loan_Opening numeric(18,5)
   ,@Loan_Issue numeric(18,5)
   ,@Loan_Return numeric(18,5)
   ,@Loan_Closing numeric(18,5)
   
AS
	 SET NOCOUNT ON 
	 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	 SET ARITHABORT ON
	 
	 Declare @Loan_ID as numeric(18,0)
	 Declare @Loan_Tran_ID as  numeric(18,0)
	 Declare @Emp_ID as numeric
	 
	 
	 Select @Emp_ID =Emp_ID from T0080_emp_master WITH (NOLOCK) where emp_code=@Emp_code  and @Cmp_ID=Cmp_ID
	 
	  
	 
	 If exists(Select Loan_ID from t0040_Loan_Master WITH (NOLOCK) where Loan_Name = @Loan_Name  and cmp_id=@Cmp_ID)
	  Begin 
			Select @Loan_ID =Loan_ID from T0040_Loan_master WITH (NOLOCK) where Loan_Name = @Loan_Name  and cmp_id=@Cmp_ID	
	  End
	 Else
	  Begin      
			exec P0040_Loan_master @Loan_ID output ,@Cmp_ID,@Loan_Name,1000000,'','I'	       
		
	  End 
	  
	 
	 --Select Loan_Tran_ID from T0140_Loan_Transaction where Emp_id= and for_Date='30-nov-2010' and cmp_ID=22
	 If Exists(Select Loan_Tran_ID from T0140_Loan_Transaction WITH (NOLOCK) where Emp_id=@Emp_ID and cmp_ID=@cmp_Id)
	   Begin
			Return 
	   End 
		
	   
	 
	   select @Loan_Tran_ID = isnull(max(Loan_Tran_ID),0) + 1  from T0140_Loan_Transaction WITH (NOLOCK)
	   
	  insert into T0140_Loan_Transaction
	   values(@Loan_Tran_ID,@Cmp_ID,@Loan_ID,@Emp_ID,@For_Date,@Loan_Opening,@Loan_Issue,@Loan_Return,@Loan_Closing,0,0)
	   
	   SET NOCOUNT OFF
	   
RETURN




