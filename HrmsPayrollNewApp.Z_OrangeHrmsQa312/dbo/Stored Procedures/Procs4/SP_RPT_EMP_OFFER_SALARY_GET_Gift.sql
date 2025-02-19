---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_OFFER_SALARY_GET_Gift]
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
	,@LETTER		VARCHAR(30)='OFFER'
    ,@PBRANCH_ID VARCHAR(200) = '0'
    ,@Show_Hidden_Allowance  bit = 0   --Added by Jaina 24-12-2016
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
DECLARE @YEAR_END_DATE AS DATETIME  
DECLARE @USER_TYPE VARCHAR(30)  
   
 
set @Show_Hidden_Allowance = 0 

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
     
--DECLARE @EMP_CONS TABLE
--(
--	EMP_ID	NUMERIC
--)

CREATE TABLE #Emp_Cons 
	 (      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric
	 )     
	 
EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0,0,0,0,0,0,3,0,0,0
	
CREATE NONCLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);

	
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
	--					( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_INCREMENT
	--					where Increment_Effective_date <= @To_Date
	--					and Cmp_ID = @Cmp_ID
	--					group by emp_ID  ) Qry on
	--					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	 Inner join
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
	--					( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_INCREMENT
	--					where Increment_Effective_date <= @To_Date
	--					and Cmp_ID = @Cmp_ID
	--					group by emp_ID  ) Qry on
	--					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	 Inner join
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
	
	CREATE table #CTCMast
	(
		
				Tran_ID		numeric IDENTITY(1,1), 	
				Cmp_ID		numeric,
				Emp_ID		numeric,
				Branch_ID	numeric,
				Increment_ID numeric,
				Def_ID		numeric,
				Label_Head	varchar(100),
				Monthly_Amt	numeric(18,2),
				Yearly_Amt	numeric(18,2),
				AD_ID		numeric,
				AD_Flag		char(1),
				AD_DEF_ID	numeric,
				Group_Name	varchar(100) null,
				Seq_No Numeric(18,2) NULL,
				Salary_Group varchar(100)null,
				Salary_Part_Group varchar(200) Null
				
	)
	
	CREATE CLUSTERED INDEX ix_ctc ON DBO.#CTCMast
	(
		EMP_ID,Branch_ID,Increment_ID,DEF_ID
	 )
	----------------------------------------------------------------
		
	Declare @Columns nvarchar(2000)
	Declare @CTC_CMP_ID numeric(18,0)
	Declare @CTC_EMP_ID numeric(18,0)
	Declare @CTC_BASIC numeric(18,2)
	Declare @AD_NAME_DYN nvarchar(100)
	Declare @val nvarchar(500)
	
	Set @Columns = '#'
	
	DECLARE Allow_Dedu_Cursor CURSOR FOR
		select AD_NAME from T0050_AD_MASTER WITH (NOLOCK) where Cmp_id = @Cmp_ID and ad_part_of_ctc = 1 and AD_NOT_EFFECT_SALARY = 0 and AD_FLAG = 'I' and isnull(Allowance_Type,'A') = 'A' order by AD_Level
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
										
					Set @AD_NAME_DYN = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
	
	
		----------------------------------------------------------------
				
	Set @Columns = @Columns +  'Reimbersement_Salary#'
	
	----------------------------------------------------------------
	
	DECLARE Allow_Dedu_Cursor CURSOR FOR
		select AD_NAME from T0050_AD_MASTER WITH (NOLOCK) where Cmp_id = @Cmp_ID and ad_part_of_ctc = 1 and AD_NOT_EFFECT_SALARY = 1 and AD_FLAG = 'I' and isnull(Allowance_Type,'A')='R' 
		AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0 AND Hide_In_Reports = 1  THEN 0 ELSE 1 END) = 1 --Added by Jaina 24-12-2016
		order by AD_Level
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
										
					Set @AD_NAME_DYN = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
	
	
----------------------------------------------------------------
				
	Set @Columns = @Columns +  'Gross_Salary#'
	
	----------------------------------------------------------------
	
	Declare Allow_Dedu_Cursor CURSOR FOR
		select AD_NAME from T0050_AD_MASTER WITH (NOLOCK) where Cmp_id = @Cmp_ID and ad_part_of_ctc = 1 and AD_NOT_EFFECT_SALARY = 1 and AD_FLAG = 'I' and isnull(Allowance_Type,'A') <> 'R' 
		AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0 AND Hide_In_Reports = 1  THEN 0 ELSE 1 END) = 1 --Added by Jaina 24-12-2016
		order by AD_Level
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
									
					Set @AD_NAME_DYN = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
	
	----------------------------------------------------------------
	
	Set @Columns = @Columns +  'CTC#'
	
	----------------------------------------------------------------
	
	
	Set @Columns = @Columns +  'PT#'
	Set @Columns = @Columns +  'Total_Deduction#'
	Set @Columns = @Columns +  'Net_Take_Home#'
	
	----------------------------------------------------------------
				
	set @CTC_CMP_ID = @Cmp_ID
	declare @Cur_Branch_ID as numeric(18,0)
	set @Cur_Branch_ID = 0
	declare @Prev_Branch_ID as numeric(18,0)
	set @Prev_Branch_ID = 0
	declare @Cur_Increment_ID as numeric(18,0)
	set @Cur_Increment_ID = 0
	Declare @CTC_DOJ datetime
	Declare @CTC_NEW_DOJ datetime
	Declare @CTC_NEW_DOJ2 datetime
	Declare @CTC_PRV_MON_DOJ numeric
    Declare @CTC_TOT_MON numeric
	Declare @CTC_COLUMNS nvarchar(100)
	Declare @CTC_GROSS numeric(18,2)
	Declare @Total_Ear numeric(18,2)
	Declare @Total_Ded numeric(18,2)
	Declare @CTC_AD_FLAG varchar(1)
	Declare @CTC_PT numeric(18,2)
	Declare @Allow_Amount numeric(18,2)
	Declare @numTmpCal numeric(18,2)
	
	Declare CTC_UPDATE CURSOR FOR
		select EC.Emp_Id,EC.Branch_ID,I.Increment_ID,EM.Date_Of_Join,IE.Basic_Salary 
		from 	#Emp_Cons EC 
				Inner JOIN T0095_INCREMENT IE WITH (NOLOCK) ON EC.EMP_Id = IE.EMP_ID --and EC.Increment_ID = IE.Increment_ID		
		INNER JOIN (								
					SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 
					FROM	T0095_Increment I2 WITH (NOLOCK)
							--INNER JOIN T0080_EMP_MASTER E ON I2.Emp_ID=E.Emp_ID	
							INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
										FROM 	T0095_INCREMENT I3 WITH (NOLOCK)
												INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.Emp_ID	
										WHERE I3.Increment_effective_Date <= @TO_DATE AND I3.Cmp_ID = @Cmp_ID and I3.Increment_Type Not IN ('Transfer','Deputation')
										GROUP BY I3.EMP_ID  
										) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID																																			
					GROUP BY I2.Emp_ID
					) I ON IE.Emp_ID = I.Emp_ID AND IE.Increment_ID=I.Increment_ID  --Added By Jimit 28022018 for getting Latest Increment Id not in transfer and deputation
		Inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EC.Emp_ID
	OPEN CTC_UPDATE
	fetch next from CTC_UPDATE into @CTC_EMP_ID,@Cur_Branch_ID,@Cur_Increment_ID,@CTC_DOJ,@CTC_BASIC
	while @@fetch_status = 0
		Begin	
			Declare @Count numeric
			set @Count = 1
			
			-------------------------------------------------------------------------------------------------
			-- Annually Salry will be calulated till current date from date of Joining or Starting of year --
			-------------------------------------------------------------------------------------------------
			
			
			--select @CTC_DOJ = Date_Of_Join from T0080_EMP_MASTER where Cmp_ID = @CTC_CMP_ID and Emp_ID = @CTC_EMP_ID
			
			--Added By Jimit 14082018 as case at WCl consider Increment Id without tranafer and deputation 
			SELECT	@CUR_INCREMENT_ID = I.INCREMENT_ID 
			FROM	T0095_INCREMENT IE WITH (NOLOCK)
					INNER JOIN (
									SELECT	MAX(I2.INCREMENT_ID) AS INCREMENT_ID,I2.EMP_ID 
									FROM	T0095_INCREMENT I2 WITH (NOLOCK)  INNER JOIN 
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
			---Ended
			


			if year(@CTC_DOJ) < YEAR(getdate()) -1 
				begin	
					
					SET @CTC_NEW_DOJ = CONVERT(datetime,'01-Apr-' + Convert(nvarchar,YEAR(GETDATE()) - 1))
				end
			else if year(@CTC_DOJ) = YEAR(getdate()) -1 and Month(@CTC_DOJ) < 4
				begin
					SET @CTC_NEW_DOJ = CONVERT(datetime,'01-Apr-' + Convert(nvarchar,YEAR(GETDATE()) - 1))
				end
			else
				begin	
					SET @CTC_NEW_DOJ = CONVERT(datetime,dbo.GET_MONTH_ST_DATE(MONTH(@CTC_DOJ),YEAR(@CTC_DOJ)))
				end
			
			--select @CTC_DOJ
			
			if MONTH(getdate()) = 3
				begin	
					Set @CTC_NEW_DOJ2 = CONVERT(datetime,'31-Mar-'  + Convert(nvarchar,YEAR(GETDATE())))
				end
			else if MONTH(getdate()) < 4
				begin	
					Set @CTC_NEW_DOJ2 = CONVERT(datetime,'31-Mar-'  + Convert(nvarchar,YEAR(GETDATE())))
				end
			else
				begin
					SET @CTC_NEW_DOJ = CONVERT(datetime,'01-Apr-' + Convert(nvarchar,YEAR(GETDATE())))
					Set @CTC_NEW_DOJ2 = CONVERT(datetime,'31-Mar-'  + Convert(nvarchar,YEAR(GETDATE()) + 1))
				end
			
			
			
			--select @CTC_NEW_DOJ,@CTC_NEW_DOJ2
			
			SET @CTC_TOT_MON = DATEDIFF(mm,@CTC_NEW_DOJ,@CTC_NEW_DOJ2) + 1
			
			--select @CTC_TOT_MON
			
			if @CTC_TOT_MON > 12
				begin	
					set @CTC_TOT_MON  = 12
				end
									
		
			
			set @CTC_COLUMNS = ''
			Set @CTC_GROSS = 0
			Set @Total_Ear = 0
			Set @Total_Ded = 0
			set @CTC_AD_FLAG = ''
			Set @CTC_PT = 0
			set @numTmpCal = 0
			set @Allow_Amount = 0
		
			
			
			--------------------------------------------------------------------------------------
			
			--select @CTC_BASIC=Basic_Salary  from T0095_INCREMENT where CMP_ID = @Cmp_Id and EMP_ID = @CTC_EMP_ID 
			--and Increment_ID = (select max(Increment_ID) as Increment_ID from T0095_INCREMENT where  Increment_Effective_Date <= @To_Date and CMP_ID = @Cmp_Id and EMP_ID = @CTC_EMP_ID)
																
			Set @numTmpCal = @numTmpCal + (@CTC_BASIC * @CTC_TOT_MON)
			
		
									
			insert into #CTCMast (Cmp_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Group_Name,seq_no,Salary_Group,Salary_Part_Group)
				values
			(@CTC_CMP_ID,@CTC_EMP_ID,@Count,'Basic Salary',@CTC_BASIC,@numTmpCal,NULL,'I',NULL,'Salary',1,'Gross Salary','Part - A')
			
			Set @Count = @Count + 1
			
			
			declare @allowance_Part numeric -- added by rohit on 30092013
			set @allowance_Part = 0 -- added by rohit on 30092013
			declare @CTC_AD_ID numeric
			Declare @ALlow_Amount_Net as numeric(18,2)
			DECLARE @Salary_Part_Group varchar(200)
			Set @Salary_Part_Group = 'Part - A'
						
			Declare CRU_COLUMNS CURSOR FOR
				Select data from Split(@Columns,'#') where data <> ''
			OPEN CRU_COLUMNS
					fetch next from CRU_COLUMNS into @CTC_COLUMNS
					while @@fetch_status = 0
						Begin					
								--------------------------------------------
								
							--	select @Inc_Id=MAX(INCREMENT_ID) from T0095_INCREMENT where CMP_ID = @CTC_CMP_ID and EMP_ID = @CTC_EMP_ID and Increment_Effective_Date <= @To_Date
								
								if @Cur_Increment_ID > 0
								begin
										
										Set @CTC_COLUMNS = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(@CTC_COLUMNS)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
										

										set @numTmpCal = 0
										
										IF @CTC_COLUMNS = 'Gross_Salary'
											begin											
												
												set @allowance_Part = 1 
												Set @Salary_Part_Group = 'Part - A'
												
											end
											
										else if	@CTC_COLUMNS = 'CTC'
											begin

													set @allowance_Part = 2 
													Set @Salary_Part_Group = 'Part - A'
											end
									
										-- Added by rohit on 19112013
											else if	@CTC_COLUMNS = 'Reimbersement_Salary'
											begin
													set @allowance_Part = 3 -- added by rohit on 30092013
													Set @Salary_Part_Group = 'Part - A'
											end
											-- Ended by rohit on 19112013

										 else if @allowance_Part = 1  
											begin
													SELECT @Allow_Amount =  E_AD_AMOUNT,@CTC_AD_FLAG = E_AD_FLAG,@CTC_AD_ID = AD_Id 
													from 
													(
														SELECT DISTINCT EED.AD_ID,EED.E_AD_FLAG,
																		 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
																			Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
																		 Else
																			eed.e_ad_Amount End As E_Ad_Amount,AD_LEVEL
														FROM		T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
																			T0080_EMP_MASTER E WITH (NOLOCK) on EED.Emp_ID=E.Emp_ID  INNER JOIN 
																			T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id LEFT OUTER JOIN
																			( Select EEDR.Emp_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
																				From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
																				( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
																					Where Emp_Id = @CTC_EMP_ID And For_date <= @To_Date AND  INCREMENT_ID = @Cur_Increment_ID
																				 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
																			) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID And Qry1.FOR_DATE>=EED.FOR_DATE 
														WHERE EED.INCREMENT_ID = @Cur_Increment_ID And EEd.EMP_ID = @CTC_EMP_ID And 
															Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D' And Am.AD_ACTIVE = 1
															AND Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(AM.Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
														
														UNION ALL
														
														SELECT DISTINCT    EED.AD_ID, EED.E_AD_FLAG, EED.E_AD_AMOUNT,AD_LEVEL
														FROM         dbo.T0110_EMP_EARN_DEDUCTION_REVISED AS EED WITH (NOLOCK) INNER JOIN
																		( SELECT Max(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) WHERE Emp_Id = @CTC_EMP_ID AND INCREMENT_ID = @Cur_Increment_ID And For_date <= @To_Date GROUP BY Ad_Id )Qry 
																			ON EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id INNER JOIN
																		dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID INNER JOIN
																		dbo.T0050_AD_MASTER WITH (NOLOCK) ON EED.AD_ID = dbo.T0050_AD_MASTER.AD_ID 
																			  					  
														WHERE EED.EMP_ID = @CTC_EMP_ID AND EEd.ENTRY_TYPE = 'A'
																AND Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(T0050_AD_MASTER.Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
																AND EED.INCREMENT_ID = @Cur_Increment_ID And T0050_AD_MASTER.AD_ACTIVE = 1

														) Qry_temp
														ORDER BY AD_LEVEL ASC
													
													
													if @Allow_Amount > 0
														begin
															
															
															set @ALlow_Amount_Net = 0
															
															--if @CTC_TOT_YEAR = 0
															--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
															--if @CTC_PRV_MON_DOJ > 0
															--	Set @ALlow_Amount_Net = @Allow_Amount
																	
															Set @ALlow_Amount_Net = @ALlow_Amount_Net + (@Allow_Amount * @CTC_TOT_MON)
															
															--Set @ALlow_Amount_Net = @ALlow_Amount_Net + @Allow_Amount
																
															
															insert into #CTCMast (Cmp_ID,Emp_ID,Branch_ID,Increment_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Group_Name,seq_no,Salary_Group,Salary_Part_Group)
																values
															(@CTC_CMP_ID,@CTC_EMP_ID,@Cur_Branch_ID,@Cur_Increment_ID,NULL,Replace(@CTC_COLUMNS,'_',' '),isnull(@Allow_Amount,0),@ALlow_Amount_Net ,@CTC_AD_ID,NULL,NULL,'Company Contribution',11,'Z-Cost to the Company',@Salary_Part_Group)			
															
															--Set @Count = @Count + 1
														end
																				   
													
												end
											
											else if @allowance_Part = 3  
											begin
											
													SELECT @Allow_Amount =  E_AD_AMOUNT,@CTC_AD_FLAG = E_AD_FLAG,@CTC_AD_ID = AD_Id 
													from 
													(
														SELECT DISTINCT EED.AD_ID,EED.E_AD_FLAG,
																		 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
																			Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
																		 Else
																			eed.e_ad_Amount End As E_Ad_Amount,AD_LEVEL
														FROM		T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
																			T0080_EMP_MASTER E WITH (NOLOCK) on EED.Emp_ID=E.Emp_ID  INNER JOIN 
																			T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id LEFT OUTER JOIN
																			( Select EEDR.Emp_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
																				From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
																				( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
																					Where Emp_Id = @CTC_EMP_ID And For_date <= @To_Date AND  INCREMENT_ID = @Cur_Increment_ID
																				 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
																			) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID And Qry1.FOR_DATE>=EED.FOR_DATE
														WHERE EED.INCREMENT_ID = @Cur_Increment_ID And EEd.EMP_ID = @CTC_EMP_ID And 
															Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
															AND Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(AM.Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
														
														UNION ALL
														
														SELECT DISTINCT    EED.AD_ID, EED.E_AD_FLAG, EED.E_AD_AMOUNT,AD_LEVEL
														FROM         dbo.T0110_EMP_EARN_DEDUCTION_REVISED AS EED WITH (NOLOCK) INNER JOIN
																		( SELECT Max(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) WHERE Emp_Id = @CTC_EMP_ID AND INCREMENT_ID = @Cur_Increment_ID And For_date <= @To_Date GROUP BY Ad_Id )Qry 
																			ON EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id INNER JOIN
																		dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID INNER JOIN
																		dbo.T0050_AD_MASTER WITH (NOLOCK) ON EED.AD_ID = dbo.T0050_AD_MASTER.AD_ID 
																			  					  
														WHERE EED.EMP_ID = @CTC_EMP_ID AND EEd.ENTRY_TYPE = 'A'
																AND Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(T0050_AD_MASTER.Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
																AND EED.INCREMENT_ID = @Cur_Increment_ID
														) Qry_temp
														ORDER BY AD_LEVEL ASC
													
													
													if @Allow_Amount > 0
														begin
															
															
															set @ALlow_Amount_Net = 0
															
															--if @CTC_TOT_YEAR = 0
															--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
															--if @CTC_PRV_MON_DOJ > 0
															--	Set @ALlow_Amount_Net = @Allow_Amount
																	
															Set @ALlow_Amount_Net = @ALlow_Amount_Net + (@Allow_Amount * @CTC_TOT_MON)
															
															--Set @ALlow_Amount_Net = @ALlow_Amount_Net + @Allow_Amount
																
															
															insert into #CTCMast (Cmp_ID,Emp_ID,Branch_ID,Increment_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Group_Name,seq_no,Salary_Group,Salary_Part_Group)
																values
															(@CTC_CMP_ID,@CTC_EMP_ID,@Cur_Branch_ID,@Cur_Increment_ID,NULL,Replace(@CTC_COLUMNS,'_',' '),isnull(@Allow_Amount,0),@ALlow_Amount_Net ,@CTC_AD_ID,NULL,NULL,'Reimbursement',11,'Gross Salary',@Salary_Part_Group)			
															
															--Set @Count = @Count + 1
														end
																				   
													
												end
																
										else
											begin
												
												
												--select @Allow_Amount=E_AD_AMOUNT,@CTC_AD_FLAG=E_AD_FLAG,@CTC_AD_ID=ad.AD_Id 
												--from T0100_EMP_EARN_DEDUCTION  ded
												--	inner join T0050_AD_MASTER ad on ded.AD_Id = ad.AD_Id
												--WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(ad.Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID and ded.INCREMENT_ID = @Inc_Id 
												
												SELECT @Allow_Amount =  E_AD_AMOUNT,@CTC_AD_FLAG = E_AD_FLAG,@CTC_AD_ID = AD_Id 
													from 
													(
														SELECT DISTINCT EED.AD_ID,EED.E_AD_FLAG,
															 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
																Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
															 Else
																eed.e_ad_Amount End As E_Ad_Amount,AD_LEVEL
														FROM		T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
																			T0080_EMP_MASTER E WITH (NOLOCK) on EED.Emp_ID=E.Emp_ID  INNER JOIN 
																			T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id LEFT OUTER JOIN
																			( Select EEDR.Emp_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE,EEDR.Increment_ID 
																				From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
																				( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
																					Where Emp_Id = @CTC_EMP_ID And For_date <= @To_Date --AND  INCREMENT_ID = @Cur_Increment_ID
																				 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
																			) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID And Qry1.FOR_DATE>=EED.FOR_DATE
														WHERE EED.INCREMENT_ID = @Cur_Increment_ID And EEd.EMP_ID = @CTC_EMP_ID And 
															Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
															--AND (CASE WHEN Qry1.FOR_DATE = EED.FOR_DATE AND Qry1.Increment_ID >= @Cur_Increment_ID THEN 1 WHEN Qry1.FOR_DATE > EED.FOR_DATE THEN 1 ELSE 0 END) = 1
															AND Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(AM.Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
														
														UNION ALL
														
														SELECT DISTINCT    EED.AD_ID, EED.E_AD_FLAG, EED.E_AD_AMOUNT,AD_LEVEL
														FROM         dbo.T0110_EMP_EARN_DEDUCTION_REVISED AS EED WITH (NOLOCK) INNER JOIN
																		( SELECT Max(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) WHERE Emp_Id = @CTC_EMP_ID And For_date <= @To_Date GROUP BY Ad_Id )Qry 
																			ON EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id INNER JOIN
																		dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID INNER JOIN
																		dbo.T0050_AD_MASTER WITH (NOLOCK) ON EED.AD_ID = dbo.T0050_AD_MASTER.AD_ID 
																			  					  
														WHERE EED.EMP_ID = @CTC_EMP_ID AND EEd.ENTRY_TYPE = 'A'
																AND Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(T0050_AD_MASTER.Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
																AND EED.INCREMENT_ID = @Cur_Increment_ID
														) Qry_temp
														ORDER BY AD_LEVEL ASC
												
												if @Allow_Amount > 0
													begin
														
														
														set @ALlow_Amount_Net = 0
														
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--if @CTC_PRV_MON_DOJ > 0
														--	Set @ALlow_Amount_Net = @Allow_Amount
																
														Set @ALlow_Amount_Net = @ALlow_Amount_Net + (@Allow_Amount * @CTC_TOT_MON)
														
														--Set @ALlow_Amount_Net = @ALlow_Amount_Net + @Allow_Amount
															
														
														insert into #CTCMast (Cmp_ID,Emp_ID,Branch_ID,Increment_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Group_Name,seq_no,Salary_Group,Salary_Part_Group)
															values
														(@CTC_CMP_ID,@CTC_EMP_ID,@Cur_Branch_ID,@Cur_Increment_ID,NULL,Replace(@CTC_COLUMNS,'_',' '),isnull(@Allow_Amount,0),@ALlow_Amount_Net ,@CTC_AD_ID,NULL,NULL,'Allowances',11,'Gross Salary',@Salary_Part_Group)			
														
														--Set @Count = @Count + 1
													end
																			   
												
											end
										if @CTC_AD_FLAG = 'I'
											begin
												Set @Total_Ear = @Total_Ear + isnull(@Allow_Amount,0)
											end
										else if @CTC_AD_FLAG = 'D'
											begin
												Set @Total_Ded = @Total_Ded + isnull(@Allow_Amount,0)											
											end
										
										--set @Inc_Id = 0
										Set @Allow_Amount = 0
										
								end
								
								--------------------------------------------
								
							fetch next from CRU_COLUMNS into @CTC_COLUMNS
						End
			close CRU_COLUMNS	
			deallocate CRU_COLUMNS
					
	
			fetch next from CTC_UPDATE into @CTC_EMP_ID,@Cur_Branch_ID,@Cur_Increment_ID,@CTC_DOJ,@CTC_BASIC
	End
	close CTC_UPDATE	
	deallocate CTC_UPDATE
	
	----------------------------------------------------------------
	UPDATE #CTCMast Set Salary_Part_Group = 'Part - B',Salary_Group='Z-Cost to the Company',Group_Name='Additional Benefit',Seq_No=12 
	From #CTCMast CM Inner join T0050_AD_MASTER AM On CM.Label_Head = AM.AD_NAME
	where AM.AD_DEF_ID in (24,25,26)


--insert into #CTCMast 
--	(Cmp_ID,Emp_ID,Branch_ID,Increment_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Group_Name,seq_no,Salary_Group,Salary_Part_Group)
	
--	Select Cmp_ID,Emp_ID,NULL,NULL,Null,'Total CTC (Part - A)',Sum(Monthly_Amt),Sum(Yearly_Amt),NULL,NULL,NULL,'Total CTC (Part - A)',11,'Total CTC (Part - A)','Part - A' 
--	From #CTCMast
--	Where Salary_Part_Group='Part - A'
--	GROUP By Cmp_ID,Emp_ID
	
	--(@CTC_CMP_ID,@CTC_EMP_ID,@Cur_Branch_ID,@Cur_Increment_ID,NULL,Replace(@CTC_COLUMNS,'_',' '),isnull(@Allow_Amount,0),@ALlow_Amount_Net ,@CTC_AD_ID,NULL,NULL,'Allowances',11,'Gross Salary',@Salary_Part_Group)			




	select (select Monthly_Amt from #CTCMast where Label_Head = 'Basic Salary' and Emp_ID = Em.Emp_ID) as Basic_Salary,--Added by ronakk 21042023
	*,(Monthly_Amt * 12) as Total_Year_Amt
			,T.Branch_ID --Added By Nimesh 11-Jul-2015 (To filter by multiple branch)
			,Cm.Curr_Name,cm.Curr_Symbol
	from	#CTCMast	T	--added By Gadriwala 17022014
	left join T0080_EMP_MASTER Em WITH (NOLOCK) on t.Emp_ID = Em.Emp_ID
	left join T0040_CURRENCY_MASTER CM WITH (NOLOCK) on EM.Curr_ID = Cm.Curr_ID
	order by T.Emp_ID ,seq_no,Tran_ID
	

	drop table #CTCMast
	
	RETURN
