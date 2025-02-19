

--'==========================================='
--''ALTER By : Falak
--''ALTER Date: 8-apr-2010
--''Description: 
--''Review By:
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--''Last Modified By: 
--'==========================================='
CREATE PROCEDURE [dbo].[P0040_HRMS_R_PROCESS_MASTER]
	@Process_Id as numeric(18,0) output
	,@Process_Name as varchar(50)
	,@Process_Desc as nvarchar(1000)
	,@cmp_id as numeric(18,0)
	,@tran_type as varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 /*******************************************************
	 ***************Created by Falak on 8-apr-2010***********
	 ********************************************************/
	 If @tran_type  = 'I' 
		Begin
				If Exists(select Process_Id From T0040_HRMS_R_PROCESS_MASTER WITH (NOLOCK) Where cmp_ID = @cmp_id and
									Process_Name = @Process_Name )
					Begin
						SET @PROCESS_ID = 0							--CHANGED BY ASHWIN 05/10/2016
						--set @Process_Name = 0
						Return 
					end
	
				select @Process_Id = Isnull(max(Process_Id),0) + 1 	From T0040_HRMS_R_PROCESS_MASTER WITH (NOLOCK)
				
				INSERT INTO T0040_HRMS_R_PROCESS_MASTER
				                      (
										  Process_Id  
										 ,Cmp_Id 
										 ,Process_Name 
										 ,Process_Desc 										 
				                      )
								VALUES     
								(
									      @Process_Id  
										 ,@Cmp_Id 
										 ,@Process_Name 
										 ,@Process_Desc										 
								)
														
		End
	Else if @Tran_Type = 'U' 
		begin

				
							--==========ADDED BY ASHWIN 05/10/2016 (start)
				IF EXISTS ( SELECT PROCESS_ID FROM T0040_HRMS_R_PROCESS_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND 
									PROCESS_NAME = @PROCESS_NAME AND PROCESS_ID <> @PROCESS_ID )
				BEGIN
					SET @PROCESS_ID = 0					
						RETURN 
				END			--==========ADDED BY ASHWIN 05/10/2016 (END)
				
				Update T0040_HRMS_R_PROCESS_MASTER
				set 
					 Process_Name = @Process_Name
					 ,Process_Desc = @Process_Desc
				where Process_Id  = @Process_Id

		end
	Else if @Tran_Type = 'D' 
		begin
				Delete From T0040_HRMS_R_PROCESS_MASTER Where Process_Id  = @Process_Id
		end


	
	RETURN




