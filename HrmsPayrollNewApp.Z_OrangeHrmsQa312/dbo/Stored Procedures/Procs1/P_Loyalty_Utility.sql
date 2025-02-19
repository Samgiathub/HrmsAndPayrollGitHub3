



CREATE PROCEDURE [dbo].[P_Loyalty_Utility]
	@Loyalty_Notification_Year as varchar(max) = ''	
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN

	DECLARE @Yearly Varchar(20)
	Set @Yearly = @Loyalty_Notification_Year

	IF Object_ID('tempdb..#YearlyData') is not null
		Drop TABLE #YearlyData

	Create Table #YearlyData
	(
		ID Numeric,
		Completed_Year Numeric 
	)

	Insert into #YearlyData
	Select * From dbo.Split(@Yearly,'#')

SELECT CM.Cmp_Email as Cmp_Email,CM.Cmp_Signature as Cmp_Signature,
	case when isnull(Image_file_Path,'') = '' then '' else RIGHT(CM.Image_file_Path,LEN(CM.Image_file_Path)-(CHARINDEX('Cmpimages',CM.Image_file_Path)+9))end as Image_file_Path,
	CM.Cmp_Id as Cmp_Id,EM.Emp_ID as Emp_ID,
	Cmp_Name,Emp_Full_Name,Work_Email,
	--CONVERT(VARCHAR(15), EM.Date_Of_Join, 6)as Date_Of_Join1, 
	Replace(CONVERT(VARCHAR(15),Case When Isnull(EM.GroupJoiningDate,'01-Jan-1900')= '01-Jan-1900' THEN EM.Date_Of_Join Else EM.GroupJoiningDate End, 103),'-','/') as Date_Of_Join1,
	Email_Signature,Email_Attachment,
	case when (isnull(EM.Image_Name,'')<>'' and isnull(EM.Image_Name,'') <> '0.jpg') then EM.Image_Name else  case when Em.Gender = 'F' then 'Emp_Default_Female.png' else 'Emp_default.png' end end as Image_Name 
	,BM.Branch_Name,DM.Dept_Name,DSM.Desig_Name,Mobile_No, 
	Cast(DATEDIFF(yyyy,Case When Isnull(EM.GroupJoiningDate,'01-Jan-1900')= '01-Jan-1900' THEN EM.Date_Of_Join Else EM.GroupJoiningDate End,GETDATE()) AS varchar(50))  as Completed_Year
FROM T0080_EMP_MASTER EM WITH (NOLOCK)
	INNER JOIN T0095_INCREMENT I WITH (NOLOCK) on EM.Increment_ID = I.Increment_ID 
	LEFT JOIN t0030_Branch_Master BM WITH (NOLOCK) on I.Branch_ID = Bm.branch_id 
	LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_Id 
	LEFT JOIN T0040_DESIGNATION_MASTER DSM WITH (NOLOCK) on I.Desig_Id = DSM.Desig_ID 
	LEFT JOIN T0010_COMPANY_MASTER as CM WITH (NOLOCK) on EM.Cmp_ID = CM.cmp_id   
	LEFT OUTER JOIN  T0010_EMAIL_FORMAT_SETTING as EFS WITH (NOLOCK) on CM.CMP_ID=EFS.CMP_ID
	LEFT OUTER JOIN T0040_EMAIL_NOTIFICATION_CONFIG ENC WITH (NOLOCK) ON ENC.CMP_ID = CM.CMP_ID AND  EFS.EMAIL_TYPE = ENC.EMAIL_TYPE_NAME
	INNER JOIN #YearlyData YD ON datediff(year,Case When Isnull(EM.GroupJoiningDate,'01-Jan-1900')= '01-Jan-1900' THEN Date_Of_Join Else EM.GroupJoiningDate End,GETDATE()) = YD.Completed_Year
WHERE 
	  datepart(d,GETDATE())-datepart(d,Case When Isnull(EM.GroupJoiningDate,'01-Jan-1900')= '01-Jan-1900' THEN Date_Of_Join Else EM.GroupJoiningDate End) = 0 
	  AND datepart(M,GETDATE())-datepart(M,Case When Isnull(EM.GroupJoiningDate,'01-Jan-1900')= '01-Jan-1900' THEN Date_Of_Join Else EM.GroupJoiningDate End) = 0 
	  AND isnull(Emp_Left,'N')<>'Y' 
	  AND ENC.EMAIL_NTF_SENT = 1 AND UPPER(EFS.EMAIL_TYPE) = 'WORK ANNIVERSARY'

END




