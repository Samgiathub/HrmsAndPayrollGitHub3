


-- =============================================
-- Author:		Sneha
-- ALTER date: 1 apr 2013
-- Description:	emp and sup skill rating during appraisal
--exec P0090_HRMS_EMP_SKILL_RATING 25,1353,9,2.50,0,0
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_EMP_SKILL_RATING]
	@Emp_Skill_ID  numeric(18,0) output,
	@Emp_ID numeric(18,0),
	@Cmpid numeric(18,0),
	@Skill_Rate_Employee numeric(18,2),
	@Skill_Rate_Superior numeric(18,2),
	@estatus as int
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	if @estatus  = 0
		BEGIN
			UPDATE T0090_HRMS_EMP_SKILL_SETTING
			SET Skill_Rate_Employee = @Skill_Rate_Employee 
			WHERE Emp_ID= @Emp_ID AND Emp_Skill_ID = @Emp_Skill_ID
		END
	Else if @estatus = 1
		BEGIN
			UPDATE T0090_HRMS_EMP_SKILL_SETTING
			SET Skill_Rate_Superior = @Skill_Rate_Superior 
			WHERE Emp_ID= @Emp_ID AND Emp_Skill_ID = @Emp_Skill_ID
		END
END


