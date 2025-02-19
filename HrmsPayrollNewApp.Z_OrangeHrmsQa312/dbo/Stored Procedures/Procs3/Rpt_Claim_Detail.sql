
CREATE PROCEDURE [dbo].[Rpt_Claim_Detail]  
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
	,@Cat_ID        numeric = 0,@is_column		tinyint = 0
	,@Salary_Cycle_id  NUMERIC  = 0
	,@Segment_ID Numeric = 0 
	,@Vertical Numeric = 0 
	,@SubVertical Numeric = 0 
	,@subBranch Numeric = 0 
	,@PBranch_ID	varchar(max)= '' --Added By Jaina 03-10-2015
	,@PVertical_ID	varchar(max)= '' --Added By Jaina 03-10-2015
	,@PSubVertical_ID	varchar(max)= '' --Added By Jaina 03-10-2015
	,@PDept_ID varchar(max)=''  --Added By Jaina 03-10-2015
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
        
IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 03-10-2015
	set @PBranch_ID = null   	
	
if @PVertical_ID ='0' or @PVertical_ID = ''		--Added By Jaina 03-10-2015
	set @PVertical_ID = null

if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	--Added By Jaina 03-10-2015
	set @PsubVertical_ID = null
	
IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 03-10-2015
	set @PDept_ID = NULL	 
		
--Added By Jaina 03-10-2015 Start		
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
--Added By Jaina 03-10-2015 End
	
   
     
	CREATE table #Emp_Cons 
 (      
	Emp_ID numeric ,     
	Branch_ID numeric,
	Increment_ID numeric
	--Alpha_Emp_Code numeric    
 )            
         

	if @Constraint <> ''        
	 BEGIN	 
	   Insert Into #Emp_Cons(Emp_ID)        
	   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')         
	  END      
 ELSE        
	 BEGIN
			Insert Into #Emp_Cons      
		    select distinct emp_id,ve.branch_id,Increment_ID from V_Emp_Cons As VE
		    left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
			inner join 
							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= @To_Date
							GROUP BY emp_id) Qry
							on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
		       ON QrySC.eid = VE.Emp_ID
			where 
		    cmp_id=@Cmp_ID 
		   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   --and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grade_ID ,Grd_ID)      
		   --and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id ,isnull(QrySC.SalDate_id,0))  
		   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))       
		  --Added By Jaina 3-10-2015 Start   
		   and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') B Where cast(B.data as numeric)=Isnull(VE.Branch_ID,0))
		   and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(VE.Vertical_ID,0))
		   and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(VE.SubVertical_ID,0))
		   and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(VE.Dept_ID,0))
		   
		   --Added By Jaina 3-10-2015 End
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		      and Increment_Effective_Date <= @To_Date 
		      and 
                      ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date )						
						) 
						order by Emp_ID
						
			Delete From #Emp_Cons Where Increment_ID Not In
				(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
				Where Increment_effective_Date <= @to_date)
  END
		
	
	IF OBJECT_ID('tempdb..#Claim') IS NOT NULL
	BEGIN
		DROP TABLE #Claim
	END
	
	CREATE table #Claim
	(
		Emp_ID			numeric(18,0),
		Claim_Apr_ID	numeric(18,0),
		Claim_App_ID    numeric(18,0),
		For_date        varchar(max),
		Claim_type      varchar(255),
		Purpose	    varchar(255),
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
	CREATE table #Total_Claim
	(
		Clam_apr_ID_1   numeric(18,0),
		Emp_ID			numeric(18,0),
		Claim_Apr_ID	numeric(18,0),
		for_Date		datetime, --varchar(255),		
		Currency        varchar(255),
		Purpose     varchar(255),
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
		--clm.Claim_App_Amount as Claim_Amount,		
		--case when cast(clmst.Desig_Wise_Limit AS varchar(5)) ='1' then cast(cast(Clm.Claim_App_Amount as numeric(18,2)) as varchar(255)) + ' For ' + cast(cast(clm.Petrol_KM as numeric(18,2)) as varchar(255)) + ' KM' Else cast(cast(Clm.Claim_App_Amount as numeric(18,2)) as varchar(255)) End AS Claim_Amount, COMMENTED BY RAJPUT ON 17032018
		case when (cast(clmst.Desig_Wise_Limit AS varchar(5)) ='1' OR cast(clmst.Grade_Wise_Limit AS varchar(5)) ='1' OR cast(clmst.Branch_Wise_Limit AS varchar(5)) ='1') AND (cast(clmst.Claim_Type AS varchar(5)) ='1') then cast(cast(Clm.Claim_App_Amount as numeric(18,2)) as varchar(255)) + ' For ' + cast(cast(clm.Petrol_KM as numeric(18,2)) as varchar(255)) + ' KM' Else cast(cast(Clm.Claim_App_Amount as numeric(18,2)) as varchar(255)) End AS Claim_Amount,
		clm.Claim_Apr_Amount as Application_Amount_one,
		clm.Claim_App_Amount as Application_Amount,
		clm.Purpose AS Purpose ,cur.Curr_Name as Currency,
		clm.Claim_Apr_Dtl_ID,
		clm.Petrol_KM
		from 
		T0120_CLAIM_APPROVAL clmpr WITH (NOLOCK)
		inner join T0130_CLAIM_APPROVAL_DETAIL clm WITH (NOLOCK) on clm.Cmp_ID=clmpr.Cmp_ID and clm.Claim_Apr_ID=clmpr.Claim_Apr_ID and clm.Emp_ID=clmpr.Emp_ID
		inner join T0040_CLAIM_MASTER clmst WITH (NOLOCK) on clmst.Claim_ID=clm.Claim_ID
		left outer join T0040_CURRENCY_MASTER cur WITH (NOLOCK) on clm.Curr_ID= cur.Curr_ID
		where clm.Cmp_ID=@Cmp_ID and clmpr.Claim_Apr_Date between @From_Date and @To_Date
		and clm.Emp_ID in (select Emp_ID from #Emp_Cons) and clm.Claim_Status='A'
	--AND clmst.Desig_Wise_Limit=0

)


	INSERT into #Claim
	SELECT Emp_ID,Claim_Apr_ID,Claim_App_ID, for_date,Claim_type,Currency,LEFT (Purpose, 35) + '..',Claim_Amount,Curr_Rate,Application_Amount_one,Curr_Rate,Claim_Apr_Dtl_ID from cte --cte where  RANK = 1
			order BY for_date, Claim_type

			
	-- ,Purpose Left Function Added by Rajput on 17032018
	
--	;WITH cte2 AS 
-- (
--		select clm.Claim_App_ID,
--		clmpr.Claim_Apr_ID,
--		clm.Claim_Apr_Date as for_date,
--		clmpr.Claim_Apr_Comments,
--		clm.Claim_Apr_Code,
--		clm.Emp_ID,
--		clmpr.Claim_Apr_By,
--		clmpr.Claim_Apr_Deduct_From_Sal,
--		clm.Claim_Apr_Amount as TotalAmount,
--		clm.Claim_Status,		
--		clm.Claim_ID,
--		clm.Curr_ID,		
--		clm.Claim_Apr_Date, 
--		clmst.Claim_Name as Claim_type,
--		clm.Claim_Apr_Amount as Claim_apr_Amount,
--		clm.Curr_Rate as Curr_Rate,
--		clm.Petrol_KM  as Claim_Amount,		
--		0 as Application_Amount_one,
--		clm.Claim_App_Amount as Application_Amount,
--		clm.Purpose AS Description ,cur.Curr_Name as Currency,
--		clm.Claim_Apr_Dtl_ID,
--		clm.Petrol_KM
--		from
--		T0120_CLAIM_APPROVAL clmpr 
--		inner join T0130_CLAIM_APPROVAL_DETAIL clm on clm.Cmp_ID=clmpr.Cmp_ID and clm.Claim_Apr_ID=clmpr.Claim_Apr_ID and clm.Emp_ID=clmpr.Emp_ID
--		inner join T0040_CLAIM_MASTER clmst on clmst.Claim_ID=clm.Claim_ID
--		left outer join T0040_CURRENCY_MASTER cur on clm.Curr_ID= cur.Curr_ID
--		where clm.Cmp_ID=@Cmp_ID and clmpr.Claim_Apr_Date between @From_Date and @To_Date
--		and clm.Emp_ID in (select Emp_ID from #Emp_Cons) and clm.Claim_Status='A' 
--		and ISNULL(clmst.Desig_Wise_Limit,0) =1
--)



--	INSERT into #Claim
--	SELECT Emp_ID,Claim_Apr_ID,Claim_App_ID, for_date,'Petrol_KM',Currency,Description,Claim_Amount,Curr_Rate,Application_Amount_one,Curr_Rate,Claim_Apr_Dtl_ID from cte2
--	 --cte where  RANK = 1
--	 --where Claim_Apr_Dtl_Id not in(select Claim_Apr_Dtl_Id from #Claim)
--    order BY for_date,Claim_type


	insert into #Total_Claim
	SELECT row_number() over( order by Emp_ID,Claim_Apr_ID), Emp_ID,Claim_Apr_ID,for_Date,Purpose,Currency,Currency_Rate,Claim_Apr_Dtl_Id  from #Claim 			
			order BY for_date, Claim_type

	
	
	Declare @Claim_Name varchar(255)
	Declare @val nvarchar(max)
	declare @AD_NAME_DYN nvarchar(max)
	declare @Column nvarchar(max)
	set @Column =''
	
	--select * from #Claim
	CREATE table #new_temp
		(		
		for_date  datetime,
		Emp_ID  numeric(18,0),
		Label_name  nvarchar(max),
		Label_Amount  numeric(18,2)
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
					
					Set @Column = @Column + '[' + REPLACE(rtrim(ltrim(@Claim_Name)),' ','_') +']' + '#'
					
					fetch next from Claim_Cursor into @Claim_Name
				End
		close Claim_Cursor	
		deallocate Claim_Cursor		
			Declare @CTC_COLUMNS nvarchar(100)
			Declare @CTC_AD_FLAG varchar(1)
			Declare @Allow_Amount varchar(500)--numeric(18,2)
			Declare @Claim_Apr_Amount numeric(18,2)
			set @Claim_Apr_Amount =0
			
			

			Set @val = 'Alter table   #Total_Claim Add Approved_Amount varchar(255)'
			exec (@val);
			
		--select isnull(Amount,0) from #Claim  
		
		--SELECT   isnull(Amount,0)
	 --   ,LEFT(isnull(Amount,0), CHARINDEX('For', isnull(Amount,0)) - 1) AS GetTotal
	   
	 --   --,REPLACE(SUBSTRING(isnull(Amount,0), CHARINDEX('For', isnull(Amount,0)), LEN(isnull(Amount,0))), ',', '') AS [FirstName]
		--from #Claim  
		-- where CHARINDEX('For', isnull(Amount,0)) > 0
		--return
		
			
					
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
																  and Claim_Apr_Dtl_Id= @Claim_apr_ID --and CHARINDEX('For', isnull(Amount,0)) = 0
													
													--if exists (select 1 from #Claim WHere  Claim_Apr_Dtl_Id= @Claim_apr_ID and CHARINDEX('For', isnull(Amount,0)) = 0)
													--     Begin
													--		select @Allow_Amount=isnull(Amount,0) from #Claim  
													--			WHere  Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(claim_type)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  = @CTC_COLUMNS 
													--			  and Claim_Apr_Dtl_Id= @Claim_apr_ID and CHARINDEX('For', isnull(Amount,0)) = 0
													--      End
													--      Else
													--		Begin
													--			select @Allow_Amount=  LEFT(isnull(Amount,0), CHARINDEX('For', isnull(Amount,0)) - 1) 
													--			from #Claim 
													--			where Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(claim_type)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  = @CTC_COLUMNS 
													--			and Claim_Apr_Dtl_Id= @Claim_apr_ID and
													--			CHARINDEX('For', isnull(Amount,0)) > 0
													--		End
												--update    #Total_Claim set Medical = Medical + 0 where    #Total_Claim.Claim_Apr_Dtl_ID = 89
												--select @CTC_COLUMNS ,convert(nvarchar,isnull(@Allow_Amount,0))
													Set @val = 	'update    #Total_Claim set ' + @CTC_COLUMNS + ' =  ''' + convert(nvarchar,isnull(@Allow_Amount,0)) + ''' where    #Total_Claim.Claim_Apr_Dtl_ID = ' + convert(nvarchar,@Claim_apr_ID)
													
													EXEC (@val)	
													--print @val
													--set @Claim_Apr_Amount = @Claim_Apr_Amount + @Allow_Amount
												--update #new_temp set Label_Amount=@Allow_Amount
												end
											
												Set @Allow_Amount = 0
												
										end
										
									fetch next from CRU_COLUMNS into @CTC_COLUMNS
								End
					close CRU_COLUMNS	
					deallocate CRU_COLUMNS										
						
						
					
						Update  #Total_Claim set Approved_Amount = C.Amount
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
		
		
		set @Column=@Column+'Purpose'+'#'+'Currency'+'#'+'Currency_Rate'+'#'+'Approved_Amount'+'#'--+'PetrolKM'+'#'
		
		
		
		--print @Column
		
		DECLARE @table_name SYSNAME
        SELECT @table_name = '#Total_Claim'
        
		
	
		declare @query as nvarchar(max)
		set @query =''
		
	--	alter table  #Total_Claim add Claim_apr_ID1 numeric(18,0) null
		
		
		If OBJECT_ID ('my_temp') Is not null
		BEGIN
			--Do Stuff
				drop table my_temp
				--print 'b'
		END
		
	
		
		DECLARE @SQL NVARCHAR(MAX)
				SELECT @SQL = '
				SELECT Emp_ID,for_Date,Clam_apr_ID_1 as Claim_apr_ID,Reim_Type,Amount into my_temp
				FROM ' + @table_name + ' 
				UNPIVOT (
					Amount FOR Reim_Type IN ( 
						' +  LEFT(replace(@Column,'#',','), LEN(replace(@Column,'#',','))-1)  + '
					) 
			 )  unpiv where Amount <> ''0.00'''
				 
			
			
		  EXEC(@SQL);
		  
		  UPDATE	my_temp
		  SET		AMOUNT = ''
		  WHERE		CAST(AMOUNT AS VARCHAR(128)) = '0'
		  
		
		  select	distinct EMP.Alpha_Emp_Code,EMP.Emp_ID,EMP.Emp_Full_Name
					,INC.BRANCH_ID --Added By Nimesh 11-Jul-2015 (To filter by multiple branch)
					,cm.Claim_Name--added by mansi
		  from		T0080_EMP_MASTER EMP WITH (NOLOCK) inner join #Emp_Cons EC on Emp.Emp_ID = EC.Emp_ID 
					inner join #Total_Claim TC on EC.Emp_ID =TC.Emp_ID
						--added by mansi start
						left join T0100_CLAIM_APPLICATION cd on cd.Emp_ID=Emp.emp_id
						left  join T0040_CLAIM_MASTER cm on cm.Claim_ID=Cd.Claim_ID 
						--added by mansi end
					LEFT OUTER JOIN (
										SELECT	EMP_ID, BRANCH_ID FROM T0095_INCREMENT I WITH (NOLOCK)
										WHERE	Increment_Effective_Date=(SELECT	MAX(Increment_Effective_Date)
																		  FROM		T0095_INCREMENT I1 WITH (NOLOCK)
																		  WHERE		I1.Cmp_ID=I.Cmp_ID AND I1.Emp_ID=I.Emp_ID
																					AND I1.Increment_Effective_Date<= @To_Date
																		  )
												AND I.Cmp_ID=@Cmp_ID																					
									) INC ON EMP.EMP_ID=INC.EMP_ID
		  where		EMP.Cmp_ID=@Cmp_ID
		  
		
		
		update my_temp set Reim_Type = ' ' + Reim_Type Where Reim_Type <> 'Purpose' and Reim_Type <>'Currency' and Reim_Type <>'Approved_Amount' and Reim_Type <>'Currency_Rate' --and Reim_Type <>'Petrol_KM'
	-- Update my_temp set Reim_type=replace(Reim_type,'_',' ')
		
			IF EXISTS(SELECT 1 FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@CMP_ID AND Setting_Name='Hide Currency in Claim Application' AND Setting_Value=0) --ADDED BY RAJPUT ON 19032018
			BEGIN
				DELETE FROM my_temp WHERE Reim_Type='Currency_Rate'
			END
			
		
		select * --qry.Emp_ID,qry.Reim_Type,Qry.Amount
		 from (
							
		  select   
		  row_number() OVER (PARTITION BY E.Emp_Full_Name ORDER BY E.Emp_Full_Name DESC ) as rank,
		  E.Emp_Full_Name,
		  DT.Dept_Name,  
		  q.amount1,E.Alpha_Emp_Code as Emp_code,E.Emp_First_Name,C.* 
		  ,BM.Branch_Name                  --added jimit 10062015
		  ,Inc_Qry.Branch_ID
		  ,cm.Claim_Name,cd.Claim_App_Date  ----added by mansi 
		  --Added By Nimesh 11-Jul-2015 (To filter by multiple branch)
		  FROM my_temp C inner join 			  
		   (SELECT Emp_ID,SUM(cast(Amount as numeric(18,2))) as amount1 FROM my_temp where Reim_Type='Approved_Amount'
		     GROUP BY Emp_ID) q ON C.Emp_ID = q.Emp_ID inner join
			dbo.T0080_EMP_MASTER E WITH (NOLOCK) on C.Emp_ID = E.Emp_ID 
			INNER JOIN #Emp_Cons EC ON e.emp_id = Ec.emp_ID 
			--added by mansi start
			left join T0100_CLAIM_APPLICATION cd on cd.Emp_ID=e.emp_id
			left  join T0040_CLAIM_MASTER cm on cm.Claim_ID=Cd.Claim_ID 
			--added by mansi end
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
			
			
		
 
Return




