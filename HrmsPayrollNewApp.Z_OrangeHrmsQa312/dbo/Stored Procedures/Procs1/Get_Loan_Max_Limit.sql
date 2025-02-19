

CREATE PROCEDURE [dbo].[Get_Loan_Max_Limit]
	@Cmp_ID			numeric,
	@Loan_Id		numeric,
	@Emp_Id			numeric,
	@Loan_Apr_ID	numeric = 0,		--Added by Nimesh on 29-Sep-2015 (To deduct existing loan amount from max limit)
	@For_Date		DateTime = null		--Added by Nimesh on 29-Sep-2015 (To check gpf balance as on date)
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 
	
	--Added by Nimesh 29-Sep-2015
	IF (@Loan_Apr_ID = 0)
		SET @Loan_Apr_ID = NULL
	IF (@For_Date IS NULL)
		SET @For_Date = GETDATE();

	Declare @Max_Limit_On_Basic_Gross As tinyint
	Declare @No_Of_Times As Numeric(9,2)	--Integer --Integer to Numeric(9,2) --Ankit 04032016
	Declare @Loan_Guarantor As Integer 
	Declare @Maxlimit_Desigwise As Integer 
	Declare @Emp_Design As Numeric(18,0)
	Declare @Is_Principal_First_than_Int As Numeric(18,0)
	Set @Loan_Guarantor = 0
	Declare @Loan_Interest_Type as varchar(20)  --Added by Gadriwala 10032015
	Declare @Loan_Interest_Per as  numeric(18,4) --Added by Gadriwala 10032015
	Declare @Is_Attachment as tinyint --Added by Gadriwala 11032015
	Declare @Is_Eligible as tinyint--Added by Gadriwala 13032015
	Declare @Eligible_Days as numeric(18,0) --Added by Gadriwala 13032015
	DECLARE	@IS_GPF_LOAN	BIT				--ADDED BY Nimesh 30-Jul-2015 (To get max limit of GPF Loan)
	DECLARE @EXISTING_LOAN_AMT	numeric(18,4) --Added by Nimesh on 29-Sep-2015 (To deduct existing loan amount from max limit if it is in edit mode)	
	DECLARE @Loan_Guarantor2 as Numeric(18,0) --added By Mukti(17112015) 
	DECLARE @is_Subsidy_loan as tinyint
	DECLARE @Hide_Loan_Max_Amount as tinyint
	
	set @is_Subsidy_loan = 0  -- Added by rohit on 25072016
	
	set @Is_Attachment = 0 --Added by Gadriwala 11032015
	set @Loan_Interest_Type = '' --Added by Gadriwala 10032015
	set @Loan_Interest_Per =0  --Added by Gadriwala 10032015
	set @Is_Eligible = 0 --Added by Gadriwala 13032015
	set @Eligible_Days = 0 --Added by Gadriwala 13032015
	Set @Is_Principal_First_than_Int = 0 --Added by nilesh patel on 20072015
	Set @Hide_Loan_Max_Amount = 0
	
	Select @Max_Limit_On_Basic_Gross = Isnull(Max_Limit_On_Basic_Gross,0), @No_Of_Times = No_Of_Times ,
		   @Loan_Guarantor = Loan_Guarantor,@Maxlimit_Desigwise = Isnull(Desig_max_limit,0),@Loan_Interest_Type = ISNULL(Loan_Interest_Type,''),
		   @Loan_Interest_Per = Loan_Interest_Per, @Is_Attachment = Is_attachment,@Is_Eligible = Is_Eligible ,@Eligible_Days = Eligible_Days,
		   @Is_Principal_First_than_Int = Is_Principal_First_than_Int,
		   @IS_GPF_LOAN = Is_GPF,	--ADDED BY Nimesh 30-Jul-2015 (To determin Loan Type is GPF Loan)
		   @Loan_Guarantor2=Loan_Guarantor2 --added By Mukti(17112015) 
		  ,@is_Subsidy_loan = is_Subsidy_loan
		  ,@Hide_Loan_Max_Amount = Hide_Loan_Max_Amount
		From T0040_LOAN_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_Id And Loan_ID = @Loan_Id
		
		
	IF (@Loan_Apr_ID is not null)
	BEGIN
		SELECT @EXISTING_LOAN_AMT = Loan_Apr_Amount FROM T0120_LOAN_APPROVAL WITH (NOLOCK) WHERE Loan_Apr_ID=@Loan_Apr_ID		
	END
	IF (@EXISTING_LOAN_AMT IS NULL)
			SET @EXISTING_LOAN_AMT = 0;
	
	
	If @Max_Limit_On_Basic_Gross = 0 and @Maxlimit_Desigwise = 0 and @IS_GPF_LOAN = 0
		Begin			
			Select	Loan_Max_Limit,Loan_Guarantor,ISNULL(Loan_Interest_Type,'') as Loan_Interest_Type,Loan_Interest_Per,Is_Attachment,Is_Eligible,Eligible_Days,Is_Principal_First_than_Int 
					,Is_GPF --Added by Nimesh 30-Jul-2015
					,Loan_Guarantor2 --Mukti 17112015
					,Is_Subsidy_Loan
					,Hide_Loan_Max_Amount
			From	T0040_LOAN_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_Id And Loan_ID = @Loan_Id
		End
	Else if @Maxlimit_Desigwise = 1 and @IS_GPF_LOAN = 0
		Begin
			Select	@Emp_Design = Desig_Id From T0095_INCREMENT WITH (NOLOCK) where Cmp_ID = @Cmp_Id and Emp_ID = @Emp_Id
			
			Select	LMD.Loan_Max_Limit ,LM.Loan_Guarantor,ISNULL(Loan_Interest_Type,'') as Loan_Interest_Type,Loan_Interest_Per,Is_Attachment,Is_Eligible,Eligible_Days,Is_Principal_First_than_Int
					,LM.Is_GPF --Added by Nimesh 30-Jul-2015
					,Loan_Guarantor2 --Mukti 17112015
					,Is_Subsidy_Loan
					,Hide_Loan_Max_Amount
			From T0040_LOAN_MASTER LM WITH (NOLOCK) inner join T0040_Loan_Maxlimit_Design LMD WITH (NOLOCK) on LM.Loan_ID = LMD.Loan_ID where LM.Cmp_ID = @Cmp_Id and LM.Loan_ID = @Loan_Id and LMD.Desig_Id = @Emp_Design
		End 
	Else IF @IS_GPF_LOAN = 1 --Added by Nimesh 30-Jul-2015
		BEGIN
			DECLARE @BALANCE NUMERIC(18,4);
			SET @BALANCE = 0
			
			SELECT	TOP 1 @BALANCE = GPF_CLOSING 
			FROM	T0140_EMP_GPF_TRANSACTION WITH (NOLOCK)
			WHERE	EMP_ID=@EMP_ID AND CMP_ID=@CMP_ID AND FOR_DATE <= @FOR_DATE
			ORDER BY FOR_DATE DESC	
			
						
			Select	(dbo.F_Lower_Round((@BALANCE + @EXISTING_LOAN_AMT) * ((CASE WHEN LM.GPF_Max_Loan_per > 0 THEN LM.GPF_Max_Loan_per ELSE 100 END) / 100), LM.CMP_ID) ) AS Loan_Max_Limit,
					LM.Loan_Guarantor,ISNULL(Loan_Interest_Type,'') as Loan_Interest_Type,
					CAST(0 AS numeric(18,2))Loan_Interest_Per,Is_Attachment,Is_Eligible,Eligible_Days,
					Is_Principal_First_than_Int
					,LM.Is_GPF --Added by Nimesh 30-Jul-2015
					,Loan_Guarantor2 --Mukti 17112015
					,Is_Subsidy_Loan
					,Hide_Loan_Max_Amount
			From	T0040_LOAN_MASTER LM WITH (NOLOCK) where LM.Cmp_ID = @Cmp_Id and LM.Loan_ID = @Loan_Id 
		END
	Else
		Begin
			
			Declare @Allowance_Id_String_Max_Limit as varchar(500)
			Select @Allowance_Id_String_Max_Limit = Isnull(Allowance_Id_String_Max_Limit,'') 
				From T0040_LOAN_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_Id And Loan_ID = @Loan_Id
			
			Declare @Allow_Id as Numeric
			Declare @Max_Loan_Limit as Numeric
			
			Set @Max_Loan_Limit = 0
			
			
			
			Declare Cur Cursor for
				Select Data from dbo.Split(@Allowance_Id_String_Max_Limit,'#')
			Open Cur
			fetch next from Cur into @Allow_Id
			while @@FETCH_STATUS = 0
				Begin
					If @Allow_Id = 888  -- 888 id from Basic
						Begin
							Select @Max_Loan_Limit = @Max_Loan_Limit + Isnull(Basic_Salary,0) From T0095_INCREMENT I WITH (NOLOCK) Where Emp_ID = @Emp_Id And Increment_ID = 
								(Select MAX(Increment_ID) From T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = @Emp_Id And Increment_Effective_Date <= GETDATE())		 --Changed by Hardik 09/09/2014 for Same Date Increment
						End
					Else if @Allow_Id = 999 --- 999 id from Gross
						Begin
							Select @Max_Loan_Limit = @Max_Loan_Limit + Isnull(Gross_Salary,0) From T0095_INCREMENT I WITH (NOLOCK) Where Emp_ID = @Emp_Id And Increment_ID = 
								(Select MAX(Increment_ID) From T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = @Emp_Id And Increment_Effective_Date <= GETDATE())		 --Changed by Hardik 09/09/2014 for Same Date Increment
						End
					Else if @Allow_Id = 1000 --- 1000 id from CTC
						Begin
							Select @Max_Loan_Limit = @Max_Loan_Limit + Isnull(CTC,0) From T0095_INCREMENT I WITH (NOLOCK) Where Emp_ID = @Emp_Id And Increment_ID = 
								(Select MAX(Increment_ID) From T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = @Emp_Id And Increment_Effective_Date <= GETDATE())		 --Added new condition by nilesh patel on 11022016
						End
					Else
						Begin
							Select @Max_Loan_Limit = @Max_Loan_Limit + Isnull(E.E_AD_AMOUNT,0) From T0095_INCREMENT I WITH (NOLOCK) 
								Inner Join T0100_EMP_EARN_DEDUCTION E WITH (NOLOCK) on I.Increment_ID = E.INCREMENT_ID
							Where I.Emp_ID = @Emp_Id And AD_ID = @Allow_Id And I.Increment_ID = 
								(Select MAX(Increment_ID) From T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = @Emp_Id And Increment_Effective_Date <= GETDATE()) --Changed by Hardik 09/09/2014 for Same Date Increment
								
						End
					fetch next from Cur into @Allow_Id
				End
				
				Select	Isnull(@Max_Loan_Limit,0) * @No_Of_Times as Loan_Max_Limit,@Loan_Guarantor As Loan_Guarantor,@Loan_Interest_Type as Loan_Interest_Type ,@Loan_Interest_Per as Loan_Interest_Per ,@Is_Attachment as Is_Attachment,@Is_Eligible as Is_Eligible ,@Eligible_Days as Eligible_Days,@Is_Principal_First_than_Int as Is_Principal_First_than_Int 
						,Cast(0 AS BIT) AS Is_GPF,@Loan_Guarantor2 as Loan_Guarantor2,@is_Subsidy_loan as Is_Subsidy_Loan, @Hide_Loan_Max_Amount As Hide_Loan_Max_Amount --Added by Nimesh 30-Jul-2015

		End

Return




