

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_MY_Team_Leave]
	-- Add the parameters for the stored procedure here
	@Cmp_ID		NUMERIC(18,0),
	@Emp_ID		NUMERIC(18,0)
	
	
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	Declare @Member_emp_Ids as varchar(max)

	Create table #MemberDetails
	(
		Emp_Id     Int
	)


    SELECT @Member_emp_Ids = STUFF((select distinct(convert(nvarchar,ERD.Emp_ID)) + ','  from T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
	INNER JOIN (select max(Effect_Date) as Effect_Date,Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) where ERD1.Effect_Date <= getdate() and ERD1.Reporting_Method = 'Direct'
		AND Emp_ID IN (Select Emp_ID From T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE R_Emp_ID = @Emp_ID and Reporting_Method = 'Direct' ) GROUP by Emp_ID ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID 
			AND Tbl1.Effect_Date = ERD.Effect_Date where ERD.R_Emp_ID = @Emp_ID and ERD.Reporting_Method = 'Direct' for xml path ('') ), 1, 0, '') 
			


	--Select @Member_emp_Ids

	insert into #MemberDetails(Emp_Id)
	select x.part
	from dbo.SplitString(@Member_emp_Ids, ',') x
	

	Select EM.Emp_Id, EM.Initial,Em.Alpha_Emp_Code + ' - ' + EM.Emp_First_Name +' '+ EM.Emp_Second_Name  +' ' + EM.Emp_Last_Name as Emp_Full_Name,
	Em.Alpha_Emp_Code,REPLACE(CONVERT(VARCHAR(11), lad.From_Date, 113),' ','-') as From_Date  ,REPLACE(CONVERT(VARCHAR(11), lad.To_Date, 113),' ','-') as To_Date 
	,Convert(VARCHAR(10),LAD.Leave_Period) + ' '  + CASE WHEN LEAVE_ASSIGN_As = 'Part Day' then 'Hour(s)' Else 'Day(s)' END  AS Leave_Period,LM.Leave_Name,LAD.Leave_Assign_As,
	(
				SELECT STUFF((select '; ' + cast(convert(varchar(11),For_date,103) as varchar(max)) + '-' + cast(Leave_period as varchar(10))
					FROM T0150_LEAVE_CANCELLATION   T WITH (NOLOCK)
					WHERE T.Leave_Approval_id=LAD.Leave_Approval_ID
						AND T.Is_Approve=1
					ORDER BY EMP_ID
				FOR XML PATH('')), 1, 1, '') 
      
			) AS CANCEL_DATE

	from T0120_LEAVE_APPROVAL  LA WITH (NOLOCK)
	inner join T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_Id =LA.Emp_ID
	inner join  #MemberDetails MD on LA.Emp_ID =md.Emp_Id
	left join T0130_LEAVE_APPROVAL_DETAIL  LAD WITH (NOLOCK) on LA.Leave_Approval_ID =LAD.Leave_Approval_ID	
	inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LAD.Leave_ID=Lm.Leave_ID
	where  CONVERT(VARCHAR(10), LAD.To_Date, 112)  >= CONVERT(VARCHAR(10), GETDATE(), 112)   and  la.Approval_Status='A'

END
