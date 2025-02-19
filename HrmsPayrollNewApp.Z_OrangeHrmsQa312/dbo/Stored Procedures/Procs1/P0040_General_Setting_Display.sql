
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_General_Setting_Display]
	 @CMP_ID		NUMERIC 
	,@Branch_ID		NUMERIC
	,@Grade_Id		Numeric =0 --Added by Hardik 16/03/2015 for Bhashker
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
	
		Declare @For_Date as datetime
		Declare @Is_OT as Numeric
		set @Is_OT = 0
		
		Declare @temp_table table
		(
			Is_OT Numeric,
			Is_PF Numeric,
			Is_PT Numeric,
			Is_Late_Mark Numeric,
			Is_LWF Numeric,
			Branch_ID Numeric,
			Monthly_Deficit_Adjust_OT_Hrs Numeric,
			Is_inout_Sal Numeric
		)


		Select @For_Date = max(For_Date) From T0040_General_Setting WITH (NOLOCK) where Branch_ID = @Branch_ID and Cmp_ID=@Cmp_ID
				
			
		 --Select Is_OT,Is_PF,Is_PT,Is_Late_Mark,Branch_ID from T0040_General_Setting where Branch_ID = @Branch_ID and Cmp_ID=@Cmp_ID and for_date= @For_Date
		 
		 Insert Into @temp_table
		 Select Is_OT,Is_PF,Is_PT,Is_Late_Mark,Is_LWF,Branch_ID,Monthly_Deficit_Adjust_OT_Hrs,Is_inout_Sal from T0040_General_Setting  WITH (NOLOCK) where Branch_ID = @Branch_ID and Cmp_ID=@Cmp_ID and for_date= @For_Date
	
		--Added by Hardik 16/03/2015 for Bhashker (They have Grade Wise OT Setting)
		If @Grade_Id > 0 
			Begin
				Select @Is_OT = Isnull(OT_Applicable,0) From T0040_GRADE_MASTER WITH (NOLOCK) Where Cmp_ID = @CMP_ID And Grd_ID = @Grade_Id
				
				If not exists(Select Is_OT From @temp_table where Is_OT = 0)
					Update @temp_table Set Is_OT = @Is_OT 
				
			End

		Select * from @temp_table

	RETURN

