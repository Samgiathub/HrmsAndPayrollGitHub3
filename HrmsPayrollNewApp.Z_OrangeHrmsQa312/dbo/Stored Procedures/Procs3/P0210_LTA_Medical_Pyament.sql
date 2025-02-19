



--zalak for lta medical payment --07032011
CREATE PROCEDURE [dbo].[P0210_LTA_Medical_Pyament]
	 @LM_Pay_ID	numeric(18, 0) output
	,@LM_Apr_ID	numeric(18, 0)
	,@Cmp_ID	numeric(18, 0)
	,@Sal_Tran_ID	numeric(18, 0)
	,@LM_Pay_Amount	numeric(18, 0)
	,@LM_Pay_Comments	varchar(250)
	,@LM_Payment_Date	datetime
	,@LM_Payment_Type	varchar(20)
	,@Bank_Name	varchar(50)
	,@LM_Cheque_No	varchar(50)
	,@tran_type char(1)
	
	
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

	if @Sal_Tran_ID=0
	set @Sal_Tran_ID=null
	declare @LM_Pay_Code as varchar(20)
	If @tran_type  = 'I' 
			Begin
				If Exists(select LM_Pay_ID From T0210_LTA_Medical_Payment WITH (NOLOCK)  Where cmp_ID = @Cmp_ID and
													  LM_Pay_ID=@LM_Pay_ID)
					Begin
						set @LM_Pay_ID = 0
						Return 
					end
	
				select @LM_Pay_ID = Isnull(max(LM_Pay_ID),0) + 1,@LM_Pay_Code=Isnull(max(LM_Pay_ID),0) + 1 	From T0210_LTA_Medical_Payment WITH (NOLOCK)
				
				INSERT INTO T0210_LTA_Medical_Payment
				                      (
										        LM_Pay_ID
												,LM_Apr_ID
												,Cmp_ID
												,Sal_Tran_ID
												,LM_Pay_Amount
												,LM_Pay_Comments
												,LM_Payment_Date
												,LM_Payment_Type
												,Bank_Name
												,LM_Cheque_No
												,LM_Pay_Code

									 )
								VALUES     
								(
									             @LM_Pay_ID
												,@LM_Apr_ID
												,@Cmp_ID
												,@Sal_Tran_ID
												,@LM_Pay_Amount
												,@LM_Pay_Comments
												,@LM_Payment_Date
												,@LM_Payment_Type
												,@Bank_Name
												,@LM_Cheque_No
												,@LM_Pay_Code
										)
						End
	Else if @tran_type = 'U' 
		begin
				Update T0210_LTA_Medical_Payment
				set 
							 LM_Pay_Amount=@LM_Pay_Amount,
							LM_Pay_Comments=@LM_Pay_Comments
							,LM_Payment_Date=@LM_Payment_Date
							,LM_Payment_Type=@LM_Payment_Type
							,Bank_Name=@Bank_Name
							,LM_Cheque_No=@LM_Cheque_No
							where LM_Pay_ID  = @LM_Pay_ID
		end
	Else if @tran_type = 'D' 
		begin
				select  @LM_Apr_ID=LM_Apr_ID From T0210_LTA_Medical_Payment WITH (NOLOCK) where LM_Pay_ID  = @LM_Pay_ID
				update T0240_LTA_Medical_Transaction set P_Status=0 where LM_Apr_ID=@LM_Apr_ID
				Delete From T0210_LTA_Medical_Payment where LM_Pay_ID  = @LM_Pay_ID
		end
		
	RETURN



