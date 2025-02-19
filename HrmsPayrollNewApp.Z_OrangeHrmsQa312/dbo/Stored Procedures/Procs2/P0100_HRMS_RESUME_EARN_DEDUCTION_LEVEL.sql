
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_HRMS_RESUME_EARN_DEDUCTION_LEVEL]
	 @AD_Row_ID	numeric(18, 0)	output
	,@CMP_ID	numeric(18, 0)	
	,@Resume_id	numeric(18, 0)	
	,@AD_ID	numeric(18, 0)	
	,@E_AD_FLAG	char(1)	
	,@E_AD_MODE	varchar(10)	
	,@E_AD_PERCENTAGE	numeric(12, 2)	
	,@E_AD_AMOUNT	numeric(18, 2)	
	,@E_AD_MAX_LIMIT	numeric(18, 0)	
	,@Tran_ID	numeric(18, 0)	
	,@Trans_Type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @AD_ID=0
		set @AD_ID=null
	if @CMP_ID=0
		set @CMP_ID=null
		
	declare @FOR_DATE as datetime
	set @FOR_DATE = cast(getdate() as varchar(11))
	
	If @Trans_Type  = 'I'
		Begin
				If Exists(Select AD_Row_ID From T0100_HRMS_RESUME_EARN_DEDUCTION_LEVEL WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and AD_ID = @AD_ID and Resume_id=@Resume_id)
					begin
						set @AD_Row_ID = 0
					Return 
				end
				
				select @AD_Row_ID= Isnull(max(AD_Row_ID),0) + 1 From T0100_HRMS_RESUME_EARN_DEDUCTION_LEVEL WITH (NOLOCK)
				
				INSERT INTO T0100_HRMS_RESUME_EARN_DEDUCTION_LEVEL
				                      ( AD_Row_ID
										,CMP_ID
										,Resume_id
										,AD_ID
										,FOR_DATE
										,E_AD_FLAG
										,E_AD_MODE
										,E_AD_PERCENTAGE
										,E_AD_AMOUNT
										,E_AD_MAX_LIMIT
										,Tran_ID
										)
				VALUES					(@AD_Row_ID
										,@CMP_ID
										,@Resume_id
										,@AD_ID
										,@FOR_DATE
										,@E_AD_FLAG
										,@E_AD_MODE
										,@E_AD_PERCENTAGE
										,@E_AD_AMOUNT
										,@E_AD_MAX_LIMIT
										,@Tran_ID
										)
		End
	Else if @Trans_Type = 'U'
		begin
				Update T0100_HRMS_RESUME_EARN_DEDUCTION_LEVEL
				set 
					 E_AD_FLAG=@E_AD_FLAG
					,E_AD_MODE=@E_AD_MODE
					,E_AD_PERCENTAGE=@E_AD_PERCENTAGE
					,E_AD_AMOUNT=@E_AD_AMOUNT
					,E_AD_MAX_LIMIT=@E_AD_MAX_LIMIT
			where Resume_id = @Resume_id and AD_ID=@AD_ID and Tran_ID=@Tran_ID and cmp_id=@cmp_id
				
		end
	Else if @Trans_Type = 'D'
		begin
				Delete From T0100_HRMS_RESUME_EARN_DEDUCTION_LEVEL Where AD_Row_ID= @AD_Row_ID
				
		end

	RETURN




