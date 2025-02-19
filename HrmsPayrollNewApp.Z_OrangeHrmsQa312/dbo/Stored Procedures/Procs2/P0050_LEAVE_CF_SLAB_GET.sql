



-- =============================================
-- Author	  :	<Alpesh>
-- ALTER date: <24-Apr-2012>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_LEAVE_CF_SLAB_GET]
	 @Leave_ID		numeric(18, 0)
	,@Cmp_ID		numeric(18, 0)
	--,@Type_ID		numeric(18, 0)
	,@Effective_Date	Datetime
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	--Comment by nilesh patel on 02042015 --Start
	--Select ROW_NUMBER() over(order by c.Slab_ID) as Row_No, c.*,'U' as TransType from T0050_LEAVE_CF_SLAB c left outer join 
	--(Select MAX(Effective_Date) Effective_Date,Leave_ID from T0050_LEAVE_CF_SLAB where Cmp_Id=@Cmp_ID and Leave_ID=@Leave_ID group by Leave_ID) qry 
	--on c.Leave_ID=qry.Leave_ID and c.Effective_Date=qry.Effective_Date
	--where c.Cmp_ID=@Cmp_ID  and  c.Leave_ID=@Leave_ID--and c.Type_ID=@Type_ID
	--order by c.Slab_ID,From_Days
	--Comment by nilesh patel on 02042015 --End
	
	Select ROW_NUMBER() over(order by Slab_ID) as Row_No,*,'U' as TransType From T0050_LEAVE_CF_SLAB WITH (NOLOCK) where Leave_ID = @Leave_ID and Cmp_ID = @Cmp_ID /*and Type_ID = @Type_ID*/ and Effective_Date = @Effective_Date

	
END



