



-- =============================================
-- Author:		<Ripal Patel>
-- ALTER date: <19-Jan-2013>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_Appraisal_Emp_PerformanceSummary_SignoffHistory]
	@Signoff_ID				    numeric(18,0) Output,
	@FK_PS_Id					numeric(18,0),
	@Signoff_Date				datetime,
	@Tran_type					varchar(1),
	@User_Id					numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	if @Tran_type = 'I'
		begin
			declare @Signoff_Version as numeric(18,0)
			select @Signoff_ID = isnull(max(Signoff_ID),0)+1 from T0090_HRMS_Appraisal_Emp_PerformanceSummary_SignoffHistory WITH (NOLOCK)
			select @Signoff_Version = isnull(max(Signoff_Version),0)+1   from T0090_HRMS_Appraisal_Emp_PerformanceSummary_SignoffHistory WITH (NOLOCK) where FK_PS_Id = @FK_PS_Id
			INSERT INTO T0090_HRMS_Appraisal_Emp_PerformanceSummary_SignoffHistory
				   (Signoff_ID
				   ,FK_PS_Id
				   ,Signoff_Version
				   ,Signoff_Date
				   ,Emp_ID)
			 VALUES
				   (@Signoff_ID
				   ,@FK_PS_Id
				   ,@Signoff_Version
				   ,@Signoff_Date
				   ,@User_Id)
		end	
END



