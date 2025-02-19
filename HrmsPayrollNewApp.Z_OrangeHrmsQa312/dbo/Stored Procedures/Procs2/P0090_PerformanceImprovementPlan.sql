


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_PerformanceImprovementPlan]
	   @Emp_PIP_Id			numeric(18,0) OUT
	  ,@Cmp_Id				numeric(18,0)
      ,@Emp_Id				numeric(18,0)
      ,@PIP_Status			int
      ,@FinYear				int
      ,@StartDate			datetime
      ,@Enddate				datetime
      ,@tran_type			varchar(1)
      ,@User_Id				numeric(18,0)
      ,@IP_Address			varchar(30)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @OldValue as varchar(max)
	declare @OldPIP_Status as varchar(18)
	declare @OldFinYear as varchar(4)
	declare @oldDate as varchar(50)
	
	SET @OldValue = ''
	SET @OldFinYear = ''
	SET @OldPIP_Status = ''
	Set @oldDate = ''
	
	If @Tran_Type = 'I'
		BEGIN
			IF EXISTS(select 1 from T0090_PerformanceImprovementPlan WITH (NOLOCK) where Emp_Id=@Emp_Id and FinYear=@FinYear)
				BEGIN 
					SET @Emp_PIP_Id = 0 
					Select @Emp_PIP_Id
					RETURN
				END
			SELECT @Emp_PIP_Id = isnull(max(Emp_PIP_Id),0)+1 from T0090_PerformanceImprovementPlan WITH (NOLOCK)
			INSERT INTO T0090_PerformanceImprovementPlan
			(
				Emp_PIP_Id
			   ,Cmp_Id	
			   ,Emp_Id
			   ,PIP_Status
			   ,FinYear
			   ,CreatedDate
			   ,StartDate
			   ,Enddate
			)
			VALUES
			(
				@Emp_PIP_Id
			   ,@Cmp_Id	
			   ,@Emp_Id
			   ,@PIP_Status
			   ,@FinYear
			   ,GETDATE()
			   ,@StartDate
			   ,@Enddate
			)
			set @OldValue = 'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Status :' + case when @PIP_Status = 0 then 'Draft' when @PIP_Status=1 then 'Send For Employee Review' when @PIP_Status=3 then 'Approved By Employee' when @PIP_Status =4 then 'Approved By Manager' end + '#' + 'Date :' +  cast(GETDATE() as varchar)
		END
	ELSE IF @Tran_Type ='U'
		BEGIN
			SELECT @OldPIP_Status = cast(PIP_Status as varchar) ,@OldFinYear =cast(FinYear as varchar),@oldDate= isnull(cast(ModifiedDate as varchar),cast(CreatedDate as varchar)) From dbo.T0090_PerformanceImprovementPlan WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Emp_PIP_Id = @Emp_PIP_Id
			UPDATE T0090_PerformanceImprovementPlan
			SET PIP_Status = @PIP_Status
				,FinYear	= @FinYear
				,ModifiedDate = GETDATE()
			WHERE Emp_PIP_Id = @Emp_PIP_Id
			
			set @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Status :' + case when @OldPIP_Status = 0 then 'Draft' when @OldPIP_Status=1 then 'Send For Employee Review' when @OldPIP_Status=3 then 'Approved By Employee' when @OldPIP_Status =4 then 'Approved By Manager' end + '#' + 'Date :' +  cast(GETDATE() as varchar)
							+'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Status :' + case when @PIP_Status = 0 then 'Draft' when @PIP_Status=1 then 'Send For Employee Review' when @PIP_Status=3 then 'Approved By Employee' when @PIP_Status =4 then 'Approved By Manager' end + '#' + 'Date :' +  cast(GETDATE() as varchar)
		END
	ELSE IF  @Tran_Type = 'D'	
		BEGIN
			SELECT @OldPIP_Status = cast(PIP_Status as varchar) ,@OldFinYear =cast(FinYear as varchar),@oldDate= isnull(cast(ModifiedDate as varchar),cast(CreatedDate as varchar)) From dbo.T0090_PerformanceImprovementPlan WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Emp_PIP_Id = @Emp_PIP_Id
			set @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Status :' + case when @OldPIP_Status = 0 then 'Draft' when @OldPIP_Status=1 then 'Send For Employee Review' when @OldPIP_Status=3 then 'Approved By Employee' when @OldPIP_Status =4 then 'Approved By Manager' end + '#' + 'Date :' +  cast(GETDATE() as varchar)
			
			DELETE FROM T0095_PerformanceImprovementPlan_Details WHERE Emp_PIP_Id = @Emp_PIP_Id
			DELETE FROM T0090_PerformanceImprovementPlan WHERE Emp_PIP_Id = @Emp_PIP_Id
		END
		exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Performance Improvement Plan',@OldValue,@Emp_PIP_Id,@User_Id,@IP_Address

END


