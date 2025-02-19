


---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_Claim_Detail_Format2]  
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

 
 
SET NOCOUNT ON 
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
        
IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 14-10-2015
	set @PBranch_ID = null   	
	
if @PVertical_ID ='0' or @PVertical_ID = ''		--Added By Jaina 14-10-2015
	set @PVertical_ID = null

if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	--Added By Jaina 14-10-2015
	set @PsubVertical_ID = null
	
IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 14-10-2015
	set @PDept_ID = NULL	 
		
--Added By Jaina 14-10-2015 Start		
	if @PBranch_ID is null
	Begin	
		select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @PBranch_ID = @PBranch_ID + ',0'
	End
	
	if @PVertical_ID is null
	Begin	
		select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		If @PVertical_ID IS NULL
			set @PVertical_ID = '0';
		else
			set @PVertical_ID = @PVertical_ID + ',0'
			
	End
	if @PsubVertical_ID is null
	Begin	
		select   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		If @PsubVertical_ID IS NULL
			set @PsubVertical_ID = '0';
		else
			set @PsubVertical_ID = @PsubVertical_ID + ',0'
	End
	IF @PDept_ID is null
	Begin
		select   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
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
         

	--if @Constraint <> ''        
	-- BEGIN	 
	--   Insert Into #Emp_Cons(Emp_ID)        
	--   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')         
	--  END      
 --ELSE        
	-- BEGIN
	--		Insert Into #Emp_Cons      
	--	    select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons 
	--	    left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC
	--		inner join 
	--						(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle where Effective_date <= @To_Date
	--						GROUP BY emp_id) Qry
	--						on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
	--	       ON QrySC.eid = V_Emp_Cons.Emp_ID
	--		where 
	--	    cmp_id=@Cmp_ID 
	--	   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	--	   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	--	   and Grd_ID = isnull(@Grade_ID ,Grd_ID)      
	--	   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	--	   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	--	   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
	--	   and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id ,isnull(QrySC.SalDate_id,0))  
	--	   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))       
	--	   --Added By Jaina 14-10-2015 Start
	--	   --and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') B Where cast(B.data as numeric)=Isnull(V_Emp_Cons.Branch_ID,0))
	--	   --and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(V_Emp_Cons.Vertical_ID,0))
	--	   --and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(V_Emp_Cons.SubVertical_ID,0))
	--	   --and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(V_Emp_Cons.Dept_ID,0))
	--	   --Added By Jaina 14-10-2015 End
	--	   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
	--	      and Increment_Effective_Date <= @To_Date 
	--	      and 
 --                     ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
	--					or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
	--					or (Left_date is null and @To_Date >= Join_Date)      
	--					or (@To_Date >= left_date  and  @From_Date <= left_date )						
	--					) 
	--					order by Emp_ID
	--		Delete From #Emp_Cons Where Increment_ID Not In
	--			(select TI.Increment_ID from t0095_increment TI inner join
	--			(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment
	--			Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
	--			on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
	--			Where Increment_effective_Date <= @to_date)
 -- END
		
	
	IF OBJECT_ID('tempdb..#Claim') IS NOT NULL
	BEGIN
		DROP TABLE #Claim
	END
	
	Create table #Claim
	(
		Emp_ID			numeric(18,0),
		Claim_Apr_ID	numeric(18,0),
		Claim_App_ID    numeric(18,0),
		For_date        varchar(max),
		Claim_type      varchar(255),
		Description	    varchar(255),
		Currency        varchar(255),
		Amount			varchar(255),--numeric(18,2),
		rate			numeric(18,2),
		TotalAmount_one numeric(18,2),
		Currency_Rate numeric(18,2)	,
		Claim_Apr_Dtl_Id numeric(18,0)			
	)
	
	IF OBJECT_ID('tempdb..#Total_Claim') IS NOT NULL
	BEGIN
		DROP TABLE #Total_Claim
	END
	Create table #Total_Claim
	(
		Clam_apr_ID_1   numeric(18,0),
		Emp_ID			numeric(18,0),
		Claim_Apr_ID	numeric(18,0),
	
		for_Date		datetime, --varchar(255),		
		Currency        varchar(255),
		Description     varchar(255),
		Currency_Rate varchar(255),
		Claim_Apr_Dtl_Id numeric(18,0)	
		
						
	)
	
		
;WITH cte AS 
 (
		select clm.Claim_App_ID,
		clmpr.Claim_Apr_ID,
		clm.Claim_Apr_Date as for_date,
		clmpr.Claim_Apr_Comments,
		clm.Claim_Apr_Code,
		clm.Emp_ID,
		clmpr.Claim_Apr_By,
		clmpr.Claim_Apr_Deduct_From_Sal,
		clm.Claim_Apr_Amount as TotalAmount,
		clm.Claim_Status,		
		clm.Claim_ID,
		clm.Curr_ID,		
		clm.Claim_Apr_Date, 
		clmst.Claim_Name as Claim_type,
		clm.Claim_Apr_Amount as Claim_apr_Amount,
		clm.Curr_Rate as Curr_Rate,
		clm.Claim_App_Amount as Claim_Amount,		
		clm.Claim_Apr_Amount as Application_Amount_one,
		clm.Claim_App_Amount as Application_Amount,
		clm.Purpose AS Description ,cur.Curr_Name as Currency,
		clm.Claim_Apr_Dtl_ID
		from 
		T0120_CLAIM_APPROVAL clmpr WITH (NOLOCK)
		inner join T0130_CLAIM_APPROVAL_DETAIL clm WITH (NOLOCK) on clm.Cmp_ID=clmpr.Cmp_ID and clm.Claim_Apr_ID=clmpr.Claim_Apr_ID and clm.Emp_ID=clmpr.Emp_ID
		inner join T0040_CLAIM_MASTER clmst WITH (NOLOCK) on clmst.Claim_ID=clm.Claim_ID
		left outer join T0040_CURRENCY_MASTER cur WITH (NOLOCK) on clm.Curr_ID= cur.Curr_ID
		where clm.Cmp_ID=@Cmp_ID and clmpr.Claim_Apr_Date between @From_Date and @To_Date
		and clm.Emp_ID in (select Emp_ID from #Emp_Cons) and clm.Claim_Status='A'
)



	INSERT into #Claim
	SELECT Emp_ID,Claim_Apr_ID,Claim_App_ID, for_date,Claim_type,Currency,LEFT(Description, 35),Claim_Amount,Curr_Rate,Application_Amount_one,Curr_Rate,Claim_Apr_Dtl_ID from cte --cte where  RANK = 1
			order BY for_date, Claim_type

   -- LEFT (Description, 35) Added by rajput on 17032018

	insert into #Total_Claim
	SELECT row_number() over( order by Emp_ID,Claim_Apr_ID), Emp_ID,Claim_Apr_ID,for_Date,LEFT(Description, 35),Currency,Currency_Rate,Claim_Apr_Dtl_Id  from #Claim 
			order BY for_date, Claim_type 



	Declare @Claim_Name varchar(255)
	Declare @val nvarchar(max)
	declare @AD_NAME_DYN nvarchar(max)
	declare @Column nvarchar(max)
	set @Column =''
	
	Create Table #new_temp
		(		
		for_date  datetime,
		Emp_ID  numeric(18,0),
		Label_name  nvarchar(max),
		Label_Amount  numeric(18,3)
		)
		
	
	
	DECLARE Claim_Cursor CURSOR FOR
			SELECT distinct Claim_type from #Claim
			
			--Declare @New_fordate as Datetime
			--		declare @New_Emp_id as numeric(18,0) 
			--		declare @New_Amount as numeric(18,3)
			--		select ,@New_Emp_id=Emp_ID,@New_Amount=Amount from #Claim		
		 
		OPEN Claim_Cursor		
			fetch next from Claim_Cursor into @Claim_Name
			while @@fetch_status = 0
				Begin
					
					Set @Claim_Name = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@Claim_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					
					Set @val = 'Alter table   #Total_Claim Add [' + REPLACE(@Claim_Name,' ','_') + '] varchar(255) default 0 not null'
					
					
					exec (@val)	
					Set @val = ''
					
					
					
					Set @Column = @Column +  + '[' + REPLACE(rtrim(ltrim(@Claim_Name)),' ','_') +']' + + '#'
					
					fetch next from Claim_Cursor into @Claim_Name
				End
		close Claim_Cursor	
		deallocate Claim_Cursor		
			Declare @CTC_COLUMNS nvarchar(100)
			Declare @CTC_AD_FLAG varchar(1)
			Declare @Allow_Amount numeric(18,2)
			Declare @Claim_Apr_Amount numeric(18,2)
			set @Claim_Apr_Amount =0
			
			Set @val = 'Alter table   #Total_Claim Add Total_Amount varchar(255)'
			exec (@val)				
					
		Declare @Claim_apr_ID as numeric(18,0)	
			
		DECLARE Claim_Cursor CURSOR FOR
			SELECT distinct Claim_Apr_Dtl_ID from #Claim  
		 
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
														
													select @Allow_Amount=isnull(Amount,0) from #Claim  
														WHere  Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(claim_type)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  = @CTC_COLUMNS 
													      and Claim_Apr_Dtl_Id= @Claim_apr_ID
														
													
													
													Set @val = 	'update    #Total_Claim set ' + @CTC_COLUMNS + ' = ' + @CTC_COLUMNS + ' + ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' where    #Total_Claim.Claim_Apr_Dtl_ID = ' + convert(nvarchar,@Claim_apr_ID)
													EXEC (@val)		
													--set @Claim_Apr_Amount = @Claim_Apr_Amount + @Allow_Amount
												--update #new_temp set Label_Amount=@Allow_Amount
												end
											
												Set @Allow_Amount = 0
												
										end
										
									fetch next from CRU_COLUMNS into @CTC_COLUMNS
								End
					close CRU_COLUMNS	
					deallocate CRU_COLUMNS										
						Update  #Total_Claim set Total_Amount = C.Amount
						 from  #Total_Claim TC inner join 
						 (SELECT Claim_Apr_Dtl_ID, sum(TotalAmount_one) as Amount from #Claim
						  group BY Claim_Apr_Dtl_Id
						 ) C on
						 TC.Claim_Apr_Dtl_Id =C.Claim_Apr_Dtl_Id
						
						where TC.Claim_Apr_Dtl_Id=@Claim_apr_ID																
					fetch next from Claim_Cursor into @Claim_apr_ID
				End
		close Claim_Cursor	
		deallocate Claim_Cursor			 
	
	
	
		set @Column = ' ' + @Column
		Set  @Column = REPLACE(@Column,'#','# ')
		
		set @Column=@Column+'Description'+'#'+'Currency'+'#'+'Currency_Rate'+'#'+'Total_Amount'+'#'
		
		print @Column
		
		DECLARE @table_name SYSNAME
        SELECT @table_name = '#Total_Claim'
        
     
		
		declare @query as nvarchar(max)
		set @query =''
		
	--	alter table  #Total_Claim add Claim_apr_ID1 numeric(18,0) null
		
		
		
		drop table my_temp
		
		DECLARE @SQL NVARCHAR(MAX)
				SELECT @SQL = '
				SELECT Emp_ID,for_Date,Clam_apr_ID_1 as Claim_apr_ID,Reim_Type,Amount into my_temp
				FROM ' + @table_name + ' 
				UNPIVOT (
					Amount FOR Reim_Type IN ( 
						' +  LEFT(replace(@Column,'#',','), LEN(replace(@Column,'#',','))-1)  + '
					) 
			 )  unpiv where Amount <> ''0.00'''
				 
			
			
		  EXEC(@SQL)
		  

		 
		  select	distinct EMP.Alpha_Emp_Code,EMP.Emp_ID,EMP.Emp_Full_Name 
					,INC.BRANCH_ID --Added By Nimesh 11-Jul-2015 (To filter by multiple branch)
		  from		T0080_EMP_MASTER EMP WITH (NOLOCK) inner join #Emp_Cons EC on Emp.Emp_ID = EC.Emp_ID 
					inner join #Total_Claim TC on EC.Emp_ID =TC.Emp_ID
					LEFT OUTER JOIN (
										SELECT	EMP_ID, BRANCH_ID FROM T0095_INCREMENT I WITH (NOLOCK)
										WHERE	Increment_Effective_Date=(SELECT	MAX(Increment_Effective_Date)
																		  FROM		T0095_INCREMENT I1 WITH (NOLOCK)
																		  WHERE		I1.Cmp_ID=I.Cmp_ID AND I1.Emp_ID=I.Emp_ID
																					AND I1.Increment_Effective_Date<= @To_Date
																		  )
												AND I.Cmp_ID=@Cmp_ID																					
									) INC ON EMP.EMP_ID=INC.EMP_ID
		  where EMP.Cmp_ID=@Cmp_ID
		  
		
		
		update my_temp set Reim_Type = ' ' + Reim_Type Where Reim_Type <> 'Description' and Reim_Type <>'Currency' and Reim_Type <>'Total_Amount' and Reim_Type <>'Currency_Rate'
	-- Update my_temp set Reim_type=replace(Reim_type,'_',' ')
		
		select * from (
							
		  select    
		  row_number() OVER (PARTITION BY E.Emp_Full_Name ORDER BY E.Emp_Full_Name DESC ) as rank,
		  E.Emp_Full_Name,
		  DT.Dept_Name,  
		  q.amount1,E.Alpha_Emp_Code as Emp_code,E.Emp_First_Name,C.* 
		  ,BM.Branch_Name                  --added jimit 10062015
		  ,@From_Date as From_Date,@To_Date as To_Date
		  ,E.Date_Of_Birth as DOB
		  ,BM.Branch_ID
		  FROM my_temp C inner join 			  
		   (SELECT Emp_ID,SUM(cast(Amount as numeric(18,2))) as amount1 FROM my_temp where Reim_Type='Total_Amount'
		     GROUP BY Emp_ID) q ON C.Emp_ID = q.Emp_ID inner join
			dbo.T0080_EMP_MASTER E WITH (NOLOCK) on C.Emp_ID = E.Emp_ID 
			INNER JOIN #Emp_Cons EC ON e.emp_id = Ec.emp_ID 
			INNER JOIN (SELECT T0095_INCREMENT.Emp_Id, cat_id, Grd_ID, Dept_ID, Desig_Id, Branch_Id, TYPE_ID, Bank_id, Curr_id, Wages_Type
								, Salary_Basis_on, Basic_salary, Gross_salary, Inc_Bank_Ac_No, Emp_OT, Emp_Late_Mark, Emp_Full_PF, Emp_PT, Emp_Fix_Salary
								, Emp_Part_time, Late_Dedu_Type, Emp_Childran, Center_ID
								, SalDate_ID, Segment_ID, Vertical_ID, SubVertical_ID, SubBranch_ID		
							FROM T0095_INCREMENT WITH (NOLOCK)
								INNER JOIN (SELECT MAX(Increment_effective_Date) AS For_Date, Emp_ID 
												FROM T0095_INCREMENT WITH (NOLOCK)
												WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_Id 
												GROUP BY emp_ID
											) Qry ON T0095_INCREMENT.Emp_ID = Qry.Emp_ID AND Increment_Effective_date = Qry.For_date   
							WHERE cmp_id = @Cmp_Id
						) Inc_Qry ON e.Emp_ID = Inc_Qry.Emp_ID 
			INNER JOIN T0010_COMPANY_MASTER COM WITH (NOLOCK) ON COM.Cmp_Id = E.Cmp_ID
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_Id = GM.Grd_Id
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.Branch_ID = BM.Branch_Id
			INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON Inc_Qry.Desig_Id = DM.Desig_Id									
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DT WITH (NOLOCK) ON Inc_Qry.Dept_Id = DT.Dept_Id) qry		
			
		

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
			FROM T0050_SCHEME_DETAIL SD WITH (NOLOCK)
			INNER JOIN 
(SELECT ES.SCHEME_ID,ES.EMP_ID,ES.TYPE FROM T0095_EMP_SCHEME ES WITH (NOLOCK) INNER JOIN
					(SELECT MAX(EFFECTIVE_DATE) AS EFFECTIVE_DATE,EMP_ID FROM T0095_EMP_SCHEME WITH (NOLOCK)
					WHERE EFFECTIVE_DATE <= @TO_DATE AND CMP_ID=@CMP_ID AND TYPE='Claim' 
					AND EMP_ID IN (SELECT EMP_ID FROM #EMP_CONS)
					GROUP BY EMP_ID) NEW_INC
					ON ES.EMP_ID = NEW_INC.EMP_ID AND ES.EFFECTIVE_DATE=NEW_INC.EFFECTIVE_DATE
					WHERE ES.EFFECTIVE_DATE <= @TO_DATE AND CMP_ID=@CMP_ID AND ES.TYPE='Claim'
					AND ES.EMP_ID IN (SELECT EMP_ID FROM #EMP_CONS))
					QRY_ONE
					ON SD.SCHEME_ID=QRY_ONE.SCHEME_ID
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID=QRY_ONE.EMP_ID
					INNER JOIN #EMP_CONS EC ON EC.EMP_ID=EM.EMP_ID
					
					INNER JOIN T0120_CLAIM_APPROVAL CA WITH (NOLOCK) ON CA.EMP_ID=EM.EMP_ID
					inner JOIN T0115_CLAIM_LEVEL_APPROVAL LA WITH (NOLOCK) ON LA.Emp_ID=EM.Emp_ID --LA.CLAIM_APP_ID=CA.CLAIM_APP_ID
					and SD.Rpt_Level=LA.Rpt_Level --and 
					--LA.Emp_ID=CA.Emp_ID AND 
					--LA.S_EMP_ID=EMSUP.EMP_ID
					left JOIN T0080_EMP_MASTER EMSUP WITH (NOLOCK) ON EMSUP.EMP_ID=EM.EMP_SUPERIOR
					and LA.S_Emp_ID=EMSUP.Emp_ID
					left JOIN T0080_EMP_MASTER EMS WITH (NOLOCK) ON EMS.EMP_ID=SD.APP_EMP_ID
					where La.Approval_Date >=@From_Date and La.Approval_Date<=@To_Date and LA.Cmp_ID=@Cmp_ID
					--order by sd.Scheme_Detail_Id asc
					
					
	
SELECT distinct EM.ALPHA_EMP_CODE,ES.*,BM.BRANCH_NAME,DM.DEPT_NAME,DSG.DESIG_NAME,BM.Branch_ID FROM #EMP_SCHEME ES
INNER JOIN (SELECT T0095_INCREMENT.EMP_ID, CAT_ID, GRD_ID, DEPT_ID, DESIG_ID, BRANCH_ID, TYPE_ID, BANK_ID, CURR_ID, WAGES_TYPE
								, SALARY_BASIS_ON, BASIC_SALARY, GROSS_SALARY, INC_BANK_AC_NO, EMP_OT, EMP_LATE_MARK, EMP_FULL_PF, EMP_PT, EMP_FIX_SALARY
								, EMP_PART_TIME, LATE_DEDU_TYPE, EMP_CHILDRAN, CENTER_ID
								, SALDATE_ID, SEGMENT_ID, VERTICAL_ID, SUBVERTICAL_ID, SUBBRANCH_ID		
							FROM T0095_INCREMENT WITH (NOLOCK)
								INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS FOR_DATE, EMP_ID 
												FROM T0095_INCREMENT WITH (NOLOCK) 
												WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE --AND CMP_ID = @CMP_ID 
												GROUP BY EMP_ID
											) QRY ON T0095_INCREMENT.EMP_ID = QRY.EMP_ID AND INCREMENT_EFFECTIVE_DATE = QRY.FOR_DATE   
							--WHERE CMP_ID = @CMP_ID
						) INC_QRY ON ES.S_EMP_ID = INC_QRY.EMP_ID 
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID=ES.S_EMP_ID
						LEFT JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID=INC_QRY.BRANCH_ID
						LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.DEPT_ID=INC_QRY.DEPT_ID
						LEFT JOIN T0040_DESIGNATION_MASTER DSG WITH (NOLOCK) ON DSG.DESIG_ID=INC_QRY.DESIG_ID
						

IF(@FLAG=1)
	BEGIN
	
	
		SELECT	EM.EMP_FULL_NAME,EM.EMP_ID,EM.ALPHA_EMP_CODE,CLD.Claim_App_ID,CLD.CMP_ID,
		CLD.CLAIM_APP_ID,CLD.Claim_Apr_Date,CL.Claim_Apr_Date as Approval_Date,ISNULL(CLD.Claim_Apr_Amount,0) AS Approval_Amount,
		--CLD.Purpose, -- Commented by Rajput on 17032018
		LEFT (CLD.Purpose, 35) + '..',
		CLD.CLAIM_ID,ISNULL(CLD.CURR_ID,0) AS CURR_ID,ISNULL(CLD.CURR_RATE,0) AS CURR_RATE,
		ISNULL(CLD.Claim_App_Amount,0) AS CLAIM_AMOUNT,
		ISNULL(CLD.Petrol_KM,0) AS PETROL_KM,CM.CLAIM_NAME,CMP.CMP_NAME,
		CMP.CMP_ADDRESS,CMP.CMP_LOGO,BM.Branch_Name,DM.Dept_Name,DSM.Desig_Name,isnull(Vs.Vertical_Name,'') as Vertical_Name,
		ISNULL(BS.Segment_Name,'') as Segment_Name,ISNULL(VS.Vertical_Name,'') as Vertical_Name,ISNULL(SV.SubVertical_Name,'') as SubVertical_Name,
		ISNULL(SB.SubBranch_Name,'') as SubBranch_Name,ISNULL(GM.Grd_Name,'') as Grade_Name,
		case when CLD.Claim_Status='A' then 'Approved' Else 'Rejected' End as Claim_Status
		,CLD.Claim_Apr_Dtl_ID,ISNULL(CLD.Claim_App_Amount,0) AS ACTUAL_CLAIM_AMOUNT,CMT.Curr_Symbol -- CMT.Curr_Symbol,ACTUAL_CLAIM_AMOUNT ADDED BY RAJPUT ON 16032018
FROM	T0130_CLAIM_APPROVAL_DETAIL CLD WITH (NOLOCK)
		INNER JOIN T0120_CLAIM_APPROVAL CL WITH (NOLOCK) ON CL.CLAIM_APP_ID = CLD.CLAIM_APP_ID AND CL.Claim_Apr_ID=CLD.Claim_Apr_ID
		AND CL.CMP_ID=CLD.CMP_ID		
		INNER JOIN #Emp_Cons EC ON EC.Emp_ID=CL.Emp_ID
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID=EC.EMP_ID
		INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON INC.Increment_ID=EC.Increment_ID		
		INNER JOIN T0040_CLAIM_MASTER CM WITH (NOLOCK) ON CM.CLAIM_ID=CLD.CLAIM_ID AND CM.CMP_ID=CLD.CMP_ID		
		INNER JOIN T0010_COMPANY_MASTER CMP WITH (NOLOCK) ON CMP.CMP_ID=CL.CMP_ID
		Left Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on Dm.Dept_Id=INC.Dept_ID
		Left Join T0040_DESIGNATION_MASTER DSM WITH (NOLOCK) on DSM.Desig_ID=INC.Desig_Id
		Left Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID=INC.Branch_ID
		Left Join T0040_GRADE_MASTER GM WITH (NOLOCK) on GM.Grd_ID=INC.Grd_ID
		Left Join T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID=INC.Segment_ID
		Left Join T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID=INC.Vertical_ID
		Left Join T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID=INC.SubVertical_ID
		Left Join T0050_SubBranch SB WITH (NOLOCK) on SB.SubBranch_ID=INC.subBranch_ID	
		left join T0040_CURRENCY_MASTER CMT WITH (NOLOCK) ON  CLD.Curr_ID=CMT.Curr_ID  --Added by Rajput on 16032018
		where CL.Claim_Apr_Date>=@From_Date  and CL.Claim_Apr_Date<=@To_Date
		and CL.Cmp_ID=@Cmp_ID

	END						

DROP TABLE #EMP_SCHEME			
			

Return




