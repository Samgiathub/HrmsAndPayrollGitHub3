



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Increment_Utility_Record]
	 @cmp_id			numeric(18,0)
	,@effective_date	datetime
	,@SegmentId			numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	CREATE TABLE #grdTable
	(
		 grd_id NUMERIC(18,0)
		,grd_name varchar(100)
		,segment_id  NUMERIC(18,0)
	)
	
	INSERT INTO #grdTable
	SELECT DISTINCT I.Grd_ID,G.Grd_Name,i.Segment_ID
	FROM T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN
	(
		SELECT T0095_INCREMENT.Emp_ID,Branch_ID,Grd_ID,Segment_ID,Desig_Id,Dept_ID,I1.Increment_ID
		FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
			(
				SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
				FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
					(
						SELECT  MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
						FROM T0095_INCREMENT WITH (NOLOCK)
						WHERE  Cmp_ID = @cmp_id and Increment_Effective_Date <= @effective_date  
						GROUP BY Emp_ID
					)I3 on I3.Emp_ID = T0095_INCREMENT.Emp_ID
				WHERE  Cmp_ID = @cmp_id
				GROUP BY T0095_INCREMENT.Emp_ID
			)I1 ON I1.Emp_ID = T0095_INCREMENT.Emp_ID and I1.Increment_ID = T0095_INCREMENT.Increment_ID
		WHERE Cmp_ID = @cmp_id		
	)I on I.Emp_ID = E.Emp_ID LEFT JOIN
	T0040_GRADE_MASTER G WITH (NOLOCK) on g.Grd_ID = I.Grd_ID
	WHERE E.Cmp_ID = @cmp_id
AND i.Segment_ID is NOT NULL
	
	--SELECT * from #grdTable
	
	IF EXISTS(SELECT 1 FROM T0052_Increment_Utility WITH (NOLOCK) WHERE EffectiveDate = @effective_date and Segment_ID= @SegmentID)
		BEGIN			
			SELECT IU.Segment_ID,IU.EffectiveDate,IU.Amount as Amount,G.Grd_Id,G.Grd_Name
			FROM  T0052_Increment_Utility_BaseAmount IU WITH (NOLOCK) INNER JOIN 
				  #grdTable G on g.segment_id = IU.Segment_ID and G.grd_id = IU.Grd_Id
			WHERE IU.EffectiveDate = @effective_date and IU.Segment_ID = @SegmentId
			
			SELECT 1 as 'Validation'
		END
	ELSE
		BEGIN
			SELECT AU.Segment_ID,AU.EffectiveDate,0 as 'Amount',G.Grd_Id,G.Grd_Name
			FROM  T0050_Appraisal_Utility_Setting AU WITH (NOLOCK) INNER JOIN
				  (
					SELECT MAX(EffectiveDate) EffectiveDate,Segment_ID
					FROM T0050_Appraisal_Utility_Setting WITH (NOLOCK)
					WHERE Segment_ID = @SegmentId and EffectiveDate <= @effective_date
					GROUP BY Segment_ID
				  )AU1 ON AU1.Segment_ID = AU.Segment_ID AND AU1.EffectiveDate = AU.EffectiveDate INNER JOIN
				  T0040_Achievement_Master A WITH (NOLOCK) on A.AchievementId = AU.Achivement_Id INNER JOIN 
				  #grdTable G on g.segment_id = au.Segment_ID
				 --CROSS JOIN #grdTable G
			WHERE AU.Segment_ID = @SegmentId and AU.Percentage = 0 
			
			SELECT 0 as 'Validation'
		END
		
		
		DROP TABLE #grdTable
END

