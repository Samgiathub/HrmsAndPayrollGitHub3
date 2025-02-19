



--zalak for lta medical application's Dependant

CREATE PROCEDURE [dbo].[P0130_LTA_For_Dependant]
	 @LTA_D_ID	numeric(18, 0) output
	,@Cmp_ID	numeric(18, 0)
	,@LM_App_ID	numeric(18, 0)
	,@Depend_ID	numeric(18, 0)
	,@age		int
	,@LM_Apr_ID	numeric(18, 0)
	,@emp_id	numeric(18, 0)
	,@tran_type char(1)
	
	
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

	if @LM_Apr_ID=0
		set @LM_Apr_ID=null
	declare @System_Date as varchar(11)
		set @System_Date=cast(getdate() as varchar(11))
	
		If @tran_type  = 'I' 
			Begin
				If Exists(select LM_Apr_ID From T0130_LTA_For_Dependant WITH (NOLOCK) Where cmp_ID = @Cmp_ID and
									Emp_ID = @Emp_ID  and Depend_ID=@Depend_ID and LM_App_ID=@LM_App_ID)
				    begin		
						set @LTA_D_ID = 0
						Return 
					end
	
				select @LTA_D_ID = Isnull(max(LTA_D_ID),0) + 1 	From T0130_LTA_For_Dependant WITH (NOLOCK) 
				
								INSERT INTO T0130_LTA_For_Dependant
				                      (
										        LTA_D_ID
												,Cmp_ID
												,LM_App_ID
												,Depend_ID
												,age
												,LM_Apr_ID
												,emp_id
										 )
										VALUES     
										(
									            @LTA_D_ID
												,@Cmp_ID
												,@LM_App_ID
												,@Depend_ID
												,@age
												,@LM_Apr_ID
												,@emp_id
										)
								
		End
	else if @tran_type = 'U' 
	
		begin
				update T0130_LTA_For_Dependant 
											set Depend_ID=@Depend_ID
												,LM_Apr_ID=@LM_Apr_ID	
											where LTA_D_ID=@LTA_D_ID
											
		end
	Else if @Tran_Type = 'D' 
		begin
				Delete From T0130_LTA_For_Dependant where LTA_D_ID  = @LTA_D_ID
		end
	RETURN



