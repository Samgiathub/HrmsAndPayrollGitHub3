

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_KPI_DevelopmentPlan_Level]
	 @Row_Id			numeric(18,0) OUTPUT
	,@Cmp_ID			numeric(18,0)
	,@Tran_Id			numeric(18,0)
	,@Strengths			varchar(200)
	,@DevelopmentAreas	varchar(200)
	,@ImprovementAction	varchar(200)
	,@Timeline			varchar(200)
	,@Status			varchar(200)
	,@tran_type		varchar(1) 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	If Upper(@tran_type) ='I'
		Begin
			if @Tran_Id=0
				begin 
					select @Tran_Id = max(Tran_Id)  from T0090_KPIPMS_EVAL_Approval WITH (NOLOCK) 
				end
				select @Row_Id = isnull(max(Row_Id),0) + 1 from T0100_KPI_DevelopmentPlan_Level WITH (NOLOCK)
				
				Insert Into	T0100_KPI_DevelopmentPlan_Level
				(
					Row_Id
					,Cmp_Id
					,Tran_Id
					,Strengths
					,DevelopmentAreas
					,ImprovementAction
					,Timeline
					,[Status]					
				)
				Values
				(
					@Row_Id
					,@Cmp_ID
					,@Tran_Id
					,@Strengths
					,@DevelopmentAreas
					,@ImprovementAction
					,@Timeline
					,@Status
				)
		End
	Else If  Upper(@tran_type) ='U' 
		Begin						
			UPDATE    T0100_KPI_DevelopmentPlan_Level
			SET 
				Strengths=@Strengths,
				DevelopmentAreas=@DevelopmentAreas,
				ImprovementAction = @ImprovementAction,
				Timeline=@Timeline,
				[Status] = @Status
			WHERE    Row_Id = @Row_Id
		End
	Else If  Upper(@tran_type) ='D'
		begin
			DELETE FROM T0100_KPI_DevelopmentPlan_Level WHERE Row_Id = @Row_Id 
		End
END

