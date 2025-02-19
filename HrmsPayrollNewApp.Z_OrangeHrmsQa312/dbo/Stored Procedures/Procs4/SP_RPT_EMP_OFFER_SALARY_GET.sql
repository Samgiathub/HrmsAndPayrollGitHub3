
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_RPT_EMP_OFFER_SALARY_GET]	
	 @CMP_ID		NUMERIC
	,@FROM_DATE		DATETIME
	,@TO_DATE		DATETIME 
	,@BRANCH_ID		NUMERIC   = 0
	,@CAT_ID		NUMERIC  = 0
	,@GRD_ID		NUMERIC = 0
	,@TYPE_ID		NUMERIC  = 0
	,@DEPT_ID		NUMERIC  = 0
	,@DESIG_ID		NUMERIC = 0
	,@EMP_ID		NUMERIC  = 0
	,@CONSTRAINT	VARCHAR(MAX) = ''
	,@LETTER		VARCHAR(30)= 'Offer'
    ,@PBRANCH_ID VARCHAR(200) = '0'
    ,@Show_Hidden_Allowance  bit = 0   --Added by Jaina 24-12-2016
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
 set @Show_Hidden_Allowance = 0
 
 DECLARE @YEAR_END_DATE AS DATETIME  
 DECLARE @USER_TYPE VARCHAR(30)  
 IF @BRANCH_ID = 0  
	SET @BRANCH_ID = NULL   
 IF @GRD_ID = 0  
	SET @GRD_ID = NULL  
 IF @EMP_ID = 0  
	SET @EMP_ID = NULL  
 IF @DESIG_ID = 0  
	SET @DESIG_ID = NULL  
 IF @DEPT_ID = 0  
	SET @DEPT_ID = NULL 
		   
CREATE TABLE #EMP_CONS 
 (      
	EMP_ID NUMERIC ,     
	BRANCH_ID NUMERIC,
	INCREMENT_ID NUMERIC
 )     
	 
EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0,0,0,0,0,0,3,0,0,0
	
CREATE NONCLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);
	
 --Declare @Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into @Emp_Cons(Emp_ID)
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
	--		if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
	--	   Begin
	--		Insert Into @Emp_Cons
               
	--			select I.Emp_Id from dbo.T0095_INCREMENT I inner join 
	--					( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_INCREMENT	-- Ankit 09092014 for Same Date Increment
	--					where Increment_Effective_date <= @To_Date
	--					and Cmp_ID = @Cmp_ID
	--					group by emp_ID  ) Qry on
	--					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	 Inner join
	--					dbo.T0080_EMP_MASTER E on i.emp_ID = E.Emp_ID
	--				Where E.CMP_ID = @Cmp_ID 
	--				--and i.BRANCH_ID = isnull(@BRANCH_ID ,i.BRANCH_ID)
	--				and i.Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))
	--				and i.Grd_ID = isnull(@Grd_ID ,i.Grd_ID)
	--				and isnull(i.Dept_ID,0) = isnull(@Dept_ID ,isnull(i.Dept_ID,0))			
	--				and Isnull(i.Desig_ID,0) = isnull(@Desig_ID ,Isnull(i.Desig_ID,0))			
	--				and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0))
	--				and Date_Of_Join <= @To_Date and I.emp_id in(
	--					select e.Emp_Id from
	--					(select e.emp_id, e.cmp_id, Date_Of_Join, isnull(Emp_left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--					where cmp_id = @Cmp_ID   and  
	--					(( @From_Date  >= Date_Of_Join  and  @From_Date <= Emp_left_date ) 
	--					or ( @to_Date  >= Date_Of_Join  and @To_Date <= Emp_left_date )
	--					or Emp_left_date is null and @To_Date >= Date_Of_Join)
	--					or @To_Date >= Emp_left_date  and  @From_Date <= Emp_left_date )  
	--	   End
	--	 else
	--	   Begin
	--	     Insert Into @Emp_Cons
               
	--			select I.Emp_Id from dbo.T0095_INCREMENT I inner join	
	--					( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_INCREMENT	-- Ankit 09092014 for Same Date Increment
	--					where Increment_Effective_date <= @To_Date
	--					and Cmp_ID = @Cmp_ID
	--					group by emp_ID  ) Qry on
	--					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	 Inner join
	--					dbo.T0080_EMP_MASTER E on i.emp_ID = E.Emp_ID
	--				Where E.CMP_ID = @Cmp_ID 
	--				and i.BRANCH_ID = isnull(@BRANCH_ID ,i.BRANCH_ID)
	--				and i.Grd_ID = isnull(@Grd_ID ,i.Grd_ID)
	--				and isnull(i.Dept_ID,0) = isnull(@Dept_ID ,isnull(i.Dept_ID,0))			
	--				and Isnull(i.Desig_ID,0) = isnull(@Desig_ID ,Isnull(i.Desig_ID,0))			
	--				and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0))
	--				and Date_Of_Join <= @To_Date and I.emp_id in(
	--					select e.Emp_Id from
	--					(select e.emp_id, e.cmp_id, Date_Of_Join, isnull(Emp_left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--					where cmp_id = @Cmp_ID   and  
	--					(( @From_Date  >= Date_Of_Join  and  @From_Date <= Emp_left_date ) 
	--					or ( @to_Date  >= Date_Of_Join  and @To_Date <= Emp_left_date )
	--					or Emp_left_date is null and @To_Date >= Date_Of_Join)
	--					or @To_Date >= Emp_left_date  and  @From_Date <= Emp_left_date ) 
	--	   End  
			
	--	end
---------------------  
	
CREATE TABLE #CTCMAST
(
	
	TRAN_ID		NUMERIC IDENTITY(1,1), 	
	CMP_ID		NUMERIC,
	BRANCH_ID	NUMERIC,
	INCREMENT_ID NUMERIC,
	EMP_ID		NUMERIC,
	DEF_ID		NUMERIC,
	LABEL_HEAD	VARCHAR(100),
	MONTHLY_AMT	NUMERIC(18,2),
	YEARLY_AMT	NUMERIC(18,2),
	AD_ID		NUMERIC,
	AD_FLAG		CHAR(1),
	AD_DEF_ID	NUMERIC,
	Allowance_Type	CHAR(1) DEFAULT ''  --added jimit 04032016
)
	
CREATE NONCLUSTERED INDEX IX_CTCMAST ON #CTCMAST
(
 TRAN_ID,CMP_ID,BRANCH_ID,INCREMENT_ID,EMP_ID,DEF_ID
)
	----------------------------------------------------------------

DECLARE @COLUMNS NVARCHAR(2000)
DECLARE @CTC_CMP_ID NUMERIC(18,0)
DECLARE @CTC_EMP_ID NUMERIC(18,0)
DECLARE @CTC_BASIC NUMERIC(18,2)
DECLARE @AD_NAME_DYN NVARCHAR(100)
DECLARE @VAL NVARCHAR(500)
DECLARE @Allowance_Type	char(1)

SET @COLUMNS = '#'
	DECLARE ALLOW_DEDU_CURSOR CURSOR FOR
	SELECT AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND AD_PART_OF_CTC = 1 AND AD_NOT_EFFECT_SALARY = 0 AND AD_FLAG = 'I' ORDER BY AD_LEVEL
	OPEN ALLOW_DEDU_CURSOR
			FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN
			WHILE @@FETCH_STATUS = 0
				BEGIN									
					SET @AD_NAME_DYN = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					SET @COLUMNS = @COLUMNS +  REPLACE(RTRIM(LTRIM(@AD_NAME_DYN)),' ','_') + '#'
					FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN
				END
	CLOSE ALLOW_DEDU_CURSOR	
	DEALLOCATE ALLOW_DEDU_CURSOR
	
	----------------------------------------------------------------
				
	SET @COLUMNS = @COLUMNS +  'Gross_Salary#'
	
	----------------------------------------------------------------
	
	DECLARE ALLOW_DEDU_CURSOR CURSOR FOR
		SELECT AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND AD_PART_OF_CTC = 1 AND AD_NOT_EFFECT_SALARY = 1 AND AD_FLAG = 'I'
				AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0 AND Hide_In_Reports = 1  THEN 0 ELSE 1 END) = 1 --Added by Jaina 24-12-2016
		ORDER BY AD_LEVEL
	OPEN ALLOW_DEDU_CURSOR
			FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN
			WHILE @@FETCH_STATUS = 0
				BEGIN									
					SET @AD_NAME_DYN = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					SET @COLUMNS = @COLUMNS +  REPLACE(RTRIM(LTRIM(@AD_NAME_DYN)),' ','_') + '#'
					FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN
				END
	CLOSE ALLOW_DEDU_CURSOR	
	DEALLOCATE ALLOW_DEDU_CURSOR
	
	----------------------------------------------------------------
	
	SET @COLUMNS = @COLUMNS +  'CTC#'
	
	----------------------------------------------------------------
	
	DECLARE ALLOW_DEDU_CURSOR CURSOR FOR
		SELECT AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND AD_NOT_EFFECT_SALARY = 0 AND AD_FLAG = 'D' ORDER BY AD_LEVEL
	OPEN ALLOW_DEDU_CURSOR
			FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN
			WHILE @@FETCH_STATUS = 0
				BEGIN									
					SET @AD_NAME_DYN = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')															
					SET @COLUMNS = @COLUMNS +  REPLACE(RTRIM(LTRIM(@AD_NAME_DYN)),' ','_') + '#'
					FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN
				END
	CLOSE ALLOW_DEDU_CURSOR	
	DEALLOCATE ALLOW_DEDU_CURSOR
	
	----------------------------------------------------------------
	
	SET @COLUMNS = @COLUMNS +  'PT#'
	SET @COLUMNS = @COLUMNS +  'Total_Deduction#'
	SET @COLUMNS = @COLUMNS +  'Net_Take_Home#'
	
	----------------------------------------------------------------
	
				
	SET @CTC_CMP_ID = @CMP_ID
	DECLARE @CUR_BRANCH_ID NUMERIC(18,0)
	DECLARE @CUR_INCREMENT_ID NUMERIC(18,0)
	SET @CUR_BRANCH_ID = 0
	SET @CUR_INCREMENT_ID = 0
	DECLARE @CTC_DOJ DATETIME
	DECLARE @CTC_NEW_DOJ DATETIME
	DECLARE @CTC_NEW_DOJ2 DATETIME
	DECLARE @CTC_PRV_MON_DOJ NUMERIC
	--DECLARE @CTC_TOT_YEAR NUMERIC
	DECLARE @CTC_TOT_MON NUMERIC
	--DECLARE @CTC_CUR_MON_DAY NUMERIC
	DECLARE @CTC_COLUMNS NVARCHAR(100)
	DECLARE @CTC_GROSS NUMERIC(18,2)
	DECLARE @TOTAL_EAR NUMERIC(18,2)
	DECLARE @TOTAL_DED NUMERIC(18,2)
	DECLARE @CTC_AD_FLAG VARCHAR(1)
	DECLARE @CTC_PT NUMERIC(18,2)
	--DECLARE @INC_ID  NUMERIC
	DECLARE @ALLOW_AMOUNT NUMERIC(18,2)
	DECLARE @NUMTMPCAL NUMERIC(18,2)
	
	DECLARE CTC_UPDATE CURSOR FOR
		SELECT EC.EMP_ID,EC.BRANCH_ID,EC.INCREMENT_ID,EM.DATE_OF_JOIN,IE.BASIC_SALARY FROM #EMP_CONS EC 
		INNER JOIN T0095_INCREMENT IE WITH (NOLOCK) ON EC.INCREMENT_ID = IE.INCREMENT_ID
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID = EC.EMP_ID
	OPEN CTC_UPDATE
	FETCH NEXT FROM CTC_UPDATE INTO @CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@CTC_DOJ,@CTC_BASIC
	WHILE @@FETCH_STATUS = 0
		BEGIN	
		
			DECLARE @COUNT NUMERIC
			SET @COUNT = 1
			-------------------------------------------------------------------------------------------------
			-- Annually Salry will be calulated till current date from date of Joining or Starting of year --
			-------------------------------------------------------------------------------------------------	
			--select @CTC_DOJ = Date_Of_Join from T0080_EMP_MASTER where Cmp_ID = @CTC_CMP_ID and Emp_ID = @CTC_EMP_ID
			
			--Added By Jimit 14082018 as case at WCl consider Increment Id without tranafer and deputation 
			SELECT	@CUR_INCREMENT_ID = I.INCREMENT_ID 
			FROM	T0095_INCREMENT IE WITH (NOLOCK)
					INNER JOIN (
									SELECT	MAX(I2.INCREMENT_ID) AS INCREMENT_ID,I2.EMP_ID 
									FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN 
											T0080_EMP_MASTER E WITH (NOLOCK) ON I2.EMP_ID=E.EMP_ID	
											INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
														FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.EMP_ID=E3.EMP_ID	
														WHERE	I3.INCREMENT_EFFECTIVE_DATE <= @TO_DATE AND I3.CMP_ID = @CMP_ID AND 
																I3.INCREMENT_TYPE NOT IN ('TRANSFER','DEPUTATION') AND 
																E3.Emp_ID = @CTC_EMP_ID
														GROUP BY I3.EMP_ID  
														) I3 ON I2.INCREMENT_EFFECTIVE_DATE=I3.INCREMENT_EFFECTIVE_DATE AND 
														I2.EMP_ID=I3.EMP_ID 
									WHERE I2.INCREMENT_TYPE NOT IN ('TRANSFER','DEPUTATION') AND E.Emp_ID = @CTC_EMP_ID																																			
									GROUP BY I2.EMP_ID
						) I ON IE.EMP_ID = I.EMP_ID AND IE.INCREMENT_ID=I.INCREMENT_ID
			---ENDED
			
			
			IF YEAR(@CTC_DOJ) < YEAR(GETDATE()) -1 
				BEGIN					
					SET @CTC_NEW_DOJ = CONVERT(DATETIME,'01-APR-' + CONVERT(NVARCHAR,YEAR(GETDATE()) - 1))
				END
			ELSE IF YEAR(@CTC_DOJ) = YEAR(GETDATE()) -1 AND MONTH(@CTC_DOJ) < 4
				BEGIN
					SET @CTC_NEW_DOJ = CONVERT(DATETIME,'01-APR-' + CONVERT(NVARCHAR,YEAR(GETDATE()) - 1))
				END
			ELSE
				BEGIN	
					SET @CTC_NEW_DOJ = CONVERT(DATETIME,DBO.GET_MONTH_ST_DATE(MONTH(@CTC_DOJ),YEAR(@CTC_DOJ)))
				END
			IF MONTH(GETDATE()) = 3
				BEGIN	
					SET @CTC_NEW_DOJ2 = CONVERT(DATETIME,'31-MAR-'  + CONVERT(NVARCHAR,YEAR(GETDATE())))
				END
			ELSE IF MONTH(GETDATE()) < 4
				BEGIN	
					SET @CTC_NEW_DOJ2 = CONVERT(DATETIME,'31-MAR-'  + CONVERT(NVARCHAR,YEAR(GETDATE())))
				END
			ELSE
				BEGIN
					SET @CTC_NEW_DOJ = CONVERT(DATETIME,'01-APR-' + CONVERT(NVARCHAR,YEAR(GETDATE())))
					SET @CTC_NEW_DOJ2 = CONVERT(DATETIME,'31-MAR-'  + CONVERT(NVARCHAR,YEAR(GETDATE()) + 1))
				END
			--select @CTC_NEW_DOJ,@CTC_NEW_DOJ2
			SET @CTC_TOT_MON = DATEDIFF(mm,@CTC_NEW_DOJ,@CTC_NEW_DOJ2) + 1
			
			--select @CTC_TOT_MON
			
			IF @CTC_TOT_MON > 12
				BEGIN	
					SET @CTC_TOT_MON  = 12
				END
			
			----IF MONTH(GETDATE()) > 3
			----	Begin
			----		IF YEAR(@CTC_DOJ) < YEAR(GETDATE())
			----			begin
			----				SET @CTC_NEW_DOJ = CONVERT(datetime,'01-Apr-' + Convert(nvarchar,YEAR(GETDATE())))
			----			end						
			----		else
			----			begin
			----				IF MONTH(@CTC_DOJ) < 4 
			----					begin
			----						SET @CTC_NEW_DOJ = CONVERT(datetime,'01-Apr-' + Convert(nvarchar,YEAR(GETDATE())))
			----					end
			----				else
			----					begin
			----						SET @CTC_NEW_DOJ = @CTC_DOJ
			----					end
								
			----			end
			----	end
			----else
			----	begin
			----		IF YEAR(@CTC_DOJ) < YEAR(GETDATE())
			----			begin
			----					IF MONTH(@CTC_DOJ) > 3 
			----						begin
			----							SET @CTC_NEW_DOJ = CONVERT(datetime,'01-Apr-' + Convert(nvarchar,(YEAR(GETDATE()) - 1)))
			----						end									
			----					else
			----						begin
			----							SET @CTC_NEW_DOJ = @CTC_DOJ
			----						end
			----			end						
			----		else
			----			begin
			----				SET @CTC_NEW_DOJ = @CTC_DOJ
			----			end
			----	end
				
				
				
			----IF DAY(@CTC_NEW_DOJ) = 1
			----	begin
			----		Set @CTC_PRV_MON_DOJ = 0
			----	end
			----else
			----	begin
			----		Set @CTC_PRV_MON_DOJ =  DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ))) - DAY(@CTC_NEW_DOJ) + 1
			----	end
				
			----	select dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)),@CTC_NEW_DOJ
			
			----CREATE table #Days
			----(
			----	Id		numeric(18,0),
			----	Data	numeric(18,0)
			----)
			
			----Declare @gAgeVal nvarchar(15)
			----set @gAgeVal = dbo.F_GET_AGE (dateadd(dd,@CTC_PRV_MON_DOJ + 1,@CTC_NEW_DOJ) ,getdate(),'Y','Y')
			
			
			
			----Insert into #Days
			----select id,cast(data  as numeric) as data from dbo.Split(@gAgeVal,'.')
			
			------select id,cast(data  as numeric) as data from dbo.Split(dbo.F_GET_AGE (dateadd(dd,@CTC_PRV_MON_DOJ + 1,@CTC_NEW_DOJ) ,getdate(),'Y','Y'),'.')
					
			----Select @CTC_TOT_YEAR=data from #Days where id = 1
			----Select @CTC_TOT_MON=data from #Days where id = 2 
			----Select @CTC_CUR_MON_DAY=data from #Days where id = 3
			
			
			
			--set @CTC_TOT_MON = @CTC_TOT_MON + (12 - MONTH(getdate())) + 4
			--set @CTC_CUR_MON_DAY = 0
						
			--Print @CTC_DOJ
			--Print @CTC_NEW_DOJ
			
			--Print @CTC_PRV_MON_DOJ
			--Print dateadd(dd,@CTC_PRV_MON_DOJ + 1,@CTC_NEW_DOJ)
			
			--print @CTC_TOT_YEAR
			--Print @CTC_TOT_MON
			--Print @CTC_CUR_MON_DAY		
			
			--Drop table #Days		
			
			--------------------------------------------------------------------------------------
						
			
			
			--set @numTmpCal = 0
			--Set @CTC_PT = 0
			--Set @CTC_GROSS = 0
			--Set @Total_Ear = 0
			--Set @Total_Ded = 0
			
			SET @CTC_COLUMNS = ''
			SET @CTC_GROSS = 0
			SET @TOTAL_EAR = 0
			SET @TOTAL_DED = 0
			SET @CTC_AD_FLAG = ''
			SET @CTC_PT = 0
			SET @NUMTMPCAL = 0
			SET @ALLOW_AMOUNT = 0
			--------------------------------------------------------------------------------------
			
			--Select @CTC_BASIC= isnull(Basic_Salary,0) from T0080_EMP_MASTER where Emp_ID = @CTC_EMP_ID and Cmp_ID = @Cmp_ID
			
			--select @CTC_BASIC=Basic_Salary  from T0095_INCREMENT where CMP_ID = @Cmp_Id and EMP_ID = @CTC_EMP_ID and Increment_Effective_Date <= @To_Date
			--select @CTC_BASIC=Basic_Salary  from T0095_INCREMENT where CMP_ID = @Cmp_Id and EMP_ID = @CTC_EMP_ID 
			--and Increment_ID = (select max(Increment_ID) as Increment_ID from T0095_INCREMENT where  Increment_Effective_Date <= @To_Date and CMP_ID = @Cmp_Id and EMP_ID = @CTC_EMP_ID)	-- Ankit 09092014 for Same Date Increment
			----if @CTC_TOT_YEAR = 0
			--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
		--	Set @numTmpCal = (@CTC_BASIC/(DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ))))) * @CTC_PRV_MON_DOJ								
			SET @NUMTMPCAL = @NUMTMPCAL + (@CTC_BASIC * @CTC_TOT_MON)
		--	Set @numTmpCal = @numTmpCal + ((@CTC_BASIC/(DaY(dbo.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))))) * @CTC_CUR_MON_DAY)
			INSERT INTO #CTCMAST (CMP_ID,EMP_ID,Branch_ID,Increment_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,Allowance_Type)
				VALUES
			(@CTC_CMP_ID,@CTC_EMP_ID,@Cur_Branch_ID,@Cur_Increment_ID,@COUNT,'Basic Salary',@CTC_BASIC,@numTmpCal,NULL,'I',NULL,'A')
			
			SET @COUNT = @COUNT + 1
			
					
			DECLARE CRU_COLUMNS CURSOR FOR
				SELECT DATA FROM SPLIT(@COLUMNS,'#') WHERE DATA <> ''
			OPEN CRU_COLUMNS
					FETCH NEXT FROM CRU_COLUMNS INTO @CTC_COLUMNS
					WHILE @@FETCH_STATUS = 0
						BEGIN					
								--------------------------------------------
								
								--SELECT @INC_ID=MAX(INCREMENT_ID) FROM T0095_INCREMENT WHERE CMP_ID = @CTC_CMP_ID AND EMP_ID = @CTC_EMP_ID
								-- AND INCREMENT_EFFECTIVE_DATE <= @TO_DATE
								IF @CUR_INCREMENT_ID > 0
								BEGIN
										SET @CTC_COLUMNS = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@CTC_COLUMNS)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
										SET @NUMTMPCAL = 0
										
										IF @CTC_COLUMNS = 'Gross_Salary'
											BEGIN													
												SET @CTC_GROSS =ISNULL(@TOTAL_EAR,0) + ISNULL(@CTC_BASIC,0)
												
												--added jimit 04032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER  WITH (NOLOCK)
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
												
												
												IF @CTC_GROSS > 0
													BEGIN
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--Set @numTmpCal = (@CTC_GROSS/(DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ))))) * @CTC_PRV_MON_DOJ
														SET @NUMTMPCAL = @NUMTMPCAL + (@CTC_GROSS * @CTC_TOT_MON)
													--	Set @numTmpCal = @numTmpCal + ((@CTC_GROSS/(DaY(dbo.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))))) * @CTC_CUR_MON_DAY)
														INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID)
															VALUES
														(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@COUNT,REPLACE(@CTC_COLUMNS,'_',' '),@CTC_GROSS,(@NUMTMPCAL),NULL,'I',NULL)
													
														SET @COUNT = @COUNT + 1
													END
												
											END
										ELSE IF	@CTC_COLUMNS = 'CTC'
											BEGIN
												SET @NUMTMPCAL =  ISNULL(@TOTAL_EAR,0) + ISNULL(@CTC_BASIC,0)
												IF @NUMTMPCAL > 0
													BEGIN			
														
													--added jimit 04032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK) 
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
														
														DECLARE @NUMTEMPCAL2 NUMERIC(18,2)
														SET @NUMTEMPCAL2 = 0
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--Set @numTempCal2 = (@numTmpCal/(DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ))))) * @CTC_PRV_MON_DOJ
														SET @NUMTEMPCAL2 = @NUMTEMPCAL2 + (@NUMTMPCAL * @CTC_TOT_MON)
														--Set @numTempCal2 = @numTempCal2 + ((@numTmpCal/(DaY(dbo.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))))) * @CTC_CUR_MON_DAY)
														INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID)
															VALUES
														(@CTC_CMP_ID,@CTC_EMP_ID,@Cur_Branch_ID,@CUR_INCREMENT_ID,@COUNT, @CTC_COLUMNS,@NUMTMPCAL,@NUMTEMPCAL2,NULL,'I',NULL)
														SET @COUNT = @COUNT + 1
													END		
											END
										ELSE IF @CTC_COLUMNS = 'PT'	
											BEGIN
												SELECT @CTC_PT=EMP_PT_AMOUNT FROM T0095_INCREMENT WITH (NOLOCK) WHERE INCREMENT_ID=@CUR_INCREMENT_ID
												if @CTC_PT > 0
													BEGIN
														
														--added jimit 04032016	
														select @Allowance_Type = Allowance_Type 
														from   T0050_AD_MASTER WITH (NOLOCK) 
														WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
														and CMP_ID = @CTC_CMP_ID 
														--ended
														
														SET @NUMTMPCAL = @NUMTMPCAL + (@CTC_PT * @CTC_TOT_MON)
														INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID)
															VALUES
														(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@COUNT,@CTC_COLUMNS,@CTC_PT, @NUMTMPCAL ,NULL,'D',NULL)
														
														SET @COUNT = @COUNT + 1
														SET @TOTAL_DED = @TOTAL_DED + ISNULL(@CTC_PT,0)
													END												
											end
										ELSE IF @CTC_COLUMNS = 'Total_Deduction'	
											BEGIN		
												IF  @TOTAL_DED > 0
													BEGIN		
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--if @CTC_PRV_MON_DOJ > 0
														--	Set @numTmpCal = @Total_Ded
														
														--added jimit 04032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK) 
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
														
														SET @NUMTMPCAL = @NUMTMPCAL + (@TOTAL_DED * @CTC_TOT_MON)
														--Set @numTmpCal = @numTmpCal + @Total_Ded
														INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID)
															VALUES
														(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@COUNT,REPLACE(@CTC_COLUMNS,'_',' '),@TOTAL_DED,@NUMTMPCAL,NULL,'D',NULL)
														SET @COUNT = @COUNT + 1
													END				
											END
										ELSE IF @CTC_COLUMNS = 'Net_Take_Home'	
											BEGIN
												SET @NUMTMPCAL = (ISNULL(@CTC_GROSS,0)  - ISNULL(@TOTAL_DED,0))
												IF  @NUMTMPCAL > 0
													BEGIN
													
														--added jimit 04032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK) 
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
																										
														DECLARE @NUMTEMPCAL3 NUMERIC(18,2)
														SET @NUMTEMPCAL3 = 0
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
																--Set @numTempCal3 = (@numTmpCal/(DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ))))) * @CTC_PRV_MON_DOJ
														SET @NUMTEMPCAL3 = @NUMTEMPCAL3 + (@NUMTMPCAL * @CTC_TOT_MON)
														--Set @numTempCal3 = @numTempCal3 + ((@numTmpCal/(DaY(dbo.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))))) * @CTC_CUR_MON_DAY)
														INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID)
															VALUES
														(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@COUNT,REPLACE(@CTC_COLUMNS,'_',' '),@NUMTMPCAL,@NUMTEMPCAL3,NULL,NULL,NULL)	
														SET @COUNT = @COUNT + 1
													END
											END
										ELSE
											BEGIN
												DECLARE @CTC_AD_ID NUMERIC

												
												--SELECT @ALLOW_AMOUNT=E_AD_AMOUNT,@CTC_AD_FLAG=E_AD_FLAG,@CTC_AD_ID=AD.AD_ID FROM T0100_EMP_EARN_DEDUCTION  DED
												--	INNER JOIN T0050_AD_MASTER AD ON DED.AD_ID = AD.AD_ID
												--	WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(AD.AD_NAME)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS AND DED.CMP_ID = @CTC_CMP_ID AND DED.EMP_ID = @CTC_EMP_ID AND DED.INCREMENT_ID = @CUR_INCREMENT_ID 
												
												--SELECT @ALLOW_AMOUNT=E_AD_AMOUNT,@CTC_AD_FLAG=E_AD_FLAG,@CTC_AD_ID=AD.AD_ID,@Allowance_Type = AD.Allowance_Type 
												--FROM T0100_EMP_EARN_DEDUCTION  DED
												--	INNER JOIN T0050_AD_MASTER AD ON DED.AD_ID = AD.AD_ID
												--WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(AD.AD_NAME)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
												--AND DED.CMP_ID = @CTC_CMP_ID AND DED.EMP_ID = @CTC_EMP_ID AND DED.INCREMENT_ID = @CUR_INCREMENT_ID 
												
												
												SELECT @ALLOW_AMOUNT =  ISNULL(E_AD_AMOUNT,0),@CTC_AD_FLAG = E_AD_FLAG,@CTC_AD_ID = AD_Id ,@Allowance_Type = Allowance_Type 
												from 
												(
													SELECT DISTINCT EED.AD_ID,EED.E_AD_FLAG,
														 Case When Qry1.Increment_ID >= EED.INCREMENT_ID Then
															Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
														 Else
															eed.e_ad_Amount End As E_Ad_Amount,AD_LEVEL , AM.Allowance_Type
													FROM	T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
															T0080_EMP_MASTER E WITH (NOLOCK) on EED.Emp_ID=E.Emp_ID  INNER JOIN 
															T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id LEFT OUTER JOIN
															( Select EEDR.Emp_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
																From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
																( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
																	Where Emp_Id = @CTC_EMP_ID And For_date <= @To_Date 
																 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
															) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID
													WHERE Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
														AND REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(AM.AD_NAME)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
														AND EED.CMP_ID = @CTC_CMP_ID AND EED.EMP_ID = @CTC_EMP_ID AND EED.INCREMENT_ID = @CUR_INCREMENT_ID 
													
													UNION ALL
													
													SELECT DISTINCT    EED.AD_ID, EED.E_AD_FLAG, EED.E_AD_AMOUNT,AD_LEVEL  , T0050_AD_MASTER.Allowance_Type
													FROM   dbo.T0110_EMP_EARN_DEDUCTION_REVISED AS EED WITH (NOLOCK) INNER JOIN
															( SELECT Max(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) WHERE Emp_Id = @CTC_EMP_ID AND INCREMENT_ID = @Cur_Increment_ID And For_date <= @To_Date GROUP BY Ad_Id )Qry 
																ON EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id INNER JOIN
															dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID INNER JOIN
															dbo.T0050_AD_MASTER WITH (NOLOCK) ON EED.AD_ID = dbo.T0050_AD_MASTER.AD_ID 
													WHERE EED.EMP_ID = @CTC_EMP_ID AND EEd.ENTRY_TYPE = 'A'
														AND REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(dbo.T0050_AD_MASTER.AD_NAME)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
														AND EED.CMP_ID = @CTC_CMP_ID AND EED.EMP_ID = @CTC_EMP_ID AND EED.INCREMENT_ID = @CUR_INCREMENT_ID 
													
													) Qry_temp
													ORDER BY AD_LEVEL ASC
												
												
												IF @ALLOW_AMOUNT > 0
													BEGIN
														
														DECLARE @ALLOW_AMOUNT_NET AS NUMERIC(18,2)
														SET @ALLOW_AMOUNT_NET = 0
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--if @CTC_PRV_MON_DOJ > 0
														--	Set @ALlow_Amount_Net = @Allow_Amount
														SET @ALLOW_AMOUNT_NET = @ALLOW_AMOUNT_NET + (@ALLOW_AMOUNT * @CTC_TOT_MON)
														--Set @ALlow_Amount_Net = @ALlow_Amount_Net + @Allow_Amount
														INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,Allowance_Type)
															VALUES
														(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,NULL,REPLACE(@CTC_COLUMNS,'_',' '),ISNULL(@ALLOW_AMOUNT,0),@ALLOW_AMOUNT_NET ,@CTC_AD_ID,NULL,NULL,@Allowance_Type)			
														--Set @Count = @Count + 1
													END											   
											END
										IF @CTC_AD_FLAG = 'I'
											BEGIN
												SET @TOTAL_EAR = @TOTAL_EAR + ISNULL(@ALLOW_AMOUNT,0)
											END
										ELSE IF @CTC_AD_FLAG = 'D'
											BEGIN
												SET @TOTAL_DED = @TOTAL_DED + ISNULL(@ALLOW_AMOUNT,0)											
											END
										--set @Inc_Id = 0
										SET @ALLOW_AMOUNT = 0		
								END
								
								--------------------------------------------			
							FETCH NEXT FROM CRU_COLUMNS INTO @CTC_COLUMNS
						END
			CLOSE CRU_COLUMNS	
			DEALLOCATE CRU_COLUMNS
			FETCH NEXT FROM CTC_UPDATE INTO  @CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@CTC_DOJ,@CTC_BASIC
	END
	CLOSE CTC_UPDATE	
	DEALLOCATE CTC_UPDATE	
	----------------------------------------------------------------
	SELECT *,(ISNULL(MONTHLY_AMT,0) * 12) AS TOTAL_YEAR_AMT FROM #CTCMAST  -- ADDED BY GADRIWALA 05012014
	ORDER BY EMP_ID ,TRAN_ID
	
	DROP TABLE #CTCMAST
	RETURN




