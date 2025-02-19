




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0095_EmployeeGoalSetting_Details] 
	   @Emp_GoalSetting_Detail_Id	numeric(18,0)
      ,@Cmp_Id						numeric(18,0)
      ,@Emp_GoalSetting_Id			numeric(18,0)
      ,@Emp_Id						numeric(18,0)
      ,@KRA							nvarchar(500)
      ,@KPI							nvarchar(500)
      ,@Target						nvarchar(500)
      ,@Weight						numeric(18,2)
      ,@finyear						int
      ,@Tran_Type					varchar(1)
      ,@User_Id						numeric(18,0)
      ,@IP_Address					varchar(30)
      ,@KPA_Type_ID					int
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	declare @totweight as numeric(18,2)
	set @totweight =0	
	
	declare @OldValue as varchar(max)
	declare @OldKRA as varchar(500)
	declare @OldKPI as varchar(500)
	declare @OldTarget as varchar(500)
	declare @OldWeight as varchar(18)
	declare @oldDate as varchar(50)
	DECLARE @oldKPA_Type_ID as varchar(10)
	
	set @OldValue =''
	set @OldKRA = ''
	set @OldKPI = ''
	set @OldTarget =''
	set @OldWeight =''
	set @oldDate =''		
	
	IF @Tran_Type = 'I'
		BEGIN				
			if 	@Emp_GoalSetting_Id =0
				BEGIN 
					select @Emp_GoalSetting_Id= max(Emp_GoalSetting_Id) from T0090_EmployeeGoalSetting WITH (NOLOCK) where Cmp_Id = @cmp_id and emp_id=@emp_id and FinYear = @finyear
					
				END
			--calculate total					
			select @totweight = isnull(sum(isnull(Weight,0)),0) from T0095_EmployeeGoalSetting_Details inner join T0090_EmployeeGoalSetting WITH (NOLOCK) 
			on  T0090_EmployeeGoalSetting.Emp_GoalSetting_Id=T0095_EmployeeGoalSetting_Details.Emp_GoalSetting_Id
			WHERE  T0095_EmployeeGoalSetting_Details.emp_id=@emp_id and FinYear = @finyear
					and  T0090_EmployeeGoalSetting.Emp_GoalSetting_Id=@Emp_GoalSetting_Id
			
			if @totweight >= 100
				BEGIN	
					SET @Emp_GoalSetting_Id = 0 
					Select @Emp_GoalSetting_Id
					RETURN
				END
			ELSE
				BEGIN
					SELECT @Emp_GoalSetting_Detail_Id = isnull(max(Emp_GoalSetting_Detail_Id),0)+1 from T0095_EmployeeGoalSetting_Details WITH (NOLOCK)
					INSERT INTO T0095_EmployeeGoalSetting_Details	
			(
				 [Emp_GoalSetting_Detail_Id]
				,[Cmp_Id]
				,[Emp_GoalSetting_Id]
				,[Emp_Id]
				,[KRA]
				,[KPI]
				,[Target]
				,[Weight]
				,KPA_Type_ID
			)VALUES
			(
				@Emp_GoalSetting_Detail_Id
			   ,@Cmp_Id
			   ,@Emp_GoalSetting_Id
			   ,@Emp_Id
			   ,@KRA
			   ,@KPI
			   ,@Target
			   ,@Weight	
			   ,@KPA_Type_ID
			)
			
					SET @OldValue = 'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'KRA :' + cast(@KRA as VARCHAR) + '#' + 'KPI :' +ISNULL(@KPI,'') + '#' 
												+ 'Target :' + isnull(@Target,'') + '#' + 'Weight :' + cast(@Weight as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar) + '#' + 'KPA_Type_ID :' + cast(@KPA_Type_ID as varchar)
			END
		END
	Else IF @Tran_Type = 'U'
		BEGIN
			
			select @OldKRA = cast(KRA as varchar) ,@OldKPI =cast(KPI as varchar),
				   @OldTarget =isnull([Target],''),@OldWeight = isnull(cast([Weight] as VARCHAR),''),
				   @oldKPA_Type_ID =cast(KPA_Type_ID as varchar)			  
			From dbo.T0095_EmployeeGoalSetting_Details WITH (NOLOCK)
			Where Cmp_ID = @Cmp_ID and Emp_GoalSetting_Detail_Id = @Emp_GoalSetting_Detail_Id
			
			UPDATE T0095_EmployeeGoalSetting_Details
			SET KRA = @KRA
			    ,KPI = @kpi	
			    ,[Target] = @Target
			    ,[Weight] = @Weight
			    ,KPA_Type_ID=@KPA_Type_ID
			WHERE Emp_GoalSetting_Detail_Id = @Emp_GoalSetting_Detail_Id
			
			SET @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'KRA :' + cast(@OldKRA as VARCHAR) + '#' + 'KPI :' +ISNULL(@OldKPI,'') + '#' 
										+ 'Target :' + isnull(@OldTarget,'') + '#' + 'Weight :' + cast(@OldWeight as varchar) + '#' + 'KPA_Type_ID :' + cast(@oldKPA_Type_ID as varchar) +
							'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'KRA :' + cast(@KRA as VARCHAR) + '#' + 'KPI :' +ISNULL(@KPI,'') + '#' 
												+ 'Target :' + isnull(@Target,'') + '#' + 'Weight :' + cast(@Weight as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar) + '#' + 'KPA_Type_ID :' + cast(@KPA_Type_ID as varchar)
		END
	Else IF @Tran_Type = 'D'
		BEGIN
			select @OldKRA = cast(KRA as varchar) ,@OldKPI =cast(KPI as varchar),
				   @OldTarget =isnull([Target],''),@OldWeight = isnull(cast([Weight] as VARCHAR),''),
				   @oldKPA_Type_ID =cast(KPA_Type_ID as varchar)					  
			From dbo.T0095_EmployeeGoalSetting_Details WITH (NOLOCK)
			Where Cmp_ID = @Cmp_ID and Emp_GoalSetting_Detail_Id = @Emp_GoalSetting_Detail_Id
			
			SET @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'KRA :' + cast(@OldKRA as VARCHAR) + '#' + 'KPI :' +ISNULL(@OldKPI,'') + '#' 
										+ 'Target :' + isnull(@OldTarget,'') + '#' + 'Weight :' + cast(@OldWeight as varchar)+ '#' + 'KPA_Type_ID :' + cast(@oldKPA_Type_ID as varchar)
			
			DELETE FROM T0095_EmployeeGoalSetting_Details WHERE Emp_GoalSetting_Detail_Id = @Emp_GoalSetting_Detail_Id
		END
		 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee Goal Setting Details',@OldValue,@Emp_GoalSetting_Detail_Id,@User_Id,@IP_Address

END



