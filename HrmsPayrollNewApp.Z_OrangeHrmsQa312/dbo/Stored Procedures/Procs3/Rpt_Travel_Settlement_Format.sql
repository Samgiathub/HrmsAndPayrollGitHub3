


CREATE PROCEDURE [DBO].[Rpt_Travel_Settlement_Format]  
	@Cmp_ID		numeric  
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric	
	,@Grade_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@Constraint	varchar(max)
	,@Cat_ID        numeric = 0
	,@is_column		tinyint = 0
	,@Salary_Cycle_id  NUMERIC  = 0
	,@Segment_ID Numeric = 0 
	,@Vertical Numeric = 0 
	,@SubVertical Numeric = 0 
	,@subBranch Numeric = 0 
	,@PBranch_ID Varchar(max) = ''
	,@PVertical_ID Varchar(max) = ''
	,@PSubVertical_ID Varchar(max) = ''
	,@PDept_ID Varchar(max) = ''
	,@FLAG TINYINT =0
AS  

 
 
 Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
   
IF @Branch_ID = 0  
		SET @Branch_ID = NULL
		
	IF @Grade_ID = 0  
		 SET @Grade_ID = NULL  
		 
	IF @Emp_ID = 0  
		SET @Emp_ID = NULL  
		
	IF @Desig_ID = 0  
		SET @Desig_ID = NULL  
		
    IF @Dept_ID = 0  
		SET @Dept_ID = NULL 
		
	IF @Type_ID = 0  
		SET @Type_ID = NULL 	
		
    IF @Cat_ID = 0
        SET @Cat_ID = NULL
        
	If @Salary_Cycle_id = 0
   set @Salary_Cycle_id = null
   
	If @Segment_ID = 0
   set @Segment_ID = null
        
	IF @PBranch_ID = '0' or @PBranch_ID='' 
		set @PBranch_ID = null   	
		
	if @PVertical_ID ='0' or @PVertical_ID = ''	
		set @PVertical_ID = null

	if @PsubVertical_ID ='0' or @PsubVertical_ID = ''
		set @PsubVertical_ID = null
		
	IF @PDept_ID = '0' or @PDept_Id='' 
		set @PDept_ID = NULL	 
		

	if @PBranch_ID is null
	Begin	
		select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER where Cmp_ID=@Cmp_ID 
		set @PBranch_ID = @PBranch_ID + ',0'
	End
	
	if @PVertical_ID is null
	Begin	
		select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment where Cmp_ID=@Cmp_ID 
		
		If @PVertical_ID IS NULL
			set @PVertical_ID = '0';
		else
			set @PVertical_ID = @PVertical_ID + ',0'
			
	End
	if @PsubVertical_ID is null
	Begin	
		select   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical where Cmp_ID=@Cmp_ID 
		If @PsubVertical_ID IS NULL
			set @PsubVertical_ID = '0';
		else
			set @PsubVertical_ID = @PsubVertical_ID + ',0'
	End
	IF @PDept_ID is null
	Begin
		select   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER where Cmp_ID=@Cmp_ID 		
		set @PDept_ID = @PDept_ID + ',0'
		if @PDept_ID is null
			set @PDept_ID = '0';
		else
			set @PDept_ID = @PDept_ID + ',0'
	End
--Added By Jaina 14-10-2015 End
	
   
     
	CREATE table #Emp_Cons 
 (      
	Emp_ID numeric ,     
	Branch_ID numeric,
	Increment_ID numeric
	--Alpha_Emp_Code numeric    
 )     
 EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,0,@Grade_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID ,@EMP_ID ,@CONSTRAINT        
         

	
	IF OBJECT_ID('tempdb..#travel') IS NOT NULL
	BEGIN
		DROP TABLE #travel
	END
	
	CREATE TABLE #TRAVEL
	(
		EMP_ID					NUMERIC(18,0),
		TRAVEL_SETTLEMENT_ID	NUMERIC(18,0),
		INT_EXP_ID				NUMERIC(18,0),
		FOR_DATE				VARCHAR(MAX),
		EXPENSE_TYPE_NAME		VARCHAR(255),
		APPROVED_AMOUNT			NUMERIC(18,0)
		
	)
	
	IF OBJECT_ID('tempdb..#Total_Travel') IS NOT NULL
	BEGIN
		DROP TABLE #Total_Travel
	END
	
	
	CREATE TABLE #TOTAL_TRAVEL
	(
		ROW_NO NUMERIC(18,0),
		EMP_ID NUMERIC(18,0),
		TRAVEL_SETTLEMENT_ID NUMERIC(18,0),
		INT_EXP_ID				NUMERIC(18,0),
		FOR_DATE DATETIME
	)
	
		
;WITH cte AS 
 (
		SELECT		TSA.CMP_ID,TSA.EMP_ID,TSA.APPROVAL_DATE,TSA.ADVANCE_AMOUNT,TSA.EXPANCE_INCURED,TSA.APPROVED_EXPANCE,TSA.AMOUNT_DIFFERNCE,TSA.PAYMENT_TYPE,TSA.TRAVEL_AMT_IN_SALARY,
					TSAE.TRAVEL_SETTLEMENT_ID,TSAE.FOR_DATE,TSAE.AMOUNT,TSAE.APPROVED_AMOUNT,TSAE.INT_EXP_ID,
					TETM.EXPENSE_TYPE_NAME
		FROM		T0150_TRAVEL_SETTLEMENT_APPROVAL TSA
		INNER JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_EXPENSE TSAE ON TSA.CMP_ID=TSAE.CMP_ID AND TSA.TRAVEL_SET_APPLICATION_ID=TSAE.TRAVEL_SETTLEMENT_ID AND TSA.EMP_ID=TSAE.EMP_ID
		INNER JOIN	T0040_EXPENSE_TYPE_MASTER TETM ON TSAE.EXPENSE_TYPE_ID=TETM.EXPENSE_TYPE_ID
		WHERE		TSA.CMP_ID=@CMP_ID AND TSA.APPROVAL_DATE BETWEEN @FROM_DATE AND @TO_DATE AND 
					TSA.EMP_ID IN (SELECT EMP_ID FROM #EMP_CONS) AND TSA.IS_APR=1
)



	INSERT	INTO #TRAVEL
	SELECT	EMP_ID,TRAVEL_SETTLEMENT_ID,INT_EXP_ID,FOR_DATE,EXPENSE_TYPE_NAME,APPROVED_AMOUNT
			FROM CTE 
			ORDER BY FOR_DATE, EXPENSE_TYPE_NAME


	INSERT	INTO #TOTAL_TRAVEL
	SELECT	ROW_NUMBER() OVER( ORDER BY EMP_ID,TRAVEL_SETTLEMENT_ID), EMP_ID,TRAVEL_SETTLEMENT_ID,INT_EXP_ID,FOR_DATE
			FROM #TRAVEL 
			ORDER BY FOR_DATE, EXPENSE_TYPE_NAME 



		DECLARE @CLAIM_NAME VARCHAR(255)
		DECLARE @VAL NVARCHAR(MAX)
		DECLARE @AD_NAME_DYN NVARCHAR(MAX)
		DECLARE @COLUMN NVARCHAR(MAX)
		SET @COLUMN =''
	
		CREATE TABLE #NEW_TEMP
		(		
			FOR_DATE  DATETIME,
			EMP_ID  NUMERIC(18,0),
			LABEL_NAME  NVARCHAR(MAX),
			LABEL_AMOUNT  NUMERIC(18,3)
		)
		
	
	
			DECLARE CLAIM_CURSOR CURSOR FOR
			
			SELECT DISTINCT EXPENSE_TYPE_NAME 
			FROM #TRAVEL
		
			OPEN CLAIM_CURSOR		
			FETCH NEXT FROM CLAIM_CURSOR INTO @CLAIM_NAME
			WHILE @@FETCH_STATUS = 0
				BEGIN
					
					Set @Claim_Name = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@Claim_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					
					Set @val = 'Alter table   #Total_Travel Add ' + REPLACE(@Claim_Name,' ','_') + ' varchar(255) default 0 not null'
					exec (@val)	
					Set @val = ''
					
					
					Set @Column = @Column +  REPLACE(rtrim(ltrim(@Claim_Name)),' ','_') + '#'
					
					fetch next from Claim_Cursor into @Claim_Name
				END
			CLOSE CLAIM_CURSOR	
			DEALLOCATE CLAIM_CURSOR	
		
		
			
			DECLARE @CTC_COLUMNS NVARCHAR(100)
			DECLARE @CTC_AD_FLAG VARCHAR(1)
			DECLARE @ALLOW_AMOUNT NUMERIC(18,2)
			DECLARE @CLAIM_APR_AMOUNT NUMERIC(18,2)
			SET @CLAIM_APR_AMOUNT =0
			
			SET @VAL = 'ALTER TABLE   #TOTAL_TRAVEL ADD TOTAL_AMOUNT VARCHAR(255)'
			EXEC (@VAL)				
					
			DECLARE @CLAIM_APR_ID AS NUMERIC(18,0)	
			
			
			
			DECLARE Claim_Cursor CURSOR FOR
			SELECT DISTINCT INT_EXP_ID 
			FROM #TRAVEL  
			OPEN Claim_Cursor
			fetch next from Claim_Cursor into @Claim_apr_ID
			while @@fetch_status = 0
				Begin
							Declare CRU_COLUMNS CURSOR FOR
							Select data from Split(@Column,'#') where data <> ''
							OPEN CRU_COLUMNS
							fetch next from CRU_COLUMNS into @CTC_COLUMNS
							while @@fetch_status = 0
								Begin					
										begin
												Set @CTC_COLUMNS = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@CTC_COLUMNS)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
																						
												begin 
														
													select @Allow_Amount=isnull(APPROVED_AMOUNT,0) from #travel  
														WHere  Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(EXPENSE_TYPE_NAME)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  = @CTC_COLUMNS 
													      and INT_EXP_ID= @Claim_apr_ID
														
													
													
													Set @val = 	'update    #Total_Travel set ' + @CTC_COLUMNS + ' = ' + @CTC_COLUMNS + ' + ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' where    #Total_Travel.INT_EXP_ID = ' + convert(nvarchar,@Claim_apr_ID)
													
													EXEC (@val)		
													
												end
											
												Set @Allow_Amount = 0
												
										end
										
									fetch next from CRU_COLUMNS into @CTC_COLUMNS
								End
					close CRU_COLUMNS	
					deallocate CRU_COLUMNS		
					
						
							
					UPDATE  #TOTAL_TRAVEL 
					SET		TOTAL_AMOUNT = C.AMOUNT
					FROM	#TOTAL_TRAVEL TC 
					INNER JOIN (
										SELECT INT_EXP_ID, SUM(APPROVED_AMOUNT) AS AMOUNT 
										FROM #TRAVEL
										GROUP BY INT_EXP_ID
								) C ON	TC.INT_EXP_ID =C.INT_EXP_ID
					WHERE TC.INT_EXP_ID=@CLAIM_APR_ID																
						
					fetch next from Claim_Cursor into @Claim_apr_ID
				End
		close Claim_Cursor	
		deallocate Claim_Cursor			 
	
	
	
		set @Column = ' ' + @Column
		Set  @Column = REPLACE(@Column,'#','# ')
		
		set @Column=@Column
		
		
		DECLARE @table_name SYSNAME
        SELECT @table_name = '#Total_Travel'
    	
		declare @query as nvarchar(max)
		set @query =''
		
		drop table my_temp
		
		DECLARE @SQL NVARCHAR(MAX)
				SELECT @SQL = '
				SELECT EMP_ID,FOR_DATE,TRAVEL_SETTLEMENT_ID,EXPENSE_TYPE_NAME,AMOUNT INTO MY_TEMP
				FROM ' + @table_name + ' 
				UNPIVOT (
					Amount FOR EXPENSE_TYPE_NAME IN ( 
						' +  LEFT(replace(@Column,'#',','), LEN(replace(@Column,'#',','))-1)  + '
					) 
			 )  unpiv where Amount <> ''0.00'''
				 
			
			
		  EXEC(@SQL)
		  

		 
		  SELECT		DISTINCT EMP.ALPHA_EMP_CODE,EMP.EMP_ID,EMP.EMP_FULL_NAME,INC.BRANCH_ID 
		  FROM			T0080_EMP_MASTER EMP 
		  INNER JOIN	#EMP_CONS EC ON EMP.EMP_ID = EC.EMP_ID
		  INNER JOIN	#TOTAL_TRAVEL TC ON EC.EMP_ID =TC.EMP_ID 
		  LEFT OUTER JOIN (
										SELECT	EMP_ID, BRANCH_ID FROM T0095_INCREMENT I
										WHERE	Increment_Effective_Date=(SELECT	MAX(Increment_Effective_Date)
																		  FROM		T0095_INCREMENT I1
																		  WHERE		I1.Cmp_ID=I.Cmp_ID AND I1.Emp_ID=I.Emp_ID
																					AND I1.Increment_Effective_Date<= @To_Date
																		  )
												AND I.Cmp_ID=@Cmp_ID																					
							) INC ON EMP.EMP_ID=INC.EMP_ID
		  where EMP.Cmp_ID=@Cmp_ID
		  
		
	
		update my_temp set EXPENSE_TYPE_NAME = ' ' + EXPENSE_TYPE_NAME 
		
	
		
		select * from (
							
		  select    
		  row_number() OVER (PARTITION BY E.Emp_Full_Name ORDER BY E.Emp_Full_Name DESC ) as rank,
		  E.Emp_Full_Name,
		  DT.Dept_Name,  
		  q.amount1,E.Alpha_Emp_Code as Emp_code,E.Emp_First_Name,C.* 
		  ,BM.Branch_Name
		  ,@From_Date as From_Date,@To_Date as To_Date
		  ,E.Date_Of_Birth as DOB
		  ,BM.Branch_ID
		  FROM my_temp C inner join 			  
		   (SELECT Emp_ID,SUM(cast(Amount as numeric(18,2))) as amount1 FROM my_temp 
		     GROUP BY Emp_ID) q ON C.Emp_ID = q.Emp_ID inner join
			dbo.T0080_EMP_MASTER E on C.Emp_ID = E.Emp_ID 
			INNER JOIN #Emp_Cons EC ON e.emp_id = Ec.emp_ID 
			INNER JOIN (SELECT T0095_INCREMENT.Emp_Id, cat_id, Grd_ID, Dept_ID, Desig_Id, Branch_Id, TYPE_ID, Bank_id, Curr_id, Wages_Type
								, Salary_Basis_on, Basic_salary, Gross_salary, Inc_Bank_Ac_No, Emp_OT, Emp_Late_Mark, Emp_Full_PF, Emp_PT, Emp_Fix_Salary
								, Emp_Part_time, Late_Dedu_Type, Emp_Childran, Center_ID
								, SalDate_ID, Segment_ID, Vertical_ID, SubVertical_ID, SubBranch_ID		
							FROM T0095_INCREMENT 
								INNER JOIN (SELECT MAX(Increment_effective_Date) AS For_Date, Emp_ID 
												FROM T0095_INCREMENT  
												WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_Id 
												GROUP BY emp_ID
											) Qry ON T0095_INCREMENT.Emp_ID = Qry.Emp_ID AND Increment_Effective_date = Qry.For_date   
							WHERE cmp_id = @Cmp_Id
						) Inc_Qry ON e.Emp_ID = Inc_Qry.Emp_ID 
			INNER JOIN T0010_COMPANY_MASTER COM ON COM.Cmp_Id = E.Cmp_ID
			INNER JOIN T0040_GRADE_MASTER GM ON Inc_Qry.Grd_Id = GM.Grd_Id
			INNER JOIN T0030_BRANCH_MASTER BM ON Inc_Qry.Branch_ID = BM.Branch_Id
			INNER JOIN T0040_DESIGNATION_MASTER DM ON Inc_Qry.Desig_Id = DM.Desig_Id									
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DT ON Inc_Qry.Dept_Id = DT.Dept_Id) qry		
			
		
CREATE TABLE #EMP_SCHEME
(
	EMP_ID NUMERIC(18,0),	
	S_EMP_ID NUMERIC(18,0),
	EMP_FULL_NAME VARCHAR(100),
	APPROVAL_DATE DATETIME
)

INSERT INTO #EMP_SCHEME
			SELECT DISTINCT EM.EMP_ID,
			CASE WHEN APP_EMP_ID =0 THEN EM.EMP_SUPERIOR ELSE APP_EMP_ID END AS APP_S_EMP_ID,
			ISNULL(EMS.EMP_FULL_NAME,EMSUP.EMP_FULL_NAME) AS EMP_NAME,LA.APPROVAL_DATE
			FROM T0050_SCHEME_DETAIL SD
			INNER JOIN 
(SELECT ES.SCHEME_ID,ES.EMP_ID,ES.TYPE FROM T0095_EMP_SCHEME ES INNER JOIN
					(SELECT MAX(EFFECTIVE_DATE) AS EFFECTIVE_DATE,EMP_ID FROM T0095_EMP_SCHEME
					WHERE EFFECTIVE_DATE <= @TO_DATE AND CMP_ID=@CMP_ID AND TYPE='Claim' 
					AND EMP_ID IN (SELECT EMP_ID FROM #EMP_CONS)
					GROUP BY EMP_ID) NEW_INC
					ON ES.EMP_ID = NEW_INC.EMP_ID AND ES.EFFECTIVE_DATE=NEW_INC.EFFECTIVE_DATE
					WHERE ES.EFFECTIVE_DATE <= @TO_DATE AND CMP_ID=@CMP_ID AND ES.TYPE='Claim'
					AND ES.EMP_ID IN (SELECT EMP_ID FROM #EMP_CONS))
					QRY_ONE
					ON SD.SCHEME_ID=QRY_ONE.SCHEME_ID
					INNER JOIN T0080_EMP_MASTER EM ON EM.EMP_ID=QRY_ONE.EMP_ID
					INNER JOIN #EMP_CONS EC ON EC.EMP_ID=EM.EMP_ID
					
					INNER JOIN T0120_CLAIM_APPROVAL CA ON CA.EMP_ID=EM.EMP_ID
					inner JOIN T0115_CLAIM_LEVEL_APPROVAL LA ON LA.Emp_ID=EM.Emp_ID --LA.CLAIM_APP_ID=CA.CLAIM_APP_ID
					and SD.Rpt_Level=LA.Rpt_Level --and 
					--LA.Emp_ID=CA.Emp_ID AND 
					--LA.S_EMP_ID=EMSUP.EMP_ID
					left JOIN T0080_EMP_MASTER EMSUP ON EMSUP.EMP_ID=EM.EMP_SUPERIOR
					and LA.S_Emp_ID=EMSUP.Emp_ID
					left JOIN T0080_EMP_MASTER EMS ON EMS.EMP_ID=SD.APP_EMP_ID
					where La.Approval_Date >=@From_Date and La.Approval_Date<=@To_Date and LA.Cmp_ID=@Cmp_ID
					--order by sd.Scheme_Detail_Id asc
					
					
	
SELECT distinct EM.ALPHA_EMP_CODE,ES.*,BM.BRANCH_NAME,DM.DEPT_NAME,DSG.DESIG_NAME,BM.Branch_ID FROM #EMP_SCHEME ES
INNER JOIN (SELECT T0095_INCREMENT.EMP_ID, CAT_ID, GRD_ID, DEPT_ID, DESIG_ID, BRANCH_ID, TYPE_ID, BANK_ID, CURR_ID, WAGES_TYPE
								, SALARY_BASIS_ON, BASIC_SALARY, GROSS_SALARY, INC_BANK_AC_NO, EMP_OT, EMP_LATE_MARK, EMP_FULL_PF, EMP_PT, EMP_FIX_SALARY
								, EMP_PART_TIME, LATE_DEDU_TYPE, EMP_CHILDRAN, CENTER_ID
								, SALDATE_ID, SEGMENT_ID, VERTICAL_ID, SUBVERTICAL_ID, SUBBRANCH_ID		
							FROM T0095_INCREMENT 
								INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS FOR_DATE, EMP_ID 
												FROM T0095_INCREMENT  
												WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE --AND CMP_ID = @CMP_ID 
												GROUP BY EMP_ID
											) QRY ON T0095_INCREMENT.EMP_ID = QRY.EMP_ID AND INCREMENT_EFFECTIVE_DATE = QRY.FOR_DATE   
							--WHERE CMP_ID = @CMP_ID
						) INC_QRY ON ES.S_EMP_ID = INC_QRY.EMP_ID 
						INNER JOIN T0080_EMP_MASTER EM ON EM.EMP_ID=ES.S_EMP_ID
						LEFT JOIN T0030_BRANCH_MASTER BM ON BM.BRANCH_ID=INC_QRY.BRANCH_ID
						LEFT JOIN T0040_DEPARTMENT_MASTER DM ON DM.DEPT_ID=INC_QRY.DEPT_ID
						LEFT JOIN T0040_DESIGNATION_MASTER DSG ON DSG.DESIG_ID=INC_QRY.DESIG_ID
						

IF(@FLAG=1)
	BEGIN
	
	
		SELECT	EM.EMP_FULL_NAME,EM.EMP_ID,EM.ALPHA_EMP_CODE,CLD.TRAVEL_SETTLEMENT_ID,
		CLD.TRAVEL_APPROVAL_ID,CLD.FOR_DATE,CL.APPROVAL_DATE,ISNULL(CLD.APPROVED_AMOUNT,0) AS APPROVAL_AMOUNT,
		TETM.EXPENSE_TYPE_NAME,CMP.CMP_NAME,
		CMP.CMP_ADDRESS,CMP.CMP_LOGO,BM.BRANCH_NAME,DM.DEPT_NAME,DSM.DESIG_NAME,ISNULL(VS.VERTICAL_NAME,'') AS VERTICAL_NAME,
		ISNULL(BS.SEGMENT_NAME,'') AS SEGMENT_NAME,ISNULL(VS.VERTICAL_NAME,'') AS VERTICAL_NAME,ISNULL(SV.SUBVERTICAL_NAME,'') AS SUBVERTICAL_NAME,
		ISNULL(SB.SUBBRANCH_NAME,'') AS SUBBRANCH_NAME,ISNULL(GM.GRD_NAME,'') AS GRADE_NAME,
		CASE WHEN CL.IS_APR=1 THEN 'APPROVED' ELSE 'REJECTED' END AS TRAVEL_STATUS
FROM	T0150_Travel_Settlement_Approval_Expense CLD 
		INNER JOIN T0150_Travel_Settlement_Approval CL ON CL.CMP_ID=CLD.CMP_ID AND CL.TRAVEL_SET_APPLICATION_ID=CLD.TRAVEL_SETTLEMENT_ID AND CL.EMP_ID=CLD.EMP_ID
		INNER JOIN #Emp_Cons EC ON EC.Emp_ID=CL.Emp_ID
		INNER JOIN T0080_EMP_MASTER EM ON EM.EMP_ID=EC.EMP_ID
		INNER JOIN T0095_INCREMENT INC ON INC.Increment_ID=EC.Increment_ID		
		INNER JOIN	T0040_EXPENSE_TYPE_MASTER TETM ON CLD.EXPENSE_TYPE_ID=TETM.EXPENSE_TYPE_ID AND CLD.CMP_ID=TETM.CMP_ID
		INNER JOIN T0010_COMPANY_MASTER CMP ON CMP.CMP_ID=CL.CMP_ID
		LEFT JOIN T0040_DEPARTMENT_MASTER DM ON DM.DEPT_ID=INC.DEPT_ID
		LEFT JOIN T0040_DESIGNATION_MASTER DSM ON DSM.DESIG_ID=INC.DESIG_ID
		LEFT JOIN T0030_BRANCH_MASTER BM ON BM.BRANCH_ID=INC.BRANCH_ID
		LEFT JOIN T0040_GRADE_MASTER GM ON GM.GRD_ID=INC.GRD_ID
		LEFT JOIN T0040_BUSINESS_SEGMENT BS ON BS.SEGMENT_ID=INC.SEGMENT_ID
		LEFT JOIN T0040_VERTICAL_SEGMENT VS ON VS.VERTICAL_ID=INC.VERTICAL_ID
		LEFT JOIN T0050_SUBVERTICAL SV ON SV.SUBVERTICAL_ID=INC.SUBVERTICAL_ID
		LEFT JOIN T0050_SUBBRANCH SB ON SB.SUBBRANCH_ID=INC.SUBBRANCH_ID	
		LEFT JOIN T0040_CURRENCY_MASTER CMT ON  CLD.CURR_ID=CMT.CURR_ID 
		WHERE CL.APPROVAL_DATE>=@FROM_DATE  AND CL.APPROVAL_DATE<=@TO_DATE
		and CL.Cmp_ID=@Cmp_ID

	END						

DROP TABLE #EMP_SCHEME			
			

Return




