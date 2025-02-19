---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- exec [dbo].[P_Birthday_Utility]
CREATE PROCEDURE [dbo].[P_Birthday_Utility]
	@date as varchar(max) = ''	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	IF @date = ''
	 SET @date = getdate()

	SELECT	CM.Cmp_Email as Cmp_Email,CM.Cmp_Signature as Cmp_Signature,
			CASE WHEN isnull(Image_file_Path,'') = '' 
				THEN '' 
				ELSE RIGHT(CM.Image_file_Path,LEN(CM.Image_file_Path)-(CHARINDEX('Cmpimages',CM.Image_file_Path)+9))
			END AS Image_file_Path,
			CM.Cmp_Id as Cmp_Id,EM.Emp_ID as Emp_ID,Cmp_Name,Emp_Full_Name,Work_Email,
			CONVERT(VARCHAR(7), case when isnull(Actual_Date_Of_Birth,'') = '' then  Date_Of_Birth else Actual_Date_Of_Birth end , 6)as Date_Of_Birth1,
			Email_Signature,Email_Attachment,
			CASE WHEN (isnull(EM.Image_Name,'')<>'' and isnull(EM.Image_Name,'') <> '0.jpg') 
				THEN EM.Image_Name 
				ELSE  
					CASE WHEN Em.Gender = 'F' 
						THEN 'Emp_Default_Female.png' 
						ELSE 'Emp_default.png' 
					END 
			END AS Image_Name ,BM.Branch_Name,DM.Dept_Name,DSM.Desig_Name,Mobile_No
	FROM T0080_EMP_MASTER EM WITH (NOLOCK)
	--INNER JOIN T0095_INCREMENT I ON EM.INCREMENT_ID = I.INCREMENT_ID 
	INNER JOIN	T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = EM.emp_id   -- Added Max Increment by Hardik 24/06/2020
	INNER JOIN (SELECT	Max(TI.Increment_ID) Increment_Id,TI.Emp_ID 
				FROM	T0095_INCREMENT TI WITH (NOLOCK) 
						INNER JOIN (SELECT	Max(Increment_Effective_Date) AS Increment_Effective_Date,Emp_ID 
									FROM	T0095_INCREMENT WITH (NOLOCK)
									WHERE	Increment_Effective_Date <= GETDATE() 
									GROUP BY Emp_ID) New_Inc ON TI.Emp_ID = New_Inc.Emp_ID AND TI.Increment_Effective_Date=New_Inc.Increment_Effective_Date
				WHERE	TI.Increment_Effective_Date <= GETDATE() 
				GROUP BY TI.Emp_ID)	Qry2 ON Qry2.Emp_ID=I.Emp_ID AND Qry2.Increment_Id=I.Increment_ID

	LEFT JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.BRANCH_ID = BM.BRANCH_ID 
	LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID 
	LEFT JOIN T0040_DESIGNATION_MASTER DSM WITH (NOLOCK) ON I.DESIG_ID = DSM.DESIG_ID 
	LEFT JOIN T0010_COMPANY_MASTER AS CM WITH (NOLOCK) ON EM.CMP_ID = CM.CMP_ID   
	LEFT OUTER JOIN  T0010_EMAIL_FORMAT_SETTING AS EFS WITH (NOLOCK) ON CM.CMP_ID=EFS.CMP_ID
	LEFT OUTER JOIN T0030_CATEGORY_MASTER CAT WITH (NOLOCK) ON I.Cat_ID = CAT.Cat_ID  -- Added by Hardik 24/06/2020 for Umbrella client, if category has tick then only email should go
	LEFT OUTER JOIN T0040_EMAIL_NOTIFICATION_CONFIG ENC WITH (NOLOCK) ON ENC.CMP_ID = CM.CMP_ID AND  EFS.EMAIL_TYPE = ENC.EMAIL_TYPE_NAME
	WHERE 
		1 = (CASE WHEN Actual_Date_Of_Birth is not null and month(Actual_Date_Of_Birth)= month(@date) and day(Actual_Date_Of_Birth) = day(@date) and Actual_Date_Of_Birth <> '1900-01-01 00:00:00.000'
				  THEN 1 
				  WHEN  Date_Of_Birth is not null and month(Date_Of_Birth)=month(@date) and day(Date_Of_Birth) = day(@date) and Actual_Date_Of_Birth is null and Date_Of_Birth <> '1900-01-01 00:00:00.000'
				  THEN 1 
				  ELSE 0 
			  END
			 )
	AND (ISNULL(EMP_LEFT,'N') <> 'Y' OR EM.Emp_Left_Date IS NULL) AND EFS.IS_ACTIVE = 1 
	AND ENC.EMAIL_NTF_SENT = 1 AND UPPER(EFS.EMAIL_TYPE) = 'BIRTH DAY' AND ISNULL(CAT.Chk_Birth,1) = 1  --and em.Cmp_ID=121
END

