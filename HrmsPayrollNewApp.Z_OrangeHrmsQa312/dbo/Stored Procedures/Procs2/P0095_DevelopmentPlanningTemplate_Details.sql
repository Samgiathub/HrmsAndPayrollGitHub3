


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0095_DevelopmentPlanningTemplate_Details]
	   @Emp_DPT_Detail_Id		numeric(18,0)
      ,@Cmp_Id					numeric(18,0)	
      ,@Emp_Id					numeric(18,0)
      ,@Emp_DPT_Id				numeric(18,0)
      ,@DevelopmentArea			varchar(300)
      ,@Action_Target			nvarchar(100)
      ,@Start_Date				datetime
      ,@End_Date				datetime
      ,@Resources				varchar(100)
      ,@Emp_Feedback			varchar(200)
      ,@Manager_Feedback		varchar(200)
      ,@finyear					int
      ,@Tran_Type				varchar(1)
      ,@User_Id					numeric(18,0)
      ,@IP_Address				varchar(30)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @OldValue as varchar(max)
	declare @OldDevelopmentArea as varchar(300)
	declare @OldAction_Target as varchar(100)
	declare @OldStart_Date as varchar(18)
	declare @OldEnd_Date as varchar(18)
	declare @OldResources as varchar(100)
	declare @OldEmp_Feedback as varchar(200)
	declare @OldManager_Feedback as varchar(200)
	declare @oldDate as varchar(50)
	
	SET @OldValue				= ''
	SET @OldDevelopmentArea		= ''
	SET @OldAction_Target		= ''
	SET @OldStart_Date			= ''
	SET @OldEnd_Date			= ''
	SET @OldResources			= ''
	SET @OldEmp_Feedback		= ''
	SET @OldManager_Feedback	= ''
	SET @oldDate				= ''
	
	IF @Tran_Type = 'I'
		BEGIN
			IF 	@Emp_DPT_Id =0
				BEGIN 
					select @Emp_DPT_Id= max(Emp_DPT_Id) from T0090_DevelopmentPlanningTemplate WITH (NOLOCK) where Cmp_Id = @cmp_id and emp_id=@emp_id and FinYear = @finyear					
				END
			SELECT @Emp_DPT_Detail_Id = isnull(max(Emp_DPT_Detail_Id),0)+1 from T0095_DevelopmentPlanningTemplate_Details WITH (NOLOCK)
			INSERT INTO T0095_DevelopmentPlanningTemplate_Details
			(
				   Emp_DPT_Detail_Id
				  ,Cmp_Id
				  ,Emp_Id
				  ,Emp_DPT_Id
				  ,DevelopmentArea
				  ,Action_Target
				  ,[Start_Date]
				  ,End_Date
				  ,Resources
				  ,Emp_Feedback
				  ,Manager_Feedback
			)
			VALUES
			(
				   @Emp_DPT_Detail_Id
				  ,@Cmp_Id
				  ,@Emp_Id
				  ,@Emp_DPT_Id
				  ,@DevelopmentArea
				  ,@Action_Target
				  ,@Start_Date
				  ,@End_Date
				  ,@Resources
				  ,@Emp_Feedback
				  ,@Manager_Feedback
			)
			
			SET @OldValue = 'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Development Area :' + cast(@DevelopmentArea as VARCHAR) + '#' + 'Action Target :' +ISNULL(@Action_Target,'') + '#' 
												+ 'Start Date :' + isnull(cast(@start_Date as varchar),'') + '#' + 'End Date :' + cast(@End_Date as varchar) + '#' + 'Resources :' + cast(@Resources as varchar) + '#' 
												+ 'Emp Feedback :' + cast(@Emp_Feedback as varchar) + '#' + 'Manager Feedback :' + cast(@Manager_Feedback as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	
		END	
	Else IF @Tran_Type = 'U'
		BEGIN
			select @OldDevelopmentArea = cast(DevelopmentArea as varchar) ,@OldAction_Target =cast(Action_Target as varchar),
				   @OldStart_Date =isnull(cast([Start_Date] as VARCHAR),''),@OldEnd_Date = isnull(cast([End_Date] as VARCHAR),''),
				   @OldResources = 	cast(Resources as varchar), @OldEmp_Feedback = cast(Emp_Feedback as varchar),@OldManager_Feedback = cast(Manager_Feedback as varchar)	  
			From dbo.T0095_DevelopmentPlanningTemplate_Details WITH (NOLOCK)
			Where Cmp_ID = @Cmp_ID and Emp_DPT_Detail_Id = @Emp_DPT_Detail_Id
			
			UPDATE T0095_DevelopmentPlanningTemplate_Details
			SET  DevelopmentArea = @DevelopmentArea
			    ,Action_Target = @Action_Target
			    ,[Start_Date] = @Start_Date
			    ,[End_Date] = @End_Date
			    ,Resources = @Resources
			    ,Emp_Feedback = @Emp_Feedback
			    ,Manager_Feedback = @Manager_Feedback
			WHERE Emp_DPT_Detail_Id = @Emp_DPT_Detail_Id
			
			SET @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Development Area :' + cast(@OldDevelopmentArea as VARCHAR) + '#' + 'Action Target :' +ISNULL(@OldAction_Target,'') + '#' 
												+ 'Start Date :' + isnull(cast(@OldStart_Date as varchar),'') + '#' + 'End Date :' + cast(@OldEnd_Date as varchar) + '#' + 'Resources :' + cast(@OldResources as varchar) + '#' 
												+ 'Emp Feedback :' + cast(@OldEmp_Feedback as varchar) + '#' + 'Manager Feedback :' + cast(@OldManager_Feedback as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)+	
							'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Development Area :' + cast(@DevelopmentArea as VARCHAR) + '#' + 'Action Target :' +ISNULL(@Action_Target,'') + '#' 
												+ 'Start Date :' + isnull(cast(@Start_Date as VARCHAR),'') + '#' + 'End Date :' + cast(@End_Date as varchar) + '#' + 'Resources :' + cast(@Resources as varchar) + '#' 
												+ 'Emp Feedback :' + cast(@Emp_Feedback as varchar) + '#' + 'Manager Feedback :' + cast(@Manager_Feedback as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	
		END
	Else IF @Tran_Type = 'D'
		BEGIN
			select @OldDevelopmentArea = cast(DevelopmentArea as varchar) ,@OldAction_Target =cast(Action_Target as varchar),
				   @OldStart_Date =isnull(cast([Start_Date] as VARCHAR),''),@OldEnd_Date = isnull(cast([End_Date] as VARCHAR),''),
				   @OldResources = 	cast(Resources as varchar), @OldEmp_Feedback = cast(Emp_Feedback as varchar),@OldManager_Feedback = cast(Manager_Feedback as varchar)	  
			From dbo.T0095_DevelopmentPlanningTemplate_Details WITH (NOLOCK)
			Where Cmp_ID = @Cmp_ID and Emp_DPT_Detail_Id = @Emp_DPT_Detail_Id
			
			SET @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Development Area :' + cast(@OldDevelopmentArea as VARCHAR) + '#' + 'Action Target :' +ISNULL(@OldAction_Target,'') + '#' 
												+ 'Start Date :' + isnull(@OldStart_Date,'') + '#' + 'End Date :' + cast(@OldEnd_Date as varchar) + '#' + 'Resources :' + cast(@OldResources as varchar) + '#' 
												+ 'Emp Feedback :' + cast(@OldEmp_Feedback as varchar) + '#' + 'Manager Feedback :' + cast(@OldManager_Feedback as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)
												
			DELETE FROM T0095_DevelopmentPlanningTemplate_Details WHERE Emp_DPT_Detail_Id = @Emp_DPT_Detail_Id
		END
	 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Development Planning Details',@OldValue,@Emp_DPT_Detail_Id,@User_Id,@IP_Address
END


