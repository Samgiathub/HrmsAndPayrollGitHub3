



-- =============================================
-- Author:		Sneha
-- ALTER date: 13/02/2012
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Select_FillExitDetails]
	@cmp_id as numeric(18,0),
	 @exit_id as numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	Declare @smpid as numeric(18,0)
	
	If @cmp_id <>0
		Begin
			Select @smpid= ISNULL(s_emp_id,0) From T0200_Emp_ExitApplication WITH (NOLOCK) Where cmp_id = @cmp_id and exit_id =@exit_id
			If @smpid = 0
				Begin
					Select distinct E.exit_id,E.emp_id,E.cmp_id,E.branch_id,E.desig_id,E.resignation_date,
					E.last_date,E.reason,E.comments,E.status,E.is_rehirable,Isnull(E.s_emp_id,0)as s_emp_id,E.feedback,E.sup_ack,E.interview_date,E.Rpt_Mng_ID,
					E.interview_time,E.Is_process,E.Email_ForwardTo,E.DriveData_ForwardTo,EM.Emp_Full_Name,E.Application_Date,isnull(Exit_App_Doc,'')Exit_App_Doc
					,RM.Reason_Name,EAL.Comments as Sup_Comment	-- Added by Divyaraj Kiri on 23/10/2024
					From T0200_Emp_ExitApplication as E WITH (NOLOCK)
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = E.emp_id  --Added By Jaina 18-04-2016
						INNER JOIN T0040_Reason_Master RM WITH (NOLOCK) ON RM.Res_Id = E.reason	-- Added by Divyaraj Kiri on 23/10/2024
						INNER JOIN T0300_Emp_Exit_Approval_Level EAL WITH (NOLOCK) ON EAL.S_Emp_Id = E.s_emp_id	-- Added by Divyaraj Kiri on 23/10/2024
					Where E.cmp_id = @cmp_id and E.exit_id = @exit_id 
				End
			Else
				Begin
					Select distinct E.exit_id,E.emp_id,E.cmp_id,E.branch_id,E.desig_id,E.resignation_date,
					E.last_date,E.reason,E.comments,E.status,E.is_rehirable,E.s_emp_id,G.Emp_Superior,E.feedback,E.sup_ack,E.interview_date,
					E.interview_time,E.Is_process,E.Email_ForwardTo,E.DriveData_ForwardTo,E.Rpt_Mng_ID,
					G.Emp_Full_Name,E.Application_Date,isnull(Exit_App_Doc,'')Exit_App_Doc --Added By Jaina 29-03-2016 
					,RM.Reason_Name,EAL.Comments as Sup_Comment	-- Added by Divyaraj Kiri on 23/10/2024
					From T0200_Emp_ExitApplication as E WITH (NOLOCK) left join 
					Get_Emp_Superior as G on  G.Superior_Id = E.s_emp_id and g.Emp_ID=E.emp_id  --Change By Jaina 29-03-2016
					INNER JOIN T0040_Reason_Master RM WITH (NOLOCK) ON RM.Res_Id = E.reason	-- Added by Divyaraj Kiri on 23/10/2024
					INNER JOIN T0300_Emp_Exit_Approval_Level EAL WITH (NOLOCK) ON EAL.S_Emp_Id = E.s_emp_id	-- Added by Divyaraj Kiri on 23/10/2024
					Where E.cmp_id = @cmp_id and E.exit_id = @exit_id     --Left Join Done by Ramiz on 07/01/2015 as exit application was not coming Blank
				End
		End
		
END




