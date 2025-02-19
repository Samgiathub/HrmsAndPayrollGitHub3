





CREATE VIEW [dbo].[V0120_BOND_APPROVAL]
AS
SELECT				  EM.EMP_FULL_NAME, BM.BOND_NAME, BA.BOND_APR_ID, 
                      BA.CMP_ID, BA.EMP_ID, BA.BOND_ID,BA.BOND_APR_DATE, BA.BOND_APR_CODE, BA.BOND_APR_AMOUNT, 
                      BA.BOND_APR_NO_OF_INSTALLMENT, BA.BOND_APR_INSTALLMENT_AMOUNT,
                      BA.BOND_APR_DEDUCT_FROM_SAL,EM.MOBILE_NO, EM.EMP_FIRST_NAME,EM.EMP_LEFT, 
                      BM.BOND_AMOUNT, BRNM.BRANCH_NAME, 
                      EM.EMP_CODE, BA.DEDUCTION_TYPE,EM.WORK_EMAIL AS OTHER_EMAIL, DM.DEPT_NAME, DESM.DESIG_NAME, 
                      I.GROSS_SALARY, I.CTC, EM.DATE_OF_JOIN, I.BASIC_SALARY, 
                      EM.ALPHA_EMP_CODE, 
                      ISNULL(BA.INSTALLMENT_START_DATE, BA.BOND_APR_DATE) AS INSTALLMENT_START_DATE,
                      BA.BOND_APPROVAL_REMARKS,BA.ATTACHMENT_PATH AS APR_ATTACHMENT_PATH, I.VERTICAL_ID, I.SUBVERTICAL_ID, I.DEPT_ID,
					  VS.VERTICAL_NAME , SVS.SUBVERTICAL_NAME,QRY_REPORTING.EMP_FULL_NAME AS REFERENCE_NAME,BA.Bond_Return_Mode , BA.BOND_RETURN_MONTH,BA.BOND_RETURN_YEAR,
					  BA.Bond_Return_Status , BA.Bond_Return_Date,BRNM.BRANCH_ID
                      
                      
                      
FROM        DBO.T0120_BOND_APPROVAL AS BA WITH (NOLOCK)
			LEFT OUTER JOIN		DBO.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON BA.EMP_ID = EM.EMP_ID
			LEFT OUTER JOIN  (SELECT	I.*
								 FROM		dbo.T0095_INCREMENT AS i  WITH (NOLOCK)
											INNER JOIN		(SELECT     MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
																FROM          dbo.T0095_INCREMENT AS I2 WITH (NOLOCK) INNER JOIN
																						   (SELECT     MAX(Increment_Effective_Date) AS INCREMENT_EFFECTIVE_DATE, Emp_ID
																							 FROM          dbo.T0095_INCREMENT AS I3 WITH (NOLOCK)
																							 WHERE      (Increment_Effective_Date <= GETDATE())
																							 GROUP BY Emp_ID) AS I3 ON I2.Increment_Effective_Date = I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID = I3.Emp_ID
																GROUP BY I2.Emp_ID) AS I2 ON i.Emp_ID = I2.Emp_ID AND i.Increment_ID = I2.Increment_ID 
								) I ON EM.EMP_ID = I.EMP_ID 
			LEFT OUTER JOIN		DBO.T0040_DEPARTMENT_MASTER AS DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID 
			INNER JOIN			DBO.T0040_DESIGNATION_MASTER AS DESM WITH (NOLOCK) ON I.DESIG_ID = DESM.DESIG_ID 
			LEFT OUTER JOIN		DBO.T0040_BOND_MASTER AS BM  WITH (NOLOCK) ON BA.BOND_ID = BM.BOND_ID
			LEFT OUTER JOIN		DBO.T0040_VERTICAL_SEGMENT AS VS WITH (NOLOCK) ON I.VERTICAL_ID = VS.VERTICAL_ID
			LEFT OUTER JOIN		DBO.T0050_SUBVERTICAL AS SVS WITH (NOLOCK) ON I.SUBVERTICAL_ID = SVS.SUBVERTICAL_ID
			LEFT OUTER JOIN		DBO.T0030_BRANCH_MASTER AS BRNM WITH (NOLOCK) ON I.BRANCH_ID = BRNM.BRANCH_ID
			LEFT OUTER JOIN  (
					 
									  SELECT	R1.EMP_ID, R1.FOR_DATE, R1.R_EMP_ID, (EM.ALPHA_EMP_CODE + ' - ' + EM.EMP_FULL_NAME)AS EMP_FULL_NAME,R1.SOURCE_TYPE
									  FROM      dbo.T0090_EMP_REFERENCE_DETAIL AS R1  WITH (NOLOCK)
												INNER JOIN (
															
															SELECT TOP 1 MAX(R2.REFERENCE_ID) AS ROW_ID, R2.R_Emp_ID
															FROM    dbo.T0090_EMP_REFERENCE_DETAIL AS R2 WITH (NOLOCK) 
																	INNER JOIN (
																	
																					SELECT     MAX(FOR_DATE) AS Effect_Date, R_Emp_ID
																					FROM          dbo.T0090_EMP_REFERENCE_DETAIL AS R3 WITH (NOLOCK)
																					WHERE      (FOR_DATE < GETDATE())
																					GROUP BY R_Emp_ID
																					
																				) AS R3_1 ON R2.R_Emp_ID = R3_1.R_Emp_ID AND R2.FOR_DATE = R3_1.Effect_Date
																GROUP BY R2.R_Emp_ID
																
																
															) AS R2_1 ON R1.REFERENCE_ID = R2_1.ROW_ID AND R1.R_Emp_ID = R2_1.R_Emp_ID 
															INNER JOIN dbo.T0080_EMP_MASTER AS Em WITH (NOLOCK) ON R1.R_Emp_ID = Em.Emp_ID and EM.Emp_Left <> 'Y'
															
									) AS Qry_Reporting ON EM.Emp_ID = Qry_Reporting.Emp_ID AND Qry_Reporting.SOURCE_TYPE = 2
			LEFT OUTER JOIN  (SELECT	BID.Installment_Amt , BID.Emp_ID
							  FROM		dbo.T0130_BOND_INSTALLMENT_DETAIL AS BID  WITH (NOLOCK)
										INNER JOIN		(SELECT     MAX(BI2.Installment_ID) AS Installment_ID, BI2.Emp_ID
															FROM          dbo.T0130_BOND_INSTALLMENT_DETAIL AS BI2 WITH (NOLOCK) INNER JOIN
																					   (SELECT     MAX(Effective_Date) AS Effective_Date, Emp_ID
																						FROM          dbo.T0130_BOND_INSTALLMENT_DETAIL AS BI3 WITH (NOLOCK)
																						WHERE      (Effective_Date <= GETDATE())
																						GROUP BY Emp_ID
																						) AS BI3 ON BI2.Effective_Date = BI3.Effective_Date AND BI2.Emp_ID = BI3.Emp_ID
															GROUP BY BI2.Emp_ID
														 ) AS I2 ON BID.Emp_ID = I2.Emp_ID AND BID.Installment_ID = I2.Installment_ID 
								) INS ON INS.Emp_ID = BA.Emp_ID
								
	


