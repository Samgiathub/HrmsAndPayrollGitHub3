


-- =============================================
-- Author:		<Ankit>
-- ALTER date: <01052014,,>
-- Description:	<Description,,>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_LOAN_STATEMENT_REPORT_GUARANTOR]
 @Cmp_ID 			Numeric
,@From_Date 		Datetime
,@Emp_ID 			Numeric
,@Loan_ID			Numeric
,@Guarantor_Emp_ID	Numeric
,@For_Exit     bigint = 0   --Added by Jaina 05-12-2016

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
 	IF @Emp_ID = 0  
		set @Emp_ID = null
	
	Declare @App_Emp_ID Numeric
		Set @App_Emp_ID = 0
	--Declare @To_Date Datetime
	--	Set	@To_Date = GETDATE()
	Declare @Loan_Closing Numeric
		Set @Loan_Closing = 0
	Declare @Error_Logs Numeric
		Set @Error_Logs   = 0

	Declare @Loan_Guarantor tinyint
	Select @Loan_Guarantor = Loan_Guarantor from T0040_LOAN_MASTER WITH (NOLOCK) where cmp_id=@Cmp_Id And Loan_ID=@Loan_Id
	
	--Added by Hardik 29/04/2016
	Declare @Setting_Value as tinyint
	Set @Setting_Value = 0
	Select @Setting_Value = Setting_Value from T0040_SETTING WITH (NOLOCK) where Setting_Name='Disable Guarantor Validation in Loan Application/Approval' And Cmp_ID=@Cmp_Id
	
	if @For_Exit = 0  --Added by Jaina 05-12-2016
	Begin
		If Isnull(@Loan_Guarantor,0) = 0 
			Return
	END
	
	--Added by Jaina 05-12-2016 Start ( Check Exit Application Guarantor Detail)
	IF @FOR_EXIT = 1
	BEGIN 
		DECLARE @G_EMP_ID VARCHAR(100) = NULL	
		
		SELECT   @G_EMP_ID = COALESCE(@G_EMP_ID + '#', '') + CAST(EMP_ID AS NVARCHAR(5))
		FROM T0120_LOAN_APPROVAL WITH (NOLOCK)
		WHERE (GUARANTOR_EMP_ID=@EMP_ID OR GUARANTOR_EMP_ID2=@EMP_ID) and Cmp_ID=@Cmp_Id
		
		IF @G_EMP_ID <> ''
			Begin
											
				Select  @Loan_Closing = Loan_Closing From T0140_LOAN_TRANSACTION WITH (NOLOCK)
				Where EXISTS (select Data from dbo.Split(@G_Emp_Id, '#') G Where cast(G.data as numeric)=Isnull(Emp_ID,0))
					And For_Date = (Select Max(For_Date) From T0140_LOAN_TRANSACTION WITH (NOLOCK)
									Where For_Date <= @From_Date AND 
									EXISTS (select Data from dbo.Split(@G_Emp_Id, '#') G Where cast(G.data as numeric)=Isnull(Emp_ID,0)))
				
				IF @Loan_Closing > 0
					Begin
						Set @Loan_Closing = 1
						Set @Error_Logs = -1
						Select @Error_Logs As Error_Logs ,@G_Emp_Id As Guar_Emp_ID  
						Return 
					End
						
			End
	
	End
	--Added by Jaina 05-12-2016 End ( Check Exit Application Guarantor Detail)
		
	-- Check For Applicant Employee non of Guarantor 
	
	Select @App_Emp_ID = Emp_ID From T0120_LOAN_APPROVAL WITH (NOLOCK) Where Guarantor_Emp_ID = @Emp_ID --And Cmp_ID = @Cmp_ID

	IF @App_Emp_ID	 > 0 
		Begin
		
			Select @Loan_Closing = Loan_Closing From T0140_LOAN_TRANSACTION WITH (NOLOCK)
			Where Emp_ID = @App_Emp_ID --And Cmp_ID = @Cmp_ID
				And For_Date = (Select Max(For_Date) From T0140_LOAN_TRANSACTION WITH (NOLOCK)
								Where Emp_ID = @App_Emp_ID And For_Date <= @From_Date)-- And Cmp_ID = @Cmp_ID )

			IF @Loan_Closing > 0
				Begin
					Set @Loan_Closing = 1
					Set @Error_Logs = -1
					--Select @Error_Logs As Error_Logs ,@App_Emp_ID As Guar_Emp_ID  --Commented by Hardik to Disable Check Guarantor Validation for Havmor client 29/04/2016
					Return
				End
			--Else
			--	Begin
			--		Set @Loan_Closing = 0
			--		Set @Error_Logs = 0
			--		Select @Error_Logs As Error_Logs
			--	End
				
		End
	
	-- Check For Applicant Employee non of Guarantor 
 			
	-- Check For Guarantor Employee Loan Amount Status
	If 	@Guarantor_Emp_ID > 0
		Begin
			Select @Loan_Closing = Loan_Closing From T0140_LOAN_TRANSACTION WITH (NOLOCK)
			Where Emp_ID = @Guarantor_Emp_ID --And Cmp_ID = @Cmp_ID
				And For_Date = (Select Max(For_Date) From T0140_LOAN_TRANSACTION WITH (NOLOCK)
								Where Emp_ID = @Guarantor_Emp_ID And For_Date <= @From_Date)-- And Cmp_ID = @Cmp_ID )
			IF @Loan_Closing > 0
				Begin
					Set @Loan_Closing = 1
					Set @Error_Logs = -2
					--Select @Error_Logs As Error_Logs   --Commented by Hardik to Disable Check Guarantor Validation for Havmor client 29/04/2016
					Return
				End
			--Else
			--	Begin
			--		Set @Loan_Closing = 0
			--		Set @Error_Logs = 0
			--		Select @Error_Logs As Error_Logs
			--	End
		End
	
	-- Check For Guarantor Employee Loan Amount Status
	
	-- Check For Guarantor Employee Not other Employee guarantor
	Set @App_Emp_ID = 0

	Select @App_Emp_ID = Emp_ID From T0120_LOAN_APPROVAL WITH (NOLOCK) Where Guarantor_Emp_ID = @Guarantor_Emp_ID And Emp_Id <> @Emp_ID-- And Cmp_ID = @Cmp_ID 


	IF @App_Emp_ID	 > 0 
		Begin
		
			Select @Loan_Closing = Loan_Closing From T0140_LOAN_TRANSACTION WITH (NOLOCK)
			Where Emp_ID = @App_Emp_ID --And Cmp_ID = @Cmp_ID
				And For_Date = (Select Max(For_Date) From T0140_LOAN_TRANSACTION WITH (NOLOCK)
								Where Emp_ID = @App_Emp_ID And For_Date <= @From_Date) -- And Cmp_ID = @Cmp_ID )

			IF @Loan_Closing > 0
				Begin
					Set @Loan_Closing = 1
					Set @Error_Logs = -3
					--Select @Error_Logs As Error_Logs  --Commented by Hardik to Disable Check Guarantor Validation for Havmor client 29/04/2016
					 
				End
			--Else
			--	Begin
			--		Set @Loan_Closing = 0
			--		Set @Error_Logs = 0
			--		Select @Error_Logs As Error_Logs
			--		Return
			--	End
			 
		End
	
	-- Check For Guarantor Employee Not other Employee guarantor
	
	--Added by Hardik to Disable Check Guarantor Validation for Havmor client 29/04/2016
	If @Setting_Value =1
		BEGIN
			Set @Error_Logs = 0
			Select @Error_Logs As Error_Logs,@G_Emp_Id As Guar_Emp_ID  --@G_Emp_Id added by sneha to retrieve the same no. of column results 07/11/2017
		END
	ELSE
		BEGIN
			Select @Error_Logs As Error_Logs,@G_Emp_Id As Guar_Emp_ID  
		END
	
	RETURN

