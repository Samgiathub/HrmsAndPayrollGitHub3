
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Work_Anniversary_Utility]
	@date as varchar(max) = ''	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @date = ''
 set @date = getdate()

SELECT CM.Cmp_Email as Cmp_Email,CM.Cmp_Signature as Cmp_Signature,
	case when isnull(Image_file_Path,'') = '' then '' else RIGHT(CM.Image_file_Path,LEN(CM.Image_file_Path)-(CHARINDEX('Cmpimages',CM.Image_file_Path)+9))end as Image_file_Path,
	CM.Cmp_Id as Cmp_Id,EM.Emp_ID as Emp_ID,
	Cmp_Name,Emp_Full_Name,Work_Email,
	--CONVERT(VARCHAR(15), EM.Date_Of_Join, 6)as Date_Of_Join1, 
	Replace(CONVERT(VARCHAR(15),Case When Isnull(EM.GroupJoiningDate,'01-Jan-1900')= '01-Jan-1900' THEN EM.Date_Of_Join Else EM.GroupJoiningDate End, 103),'-','/') as Date_Of_Join1,
	Email_Signature,Email_Attachment,
	case when (isnull(EM.Image_Name,'')<>'' and isnull(EM.Image_Name,'') <> '0.jpg') then EM.Image_Name else  case when Em.Gender = 'F' then 'Emp_Default_Female.png' else 'Emp_default.png' end end as Image_Name 
	,BM.Branch_Name,DM.Dept_Name,DSM.Desig_Name,Mobile_No, 
	Cast(DATEDIFF(yyyy,Case When Isnull(EM.GroupJoiningDate,'01-Jan-1900')= '01-Jan-1900' THEN EM.Date_Of_Join Else EM.GroupJoiningDate End,GETDATE()) AS varchar(50)) +' (yrs)' as Completed_Year
FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
	--INNER JOIN T0095_INCREMENT I on EM.Increment_ID = I.Increment_ID 
INNER JOIN	T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = EM.emp_id   -- Added Max Increment by Hardik 24/06/2020
	INNER JOIN (SELECT	Max(TI.Increment_ID) Increment_Id,TI.Emp_ID 
				FROM	T0095_INCREMENT TI WITH (NOLOCK)
						INNER JOIN (SELECT	Max(Increment_Effective_Date) AS Increment_Effective_Date,Emp_ID 
									FROM	T0095_INCREMENT WITH (NOLOCK)
									WHERE	Increment_Effective_Date <= GETDATE() 
									GROUP BY Emp_ID) New_Inc ON TI.Emp_ID = New_Inc.Emp_ID AND TI.Increment_Effective_Date=New_Inc.Increment_Effective_Date
				WHERE	TI.Increment_Effective_Date <= GETDATE() 
				GROUP BY TI.Emp_ID)	Qry2 ON Qry2.Emp_ID=I.Emp_ID AND Qry2.Increment_Id=I.Increment_ID

	LEFT JOIN t0030_Branch_Master BM WITH (NOLOCK) on I.Branch_ID = Bm.branch_id 
	LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_Id 
	LEFT JOIN T0040_DESIGNATION_MASTER DSM WITH (NOLOCK) on I.Desig_Id = DSM.Desig_ID 
	LEFT JOIN T0010_COMPANY_MASTER as CM WITH (NOLOCK) on EM.Cmp_ID = CM.cmp_id   
	LEFT OUTER JOIN  T0010_EMAIL_FORMAT_SETTING as EFS WITH (NOLOCK) on CM.CMP_ID=EFS.CMP_ID
	LEFT OUTER JOIN T0040_EMAIL_NOTIFICATION_CONFIG ENC WITH (NOLOCK) ON ENC.CMP_ID = CM.CMP_ID AND  EFS.EMAIL_TYPE = ENC.EMAIL_TYPE_NAME
	LEFT OUTER JOIN T0030_CATEGORY_MASTER CAT WITH (NOLOCK) ON I.Cat_ID = CAT.Cat_ID  -- Added by Hardik 24/06/2020 for Umbrella client, if category has tick then only email should go
WHERE MONTH(Case When Isnull(EM.GroupJoiningDate,'01-Jan-1900')= '01-Jan-1900' THEN Date_Of_Join Else EM.GroupJoiningDate End)=MONTH(@date) 
	AND DAY(Case When Isnull(EM.GroupJoiningDate,'01-Jan-1900')= '01-Jan-1900' THEN Date_Of_Join Else EM.GroupJoiningDate End) = DAY(@date) 
	AND isnull(Emp_Left,'N')<>'Y' 
	AND YEAR(Case When Isnull(EM.GroupJoiningDate,'01-Jan-1900')= '01-Jan-1900' THEN Date_Of_Join Else EM.GroupJoiningDate End) <> YEAR(@date)
	AND ENC.EMAIL_NTF_SENT = 1 AND UPPER(EFS.EMAIL_TYPE) = 'WORK ANNIVERSARY' AND ISNULL(CAT.Chk_Birth,1) = 1

END



