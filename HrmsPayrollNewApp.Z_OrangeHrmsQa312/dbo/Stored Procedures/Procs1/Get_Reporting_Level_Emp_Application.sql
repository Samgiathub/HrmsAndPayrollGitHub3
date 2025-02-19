


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Reporting_Level_Emp_Application] 
	-- Add the parameters for the stored procedure here
	@Emp_ID INT,
	@Rpt_Level INT=0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	IF @Emp_ID <> 0
	BEGIN
    -- Insert statements for procedure here
		Select @Rpt_Level=SD.Rpt_Level
		FROM	T0050_Scheme_Detail SD WITH (NOLOCK)
				--INNER JOIN T0030_BRANCH_MASTER BM on sd.Cmp_Id = bm.Cmp_ID and (CHARINDEX('#' + CAST(BM.BRANCH_ID AS VARCHAR(10)) + '#', '#' + sd.Leave + '#') > 0)
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) on sd.Cmp_Id = bm.Cmp_ID and ((CHARINDEX('#' + CAST(BM.BRANCH_ID AS VARCHAR(10)) + '#', '#' + sd.Leave + '#') > 0) OR sd.Leave = '0')
				INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id 
		WHERE	SM.Scheme_Type = 'Employee Application' AND SD.App_Emp_ID=@Emp_ID
	
	END
	
END


