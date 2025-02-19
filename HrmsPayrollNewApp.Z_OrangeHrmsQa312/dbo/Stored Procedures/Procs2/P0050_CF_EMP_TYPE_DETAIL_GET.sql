

-- =============================================
-- Author	  :	<Alpesh>
-- ALTER date: <24-Apr-2012>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_CF_EMP_TYPE_DETAIL_GET]
	 @Leave_ID		numeric(18, 0)
	,@Cmp_ID		numeric(18, 0)	
		
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	Select t.Type_ID,t.Type_Name,t.Cmp_ID,qw.Setting_ID,qw.Effective_Date,qw.Leave_ID,qw.CF_Type_ID,
			CONVERT(nvarchar,qw.Reset_Months) as Reset_Months,qw.Duration,qw.CF_Months,qw.Release_Month,
			qw.Reset_Month_String,qw.Laps_After_Release
	from T0040_TYPE_MASTER t WITH (NOLOCK)
	left outer join 
	(Select c.Setting_ID,c.Type_ID,c.Effective_Date,c.Leave_ID,c.CF_Type_ID,c.Reset_Months,c.Duration,c.CF_Months,c.Release_Month,c.Reset_Month_String,Laps_After_Release from T0050_CF_EMP_TYPE_DETAIL c WITH (NOLOCK)
	inner join (Select MAX(Effective_Date) Effective_Date,Leave_ID from T0050_CF_EMP_TYPE_DETAIL WITH (NOLOCK) where Cmp_Id=@Cmp_ID and Leave_ID=@Leave_ID group by Leave_ID) qry 
	on c.Leave_ID=qry.Leave_ID and c.Effective_Date=qry.Effective_Date) qw 
	on ISNULL(qw.Type_ID,t.Type_ID)=t.Type_ID  and qw.Leave_ID=@Leave_ID 
	where t.Cmp_ID=@Cmp_ID and isnull(qw.Leave_ID,@Leave_ID)=@Leave_ID
	
END


