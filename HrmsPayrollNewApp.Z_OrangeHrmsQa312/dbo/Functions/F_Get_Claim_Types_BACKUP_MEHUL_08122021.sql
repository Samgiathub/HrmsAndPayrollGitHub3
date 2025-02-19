
CREATE FUNCTION [dbo].[F_Get_Claim_Types_BACKUP_MEHUL_08122021]
(
	@Emp_ID		numeric,
	@Cmp_ID		numeric,
	@For_Date	DATETIME
)  
RETURNS @RtnValue table 
(
	Claim_ID numeric,
	Claim_Name nvarchar(500)
) 
AS  
BEGIN 
	
	IF EXISTS(SELECT 1 FROM T0095_EMP_SCHEME ES WITH (NOLOCK)
			  INNER JOIN	(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
					Where Effective_Date<=GETDATE() And Type='Claim' AND Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID
					GROUP BY emp_ID) Qry on      
					ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date And Type='Claim'
			  INNER JOIN T0050_Scheme_Detail SD WITH (NOLOCK) ON ES.Scheme_ID=SD.Scheme_Id AND Leave <> '0')
		BEGIN
			INSERT INTO @RtnValue 
			SELECT DISTINCT CM.Claim_ID,CM.Claim_Name FROM T0040_CLAIM_MASTER CM WITH (NOLOCK)
			WHERE  CM.CMP_ID=@Cmp_ID AND Claim_ID IN
			(SELECT CAST(DATA AS NUMERIC)FROM DBO.Split(STUFF((SELECT '#' + SD.Leave FROM T0095_EMP_SCHEME ES WITH (NOLOCK)
			Inner Join	(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
							Where Effective_Date<=@For_Date And Type='Claim' AND Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID
							GROUP BY emp_ID) Qry on      
							ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date And Type='Claim'
			INNER JOIN T0050_Scheme_Detail SD WITH (NOLOCK) ON ES.Scheme_ID=SD.Scheme_Id 
			FOR XML PATH('')), 1, 1, ''),'#'))
		END
	ELSE
		BEGIN
			INSERT INTO @RtnValue 
			SELECT DISTINCT CM.Claim_ID,CM.Claim_Name FROM T0040_CLAIM_MASTER CM WITH (NOLOCK)
			INNER JOIN T0095_EMP_SCHEME ES WITH (NOLOCK) ON CM.CMP_ID=ES.CMP_ID AND Type='Claim' 
			WHERE  CM.CMP_ID=@Cmp_ID and es.Emp_ID=@Emp_ID			
		END

	Return
END