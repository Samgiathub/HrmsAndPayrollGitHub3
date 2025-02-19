

 ---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_Leave_Details_Get]
	@Cmp_Id as numeric
	,@Emp_Id as numeric
	,@Leave_Id as numeric	
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		Declare @Year as numeric
		Set @Year = YEAR(GETDATE())
		
		IF MONTH(GETDATE())> 3
		BEGIN
			SET @Year = @Year + 1
		END
		
		Declare @date as varchar(20)  
		Set @date = '31-Mar-'+ convert(varchar(5),@Year)  
		
		(select 
		case when ISNULL(temp.Min_Leave,0)=0 then lm.Leave_Min else temp.Min_Leave end as Leave_Min 
		,case when ISNULL(temp.Max_Leave,0)=0 then lm.Leave_Max else temp.Max_Leave end as Leave_Max
		,case when ISNULL(temp.Notice_Period,0)=0 then lm.Leave_Notice_Period else temp.Notice_Period end as Leave_Notice_Period
		,Leave_Applicable
		,Leave_Negative_Allow
		,Leave_Paid_Unpaid 
		,is_document_required
		,Apply_Hourly
		,Can_Apply_Fraction 
		,Default_Short_Name
		,Leave_Name
		,AllowNightHalt
		,Half_Paid
		,isnull(leave_negative_max_limit,0) as  leave_negative_max_limit
		,isnull(LM.Min_Leave_Not_Mandatory,0) as Min_Leave_Not_Mandatory
		,isnull(Attachment_Days,0)Attachment_Days
		from T0040_Leave_MASTER LM WITH (NOLOCK) left join 
		(	Select Min_Leave,Max_Leave,Notice_Period,Leave_ID from T0050_LEAVE_DETAIL WITH (NOLOCK) where Leave_ID = @Leave_Id 
			and Grd_ID in (Select I.Grd_ID from   dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN 
			(SELECT MAX(Increment_Id) AS Increment_Id , Emp_ID FROM dbo.T0095_Increment IM WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
			WHERE Increment_Effective_date <= @date GROUP BY emp_ID ) Qry ON I.Emp_ID = Qry.Emp_ID 
			AND I.Increment_Id = Qry.Increment_Id INNER JOIN
			dbo.T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = Qry.Emp_ID 
			where em.Cmp_ID = @Cmp_Id and em.Emp_ID = @Emp_Id)
		) as temp on LM.leave_id = temp.leave_id 
		where LM.Leave_ID = @Leave_Id )

END


