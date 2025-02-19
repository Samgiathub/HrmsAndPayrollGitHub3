

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_KPIPMS_Objective_Level]
	   @Row_Id		numeric(18,0)
      ,@Cmp_Id		numeric(18,0)
      ,@Tran_Id		numeric(18,0)
      ,@KPIObj_ID	numeric(18,0)
      ,@Status		varchar(250)
      ,@tran_type		varchar(1) 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 If Upper(@tran_type) ='I'
		Begin
			if @Tran_Id=0
				begin 
					select @Tran_Id = max(tran_id)  from T0090_KPIPMS_EVAL_Approval WITH (NOLOCK)
				end
			select @Row_Id = isnull(max(Row_Id),0) + 1 from T0100_KPIPMS_Objective_Level WITH (NOLOCK)
			
			Insert into T0100_KPIPMS_Objective_Level
			(
			   [Row_Id]
			  ,[Cmp_Id]
			  ,[Tran_Id]
			  ,[KPIObj_ID]
			  ,[Status]
			)
			Values
			(
				 @Row_Id
				,@Cmp_Id
				,@Tran_Id
				,@KPIObj_ID
				,@Status
			)
		End
	Else If  Upper(@tran_type) ='U' 
		Begin	
			UPDATE  T0100_KPIPMS_Objective_Level
			SET	 [Status] = @Status
			WHERE 	Row_Id = @Row_Id
		End
	Else If  Upper(@tran_type) ='D'
		begin
			DELETE FROM T0100_KPIPMS_Objective_Level WHERE Row_Id = @Row_Id 
		End
END

