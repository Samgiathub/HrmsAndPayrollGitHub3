
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_EmployeeGoalSetting_Evaluation_Details]
	   @Emp_GoalSetting_Review_Detail_Id	numeric(18,0)
      ,@Cmp_Id								numeric(18,0)
      ,@Emp_Id								numeric(18,0)
      ,@Emp_GoalSetting_Review_Id			numeric(18,0)
      ,@Emp_GoalSetting_Detail_Id			numeric(18,0)
      ,@Actual								nvarchar(100) --Changed by Deepali -02Jun22
      ,@Emp_Feedback						nvarchar(300) --Changed by Deepali -02Jun22
      ,@Sup_Score							varchar(50)
      ,@Sup_Feedback						nvarchar(300) --Changed by Deepali -02Jun22
      ,@WeightedScore						numeric(18,2)
      ,@finyear								int
      ,@Review_Type							int
      ,@Tran_Type							varchar(1)
      ,@User_Id								numeric(18,0)
      ,@IP_Address							varchar(30)
      ,@KPA_Type_ID							int --Mukti(11012019)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN


    declare @OldValue as nvarchar(max)--Changed by Deepali -02Jun22
	declare @OldActual as nvarchar(100) --Changed by Deepali -02Jun22
	declare @OldEmp_Feedback as nvarchar(300) --Changed by Deepali -02Jun22
	declare @OldSup_Score as varchar(50)
	declare @OldSup_Feedback as nvarchar(300) --Changed by Deepali -02Jun22
	declare @OldWeightedScore as varchar(18)
	declare @oldDate as varchar(50)
	
	set @OldValue =''
	set @OldActual = ''
	set @OldEmp_Feedback = ''
	set @OldSup_Score =''
	set @OldSup_Feedback =''
	set @OldWeightedScore =''	
	set @oldDate =''	
	
	IF @Tran_Type = 'I'
		BEGIN
			IF 	@Emp_GoalSetting_Review_Id =0
				BEGIN 
					select @Emp_GoalSetting_Review_Id= isnull(max(Emp_GoalSetting_Review_Id),0) from T0095_EmployeeGoalSetting_Evaluation WITH (NOLOCK) where Cmp_Id = @cmp_id and emp_id=@emp_id and FinYear = @finyear and Review_Type=@Review_Type					
					if @Emp_GoalSetting_Review_Id =0
						BEGIN
							set @Emp_GoalSetting_Review_Detail_Id = 0
							select @Emp_GoalSetting_Review_Detail_Id
							RETURN
						END
				END
				SELECT @Emp_GoalSetting_Review_Detail_Id = isnull(max(Emp_GoalSetting_Review_Detail_Id),0)+1 from T0100_EmployeeGoalSetting_Evaluation_Details WITH (NOLOCK)
				INSERT INTO T0100_EmployeeGoalSetting_Evaluation_Details
				(
					   Emp_GoalSetting_Review_Detail_Id
					  ,Cmp_Id
					  ,Emp_Id
					  ,Emp_GoalSetting_Review_Id
					  ,Emp_GoalSetting_Detail_Id
					  ,Actual
					  ,Emp_Feedback
					  ,Sup_Score
					  ,Sup_Feedback
					  ,WeightedScore
					  ,KPA_Type_ID
				)VALUES
				(
					  @Emp_GoalSetting_Review_Detail_Id
					  ,@Cmp_Id
					  ,@Emp_Id
					  ,@Emp_GoalSetting_Review_Id
					  ,@Emp_GoalSetting_Detail_Id
					  ,@Actual
					  ,@Emp_Feedback
					  ,@Sup_Score
					  ,@Sup_Feedback
					  ,@WeightedScore
					  ,@KPA_Type_ID
				)
				
				SET @OldValue = 'New Value' + '#'+ 'Emp Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Actual :' + cast(@Actual as VARCHAR) + '#' + 'Employee Feedback :' +ISNULL(@Emp_Feedback,'') + '#' 
												 + 'Superior Score :' + isnull(@Sup_Score,'') + '#'  + 'Superior Feedback :' + isnull(@Sup_Feedback,'') + '#' + 'Weighted Score :' + cast(@WeightedScore as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	
		END
	Else IF @Tran_Type = 'U'
		BEGIN
			select @OldActual = cast(Actual as varchar) ,@OldEmp_Feedback =cast(Emp_Feedback as varchar),
				   @OldSup_Score =isnull(Sup_Score,''),@OldSup_Feedback = isnull(Sup_Feedback,''),@OldWeightedScore = isnull(cast([WeightedScore] as VARCHAR),'')				  
			From dbo.T0100_EmployeeGoalSetting_Evaluation_Details WITH (NOLOCK) 
			Where Cmp_ID = @Cmp_ID and Emp_GoalSetting_Review_Detail_Id = @Emp_GoalSetting_Review_Detail_Id
			
			UPDATE T0100_EmployeeGoalSetting_Evaluation_Details
			SET  Actual = @Actual
			    ,Emp_Feedback = @Emp_Feedback	
			    ,[Sup_Score] = @Sup_Score
			    ,Sup_Feedback = @Sup_Feedback
			    ,WeightedScore = @WeightedScore
			    ,KPA_Type_ID=@KPA_Type_ID
			WHERE Emp_GoalSetting_Review_Detail_Id = @Emp_GoalSetting_Review_Detail_Id
			
			SET @OldValue = 'Old Value' + '#'+ 'Emp Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Actual :' + cast(@OldActual as VARCHAR) + '#' + 'Employee Feedback :' +ISNULL(@OldEmp_Feedback,'') + '#' 
											 + 'Superior Score :' + isnull(@OldSup_Score,'') + '#'  + 'Superior Feedback :' + isnull(@OldSup_Feedback,'') + '#' + 'Weighted Score :' + cast(@OldWeightedScore as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	
					       + 'New Value' + '#'+ 'Emp Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Actual :' + cast(@Actual as VARCHAR) + '#' + 'Employee Feedback :' +ISNULL(@Emp_Feedback,'') + '#' 
											  + 'Superior Score :' + isnull(@Sup_Score,'') + '#'  + 'Superior Feedback :' + isnull(@Sup_Feedback,'') + '#' + 'Weighted Score :' + cast(@WeightedScore as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	
		END
	Else IF @Tran_Type = 'D'
		BEGIN
			SELECT @OldActual = cast(Actual as varchar) ,@OldEmp_Feedback =cast(Emp_Feedback as varchar),
				   @OldSup_Score =isnull(Sup_Score,''),@OldSup_Feedback = isnull(Sup_Feedback,''),@OldWeightedScore = isnull(cast([WeightedScore] as VARCHAR),'')				  
			FROM dbo.T0100_EmployeeGoalSetting_Evaluation_Details WITH (NOLOCK)
			WHERE Cmp_ID = @Cmp_ID and Emp_GoalSetting_Review_Detail_Id = @Emp_GoalSetting_Review_Detail_Id
			
			SET @OldValue = 'Old Value' + '#'+ 'Emp Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Actual :' + cast(@OldActual as VARCHAR) + '#' + 'Employee Feedback :' +ISNULL(@OldEmp_Feedback,'') + '#' 
											 + 'Superior Score :' + isnull(@OldSup_Score,'') + '#'  + 'Superior Feedback :' + isnull(@OldSup_Feedback,'') + '#' + 'Weighted Score :' + cast(@OldWeightedScore as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	
			
			DELETE FROM T0100_EmployeeGoalSetting_Evaluation_Details WHERE Emp_GoalSetting_Review_Detail_Id = @Emp_GoalSetting_Review_Detail_Id
		END
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee Goal Review Details',@OldValue,@Emp_GoalSetting_Review_Detail_Id,@User_Id,@IP_Address
	
END
