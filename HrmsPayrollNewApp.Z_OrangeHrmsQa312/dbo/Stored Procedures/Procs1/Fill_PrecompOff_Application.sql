


-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <27052015>
-- Description:	<PreComOff Application Date>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE  [dbo].[Fill_PrecompOff_Application] 
	@Rpt_level	numeric(18,0)
   ,@PreCompOff_App_ID numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	If @Rpt_Level = 1 
		begin
			select  LAD.Cmp_ID, LAD.Emp_ID, LAD.Emp_Full_Name, LAD.S_Emp_ID, LAD.PreCompOff_App_ID, LAD.PreCompOff_App_date, 
			LAD.Alpha_Emp_code,LAD.From_date,LAD.To_Date,LAD.Period,LAD.Remarks,LAD.App_Status 
			From V0110_PrecompOff_Application LAD where PreCompOff_App_ID = @PreCompOff_App_ID 
		end
	else
		begin
			Select LAD.Cmp_ID,LAD.Emp_ID, LAD.Emp_Full_Name, LAD.S_Emp_ID, LAD.PreCompOff_App_ID, LAD.PreCompOff_App_date, 
				   LAD.Alpha_Emp_code,isnull(Qry1.From_Date,LAD.From_date) as From_Date,
				   isnull(Qry1.To_date,LAD.To_Date) as To_Date,
				   isnull(Qry1.Period,LAD.Period) as Period,
				   ISNULL(qry1.Remarks,LAD.Remarks) as Remarks,
				   isnull(Qry1.Approval_Status,LAD.App_Status) as App_Status 
				   From V0110_PrecompOff_Application LAD left outer join 
				   (
					   select lla.PreCompOff_App_ID As App_ID, Rpt_Level  as Rpt_Level,lla.Approval_Status,Lla.From_Date,
					   LLA.To_Date,LLA.Period,LLA.Remarks  From T0115_PreCompOff_Approval_Level lla WITH (NOLOCK) inner join 
					   (
						Select max(rpt_level) as rpt_level1,PreCompOff_App_ID From T0115_PreCompOff_Approval_Level WITH (NOLOCK)
						where PreCompOff_App_ID = @PreCompOff_App_ID Group by PreCompOff_App_ID
					   ) Qry on qry.PreCompOff_App_ID = lla.PreCompOff_App_ID and qry.rpt_level1 = lla.rpt_level
				   ) As Qry1 On  LAD.PreCompOff_App_ID = Qry1.App_ID	
				   where LAD.PreCompOff_App_ID = @PreCompOff_App_ID
		end
END

