
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_IT_FORM_DESIGN_COPY]
	@Cmp_ID			Numeric,
	@From_FY_Year	Varchar(10) = '',
	@Financial_Year Varchar(10) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

    Declare @Tran_ID As numeric (18,0)
	Declare @Format_Name As varchar (20)
	Declare @Row_ID As int
	Declare @Field_Name As varchar (100)
	Declare @AD_ID As numeric (18,0)
	Declare @Rimb_ID As numeric (18,0)
	Declare @Default_Def_Id As int
	Declare @Is_Total As tinyint
	Declare @From_Row_ID As int
	Declare @To_Row_ID As int
	Declare @Multiple_Row_ID As varchar (200)
	Declare @Is_Exempted As tinyint
	Declare @Max_Limit As numeric (18,0)
	Declare @Max_Limit_Compare_Row_ID As int
	Declare @Max_Limit_Compare_Type As tinyint
	Declare @Is_Proof_Req As tinyint
	Declare @Login_ID As numeric (18,0)
	Declare @System_Date As datetime
	Declare @IT_ID As numeric (18,0)
	Declare @Field_Type As tinyint
	Declare @Is_Show As tinyint
	Declare @Col_No As tinyint
	Declare @Form_ID As numeric (18,0)
	Declare @Concate_Space As tinyint
	Declare @Is_Salary_Comp As tinyint
	Declare @Exem_Againt_Row_ID As int
	Declare @For_Date As datetime
	Declare @Show_In_SalarySlip As bit
	Declare @Display_Name_For_Salaryslip As varchar (250)
	Declare @Column_24Q tinyint
	Declare @Net_Income_Range numeric(18,2)
	declare @Surcharge_Percentage numeric(18,2)
	declare @TotalFormula varchar(max)
	declare @TotalFormula_Actual varchar(max)
	
	Declare @From_cmp_id As Numeric
		Set @From_cmp_id = @Cmp_ID
	If @Financial_Year = ''
		Set @Financial_Year = NULL		
	
	
	
	Declare @Loc_Name as varchar(100)
	DECLARE @Start_Year TABLE ( Year_ID NUMERIC )
	Declare @Year as Numeric
	
	INSERT  INTO @Start_Year
		  SELECT  CAST(data AS NUMERIC)
		  FROM   dbo.Split (@Financial_Year,'-')
		  
	Select @Loc_Name = Loc_name From T0001_LOCATION_MASTER WITH (NOLOCK) Where Loc_ID in 
		(Select Loc_ID  From T0010_COMPANY_MASTER WITH (NOLOCK) Where Cmp_Id = @Cmp_ID)

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
	
	Declare Cur_IT_form cursor Fast_forward for
			Select Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit,
					Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,Login_ID,System_Date,IT_ID,Field_Type,Is_Show,Col_No,Form_ID,Concate_Space,Is_Salary_Comp,
					Exem_Againt_Row_ID,Show_In_SalarySlip,Display_Name_For_Salaryslip,Column_24Q,Net_Income_Range,Field_Value,TotalFormula,TotalFormula_Actual
				From T0100_IT_FORM_DESIGN WITH (NOLOCK) where cmp_id = @From_cmp_id and Financial_Year = @From_FY_Year order by row_id
				open Cur_IT_form
					fetch next from Cur_IT_form into @Cmp_ID,@Format_Name,@Row_ID,@Field_Name,@AD_ID,@Rimb_ID,@Default_Def_Id,@Is_Total,@From_Row_ID,@To_Row_ID,@Multiple_Row_ID,@Is_Exempted,@Max_Limit,
						@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type,@Is_Proof_Req,@Login_ID,@System_Date,@IT_ID,@Field_Type,@Is_Show,@Col_No,@Form_ID,@Concate_Space,@Is_Salary_Comp,
						@Exem_Againt_Row_ID,@Show_In_SalarySlip,@Display_Name_For_Salaryslip,@Column_24Q,@Net_Income_Range,@Surcharge_Percentage,@TotalFormula,@TotalFormula_Actual
						While @@Fetch_Status=0
							begin	
								Begin				
									Select @Tran_ID = Max(tran_id) + 1 from T0100_IT_FORM_DESIGN WITH (NOLOCK)
								
									Insert into T0100_IT_FORM_DESIGN
										(Tran_id,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit,
										Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,Login_ID,System_Date,IT_ID,Field_Type,Is_Show,Col_No,Form_ID,Concate_Space,Is_Salary_Comp,
										Exem_Againt_Row_ID,Financial_Year,For_Date,Show_In_SalarySlip,Display_Name_For_Salaryslip,Column_24Q,Net_Income_Range,Field_Value,TotalFormula,TotalFormula_Actual)
									Values
										(@Tran_id,@Cmp_ID,@Format_Name,@Row_ID,@Field_Name,@AD_ID,@Rimb_ID,@Default_Def_Id,@Is_Total,@From_Row_ID,@To_Row_ID,@Multiple_Row_ID,@Is_Exempted,@Max_Limit,
										@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type,@Is_Proof_Req,@Login_ID,@System_Date,@IT_ID,@Field_Type,@Is_Show,@Col_No,@Form_ID,@Concate_Space,@Is_Salary_Comp,
										@Exem_Againt_Row_ID,@Financial_Year,@For_Date,@Show_In_SalarySlip,@Display_Name_For_Salaryslip,@Column_24Q,@Net_Income_Range,@Surcharge_Percentage,@TotalFormula,@TotalFormula_Actual) 
								End
						
							fetch next from Cur_IT_form into @Cmp_ID,@Format_Name,@Row_ID,@Field_Name,@AD_ID,@Rimb_ID,@Default_Def_Id,@Is_Total,@From_Row_ID,@To_Row_ID,@Multiple_Row_ID,@Is_Exempted,@Max_Limit,
								@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type,@Is_Proof_Req,@Login_ID,@System_Date,@IT_ID,@Field_Type,@Is_Show,@Col_No,@Form_ID,@Concate_Space,@Is_Salary_Comp,
								@Exem_Againt_Row_ID,@Show_In_SalarySlip,@Display_Name_For_Salaryslip,@Column_24Q,@Net_Income_Range,@Surcharge_Percentage,@TotalFormula,@TotalFormula_Actual
							End
				close Cur_IT_form
	deallocate Cur_IT_form	
				


END



