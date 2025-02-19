

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_IT_FORM_DESIGN]

	 @Tran_ID					Numeric output , 
	 @Cmp_ID					Numeric , 
	 @Format_Name				Varchar(20) , 
	 @Row_ID					Numeric , 
	 @Field_Name				Varchar(100) , 
	 @Field_Type				Tinyint,
	 @AD_ID						Numeric , 
	 @Rimb_ID					Numeric , 
	 @Default_Def_Id			Numeric , 
	 @Is_Total					Tinyint , 
	 @From_Row_ID				Int, 
	 @To_Row_ID					Int, 
	 @Multiple_Row_ID			Varchar(200), 
	 @Is_Exempted				Tinyint, 
	 @Max_Limit					Numeric, 
	 @Max_Limit_Compare_Row_ID	Numeric , 
	 @Max_Limit_Compare_Type	Tinyint, 
	 @Is_Proof_Req				Tinyint , 
	 @Login_ID					Numeric,
	 @IT_ID						Numeric,
	 @Tran_Type					Char(1),
	 @Form_ID					Numeric,
	 @Col_No					Int,
	 @Is_Show					Tinyint	,
	 @Concate_Space				Tinyint,
	 @Is_Salary_Comp			Tinyint,
	 @Exem_Againt_Row_ID		Int, 
	 @Financial_Year			Varchar(10) = '',
	 @Show_In_SalarySlip		bit = 0,  -- Added by Ali 24012014
	 @Display_Name_For_Salaryslip varchar(250) = '', 
	 @24Q_Column int=0, --Added by Hardik 19/08/2014
	 @Net_Income_Range numeric(18,2)=0,
	 @Surcharge_Percentage numeric(18,2) =0,
	 --@New_standard_deduction numeric(18,2) =0, -- comment by divya 25092024
	 @TotalFormula Varchar(1000) = '',
	 @User_Id numeric(18,0) = 0, -- Add By Mukti 20072016
	 @IP_Address varchar(30)= '' -- Add By Mukti 20072016
	 ,@New_standard_deduction numeric(18,2) = 0.0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Login_ID =0
		SET @Login_ID = null
	IF @AD_ID =0
		SET @AD_ID =null
	IF @Rimb_ID = 0	
		SET @Rimb_Id = null
	IF @IT_ID =0
		SET @IT_ID = NULL
	IF @Form_ID =0
		SET @Form_ID = NULL
		
	 -- Add By Mukti 20072016(start)
		declare @OldValue as  varchar(max)
		Declare @String as varchar(max)
		set @String=''
		set @OldValue =''
	-- Add By Mukti 20072016(end)	
	
	if @Is_Total = 4
		Begin
			Set @From_Row_ID = 0
			Set @To_Row_ID	= 0 
		End
	
	DECLARE @old_Row_ID			INT
	DECLARE @var_Old_Row_ID		VARCHAR(10)
	DECLARE @var_Row_ID			VARCHAR(10)
	
	-- Added By Hiral 28 May,2013 (Start)
	If @Financial_Year = ''				--If conditions Added On 03 June, 2013 (When delete problem was occured)
		Set @Financial_Year = NULL		
	
	Declare @For_Date			Datetime
	DECLARE @Start_Year TABLE ( Year_ID NUMERIC )
	Declare @Year as Numeric
	
	Declare @Loc_Name as varchar(100)
	Select @Loc_Name = Loc_name From T0001_LOCATION_MASTER WITH (NOLOCK) Where Loc_ID in 
		(Select Loc_ID  From T0010_COMPANY_MASTER WITH (NOLOCK) Where Cmp_Id = @Cmp_ID)

	INSERT  INTO @Start_Year
		  SELECT  CAST(data AS NUMERIC)
		  FROM   dbo.Split (@Financial_Year,'-')

	If Upper(@Loc_Name) = 'PAKISTAN'
		Begin
			Select top 1 @Year = Year_ID From @Start_Year order by Year_ID 
			Set @For_Date = Cast('1 Jul,' + Cast(@Year As Varchar(6)) As Datetime)
		End
	Else
		Begin
			Select top 1 @Year = Year_ID From @Start_Year order by Year_ID 
			Set @For_Date = Cast('1 Apr,' + Cast(@Year As Varchar(6)) As Datetime)
		End
	-- Added By Hiral 28 May,2013 (End)
	
	IF @Tran_Type ='I'
		BEGIN
				IF EXISTS(select Row_ID From T0100_IT_FORM_DESIGN WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and isnull(Form_ID,0) = isnull(@Form_ID,0) and Row_ID=@Row_ID And Financial_Year = @Financial_Year)
					BEGIN
						Raiserror('@@Duplicate Row No@@',16,2)
						RETURN -1
					END
				SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
				INSERT INTO T0100_IT_FORM_DESIGN
									  (Tran_ID, Cmp_ID, Format_Name, Row_ID, Field_Name, AD_ID, Rimb_ID, Default_Def_Id, Is_Total, From_Row_ID, To_Row_ID, Multiple_Row_ID, 
									  Is_Exempted, Max_Limit, Max_Limit_Compare_Row_ID, Max_Limit_Compare_Type, Is_Proof_Req, Login_ID, System_Date,IT_ID,Form_ID,Field_Type,Col_No,Is_Show,
									  Concate_Space,Is_Salary_Comp,Exem_Againt_Row_ID,Financial_Year,For_Date,Show_In_SalarySlip,Display_Name_For_Salaryslip,Column_24Q,Net_Income_Range,Field_Value,Field_Value2,TotalFormula,TotalFormula_Actual) -- Added by Ali 24012014
				VALUES     (@Tran_ID, @Cmp_ID, @Format_Name, @Row_ID, @Field_Name, @AD_ID, @Rimb_ID, @Default_Def_Id, @Is_Total, @From_Row_ID, @To_Row_ID, @Multiple_Row_ID, 
									  @Is_Exempted, @Max_Limit, @Max_Limit_Compare_Row_ID, @Max_Limit_Compare_Type, @Is_Proof_Req, @Login_ID, getdate(),@IT_ID,@Form_ID,@Field_Type,@Col_No,@Is_Show,
									  @Concate_Space,@Is_Salary_Comp, @Exem_Againt_Row_ID,@Financial_Year,@For_Date,@Show_In_SalarySlip,@Display_Name_For_Salaryslip,@24Q_Column,@Net_Income_Range,@Surcharge_Percentage,@New_standard_deduction
									  --,Replace(Replace(@TotalFormula,'{','#'),'}','#'),@TotalFormula) -- Added by Ali 24012014
									  ,Replace(Replace(Replace(Replace(@TotalFormula,'{','#'),'}','#'),'*','*#'),'/','/#'),@TotalFormula) -- Added by Ali 24012014
									  
				-- Add By Mukti 20072016(start)
					exec P9999_Audit_get @table = 'T0100_IT_FORM_DESIGN' ,@key_column='Tran_ID',@key_Values=@Tran_ID,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
				-- Add By Mukti 20072016(end)	
		end
	ELSE IF @Tran_Type ='U'
		BEGIN
				-- Add By Mukti 20072016(start)
						exec P9999_Audit_get @table='T0100_IT_FORM_DESIGN' ,@key_column='Tran_ID',@key_Values=@Tran_ID,@String=@String output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
				-- Add By Mukti 20072016(end)
				
				SELECT @old_Row_ID = Row_ID FROM T0100_IT_FORM_DESIGN WITH (NOLOCK) WHERE Tran_ID =@Tran_ID
				
				IF @old_Row_ID <> @Row_ID 
					BEGIN
						SET @var_Old_Row_ID = '#' + CAST(@old_Row_ID AS VARCHAR(5)) + '#'
						SET @var_row_Id  ='#' + CAST(@Row_ID AS VARCHAR(5)) + '#'
						
						UPDATE T0100_IT_FORM_DESIGN
						SET From_Row_ID =@Row_ID 
						WHERE From_Row_ID =@old_Row_ID AND Form_ID=@Form_ID
						
						UPDATE T0100_IT_FORM_DESIGN
						SET To_Row_ID =@Row_ID 
						WHERE To_Row_ID =@old_Row_ID AND Form_ID=@Form_ID

						UPDATE T0100_IT_FORM_DESIGN
						SET Max_Limit_Compare_Row_ID =@Row_ID 
						WHERE Max_Limit_Compare_Row_ID =@old_Row_ID AND Form_ID=@Form_ID

						UPDATE T0100_IT_FORM_DESIGN
						SET    Exem_Againt_Row_ID =@Row_ID 
						WHERE  ISNULL(Exem_Againt_Row_ID,0) =@old_Row_ID AND Form_ID=@Form_ID

						
						UPDATE T0100_IT_FORM_DESIGN
						SET Multiple_Row_ID = replace(Multiple_Row_ID,@var_Old_Row_ID,@var_row_Id)
						WHERE CHARINDEX(@var_Old_Row_ID,Multiple_Row_ID,0) > 0 AND Form_ID=@Form_ID
						
						
					END

					UPDATE    T0100_IT_FORM_DESIGN
					SET       Format_Name = @Format_Name, Row_ID = @Row_ID, Field_Name = @Field_Name, AD_ID = @AD_ID, 
										  Rimb_ID = @Rimb_ID, Default_Def_Id = @Default_Def_Id, Is_Total = @Is_Total, From_Row_ID = @From_Row_ID, To_Row_ID = @To_Row_ID, 
										  Multiple_Row_ID = @Multiple_Row_ID, Is_Exempted = @Is_Exempted, Max_Limit = @Max_Limit, 
										  Max_Limit_Compare_Row_ID = @Max_Limit_Compare_Row_ID, Max_Limit_Compare_Type = @Max_Limit_Compare_Type, 
										  Is_Proof_Req = @Is_Proof_Req, Login_ID = @Login_ID, System_Date = GETDATE(), 
										  IT_ID = @IT_ID , Form_ID = @Form_ID  ,Field_Type =@Field_Type,Col_No =@Col_No , Is_Show =@Is_Show,
										  Concate_Space=@Concate_Space,Is_Salary_Comp = @Is_Salary_Comp, Exem_Againt_Row_ID = @Exem_Againt_Row_ID,
										  Financial_Year = @Financial_Year, For_Date = @For_Date,Show_In_SalarySlip = @Show_In_SalarySlip, -- Added by Ali 24012014
										  Display_Name_For_Salaryslip = @Display_Name_For_Salaryslip, Column_24Q = @24Q_Column
										  ,Field_Value =@Surcharge_Percentage,Field_Value2 = @New_standard_deduction,Net_Income_Range=@Net_Income_Range
										  --,TotalFormula = Replace(Replace(Replace(Replace(@TotalFormula,'{','#'),'}','#'),')','#)#'),'(','#(#')
										  ,TotalFormula = Replace(Replace(Replace(Replace(@TotalFormula,'{','#'),'}','#'),'*','*#'),'/','/#')
										  ,TotalFormula_Actual = @TotalFormula
					WHERE	Tran_ID =@Tran_ID
					
				-- Add By Mukti 20072016(start)
					exec P9999_Audit_get @table = 'T0100_IT_FORM_DESIGN' ,@key_column='Tran_ID',@key_Values=@Tran_ID,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
				-- Add By Mukti 20072016(end)	
		END
	ELSE IF @Tran_Type ='D' -- Added by Mayur Modi to check flag is D for Delete on 16/05/2019
		BEGIN
			SELECT @Row_ID =Row_ID ,@Form_Id =Form_ID, @Financial_Year = Financial_Year
				FROM T0100_IT_FORM_DESIGN WITH (NOLOCK) where Tran_ID =@Tran_ID
			
			
			IF  NOT EXISTS(SELECT Row_ID FROM T0100_IT_FORM_DESIGN WITH (NOLOCK) WHERE Form_Id  =@Form_Id AND Financial_Year = @Financial_Year
							AND (From_Row_Id =@Row_ID OR To_Row_ID =@Row_ID OR ISNULL(Exem_Againt_Row_ID,0) =@Row_ID))
				BEGIN
				-- Add By Mukti 20072016(start)
						exec P9999_Audit_get @table='T0100_IT_FORM_DESIGN' ,@key_column='Tran_ID',@key_Values=@Tran_ID,@String=@String output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
				-- Add By Mukti 20072016(end)
				
					DELETE FROM T0100_IT_FORM_DESIGN WHERE Tran_ID =@Tran_ID
				END
			ELSE
				BEGIN
					RAISERROR('@@Reference Exists,Cant Delete@@',16,2)
					RETURN -1
				END
		END
	
	 exec P9999_Audit_Trail @CMP_ID,@Tran_type,'IT Form Design',@OldValue,@Tran_ID,@User_Id,@IP_Address
RETURN




