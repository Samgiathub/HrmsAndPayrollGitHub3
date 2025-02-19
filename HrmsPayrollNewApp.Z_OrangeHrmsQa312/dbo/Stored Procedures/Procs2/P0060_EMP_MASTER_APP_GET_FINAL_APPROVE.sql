


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0060_EMP_MASTER_APP_GET_FINAL_APPROVE] 
	-- Add the parameters for the stored procedure here
	@Emp_Tran_ID BIGINT = 0,
	@Is_Final_Approval TINYINT  =0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    -- Insert statements for procedure here
	SELECT  @Is_Final_Approval = AP.Is_Final_Approval 
					   
	FROM	T0060_EMP_MASTER_APP AP WITH (NOLOCK)
		INNER JOIN (SELECT	Emp_Application_ID, Max(Emp_Tran_ID) As Emp_Tran_ID
					FROM	T0060_EMP_MASTER_APP AP1 WITH (NOLOCK)
					WHERE	EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP AP2 WITH (NOLOCK)					
									WHERE AP2.Emp_Application_ID=AP1.Emp_Application_ID AND AP2.Emp_Tran_ID=@Emp_Tran_ID)
					GROUP BY Emp_Application_ID) AP1 ON AP.Emp_Application_ID=AP1.Emp_Application_ID 
														AND AP.Emp_Tran_ID=AP1.Emp_Tran_ID
				
				SELECT  @Is_Final_Approval as Is_Final_Approval
					
END

