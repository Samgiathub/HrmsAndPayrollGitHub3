

-- =============================================
-- Author:		<Jimit Soni>
-- Create date: 19-11-2018
-- Description:	 For getting Break Records according to Employee and Department + Branch Wise
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_GET_BREAK_RECORDS]
	@CMP_ID				NUMERIC,
	@EFFECTIVE_DATE		DATETIME,	
	@BRANCH_ID			Numeric,	
	@Dept_Id			Numeric,
	@EMP_ID				Numeric = 0,
	@GRD_ID				Numeric = 0,
	@Desig_Id			Numeric = 0,
	@Type_Id			Numeric = 0,
	@Segment_Id			Numeric = 0,
	@Cat_Id				Numeric = 0,
	@VERTICAL_ID		Numeric = 0,
	@SUBVERTICAL_Id		Numeric = 0,
	@BreakType		tinyint = 0

AS
BEGIN
         
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    
	DECLARE @FROM_DATE		 DATETIME
	DECLARE @TO_DATE		 DATETIME
	
	SET @FROM_DATE = dbo.GET_MONTH_ST_DATE(MONTH(@EFFECTIVE_DATE) , YEAR(@EFFECTIVE_DATE))	
	SET @TO_DATE = dbo.GET_MONTH_END_DATE(MONTH(@EFFECTIVE_DATE) , YEAR(@EFFECTIVE_DATE))
				
	CREATE TABLE #EMP_CONS 
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC    
	)  

	EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@Cat_Id,@GRD_ID,@Type_Id,@Dept_Id,@Desig_Id,@EMP_ID,'',0 ,0 ,@Segment_Id,
								@VERTICAL_ID,@SUBVERTICAL_Id,0,0,0,0,0,0,0
		

		
	If @BreakType = 0
		BEGIN
				
				IF EXISTS(SELECT 1 FROM T0100_Break_Time WITH (NOLOCK) WHERE Branch_ID = (CASE WHEN @Branch_ID = 0 THEN Branch_ID ELSE @Branch_ID END) AND
								Dept_Id = (CASE WHEN @Dept_Id = 0 THEN Dept_Id ELSE @Dept_Id END) AND Effective_date = @EFFECTIVE_DATE)
						BEGIN
								SELECT	0 AS COLUMN1,Branch_Name as COLUMN2, Q.Dept_Name as COLUMN3,										
										ISNULL(LBT.Break_Start_Time,'') as Break_START_TIME,
										ISNULL(LBT.Break_End_Time,'') as Break_END_TIME,1 As BreakType,
										ISNULL(LBT.Break_Duration,'') as DURATION,Bm.Branch_ID AS Branch_Id,Q.Dept_Id AS Dept_Id 
								FROM	T0030_BRANCH_MASTER BM	WITH (NOLOCK)
										CROSS APPLY
										(select DEpt_Id,Dept_Name from T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) WHERE DM.Cmp_Id = BM.Cmp_Id and Dm.Cmp_Id = @CMP_ID )Q LEFT OUTER JOIN
										T0100_Break_Time LBT WITH (NOLOCK) On LBT.Branch_Id = BM.Branch_Id AND  LBT.DEpt_Id = Q.DEpt_Id And
										LBT.Effective_date = (case when LBT.Effective_date <> '' then @EFFECTIVE_DATE else LBT.Effective_date end)
								WHERE	Bm.Branch_ID = (CASE WHEN @Branch_ID = 0 THEN Bm.Branch_ID ELSE @Branch_ID END) AND
										Q.Dept_Id = (CASE WHEN @Dept_Id = 0 THEN Q.Dept_Id ELSE @Dept_Id END) 
										--AND LBT.Effective_date = (case when LBT.Effective_date <> '' then @EFFECTIVE_DATE else LBT.Effective_date end)
						END
				ELSE

					BEGIN
							SELECT	0 AS COLUMN1,Branch_Name as COLUMN2, Q.Dept_Name as COLUMN3,										
									'' as Break_START_TIME,
									'' as Break_END_TIME,1 As BreakType,
									'' as DURATION,Bm.Branch_ID AS Branch_Id,Q.Dept_Id AS Dept_Id 
							FROM	T0030_BRANCH_MASTER BM	WITH (NOLOCK)
									CROSS APPLY
									(select DEpt_Id,Dept_Name from T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) WHERE DM.Cmp_Id = BM.Cmp_Id and Dm.Cmp_Id = @CMP_ID )Q 
							WHERE	Bm.Branch_ID = (CASE WHEN @Branch_ID = 0 THEN Bm.Branch_ID ELSE @Branch_ID END) AND
									Q.Dept_Id = (CASE WHEN @Dept_Id = 0 THEN Q.Dept_Id ELSE @Dept_Id END) 								
					END
				
				
						
		END	
	ELSE IF @BreakType = 1
		BEGIN
				

				IF EXISTS(SELECT 1 FROM T0100_Break_Time LBT WITH (NOLOCK)
						   WHERE	EMP_ID = (CASE WHEN @EMP_ID = 0 THEN EMP_ID ELSE @EMP_ID END) AND 
									Exists (select 1 from #EMP_CONS EC where Ec.EMP_ID = LBT.Emp_Id) AND
									Effective_date = @EFFECTIVE_DATE)
						BEGIN
								SELECT	E.Emp_Id AS COLUMN1,E.Alpha_Emp_Code as COLUMN2,E.Emp_Full_Name as COLUMN3,										
										ISNULL(LBT.Break_Start_Time,'') as Break_START_TIME,
										ISNULL(LBT.Break_End_Time,'') as Break_END_TIME,1 As BreakType,
										ISNULL(LBT.Break_Duration,'') as DURATION,0 AS Branch_Id,0 AS Dept_Id
								FROM	#EMP_CONS EC INNER JOIN 
										T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID=E.Emp_ID LEFT OUTER JOIN										
										T0100_Break_Time LBT WITH (NOLOCK) On LBT.Emp_Id = E.Emp_Id And LBT.Effective_date = (case when LBT.Effective_date <> '' then @EFFECTIVE_DATE else LBT.Effective_date end)
								WHERE	EC.EMP_ID = (CASE WHEN @EMP_ID = 0 THEN EC.EMP_ID ELSE @EMP_ID END) 
										--AND LBT.Effective_date = @EFFECTIVE_DATE
										--AND LBT.Effective_date = (case when LBT.Effective_date <> '' then @EFFECTIVE_DATE else LBT.Effective_date end)
										and E.cmp_Id = @CMP_ID
						END
				ELSE
						BEGIN	

								SELECT	E.Emp_Id AS COLUMN1,E.Alpha_Emp_Code as COLUMN2,E.Emp_Full_Name as COLUMN3,										
										'' as Break_START_TIME,'' as Break_END_TIME,1 As BreakType,'' as DURATION,0 AS Branch_Id,0 AS Dept_Id
								FROM	#EMP_CONS EC INNER JOIN 
										T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID=E.Emp_ID
								WHERE	EC.EMP_ID = (CASE WHEN @EMP_ID = 0 THEN EC.EMP_ID ELSE @EMP_ID END) 										
										and E.cmp_Id = @CMP_ID
						END
			
					
		END
	 
	DROP TABLE #EMP_CONS
	
END



