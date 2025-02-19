

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_HRMS_TeamSelfAssessment]
	 @cmp_id	as numeric(18,0)
	,@sup_id	as numeric(18,0)
	,@Startdate as varchar(50)
	,@EndDate	as varchar(50)
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	declare @col as numeric(18,0)
	declare cur  cursor
for 
	--select emp_id from T0080_EMP_MASTER where Emp_Superior=@sup_id
		SELECT erd.Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
		(select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
			where ERD1.Effect_Date <= getdate() and erd1.R_Emp_ID=@sup_id
			GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = isnull(ERD.Effect_Date,ERD.Effect_Date)
			where ERD.r_emp_id = @sup_id
	open cur
		Fetch Next From cur into @col
		WHILE @@FETCH_STATUS = 0
		begin
			if exists(Select InitiateId,Cmp_ID,Emp_Id,AppraiserId,SA_Startdate,SA_Enddate from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id = @col and SA_Status<>1 and  SA_Startdate <= @Startdate and SA_Enddate >= @EndDate and SA_SendToRM=1 )
				begin
					Select InitiateId,Cmp_ID,Emp_Id,AppraiserId,SA_Startdate,SA_Enddate from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id = @col and SA_Status<>1 and  SA_Startdate <= @Startdate and SA_Enddate >= @EndDate  and SA_SendToRM=1
				End
			Fetch Next From cur into @col
		End
Close cur	
Deallocate cur
END

