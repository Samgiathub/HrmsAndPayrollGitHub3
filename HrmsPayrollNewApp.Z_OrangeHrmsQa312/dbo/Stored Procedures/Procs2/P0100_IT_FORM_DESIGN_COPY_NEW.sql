-- EXEC P0100_IT_FORM_DESIGN_COPY_NEW
-- DROP PROC P0100_IT_FORM_DESIGN_COPY_NEW
CREATE PROCEDURE P0100_IT_FORM_DESIGN_COPY_NEW
@Cmp_ID NUMERIC,
@From_FY_Year VARCHAR(10) = '',
@Financial_Year VARCHAR(10) = ''
AS
BEGIN
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	Declare @From_cmp_id As Numeric
		SET @From_cmp_id = @Cmp_ID
	
	IF @Financial_Year = ''
		SET @Financial_Year = NULL		
		
	
	DECLARE @Loc_Name as varchar(100)
	DECLARE @Start_Year TABLE(Year_ID NUMERIC)
	DECLARE @Year as Numeric
	Declare @For_Date As datetime
	
	INSERT INTO @Start_Year
	SELECT CAST(data AS NUMERIC) FROM dbo.Split (@Financial_Year,'-')
		  
	Select @Loc_Name = Loc_name
	From T0001_LOCATION_MASTER LM WITH (NOLOCK)
	INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON LM.Loc_ID = CM.Loc_ID
	Where Cmp_Id = @Cmp_ID

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

	insert into T0100_IT_FORM_DESIGN
	(
		Tran_id,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit,
		Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,Login_ID,System_Date,IT_ID,Field_Type,Is_Show,Col_No,Form_ID,Concate_Space,Is_Salary_Comp,
		Exem_Againt_Row_ID,Financial_Year,For_Date,Show_In_SalarySlip,Display_Name_For_Salaryslip,Column_24Q,Net_Income_Range,Field_Value,TotalFormula,TotalFormula_Actual
	)
	select maxid + rno, Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit,
	Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,Login_ID,System_Date,IT_ID,Field_Type,Is_Show,Col_No,Form_ID,Concate_Space,Is_Salary_Comp,
	Exem_Againt_Row_ID,@Financial_Year,@For_Date,Show_In_SalarySlip,Display_Name_For_Salaryslip,Column_24Q,Net_Income_Range,Field_Value,TotalFormula,TotalFormula_Actual
	from
	(
		SELECT ROW_NUMBER () OVER (ORDER BY TT.tran_id) as rno,  
		(SELECT MAX(T.tran_id) FROM T0100_IT_FORM_DESIGN T WITH (NOLOCK)) as maxid,row_id 
		Tran_id,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit,
		Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,Login_ID,System_Date,IT_ID,Field_Type,Is_Show,Col_No,Form_ID,Concate_Space,Is_Salary_Comp,
		Exem_Againt_Row_ID,Financial_Year,For_Date,Show_In_SalarySlip,Display_Name_For_Salaryslip,Column_24Q,Net_Income_Range,Field_Value,TotalFormula,TotalFormula_Actual
		FROM T0100_IT_FORM_DESIGN TT WITH (NOLOCK) where cmp_id = @From_cmp_id and Financial_Year = @From_FY_Year
	) as S order by Row_ID
END