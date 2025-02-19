CREATE FUNCTION [dbo].[fn_getActualStrength] 
(	
	@CMP_ID Numeric, 
	@BRANCH_ID NUMERIC,
	@DEPT_ID NUMERIC,
	@DESIG_ID NUMERIC
)
RETURNS @STRENGTH TABLE(TOTAL_EMPLOYEE INT,ACTUAL_STREGTH INT)
AS
BEGIN

	Declare @Employee_Strength_Setting tinyint
	select @Employee_Strength_Setting = setting_value from T0040_SETTING where cmp_id = @Cmp_ID and setting_name = 'Restrict Entry based on Employee Strength Master'	
	IF @Employee_Strength_Setting = 1
		Begin
			IF @Branch_ID > 0 AND @DESIG_ID > 0 AND @DEPT_ID > 0
			Begin
				Declare @Branch_Desig_Wise_Count Numeric(18,0)
				Set @Branch_Desig_Wise_Count = 0

				Declare @Branch_Desig_Strength_Count Numeric(18,0)
				Set @Branch_Desig_Strength_Count = 0

				Select 
					@Branch_Desig_Wise_Count = Count(1)
				FROM
					(SELECT	
						I1.EMP_ID, I1.DESIG_ID, I1.BRANCH_ID,I1.Dept_ID
					FROM	T0095_INCREMENT I1 
					INNER JOIN T0080_EMP_MASTER E ON E.EMP_ID = I1.EMP_ID AND (E.Emp_Left_Date IS NULL OR ISNULL(Emp_Left,'N') = 'N')
					INNER JOIN (
								SELECT	
									MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
								FROM	T0095_INCREMENT I2 
								INNER JOIN (
												SELECT	
													MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
												FROM	T0095_INCREMENT I3 
												WHERE	I3.Increment_Effective_Date <= Getdate() AND Cmp_ID = @Cmp_ID
												GROUP BY I3.Emp_ID
											) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
								WHERE	I2.Cmp_ID = @Cmp_Id 
								GROUP BY I2.Emp_ID
							) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
					WHERE	I1.Cmp_ID=@Cmp_Id	
					AND NOT EXISTS(SELECT 1 FROM T0200_EMP_EXITAPPLICATION EE WHERE EE.EMP_ID = I1.EMP_ID AND EE.status NOT IN('R','LR'))									
					) I
				WHERE I.Branch_ID = @Branch_ID AND I.Desig_Id = @DESIG_ID  and i.dept_id=@DEPT_ID

				Select @Branch_Desig_Strength_Count = ESM.Strength
					From T0040_Employee_Strength_Master ESM
					INNER JOIN(
								Select Max(Effective_Date) as For_Date,Branch_ID,Desig_Id ,Dept_Id
									From T0040_Employee_Strength_Master 
								Where Branch_Id <> 0 and Desig_Id <> 0 AND Cmp_Id=@CMP_ID
								Group By Branch_ID,Desig_Id,Dept_Id
					) as Qry 
				ON ESM.Effective_Date = Qry.For_Date AND ESM.Branch_Id = Qry.Branch_Id AND ESM.Desig_Id = Qry.Desig_Id
				WHERE ESM.Cmp_Id=@CMP_ID AND ESM.Branch_Id=@BRANCH_ID AND ESM.Desig_Id=@DESIG_ID AND ESM.DEPT_ID=@DEPT_ID
	
			INSERT INTO @STRENGTH(TOTAL_EMPLOYEE,ACTUAL_STREGTH)
			VALUES(@Branch_Desig_Wise_Count,@Branch_Desig_Strength_Count)
		END
	END
		
	RETURN 
END

