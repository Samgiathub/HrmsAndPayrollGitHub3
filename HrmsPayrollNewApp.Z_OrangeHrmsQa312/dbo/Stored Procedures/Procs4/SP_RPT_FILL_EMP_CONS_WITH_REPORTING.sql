


CREATE PROCEDURE [dbo].[SP_RPT_FILL_EMP_CONS_WITH_REPORTING]          
  @Cmp_ID			numeric          
 ,@From_Date		datetime          
 ,@To_Date			datetime          
 ,@Branch_ID		varchar(MAX)     
 ,@Cat_ID			varchar(MAX)            
 ,@Grd_ID			varchar(MAX)        
 ,@Type_ID			varchar(MAX)          
 ,@Dept_ID			varchar(MAX)            
 ,@Desig_ID			varchar(MAX)            
 ,@Emp_ID			numeric          
 ,@constraint		VARCHAR(MAX)          
 ,@Sal_Type			numeric = 0      
 ,@Salary_Cycle_id	numeric = 0  
 ,@Segment_Id		varchar(MAX) = 0
 ,@Vertical_Id		varchar(MAX) = 0
 ,@SubVertical_Id	varchar(MAX) = 0
 ,@SubBranch_Id		varchar(MAX) = 0
 ,@New_Join_emp		Numeric = 0 
 ,@Left_Emp			Numeric = 0
 ,@SalScyle_Flag	Numeric = 0	 
 ,@PBranch_ID		varchar(MAX) = 0
 ,@With_Ctc			Numeric = 0
 ,@Type				numeric = 0
 ,@Scheme_Id		Numeric
 ,@Rpt_Level		Numeric
 ,@SCHEME_TYPE		Varchar(50) = ''
AS 

	SET NOCOUNT ON 
  	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 
	DECLARE @HAS_TABLE AS BIT = 0
	
	--select @SCHEME_TYPE
	--------- IF Emp Cons is available then truncate ------------
	--IF Object_ID('tempdb..#EMP_CONS') is not null
	--	BEGIN			
					
	--		CREATE TABLE #EMP_CONS_BACK 
	--		(      
	--			EMP_ID NUMERIC ,     
	--			BRANCH_ID NUMERIC,
	--			INCREMENT_ID NUMERIC
	--		)	
					
	--		INSERT 
	--		INTO	#EMP_CONS_BACK
	--		SELECT	*,0,0
	--		FROM	#EMP_CONS				
					
	--		TRUNCATE TABLE #EMP_CONS				
	--		SET @HAS_TABLE = 1												
	--	END
	---------------------ended---------------------------
			
	-------------Call Multi cons Sp--------
	--		--If @HAS_TABLE = 0
	--		--	BEGIN	
	--				CREATE TABLE #EMP_CONS 
	--					(      
	--						EMP_ID NUMERIC ,     
	--						BRANCH_ID NUMERIC ,
	--						INCREMENT_ID NUMERIC
	--					)				
	--			--END
			
				
	--EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,
	--										@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,'','','','',0,0,0,'',0,0   
	------------------Ended--------------------
	
	
	
	----------------------Create Reporting Manager Table----------------
			
		
	--CREATE TABLE #EMP_CONS_SUP 
	--(      
	--	EMP_ID		NUMERIC ,     
	--	BRANCH_ID	NUMERIC,
	--	INCREMENT_ID NUMERIC,
	--	R_EMP_ID	NUMERIC DEFAULT 0,
	--	Scheme_ID	NUMERIC
	--)	
			
	--INSERT INTO	#EMP_CONS_SUP(EMP_ID)		
	--SELECT		EMP_ID							
	--FROM		#EMP_CONS
			
			
			
	-----------------------------ended---------------------------------------		
			
	-----------------If exists emp cons then get data back from back up table------	
	--		IF (@HAS_TABLE = 1)
	--			BEGIN
	--					TRUNCATE TABLE #EMP_CONS
			
	--					INSERT	
	--					INTO	#EMP_CONS
	--					SELECT	* 
	--					FROM	#EMP_CONS_BACK	
	--			END
	--select @EMP_ID,@SCHEME_TYPE
	--------------------------------ended----------------------------
		
	---------------------Reporting table operations----------------------
	
		--INSERT INTO #EMP_CONS_SUP(EMP_ID,R_EMP_ID,Scheme_ID)    
		INSERT INTO #EMP_CONS_RM(EMP_ID,R_EMP_ID,Scheme_ID,Rpt_Level)
		SELECT 	ERD.EMP_ID,ERD.R_EMP_ID, Scheme_ID, 1
		FROM	T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
					(
						SELECT	 MAX(EFFECT_DATE) AS EFFECT_DATE,EMP_ID
						FROM	 T0090_EMP_REPORTING_DETAIL  WITH (NOLOCK) 
						WHERE	 EFFECT_DATE <= GETDATE() 
						GROUP BY EMP_ID
					) RQRY ON  ERD.EMP_ID = RQRY.EMP_ID AND ERD.EFFECT_DATE = RQRY.EFFECT_DATE 
			left OUTER JOIN 			
				(Select ES.Emp_Id,ES.Scheme_Id From T0095_EMP_SCHEME ES  WITH (NOLOCK)  INNER JOIN			
					(
						SELECT	 MAX(EFFECTIVE_DATE) AS FOR_DATE, EMP_ID
						FROM	 T0095_EMP_SCHEME WITH (NOLOCK) 
						WHERE	 EFFECTIVE_DATE <= GETDATE() AND [TYPE] = @SCHEME_TYPE								
						GROUP BY EMP_ID
					) QRY ON  ES.EMP_ID = QRY.EMP_ID AND ES.EFFECTIVE_DATE = QRY.FOR_DATE --AND SCHEME_ID = @SCHEME_ID 
							  AND TYPE = @SCHEME_TYPE)ES ON ES.EMP_ID = ERD.EMP_ID
		WHERE ERD.R_EMP_ID = @EMP_ID --AND ES.SCHEME_ID = @SCHEME_ID  
		

		--select * from #EMP_CONS_RM
		--INSERT INTO #EMP_CONS_SUP(EMP_ID,R_EMP_ID,Scheme_ID)  
			
		
		INSERT INTO #EMP_CONS_RM(EMP_ID,R_EMP_ID,Scheme_ID,Rpt_Level)    
		SELECT	ERD.EMP_ID,ERD.R_EMP_ID, ES.Scheme_ID, 2		--ERD.R_EMP_ID
		FROM	T0090_EMP_REPORTING_DETAIL ERD  WITH (NOLOCK) INNER JOIN 
					(
						SELECT	 MAX(EFFECT_DATE) AS EFFECT_DATE,EMP_ID
						FROM	 T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
						WHERE	 EFFECT_DATE <= GETDATE()
						GROUP BY EMP_ID
					) RQRY ON  ERD.EMP_ID = RQRY.EMP_ID AND ERD.EFFECT_DATE = RQRY.EFFECT_DATE 
			INNER JOIN #EMP_CONS_RM SUP ON ERD.R_Emp_ID=SUP.EMP_ID
			left OUTER JOIN 			
				(Select ES.Emp_Id,ES.Scheme_Id From T0095_EMP_SCHEME ES  WITH (NOLOCK)  INNER JOIN			
					(
						SELECT	 MAX(EFFECTIVE_DATE) AS FOR_DATE, EMP_ID
						FROM	 T0095_EMP_SCHEME WITH (NOLOCK) 
						WHERE	 EFFECTIVE_DATE <= GETDATE() AND [TYPE] = @SCHEME_TYPE								
						GROUP BY EMP_ID
					) QRY ON  ES.EMP_ID = QRY.EMP_ID AND ES.EFFECTIVE_DATE = QRY.FOR_DATE --AND SCHEME_ID = @SCHEME_ID 
							  AND TYPE = @SCHEME_TYPE)ES ON ES.EMP_ID = ERD.EMP_ID
		where  SUP.Emp_ID <> @EMP_ID
		
		--select * from #EMP_CONS_RM where Rpt_Level = 2 and emp_Id = @EMP_ID
	
		--select * from #EMP_CONS_RM
		--DELETE 
		--FROM	#EMP_CONS_SUP 
		--WHERE	EMP_ID NOT IN (
		--						SELECT	ERD.EMP_ID 
		--						FROM	T0090_EMP_REPORTING_DETAIL ERD INNER JOIN						 
		--									( 
		--										  SELECT	MAX(EFFECT_DATE) AS EFFECT_DATE,ERD1.EMP_ID 
		--										  FROM		T0090_EMP_REPORTING_DETAIL ERD1 INNER JOIN 
		--													#EMP_CONS_SUP EC1 ON EC1.EMP_ID = ERD1.EMP_ID 
		--										  WHERE		EFFECT_DATE	<= GETDATE() 
		--										  GROUP BY	ERD1.EMP_ID
		--									) RQRY ON  ERD.EMP_ID = RQRY.EMP_ID AND ERD.EFFECT_DATE = RQRY.EFFECT_DATE INNER JOIN--AND R_EMP_ID = @EMP_ID_CUR 
		--								#EMP_CONS_SUP EC ON EC.EMP_ID = RQRY.EMP_ID 
		--						)
			
			
			
					--;WITH R(R_EMP_ID, EMP_ID,PARENT, R_LEVEL,BRANCH_ID,INCREMENT_ID,Scheme_ID) AS
					--(
					--	SELECT	R_EMP_ID, EMP_ID, CAST(0 AS NUMERIC) PARENT , CAST(1 AS NUMERIC) AS R_LEVEL,EC.BRANCH_ID,EC.INCREMENT_ID,Scheme_ID
					--	FROM	#EMP_CONS_SUP EC
					--	WHERE   R_EMP_ID = @EMP_ID
					--	UNION ALL
					--	SELECT	EC1.R_EMP_ID, EC1.EMP_ID, R.R_EMP_ID, CAST((R_LEVEL + 1) AS NUMERIC) AS R_LEVEL,EC1.BRANCH_ID,EC1.INCREMENT_ID,EC1.Scheme_ID
					--	FROM	#EMP_CONS_SUP EC1 INNER JOIN 
					--			R ON EC1.R_EMP_ID=R.EMP_ID			
					--)					
					--INSERT INTO #EMP_CONS_RM
					--SELECT EMP_ID,BRANCH_ID,INCREMENT_ID,R_EMP_ID,Scheme_ID FROM R 
					--WHERE R_LEVEL <= @RPT_LEVEL AND Scheme_ID=@Scheme_Id
					--Option	(MAXRECURSION 0)
		

		DELETE #EMP_CONS_RM Where Isnull(Scheme_Id,0) <> @Scheme_Id
		
		---------------------------------------ended--------------------------------------------
	
		
	--exec SP_RPT_FILL_EMP_CONS_WITH_REPORTING @Cmp_ID=149,@From_Date='2017-01-01 00:00:00',@To_Date='2017-01-31 00:00:00',@Branch_ID=0,
	--@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID= 14838,@Constraint='',@Sal_Type = 0 ,@Salary_Cycle_id	= 0
	-- ,@Segment_Id = 0,@Vertical_Id	= 0,@SubVertical_Id = 0,@SubBranch_Id	= 0,@New_Join_emp = 0,@Left_Emp = 0
	-- ,@SalScyle_Flag = 0 ,@PBranch_ID = 0,@With_Ctc	= 1,@Type = 0 ,@Scheme_Id = 332 ,@Rpt_Level	= 2 ,@SCHEME_TYPE = 'Loan'

	--------------------------------------------------------------------------------------------------------------------------------

