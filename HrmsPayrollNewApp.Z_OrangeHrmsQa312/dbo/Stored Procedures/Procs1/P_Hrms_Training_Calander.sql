

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Hrms_Training_Calander]
	-- Add the parameters for the stored procedure here
		@Cmp_ID numeric(18,0),  
		@Branch_ID numeric(18,0),
		@emp_id numeric(18,0)  
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	

    -- Insert statements for procedure here
		SELECT Training_Apr_ID,Training_Name,Training_Date,cast(Description AS VARCHAR(50)) as Description
			FROM   dbo.V0120_HRMS_TRAINING_APPROVAL 
			WHERE  apr_status=1 and isnull(training_apr_id,0) <> 0 and Training_Date>= cast(getdate() AS VARCHAR(11))
				   	and publishTraining=1 
			ORDER BY Training_Date ASC 
END

