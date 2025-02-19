


CREATE VIEW	[dbo].[V0090_CURRENT_MANAGER_DETAIL]
AS
SELECT    distinct T0080_EMP_MASTER_1.Alpha_Emp_Code AS [EMPLOYEE_CODE],T0080_EMP_MASTER_1.Emp_Full_Name AS [EMPLOYEE_NAME], 
				   dbo.T0030_BRANCH_MASTER.Branch_Name AS [BRANCH_NAME],CAST(dbo.T0080_EMP_MASTER.Date_Of_Join AS varchar(11)) AS [DATE_OF_JOIN] ,
				   dbo.T0040_DESIGNATION_MASTER.Desig_Name AS [MANAGER_DESIGNATION],
				   CAST(dbo.T0080_EMP_MASTER.Alpha_Emp_Code AS varchar(15)) + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS [MANAGER_NAME], 
				   T0010_COMPANY_MASTER_R.Cmp_Name AS [MANAGER_COMPANY], 
				   QRY_REPORTING.Reporting_Method AS [REPORTING_METHOD], 
                   CAST(QRY_REPORTING.Effect_Date As Varchar(11)) AS [EFFECT_DATE],
                   T0080_EMP_MASTER_1.CMP_ID,T0080_EMP_MASTER_1.EMP_ID,dbo.T0080_EMP_MASTER.Branch_ID AS [BRANCH_ID]
FROM	 (			
				SELECT	R1.EMP_ID, R1.EFFECT_DATE AS EFFECT_DATE,ALPHA_EMP_CODE, T0080_EMP_MASTER.EMP_FULL_NAME,R_EMP_ID,
						R1.Row_ID,R1.Cmp_ID,R1.Reporting_To,Reporting_Method
				FROM	DBO.T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK) INNER JOIN 
					(
						--SELECT		MAX(ROW_ID) AS ROW_ID, R2.EMP_ID
						--FROM		T0090_EMP_REPORTING_DETAIL R2 INNER JOIN 
									--(
										SELECT	MAX(R3.EFFECT_DATE) AS EFFECT_DATE, R3.EMP_ID 
										FROM	T0090_EMP_REPORTING_DETAIL R3 WITH (NOLOCK) 
										WHERE	R3.EFFECT_DATE < GETDATE() 
										GROUP BY R3.EMP_ID
									--)R3 ON R2.EMP_ID=R3.EMP_ID AND R2.EFFECT_DATE=R3.EFFECT_DATE 
						--GROUP BY R2.EMP_ID
					)R2 ON R1.EFFECT_DATE=R2.EFFECT_DATE AND R1.EMP_ID=R2.EMP_ID INNER JOIN 
					T0080_EMP_MASTER WITH (NOLOCK)   ON R1.R_EMP_ID = T0080_EMP_MASTER.EMP_ID
		 ) AS QRY_REPORTING INNER JOIN DBO.T0080_EMP_MASTER WITH (NOLOCK)  ON T0080_EMP_MASTER.EMP_ID = QRY_REPORTING.R_EMP_ID INNER JOIN 
		 dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK)  ON QRY_REPORTING.Emp_ID = T0080_EMP_MASTER_1.Emp_ID INNER JOIN 
		 (
				SELECT        Increment_ID, Emp_ID, Cmp_ID, Branch_ID, Cat_ID, Grd_ID, Dept_ID, Desig_Id
                FROM            dbo.T0095_INCREMENT AS SInc WITH (NOLOCK) 
                WHERE        (Increment_Effective_Date =
                                                             (SELECT        MAX(Increment_Effective_Date) AS For_Date
                                                               FROM            dbo.T0095_INCREMENT AS ssInc WITH (NOLOCK) 
                                                               WHERE        (Emp_ID = SInc.Emp_ID)
                                                               GROUP BY Emp_ID))
                            ) AS Qry ON T0080_EMP_MASTER_1.Emp_ID = Qry.Emp_ID 
				INNER JOIN dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID 
				INNER JOIN dbo.T0010_COMPANY_MASTER WITH (NOLOCK)  ON T0080_EMP_MASTER_1.Cmp_ID = dbo.T0010_COMPANY_MASTER.Cmp_Id 
				INNER JOIN dbo.T0010_COMPANY_MASTER AS T0010_COMPANY_MASTER_R WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Cmp_ID = T0010_COMPANY_MASTER_R.Cmp_Id 
                LEFT OUTER JOIN (
								SELECT	Emp_id,I.Desig_Id,I.Cmp_ID 
								FROM		T0095_INCREMENT I WITH (NOLOCK) 
								WHERE		I.Increment_ID=(	SELECT	MAX(INCREMENT_ID)
																FROM	T0095_INCREMENT I1 WITH (NOLOCK) 
																WHERE	I1.Increment_Effective_Date = (	SELECT	MAX(I2.Increment_Effective_Date)
																										FROM	T0095_INCREMENT I2 WITH (NOLOCK) 
																										WHERE	I2.Emp_ID=I1.Emp_ID AND I2.Cmp_ID=I1.Cmp_ID
																										GROUP BY I2.Emp_ID, I2.Cmp_ID
																									   )
																AND I1.Cmp_ID=I.Cmp_ID AND I1.Emp_ID=I.Emp_ID
																GROUP BY I1.Emp_ID, I1.Cmp_ID
															)													
								) RPT_EMP ON T0080_EMP_MASTER.Cmp_ID=RPT_EMP.Cmp_ID AND dbo.T0080_EMP_MASTER.Emp_ID=RPT_EMP.Emp_ID																																																		
              INNER JOIN dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) ON RPT_EMP.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID AND dbo.T0040_DESIGNATION_MASTER.Cmp_ID = dbo.T0080_EMP_MASTER.Cmp_ID
		
