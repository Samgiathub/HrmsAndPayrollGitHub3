



-- =============================================
-- Author:		Sneha 
-- ALTER date: 03/10/2011
-- Description:	
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Sup_ExitAlert]
	@s_emp_id as numeric(18,0),
	@cmp_id as numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
 --  if exists(select s_emp_id  from V0200_ExitInterview where s_emp_id = 163 and interview_date <> 0)
	--select  v.emp_id,e.Emp_full_name,interview_date,interview_time,Posted_date from V0200_ExitInterview as v,T0080_EMP_MASTER as e where s_emp_id = @s_emp_id and e.Emp_ID = v.emp_id and interview_date >= GETDATE() and v.cmp_id= @cmp_id
	
	IF Exists(select 1 from V0200_EXIT_APPLICATION where s_emp_id = @s_emp_id and cmp_id = @cmp_id)
	Begin 
			Select  distinct v.emp_id,Cast(e.Emp_code as varchar)+' '+ e.Emp_full_name as Emp_full_name,interview_date,interview_time from T0200_Emp_ExitApplication as v WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where v.Emp_ID = e.emp_id  and v.cmp_id= @cmp_id and s_emp_id = @s_emp_id and GETDATE()<= interview_date order by interview_date
	End
END




