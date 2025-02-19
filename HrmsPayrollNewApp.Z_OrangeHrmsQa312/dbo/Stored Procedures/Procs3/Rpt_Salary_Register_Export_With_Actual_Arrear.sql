


---Author : Mihir Trivedi 
---Date : 26/04/2012
-- For Export Salary Register Report from Customised report format for arrear data
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[Rpt_Salary_Register_Export_With_Actual_Arrear]  
	@Company_id		numeric  
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
	,@is_column tinyint = 0
	,@Order_By		varchar(30) = 'Code' --Added by Jimit 28/9/2015 (To sort by Code/Name/Enroll No)
AS   
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	Declare @Basic_Salary As Numeric(22,2)	
	Declare @Net_Salary As Numeric(22,2)		
	Declare @Total_CTC As Numeric(22,2)	
	  
 
 	IF @Branch_ID = 0  
		set @Branch_ID = null   
	 If @Grade_ID = 0  
		 set @Grade_ID = null  
	 If @Emp_ID = 0  
		set @Emp_ID = null  
	 If @Desig_ID = 0  
		set @Desig_ID = null  
     If @Dept_ID = 0  
		set @Dept_ID = null 
     If @Cat_ID = 0
        set @Cat_ID = null
   
    
 Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin			
			Insert Into @Emp_Cons(Emp_ID)
			select  cast(Emp.Data  as numeric) from dbo.Split (@Constraint,'#') Emp
			Inner Join dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Emp_ID =  cast(Emp.Data  as numeric)
			where  ms.Is_FNF = 0 and ms.Month_St_Date >= @From_Date and ms.Month_End_Date <= @To_Date 
		end
	else
		begin
			Insert Into @Emp_Cons

				select I.Emp_Id from dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Company_id
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	 Inner join
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on i.emp_ID = E.Emp_ID Inner Join
						dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Emp_ID = E.Emp_ID 						
					Where E.CMP_ID = @Company_id 
					and i.BRANCH_ID = isnull(@BRANCH_ID ,i.BRANCH_ID)
					and i.Grd_ID = isnull(@Grade_ID ,i.Grd_ID)
					and isnull(i.Dept_ID,0) = isnull(@Dept_ID ,isnull(i.Dept_ID,0))			
					and Isnull(i.Desig_ID,0) = isnull(@Desig_ID ,Isnull(i.Desig_ID,0))			
					and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0))
					and ISNULL(I.Cat_ID,0) = ISNULL(@Cat_ID, ISNULL(I.Cat_ID,0))
					and ms.Month_St_Date >= @From_Date and ms.Month_End_Date <= @To_Date
					and ms.Is_FNF = 0
					and Date_Of_Join <= @To_Date and I.emp_id in(
						select e.Emp_Id from
						(select e.emp_id, e.cmp_id, Date_Of_Join, isnull(Emp_left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
						where cmp_id = @Company_id   and  
						(( @From_Date  >= Date_Of_Join  and  @From_Date <= Emp_left_date ) 
						or ( @to_Date  >= Date_Of_Join  and @To_Date <= Emp_left_date )
						or Emp_left_date is null and @To_Date >= Date_Of_Join)
						or @To_Date >= Emp_left_date  and  @From_Date <= Emp_left_date )  
			
		end
	
	
		 
	CREATE table #CTCMast
	(
		
	    Cmp_ID			numeric(18,0)
	   ,Emp_ID			numeric(18,0) primary key
	   ,Emp_code		varchar(100)
	   ,Emp_Full_Name	varchar(250)
	   ,Branch			nvarchar(100)
	   ,Deptartment		nvarchar(100)
	   ,Designation		nvarchar(100)
	   ,Grade			nvarchar(100)
	   ,TypeName		nvarchar(100)	
	   ,Joining_Date	nvarchar(30)
	   ,Arrear_Day      numeric(18,0)
	   ,Arrear_Month    varchar(50)	  -- Added By Ali 14122013
	   ,Arrear_Year		numeric(18,0) -- Added By Ali 14122013 
	   ,Desig_dis_No    numeric(18,0) DEFAULT 0  --added jimit 28/9/2015
	   ,Enroll_No       VARCHAR(50)	DEFAULT ''	--added jimit 28/9/2015	 
	)
	
	Declare @AllColumns nvarchar(Max)
	
	Declare @Columns nvarchar(max)	
	Set @Columns = '#'
	set @AllColumns = ''	
	
	Declare @CTC_CMP_ID numeric(18,0)
	Declare @CTC_EMP_ID numeric(18,0)	
    Declare @Arrear_Day numeric(18,0)
	Declare @CTC_COLUMNS nvarchar(100)
	Declare @CTC_AD_FLAG varchar(1)
	Declare @Allow_Amount numeric(18,2)
			
	Declare @Allow_Amount_Arrear numeric(18,2)
	Declare @Basic_Salary_Arrear Numeric(18,2)	
		
	Declare @AD_NAME_DYN nvarchar(100)
	declare @val nvarchar(500)
	declare @count_leave as numeric(18,2)
		
	set @Basic_Salary_Arrear = 0
	set @Allow_Amount_Arrear =0
	
	
	
	Insert Into #CTCMast 
	SELECT e.Cmp_ID,e.Emp_ID,e.Alpha_Emp_Code
	,ISNULL(e.EmpName_Alias_Salary,e.Emp_First_Name + ' ' + e.Emp_Last_Name) -- Added By Ali 14122013
	,bm.Branch_Name,dm.Dept_Name,dnm.Desig_Name,ga.Grd_Name,tm.Type_Name,convert(varchar,e.Date_Of_Join,103),0
	,convert(char(20),DATENAME(mm,DATEADD(mm,MPI.Extra_Day_Month,-1)), 0)	-- Added By Ali 14122013
	,MPI.Extra_Day_Year -- Added By Ali 14122013
	,dnm.Desig_Dis_No,E.Enroll_No --added jimit 28/9/2015	 
		from T0080_EMP_MASTER e	WITH (NOLOCK) inner join
		( select I.Emp_id,I.Basic_Salary,I.CTC,I.Branch_Id,I.Grd_ID,I.Dept_ID,I.Desig_Id,I.Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 11092014 for Same Date Increment
			where Increment_Effective_date <= @To_Date
			and cmp_id = @Company_id
			group by emp_ID  ) Qry on
			I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID 
	inner join @Emp_Cons ec on e.Emp_ID = ec.Emp_ID
	left outer join T0030_BRANCH_MASTER bm WITH (NOLOCK) on Inc_Qry.Branch_ID = bm.Branch_ID
	left outer join T0040_GRADE_MASTER ga WITH (NOLOCK) on Inc_Qry.Grd_ID = ga.Grd_ID
	left outer join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on Inc_Qry.Dept_ID = dm.Dept_Id
	left outer join T0040_DESIGNATION_MASTER dnm WITH (NOLOCK) on Inc_Qry.Desig_Id = dnm.Desig_ID
	left outer join T0040_TYPE_MASTER tm WITH (NOLOCK) on Inc_Qry.Type_ID = tm.Type_ID
	inner join T0190_MONTHLY_PRESENT_IMPORT MPI WITH (NOLOCK) on MPI.Emp_ID = e.Emp_ID 
	And MPI.Month = MONTH(@To_Date) AND MPI.Year = YEAR(@To_Date) 	-- Added By Ali 14122013

print @To_Date
	set @AllColumns = @AllColumns + @Columns
	Set @Columns = ''	
	
		
		Set @val = 'Alter table  #CTCMast Add Basic_Salary_Arrear numeric(18,2) default 0 not null'
		exec (@val)	
	
	DECLARE Allow_Dedu_Cursor CURSOR FOR
		Select AD_SORT_NAME from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id and month(T.For_Date) =  MONTH(@From_Date) and Year(T.For_Date) = YEAR(@From_Date)
				and isnull(T.M_Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I'
		Group by AD_SORT_NAME 
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin					
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+',''),'''',''),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table  #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + '_Arrear numeric(18,2) default 0  not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '_Arrear#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
		
	Declare Allow_Dedu_Cursor CURSOR FOR
				Select AD_SORT_NAME from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id and month(T.For_Date) =  MONTH(@From_Date) and Year(T.For_Date) = YEAR(@From_Date)
				and isnull(T.M_Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'D'
		Group by AD_SORT_NAME 
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+',''),'''','_'),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + '_Arrear numeric(18,2) default 0  not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '_Arrear#'
					
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
	
		if @is_column = 1 
			begin 
				select * from #CTCMast
				return
			end
				
	
	set @AllColumns = @AllColumns + @Columns	
	
	
	
	Declare CTC_UPDATE CURSOR FOR
		select Cmp_Id,Emp_Id from #CTCMast
	OPEN CTC_UPDATE
	fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID
	while @@fetch_status = 0
		Begin							
			
			set @Basic_Salary_Arrear = 0
			set @Arrear_Day = 0
			Set @Net_Salary  = 0	
						
			select @Arrear_Day = Arear_Day, @Basic_Salary_Arrear = Arear_Basic 
			from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @CTC_EMP_ID and Month(Month_st_date) = Month(@From_Date) 
				and Year(Month_st_date) = Year(@From_Date)
						
									
			update  #CTCMast set Arrear_Day = @Arrear_Day, Basic_Salary_arrear =  @Basic_Salary_Arrear 		 
			where #CTCMast.Cmp_ID = @CTC_CMP_ID and #CTCMast.Emp_ID = @CTC_EMP_ID			
			
			
			Declare CRU_COLUMNS CURSOR FOR
				Select data from Split(@Columns,'#') where data <> ''
			OPEN CRU_COLUMNS
					fetch next from CRU_COLUMNS into @CTC_COLUMNS
					while @@fetch_status = 0
						Begin					
								begin										
										Set @CTC_COLUMNS = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@CTC_COLUMNS)),'+',''),'''',''),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
																				
										begin
											declare @not_effect_in_salary tinyint
											set @not_effect_in_salary = 1
											
											select @Allow_Amount=ded.M_AD_Amount,@CTC_AD_FLAG=ded.M_AD_Flag , @Allow_Amount_Arrear = isnull(M_AREAR_AMOUNT,0) , @not_effect_in_salary = ad.AD_NOT_EFFECT_SALARY from T0210_MONTHLY_AD_DETAIL  ded WITH (NOLOCK)
												inner join T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id
												WHere  Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_Sort_Name)),'+',''),'''',''),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')  = Replace(@CTC_COLUMNS,'_Arrear','') and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID
												And MONTH(ded.For_Date) = MONTH(@From_Date) And YEAR(ded.For_Date) = YEAR(@From_Date)
																																	
											Set @val = ''
											if @not_effect_in_salary = 0 
												begin																
													if @CTC_AD_FLAG = 'I'
														begin
															Set @val = 	'update  #CTCMast set ' +  @CTC_COLUMNS  + ' = ' + convert(nvarchar,isnull(@Allow_Amount_Arrear,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)														
														end
													else if  @CTC_AD_FLAG = 'D'
														begin
															Set @val = 	'update  #CTCMast set ' +  @CTC_COLUMNS  + ' = ' + convert(nvarchar,isnull(@Allow_Amount_Arrear,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)																													
														end
												end
											else  if charindex('_Arrear',@CTC_COLUMNS) = 0
												begin
													Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS + ' = ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)																														
												end									
											
											EXEC (@val)								   											
										end										
										Set @Allow_Amount = 0										
								end								
							fetch next from CRU_COLUMNS into @CTC_COLUMNS
						End
			close CRU_COLUMNS	
			deallocate CRU_COLUMNS	
	
		fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID
	End
	close CTC_UPDATE	
	deallocate CTC_UPDATE	
	
	select * from #CTCMast
	Order by CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(#CTCMast.Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start
							WHEN @Order_By='Name' THEN #CTCMast.Emp_Full_Name
							When @Order_By = 'Designation' then (CASE WHEN #CTCMast.Desig_dis_No  = 0 THEN #CTCMast.Designation ELSE RIGHT(REPLICATE('0',21) + CAST(#CTCMast.Desig_dis_No AS VARCHAR), 21)   END)   
							--ELSE RIGHT(REPLICATE(N' ', 500) + CM.EMP_CODE, 500) 
						End,Case When IsNumeric(Replace(Replace(#CTCMast.Emp_code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(#CTCMast.Emp_code,'="',''),'"',''), 20)
								 When IsNumeric(Replace(Replace(#CTCMast.Emp_code,'="',''),'"','')) = 0 then Left(Replace(Replace(#CTCMast.Emp_code,'="',''),'"','') + Replicate('',21), 20)
								 Else Replace(Replace(#CTCMast.Emp_code,'="',''),'"','') End
	print @To_Date
	
	--Select ROW_NUMBER()  OVER (ORDER BY  MS.Emp_Id) As SrNo,CM.*,MS.Salary_Status From #CTCMast CM 
	--		Inner join T0200_MONTHLY_SALARY MS on CM.Emp_ID = MS.Emp_ID 	
	--		inner join T0095_INCREMENT INC on INC.Increment_ID = MS.Increment_id
	--where Month(MS.Month_End_Date) = Month(@To_Date) and Year(MS.Month_end_date) = Year(@To_Date) and CM.Arrear_Day <> 0
	--Order by CM.Emp_code

	Select ROW_NUMBER()  OVER (ORDER BY  MS.Emp_Id) As SrNo,CM.*,MS.Salary_Status From #CTCMast CM 
			Inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on CM.Emp_ID = MS.Emp_ID 	
			inner join T0095_INCREMENT INC WITH (NOLOCK) on INC.Increment_ID = MS.Increment_id
	where Month(MS.Month_End_Date) = Month(@To_Date) and Year(MS.Month_end_date) = Year(@To_Date) and CM.Arrear_Day <> 0
	Order by CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(Cm.Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start
							WHEN @Order_By='Name' THEN CM.Emp_Full_Name
							When @Order_By = 'Designation' then (CASE WHEN CM.Desig_dis_No  = 0 THEN CM.Designation ELSE RIGHT(REPLICATE('0',21) + CAST(CM.Desig_dis_No AS VARCHAR), 21)   END)   
							--ELSE RIGHT(REPLICATE(N' ', 500) + CM.EMP_CODE, 500) 
						End,Case When IsNumeric(Replace(Replace(CM.Emp_code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(CM.Emp_code,'="',''),'"',''), 20)
								 When IsNumeric(Replace(Replace(CM.Emp_code,'="',''),'"','')) = 0 then Left(Replace(Replace(CM.Emp_code,'="',''),'"','') + Replicate('',21), 20)
								 Else Replace(Replace(CM.Emp_code,'="',''),'"','') End
						--RIGHT(REPLICATE(N' ', 500) + CM.EMP_CODE, 500) 

		
Return




