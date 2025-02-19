




CREATE VIEW [dbo].[V0090_EMP_INSURANCE_DETAIL_FAMILY_MEMBER_BACKUP_MEHUL_16032022]
AS
SELECT  dbo.T0090_EMP_INSURANCE_DETAIL.Emp_Ins_Tran_ID,
      dbo.T0090_EMP_INSURANCE_DETAIL.Emp_Id, 
      LEFT(dbo.T0090_EMP_INSURANCE_DETAIL.Emp_Dependent_ID,LEN(dbo.T0090_EMP_INSURANCE_DETAIL.Emp_Dependent_ID) - 1)  AS Emp_Dependent_ID
      ,ISNULL(CASE WHEN LEFT(dbo.T0090_EMP_INSURANCE_DETAIL.Emp_Dependent_ID,1) = '0' THEN 
				( SELECT Emp_Full_Name +' # '+ 'Self'+' # '+ Gender+' # '+ ISNULL(Cast(dbo.F_GET_AGE(Date_Of_Birth,GETDATE(),'N','N') AS VARCHAR(4)),'-') +' # '+ ISNULL(CONVERT(varchar(15),Date_Of_Birth,106),'-') +' # '+'Yes' FROM T0080_EMP_MASTER WHERE Emp_Id = dbo.T0090_EMP_INSURANCE_DETAIL.EMP_ID)
			 + ',' ELSE '' END ,'') +
	 ISNULL(( SELECT STUFF((SELECT		',' + 
		char(10) + B.Name +' # '+ Relationship +' # '+ Gender +' # '+ISNULL(Cast(C_Age AS VARCHAR(4)),'-') +' # '+ ISNULL(CONVERT(varchar(15),Date_Of_Birth,106),'-')+' # '+ CASE WHEN Is_Dependant = 1 THEN 'Yes' ELSE 'No' END
						FROM		T0090_EMP_CHILDRAN_DETAIL B WITH (NOLOCK) INNER JOIN 
						( SELECT	CAST(DATA AS NUMERIC(18,0)) AS Row_ID FROM	dbo.Split(left(dbo.T0090_EMP_INSURANCE_DETAIL.Emp_dependent_Id,len(dbo.T0090_EMP_INSURANCE_DETAIL.Emp_dependent_Id) - 1), '#') --Where	IsNull(data, '0') <> '0'
						) MB ON B.Row_ID= MB.Row_ID 
						WHERE		B.Cmp_ID=dbo.T0090_EMP_INSURANCE_DETAIL.Cmp_ID AND Emp_Dependent_ID is NOT NULL 
						FOR XML PATH('')
					),1,1,'') 
	  ),'') As Emp_Dependent_Name_Detail
FROM         dbo.T0040_INSURANCE_MASTER WITH (NOLOCK)  INNER JOIN
                      dbo.T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK)  ON dbo.T0040_INSURANCE_MASTER.Ins_Tran_ID = dbo.T0090_EMP_INSURANCE_DETAIL.Ins_Tran_ID




