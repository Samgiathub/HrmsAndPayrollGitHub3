


-- =============================================
-- Author:		<Hiral>
-- ALTER date: <18 May 2013>
-- Description:	<Insert, Update and Delete Data of T0190_Emp_Arrear_Detail>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0190_Emp_Arrear_Detail]
	 @Arrear_ID			Numeric(18,0)	OutPut
	,@Cmp_ID			Numeric(18,0)
	,@Emp_ID			Numeric(18,0)
	,@For_Month			Numeric(18,0)
	,@For_Year			Numeric(18,0)
	,@Days				Numeric(18,2)
	,@Leave_Adjustment	TinyInt
	,@Effective_Month	Numeric(18,0)
	,@Effective_Year	Numeric(18,0)
	,@Is_Absent			TinyInt
	,@Adjust_With_Leave	Numeric(18,0)
	,@Remarks			Nvarchar(100)
	,@Tran_Type			Varchar(1)
	,@User_Id			Numeric(18,0) = 0 
	,@IP_Address		Varchar(30) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @Remarks = ''
		Set @Remarks = Null
	
	If @Effective_Month = 0
		Set @Effective_Month = NULL
		
	If @Effective_Year = 0
		Set @Effective_Year = NULL
		
	If Upper(@tran_type) ='I'
		Begin
			Select @Arrear_ID = Isnull(Max(Arrear_ID),0) + 1 From T0190_Emp_Arrear_Detail WITH (NOLOCK)
			
			Insert Into T0190_Emp_Arrear_Detail
					(Arrear_ID, Cmp_ID, Emp_ID, For_Month, For_Year, Days, Leave_Adjustment, 
					 Effective_Month, Effective_Year, Is_Absent, Adjust_With_Leave, Remarks)
				Values (@Arrear_ID, @Cmp_ID, @Emp_ID, @For_Month, @For_Year, @Days, @Leave_Adjustment, 
						@Effective_Month, @Effective_Year, @Is_Absent, @Adjust_With_Leave, @Remarks)
		End
		
	Else If Upper(@tran_type) ='D'
		Begin
			Delete From T0190_Emp_Arrear_Detail Where Arrear_ID = @Arrear_ID And Cmp_ID = @Cmp_ID
		End
END


