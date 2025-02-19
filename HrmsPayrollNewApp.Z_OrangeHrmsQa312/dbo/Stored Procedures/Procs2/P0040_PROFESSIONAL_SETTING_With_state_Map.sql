




-- Created By Rohit for Copy the Default PT State setting in PT branch on 06122013
-- Sp Created for Copy pt Slab of State into Branch.
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0040_PROFESSIONAL_SETTING_With_state_Map]
	@Branch_ID numeric(18,0)
   ,@state_id numeric(18,0)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
	
	Declare @curCMP_ID numeric
	Declare @For_date  Datetime
	Declare	@Row_Id Numeric 
	Declare @From_limit Numeric 
	Declare @To_limit Numeric
	Declare @Amount Numeric
	
	
	 if  exists( select  row_id from T0040_PROFESSIONAL_SETTING_StateWise WITH (NOLOCK) where state_id = @state_id)
	begin 
	
		delete from t0040_PROFESSIONAL_SETTING where branch_id = @Branch_ID
	end
	
	--Declare CusrCompanyMST cursor for	                  
	--select CMP_ID,For_date,From_limit,To_limit,Amount from T0040_PROFESSIONAL_SETTING_StateWise where State_id=@state_id
	--Open CusrCompanyMST
	--Fetch next from CusrCompanyMST into @curCMP_ID,@For_date,@From_limit,@To_limit,@Amount
	--While @@fetch_status = 0                    
	--	Begin     
	--	if  ISNULL(@Branch_ID,0)<>0 
	--	Begin
	--	select @Row_Id = isnull(max(row_id),0) + 1 from t0040_PROFESSIONAL_SETTING

	--	insert into t0040_PROFESSIONAL_SETTING(Cmp_ID,Branch_ID,For_Date,Row_ID,From_Limit,To_Limit,Amount) values(@curCMP_ID,@Branch_ID,@For_date,@Row_Id,@From_limit,@To_limit,@Amount)
				
	--	End
		
	--	fetch next from CusrCompanyMST into @curCMP_ID,@For_date,@From_limit,@To_limit,@Amount
	--end
	--close CusrCompanyMST                    
	--deallocate CusrCompanyMST
		
		
			--declare @Row_ID numeric(18,0)
			IF EXISTS (SELECT 1 FROM T0040_PROFESSIONAL_SETTING_STATEWISE WITH (NOLOCK) WHERE STATE_ID=@STATE_ID)
			BEGIN
				select @Row_ID = Isnull(max(Row_ID),0) + 1 	From T0040_PROFESSIONAL_SETTING WITH (NOLOCK)
				
				insert INTO T0040_PROFESSIONAL_SETTING (Cmp_ID,Branch_ID,For_Date,Row_ID,From_Limit,To_Limit,Amount,Applicable_PT_Male_Female)
				SELECT PT.Cmp_ID,@Branch_ID,PT.For_Date,@Row_ID + ROW_NUMBER() over (ORDER BY Row_ID) As Row_ID,
						PT.From_Limit,PT.To_Limit,PT.Amount,'ALL'
				FROM T0040_PROFESSIONAL_SETTING_STATEWISE PT WITH (NOLOCK)
				WHERE PT.State_ID = @STATE_ID
						
			END
RETURN




