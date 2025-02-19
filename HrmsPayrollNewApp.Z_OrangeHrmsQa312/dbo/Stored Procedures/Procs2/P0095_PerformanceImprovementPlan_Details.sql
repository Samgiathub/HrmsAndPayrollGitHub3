
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0095_PerformanceImprovementPlan_Details]
	   @Emp_PIP_Detail_Id		numeric(18,0)
      ,@Cmp_Id					numeric(18,0)
      ,@Emp_Id					numeric(18,0)
      ,@Emp_PIP_Id				numeric(18,0)
      ,@ImprovementArea			varchar(300)
      ,@Target					nvarchar(100)
      ,@Start_Date				datetime
      ,@End_Date				datetime
      ,@Emp_Feedback			nvarchar(200) --Changed by Deepali -02Jun22
      ,@Manager_Feedback		nvarchar(200) --Changed by Deepali -02Jun22
      ,@finyear					int
      ,@Tran_Type				varchar(1)
      ,@User_Id					numeric(18,0)
      ,@IP_Address				varchar(30)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	declare @OldValue as nvarchar(max)  --Changed by Deepali -02Jun22
	declare @OldImprovementArea as varchar(300)
	declare @OldTarget as nvarchar(100)
	declare @OldStart_Date as varchar(18)
	declare @OldEnd_Date as varchar(18)
	declare @OldEmp_Feedback as nvarchar(200)  --Changed by Deepali -02Jun22
	declare @OldManager_Feedback as nvarchar(200)  --Changed by Deepali -02Jun22
	declare @oldDate as varchar(50)
	
	SET @OldValue =''
	SET @OldImprovementArea =''
	SET @OldTarget =''
	SET @OldStart_Date =''
	SET @OldEnd_Date =''
	SET @OldEmp_Feedback =''
	SET @OldManager_Feedback =''
	SET @oldDate =''
	
	IF @Tran_Type = 'I'
		BEGIN
			IF 	@Emp_PIP_Id =0
				BEGIN 
					select @Emp_PIP_Id= max(Emp_PIP_Id) from T0090_PerformanceImprovementPlan WITH (NOLOCK) where Cmp_Id = @cmp_id and emp_id=@emp_id and FinYear = @finyear					
				END
			SELECT @Emp_PIP_Detail_Id = isnull(max(Emp_PIP_Detail_Id),0)+1 from T0095_PerformanceImprovementPlan_Details WITH (NOLOCK)
			INSERT INTO T0095_PerformanceImprovementPlan_Details
			(
				   Emp_PIP_Detail_Id
				  ,Cmp_Id
				  ,Emp_Id
				  ,Emp_PIP_Id
				  ,ImprovementArea
				  ,Target
				  ,Start_Date
				  ,End_Date
				  ,Emp_Feedback
				  ,Manager_Feedback
			)
			VALUES
			(
				   @Emp_PIP_Detail_Id
				  ,@Cmp_Id
				  ,@Emp_Id
				  ,@Emp_PIP_Id
				  ,@ImprovementArea
				  ,@Target
				  ,@Start_Date
				  ,@End_Date
				  ,@Emp_Feedback
				  ,@Manager_Feedback
			)
			
			SET @OldValue = 'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Improvement Area :' + cast(@ImprovementArea as VARCHAR) + '#' + 'Action Target :' +ISNULL(@Target,'') + '#' 
												+ 'Start Date :' + isnull(cast(@start_Date as varchar),'') + '#' + 'End Date :' + cast(@End_Date as varchar) + '#' 
												+ 'Emp Feedback :' + cast(@Emp_Feedback as varchar) + '#' + 'Manager Feedback :' + cast(@Manager_Feedback as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	
		END
	Else IF @Tran_Type = 'U'
		BEGIN
			select @OldImprovementArea = cast(ImprovementArea as varchar) ,@OldTarget =cast(Target as varchar),
				   @OldStart_Date =isnull(cast([Start_Date] as VARCHAR),''),@OldEnd_Date = isnull(cast([End_Date] as VARCHAR),''),
				   @OldEmp_Feedback = cast(Emp_Feedback as varchar),@OldManager_Feedback = cast(Manager_Feedback as varchar)	  
			From dbo.T0095_PerformanceImprovementPlan_Details WITH (NOLOCK)
			Where Cmp_ID = @Cmp_ID and Emp_PIP_Detail_Id = @Emp_PIP_Detail_Id
			
			UPDATE T0095_PerformanceImprovementPlan_Details
			SET  ImprovementArea = @ImprovementArea
			    ,[Target] = @Target
			    ,[Start_Date] = @Start_Date
			    ,[End_Date] = @End_Date
			    ,Emp_Feedback = @Emp_Feedback
			    ,Manager_Feedback = @Manager_Feedback
			WHERE Emp_PIP_Detail_Id = @Emp_PIP_Detail_Id
			
			SET @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Development Area :' + cast(@OldImprovementArea as VARCHAR) + '#' + 'Target :' +ISNULL(@OldTarget,'') + '#' 
												+ 'Start Date :' + isnull(cast(@OldStart_Date as varchar),'') + '#' + 'End Date :' + cast(@OldEnd_Date as varchar) + '#' 
												+ 'Emp Feedback :' + cast(@OldEmp_Feedback as nvarchar) + '#' + 'Manager Feedback :' + cast(@OldManager_Feedback as nvarchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)+	
							'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Development Area :' + cast(@ImprovementArea as VARCHAR) + '#' + ' Target :' +ISNULL(@Target,'') + '#' 
												+ 'Start Date :' + isnull(cast(@Start_Date as VARCHAR),'') + '#' + 'End Date :' + cast(@End_Date as varchar) + '#'  
												+ 'Emp Feedback :' + cast(@Emp_Feedback as nvarchar) + '#' + 'Manager Feedback :' + cast(@Manager_Feedback as nvarchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	
		END
	Else IF @Tran_Type = 'D'
		BEGIN
			select @OldImprovementArea = cast(ImprovementArea as varchar) ,@OldTarget =cast(Target as nvarchar),
				   @OldStart_Date =isnull(cast([Start_Date] as VARCHAR),''),@OldEnd_Date = isnull(cast([End_Date] as VARCHAR),''),
				   @OldEmp_Feedback = cast(Emp_Feedback as nvarchar),@OldManager_Feedback = cast(Manager_Feedback as nvarchar)	  
			From dbo.T0095_PerformanceImprovementPlan_Details WITH (NOLOCK)
			Where Cmp_ID = @Cmp_ID and Emp_PIP_Detail_Id = @Emp_PIP_Detail_Id
			
			SET @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Development Area :' + cast(@OldImprovementArea as VARCHAR) + '#' + 'Target :' +ISNULL(@OldTarget,'') + '#' 
												+ 'Start Date :' + isnull(cast(@OldStart_Date as varchar),'') + '#' + 'End Date :' + cast(@OldEnd_Date as varchar) + '#' 
												+ 'Emp Feedback :' + cast(@OldEmp_Feedback as nvarchar) + '#' + 'Manager Feedback :' + cast(@OldManager_Feedback as nvarchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)
												
			DELETE FROM T0095_PerformanceImprovementPlan_Details WHERE Emp_PIP_Detail_Id = @Emp_PIP_Detail_Id
		END
END
--SP-8
