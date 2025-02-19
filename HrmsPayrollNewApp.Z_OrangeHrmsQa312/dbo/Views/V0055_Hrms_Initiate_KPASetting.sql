

CREATE VIEW [dbo].[V0055_Hrms_Initiate_KPASetting]
AS
SELECT     KS.KPA_InitiateId, KS.Emp_Id, KS.KPA_StartDate, KS.KPA_EndDate, KS.Initiate_Status, 
					  CASE WHEN Initiate_Status = 4 THEN 'Not Submitted' WHEN Initiate_Status = 0 THEN 'Draft' 
                      WHEN (Initiate_Status = 1 and ISNULL(KS.GH_Id,0)>0) THEN 'Approved' 
                      WHEN (Initiate_Status = 1 and isnull(KS.Hod_Id,0)>0 and ISNULL(KS.GH_Id,0)=0) THEN 'Approved By HOD'  
                      WHEN (Initiate_Status = 1 and isnull(KS.Hod_Id,0)=0 and ISNULL(KS.GH_Id,0)=0) THEN 'Approved By Manager' 
                      WHEN Initiate_Status = 2 THEN 'Submitted by Appraisee' WHEN Initiate_Status = 3 THEN 'Sent For Employee Review' WHEN Initiate_Status = 5 THEN 'Approved by Manager' WHEN Initiate_Status =
                       6 THEN 'Sent For Manager Review' WHEN Initiate_Status = 7 THEN 'Approved By HOD' WHEN Initiate_Status = 8 THEN 'Sent For HOD Review' END AS InitiateStatus, 
                      KS.Year, KS.RM_Required, KS.Hod_Id, KS.GH_Id, KS.Emp_ApprovedDate, KS.Rm_ApprovedDate, E.Alpha_Emp_Code + '-' + E.Emp_Full_Name AS Emp_Full_Name, 
                      RE.R_Emp_ID,
                      case when KS.RM_Required=1 then ERE.Alpha_Emp_Code + '-' + ERE.Emp_Full_Name else '' end AS Manager_Name,
                       EHO.Alpha_Emp_Code + '-' + EHO.Emp_Full_Name AS HOD_Name, 
                      EGH.Alpha_Emp_Code + '-' + EGH.Emp_Full_Name AS GH_Name, D.Dept_Name, I.Dept_ID, I.Grd_ID, G.Grd_Name, I.Desig_Id, DG.Desig_Name, KS.Cmp_Id,
                      case when [Period] <> '' then [Period] +'-'+ ISNULL(KS.Review_Type,'Final') else ISNULL(KS.Review_Type,'Final') end Review_Type,ISNULL(Send_to_RM,0)Send_to_RM,
					  E.Emp_Left,Duration_FromMonth,Duration_ToMonth,(ISNULL(Duration_FromMonth,'')+'-'+ISNULL(Duration_ToMonth,'')) [Period],[PERIOD] AS QTR_PERIOD
--New Query Added By Deepali -28042023   start
from T0055_Hrms_Initiate_KPASetting AS KS WITH (NOLOCK) inner join

(select distinct	R.EMP_ID,R.R_EMP_ID 
							FROM	T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK)
									INNER JOIN (SELECT	distinct R1.EMP_ID, R1.ROW_ID  AS ROW_ID 
												FROM	T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)
														INNER JOIN (SELECT	max(R2.EFFECT_DATE )AS EFFECT_DATE, R2.EMP_ID
																	FROM	T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
																	INNER JOIN dbo.T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) 
																	ON R2.Emp_ID = dbo.T0055_Hrms_Initiate_KPASetting.Emp_Id AND 
                                                                    R2.Effect_Date <= dbo.T0055_Hrms_Initiate_KPASetting.KPA_EndDate  
																	GROUP	BY R2.EMP_ID
																	) R2 ON R1.Emp_ID=R2.Emp_ID AND R1.Effect_Date=R2.EFFECT_DATE 
												GROUP BY R1.Emp_ID,R1.ROW_ID) 
												R1 ON R.Emp_ID=R1.Emp_ID AND R.Row_ID=R1.ROW_ID)RE
												ON KS.EMP_ID=RE.EMP_ID

--New Query Added By Deepali -28042023   -End

--Old Query Coomented By Deepali -28042023  - Start

--FROM         dbo.T0055_Hrms_Initiate_KPASetting AS KS WITH (NOLOCK)
--					LEFT OUTER JOIN (
--							select	R.EMP_ID,R.R_EMP_ID 
--							FROM	T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK)
--									INNER JOIN (SELECT	MAX(R1.ROW_ID) AS ROW_ID, R1.EMP_ID
--												FROM	T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)
--														INNER JOIN (SELECT	MAX(R2.EFFECT_DATE) AS EFFECT_DATE, R2.EMP_ID
--																	FROM	T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
--																	INNER JOIN dbo.T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) ON R2.Emp_ID = dbo.T0055_Hrms_Initiate_KPASetting.Emp_Id AND 
--                                                                    R2.Effect_Date <= dbo.T0055_Hrms_Initiate_KPASetting.KPA_EndDate  
--																	GROUP	BY R2.EMP_ID
--																	) R2 ON R1.Emp_ID=R2.Emp_ID AND R1.Effect_Date=R2.EFFECT_DATE 
--												GROUP BY R1.Emp_ID) R1 ON R.Emp_ID=R1.Emp_ID AND R.Row_ID=R1.ROW_ID
--							) RE ON KS.EMP_ID=RE.EMP_ID  
--Old Query Coomented By Deepali -28042023 - End
LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON E.Emp_ID = KS.Emp_Id LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS ERE WITH (NOLOCK) ON ERE.Emp_ID = RE.R_Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS EHO WITH (NOLOCK) ON EHO.Emp_ID = KS.Hod_Id LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS EGH WITH (NOLOCK) ON EGH.Emp_ID = KS.GH_Id INNER JOIN
                      dbo.T0095_INCREMENT AS I WITH (NOLOCK) ON I.Emp_ID = KS.Emp_Id INNER JOIN
                           (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
							FROM	T0095_INCREMENT I2  WITH (NOLOCK)
							INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
									FROM	T0095_INCREMENT I3  WITH (NOLOCK)
									INNER JOIN T0055_Hrms_Initiate_KPASetting KS1 WITH (NOLOCK) ON KS1.Emp_ID = I3.EMp_ID									
									WHERE	I3.Increment_Effective_Date <= KS1.KPA_StartDate
									GROUP BY I3.Emp_ID
							) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID	
					GROUP BY I2.Emp_ID) AS I1 ON I1.Emp_ID = I.Emp_ID AND I1.Increment_ID = I.Increment_ID LEFT OUTER JOIN
                    dbo.T0040_DEPARTMENT_MASTER AS D WITH (NOLOCK) ON D.Dept_Id = I.Dept_ID LEFT OUTER JOIN
                    dbo.T0040_GRADE_MASTER AS G  WITH (NOLOCK) ON G.Grd_ID = I.Grd_ID LEFT OUTER JOIN
                    dbo.T0040_DESIGNATION_MASTER AS DG WITH (NOLOCK) ON DG.Desig_ID = I.Desig_Id



