

CREATE PROCEDURE [DBO].[Rpt_Salary_Allowance_Deduction]  
	@Cmp_id		numeric  
	,@From_Date		datetime
	,@To_Date 		datetime
	--,@Branch_ID		numeric	
	--,@Grd_ID 		numeric
	--,@Type_ID 		numeric
	--,@Dept_ID 		numeric
	--,@Desig_ID 		numeric
	,@Branch_ID		varchar(max)=''  --Added By Jaina 3-11-2015 Start
	,@Grd_ID 		varchar(max)=''
	,@Type_ID 		varchar(max)=''
	,@Dept_ID 		varchar(max)=''
	,@Desig_ID 		varchar(max)=''  --Added By Jaina 3-11-2015 End
	,@Emp_ID 		numeric
	,@Constraint	varchar(max)
	,@Cat_ID		varchar(max)=''   --Added By Jaina 3-11-2015 
	,@AD_ID			numeric 
	--,@SelectionType numeric
	,@Salary_Cycle_id numeric = NULL
	--,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 17082013
	--,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 17082013
	--,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 17082013	
	--,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 17082013	
	,@Segment_Id  varchar(max)=''  --Added By Jaina 3-11-2015 Start
	,@Vertical_Id varchar(max)=''
	,@SubVertical_Id varchar(max)=''
	,@SubBranch_Id varchar(max)=''  --Added By Jaina 3-11-2015 End
AS  


 
 Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	Declare @Actual_From_Date datetime
	Declare @Actual_To_Date datetime
	
	Declare @P_Days as numeric(22,2)
	Declare @Basic_Salary As Numeric(22,2)
	Declare @TDS As Numeric(22,2)
	Declare @Settl As Numeric(22,2)
	Declare @OTher_Allow As Numeric(22,2)
	Declare @Total_Allowance As Numeric(22,2)
	Declare @CO_Amount As Numeric(22,2)
	Declare @Total_Deduction As Numeric(22,2)
	Declare @PT As Numeric(22,2)
	Declare @Loan As Numeric(22,2)
	Declare @Advance As Numeric(22,2)	
	Declare @Net_Salary As Numeric(22,2)	
	Declare @Revenue_Amt As Numeric(22,2)	
	Declare @LWF_Amt As Numeric(22,2)	
	Declare @Other_Dedu As Numeric(22,2)	
	
	--Alpesh 25-Nov-2011
	Declare @Absent_Day numeric(18,2)
	Declare @Holiday_Day numeric(18,2)
	Declare @WeekOff_Day numeric(18,2)
	Declare @Leave_Day numeric(18,2)
	Declare @Sal_Cal_Day numeric(18,2)
   
	set @Actual_From_Date = @From_Date
	set @Actual_To_Date = @To_Date
	
 	IF @Branch_ID = '0' or @Branch_ID = ''
		set @Branch_ID = null   
	 If @Grd_ID = '0'  or @Grd_ID=''
		 set @Grd_ID = null  
	 If @Emp_ID = 0  
		set @Emp_ID = null  
	 If @Desig_ID = '0'  or @Desig_ID=''
		set @Desig_ID = null  
     If @Dept_ID = '0' or @Dept_ID='' 
		set @Dept_ID = null 
	IF @Cat_ID = '0' or @Cat_ID=''
		Set @Cat_ID = NULL	
	
	If @Salary_Cycle_id = 0	 -- Added By Gadriwala Muslim 17082013
	set @Salary_Cycle_id = null	
	If @Segment_Id = '0' or @Segment_Id=''		 -- Added By Gadriwala Muslim 17082013
	set @Segment_Id = null
	If @Vertical_Id = '0' or @Vertical_Id=''		 -- Added By Gadriwala Muslim 17082013
	set @Vertical_Id = null
	If @SubVertical_Id = '0' or @SubVertical_Id='' 	 -- Added By Gadriwala Muslim 17082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = '0' or @SubBranch_Id=''	 -- Added By Gadriwala Muslim 17082013
	set @SubBranch_Id = null	
	
   
   
	CREATE TABLE #Emp_Cons  -- Ankit 05092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 --Comment by Jaina 3-11-2015
	 --EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
	 exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'',0,0    	

 --Declare #Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	
	
		
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons(Emp_ID)
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
	--		Insert Into #Emp_Cons

	--			select distinct I.Emp_Id from dbo.T0095_INCREMENT I inner join 
	--					( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_INCREMENT
	--					where Increment_Effective_date <= @To_Date
	--					and Cmp_ID = @Cmp_id
	--					group by emp_ID  ) Qry on
	--					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	 Inner join
	--					dbo.T0080_EMP_MASTER E on i.emp_ID = E.Emp_ID Inner Join
	--					dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = E.Emp_ID 						
	--				Where E.CMP_ID = @Cmp_id 
	--				and i.BRANCH_ID = isnull(@BRANCH_ID ,i.BRANCH_ID)
	--				and i.Grd_ID = isnull(@Grd_ID ,i.Grd_ID)
	--				and isnull(i.Dept_ID,0) = isnull(@Dept_ID ,isnull(i.Dept_ID,0))			
	--				and Isnull(i.Desig_ID,0) = isnull(@Desig_ID ,Isnull(i.Desig_ID,0))			
	--				and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0))
	--				and ISNULL(I.Segment_ID,0) = ISNULL(@Segment_Id,Isnull(I.Segment_ID,0))	 -- Added By Gadriwala Muslim 17082013
	--				and ISNULL(I.Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(I.Vertical_ID,0))	 -- Added By Gadriwala Muslim 17082013
	--				and ISNULL(I.SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(I.SubVertical_ID,0)) -- Added By Gadriwala Muslim 17082013
	--				and ISNULL(I.subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(I.subBranch_ID,0)) -- Added By Gadriwala Muslim 17082013
			
	--				and ms.Month_St_Date >= @From_Date and ms.Month_End_Date <= @To_Date
	--				and ms.Is_FNF = 0
	--				and Date_Of_Join <= @To_Date and I.emp_id in(
	--					select e.Emp_Id from
	--					(select e.emp_id, e.cmp_id, Date_Of_Join, isnull(Emp_left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--					where cmp_id = @Cmp_id   and  
	--					(( @From_Date  >= Date_Of_Join  and  @From_Date <= Emp_left_date ) 
	--					or ( @to_Date  >= Date_Of_Join  and @To_Date <= Emp_left_date )
	--					or Emp_left_date is null and @To_Date >= Date_Of_Join)
	--					or @To_Date >= Emp_left_date  and  @From_Date <= Emp_left_date )  
			
	--	end
	
			
	CREATE table #CTCMast
	(
		
	    Cmp_ID			numeric(18,0)
	   ,Emp_ID			numeric(18,0) primary key
	   ,Emp_code		numeric(18,0)
	   ,Alpha_Emp_Code	varchar(50)
	   ,Emp_Full_Name	varchar(250)
	   ,Branch			nvarchar(100)
	   ,Deptartment		nvarchar(100)
	   ,Designation		nvarchar(100)
	   ,Grade			nvarchar(100)
	   ,TypeName		nvarchar(100)	
	   ,Basic_Salary	numeric(18,2)
	   
	)
	
	CREATE table #Allow_Dedu
	(
	    Cmp_ID			numeric(18,0)
	   ,Emp_ID			numeric(18,0) 
	   ,Alpha_Emp_Code	varchar(50)
	   ,Emp_Full_Name	varchar(250)
	   ,Allow_Name		varchar(100)
	   ,Allow_Amount	numeric(18,2)
	   ,Allow_Type		varchar(1)			
	)
	
	Declare @Columns nvarchar(4000)
	Set @Columns = '#'
	
	-- Changed By Ali 22112013 EmpName_Alias
	Insert Into #CTCMast 
	SELECT e.Cmp_ID,e.Emp_ID,e.Emp_code,e.Alpha_Emp_Code
	--,e.Emp_First_Name+' '+e.Emp_Last_Name
	,ISNULL(e.EmpName_Alias_Salary,e.Emp_First_Name + ' ' + e.Emp_Last_Name)
	,bm.Branch_Name,dm.Dept_Name,dnm.Desig_Name,ga.Grd_Name,tm.Type_Name,
		 0
		from T0080_EMP_MASTER e	inner join
		( select I.Emp_id,I.Basic_Salary,I.CTC from T0095_Increment I inner join 
			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
			where Increment_Effective_date <= @To_Date
			and cmp_id = @Cmp_id
			group by emp_ID  ) Qry on
			I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID 
	inner join #Emp_Cons ec on e.Emp_ID = ec.Emp_ID
	left outer join T0030_BRANCH_MASTER bm on e.Branch_ID = bm.Branch_ID
	left outer join T0040_GRADE_MASTER ga on e.Grd_ID = ga.Grd_ID
	left outer join T0040_DEPARTMENT_MASTER dm on e.Dept_ID = dm.Dept_Id
	left outer join T0040_DESIGNATION_MASTER dnm on e.Desig_Id = dnm.Desig_ID
	left outer join T0040_TYPE_MASTER tm on e.Type_ID = tm.Type_ID
	
	
	Declare @CTC_CMP_ID numeric(18,0)
	Declare @CTC_EMP_ID numeric(18,0)
	Declare @CTC_BASIC numeric(18,2)
	Declare @CTC_Alpha_Code varchar(50)
	Declare @CTC_Emp_Name varchar(250)


	
	Declare @AD_NAME_DYN nvarchar(100)
	declare @val nvarchar(500)
	
	
			
	DECLARE Allow_Dedu_Cursor CURSOR FOR
		--Select AD_SORT_NAME from T0210_MONTHLY_AD_DETAIL T Inner Join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		--Where M_AD_Amount > 0 And T.Cmp_ID = @Cmp_id and month(T.For_Date) =  MONTH(@From_Date) and Year(T.For_Date) = YEAR(@From_Date)
		--		and isnull(A.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I'
		--Group by AD_SORT_NAME 
		Select AD_SORT_NAME from T0210_MONTHLY_AD_DETAIL T Inner Join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount > 0 And T.Cmp_ID = @Cmp_id --and month(T.For_Date) >=  MONTH(@From_Date) and Year(T.For_Date) >= YEAR(@From_Date) and month(T.For_Date) <=  MONTH(@To_Date) and Year(T.For_Date) <= YEAR(@To_Date)
				and T.For_Date between @From_Date and @To_Date
				and isnull(A.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I'
		Group by AD_SORT_NAME 
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
					
					--Set @AD_NAME_DYN = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					--Changes done by Mihir 16102011 add / special charecter and Comment above Line
					  Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')
					-- End of Changes done by mihir...
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0 not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor

		----Set @val = 'Alter table  #CTCMast Add Gross_Salary numeric(18,2) default 0 not null'
		----exec (@val)	
	
		Set @val = 'Alter table  #CTCMast Add PT_Amount numeric(18,2) default 0 not null'
		exec (@val)	
	
		----Set @val = 'Alter table  #CTCMast Add Loan_Amount numeric(18,2) default 0 not null'
		----exec (@val)	

		----Set @val = 'Alter table  #CTCMast Add Advance_Amount numeric(18,2) default 0 not null'
		----exec (@val)	

		
	
	Declare Allow_Dedu_Cursor CURSOR FOR
		--		Select AD_SORT_NAME from T0210_MONTHLY_AD_DETAIL T Inner Join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		--Where M_AD_Amount > 0 And T.Cmp_ID = @Cmp_id and month(T.For_Date) =  MONTH(@From_Date) and Year(T.For_Date) = YEAR(@From_Date)
		--		and isnull(A.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'D'
		--Group by AD_SORT_NAME
			Select AD_SORT_NAME from T0210_MONTHLY_AD_DETAIL T Inner Join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount > 0 And T.Cmp_ID = @Cmp_id --and month(T.For_Date) >=  MONTH(@From_Date) and Year(T.For_Date) >= YEAR(@From_Date) and month(T.For_Date) <=  MONTH(@To_Date) and Year(T.For_Date) <= YEAR(@To_Date)
				and T.For_Date between @From_Date and @To_Date
				and isnull(A.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'D'
		Group by AD_SORT_NAME  
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0 not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
					
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor

		--Set @val = 'Alter table  #CTCMast Add Revenue_Amount numeric(18,2) default 0 not null'
		--exec (@val)	

		--Set @val = 'Alter table  #CTCMast Add LWF_Amount numeric(18,2) default 0  not null'
		--exec (@val)	

		--Set @val = 'Alter table  #CTCMast Add Other_Dedu numeric(18,2) default 0 not null'
		--exec (@val)	

		--Set @val = 'Alter table  #CTCMast Add Total_Deduction numeric(18,2) default 0 not null'
		--exec (@val)	

		--Set @val = 'Alter table  #CTCMast Add Net_Amount numeric(18,2) default 0 not null'
		--exec (@val)	
	
		
	
	Declare CTC_UPDATE CURSOR FOR
		select Cmp_Id,Emp_Id,Basic_Salary,Alpha_Emp_Code,Emp_Full_Name from #CTCMast
	OPEN CTC_UPDATE
	fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID,@CTC_BASIC,@CTC_Alpha_Code,@CTC_Emp_Name
	while @@fetch_status = 0
		Begin	
			
			
			Set @P_Days =0 
			Set @Basic_Salary =0
			Set @TDS = 0
			Set @Settl  = 0
			Set @OTher_Allow  = 0
			Set @Total_Allowance  = 0
			Set @CO_Amount  = 0
			Set @Total_Deduction  = 0
			Set @PT  = 0
			Set @Loan  = 0
			Set @Advance  = 0	
			Set @Net_Salary  = 0	
			Set @Revenue_Amt  = 0	
			Set @LWF_Amt  = 0	
			Set @Other_Dedu  = 0	

			Set @Absent_Day = 0 
			Set @Holiday_Day = 0
			Set @WeekOff_Day = 0
			Set @Leave_Day = 0
			Set @Sal_Cal_Day = 0
			
			Declare @CTC_COLUMNS nvarchar(100)
			Declare @CTC_AD_FLAG varchar(1)
			Declare @Allow_Amount numeric(18,2)
			
			set @CTC_AD_FLAG = ''
			
			--Set @From_Date = @Actual_From_Date
			--set @To_Date = dateadd(dd,-1,DATEADD(mm,1,@Actual_From_Date))
			
									
			--while @To_Date <= @Actual_To_Date 
			--	Begin	
			
					-- yearly change done by mitesh on 28032012
							
					--select @Basic_Salary = sum(Salary_Amount),@P_Days=sum(Present_Days),@Absent_Day=sum(Absent_Days),@Holiday_Day=sum(Holiday_Days),@WeekOff_Day=sum(Weekoff_Days),@Leave_Day=sum(Total_Leave_Days),@Sal_Cal_Day=sum(Sal_Cal_Days),@TDS=sum(isnull(M_IT_TAX,0)),
					--	@Settl = sum(Isnull(Settelement_Amount,0)),@OTher_Allow = sum(ISNULL(Other_Allow_Amount,0)),
					--	@Total_Allowance = sum(Isnull(Allow_Amount,0))
					--from T0200_MONTHLY_SALARY where Emp_ID = @CTC_EMP_ID 
					--	--and Month(Month_st_date) = Month(@From_Date) and Year(Month_st_date) = Year(@From_Date)
					--	and Month_st_date between @From_Date and @To_Date
					--	group by Emp_ID
					
					--select @Total_Deduction = sum(Total_Dedu_Amount) ,@PT = sum(PT_Amount) ,@Loan =  sum(( Loan_Amount + Loan_Intrest_Amount ) )
					--		,@Advance =  sum(Isnull(Advance_Amount,0)) ,@Net_Salary = sum(Net_Amount) ,@Revenue_Amt = sum(Isnull(Revenue_amount,0)),@LWF_Amt =sum(Isnull(LWF_Amount,0)),@Other_Dedu= sum(Isnull(Other_Dedu_Amount,0))
					--from T0200_Monthly_salary where Emp_ID = @CTC_EMP_ID 
					--		--and Month(Month_st_date) = Month(@From_Date) and Year(Month_st_date) = Year(@From_Date)
					--		and Month_st_date between @From_Date and @To_Date
					--		group by Emp_ID

					--update  #CTCMast set Basic_Salary = Basic_Salary + @Basic_Salary,Present_Day=Present_Day + @P_Days, Absent_Day= Absent_Day + @Absent_Day,Holiday_Day= Holiday_Day + @Holiday_Day,WeekOff_Day=WeekOff_Day + @WeekOff_Day,Leave_Day= Leave_Day + @Leave_Day,Sal_Cal_Day=Sal_Cal_Day + @Sal_Cal_Day,Settl_Salary = Settl_Salary  + @Settl,
					--	Other_Allow = Other_Allow + @OTher_Allow, Gross_Salary = Gross_Salary + (@Total_Allowance+@Basic_Salary+isnull(@Settl,0)+ISNULL(@OTher_Allow,0)+isnull(@CO_Amount,0)),
					--	Total_Deduction = Total_Deduction + @Total_Deduction, PT_Amount = PT_Amount + @PT,
					--	Loan_Amount = Loan_Amount +  @Loan, Advance_Amount = Advance_Amount + @Advance, Revenue_Amount = Revenue_Amount + @Revenue_Amt, LWF_Amount =LWF_Amount + @LWF_Amt,
					--	Other_Dedu =Other_Dedu + @Other_Dedu, Net_Amount =Net_Amount + @Net_Salary--,Total_Allowance = @Total_Allowance
					--where #CTCMast.Cmp_ID = @CTC_CMP_ID and #CTCMast.Emp_ID = @CTC_EMP_ID
					
				
					Declare CRU_COLUMNS CURSOR FOR
						Select data from Split(@Columns,'#') where data <> ''
					OPEN CRU_COLUMNS
							fetch next from CRU_COLUMNS into @CTC_COLUMNS
							while @@fetch_status = 0
								Begin					
										begin
												Set @CTC_COLUMNS = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@CTC_COLUMNS)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
																						
												begin
																																							
													select @Allow_Amount=sum(ded.M_AD_Amount),@CTC_AD_FLAG=ded.M_AD_Flag from T0210_MONTHLY_AD_DETAIL  ded
														inner join T0050_AD_MASTER ad on ded.AD_Id = ad.AD_Id
														WHere  Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_Sort_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  = @CTC_COLUMNS 
														and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID
														And MONTH(ded.For_Date) = MONTH(@From_Date) And YEAR(ded.For_Date) = YEAR(@From_Date)
														group by ded.M_AD_Flag , ded.EMP_ID , ded.AD_Id
													
													--Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS + ' = ' + @CTC_COLUMNS + ' + ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)
													--EXEC (@val)		
													if @CTC_AD_FLAG = ''
														begin
															select @CTC_AD_FLAG = AD_FLAG from T0050_AD_MASTER Where CMP_ID = @CTC_CMP_ID and Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(AD_Sort_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  = @CTC_COLUMNS 
														end
													
													
													Set @val = 	'Insert into #Allow_Dedu (cmp_id,Emp_id,Alpha_Emp_Code,Emp_Full_Name,Allow_Name,Allow_Amount,Allow_Type) values ( ' + convert(nvarchar,@CTC_CMP_ID) + ' , ' + convert(nvarchar,@CTC_EMP_ID) + ' , ''' + @CTC_Alpha_Code + ''' , ''' + @CTC_Emp_Name + ''' , ''' +  convert(nvarchar,replace(@CTC_COLUMNS,'_',' ')) + ''' , ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' , ''' + @CTC_AD_FLAG + ''' ) '
													
													EXEC (@val)		
													
													set @CTC_AD_FLAG = ''
																   
												end
												
												Set @Allow_Amount = 0
												
										end
										
									fetch next from CRU_COLUMNS into @CTC_COLUMNS
								End
					close CRU_COLUMNS	
					deallocate CRU_COLUMNS
					
					
			--Set @From_Date = DATEADD(mm,1,@From_Date)
			--set @To_Date = dateadd(dd,-1,DATEADD(mm,1,@From_Date))
					
			--End
					
	
	fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID,@CTC_BASIC,@CTC_Alpha_Code,@CTC_Emp_Name
				End
	close CTC_UPDATE	
	deallocate CTC_UPDATE
	
	--Select CM.*  from #CTCMast CM
	--Order by CM.Emp_code
	
	
	
	--Select CM.*,MS.Salary_Status From #CTCMast CM Inner join T0200_MONTHLY_SALARY MS on CM.Emp_ID = MS.Emp_ID 
	--	where Month(MS.Month_st_date) = Month(@From_Date) and Year(MS.Month_st_date) = Year(@From_Date)
	--Order by CM.Emp_code
	

		
	Select AD.* ,Cm.Cmp_Name , CM.Cmp_Address ,@From_Date as From_Date , @To_Date as To_Date 
			,CTm.Branch,CTm.Deptartment,CTm.Designation,CTm.Grade,CTm.TypeName  --added jimit 21/07/2016
			,em.Father_name,DAteName(M,GETDATE())as Month,YEar(GETDATE())as Year,DAteName(M,@To_Date)as To_Month,YEar(@To_Date)as To_Year--added by mansi 22-09-22
	from #Allow_Dedu AD
		Inner join T0010_COMPANY_MASTER CM on CM.Cmp_Id = AD.Cmp_ID
		Left JOIN #CTCMast CTM On Ctm.Emp_ID = Ad.Emp_ID and CTm.Cmp_ID = Ad.Cmp_ID
	Inner join T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Cmp_Id = AD.Cmp_ID and em.Emp_ID=ad.Emp_ID--added by mansi 22-09-22
	--select data from dbo.split(@Columns,'#') where data <> ''
Return




