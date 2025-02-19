



--zalak for lta medical application's Jurney_Detail

CREATE PROCEDURE [dbo].[P0130_LTA_Jurney_Detail]
	 @LTA_J_ID	numeric(18, 0)output
	,@Cmp_ID	numeric(18, 0)
	,@emp_id	numeric(18, 0)
	,@LM_App_ID	numeric(18, 0)
	,@JR_Date	datetime
	,@From_Place	varchar(100)
	,@To_Place	varchar(100)
	,@Route	varchar(100)
	,@Mode_Of_Travel	varchar(100)
	,@Fare	numeric(18, 2)
	,@File_Name	varchar(100)
	,@LM_Apr_ID	numeric(18, 0)
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
				If Exists(select LM_Apr_ID From T0130_LTA_Jurney_Detail WITH (NOLOCK)  Where cmp_ID = @Cmp_ID and
									Emp_ID = @Emp_ID  and JR_Date=@JR_Date and LM_App_ID=@LM_App_ID)
				    begin		
						set @LTA_J_ID = 0
						Return 
					end
	
				select @LTA_J_ID = Isnull(max(LTA_J_ID),0) + 1 	From T0130_LTA_Jurney_Detail WITH (NOLOCK)
				
								INSERT INTO T0130_LTA_Jurney_Detail
				                      (
												LTA_J_ID
												,Cmp_ID
												,emp_id
												,LM_App_ID
												,JR_Date
												,From_Place
												,To_Place
												,Route
												,Mode_Of_Travel
												,Fare
												,File_Name
												,LM_Apr_ID
										)
										VALUES     
										(
									            @LTA_J_ID
												,@Cmp_ID
												,@emp_id
												,@LM_App_ID
												,@JR_Date
												,@From_Place
												,@To_Place
												,@Route
												,@Mode_Of_Travel
												,@Fare
												,@File_Name
												,@LM_Apr_ID
										)
								
		End
	else if @tran_type = 'U' 
	
		begin
				update T0130_LTA_Jurney_Detail 
											set JR_Date=@JR_Date
												,From_Place=@From_Place
												,To_Place=@To_Place
												,Route=@Route
												,Mode_Of_Travel=@Mode_Of_Travel
												,Fare=Fare
												,LM_Apr_ID=@LM_Apr_ID
				where LTA_J_ID=@LTA_J_ID
				if @File_Name<> ''
						update T0130_LTA_Jurney_Detail 
											set File_Name=@File_Name
				where LTA_J_ID=@LTA_J_ID								
		end
		
	Else if @tran_type = 'D' 
		begin
				Delete From T0130_LTA_Jurney_Detail where LTA_J_ID  = @LTA_J_ID
		end
	RETURN



