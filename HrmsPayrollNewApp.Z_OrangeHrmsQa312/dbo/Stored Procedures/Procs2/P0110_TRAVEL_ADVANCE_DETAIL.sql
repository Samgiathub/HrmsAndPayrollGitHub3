

---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0110_TRAVEL_ADVANCE_DETAIL]
	 @Travel_Advance_Detail_ID	Numeric(18,0)
	,@Cmp_ID					Numeric(18,0)
	,@Travel_App_ID				Numeric(18,0)
	,@Expence_Type				Varchar(100)
	,@Amount					Numeric(18,2)
	,@Adv_Detail_Desc			NVarchar(250)
	,@Curr_ID					numeric(18,0)=0
	,@Tran_Type					Char(1) 
	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If UPPER(@Tran_Type) = 'I' OR UPPER(@Tran_Type) = 'M'
		Begin
			Select @Travel_Advance_Detail_ID = ISNULL(MAX(Travel_Advance_Detail_ID),0) + 1 From T0110_TRAVEL_ADVANCE_DETAIL WITH (NOLOCK)
			--Select  @Travel_App_ID= ISNULL(MAX(Travel_Application_ID),0)  from T0100_TRAVEL_APPLICATION
			if not exists(select Travel_Advance_Detail_ID from T0110_TRAVEL_ADVANCE_DETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Expence_Type=@Expence_Type and Amount=@Amount and Travel_App_ID=@Travel_App_ID)
				Begin
					Insert Into T0110_TRAVEL_ADVANCE_DETAIL
					(Travel_Advance_Detail_ID, Cmp_ID, Travel_App_ID, Expence_Type, Amount, Adv_Detail_Desc,Curr_ID)
					Values (@Travel_Advance_Detail_ID, @Cmp_ID, @Travel_App_ID, @Expence_Type, @Amount, @Adv_Detail_Desc,@Curr_ID)
				End	
		End
	Else If UPPER(@Tran_Type)='U' --Added by sumit 01092015
		begin
		Select @Travel_Advance_Detail_ID = ISNULL(MAX(Travel_Advance_Detail_ID),0) + 1 From T0110_TRAVEL_ADVANCE_DETAIL WITH (NOLOCK)
		if not exists(select Travel_Advance_Detail_ID from T0110_TRAVEL_ADVANCE_DETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Expence_Type=@Expence_Type and Amount=@Amount and Travel_App_ID=@Travel_App_ID)
			Begin				
				Insert Into T0110_TRAVEL_ADVANCE_DETAIL
					(Travel_Advance_Detail_ID, Cmp_ID, Travel_App_ID, Expence_Type, Amount, Adv_Detail_Desc,Curr_ID)
				Values (@Travel_Advance_Detail_ID, @Cmp_ID, @Travel_App_ID, @Expence_Type, @Amount, @Adv_Detail_Desc,@Curr_ID)
			End		
		End			
END


