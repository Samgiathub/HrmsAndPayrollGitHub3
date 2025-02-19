

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0100_Abstract_Report_Details]
	  @Trans_ID numeric(18) output
	 ,@Cmp_ID numeric(18)
	 ,@Report_ID numeric(18)
	 ,@Employee_type numeric(18)
	 ,@Sorting_No numeric(18)
	 ,@Earning_Component_ID varchar(2000) = ''
	 ,@Earning_Short_Name varchar(Max)  = ''
	 ,@Deduction_Component_ID varchar(2000)  = ''
	 ,@Deduction_Short_Name varchar(Max)  = ''
	 ,@Loan_ID varchar(2000)  = ''
	 ,@Loan_Short_Name varchar(Max)  = ''
	 ,@TypeID Numeric(5,0)
	 ,@Abstract_Report_ID Numeric(5,0)
	 ,@tran_type  varchar
AS
	begin

	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

				if @Earning_Component_ID = '' 
					Set @Earning_Component_ID = NULL
			
				if @Earning_Short_Name = ''
					Set @Earning_Short_Name = NULL
					
				if @Deduction_Component_ID = ''
					Set @Deduction_Component_ID = NULL
					
				if @Deduction_Short_Name = ''
					Set @Deduction_Short_Name = NULL
				
				if @Loan_ID = ''
					Set @Loan_ID = NULL
					
				IF @Loan_Short_Name = ''
					Set @Loan_Short_Name = NULL
					
		if @tran_type = 'I'
			BEGIN
				
				if exists (Select Trans_ID  from T0100_Abstract_Report_Details WITH (NOLOCK) Where Report_ID = @Report_ID and Employee_Type = @Employee_type and Cmp_ID=@Cmp_ID AND TYPEID = @TypeID AND Abstract_Report_ID = @Abstract_Report_ID) 
						begin
							set @Trans_ID =0
							return
						end
					else
						begin
							select @Trans_ID = isnull(max(Trans_ID),0) +1  from T0100_Abstract_Report_Details WITH (NOLOCK)
							insert into T0100_Abstract_Report_Details
							(Trans_ID,Cmp_ID,Report_ID,Employee_Type,Sorting_No,Earning_Component_ID,Earning_Short_Name,Deduction_Component_ID,Deduction_Short_Name,Loan_ID,Loan_Short_Name,System_Date,TypeID,Abstract_Report_ID) 
							values(@Trans_ID,@Cmp_ID,@Report_ID,@Employee_type,@Sorting_No,@Earning_Component_ID,@Earning_Short_Name,@Deduction_Component_ID,@Deduction_Short_Name,@Loan_ID,@Loan_Short_Name,GETDATE(),@TypeID,@Abstract_Report_ID)
						end
				end 
			End
		if @tran_type = 'U'
			Begin
				Update T0100_Abstract_Report_Details 
				SET Sorting_No = @Sorting_No,
					Earning_Component_ID = @Earning_Component_ID,
					Earning_Short_Name = @Earning_Short_Name,
					Deduction_Component_ID = @Deduction_Component_ID,
					Deduction_Short_Name = @Deduction_Short_Name,
					Loan_ID = @Loan_ID,
					Loan_Short_Name = @Loan_Short_Name,
					System_Date = GETDATE(),
					TypeID = @TypeID,
					Abstract_Report_ID = @Abstract_Report_ID
				Where Trans_ID = @Trans_ID and Cmp_ID = @Cmp_ID
			End 
		if @tran_type = 'D'
			Begin
				Delete From T0100_Abstract_Report_Details where Trans_ID = @Trans_ID
			End
		
	RETURN




