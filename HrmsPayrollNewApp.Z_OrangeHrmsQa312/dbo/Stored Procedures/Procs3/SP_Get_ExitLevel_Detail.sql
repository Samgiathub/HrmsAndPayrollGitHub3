

-- =============================================
-- Author:		<Jaina>
-- Create date: <03-06-2016>
-- Description:	<Get Schemewise exit detail>
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_ExitLevel_Detail] 
	@Cmp_id numeric(18,0),
	@Exit_id numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		Select  EX.Application_Date, EX.last_date, EX.reason,EX.status, 0 As Rpt_Level, 
				Convert(varchar(10), EX.Application_Date,103) as System_Date ,
				 (EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name) as name 
		From V0200_Emp_ExitApplication EX inner JOIN
			 T0080_EMP_MASTER EM WITH (NOLOCK) ON EX.Emp_ID = EM.Emp_ID 
		Where EX.exit_id = @Exit_id and ex.cmp_id = @Cmp_id
		Union
		 Select EL.Approval_Date, EL.Last_date, EL.Reason,EL.Status, Rpt_Level,
				 Convert(varchar(10), EL.Approval_Date,103) as System_Date ,(EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name) as name 
				 From T0300_Emp_Exit_Approval_Level EL WITH (NOLOCK) inner JOIN 
						T0080_EMP_MASTER EM WITH (NOLOCK) ON EL.S_Emp_Id = EM.Emp_ID 
		Where EL.Exit_id = @Exit_id and EL.Cmp_id=@Cmp_id
		Order By Rpt_Level
END


