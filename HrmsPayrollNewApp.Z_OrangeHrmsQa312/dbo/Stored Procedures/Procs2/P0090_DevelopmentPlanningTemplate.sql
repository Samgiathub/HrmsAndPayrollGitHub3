


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_DevelopmentPlanningTemplate]
	   @Emp_DPT_Id			numeric(18,0) OUT
      ,@Cmp_Id				numeric(18,0)
      ,@Emp_Id				numeric(18,0)
      ,@FinYear				int
      ,@DPT_Status			int      
      ,@Emp_Comment			varchar(300)
      ,@Manager_Comment		varchar(300)
      ,@StartDate			datetime
      ,@Enddate				datetime
      ,@tran_type			varchar(1)
      ,@User_Id				numeric(18,0)
      ,@IP_Address			varchar(30)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	declare @OldValue as varchar(max)
	declare @OldDPT_Status as varchar(18)
	declare @OldFinYear as varchar(4)
	declare @OldEmp_Comment as varchar(300)
	declare @OldManager_Comment as varchar(300)
	declare @oldDate as varchar(50)
	
	set @OldValue =''
	set @OldDPT_Status = ''
	set @OldFinYear = ''
	set @OldEmp_Comment =''
	set @OldManager_Comment =''
	set @oldDate =''
	
	If @Tran_Type = 'I'
		BEGIN
			IF EXISTS(select 1 from T0090_DevelopmentPlanningTemplate WITH (NOLOCK) where Emp_Id=@Emp_Id and FinYear=@FinYear)
				BEGIN 
					SET @Emp_DPT_Id = 0 
					Select @Emp_DPT_Id
					RETURN
				END
			SELECT @Emp_DPT_Id = isnull(max(Emp_DPT_Id),0)+1 from T0090_DevelopmentPlanningTemplate WITH (NOLOCK)
			INSERT INTO T0090_DevelopmentPlanningTemplate
			(
				 Emp_DPT_Id
				,Cmp_Id
				,Emp_Id
				,DPT_Status
				,FinYear
				,Emp_Comment
				,Manager_Comment
				,CreatedDate
				,StartDate
				,Enddate
			)VALUES
			(
				 @Emp_DPT_Id
				,@Cmp_Id
				,@Emp_Id
				,@DPT_Status
				,@FinYear
				,@Emp_Comment
				,@Manager_Comment
				,GETDATE()
				,@StartDate
				,@Enddate
			)
			set @OldValue = 'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Status :' + case when @DPT_Status = 0 then 'Draft' when @DPT_Status=1 then 'Send For Employee Review' when @DPT_Status=3 then 'Approved By Employee' when @DPT_Status =4 then 'Approved By Manager' end + '#' + 'Employee comment :' +ISNULL(@Emp_Comment,'') + '#' + 'Manager Comment :' + isnull(@Manager_Comment,'') + '#' + 'Date :' +  cast(GETDATE() as varchar)
		END
	ELSE IF @Tran_Type ='U'
		BEGIN
			select @OldDPT_Status = cast(DPT_Status as varchar) ,@OldFinYear =cast(FinYear as varchar),@OldEmp_Comment =isnull(Emp_Comment,''),@OldManager_Comment = isnull(Manager_Comment,''),@oldDate= isnull(cast(ModifiedDate as varchar),cast(CreatedDate as varchar)) From dbo.T0090_DevelopmentPlanningTemplate WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Emp_DPT_Id = @Emp_DPT_Id
			
			UPDATE T0090_DevelopmentPlanningTemplate
			SET DPT_Status = @DPT_Status
				,FinYear	= @FinYear
				,Emp_Comment= @Emp_Comment				
				,Manager_Comment = @Manager_Comment
				,ModifiedDate = GETDATE()
			WHERE Emp_DPT_Id = @Emp_DPT_Id
			
			set @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + @OldFinYear + '#' + 'Status :' + case when @OldDPT_Status = 0 then 'Draft' when @OldDPT_Status=1 then 'Send For Employee Review' when @OldDPT_Status=3 then 'Approved By Employee' when @OldDPT_Status =4 then 'Approved By Manager' end + '#' + 'Employee comment :' +ISNULL(@OldEmp_Comment,'') + '#' + 'Manager Comment :' + isnull(@OldManager_Comment,'') + '#' + 'Date :' +  @oldDate +
							'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Status :' + case when @DPT_Status = 0 then 'Draft' when @DPT_Status=1 then 'Send For Employee Review' when @DPT_Status=3 then 'Approved By Employee' when @DPT_Status =4 then 'Approved By Manager' end + '#' + 'Employee comment :' +ISNULL(@Emp_Comment,'') + '#' + 'Manager Comment :' + isnull(@Manager_Comment,'') + '#' + 'Date :' + cast(GETDATE() as varchar)
		END
	ELSE IF  @Tran_Type = 'D'	
		BEGIN
			select @OldDPT_Status = cast(DPT_Status as varchar) ,@OldFinYear =cast(FinYear as varchar),@OldEmp_Comment =isnull(Emp_Comment,''),@OldManager_Comment = isnull(Manager_Comment,''), @oldDate= isnull(cast(ModifiedDate as varchar),cast(CreatedDate as varchar))  From dbo.T0090_DevelopmentPlanningTemplate WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Emp_DPT_Id = @Emp_DPT_Id
			set @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + @OldFinYear + '#' + 'Status :' + case when @OldDPT_Status = 0 then 'Draft' when @OldDPT_Status=1 then 'Send For Employee Review' when @OldDPT_Status=3 then 'Approved By Employee' when @OldDPT_Status =4 then 'Approved By Manager' end + '#' + 'Employee comment :' +ISNULL(@OldEmp_Comment,'') + '#' + 'Manager Comment :' + isnull(@OldManager_Comment,'') + '#' + 'Date :' +  @oldDate
			
			DELETE FROM T0095_DevelopmentPlanningTemplate_Details WHERE Emp_DPT_Id = @Emp_DPT_Id
			DELETE FROM T0090_DevelopmentPlanningTemplate WHERE Emp_DPT_Id = @Emp_DPT_Id
		END
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Development Planning Template',@OldValue,@Emp_DPT_Id,@User_Id,@IP_Address
END


