-- =============================================
-- Author:		<Mehul>
-- Create date: <02/06/2023>
-- Description:	<This sp was created to bind GRADE, DESIGNATION, BRANCH etc for claim>
-- =============================================
--EXEC P0040_BIND_FIELDS_FOR_CLAIM @CMP_ID=203, @CLAIM_ID=130, @FLAG='BRANCH'

CREATE PROCEDURE [dbo].[P0040_BIND_FIELDS_FOR_CLAIM] 
		@CMP_ID NUMERIC(18,0)
		,@CLAIM_ID NUMERIC(18,0)
		,@FLAG VARCHAR(10) = ''
AS
BEGIN

-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
		IF @FLAG = 'BRANCH'
		BEGIN

					CREATE TABLE #BRANCH_TEMP(
						Branch_ID NUMERIC
						,Branch_Name VARCHAR(500)
						,Max_Limit_Km NUMERIC
						,Rate_Per_Km NUMERIC
						,UNIT_ID NUMERIC
						,MaxUnit NUMERIC
						,JoiningDays NUMERIC
						,MinKm NUMERIC
					)
	
					
					INSERT INTO #BRANCH_TEMP
					Select CM.Branch_ID As Branch_ID , Branch_Name, CM.Max_Limit_Km, CM.Rate_Per_Km, CM.UnitId, isnull(CM.Max_Unit, 0) As MaxUnit,
					isnull(After_Joining_Days, 0) As JoiningDays, isnull(Min_KM, 0) As MinKm 
					FROM dbo.T0041_Claim_Maxlimit_Design CM 
					INNER JOIN T0030_BRANCH_MASTER DM On CM.Branch_ID = DM.Branch_ID 
					Where Cmp_ID = @CMP_ID And Claim_ID = @CLAIM_ID
					
					
					IF EXISTS(	SELECT 1 FROM T0030_BRANCH_MASTER 
					WHERE Branch_ID NOT IN (SELECT Branch_ID FROM #BRANCH_TEMP) AND Cmp_ID = @CMP_ID)

					BEGIN
								
								INSERT INTO #BRANCH_TEMP
								SELECT Branch_ID , Branch_Name, 0 As Max_Limit_Km , 0 As Rate_Per_Km,0 As UNIT_ID, 0 As MaxUnit, 0 As JoiningDays, 0 as MinKm
								FROM T0030_BRANCH_MASTER 
								WHERE Branch_ID NOT IN (SELECT Branch_ID FROM #BRANCH_TEMP) AND Cmp_ID = @CMP_ID

					END

					SELECT * FROM #BRANCH_TEMP

					DROP TABLE #BRANCH_TEMP

		END

		ELSE IF @FLAG = 'GRADE'
		BEGIN
					
					CREATE TABLE #GRADE_TEMP(
						Grd_ID NUMERIC
						,Grd_Name  VARCHAR(500)
						,Max_Limit_Km NUMERIC
						,Rate_Per_Km NUMERIC
						,UNIT_ID NUMERIC
						,MaxUnit NUMERIC
						,JoiningDays NUMERIC
						,MinKm NUMERIC
					)

					INSERT INTO #GRADE_TEMP
					SELECT CM.Grade_ID as Grd_ID ,Grd_Name,CM.Max_Limit_Km,CM.Rate_Per_Km,CM.UnitId,isnull(CM.Max_Unit,0) as MaxUnit,
					isnull(After_Joining_Days,0) as JoiningDays,isnull(Min_KM,0) as MinKm 
					FROM dbo.T0041_Claim_Maxlimit_Design CM 
					INNER JOIN T0040_GRADE_MASTER DM ON CM.Grade_ID = DM.Grd_ID 
					Where Cmp_ID = @CMP_ID And Claim_ID = @CLAIM_ID

					
					IF EXISTS(	SELECT 1 FROM T0040_GRADE_MASTER 
					WHERE Grd_ID NOT IN (SELECT Grd_ID FROM #GRADE_TEMP) AND Cmp_ID = @CMP_ID)

					BEGIN
								
								INSERT INTO #GRADE_TEMP
								SELECT Grd_ID , Grd_Name , 0 AS Max_Limit_Km , 0 AS Rate_Per_Km ,0 As UNIT_ID,0 as MaxUnit,0 as JoiningDays,0 as MinKm
								FROM T0040_GRADE_MASTER 
								WHERE Grd_ID NOT IN (SELECT Grd_ID FROM #GRADE_TEMP) AND Cmp_ID = @CMP_ID

					END

					SELECT * FROM #GRADE_TEMP

					DROP TABLE #GRADE_TEMP
		END

		ELSE
		BEGIN		
					
					CREATE TABLE #DESIGNATION_TEMP(
						Desig_ID NUMERIC
						,Desig_Name VARCHAR(500)
						,Max_Limit_Km NUMERIC
						,Rate_Per_Km NUMERIC
						,UNIT_ID NUMERIC
						,MaxUnit NUMERIC
						,JoiningDays NUMERIC
						,MinKm NUMERIC
					)

					INSERT INTO #DESIGNATION_TEMP
					SELECT CM.Desig_ID,Desig_Name,CM.Max_Limit_Km,CM.Rate_Per_Km,CM.UnitId,isnull(CM.Max_Unit,0) as MaxUnit,
					isnull(After_Joining_Days,0) as JoiningDays,isnull(Min_KM,0) as MinKm 
					FROM dbo.T0041_Claim_Maxlimit_Design CM 
					INNER JOIN T0040_DESIGNATION_MASTER DM ON CM.Desig_ID = DM.Desig_ID 
					Where Cmp_ID = @CMP_ID And Claim_ID = @CLAIM_ID

					IF EXISTS(	SELECT 1 FROM T0040_DESIGNATION_MASTER 
					WHERE Desig_ID NOT IN (SELECT DESIG_ID FROM #DESIGNATION_TEMP) AND Cmp_ID = @CMP_ID)

					BEGIN
								
								INSERT INTO #DESIGNATION_TEMP
								SELECT Desig_ID , Desig_Name , 0 AS Max_Limit_Km , 0 AS Rate_Per_Km ,0 As UNIT_ID,0 as MaxUnit,0 as JoiningDays,0 as MinKm
								FROM T0040_DESIGNATION_MASTER 
								WHERE Desig_ID NOT IN (SELECT Desig_ID FROM #DESIGNATION_TEMP) AND Cmp_ID = @CMP_ID

					END

					SELECT * FROM #DESIGNATION_TEMP

					DROP TABLE #DESIGNATION_TEMP
				
		END

END	
