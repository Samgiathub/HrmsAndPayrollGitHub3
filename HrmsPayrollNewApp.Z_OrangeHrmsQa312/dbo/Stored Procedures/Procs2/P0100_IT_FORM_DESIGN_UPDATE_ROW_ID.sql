



---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_IT_FORM_DESIGN_UPDATE_ROW_ID]
	@Cmp_ID			numeric,
	@Form_ID		numeric ,
	@Row_ID			int,
	@Plus_Row_ID	int
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	Declare @Tran_ID			numeric 
	Declare @Format_Name		varchar(20) 
	Declare @Field_Name		Varchar(100) 
	Declare @Field_Type		tinyint
	Declare @AD_ID				numeric 
	Declare @Rimb_ID			numeric 
	Declare @Default_Def_Id	numeric 
	Declare @Is_Total			tinyint 
	Declare @From_Row_ID		int
	Declare @To_Row_ID			int
	Declare @Multiple_Row_ID	varchar(200)
	Declare @Is_Exempted		tinyint
	Declare @Max_Limit			numeric
	Declare @Max_Limit_Compare_Row_ID numeric 
	Declare @Max_Limit_Compare_Type TINYINT
	Declare @Is_Proof_Req		tinyint 
	Declare @Login_ID			numeric
	Declare @IT_ID				NUMERIC
	Declare @Tran_Type			char(1)
	Declare @Col_No			int
	Declare @Is_Show			tinyint
	Declare @Concate_Space		tinyint
	Declare @Is_Salary_Comp		tinyint
	Declare @Exem_Againt_Row_ID	int
	

	Declare Cur_IT cursor for
	select  Tran_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,Field_Type,AD_ID,Rimb_ID,Default_Def_Id
		,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit,Max_Limit_Compare_Row_ID
		,Max_Limit_Compare_Type,Is_Proof_Req,Login_ID,IT_ID,Form_ID,Col_No,Is_Show,Concate_Space,Is_Salary_Comp,Exem_Againt_Row_ID
			From T0100_IT_FORM_DESIGN WITH (NOLOCK) WHERE FORM_ID =@FORM_ID AND ROW_id >=@Row_ID
		order by Row_ID Desc
	Open Cur_IT
	Fetch next from Cur_IT into @Tran_ID,@Cmp_ID,@Format_Name,@Row_ID,@Field_Name,@Field_Type,@AD_ID,@Rimb_ID,@Default_Def_Id
		,@Is_Total,@From_Row_ID,@To_Row_ID,@Multiple_Row_ID,@Is_Exempted,@Max_Limit,@Max_Limit_Compare_Row_ID
		,@Max_Limit_Compare_Type,@Is_Proof_Req,@Login_ID,@IT_ID,@Form_ID,@Col_No,@Is_Show,@Concate_Space,@Is_Salary_Comp, @Exem_Againt_Row_ID
	while @@Fetch_Status = 0
		begin
		set @Row_ID = @Plus_Row_ID + @Row_ID

		Exec dbo.P0100_IT_FORM_DESIGN @Tran_ID,@Cmp_ID,@Format_Name,@Row_ID,@Field_Name,@Field_Type,@AD_ID,@Rimb_ID,@Default_Def_Id
		,@Is_Total,@From_Row_ID,@To_Row_ID,@Multiple_Row_ID,@Is_Exempted,@Max_Limit,@Max_Limit_Compare_Row_ID
		,@Max_Limit_Compare_Type,@Is_Proof_Req,@Login_ID,@IT_ID,'U',@Form_ID,@Col_No,@Is_Show,@Concate_Space,@Is_Salary_Comp, @Exem_Againt_Row_ID

			
		Fetch next from Cur_IT into @Tran_ID,@Cmp_ID,@Format_Name,@Row_ID,@Field_Name,@Field_Type,@AD_ID,@Rimb_ID,@Default_Def_Id
			,@Is_Total,@From_Row_ID,@To_Row_ID,@Multiple_Row_ID,@Is_Exempted,@Max_Limit,@Max_Limit_Compare_Row_ID
			,@Max_Limit_Compare_Type,@Is_Proof_Req,@Login_ID,@IT_ID,@Form_ID,@Col_No,@Is_Show,@Concate_Space,@Is_Salary_Comp, @Exem_Againt_Row_ID
		end	
	close Cur_IT
	deallocate Cur_IT
		
	
	
	RETURN




