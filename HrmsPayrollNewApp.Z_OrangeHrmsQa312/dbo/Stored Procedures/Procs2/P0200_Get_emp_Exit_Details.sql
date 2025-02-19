

-- =============================================
-- Author:		Sneha
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Get_emp_Exit_Details]
@emp_id as numeric(18,0),	
@cmp_id as numeric(18,0)	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	declare @sup_id as numeric(18,0)
	-- ADDED BY GADRIWALA MUSLIM 01092016
	SELECT EXIT_ID,RESIGNATION_DATE,STATUS FROM T0200_EMP_EXITAPPLICATION EEA  WITH (NOLOCK) WHERE 
	EEA.EMP_ID = @EMP_ID	AND EEA.CMP_ID = @CMP_ID AND (EEA.STATUS = 'P' OR EEA.STATUS = 'H')

--COMMENTED BY GADIRWALA MUSLIM 01092016 - WRITTEN CODE WITHOUT MIND & UNUSE
    -- Insert statements for procedure here
--	If Exists (select isnull(s_emp_id,0) from T0200_Emp_ExitApplication where emp_id = @emp_id and cmp_id=@cmp_id)
--begin
--	select * from T0200_Emp_ExitApplication as x, T0080_EMP_MASTER as s where 
--				x.emp_id=@emp_id and x.cmp_id = @cmp_id and x.emp_id = s.Emp_ID and status = 'P' 
--	union all
--		select * from T0200_Emp_ExitApplication as x, T0080_EMP_MASTER as s where 
--				x.emp_id=@emp_id and x.cmp_id = @cmp_id and x.emp_id = s.Emp_ID and status = 'H' 
--end
--else
--	begin
--		select * from T0200_Emp_ExitApplication as x , Get_Emp_Superior as s where
--			x.emp_id=@emp_id and x.cmp_id = @cmp_id and x.emp_id = s.Emp_id and status='P' 
--			Union All
--		select * from T0200_Emp_ExitApplication as x , Get_Emp_Superior as s where
--			x.emp_id=@emp_id and x.cmp_id = @cmp_id and x.emp_id = s.Emp_id and status='H' 
--	end
	--if COL_LENGTH('V0200_ExitInterview','s_emp_id') is not null
		
	--	begin
	--		select * from V0200_ExitInterview as x , Get_Emp_Superior as s where
	--		x.emp_id=@emp_id and x.cmp_id = @cmp_id and x.emp_id = s.Emp_id
	--	end
	--else
	--	begin
	--		select * from V0200_ExitInterview as x, T0080_EMP_MASTER as s where 
	--		x.emp_id=@emp_id and x.cmp_id = @cmp_id and x.emp_id = s.Emp_ID
	--	end
	
END




