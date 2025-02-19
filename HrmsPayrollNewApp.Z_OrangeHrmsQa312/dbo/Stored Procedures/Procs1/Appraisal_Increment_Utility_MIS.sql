


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Appraisal_Increment_Utility_MIS]
	 @Cmp_ID			Numeric(18,0)
	,@BusinessSegment	Numeric(18,0)
	,@UtilityDate		datetime
	,@SearchType		int 	 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	CREATE TABLE #Emp_CTC_Report
	(
		 Emp_Id		    NUMERIC(18,0)
		,Emp_Full_Name	VARCHAR(200)
		,Desig_Id		NUMERIC(18,0)
		,Desig_Name		VARCHAR(100)
		,Dept_Id		NUMERIC(18,0)
		,Dept_Name		VARCHAR(100)
		,Branch_Id		NUMERIC(18,0)
		,Branch_Name	VARCHAR(100)
		,Grd_Id			NUMERIC(18,0)
		,Grd_Name		VARCHAR(100)
		,Segment_Id		NUMERIC(18,0)
		,Segment_Name	VARCHAR(100)
		,Current_CTC    NUMERIC(18,2)
		,Probable_CTC	NUMERIC(18,2)
		,Achivemnet_Id	NUMERIC(18,2)
		,Achivement_Name VARCHAR(100)
		,IncrementAmt	NUMERIC(18,2)
	)
	
	INSERT INTO #Emp_CTC_Report
		(Emp_Id,Emp_Full_Name,Desig_Id,Desig_Name,Dept_Id,Dept_Name,Branch_Id,Branch_Name,
		 Grd_Id,Grd_Name,Segment_Id,Segment_Name,Current_CTC,Probable_CTC,Achivemnet_Id,Achivement_Name,IncrementAmt)
	SELECT  AI.Emp_Id,E.Alpha_Emp_Code +'-'+ E.Emp_Full_Name,I.Desig_Id,DG.Desig_Name,I.Dept_ID,D.Dept_Name,I.Branch_ID,b.Branch_Name,
		   I.Grd_ID,G.Grd_Name,I.Segment_ID,BS.Segment_Name,I.CTC,(I.CTC + IU.Amount),A.Range_AchievementId as AchievementId,A.Range_Level as Achievement_Level,IU.Amount
	FROM   T0050_HRMS_InitiateAppraisal AI WITH (NOLOCK) INNER JOIN
		   (
				SELECT MAX(SA_Startdate)SA_Startdate,Emp_Id
				FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
				WHERE Cmp_ID = @Cmp_ID AND SA_Startdate <= @UtilityDate
				GROUP BY Emp_Id
		   )AI1 ON AI1.Emp_Id = AI.Emp_Id  and AI.SA_Startdate= AI1.SA_Startdate INNER JOIN
		   T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = AI.Emp_Id INNER JOIN
		   T0095_INCREMENT I WITH (NOLOCK) on I.Emp_ID = E.Emp_ID INNER JOIN
		   (
				SELECT MAX(Increment_ID)Increment_ID,  T0095_INCREMENT.Emp_ID
				FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
				(
					SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
					FROM  T0095_INCREMENT WITH (NOLOCK)
					WHERE Cmp_ID = @Cmp_ID AND Increment_Effective_Date <= @UtilityDate
					GROUP by Emp_ID
				)I3 on I3.Emp_ID = T0095_INCREMENT.Emp_ID
				WHERE Cmp_ID = @Cmp_ID
				GROUP BY  T0095_INCREMENT.Emp_ID
		   )I1 ON I1.Increment_ID = I.Increment_ID and I1.Emp_ID = I.Emp_ID LEFT JOIN
		   T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = I.Desig_Id LEFT JOIN
		   T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = I.Dept_ID LEFT JOIN
		   T0030_BRANCH_MASTER B WITH (NOLOCK) ON B.Branch_ID = I.Branch_ID LEFT JOIN
		   T0040_GRADE_MASTER G WITH (NOLOCK) ON G.Grd_ID = I.Grd_ID LEFT JOIN
		   T0040_Business_Segment BS WITH (NOLOCK) ON BS.Segment_ID = I.Segment_ID INNER JOIN
		   T0040_HRMS_RangeMaster A WITH (NOLOCK) on A.Range_ID = AI.Achivement_Id INNER JOIN
		   T0052_Increment_Utility IU WITH (NOLOCK) ON I.Segment_ID = IU.Segment_ID AND I.Grd_ID = IU.Grd_Id and A.Range_AchievementId = IU.Achivement_Id
	WHERE  AI.Cmp_ID = @Cmp_ID and  IU.Segment_ID =@BusinessSegment
			and I.Segment_ID = @BusinessSegment AND IU.EffectiveDate = @UtilityDate
	ORDER by B.Branch_ID
	

	
	IF @SearchType = 1
		BEGIN
			SELECT Branch_Id as ID,Branch_Name as Name,COUNT(1)EligibleEmpCount,SUM(Current_CTC)CurrentCTC,SUM(Probable_CTC)ProbableCTC,SUM(IncrementAmt)IncrementAmount
			FROM  #Emp_CTC_Report
			GROUP BY Branch_Id,Branch_Name
		END
	ELSE IF @SearchType = 2
		BEGIN
			SELECT Desig_Id as ID,Desig_Name as Name,COUNT(1)EligibleEmpCount,SUM(Current_CTC)CurrentCTC,SUM(Probable_CTC)ProbableCTC,SUM(IncrementAmt)IncrementAmount
			FROM  #Emp_CTC_Report
			GROUP BY Desig_Id,Desig_Name
		END
	ELSE IF @SearchType = 3
		BEGIN
			SELECT Dept_Id as ID,Dept_Name as Name,COUNT(1)EligibleEmpCount,SUM(Current_CTC)CurrentCTC,SUM(Probable_CTC)ProbableCTC,SUM(IncrementAmt)IncrementAmount
			FROM  #Emp_CTC_Report
			GROUP BY Dept_Id,Dept_Name
		END
	ELSE IF @SearchType = 4
		BEGIN
			SELECT  Emp_Id,Emp_Full_Name,Dept_Name,Desig_Name,Branch_Name,Segment_Name,Grd_Name,Current_CTC,Probable_CTC,IncrementAmt
			FROM #Emp_CTC_Report
		END

	
	DROP TABLE #Emp_CTC_Report
END

