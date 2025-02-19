



--zalak for lta medical application done by employee
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0110_LTA_Medical_Application]
	@LM_App_ID	numeric(18, 0)	output
	,@Cmp_ID	numeric(18, 0)	
	,@Emp_ID	numeric(18, 0)	
	,@APP_Date	datetime	
	,@APP_Code	varchar(20)	
	,@APP_Amount	numeric(18, 2)	
	,@APP_Comments	varchar(250)	
	,@File_Name	varchar(50)	
	,@File_Name1	varchar(50)	
	,@APP_Status	int	
	,@Leave_From_Date	datetime	
	,@Leave_to_Date	datetime	
	,@no_of_Days	int	
	,@type_ID	int
	,@tran_type varchar(1)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @System_Date as varchar(11)
	set @System_Date=cast(getdate() as varchar(11))
	if @Leave_From_Date=''
		set @Leave_From_Date=null
	if @Leave_to_Date=''
		set @Leave_to_Date=null

Declare @J As Varchar(10)
	Set @J= Cast(@no_of_Days As Varchar(10))
 
		
		--set @To_Date = DATEADD(day, @Leave_Period-1, @From_Date)
		
		If substring(@j,CharIndex('.',@j,1)+1, 2) > 0
		Begin
			Set @Leave_to_Date = DATEADD(day, @no_of_Days, @Leave_From_Date)		--If Decimal Leave 4.5,1.5 etc
		End
		Else
		Begin
			Set @Leave_to_Date = DATEADD(day, @no_of_Days-1, @Leave_From_Date)	--If Not Decimal Leave	1,2,4,5 etc
		End
			
		--Above Formula Changed By Nikunj at 5-March-2011.Becuase It ALTER Problem.Bug Complianed By CTNT Client


		If @tran_type  = 'I' 
			Begin
				If Exists(select LM_App_ID From T0110_LTA_Medical_Application WITH (NOLOCK) Where cmp_ID = @Cmp_ID and
									Emp_ID = @Emp_ID  and APP_Date=@APP_Date)
					Begin
						set @LM_App_ID = 0
						Return 
					end
	
				select @LM_App_ID = Isnull(max(LM_App_ID),0) + 1 ,@App_Code = Isnull(max(LM_App_ID),0) + 1 	From T0110_LTA_Medical_Application WITH (NOLOCK) 
				--select @App_Code = (case when @type_id=1 then 'LTA:0' else 'MED:0' end + cast(@cmp_id as varchar(10)) + ':AP0' + cast((Isnull(count(LM_App_ID),0) + 1) as varchar(20)) + ':' + stuff(cast(datepart(yy,getdate()) as varchar(4)),1,2,'')) from T0110_LTA_Medical_Application where cmp_id=@cmp_id and emp_id=@emp_id and type_id=@type_id
				
				INSERT INTO T0110_LTA_Medical_Application
				                      (
										        LM_App_ID
												,Cmp_ID
												,Emp_ID
												,App_Date
												,App_Code
												,App_Amount
												,App_Comments
												,System_Date
												,APP_Status
												,File_Name
												,File_Name1
												,Leave_From_Date
												,Leave_to_Date
												,no_of_Days
												,type_ID

									 )
								VALUES     
								(
									             @LM_App_ID
												,@Cmp_ID
												,@Emp_ID
												,@App_Date
												,@App_Code
												,@App_Amount
												,@App_Comments
												,@System_Date
												,@APP_Status
												,@File_Name
												,@File_Name1
												,@Leave_From_Date
												,@Leave_to_Date
												,@no_of_Days
												,@type_ID

								)
				End
	Else if @Tran_Type = 'U' 
		begin
				Update T0110_LTA_Medical_Application
				set 
							APP_Date=@APP_Date	
							,APP_Amount=@APP_Amount	
							,APP_Comments=@APP_Comments	
							,File_Name=@File_Name
							,File_Name1=@File_Name1	
							,APP_Status=@APP_Status	
							,Leave_From_Date=@Leave_From_Date	
							,Leave_to_Date=@Leave_to_Date	
							,no_of_Days=@no_of_Days
				where LM_App_ID  = @LM_App_ID And Cmp_Id=@Cmp_ID
		end
	Else if @Tran_Type = 'D' 
		begin
				delete from T0130_LTA_For_Dependant where LM_App_ID  = @LM_App_ID
				delete from T0130_LTA_Jurney_Detail where LM_App_ID  = @LM_App_ID
				Delete From T0110_LTA_Medical_Application where LM_App_ID  = @LM_App_ID
		end
	RETURN



