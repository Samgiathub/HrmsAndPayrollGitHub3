



-- =============================================
-- Author:		Rohit Patel
-- Create date: 24092015
-- Description:	For Get Rate and Subsidy Of Grade For Effective Date.
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_CANTEEN_DETAIL_Get] 
	@Cmp_ID Numeric(18,0),
	@Cnt_ID Numeric(18,0),
	@For_Date varchar(max)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	if @For_Date=''
	set @For_Date=convert(varchar(11),getdate(),103)
	
		select case when (isnull(cd.Amount,0) > 0 or isnull(cd.subsidy_amount,0) >0) then 'true' else 'False' end as Checked
		,GD.grd_id,GD.Grd_Name,isnull(cd.Amount,0) as Amount,isnull(cd.subsidy_amount,0) as subsidy_Amount,isnull(Total_Amount,0)as Total_Amount from
		T0040_GRADE_MASTER GD WITH (NOLOCK)
		left join  (select Amount,subsidy_amount,Total_Amount,grd_id from T0050_CANTEEN_DETAIL WITH (NOLOCK) where Cmp_Id=@Cmp_ID and Effective_Date=@For_Date and Cnt_Id = @Cnt_ID ) CD 
		on GD.grd_id = CD.Grd_ID
		where GD.cmp_id=@Cmp_ID  
		--and gd.IsActive = 1
 
 end
return
 
 

