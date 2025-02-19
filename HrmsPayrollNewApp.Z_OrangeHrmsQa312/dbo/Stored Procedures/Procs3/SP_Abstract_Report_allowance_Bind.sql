


---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Abstract_Report_allowance_Bind]
	@Cmp_ID Numeric,
	@Allow_Type Char
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	IF OBJECT_ID('tempdb..#Temp_Allowance_Details') IS NOT NULL
		DROP TABLE #Temp_Allowance_Details
	
	Create Table #Temp_Allowance_Details
	(
		Cmp_ID Numeric,
		Allowance_ID Numeric,
		Allowance_Name Varchar(2000),
		Allowance_Sort_Name Varchar(500)
	)
	
	
	if @Allow_Type = 'I' 
		Begin
			Insert Into #Temp_Allowance_Details(Cmp_ID,Allowance_ID,Allowance_Name,Allowance_Sort_Name)
			values(@Cmp_ID,8000,'Basic','Bas')
    
			Insert Into #Temp_Allowance_Details(Cmp_ID,Allowance_ID,Allowance_Name,Allowance_Sort_Name)
			Select CMP_ID,AD_ID,AD_NAME,AD_SORT_NAME From T0050_AD_MASTER WITH (NOLOCK) where CMP_ID = @Cmp_ID and AD_FLAG = 'I'
		End
	 
	if @Allow_Type = 'D' 
	   Begin
			Insert Into #Temp_Allowance_Details(Cmp_ID,Allowance_ID,Allowance_Name,Allowance_Sort_Name)
			Select CMP_ID,AD_ID,AD_NAME,AD_SORT_NAME From T0050_AD_MASTER WITH (NOLOCK) where CMP_ID = @Cmp_ID and AD_FLAG = 'D'
			
			Insert Into #Temp_Allowance_Details(Cmp_ID,Allowance_ID,Allowance_Name,Allowance_Sort_Name)
			values(@Cmp_ID,9000,'Prof.Tax','PT')
	   End
	if @Allow_Type = 'L' 
	   Begin
			Insert Into #Temp_Allowance_Details(Cmp_ID,Allowance_ID,Allowance_Name,Allowance_Sort_Name)
			Select Cmp_ID,Loan_ID,Loan_Name,'' FROM T0040_LOAN_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID
	   End
    Select * From #Temp_Allowance_Details
    
END

