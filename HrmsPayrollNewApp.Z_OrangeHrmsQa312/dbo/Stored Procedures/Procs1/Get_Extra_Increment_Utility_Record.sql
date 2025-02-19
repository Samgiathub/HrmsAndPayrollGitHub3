



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Extra_Increment_Utility_Record]
	 @Cmp_Id			numeric(18,0)
	,@Effective_Date	datetime
	,@Eligible			int
	,@Appraisal_From	datetime
	,@Appraisal_To		datetime
	,@ReasonType		numeric(18,0)
	,@Condition			varchar(5000)=''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	
	CREATE TABLE #EmpFinal_Table
	(
		Emp_Id NUMERIC(18,0)
	)
	
	IF @Eligible = 1
		BEGIN
			INSERT INTO #EmpFinal_Table
			SELECT DISTINCT Emp_Id
			FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
			WHERE SA_Startdate>= @Appraisal_From AND SA_Startdate<=@Appraisal_To AND Cmp_ID = @Cmp_Id
		END
	ELSE
		BEGIN
			INSERT INTO #EmpFinal_Table
			SELECT E.Emp_ID
			FROM T0080_EMP_MASTER E  WITH (NOLOCK)
			WHERE E.Cmp_ID = @Cmp_Id AND E.Emp_Left<>'Y' AND E.Date_Of_Join <= @Effective_Date AND
							NOT EXISTS(
										SELECT DISTINCT Emp_Id
										FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
										WHERE SA_Startdate>= @Appraisal_From AND SA_Startdate<=@Appraisal_To AND Cmp_ID = @Cmp_Id
										AND Emp_Id = E.Emp_ID
									  ) 
		END
	
	---SELECT * FROM #EmpFinal_Table
	
	DECLARE @Query as VARCHAR(MAX)
	
	If EXISTS(SELECT 1 FROM T0060_Extra_Increment_Utility WITH (NOLOCK) WHERE [EffectiveDate] = @Effective_Date 
				AND [EligibleType] = @Eligible AND [Res_Id] = @ReasonType)
		BEGIN
		SET	@Query ='SELECT E.Emp_Id,(EM.Alpha_Emp_Code+''-''+EM.Emp_Full_Name)Emp_Full_Name,B.Branch_Name,DG.Desig_Name,D.Dept_Name,G.Grd_Name,EQ.qual_id,isnull(EU.Amount,0)Amount,extra_increment_utility_id
					 FROM  #EmpFinal_Table E LEFT JOIN
						  T0060_Extra_Increment_Utility EU WITH (NOLOCK) ON EU.EMp_Id = E.Emp_Id and
							convert(varchar(15),[EffectiveDate],105) =''' + CONVERT(varchar(15),@Effective_Date,105) + '''
						   AND [EligibleType] =' + cast(@Eligible as VARCHAR)  +' AND [Res_Id] ='+ cast(@ReasonType as varchar) + '
						   AND convert(varchar(15),[Appraisal_From],105) =''' + CONVERT(varchar(15),@Appraisal_From,105) + ''' 
						   AND convert(varchar(15),[Appraisal_To],105) =''' + CONVERT(varchar(15),@Appraisal_To,105) + ''' INNER JOIN
						  T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = e.Emp_Id INNER JOIN
						  T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = e.Emp_Id INNER JOIN
						  (
							SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
							FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
							(
								SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
								FROM T0095_INCREMENT WITH (NOLOCK)
								WHERE Cmp_ID = ' + cast(@Cmp_ID as VARCHAR)+'
								GROUP by Emp_ID
							)I2 ON I2.Emp_ID = T0095_INCREMENT.Emp_ID
							WHERE Cmp_ID = ' + cast(@Cmp_ID as VARCHAR)+'
							GROUP BY T0095_INCREMENT.Emp_ID
						  )I1 ON I1.Emp_ID = I.Emp_ID AND I.Increment_ID = I1.Increment_ID LEFT JOIN
						  T0030_BRANCH_MASTER B WITH (NOLOCK) on I.Branch_ID = b.Branch_ID LEFT JOIN
						  T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = I.Desig_Id LEFT JOIN
						  T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = I.Dept_ID LEFT JOIN
						  T0040_GRADE_MASTER G WITH (NOLOCK) ON G.Grd_ID = I.Grd_ID LEFT JOIN
						  (
							SELECT a.Emp_ID, qual_id = 
								STUFF((SELECT '', '' + cast(qual_id as VARCHAR)
									   FROM T0090_EMP_QUALIFICATION_DETAIL b WITH (NOLOCK)
									   WHERE b.Emp_ID = a.Emp_ID 
									  FOR XML PATH('''')), 1, 2, '''')
							FROM T0090_EMP_QUALIFICATION_DETAIL a WITH (NOLOCK)
							WHERE a.Cmp_ID = ' + cast(@Cmp_ID as VARCHAR)+'
							GROUP BY a.Emp_ID
						  )	EQ ON eq.Emp_ID = E.Emp_ID'
					--WHERE 
				
		END
	ELSE
		BEGIN
			SET	@Query ='SELECT E.Emp_Id,(EM.Alpha_Emp_Code+''-''+EM.Emp_Full_Name)Emp_Full_Name,B.Branch_Name,DG.Desig_Name,D.Dept_Name,G.Grd_Name,EQ.qual_id,0 as Amount,null as extra_increment_utility_id
						FROM  #EmpFinal_Table E  INNER JOIN
							  T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = e.Emp_Id INNER JOIN
							  T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = e.Emp_Id INNER JOIN
							  (
								SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
								FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
								(
									SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
									FROM T0095_INCREMENT WITH (NOLOCK)
									WHERE Cmp_ID =' + cast(@Cmp_ID as VARCHAR)+'
									GROUP by Emp_ID
								)I2 ON I2.Emp_ID = T0095_INCREMENT.Emp_ID
								WHERE Cmp_ID = ' + cast(@Cmp_ID as VARCHAR)+'
								GROUP BY T0095_INCREMENT.Emp_ID
							  )I1 ON I1.Emp_ID = I.Emp_ID AND I.Increment_ID = I1.Increment_ID LEFT JOIN
							  T0030_BRANCH_MASTER B WITH (NOLOCK) on I.Branch_ID = b.Branch_ID LEFT JOIN
							  T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = I.Desig_Id LEFT JOIN
							  T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = I.Dept_ID LEFT JOIN
							  T0040_GRADE_MASTER G WITH (NOLOCK) ON G.Grd_ID = I.Grd_ID LEFT JOIN
							  (
								SELECT a.Emp_ID, qual_id = 
									STUFF((SELECT '', '' + cast(qual_id as VARCHAR)
										   FROM T0090_EMP_QUALIFICATION_DETAIL b WITH (NOLOCK)
										   WHERE b.Emp_ID = a.Emp_ID 
										  FOR XML PATH('''')), 1, 2, '''')
								FROM T0090_EMP_QUALIFICATION_DETAIL a WITH (NOLOCK)
								WHERE a.Cmp_ID = ' + cast(@Cmp_ID as VARCHAR)+'
								GROUP BY a.Emp_ID
							  )	EQ ON eq.Emp_ID = E.Emp_ID'
			--WHERE [EffectiveDate] = @Effective_Date 
			--	AND [EligibleType] = @Eligible AND [Res_Id] = @ReasonType
		END	
				

		
print @Query
	print @Condition
	IF @Condition =''
		BEGIN
			EXEC(@Query + ' Order by EM.Alpha_Emp_Code')	
		END 
	ELSE
		BEGIN
			EXEC(@Query + @Condition + ' Order by EM.Alpha_Emp_Code' )	
		END
	
	DROP TABLE #EmpFinal_Table
END

