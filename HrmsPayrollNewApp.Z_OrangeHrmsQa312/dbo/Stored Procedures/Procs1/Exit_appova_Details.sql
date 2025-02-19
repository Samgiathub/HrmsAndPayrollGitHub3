
CREATE PROCEDURE [dbo].[Exit_appova_Details]
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
					Return
				End
		End

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
					Return
				End

		End

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
					 
				End

		End
	
	If @Setting_Value =1
		BEGIN
			Set @Error_Logs = 0
			Select @Error_Logs As Error_Logs,@G_Emp_Id As Guar_Emp_ID 
		END
	ELSE
		BEGIN
			Select @Error_Logs As Error_Logs,@G_Emp_Id As Guar_Emp_ID  
		END
	
		exec SP_LEAVE_CLOSING_AS_ON_DATE @Cmp_ID=@CMP_ID,@For_Date=@from_date,@Emp_Id=@EMP_ID	
		
		select Asset_Name,Brand_Name,Vendor,Type_Of_Asset,Model_Name,Serial_No,Asset_Code,Emp_ID,Cmp_ID,Return_Date,Type,Allocation_Date from V0040_Asset_Allocation where Cmp_ID = @Cmp_ID and Emp_id =27185 order by Allocation_Date	
		
		select Loan_Name,Loan_Apr_Date,Loan_Apr_Amount,Loan_Apr_Pending_Amount,Loan_Apr_Status from V0120_LOAN_APPROVAL where Cmp_ID = @Cmp_ID and Emp_id =@Emp_ID order by loan_id	
			
		Select emp_id,resignation_date,status From T0200_Emp_ExitApplication Where cmp_id=@Cmp_ID and emp_id=@Emp_ID order by exit_id desc	

		select * from V0100_Warning_Details where Emp_id =@Emp_ID and cmp_id = @Cmp_ID
		
		exec P0200_AdvanceDetail_Exit @Cmp_ID=@Cmp_ID,@Todate=@From_Date,@Emp_Id=@Emp_ID

		exec GET_LOAN_GUARANTOR_FOR_EXIT @Cmp_ID=@Cmp_ID,@To_Date=@From_Date ,@Branch_ID='0',@Cat_ID='0',@Grd_ID='0',@Type_ID='0',@Dept_ID='0',@Desig_ID='0',@Emp_ID=@Emp_ID,@Constraint=@Emp_ID	

	RETURN

