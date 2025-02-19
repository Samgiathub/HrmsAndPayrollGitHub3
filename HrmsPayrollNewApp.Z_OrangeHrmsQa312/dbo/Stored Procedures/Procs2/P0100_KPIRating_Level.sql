

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_KPIRating_Level]
	 @Row_Id			numeric(18,0) OUTPUT
	,@Cmp_ID			numeric(18,0)
	,@Tran_Id			numeric(18,0)
	,@SubKPIId			numeric(18,0)
	,@Metric_Manager	varchar(500)
	,@Rating_Manager	numeric(18,0)
	,@AchievedWeight_Manager	numeric(18,2)
	,@tran_type		varchar(1) 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

--added on 11 dec 2015
if @Rating_Manager = 0
	set @rating_manager= null

	 If Upper(@tran_type) ='I'
		Begin
			if @Tran_Id=0
			begin 
				select @Tran_Id = max(tran_id)  from T0090_KPIPMS_EVAL_Approval WITH (NOLOCK)
			end
			select @Row_Id = isnull(max(Row_Id),0) + 1 from T0100_KPIRating_Level WITH (NOLOCK)
				
			Insert Into T0100_KPIRating_Level
			(
				Row_Id
				,Cmp_Id
				,Tran_Id
				,SubKPIId
				,Metric_Manager
				,Rating_Manager
				,AchievedWeight_Manager
			)
			values
			(
				@Row_Id
				,@Cmp_ID
				,@Tran_Id
				,@SubKPIId
				,@Metric_Manager
				,@Rating_Manager
				,@AchievedWeight_Manager
			)
		End
	Else If  Upper(@tran_type) ='U' 
		Begin
			UPDATE    T0100_KPIRating_Level
			SET 
				Metric_Manager=@Metric_Manager,
				Rating_Manager=@Rating_Manager,
				AchievedWeight_Manager = @AchievedWeight_Manager					
			WHERE    Row_Id = @Row_Id
			
		End
	Else If  Upper(@tran_type) ='D'
		begin
			DELETE FROM T0100_KPIRating_Level WHERE Row_Id = @Row_Id 
		End
END

