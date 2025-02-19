

CREATE PROCEDURE [dbo].[Rpt_Salary_Register_Export_Format1]  
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
	,@is_column		tinyint = 0
	,@Salary_Cycle_id  NUMERIC  = 0
	,@Segment_ID Numeric = 0 
	,@Vertical Numeric = 0 
	,@SubVertical Numeric = 0 
	,@subBranch Numeric = 0 
	,@summary varchar(max)=''
	,@summary2 varchar(max)=''
	,@summary3 varchar(max)=''
	,@Type varchar(100) = '2'
	,@Order_By   varchar(30) = 'Code' --Added by Jimit 29/09/2015 (To sort by Code/Name/Enroll No)
	,@Show_Hidden_Allowance  bit = 1   --Added by Jaina 20-12-2016
	,@Report_type NUMERIC = 0 -- Added by Rajput on 22062018
AS  
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	
	set @Show_Hidden_Allowance = 0
	
		
	Declare @Actual_From_Date datetime
	Declare @Actual_To_Date datetime
	
	Declare @P_Days as numeric(22,2)
	Declare @Arear_Days as Numeric(18,2)
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
	--Declare @Leave_Day numeric(18,2) -- Added By Ali 18122013
	Declare @Sal_Cal_Day numeric(18,2)
	
	-- Rohit 26-sep-2012
	Declare @OT_Hours numeric(18,2)
	Declare @OT_Amount numeric(18,2)
	Declare @OT_Rate Numeric(18,2)
	declare @Fix_OT_Shift_Hours varchar(40)
	declare @Fix_OT_Shift_seconds numeric(18,2)
    Declare @Net_Round As Numeric(22,2)
    
	declare @Travel_Amount as numeric(18,2)
	
	
   
	set @Actual_From_Date = @From_Date
	set @Actual_To_Date = @To_Date
	
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
        
     If @Type_id = 0
        set @Type_id = null
        
        
     if @Salary_Cycle_id   = 0
		set @Salary_Cycle_id = null
		
	if @Segment_ID = 0 
		set @Segment_ID = NULL
		
	if @Vertical = 0 
		set @Vertical = NULL
		
	if @SubVertical = 0 
		set @SubVertical = NULL
	
	if @subBranch  = 0 
		set @subBranch = NULL

   -- Comment and added By rohit on 11022013
    Declare @Sal_St_Date   Datetime    
	 Declare @Sal_end_Date   Datetime   
	
	 declare @manual_salary_period as numeric(18,0)
	 set @manual_salary_period = 0
		
	 If @Branch_ID is null
			Begin 
				select Top 1 @Sal_St_Date  = Sal_st_Date,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
				  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @Company_id    
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Cmp_ID = @Company_id)    
			End
		Else
			Begin
				select @Sal_St_Date  =Sal_st_Date,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
				  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @Company_id and Branch_ID = @Branch_ID    
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Company_id)    
			End
			
		
   
	 if isnull(@Sal_St_Date,'') = ''    
		  begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			   --set @OutOf_Days = @OutOf_Days
		  end     
	 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
		  begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			   --set @OutOf_Days = @OutOf_Days    	         
		  end     
	 --else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
		--  begin 
		--	   if @manual_salary_period = 0   
		--			Begin
		--			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
		--			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
		--			  -- set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
			   
		--			   Set @From_Date = @Sal_St_Date
		--			   Set @To_Date = @Sal_End_Date
		--			End
		--		Else
		--			Begin
		--				select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@To_Date) and YEAR=year(@To_Date)
		--			--	set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
					   
		--				Set @From_Date = @Sal_St_Date
		--				Set @To_Date = @Sal_End_Date 
		--			End    
		--  end
    -- Ended By rohit on 11022013

	

 --Declare #Emp_Cons Table
 Create table #Emp_Cons 
	(
		Emp_ID	numeric ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC 
	)
	
		
	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			select CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
		
		
		INSERT INTO #Emp_Cons

			SELECT DISTINCT V.emp_id,branch_id,V.Increment_ID FROM V_Emp_Cons V 
			  Inner Join
						dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Emp_ID = V.Emp_ID 
			LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
														WHERE Effective_date <= @To_Date
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = V.Emp_ID
			WHERE 
		      V.cmp_id=@Company_id 				
		       AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))          
		       AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)      
		   AND Grd_ID = ISNULL(@Grade_ID ,Grd_ID)      
		   AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))      
		   AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))      
		   AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
		   AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))     
		   And ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,IsNull(Segment_ID,0))
		   And ISNULL(Vertical_ID,0) = ISNULL(@Vertical,IsNull(Vertical_ID,0))
		   And ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical,IsNull(SubVertical_ID,0))
		   And ISNULL(subBranch_ID,0) = ISNULL(@subBranch,IsNull(subBranch_ID,0)) -- Added on 06082013
		   and month(ms.Month_End_Date)  = month(@To_Date) and year(ms.Month_End_Date)  = year(@To_Date)
		   and ms.Is_FNF = 0
		   AND V.Emp_Id = ISNULL(@Emp_Id,V.Emp_Id) 
		      AND Increment_Effective_Date <= @To_Date 
		      AND 
                       ( (@From_Date  >= join_Date  AND  @From_Date <= left_date )      
						OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )      
						OR (Left_date IS NULL AND @To_Date >= Join_Date)      
						OR (@To_Date >= left_date  AND  @From_Date <= left_date )
						OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
						)
			 
			ORDER BY Emp_ID
						
			DELETE  FROM #Emp_Cons WHERE Increment_ID NOT IN (SELECT MAX(Increment_ID) FROM T0095_Increment WITH (NOLOCK)
				WHERE  Increment_effective_Date <= @to_date
				GROUP BY emp_ID )
				
			--Insert Into #Emp_Cons

			--	select distinct I.Emp_Id from dbo.T0095_INCREMENT I inner join 
			--			( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_INCREMENT
			--			where Increment_Effective_date <= @To_Date
			--			and Cmp_ID = @Company_id
			--			group by emp_ID  ) Qry on
			--			I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	 Inner join
			--			dbo.T0080_EMP_MASTER E on i.emp_ID = E.Emp_ID Inner Join
			--			dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = E.Emp_ID 						
			--		Where E.CMP_ID = @Company_id 
			--		and i.BRANCH_ID = isnull(@BRANCH_ID ,i.BRANCH_ID)
			--		and i.Grd_ID = isnull(@Grade_ID ,i.Grd_ID)
			--		and isnull(i.Dept_ID,0) = isnull(@Dept_ID ,isnull(i.Dept_ID,0))			
			--		and Isnull(i.Desig_ID,0) = isnull(@Desig_ID ,Isnull(i.Desig_ID,0))			
			--		and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0))
			--		and ISNULL(I.Cat_ID,0) = ISNULL(@Cat_ID, ISNULL(I.Cat_ID,0))
			--		and ms.Month_St_Date >= @From_Date and ms.Month_End_Date <= @To_Date
			--		and ms.Is_FNF = 0
			--		and Date_Of_Join <= @To_Date and I.emp_id in(
			--			select e.Emp_Id from
			--			(select e.emp_id, e.cmp_id, Date_Of_Join, isnull(Emp_left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
			--			where cmp_id = @Company_id   and  
			--			(( @From_Date  >= Date_Of_Join  and  @From_Date <= Emp_left_date ) 
			--			or ( @to_Date  >= Date_Of_Join  and @To_Date <= Emp_left_date )
			--			or Emp_left_date is null and @To_Date >= Date_Of_Join)
			--			or @To_Date >= Emp_left_date  and  @From_Date <= Emp_left_date )  
			
		end
	
		
	CREATE table #CTCMast
	(
		
	    Cmp_ID			numeric(18,0)
	   ,Emp_ID			numeric(18,0) primary key
	   ,Emp_code		numeric(18,0)	   
	   ,Alpha_Emp_Code	varchar(50)
	   ,Emp_Full_Name	varchar(250)
	   ,Branch			nvarchar(100)
	   ,Department		nvarchar(100)
	   ,Designation		nvarchar(100)
	   ,Grade			nvarchar(100)
	   ,TypeName		nvarchar(100)
	   ,Category		nvarchar(100)
	   ,Division		nvarchar(100)
	   ,sub_vertical	nvarchar(100)
	   ,sub_branch		nvarchar(100)
	   ,Aadhar_Card_No		Varchar(50)  --added By Jimit 15072017
	   ,Bank_Ac_No		Varchar(50)
	   ,Pan_No			Varchar(50)
	   ,PF_No			Varchar(50)
	   ,Segment_Name	nvarchar(100)
	   ,Center_Code     Varchar(50)  --added jimit 10082015
	   ,Desig_dis_No    numeric(18,0) DEFAULT 0  --added jimit 29/09/2015
	   ,Enroll_No       VARCHAR(50)	DEFAULT ''		 --added jimit 29/09/2015
	   ,Date_Of_Birth   VARCHAR(50)               --added by jimit 27/03/2017
	   ,Date_Of_Join	VARCHAR(50)			   --added by jimit 27/03/2017	  
	   ,Inc_Bank_Ac_NO  VARCHAR(50)				--added by jimit 06/09/2017	
	   ,Present_Day		numeric(18,2)
	   --,Arear_Day		Numeric(18,2)
	   ,Absent_Day		numeric(18,2)
	   ,Holiday_Day		numeric(18,2)
	   ,WeekOff_Day		numeric(18,2)
	   --,Leave_Day		numeric(18,2) -- Added By Ali 18122013
	   --,Sal_Cal_Day		numeric(18,2)
	   --,Actual_CTC		Numeric(18,0)
	   --,Basic_Salary	numeric(18,2)
	   --,Settl_Salary	Numeric(18,2)
	   --,Other_Allow		Numeric(18,2)
	   ,Branch_Id       Numeric(18,0)
	   ,City		Varchar(100) --Added by Hardik 19/06/2017 for Aculife
	   ,PinCode		Varchar(10) --Added by Hardik 19/06/2017 for Aculife
	   ,Date_Of_Left	VARCHAR(50) DEFAULT ''
	   
	)
	
	Declare @Columns nvarchar(max)
	Declare @Leave_Columns nvarchar(Max)
	Declare @Leave_Name nvarchar(30)
	set @Leave_Columns = ''
	Set @Columns = '#'
	declare @count_leave as numeric(18,2)
	set @count_leave = 0
	
	declare @String as varchar(max)
	set @string=''
	
	declare @String_2 as varchar(max)
	set @String_2=''
	
	declare @String_3 as varchar(max)
	set @String_3=''
	
	if @summary2 = '' or @summary2 = '-1'
		Set @summary2 = NULL
		
	if @summary3 = '' or @summary3 = '-1'
		Set @summary3 = NULL
		
	--PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 2'
	-- Changed By Ali 22112013 EmpName_Alias
	
	
	Insert Into #CTCMast 
	SELECT e.Cmp_ID,e.Emp_ID,e.Emp_code,e.Alpha_Emp_Code,
		ISNULL(e.EmpName_Alias_Salary,e.Emp_Full_Name)
		--e.Emp_First_Name+' '+ e.Emp_Second_Name +' '+e.Emp_Last_Name
		,bm.Branch_Name,dm.Dept_Name,dnm.Desig_Name,ga.Grd_Name,tm.Type_Name,CT.Cat_Name as Category,VT.Vertical_Name,ST.SubVertical_Name,SB.SubBranch_Name,
		e.Aadhar_Card_No,
		 Case Upper(Payment_Mode) When 'BANK TRANSFER' THEN Inc_Bank_AC_No
		When 'CASH' Then 'CASH' Else 'CHEQUE' End Bank_Ac_No,Pan_No,e.SSN_No as PF_NO,BSG.Segment_Name
		,CC.Center_Code    --added jimit 10082015
		,dnm.Desig_Dis_No,e.Enroll_No  --added jimit 29/09/2015
		,convert(varchar(30),E.Date_Of_Birth,103) as Date_Of_Birth,convert(varchar(30),E.Date_Of_Join,103) as Date_Of_Join,  --added by jimit 27/03/2017
		Inc_Qry.Inc_Bank_AC_No,
		0,0,0
		 --,0 -- Added By Ali 18122013
		 ,0--,(Inc_Qry.CTC * (datediff(mm,@From_Date,@To_Date) + 1)) 
		 ,BM.Branch_ID, e.Present_City, e.Present_Post_Box,convert(varchar(30),e.Emp_Left_Date,103) as Date_Of_Join -- Added by rajput on 11062018 e.Emp_Left_Date
		    
		from T0080_EMP_MASTER e	WITH (NOLOCK) inner join
		( select I.Emp_id,I.Basic_Salary,I.CTC,I.Inc_Bank_AC_No,Payment_Mode,I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_Id,I.Type_ID,I.Cat_ID,I.Vertical_ID,I.SubVertical_ID,I.subBranch_ID,I.Segment_ID,I.Center_ID from T0095_Increment I WITH (NOLOCK) inner join 
			( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
			where Increment_Effective_date <= @To_Date
			and cmp_id = @Company_id
			group by emp_ID  ) Qry on
			I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID 
	inner join #Emp_Cons ec on e.Emp_ID = ec.Emp_ID
	left outer join T0030_BRANCH_MASTER bm WITH (NOLOCK) on Inc_Qry.Branch_ID = bm.Branch_ID
	left outer join T0040_GRADE_MASTER ga WITH (NOLOCK) on Inc_Qry.Grd_ID = ga.Grd_ID
	left outer join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on Inc_Qry.Dept_ID = dm.Dept_Id
	left outer join T0040_DESIGNATION_MASTER dnm WITH (NOLOCK) on Inc_Qry.Desig_Id = dnm.Desig_ID
	left outer join T0040_TYPE_MASTER tm WITH (NOLOCK) on Inc_Qry.Type_ID = tm.Type_ID
	left outer join T0030_CATEGORY_MASTER CT WITH (NOLOCK) on CT.Cat_ID=Inc_Qry.Cat_Id
	left outer join T0040_Vertical_Segment VT WITH (NOLOCK) on VT.Vertical_ID=Inc_Qry.Vertical_ID
	left outer join T0050_SubVertical ST WITH (NOLOCK) on ST.SubVertical_ID=Inc_Qry.SubVertical_ID
	left outer join T0050_SubBranch SB WITH (NOLOCK) on SB.SubBranch_ID=Inc_Qry.subBranch_ID 
	left outer join T0040_Business_Segment BSG WITH (NOLOCK) on BSG.Segment_ID=Inc_Qry.Segment_ID
	left outer join T0040_Cost_Center_Master CC WITH (NOLOCK) on CC.Center_ID = Inc_Qry.Center_ID
	
	
	Declare @CTC_CMP_ID numeric(18,0)
	Declare @CTC_EMP_ID numeric(18,0)
	Declare @CTC_BASIC numeric(18,2)

	
	Declare @AD_NAME_DYN nvarchar(100)
	declare @val nvarchar(max)
	declare @val_update nvarchar(max)
	
	--Comment by nilesh patel on 03102016
	/*
	DECLARE Leave_Cursor CURSOR FOR
			Select Leave_Name
				 from T0120_Leave_Approval la 
				 inner join #Emp_Cons ec on la.emp_ID = ec.emp_ID 
				 Inner join  T0130_Leave_Approval_Detail Lad on la.Leave_Approval_ID = lad.Leave_Approval_ID 
				 inner join T0080_Emp_Master e on la.emp_ID= e.emp_ID 
				 inner join T0040_Leave_Master LM on LM.Leave_ID = Lad.Leave_ID
				 inner join ( select I.Emp_Id ,Increment_effective_Date from T0095_Increment I inner join 
							( select max(T0095_Increment.Increment_Id) as Increment_Id , EC.Emp_ID from T0095_Increment 
								inner join #Emp_Cons ec on T0095_Increment.emp_ID = ec.emp_ID  --Changed by Hardik 10/09/2014 for Same Date Increment
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Company_id
									group by EC.Emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id	 ) I_Q on E.Emp_ID = I_Q.Emp_ID  
				where  la.cmp_ID=@Company_id  and ((lad.From_Date >=@From_Date and lad.From_Date <=@To_Date	) or 	(lad.to_Date >=@From_Date and lad.to_Date <=@To_Date	))				  
				group by Leave_Name
		OPEN Leave_Cursor
			fetch next from Leave_Cursor into @Leave_Name
			while @@fetch_status = 0
				Begin
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table  #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0 not null;'
					
					exec (@val)	
					Set @val = ''
					
					
					Set @Leave_Columns = @Leave_Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
					
					fetch next from Leave_Cursor into @Leave_Name
				End
		close Leave_Cursor	
		deallocate Leave_Cursor
		
		
		
		*/
		--Comment by nilesh patel on 03102016
		
		-- Added by nilesh patel on 03102016 --Start For Leave Column Details 
		Set @val = ''
		SET @val_update = '';
		DECLARE Leave_Cursor CURSOR FOR
			Select Leave_Name
				 from T0120_Leave_Approval la WITH (NOLOCK) 
				 inner join #Emp_Cons ec on la.emp_ID = ec.emp_ID 
				 Inner join  T0130_Leave_Approval_Detail Lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID 
				 inner join T0080_Emp_Master e WITH (NOLOCK) on la.emp_ID= e.emp_ID 
				 inner join T0040_Leave_Master LM on LM.Leave_ID = Lad.Leave_ID
				 inner join ( select I.Emp_Id ,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(T0095_Increment.Increment_Id) as Increment_Id , EC.Emp_ID from T0095_Increment WITH (NOLOCK)
								inner join #Emp_Cons ec on T0095_Increment.emp_ID = ec.emp_ID  --Changed by Hardik 10/09/2014 for Same Date Increment
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Company_id
									group by EC.Emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id	 ) I_Q on E.Emp_ID = I_Q.Emp_ID  
				where  la.cmp_ID=@Company_id  and ((lad.From_Date >=@From_Date and lad.From_Date <=@To_Date	) or 	(lad.to_Date >=@From_Date and lad.to_Date <=@To_Date	))				  
				group by Leave_Name
		OPEN Leave_Cursor
			fetch next from Leave_Cursor into @Leave_Name
			while @@fetch_status = 0
				Begin
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					--Set @val = @val + 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) default 0 not null; '
					Set @val = @val + 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) null; '
					Set @val_update = @val_update + 'Update #CTCMast  SET [' + REPLACE(@AD_NAME_DYN,' ','_') + '] = 0; '
					Set @Leave_Columns = @Leave_Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
					fetch next from Leave_Cursor into @Leave_Name
				End
		close Leave_Cursor	
		deallocate Leave_Cursor
		exec (@val);
		exec (@val_update);
		
		---added jimit 21042016
		DECLARE @str_qry VARCHAR(max)
		DECLARE @cnt NUMERIC
		
		Select @cnt = count(*) from T0200_MONTHLY_SALARY ms WITH (NOLOCK) inner join
		#Emp_Cons EC on Ec.emp_id = ms.Emp_ID			
		where ms.GatePass_Deduct_Days <> 0
		
			
		if @cnt > 0 
			BEGIN
				SET @str_qry = 'Alter table  #CTCMast Add GatePass_Deduct_Days numeric(18,2)'
				exec (@str_qry)
			END	 
			
		/*	
		
		--PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 4'
		Set @val = 'Alter table  #CTCMast Add Total_Paid_Leave_Days numeric(18,2) default 0'
		exec (@val)	   
			   
		Set @val = 'Alter table  #CTCMast Add Total_Leave_Days numeric(18,2) default 0'
		exec (@val)
		
		SET @str_qry = 'Alter table  #CTCMast Add Late_Days numeric(18,2) default 0'
		exec (@str_qry)
		
		SET @str_qry = 'Alter table  #CTCMast Add Early_Days numeric(18,2) default 0'
		exec (@str_qry)	*/	 		
		 
		Set @val = '';
		Set @val = @val + 'Alter table  #CTCMast Add Total_Paid_Leave_Days numeric(18,2) default 0; 
						   Alter table  #CTCMast Add Total_Leave_Days numeric(18,2) default 0;
						   Alter table  #CTCMast Add Late_Days numeric(18,2) default 0;
						   Alter table  #CTCMast Add Early_Days numeric(18,2) default 0'
		exec (@val);
		
-----ended------
		
	--added by jimit 27/03/2017
		Set @val = ''
		Set @val = 'Alter table  #CTCMast Add Arear_Day	Numeric(18,2);
					Alter table  #CTCMast Add Sal_Cal_Day numeric(18,2);
					Alter table  #CTCMast Add Actual_CTC numeric(18,0) null;
					Alter table  #CTCMast Add Basic_salary numeric(18,2) null;
					Alter table  #CTCMast Add Settl_Salary numeric(18,2) null;
					Alter table  #CTCMast Add Other_Allow numeric(18,2) null;'
		exec (@val)	
		
		Update CM
		Set Actual_CTC = (Qry.CTC * (datediff(mm,@From_Date,@To_Date) + 1)) 
		from #CTCMast CM 
			Inner Join	(select E.Emp_ID,Inc_Qry.CTC as CTC
							from T0080_EMP_MASTER e	WITH (NOLOCK) inner join
								( select I.Emp_id,I.Basic_Salary,I.CTC,I.Inc_Bank_AC_No,Payment_Mode,I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_Id,I.Type_ID,I.Cat_ID,I.Vertical_ID,I.SubVertical_ID,I.subBranch_ID,I.Segment_ID,I.Center_ID from T0095_Increment I WITH (NOLOCK) inner join 
									( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)  --Changed by Hardik 10/09/2014 for Same Date Increment
									where Increment_Effective_date <= @To_Date
									and cmp_id = @Company_id
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id )Inc_Qry on 
								E.Emp_ID = Inc_Qry.Emp_ID 
							inner join #Emp_Cons ec on e.Emp_ID = ec.Emp_ID
						) As Qry
			ON CM.Emp_ID = Qry.Emp_ID
		
		
	--ended
	
	
		   
	declare @sum_of_allownaces_earning as varchar(Max)
	set @sum_of_allownaces_earning=''
	
	declare @allownaces_earning as varchar(Max)
	set @allownaces_earning=''
	
	Declare @AD_LEVEL Numeric
	set @AD_LEVEL = 0
	
	DECLARE @ProductionBonus_Ad_Def_Id as NUMERIC ---added by jimit 21032017	
	Set @ProductionBonus_Ad_Def_Id=20
	
	
	-- Comment by nilesh patel on 03102016 --Start
	/* 
	--DECLARE @sum_of_allownaces_earning_Total As Varchar(MAX)
	--SET @sum_of_allownaces_earning_Total = ''
	--PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5'
	DECLARE Allow_Dedu_Cursor CURSOR FOR
		--Select AD_SORT_NAME from T0210_MONTHLY_AD_DETAIL T Inner Join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		--Where M_AD_Amount > 0 And T.Cmp_ID = @Company_Id and month(T.For_Date) =  MONTH(@From_Date) and Year(T.For_Date) = YEAR(@From_Date)
		--		and isnull(A.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I'
		--Group by AD_SORT_NAME 
		Select AD_SORT_NAME,AD_LEVEL from T0210_MONTHLY_AD_DETAIL T Inner Join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id --and month(T.For_Date) >=  MONTH(@From_Date) and Year(T.For_Date) >= YEAR(@From_Date) and month(T.For_Date) <=  MONTH(@To_Date) and Year(T.For_Date) <= YEAR(@To_Date)
				--and T.For_Date between @From_Date and @To_Date
				and T.For_Date >= @From_Date and T.To_date <= @To_Date
				and (isnull(A.Ad_Not_Effect_Salary,0) = 0 OR ISNULL(T.ReimShow,0) = 1) and Ad_Active = 1 and AD_Flag = 'I' and A.Allowance_Type <> 'R'
		
		Group by AD_SORT_NAME ,AD_LEVEL
		ORDER BY AD_LEVEL ASC
		
		OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
			while @@fetch_status = 0
				Begin
					
					
					--Set @AD_NAME_DYN = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					--Changes done by Mihir 16102011 add / special charecter and Comment above Line
					  Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')
					-- End of Changes done by mihir...
					set @sum_of_allownaces_earning=@sum_of_allownaces_earning + ',sum(' + @AD_NAME_DYN + ') as ' + @AD_NAME_DYN +''
					Set @allownaces_earning =@allownaces_earning + ',' + @AD_NAME_DYN + ' as ' + @AD_NAME_DYN +''
					--SET @sum_of_allownaces_earning_Total = @sum_of_allownaces_earning_Total + '+ sum(' + @AD_NAME_DYN + ')'
					
					Set @val = 'Alter table  #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0 not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
				End
		close Allow_Dedu_Cursor	
		deallocate Allow_Dedu_Cursor */
		-- Comment by nilesh patel on 03102016 --End
		
		Set @val = ''
		SET @val_update = '';
		DECLARE Allow_Dedu_Cursor CURSOR FOR
		Select AD_SORT_NAME,AD_LEVEL from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id
				and T.For_Date >= @From_Date and T.To_date <= @To_Date
				and (isnull(A.Ad_Not_Effect_Salary,0) = 0 OR ISNULL(T.ReimShow,0) = 1)
				and Ad_Active = 1  and AD_Flag = 'I' 
				and A.Allowance_Type <> 'R'
				and T.S_Sal_Tran_ID is Null   --added by jimit 25012016 to resolve the case of RK
				and ad_def_Id <> @ProductionBonus_Ad_Def_Id 
		Group by AD_SORT_NAME ,AD_LEVEL
		ORDER BY AD_LEVEL,A.AD_SORT_NAME ASC
		
		OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
			while @@fetch_status = 0
				Begin
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')
					set @sum_of_allownaces_earning=@sum_of_allownaces_earning + ',sum([' + @AD_NAME_DYN + ']) as [' + @AD_NAME_DYN +']'
					Set @allownaces_earning =@allownaces_earning + ',[' + @AD_NAME_DYN + '] as [' + @AD_NAME_DYN +']'
					--Set @val = @val + 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) default 0 not null;'
					Set @val = @val + 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) null;'
					SET @val_update = @val_update+ 'UPDATE  #CTCMast SET [' + REPLACE(@AD_NAME_DYN,' ','_') + '] = 0; '
					Set @Columns = @Columns +  '[' + REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + ']#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
				End
		close Allow_Dedu_Cursor	
		deallocate Allow_Dedu_Cursor
		
		exec (@val);
		exec (@val_update);
		
		--Added by Hardik 08/02/2018 for Arear Earning for Cera Client
		declare @sum_of_allownaces_earning_Arear as varchar(Max)
		set @sum_of_allownaces_earning_Arear=''
	
		declare @allownaces_earning_arear as varchar(Max)
		set @allownaces_earning_arear =''
	
		set @AD_LEVEL = 0
		
		Set @val = ''
		SET @val_update = '';
		DECLARE Allow_Dedu_Cursor CURSOR FOR
		Select AD_SORT_NAME,AD_LEVEL from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where (M_AREAR_AMOUNT<>0 OR M_AREAR_AMOUNT_Cutoff <> 0)  And T.Cmp_ID = @Company_Id
				and T.For_Date >= @From_Date and T.To_date <= @To_Date
				and (isnull(A.Ad_Not_Effect_Salary,0) = 0 OR ISNULL(T.ReimShow,0) = 1)
				and Ad_Active = 1 and AD_Flag = 'I' and A.Allowance_Type <> 'R'
				and T.S_Sal_Tran_ID is Null
		Group by AD_SORT_NAME ,AD_LEVEL
		ORDER BY AD_LEVEL,A.AD_SORT_NAME ASC
		
		OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
			while @@fetch_status = 0
				Begin
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')
					Set @AD_NAME_DYN = @AD_NAME_DYN + '_Arrear'
					set @sum_of_allownaces_earning_Arear=@sum_of_allownaces_earning_Arear + ',sum([' + @AD_NAME_DYN + ']) as [' + @AD_NAME_DYN +']'
					Set @allownaces_earning_arear =@allownaces_earning_arear + ',[' + @AD_NAME_DYN + '] as [' + @AD_NAME_DYN +']'
					--Set @val = @val + 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) default 0 not null;'
					Set @val = @val + 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) null;'
					SET @val_update = @val_update+ 'UPDATE  #CTCMast SET [' + REPLACE(@AD_NAME_DYN,' ','_') + '] = 0; '
					Set @Columns = @Columns +  '[' + REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + ']#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
				End
		close Allow_Dedu_Cursor	
		deallocate Allow_Dedu_Cursor
		
		exec (@val);
		exec (@val_update);		
		
		/*
		Set @val = 'Alter table  #CTCMast Add Arear_Amount numeric(18,2) default 0 not null'
		exec (@val)	
	
		Set @val = 'Alter table  #CTCMast Add Leave_Encash_Amount NUMERIC(18,2) DEFAULT 0 NOT NULL'	----Ankit 26102015
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Gross_Salary numeric(18,2) default 0 not null'
		exec (@val)	
	
		Set @val = 'Alter table  #CTCMast Add PT_Amount numeric(18,2) default 0 not null'
		exec (@val)	
	
		Set @val = 'Alter table  #CTCMast Add Loan_Amount numeric(18,2) default 0 not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Advance_Amount numeric(18,2) default 0 not null'
		exec (@val)	

		--  Added By rohit for Add two column OT Amount and OT Hours  on 26-sep-2012
		Set @val = 'Alter table  #CTCMast Add OT_Rate numeric(18,2) default 0 not null'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add OT_Hours numeric(18,2) default 0 not null'
		exec (@val)	
	
		Set @val = 'Alter table  #CTCMast Add OT_Amount numeric(18,2) default 0 not null'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Travel_Amount numeric(18,2) default 0 not null'
		exec (@val)	--Added by Sumit 06102015
		*/
		
		Set @val = ''
					--Alter table  #CTCMast Add Arear_Amount numeric(18,2) default 0 not null;		--commented by Hardik 08/02/2018 for Cera
		Set @val = 'Alter table  #CTCMast Add Production_Bonus numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add Leave_Encash_Amount NUMERIC(18,2) DEFAULT 0 NOT NULL; 
					--Alter table  #CTCMast Add Uniform_Refund_Amount numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add Gross_Salary numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add PT_Amount numeric(18,2) default 0 not null;
					--Alter table  #CTCMast Add Loan_Amount numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add Advance_Amount numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add OT_Rate numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add OT_Hours numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add OT_Amount numeric(18,2) default 0 not null;	
					
					Alter table  #CTCMast Add M_HO_OT_Hours numeric(18,2) default 0 not null; 
					Alter table  #CTCMast Add M_HO_OT_Amount numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add M_WO_OT_Hours numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add M_WO_OT_Amount numeric(18,2) default 0 not null;
					
					
									
					Alter table  #CTCMast Add WO_HO_Fix_OT_Rate numeric(18,2) default 0 not null
					Alter table  #CTCMast Add Travel_Amount numeric(18,2) default 0 not null
					Alter table  #CTCMast Add Basic_Arrear numeric(18,2) default 0 not null
					Alter table  #CTCMast Add Total_Earning numeric(18,2) default 0 not null
					Alter table  #CTCMast Add Total_Earning_Arrear numeric(18,2) default 0 not null
					Alter table  #CTCMast Add Gratuity_Amount numeric(18,2) default 0 not null' --Added on 13062018 by rajput 
		exec (@val)	
	
		UPDATE   CM 						
		SET		Production_Bonus = Q.Amount
		FROM	dbo.#CTCMast CM 
				INNER JOIN (
							SELECT	ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID
							FROM	T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
									INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID												
							WHERE	MAD.Cmp_ID= @Company_Id 
										AND MONTH(MAD.For_Date) =  Month(@From_Date) and YEAR(MAD.For_Date) = Year(@From_Date)
										AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0 
										AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id
										--AND MAD.Emp_ID = @EMp_Id_Production
							GROUP BY Mad.Emp_ID
						  )Q On CM.Emp_ID = Q.Emp_ID 
	
	--added by jimit 05042017
		Update  C
		SET		C.WO_HO_Fix_OT_Rate = Q.Fix_OT_Hour_Rate_WO_HO	
		From    #CTCMast C INNER JOIN
		(
			SELECT Inc_Qry.Fix_OT_Hour_Rate_WO_HO,e.Emp_ID,e.Cmp_ID
				from T0080_EMP_MASTER e	WITH (NOLOCK) inner join
				( select I.Emp_id,I.Fix_OT_Hour_Rate_WD,I.Fix_OT_Hour_Rate_WO_HO from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and cmp_id = @Company_id
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id )Inc_Qry on 
				E.Emp_ID = Inc_Qry.Emp_ID 
			inner join #Emp_Cons ec on e.Emp_ID = ec.Emp_ID
		)Q On Q.Emp_ID = C.Emp_ID and Q.Cmp_ID = C.Cmp_ID
		--ended
	
	
	-------------added By Jimit 15122017 for RK-------------
	Declare @Loan_name varchar(100)
		Declare @Loan_Id Numeric
		Declare @sum_of_Loan_Amount_Str varchar(Max)
		Declare @Loan_Amount_Str varchar(Max)

		Set @Loan_Amount_Str=''
		Set @sum_of_Loan_Amount_Str=''

		DECLARE Loan_Cursor CURSOR FOR
				SELECT LM.LOAN_NAME,LA.LOAN_ID FROM T0210_MONTHLY_LOAN_PAYMENT MLP WITH (NOLOCK) INNER JOIN 
				T0120_LOAN_APPROVAL LA WITH (NOLOCK) ON MLP.LOAN_APR_ID=LA.LOAN_APR_ID INNER JOIN
				T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.LOAN_ID=LM.LOAN_ID
				WHERE MLP.LOAN_PAYMENT_DATE BETWEEN @From_Date AND @To_Date AND SAL_TRAN_ID IS NOT NULL AND MLP.CMP_ID=@Company_id
				GROUP BY LM.LOAN_NAME,LA.LOAN_ID
				ORDER BY LM.LOAN_NAME
		OPEN Loan_Cursor
			fetch next from Loan_Cursor into @Loan_name,@Loan_Id
			while @@fetch_status = 0
				Begin
					
					
					Set @Loan_name = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@Loan_name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')
					set @sum_of_Loan_Amount_Str = @sum_of_Loan_Amount_Str + 'sum(' + @Loan_name + ') as ' + @Loan_name +','
					Set @Loan_Amount_Str = @Loan_Amount_Str  + @Loan_name + ','					
					
					Set @val = 'Alter table  #CTCMast Add ' + REPLACE(@Loan_name,' ','_') + ' numeric(18,2) default 0 not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@Loan_name)),' ','_') + '#'

				fetch next from Loan_Cursor into @Loan_name,@Loan_Id
				End
		close Loan_Cursor	
		deallocate Loan_Cursor
		
		
		IF  @sum_of_Loan_Amount_Str <> ''
			set  @sum_of_Loan_Amount_Str = LEFT(@sum_of_Loan_Amount_Str,len(@sum_of_Loan_Amount_Str) -1)
		IF 	@Loan_Amount_Str <> ''
			set  @Loan_Amount_Str = LEFT(@Loan_Amount_Str,len(@Loan_Amount_Str) -1)
		
		IF  @sum_of_Loan_Amount_Str <> ''
			SET @sum_of_Loan_Amount_Str = ',' + @sum_of_Loan_Amount_Str
		IF 	@Loan_Amount_Str <> ''
			SET @Loan_Amount_Str = ',' + @Loan_Amount_Str
		
		
		
	----------------ended------------------
	
	
	
	declare @sum_of_allownaces_deduct as varchar(Max)
	set @sum_of_allownaces_deduct=''
	declare @allownaces_deduct as varchar(Max)
	set @allownaces_deduct=''
	SET @AD_LEVEL = 0
	
	--Comment by nilesh patel on 03102016 --Start
	/*
	Declare Allow_Dedu_Cursor CURSOR FOR
		--		Select AD_SORT_NAME from T0210_MONTHLY_AD_DETAIL T Inner Join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		--Where M_AD_Amount > 0 And T.Cmp_ID = @Company_Id and month(T.For_Date) =  MONTH(@From_Date) and Year(T.For_Date) = YEAR(@From_Date)
		--		and isnull(A.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'D'
		--Group by AD_SORT_NAME
			Select AD_SORT_NAME,Ad_Level from T0210_MONTHLY_AD_DETAIL T Inner Join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id --and month(T.For_Date) >=  MONTH(@From_Date) and Year(T.For_Date) >= YEAR(@From_Date) and month(T.For_Date) <=  MONTH(@To_Date) and Year(T.For_Date) <= YEAR(@To_Date)
				--and T.For_Date between @From_Date and @To_Date
				and T.For_Date >= @From_Date and T.To_date <= @To_Date
				and (isnull(A.Ad_Not_Effect_Salary,0) = 0 OR ISNULL(T.ReimShow,0) = 1) and Ad_Active = 1 and AD_Flag = 'D'
		Group by AD_SORT_NAME  ,AD_LEVEL
		ORDER BY AD_LEVEL
		
		OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
			while @@fetch_status = 0
				Begin
				
				
					
				--	Set @AD_NAME_DYN = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  --comment by hasmukh & add below line 20062014
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					set @sum_of_allownaces_deduct=@sum_of_allownaces_deduct + ',sum(' + @AD_NAME_DYN + ') as ' + @AD_NAME_DYN +''
					Set @allownaces_deduct =@allownaces_deduct + ',' + @AD_NAME_DYN + ' as ' + @AD_NAME_DYN +''
					Set @val = 'Alter table  #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0 not null'
					exec (@val)	
					
					
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
					
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor */
	--Comment by nilesh patel on 03102016 --End
	

	Set @val = ''
	set @val_update = '';
	Declare Allow_Dedu_Cursor CURSOR FOR
			Select AD_SORT_NAME,Ad_Level from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id 
				and T.For_Date >= @From_Date and T.To_date <= @To_Date
				and (isnull(A.Ad_Not_Effect_Salary,0) = 0 OR ISNULL(T.ReimShow,0) = 1) and Ad_Active = 1 and AD_Flag = 'D'
				and T.S_Sal_Tran_ID is Null   --added by jimit 25012016 to resolve the case of RK 
		Group by AD_SORT_NAME  ,AD_LEVEL
		ORDER BY AD_LEVEL
		
		OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
			while @@fetch_status = 0
				Begin
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					set @sum_of_allownaces_deduct=@sum_of_allownaces_deduct + ',sum(' + @AD_NAME_DYN + ') as ' + @AD_NAME_DYN +''
					Set @allownaces_deduct =@allownaces_deduct + ',' + @AD_NAME_DYN + ' as ' + @AD_NAME_DYN +''
					--Set @val = @val + 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) default 0 not null; '
					Set @val = @val + 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) null; '
					SET @val_update = @val_update+ 'UPDATE  #CTCMast SET [' + REPLACE(@AD_NAME_DYN,' ','_') + '] = 0; '
					Set @Columns = @Columns + '[' + REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + ']#'
					
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
	
	
	exec (@val)	
	exec (@val_update)	
	
		--Added by Hardik 08/02/2018 for Arear Deduction for Cera Client
		declare @sum_of_allownaces_deduct_Arear as varchar(Max)
		set @sum_of_allownaces_deduct_Arear=''
	
		declare @allownaces_deduct_arear as varchar(Max)
		set @allownaces_deduct_arear =''
	
		set @AD_LEVEL = 0
		
		Set @val = ''
		SET @val_update = '';
		DECLARE Allow_Dedu_Cursor CURSOR FOR
		Select AD_SORT_NAME,AD_LEVEL from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where (M_AREAR_AMOUNT<>0 OR M_AREAR_AMOUNT_Cutoff <> 0)  And T.Cmp_ID = @Company_Id
				and T.For_Date >= @From_Date and T.To_date <= @To_Date
				and isnull(A.Ad_Not_Effect_Salary,0) = 0
				and Ad_Active = 1 and AD_Flag = 'D'
				and T.S_Sal_Tran_ID is Null
		Group by AD_SORT_NAME ,AD_LEVEL
		ORDER BY AD_LEVEL,A.AD_SORT_NAME ASC
		
		OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
			while @@fetch_status = 0
				Begin
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')
					Set @AD_NAME_DYN = @AD_NAME_DYN + '_Arrear'
					set @sum_of_allownaces_deduct_Arear=@sum_of_allownaces_deduct_Arear + ',sum([' + @AD_NAME_DYN + ']) as [' + @AD_NAME_DYN +']'
					Set @allownaces_deduct_arear =@allownaces_deduct_arear + ',[' + @AD_NAME_DYN + '] as [' + @AD_NAME_DYN +']'
					--Set @val = @val + 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) default 0 not null;'
					Set @val = @val + 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) null;'
					SET @val_update = @val_update+ 'UPDATE  #CTCMast SET [' + REPLACE(@AD_NAME_DYN,' ','_') + '] = 0; '
					Set @Columns = @Columns +  '[' + REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + ']#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
				End
		close Allow_Dedu_Cursor	
		deallocate Allow_Dedu_Cursor
	
		exec (@val);
		exec (@val_update);	

	/*
		Set @val = 'Alter table  #CTCMast Add Revenue_Amount numeric(18,2) default 0 not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add LWF_Amount numeric(18,2) default 0  not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Other_Dedu numeric(18,2) default 0 not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Gate_Pass_Amount numeric(18,2) default 0 not null'
		exec (@val)	 -- Added by Gadriwala Muslim 09012015
		
		Set @val = 'Alter table  #CTCMast Add Asset_Installment_Amount numeric(18,2) default 0 not null'
		exec (@val)	 -- Added by Mukti 07042015
		
		Set @val = 'Alter table  #CTCMast Add Travel_Advance_Amount numeric(18,2) default 0 not null'
		exec (@val)	--Added by Sumit 06102015

		Set @val = 'Alter table  #CTCMast Add Total_Deduction numeric(18,2) default 0 not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Net_Amount numeric(18,2) default 0 not null'
		exec (@val)				
		
		Set @val = 'Alter table  #CTCMast Add Net_Round numeric(18,2) default 0 not null'
		exec (@val)	*/
		
		--Arrear_Deduction Added By Ramiz on 24/11/2017 ( Spelling of Arrear is Incorrect in Header , but that is due to Template Logic )
		Set @val = ''
		Set @val = 'Alter table  #CTCMast Add Revenue_Amount numeric(18,2) default 0 not null; 
					Alter table  #CTCMast Add LWF_Amount numeric(18,2) default 0  not null;
					Alter table  #CTCMast Add Other_Deduction numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add Gate_Pass_Amount numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add Asset_Installment_Amount numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add Travel_Advance_Amount numeric(18,2) default 0 not null;
					--Alter table  #CTCMast Add Uniform_Dedu_Amount numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add Late_Deduction_Amount numeric(18,2) default 0 not null;	
					Alter table  #CTCMast Add Arear_Deduction numeric(18,2) default 0 not null;				
					Alter table  #CTCMast Add Total_Deduction numeric(18,2) default 0 not null;	
					Alter table  #CTCMast Add Net_Total_Deduction numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add Net_Amount numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add Net_Round numeric(18,2) default 0 not null;
					Alter table  #CTCMast Add Total_Net numeric(18,2) default 0 not null;'
		exec (@val)
		
		
		
		-----CTC ALLOWANCE --------------
		
		DECLARE @AD_NAME_DYN_CTC nvarchar(100)
		DECLARE @Sum_Of_Allownaces_Earning_CTC as varchar(Max)
		DECLARE @Sum_Of_Allownaces_Earning_CTC_Total as varchar(Max)
		
		DECLARE @Allownaces_Earning_CTC as varchar(Max)
		DECLARE @Allownaces_Earning_CTC_Total as varchar(Max)
		
		SET @AD_NAME_DYN_CTC = ''
		SET @Sum_Of_Allownaces_Earning_CTC = ''
		SET @Sum_Of_Allownaces_Earning_CTC_Total = ''
		Set @Allownaces_Earning_CTC = ''
		Set @Allownaces_Earning_CTC_Total = ''
		
		--Comment by nilesh patel on 03102016 --start
		/*
		DECLARE CTC_Allow_Dedu_Cursor CURSOR FOR
			SELECT AD_SORT_NAME,AD_LEVEL from T0210_MONTHLY_AD_DETAIL T Inner Join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
			WHERE M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id 
					and T.For_Date >= @From_Date and T.To_date <= @To_Date
					and ISNULL(A.Ad_Not_Effect_Salary,0) = 1 AND A.Allowance_Type <> 'R' and Ad_Active = 1 and AD_Flag = 'I'   --Change By Jaina 07-09-2016 (add part of CTC = 1 condition)  
					and ISNULL(A.Hide_In_Reports,0) = 0  --Added By Jaina 09-09-2016
			GROUP BY AD_SORT_NAME ,AD_LEVEL
			ORDER BY AD_LEVEL ASC
		OPEN CTC_Allow_Dedu_Cursor
			FETCH NEXT FROM CTC_Allow_Dedu_Cursor INTO @AD_NAME_DYN_CTC,@AD_LEVEL
			while @@fetch_status = 0
				BEGIN
						Set @AD_NAME_DYN_CTC = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN_CTC)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')
						
						set @Sum_Of_Allownaces_Earning_CTC = @Sum_Of_Allownaces_Earning_CTC + ',sum(' + @AD_NAME_DYN_CTC + ') as ' + @AD_NAME_DYN_CTC +''
						
						Set @Allownaces_Earning_CTC = @Allownaces_Earning_CTC + ',' + @AD_NAME_DYN_CTC + ' as ' + @AD_NAME_DYN_CTC +''
						
						SET @Sum_Of_Allownaces_Earning_CTC_Total = @Sum_Of_Allownaces_Earning_CTC_Total + '+ sum(' + @AD_NAME_DYN_CTC + ')'		--@Sum_Of_Allownaces_Earning_CTC_Total used departmentwise Group summary Report - Wonder Client -- Ankit 29052015
						
						Set @Allownaces_Earning_CTC_Total = @Allownaces_Earning_CTC_Total + '+ ' + @AD_NAME_DYN_CTC + ''	
						
						Set @val = 'Alter table  #CTCMast Add ' + REPLACE(@AD_NAME_DYN_CTC,' ','_') + ' numeric(18,2) default 0 not null'
						
						exec (@val)	
						
						Set @val = ''
						
						Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN_CTC)),' ','_') + '#'
						
					FETCH NEXT FROM CTC_Allow_Dedu_Cursor into @AD_NAME_DYN_CTC,@AD_LEVEL
				END
		CLOSE CTC_Allow_Dedu_Cursor	
		DEALLOCATE CTC_Allow_Dedu_Cursor
	*/
	--Comment by nilesh patel on 03102016 --End

			
	Set @val = ''
	DECLARE CTC_Allow_Dedu_Cursor CURSOR FOR
			SELECT AD_SORT_NAME,AD_LEVEL from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
			WHERE M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id 
					and T.For_Date >= @From_Date and T.To_date <= @To_Date
					and ISNULL(A.Ad_Not_Effect_Salary,0) = 1 AND A.Allowance_Type <> 'R' and Ad_Active = 1 --and AD_Flag = 'I'   
					and (CASE WHEN @Show_Hidden_Allowance = 0  and  A.Hide_In_Reports = 1 THEN 0 else 1 END )=1  --Change By Jaina 20-12-2016
					and T.S_Sal_Tran_ID is Null   --added by jimit 25012016 to resolve the case of RK 
					and  ad_def_Id <> @ProductionBonus_Ad_Def_Id 
			GROUP BY AD_SORT_NAME ,AD_LEVEL
			ORDER BY AD_LEVEL ASC
		OPEN CTC_Allow_Dedu_Cursor
			FETCH NEXT FROM CTC_Allow_Dedu_Cursor INTO @AD_NAME_DYN_CTC,@AD_LEVEL
			while @@fetch_status = 0
				BEGIN
						
						Set @AD_NAME_DYN_CTC = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN_CTC)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')
						set @Sum_Of_Allownaces_Earning_CTC = @Sum_Of_Allownaces_Earning_CTC + ',sum([' + @AD_NAME_DYN_CTC + ']) as ' + @AD_NAME_DYN_CTC +''
						Set @Allownaces_Earning_CTC = @Allownaces_Earning_CTC + ',[' + @AD_NAME_DYN_CTC + '] as [' + @AD_NAME_DYN_CTC +']'
						SET @Sum_Of_Allownaces_Earning_CTC_Total = @Sum_Of_Allownaces_Earning_CTC_Total + '+ sum([' + @AD_NAME_DYN_CTC + '])'
						Set @Allownaces_Earning_CTC_Total = @Allownaces_Earning_CTC_Total + '+ ' + @AD_NAME_DYN_CTC + ''
						Set @val = @val + 'ALTER TABLE  #CTCMast Add [' + REPLACE(@AD_NAME_DYN_CTC,' ','_') + '] numeric(18,2) default 0 not null; '
						Set @Columns = @Columns + '[' + REPLACE(rtrim(ltrim(@AD_NAME_DYN_CTC)),' ','_') + ']#'
					FETCH NEXT FROM CTC_Allow_Dedu_Cursor into @AD_NAME_DYN_CTC,@AD_LEVEL
				END
		CLOSE CTC_Allow_Dedu_Cursor	
		DEALLOCATE CTC_Allow_Dedu_Cursor
	exec (@val);
	
	
	declare @sum_of_allownaces_earning_reim as varchar(Max)
	set @sum_of_allownaces_earning_reim =''
	
	declare @allownaces_earning_reim as varchar(Max)
	set @allownaces_earning_reim =''
	
	DECLARE @AD_NAME_DYN_Reim nvarchar(100)
	Set @AD_NAME_DYN_Reim = ''
	
	DECLARE @AD_LEVEL_Reim Numeric(18,0)
	Set @AD_LEVEL_Reim = 0
	
	--Comment by nilesh patel on 03102016 --start
	/*
	DECLARE Allow_Dedu_Reim_Cursor CURSOR FOR
		SELECT  a.AD_SORT_NAME ,AD_LEVEL
		FROM         T0210_MONTHLY_AD_DETAIL AS m 
					INNER JOIN T0050_AD_MASTER AS a ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID
		WHERE   (m.For_Date = @From_Date) and   M.Cmp_ID = @Company_Id  And
		(m.M_AD_Amount <> 0) AND (m.M_AD_Flag = 'I') and (AD_NOT_EFFECT_SALARY = 1 and AD_PART_OF_CTC = 1) and A.Allowance_Type = 'R'
		Group by AD_SORT_NAME ,AD_LEVEL
		ORDER BY AD_LEVEL ASC
	OPEN Allow_Dedu_Reim_Cursor
			fetch next from Allow_Dedu_Reim_Cursor into @AD_NAME_DYN_Reim,@AD_LEVEL_Reim
			while @@fetch_status = 0
				Begin
					
					Set @AD_NAME_DYN_Reim = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN_Reim) + '_' + 'Credit'),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')
					set @sum_of_allownaces_earning_reim = @sum_of_allownaces_earning_reim + ',sum(' + @AD_NAME_DYN_Reim + ') as ' + @AD_NAME_DYN_Reim +''
					Set @allownaces_earning_reim =@allownaces_earning_reim + ',' + @AD_NAME_DYN_Reim + ' as ' + @AD_NAME_DYN_Reim +''
				
					Set @val = 'Alter table  #CTCMast Add ' + REPLACE(@AD_NAME_DYN_Reim,' ','_') + ' numeric(18,2) default 0 not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN_Reim)),' ','_') + '#'
				fetch next from Allow_Dedu_Reim_Cursor into @AD_NAME_DYN_Reim,@AD_LEVEL
				End
		close Allow_Dedu_Reim_Cursor	
		deallocate Allow_Dedu_Reim_Cursor
		
		
		--PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 10'
		*/
		
						
	Set @val = ''
	DECLARE Allow_Dedu_Reim_Cursor CURSOR FOR
		SELECT  a.AD_SORT_NAME ,AD_LEVEL
		FROM T0210_MONTHLY_AD_DETAIL AS m WITH (NOLOCK)
					INNER JOIN T0050_AD_MASTER AS a WITH (NOLOCK) ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID
		WHERE   (m.For_Date = @From_Date) and   M.Cmp_ID = @Company_Id  And
		(m.M_AD_Amount <> 0) AND (m.M_AD_Flag = 'I') and A.Allowance_Type = 'R'
		and (AD_NOT_EFFECT_SALARY = 1 and AD_PART_OF_CTC = 1 )
		and (CASE WHEN @Show_Hidden_Allowance = 0  and  A.Hide_In_Reports = 1 THEN 0 else 1 END )=1  --Change By Jaina 20-12-2016
		and S_Sal_Tran_ID is Null   --added by jimit 25012016 to resolve the case of RK 
		Group by AD_SORT_NAME ,AD_LEVEL
		ORDER BY AD_LEVEL ASC
	OPEN Allow_Dedu_Reim_Cursor
			fetch next from Allow_Dedu_Reim_Cursor into @AD_NAME_DYN_Reim,@AD_LEVEL_Reim
			while @@fetch_status = 0
				Begin
					Set @AD_NAME_DYN_Reim = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN_Reim) + '_' + 'Credit'),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')
					set @sum_of_allownaces_earning_reim = @sum_of_allownaces_earning_reim + ',sum([' + @AD_NAME_DYN_Reim + ']) as ' + @AD_NAME_DYN_Reim +''
					Set @allownaces_earning_reim =@allownaces_earning_reim + ',[' + @AD_NAME_DYN_Reim + '] as [' + @AD_NAME_DYN_Reim +']'
					Set @val = @val + 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN_Reim,' ','_') + '] numeric(18,2) default 0 not null; '
					Set @Columns = @Columns + '[' + REPLACE(rtrim(ltrim(@AD_NAME_DYN_Reim)),' ','_') + ']#'
				fetch next from Allow_Dedu_Reim_Cursor into @AD_NAME_DYN_Reim,@AD_LEVEL
				End
		close Allow_Dedu_Reim_Cursor	
		deallocate Allow_Dedu_Reim_Cursor	
	exec (@val);
	
	--select * from #CTCMast
	--added by jimit 27032017
		Set @val = ''
		Set @val = 'Alter table  #CTCMast Add Salary_Status Varchar(10) default 0 not null;
					Alter table  #CTCMast Add Is_FNF numeric default 0 not null;' --Added by rajput on 15032018
		exec (@val)	
	---ended
	
	
	if @is_column = 1 
			begin 
				if @Summary=''
				begin
					
					select TOP 1 *--,'' as inc_bank_ac_No
					from #CTCMast
					order by CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(#CTCMast.Enroll_No AS VARCHAR), 21)  
								WHEN @Order_By='Name' THEN #CTCMast.Emp_Full_Name 
								When @Order_By = 'Designation' then (CASE WHEN #CTCMast.Desig_dis_No  = 0 THEN #CTCMast.Designation ELSE RIGHT(REPLICATE('0',21) + CAST(#CTCMast.Desig_dis_No AS VARCHAR), 21)   END) 
								--ELSE RIGHT(REPLICATE(N' ', 500) + #CTCMast.Alpha_Emp_Code, 500) 
							End ,Case When IsNumeric(Replace(Replace(#CTCMast.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(#CTCMast.Alpha_Emp_Code,'="',''),'"',''), 20)
									 When IsNumeric(Replace(Replace(#CTCMast.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(#CTCMast.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
									 Else Replace(Replace(#CTCMast.Alpha_Emp_Code,'="',''),'"','') End
							--RIGHT(REPLICATE(N' ', 500) + #CTCMast.Alpha_Emp_Code, 500) 

					
				end
	else  ---for group wise branch--
			
			begin	
		
	
			--set @String = ' select SUM(CM.Present_Day) as "Sum(CM.Present_Day)",SUM(CM.Arear_Day) as "Sum(CM.Arear_Day)",SUM(CM.Absent_Day) as "(CM.Absent_Day)",SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as weekoff,SUM(CM.Sal_Cal_Day)as sal_cal_day,SUM(CM.Actual_CTC) as CTC,SUM(CM.Basic_Salary) as Basic_salary,SUM(CM.Settl_Salary)as settle_salary,SUM(CM.Other_Allow)as other_allowance,SUM(CM.total_paid_leave_days)as total_paid,SUM(cm.total_leave_days)as total_lv_days,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.Gross_Salary)as gross_salary,SUM(CM.PT_Amount)as pt_amt,SUM(cm.Loan_Amount)as loan_amt,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(cm.ot_rate)as ot_rate,SUM(cm.ot_hours)as ot_hours,SUM(cm.ot_amount)as ot_amt,SUM(cm.revenue_amount),SUM(cm.lwf_amount)as lwf_amt,SUM(cm.other_dedu)as other_deduction,SUM(cm.total_deduction)as total_deduction,SUM(cm.net_amount)as net_amt '
	
			--set @String = @String + @sum_of_allownaces_earning  + @sum_of_allownaces_deduct +' from #CTCMast CM group By Branch_Id'
			----select @String
			--exec(@String)
	--		set @String = ' select CM.Branch as Branch_Name, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount,SUM(cm.Loan_Amount)as Loan_Amount,SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '
	
	--		set @String = @String + ' from #CTCMast CM group By Branch_Id,branch'
	----select @String
			--exec(@String)
	--	
		--PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 11'
		If exists (Select 1 from sys.objects where name = 'tempgroup2')
			drop TABLE tempgroup2
		
		If exists (Select 1 from sys.objects where name = 'tempgroup3')
			drop TABLE tempgroup3
		
		
		if @summary2 is not null
			Begin
				
				Set @String_2 = 'Select (CASE WHEN '+ @summary2 +'=''0'' THEN ''CM.Branch_ID,CM.Branch'' When '+ @summary2 +' =''1'' Then ''CM.Grade'' When '+ @summary2 +' =''2'' Then ''CM.Category'' When '+ @summary2 +' =''3'' Then ''Department'' When '+ @summary2 +' =''4'' Then ''Designation'' When '+ @summary2 +' =''5'' Then ''TypeName'' When '+ @summary2 +' =''6'' Then ''Division'' When '+ @summary2 +' =''7'' Then ''sub_vertical'' When '+ @summary2 +' =''8'' Then ''sub_branch'' When '+ @summary2 +' =''9'' Then ''Segment_Name'' When '+ @summary2 +' =''10'' Then ''Center_Code'' End ) as Description into tempgroup2'
				exec(@String_2)
				Select @String_2 = Description From tempgroup2
				Set @String_2 = ','+ @String_2
				
			End 
		
		if @summary3 is not null
			Begin
				Set @String_3 = 'Select (CASE WHEN '+ @summary3 +'=''0'' THEN ''CM.Branch_ID,CM.Branch'' When '+ @summary3 +' =''1'' Then ''CM.Grade'' When '+ @summary3 +' =''2'' Then ''CM.Category'' When '+ @summary3 +' =''3'' Then ''Department'' When '+ @summary3 +' =''4'' Then ''Designation'' When '+ @Summary3 +' =''5'' Then ''TypeName'' When '+ @Summary3 +' =''6'' Then ''Division'' When '+ @summary3 +' =''7'' Then ''sub_vertical'' When '+ @summary3 +' =''8'' Then ''sub_branch'' When '+ @summary3 +' =''9'' Then ''Segment_Name'' When '+ @summary3 +' =''10'' Then ''Center_Code'' End ) as Description into tempgroup3'
				
				exec(@String_3)
				Select @String_3 = Description From tempgroup3
				Set @String_3 = ','+ @String_3
			End
		
		Declare @Str_Emp_Name Varchar(Max)
		Set @Str_Emp_Name = ''
		
		Declare @Str_Emp_Name_Group Varchar(Max)
		Set @Str_Emp_Name_Group = ''
		
		if @Type = 3 
			Begin
				Set @Str_Emp_Name = @Str_Emp_Name + ',CM.Alpha_Emp_Code,CM.Emp_Full_Name,'
				Set @Str_Emp_Name_Group = @Str_Emp_Name_Group + ',CM.Alpha_Emp_Code,CM.Emp_Full_Name'
			End
		Else
			Begin
				Set @Str_Emp_Name = @Str_Emp_Name + ','
				Set @Str_Emp_Name_Group = ''
			End
		
		
					
		Declare @Avg_Emp Numeric(18,1)   --changd jimit 26052016 for getting the round value of avg emp
		set @Avg_Emp = DATEDIFF(MM,@From_Date,@To_Date) + 1
		
		
	
		if @Summary='0'
			BEGIN 
			if @Type='3'
			   Begin
					set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' CM.Branch as Branch_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
					SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
					+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
					+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
					SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +','''' as Emp_Left_Date,COUNT(CASE WHEN CM.IS_FNF =1 THEN ''FNF'' ELSE CM.salary_status END) as Salary_Status'
			   
			   
					--set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' CM.Department as Department'+ @String_2 +' '+ @String_3 +',Count(Emp_ID) As Total_Emp,
					--Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Uniform_Refund_Amount) as Uniform_Refund_Amount'
					--+ @sum_of_allownaces_earning_Arear + ',SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str +',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
					--SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

					set @String = @String + ' from #CTCMast CM  group By Branch ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
					--select @String
					exec(@String)
					--select 11
			   End
			ELSE IF @TYPE='5'   --Added By Jimit 18012018
			   BEGIN
					set @String = ' select TOP 1 0 as flag ,CM.Branch as Branch_Name'+ @String_2 + ',Count(Emp_ID) As Total_Emp, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round'
			   
					set @String = @String + ' from #CTCMast CM  group By Branch ' + @Str_Emp_Name_Group + ''+@String_2+' '
				
					exec(@String)
			   END
			Else
				BEGIN		
					set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' Cast(1 As BigInt) As Row_ID, CM.Branch as Branch_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
					Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
					+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
					+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
					SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
				
					set @String = @String + ' from #CTCMast CM  group By Branch ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
					
					exec(@String)
				END
			
			end
		else if @Summary='1'
			begin
			
			if @Type='3'
			   Begin
					set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' CM.Grade as Grade'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
					SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
					+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
					+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
					SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
			   
			   
					--set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' CM.Grade as Grade'+ @String_2 +' '+ @String_3 +',Count(Emp_ID) As Total_Emp,
					--Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Uniform_Refund_Amount) as Uniform_Refund_Amount'
					--+ @sum_of_allownaces_earning_Arear + ',SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str +',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
					--SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

					set @String = @String + ' from #CTCMast CM  group By Grade ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
					
					--select @String
					exec(@String)
			   End
			ELSE IF @TYPE='5'   --Added By Jimit 18012018
			   BEGIN
					set @String = ' select TOP 1 0 as flag ,CM.Grade as Grade'+ @String_2 + ',Count(Emp_ID) As Total_Emp, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round'
			   
					set @String = @String + ' from #CTCMast CM  group By Grade ' + @Str_Emp_Name_Group + ''+@String_2+' '
				
					exec(@String)
			   END
			Else
				BEGIN				
					set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' Cast(1 As BigInt) As Row_ID, CM.Grade as Grade'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
					Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
					+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
					+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
					SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
				
					set @String = @String + ' from #CTCMast CM  group By Grade ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
					
					exec(@String)
				END

			end
		else if @Summary='2'
			begin
				if @Type='3'
					   Begin
							set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' CM.Category as Category'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
							SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
							+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
							+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
							SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
					
							--set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' Cast(1 As BigInt) As Row_ID, CM.Category as Category'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
							--Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
							--+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
							--+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
							--SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
					
						set @String = @String + ' from #CTCMast CM  group By Category ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						
						exec(@String)
					END
			ELSE IF @TYPE='5'   --Added By Jimit 18012018
			   BEGIN
					set @String = ' select TOP 1 0 as flag ,CM.Category as Category'+ @String_2 + ',Count(Emp_ID) As Total_Emp, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round'
			   
					set @String = @String + ' from #CTCMast CM  group By Category ' + @Str_Emp_Name_Group + ''+@String_2+' '
				
					exec(@String)
			   END
				Else
					BEGIN
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' Cast(1 As BigInt) As Row_ID, CM.Category as Category'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
					
						set @String = @String + ' from #CTCMast CM  group By Category ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						
						exec(@String)
					END
			end
		else if @Summary='3'
			begin
			
			if @Type='3'
			   Begin
					set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' CM.Department as Department'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
					SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
					+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
					+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
					SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
			   
			   
					--set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' CM.Department as Department'+ @String_2 +' '+ @String_3 +',Count(Emp_ID) As Total_Emp,
					--Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Uniform_Refund_Amount) as Uniform_Refund_Amount'
					--+ @sum_of_allownaces_earning_Arear + ',SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str +',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
					--SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

					set @String = @String + ' from #CTCMast CM  group By Department ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
					exec(@String)
			   End
			ELSE IF @TYPE='5'   --Added By Jimit 18012018
			   BEGIN
					set @String = ' select TOP 1 0 as flag ,CM.Department as Department'+ @String_2 + ',Count(Emp_ID) As Total_Emp, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round'
			   
					set @String = @String + ' from #CTCMast CM  group By Department ' + @Str_Emp_Name_Group + ''+@String_2+' '
				
					exec(@String)
			   END
			Else
				Begin
					set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' Cast(1 As BigInt) As Row_ID, CM.Department as Department'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
					Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
					+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
					+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
					SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
				
				
					--set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' Cast(1 As BigInt) As Row_ID, CM.Department as Department'+ @String_2 +' '+ @String_3 +',Count(Emp_ID) As Total_Emp,
					--Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Uniform_Refund_Amount) as Uniform_Refund_Amount'
					--+ @sum_of_allownaces_earning_Arear + ',SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str +',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
					--SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

					set @String = @String + ' from #CTCMast CM  group By Department ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
					exec(@String)
				End
			end
		else if @Summary='4'
			begin
				if @Type='3'
					Begin
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' CM.Designation as Designation'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

						set @String = @String + ' from #CTCMast CM  group By Designation ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						exec(@String)
					End			
				ELSE
					BEGIN
				
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' Cast(1 As BigInt) As Row_ID, CM.Designation as Designation'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

						set @String = @String + ' from #CTCMast CM  group By Designation ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						
						exec(@String)
					END
			end
		else if @Summary='5'
			begin
				if @Type='3'
					Begin
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' CM.TypeName as TypeName'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

						set @String = @String + ' from #CTCMast CM  group By TypeName ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						exec(@String)
					End			
			ELSE IF @TYPE='5'   --Added By Jimit 18012018
				   BEGIN
					
					
						set @String = ' select TOP 1 0 as flag ,CM.TypeName as TypeName'+ @String_2 + ',Count(Emp_ID) As Total_Emp, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round'
			   
						set @String = @String + ' from #CTCMast CM  group By TypeName ' + @Str_Emp_Name_Group + ''+@String_2+' '
				
						exec(@String)
				   END
				ELSE
					BEGIN				
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' Cast(1 As BigInt) As Row_ID, CM.TypeName as Type_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
					
						set @String = @String + ' from #CTCMast CM  group By TypeName ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						
						exec(@String)
					END
			end
		else if @Summary='6' -----for division wise-------------------
			begin
				IF @Type='3'
					Begin
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' CM.Division as Division'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

						set @String = @String + ' from #CTCMast CM  group By Division ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						exec(@String)
					End			
			ELSE IF @TYPE='5'   --Added By Jimit 18012018
				   BEGIN
					
					
						set @String = ' select TOP 1 0 as flag ,CM.Division as Division'+ @String_2 + ',Count(Emp_ID) As Total_Emp, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round'
			   
						set @String = @String + ' from #CTCMast CM  group By Division ' + @Str_Emp_Name_Group + ''+@String_2+' '
				
						exec(@String)
				   END	
				ELSE
					BEGIN				
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' Cast(1 As BigInt) As Row_ID, CM.Division as Division'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
					
						set @String = @String + ' from #CTCMast CM  group By Division ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						
						exec(@String)
					END

			end
		else if @Summary='7'
			begin
				IF @Type='3'
					Begin
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' CM.sub_vertical as Sub_Department'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

						set @String = @String + ' from #CTCMast CM  group By sub_vertical ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						exec(@String)
					End			
				ELSE IF @TYPE='5'   --Added By Jimit 18012018
				   BEGIN
					
					
						set @String = ' select TOP 1 0 as flag ,CM.sub_vertical as sub_vertical'+ @String_2 + ',Count(Emp_ID) As Total_Emp, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round'
			   
						set @String = @String + ' from #CTCMast CM  group By sub_vertical ' + @Str_Emp_Name_Group + ''+@String_2+' '
				
						exec(@String)
				   END
				ELSE
					BEGIN				
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' Cast(1 As BigInt) As Row_ID, CM.sub_vertical as Sub_Department'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
					
						set @String = @String + ' from #CTCMast CM  group By sub_vertical ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						
						exec(@String)
					END

			end
		else if @Summary='8'
			begin
				IF @Type='3'
					Begin
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' CM.Sub_Branch as Sub_Branch'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

						set @String = @String + ' from #CTCMast CM  group By Sub_Branch ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						exec(@String)
					End			
			ELSE IF @TYPE='5'   --Added By Jimit 18012018
				   BEGIN
					
					
						set @String = ' select TOP 1 0 as flag ,CM.Sub_Branch as Sub_Branch'+ @String_2 + ',Count(Emp_ID) As Total_Emp, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round'
			   
						set @String = @String + ' from #CTCMast CM  group By Sub_Branch ' + @Str_Emp_Name_Group + ''+@String_2+' '
				
						exec(@String)
				   END
				ELSE
					BEGIN
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' Cast(1 As BigInt) As Row_ID, CM.sub_branch as Sub_Branch'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
					
						set @String = @String + ' from #CTCMast CM  group By sub_branch ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						
						exec(@String)
					END
				
			end
		else if @Summary='9'
			begin
				IF @Type='3'
					Begin
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' CM.Segment_Name as Segment_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

						set @String = @String + ' from #CTCMast CM  group By Segment_Name ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						exec(@String)
					End			
			ELSE IF @TYPE='5'   --Added By Jimit 18012018
				   BEGIN
					
					
						set @String = ' select TOP 1 0 as flag ,CM.Segment_Name as Segment_Name'+ @String_2 + ',Count(Emp_ID) As Total_Emp, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round'
			   
						set @String = @String + ' from #CTCMast CM  group By Segment_Name ' + @Str_Emp_Name_Group + ''+@String_2+' '
				
						exec(@String)
				   END
				ELSE
					BEGIN				
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' Cast(1 As BigInt) As Row_ID, CM.Segment_Name as Segment_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
					
						set @String = @String + ' from #CTCMast CM  group By Segment_Name ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						
						exec(@String)
					END
				
			end
		else if @Summary='10'
			begin
				IF @Type='3'
					Begin
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' CM.Center_Code as Center_Code'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

						set @String = @String + ' from #CTCMast CM  group By Center_Code ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						exec(@String)
					End			
				ELSE IF @TYPE='5'   --Added By Jimit 18012018
				   BEGIN
					
					
						set @String = ' select TOP 1 0 as flag ,CM.Center_Code as Center_Code'+ @String_2 + ',Count(Emp_ID) As Total_Emp, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round'
			   
						set @String = @String + ' from #CTCMast CM  group By Center_Code ' + @Str_Emp_Name_Group + ''+@String_2+' '
				
						exec(@String)
				   END	
				ELSE
					BEGIN
						set @String = ' select TOP 1 0 as flag ' + @Str_Emp_Name + ' Cast(1 As BigInt) As Row_ID, CM.Center_Code as Center_Code'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
					
						set @String = @String + ' from #CTCMast CM  group By Center_Code ' + @Str_Emp_Name_Group + ''+@String_2+' '+ @String_3 +''
						
						exec(@String)
					END
				
			end
		end
		
		return 
				
   end
   
   

	Declare @total_paid_leave_cur numeric(18,2)
	set @total_paid_leave_cur = 0
	
	Declare @Arear_Basic As Numeric(22,6)
	Declare @Arear_Earn_Amount as Numeric(22,6)
	Declare @Arear_Dedu_Amount as Numeric(22,6)
	Declare @Arear_Net As Numeric(22,6)
	
	Declare @CTC_COLUMNS nvarchar(100)
	Declare @CTC_AD_FLAG varchar(1)
	Declare @Allow_Amount numeric(18,2)
	
	Declare @GatePass_Amount as numeric(18,2) -- Added by Gadriwala Muslim 09012015
	Declare @Asset_Installment as numeric(18,2) -- Added by Mukti 07042015
	Declare @Leave_Encash_Amount as numeric(18,2)
	Declare @TravelAdv_Amount as numeric(18,2)
	Declare @Late_Days as numeric(18,2) 
	Declare @Early_Days as numeric(18,2)
	Declare @GatePass_Deduct_Days as numeric(18,2) 
	
	
	Update M 
		SET --Arear_Amount = (t3.Arrear_Basic+t.Arrear_Earn_Amt) - t2.Arrear_Ded_Amt	''Commented and Bifurcated Arrear By Ramiz on 24/11/2017
		--Arear_Amount = (t3.Arrear_Basic + t.Arrear_Earn_Amt),  --Commented by Hardik 08/02/2018 for Cera
		Basic_Arrear = t3.Arrear_Basic,
		Total_Earning_Arrear = t3.Arrear_Basic + t.Arrear_Earn_Amt ,
		Arear_Deduction = t2.Arrear_Ded_Amt --Commented by Hardik 08/02/2018 for Cera
	From #CTCMast M
	Inner JOIN(
			   Select Isnull(SUM(M_Arear_Amount),0) as Arrear_Earn_Amt,M.Emp_ID 
			   From T0210_MONTHLY_AD_DETAIL M WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON M.Emp_ID=EC.Emp_ID -- ADDED BY RAJPUT ON 11062018 CODE OPTIMIZE
			   Where For_Date >= @From_Date And To_Date <= @To_Date And M_AD_Flag = 'I' and M_AD_NOT_EFFECT_SALARY = 0
						and S_Sal_Tran_ID is Null   --added by jimit 25012016 to resolve the case of RK 
			   Group BY M.Emp_ID
			   ) As t 
			   ON M.Emp_ID = t.Emp_ID
	Inner JOIN(
			   Select Isnull(SUM(M_Arear_Amount),0) as Arrear_Ded_Amt,M.Emp_ID 
			   From T0210_MONTHLY_AD_DETAIL  M WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON M.Emp_ID=EC.Emp_ID
			   Where For_Date >= @From_Date And To_Date <= @To_Date And M_AD_Flag = 'D' and M_AD_NOT_EFFECT_SALARY = 0
						and S_Sal_Tran_ID is Null   --added by jimit 25012016 to resolve the case of RK 
			   GROUP By M.Emp_ID 
			   ) as t2 
			   ON M.Emp_ID = t2.Emp_ID
	Inner JOIN(
				Select Isnull(Arear_Basic,0) as Arrear_Basic,M.Emp_ID 
				From T0200_MONTHLY_SALARY M WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON M.Emp_ID=EC.Emp_ID
				Where Month_St_Date >= @From_Date And Month_End_Date <= @To_Date
			   ) As t3 
			   ON M.Emp_ID = t3.Emp_ID
	
	
	
	Update CM
		Set Basic_Salary = Qry.Salary_Amount,
			Present_Day = Qry.Present_Days,
			Absent_Day = Qry.Absent_Days,
			Holiday_Day = Qry.Holiday_Days,
			WeekOff_Day = Qry.Weekoff_Days,
			Sal_Cal_Day = Qry.Sal_Cal_Days,
			Settl_Salary = Qry.Settelement_Amount,
			Other_Allow = Qry.Other_Allow_Amount,
			--Gross_Salary = Qry.Gross_Salary added by jimit 27012016
			Gross_Salary = Qry.Gross_Salary + CM.Total_Earning_Arrear,
			--Total_Deduction = Qry.Total_Dedu_Amount, -- Commented by Hardik 08/02/2018 for Cera
			Total_Deduction = Qry.Dedu_Amount + Qry.Advance_Amount + Qry.PT_Amount + Qry.LWF_Amount + Qry.Other_Dedu_Amount + Qry.Asset_Installment + Qry.Travel_Advance_Amount  + qry.Late_Deduction_Amount + Qry.Loan, 
			PT_Amount = Qry.PT_Amount,
			--Loan_Amount = Qry.Loan, 
			Advance_Amount = Qry.Advance_Amount, 
			Revenue_Amount = Qry.Revenue_amount, 
			LWF_Amount = Qry.LWF_Amount,
			Other_Deduction = Qry.Other_Dedu_Amount, 
			Net_Amount = Qry.Net_Amount - Qry.Net_Salary_Round_Diff_Amount,
			Arear_Day = Qry.Arear_Day, 
			OT_Hours= Qry.OT_Hours,
			OT_Amount= Qry.OT_Amount,
			
			M_HO_OT_Hours=Qry.Holiday_OT_Hours,
			M_HO_OT_Amount=Qry.Holiday_OT_Amount,
			M_WO_OT_Hours=Qry.Weekoff_OT_Hours,
			M_WO_OT_Amount=Qry.Weekoff_OT_Amount,
			
			
			OT_Rate = (CASE WHEN  dbo.F_Return_Sec(isnull(ot_fix_shift_hours,'00:00')) = 0 then Hour_Salary Else (Day_Salary * 3600)/ dbo.F_Return_Sec(isnull(ot_fix_shift_hours,'00:00')) END),
			Gate_Pass_Amount = Qry.GatePass_Amount,				
			Asset_Installment_Amount = Qry.Asset_Installment,				
			Net_Round = Qry.Net_Salary_Round_Diff_Amount, --Added by Hardik 08/02/2018 for Cera
			Travel_Advance_Amount = Qry.Travel_Advance_Amount,
			Travel_Amount= Qry.Travel_Amount,
			Leave_Encash_Amount = Qry.Leave_Encash_Amount,
			Late_Days = Qry.Late_Days,
			Early_Days = Qry.Early_Days,
			Total_Paid_Leave_Days = Qry.total_paid_leave_cur,
			Salary_Status = qry.Salary_Status,        --added by jimit 27032017
			Is_FNF = qry.Is_FNF,        --added by Rajput 15032018
			--Uniform_Dedu_Amount=qry.Uniform_Dedu_Amount,
			--Uniform_Refund_Amount=qry.Uniform_Refund_Amount
			 Late_Deduction_Amount = qry.Late_Deduction_Amount  ---added by Jimit 29072017
			,Total_Earning = Qry.Gross_Salary --Added by Hardik 08/02/2018 for Cera
			,Net_Total_Deduction = Qry.Total_Dedu_Amount--Added by Hardik 08/02/2018 for Cera
			,Total_Net = Qry.Net_Amount --Added by Hardik 08/02/2018 for Cera
			,Gratuity_Amount = qry.Gratuity_Amount --Added by rajput on 13062018
	from #CTCMast CM 
		Inner Join	(select GS.Branch_ID,GS.ot_fix_shift_hours
						from T0040_GENERAL_SETTING GS WITH (NOLOCK)
						INNER JOIN (
										select max(for_date) as For_Date,Cmp_ID,Branch_ID From T0040_General_Setting WITH (NOLOCK)
										Group BY Cmp_ID,Branch_ID
									) qry_1
						on qry_1.Cmp_ID = GS.Cmp_ID and qry_1.Branch_ID = GS.Branch_ID and GS.For_Date = qry_1.For_Date
					) As qry_2 on CM.Branch_id = qry_2.Branch_ID
		Inner JOIN (
					SELECT
					sum(MS.Salary_Amount) As Salary_Amount,
					sum(MS.Present_Days) As Present_Days,
					sum(MS.Absent_Days) As Absent_Days,
					sum(MS.Holiday_Days) As Holiday_Days,
					sum(MS.Weekoff_Days) As Weekoff_Days,
					sum(MS.Sal_Cal_Days) As Sal_Cal_Days,
					Isnull(sum(MS.Settelement_Amount),0) As Settelement_Amount,
					Isnull(sum(MS.Other_Allow_Amount),0) As Other_Allow_Amount, 
					(Isnull(sum(MS.Allow_Amount),0) + Isnull(sum(MS.Salary_Amount),0) + Cast(Isnull(sum(MS.Settelement_Amount),0)as Numeric(18,2)) + Cast(Isnull(sum(MS.Leave_Salary_Amount),0)as Numeric(18,2))+ Isnull(sum(MS.Other_Allow_Amount),0) + Isnull(sum(MS.Gratuity_Amount),0)) As Gross_Salary,
					Isnull(sum(MS.Total_Dedu_Amount),0) As Total_Dedu_Amount, 
					Isnull(sum(MS.PT_Amount),0) As PT_Amount,
					Isnull(sum(( MS.Loan_Amount + MS.Loan_Intrest_Amount )),0) As Loan, 
					Isnull(sum(MS.Advance_Amount),0) As Advance_Amount, 
					Isnull(sum(MS.Revenue_amount),0) As Revenue_amount, 
					Isnull(sum(MS.LWF_Amount),0) As LWF_Amount,
					Isnull(sum(MS.Other_Dedu_Amount),0) As Other_Dedu_Amount, 
					Isnull(sum(MS.Net_Amount),0) As Net_Amount,
					Isnull(Sum(MS.Arear_Day),0) As Arear_Day,
					isnull(sum(MS.OT_Hours),0) As OT_Hours,
					isnull(sum(MS.OT_Amount),0) As OT_Amount,
					
					
					isnull(sum(MS.M_HO_OT_Hours),0) As Holiday_OT_Hours,
					isnull(sum(MS.M_HO_OT_Amount),0) As Holiday_OT_Amount,
					isnull(sum(MS.M_WO_OT_Hours),0) As Weekoff_OT_Hours,
					isnull(sum(MS.M_WO_OT_Amount),0) As Weekoff_OT_Amount,
					
					isnull(SUM(MS.GatePass_Amount),0) As GatePass_Amount,				
					isnull(SUM(MS.Asset_Installment),0) As Asset_Installment,				
					Isnull(sum(MS.Net_Salary_Round_Diff_Amount),0) As Net_Salary_Round_Diff_Amount,
					Isnull(SUM(MS.Travel_Advance_Amount),0) As Travel_Advance_Amount,
					isnull(sum(MS.Travel_Amount),0) As Travel_Amount,
					isnull(SUM(MS.Leave_Salary_Amount),0) As Leave_Encash_Amount,
					isnull(sum(Ms.Late_Days),0) As Late_Days,
					isnull(sum(Ms.Early_Days),0) As Early_Days,
					isnull(sum(Paid_Leave_Days + OD_Leave_Days),0) As total_paid_leave_cur,
					isnull(sum(Hour_Salary),0) as Hour_Salary,
					isnull(sum(Day_Salary),0) as Day_Salary,
					--isnull(SUM(MS.Uniform_Dedu_Amount),0) As Uniform_Dedu_Amount,			
					--isnull(SUM(MS.Uniform_Refund_Amount),0) As Uniform_Refund_Amount,	
					isnull(SUM(MS.Allow_Amount),0) As Allow_Amount,	
					isnull(SUM(MS.Dedu_Amount),0) As Dedu_Amount,	
					Emp_ID
					,Salary_Status  
					,Isnull(SUM(MS.Late_Dedu_Amount),0) as Late_Deduction_Amount
					,ISNULL(ms.Is_FNF,0) as Is_FNF
					,ISNULL(SUM(ms.Gratuity_Amount),0) as Gratuity_Amount -- Added by rajput on 13062018
					From T0200_MONTHLY_SALARY MS WITH (NOLOCK)
					where MS.Month_st_date between @From_Date and @To_Date and MS.Cmp_ID = @Company_Id
					GROUP By MS.Emp_ID,Salary_Status,Is_FNF
				   ) As Qry
		ON CM.Emp_ID = Qry.Emp_ID
	
	
	
	--added by jimit for updating OT_Rate if Fix OT Rate for weekday is available 06042017
			Update  C
				SET		C.OT_Rate = (Case When Q.Fix_OT_Hour_Rate_WD > 0 then Q.Fix_OT_Hour_Rate_WD else C.Ot_Rate end) 
				From    #CTCMast C INNER JOIN
				(
					SELECT IsNULL(Inc_Qry.Fix_OT_Hour_Rate_WD,0) as Fix_OT_Hour_Rate_WD ,e.Emp_ID,e.Cmp_ID
						from T0080_EMP_MASTER e	WITH (NOLOCK) inner join
						( select I.Emp_id,I.Fix_OT_Hour_Rate_WD,I.Fix_OT_Hour_Rate_WO_HO from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and cmp_id = @Company_id
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id )Inc_Qry on 
						E.Emp_ID = Inc_Qry.Emp_ID 
					inner join #Emp_Cons ec on e.Emp_ID = ec.Emp_ID
				)Q On Q.Emp_ID = C.Emp_ID and Q.Cmp_ID = C.Cmp_ID
				
		--ended
	
	
	
	if object_ID('tempdb..#Emp_Allowance') is not null
		Begin
			Drop TABLE #Emp_Allowance
		End
				
	Create Table #Emp_Allowance
	(
		Emp_ID numeric(18,0),
		Ad_ID numeric(18,0),
		AD_Amount numeric(18,2)
	)
						
	Declare CRU_COLUMNS CURSOR FOR
						Select data from Split(@Columns,'#') where data <> ''
					OPEN CRU_COLUMNS
							fetch next from CRU_COLUMNS into @CTC_COLUMNS
							while @@fetch_status = 0
								Begin				
										begin
												Set @CTC_COLUMNS = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@CTC_COLUMNS)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
																						
												begin

											
													
													Insert INTO #Emp_Allowance
														select ded.EMP_ID,ded.AD_ID,
														--isnull(sum(case when ded.ReimAmount >0  then ded.ReimAmount else ded.M_AD_Amount end),0) As Amount
														--isnull(sum(ded.M_AD_Amount),0) As Amount   --Comment by Jaina 01-03-2017
														isnull(sum(case when ded.ReimAmount >0  then ded.ReimAmount else (ded.M_AD_Amount) end),0) As Amount   --Added by Jaina 01-03-2017  Bug id = 5532
														from T0210_MONTHLY_AD_DETAIL  ded WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON ded.Emp_ID=EC.Emp_ID -- ADDED BY RAJPUT ON 11062018 CODE OPETIMIZE
														inner join T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id Inner join 
														T0200_MONTHLY_SALARY m WITH (NOLOCK) on ded.Sal_Tran_ID= m.Sal_Tran_ID and 
														Isnull(ded.FOR_FNF,0)=
															Case when ad.AD_NOT_EFFECT_SALARY = 1 then  isnull(m.Is_FNF,0) else Isnull(ded.FOR_FNF,0) end
														WHere  
														-- Added Case Statement For bifurcation of reimbursment & Allowance Details
														(Case When Allowance_Type = 'A' THEN '[' + Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_Sort_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_') +']'
														 ELSE
														 '[' + Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_Sort_Name + '_' + 'Credit')),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_') + ']'
														 END) = @CTC_COLUMNS 
														and ded.For_Date >= @From_Date and ded.To_date <= @To_Date and ded.Cmp_ID = @Company_Id
														and S_Sal_Tran_ID is Null    --added by jimit 25012016 to resolve the case of RK 
														group by ded.EMP_ID , ded.AD_Id


														Insert INTO #Emp_Allowance
														select ded.EMP_ID,ded.AD_ID,
														isnull(sum(case when ded.ReimAmount >0  then ded.ReimAmount else (isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0))  end),0) As Amount   --Added by Jaina 01-03-2017  Bug id = 5532
														from T0210_MONTHLY_AD_DETAIL  ded WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON ded.Emp_ID=EC.Emp_ID -- ADDED ON 11062018 BY RAJPUT CODE OPTIMIZE
														inner join T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id
														WHere  
														(Case When Allowance_Type = 'A' THEN '[' + Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_Sort_Name + '_Arrear')),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_') +']'
														 ELSE
														 '[' + Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_Sort_Name + '_' + 'Credit_Arrear')),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_') + ']'
														 END) = @CTC_COLUMNS 
														and ded.For_Date >= @From_Date and ded.To_date <= @To_Date and ded.Cmp_ID = @Company_Id And (M_AREAR_AMOUNT<>0 OR M_AREAR_AMOUNT_Cutoff <> 0) 
														and S_Sal_Tran_ID is Null 
														group by ded.EMP_ID , ded.AD_Id

													
													Set @val = ''
													Set @val = 'Update CM Set ' + @CTC_COLUMNS + ' = Qry.AD_Amount
																From #CTCMast CM 
																Inner Join
																		(
																			Select EA.AD_Amount,EA.Emp_ID From  #Emp_Allowance EA
																		) as Qry
																 ON CM.Emp_ID = Qry.Emp_ID'
													Exec(@val)
												end
												
												TRUNCATE TABLE  #Emp_Allowance;
										end
										
									fetch next from CRU_COLUMNS into @CTC_COLUMNS
								End
					close CRU_COLUMNS	
					deallocate CRU_COLUMNS 
			
			
					
		declare @leave_total numeric(18,2)		
		declare @leave_name_temp nvarchar(100)
		set @count_leave = 0
		
		
		if object_ID('tempdb..#Emp_Leave') is not null
		Begin
			Drop TABLE #Emp_Leave
		End
				
		Create Table #Emp_Leave
		(
			Emp_ID numeric(18,0),
			Leave_ID numeric(18,0),
			Leave_Balance numeric(18,2)
		)
		-- Leave detail cursor
		DECLARE Leave_Cursor CURSOR FOR
			Select data from Split(@Leave_Columns,'#') where data <> ''
		OPEN Leave_Cursor
			fetch next from Leave_Cursor into @Leave_Name
				while @@fetch_status = 0
					Begin
						Insert INTO #Emp_Leave
						select  LT.Emp_ID, LM.Leave_ID,Isnull((SUM(lt.Leave_Used) + Sum(lt.compOff_Used)),0) As Leave
						from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner join 
						T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID = LT.Leave_ID 
						where LM.cmp_ID=@Company_id  and LT.For_Date  >=@From_Date and LT.For_Date  <=@To_Date 
						and  Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')= @Leave_Name  -- Changed By Gadriwala Muslim 26092014 --REPLACE(rtrim(ltrim(Leave_Name)),' ','_') = @Leave_Name
						group by Leave_Name,LT.Emp_ID,LM.Leave_ID	
						
						Set @val = ''
						Set @val = 'Update CM 
									Set ' + @Leave_Name + ' = Qry.Leave_Balance
									From #CTCMast CM 
									Inner Join
											(
												Select EL.Leave_Balance,EL.Emp_ID From  #Emp_Leave EL
											) as Qry
									ON CM.Emp_ID = Qry.Emp_ID'
						Exec(@val)
						
						Set @val = ''
						Set @val = 'Update CM 
									Set  Total_Leave_Days = IsNull(Total_Leave_Days,0) + Qry_1.Leave_Balance
									From #CTCMast CM 
									Inner Join
											(
												Select ISNULL(SUM(EL.Leave_Balance),0) As Leave_Balance,EL.Emp_ID From #Emp_Leave EL
												Group BY EL.Emp_ID
											) as Qry_1
									ON CM.Emp_ID = Qry_1.Emp_ID;'
									
									--Update #CTCMast Set  Total_Leave_Days = 0 Where Total_Leave_Days IS NULL'
						Exec(@val)
						
						--set @count_leave = @count_leave + @leave_total
						TRUNCATE TABLE  #Emp_Leave;
						fetch next from Leave_Cursor into @Leave_Name
					End
		close Leave_Cursor
		deallocate Leave_Cursor
			
					
		/*  Added By Jimit 16122017  */
		if object_ID('tempdb..#Emp_Loan') is not null
		Begin
			Drop TABLE #Emp_Loan
		End
				
		Create Table #Emp_Loan
		(
			Emp_ID numeric(18,0),
			Loan_ID numeric(18,0),
			Loan_Amount numeric(18,2),
			Loan_Name	Varchar(50)
		)
		
		Declare @Loan_Amount Numeric(18,4)
		DECLARE Loan_Amt_Cursor CURSOR FOR
			Select data from Split(@Loan_Amount_Str,',') where data <> ''
		OPEN Loan_Amt_Cursor
			fetch next from Loan_Amt_Cursor into @Loan_Name
				while @@fetch_status = 0
					Begin
						
					
						
						Insert INTO #Emp_Loan
						SELECT  LA.Emp_ID,LA.Loan_ID,
								SUM(MLP.LOAN_PAY_AMOUNT) 
								,LM.Loan_Name
						FROM	T0210_MONTHLY_LOAN_PAYMENT MLP WITH (NOLOCK) INNER JOIN 
								T0120_LOAN_APPROVAL LA WITH (NOLOCK) ON MLP.LOAN_APR_ID=LA.LOAN_APR_ID INNER JOIN
								T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.LOAN_ID=LM.LOAN_ID 
						WHERE MLP.LOAN_PAYMENT_DATE BETWEEN @FROM_DATE  AND @TO_DATE 
							AND SAL_TRAN_ID IS NOT NULL AND MLP.CMP_ID=@COMPANY_ID 
							AND Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(LM.LOAN_NAME)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_') =@LOAN_NAME
						Group by LM.Loan_Name,LA.Emp_ID,LA.Loan_ID

						Set @val = ''
						
						
						
						Set @val = 'Update CM 
									Set ' + @Loan_Name + ' = Qry.Loan_Amount
									From #CTCMast CM 
									Inner Join
											(
												Select EL.Emp_ID,EL.Loan_Amount From #Emp_Loan EL
											) as Qry
									ON CM.Emp_ID = Qry.Emp_ID'
						Exec(@val)
						
						
						
						TRUNCATE TABLE  #Emp_Loan;
						fetch next from Loan_Amt_Cursor into @Loan_Name
					End
		close Loan_Amt_Cursor
		deallocate Loan_Amt_Cursor
		/*  Ended  */
		

	
	Update #CTCMast set Alpha_Emp_Code = '="' + Alpha_Emp_Code + '"'      -- Added by Gadriwala 03052014
	
	
	DECLARE @COLS VARCHAR(MAX) --ADDED BY JIMIT 18012019	
	
	if @Summary=''
	begin
	
		declare @drop_cols varchar(max)
		declare @Con_Name as varchar(50)
		declare @Con_col_Name as varchar(50)
		
		DECLARE Constraint_Cur CURSOR FOR
				Select	c.name, cons.name
				From	tempdb.sys.columns c 
						left outer join  tempdb.sys.default_constraints cons on c.object_id=cons.parent_object_id and c.column_id=cons.parent_column_id
				Where c.object_id=OBJECT_ID('tempdb.dbo.#CTCMast') and c.column_id > 28 and c.precision > 0
						AND c.name NOT IN ('Sal_Cal_Day', 'Actual_CTC', 'Basic_salary')
		OPEN Constraint_Cur
			fetch next from Constraint_Cur into @Con_Name, @Con_col_Name
			while @@fetch_status = 0
				Begin
				----PRINT @Con_Name
					if @Con_col_Name is not null
						begin 
							--Changed Condition By Ramiz on 21/11/2017 , as Positive and Negative Allowance was getting SUM of 0 and that Column was getting deleted
							--SET @drop_cols = 'IF NOT EXISTS(SELECT 1 FROM #CTCMast Having SUM(' + @Con_Name + ') >  0)
							--					begin 													
							--						exec (''alter table #CTCMast drop constraint ' + @Con_col_Name + ''')
							--					end';
							SET @drop_cols = 'IF NOT EXISTS(SELECT 1 FROM #CTCMast where ' + @Con_Name + ' <>  0)
												begin 													
													exec (''alter table #CTCMast drop constraint ' + @Con_col_Name + ''')
												end';
							exec (@drop_cols)
							
						end 
								
					----PRINT @Con_Name		 
					--Changed Condition By Ramiz on 21/11/2017 , as Positive and Negative Allowance was getting SUM of 0 and that Column was getting deleted
					--SET @drop_cols = 'IF NOT EXISTS(SELECT 1 FROM #CTCMast Having Sum(' + @Con_Name + ') > 0)
					--					BEGIN 
					--						--PRINT ''' + @Con_Name  + ''';
					--						exec (''alter table #CTCMast drop column ' + @Con_Name + ''');
					--					END'
					SET @drop_cols = 'IF NOT EXISTS(SELECT 1 FROM #CTCMast where [' + @Con_Name + '] <>  0)
										BEGIN 
											--PRINT ''' + @Con_Name  + ''';
											exec (''alter table #CTCMast drop column [' + @Con_Name + ']'');
										END'
					exec (@drop_cols)
					
					
					fetch next from Constraint_Cur into @Con_Name, @Con_col_Name
				End
		close Constraint_Cur	
		deallocate Constraint_Cur
		
		
		--Select @drop_cols  = coalesce(@drop_cols + ';', '') +
		--					'if exists(select 1 from #CTCMast Having SUM([' + c.name +']) = 0)
		--						begin ' +
		--						 case when cons.object_id is not null then 'alter table  #CTCMast drop constraint [' + cons.name +'];' else '' end +
		--							'alter table  #CTCMast drop column [' + c.name +'];
		--						end'
		
		
		--Select c.name, cons.name
		--From tempdb.sys.columns c 
		--	 left outer join  tempdb.sys.default_constraints cons on c.object_id=cons.parent_object_id
		--Where c.object_id=OBJECT_ID('tempdb.dbo.#CTCMast') and c.column_id > 28 and c.precision > 0;

----PRINT @drop_cols
--		exec (@drop_cols);

		--if exists(select 1 from #CTCMast Having SUM(Other_Allow) = 0)		
		--	alter table #CTCMast drop column Other_Allow
		
		
		
		Select CM.*--,inc.inc_bank_ac_No as inc_bank_ac_No 
		into #temp_CTCMaster from #CTCMast CM
		inner join t0080_emp_master em WITH (NOLOCK) on cm.emp_id = em.emp_id
		inner join t0095_increment Inc WITH (NOLOCK) on em.increment_id = inc.increment_id	
		--Order by CM.Emp_code   commented by jimit 29/09/2015
		order by CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(CM.Enroll_No AS VARCHAR(20)), 21)  
								WHEN @Order_By='Name' THEN CM.Emp_Full_Name 
								When @Order_By = 'Designation' then (CASE WHEN CM.Desig_dis_No  = 0 THEN CM.Designation ELSE RIGHT(REPLICATE('0',21) + CAST(CM.Desig_dis_No AS VARCHAR), 21)   END)
							End ,Case When IsNumeric(Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"',''), 20)
									 When IsNumeric(Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
									 Else Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','') End 
						
							
					 Declare @column nvarchar(max)
					 Declare @column_Sum nvarchar(max)
					 
					 
					 
					 Select * into #temp_CTCMaster_Sum From #temp_CTCMaster
						
					 
					 Update #temp_CTCMaster_Sum
						SET Cmp_ID = '0',Emp_ID = '0',Emp_Code = '0',Branch_ID = '0',Desig_dis_No = '0',
						Emp_Full_Name ='Total'
					 
					 SET @column = ''
					 SET @column_Sum = ''
					
					 SELECT 	@column_Sum = 
									CASE WHEN @column_Sum = '' Then
										(case system_type_id when 108 then 
											'Sum(isnull(' + QUOTENAME(name) + ',0)) as [' + name + ']'
											else
											','''' as '+ name +'' 
										end)
									Else
										@column_Sum +
										(case system_type_id when 108 then 
													', Sum(isnull(' + QUOTENAME(name) + ',0)) as [' + name + ']'
												else
													','''' as '+ name +'' 
										end)	
									End,
							
								@column = 
									(CASE WHEN @column = '' Then 'isnull(' + QUOTENAME(name) + ',0) as [' + name + ']'
								Else
									@column + ',isnull(' + QUOTENAME(name) + ',0) as [' + name + ']'
								End)
							
							FROM tempdb.sys.columns
							WHERE [object_id] = OBJECT_ID('tempdb..#temp_CTCMaster') 
							
							
							--Set @column_Sum = Replace(@column_Sum,''' as Emp_Full_Name','''Emp_Full_Name'' as Emp_Full_Name')
							Set @column_Sum = Replace(@column_Sum,''''' as Emp_Full_Name','Emp_Full_Name')
						
					--Select @column_Sum
					
					Declare @w_sql varchar(max)
					SET @w_sql = ''	

					SET @w_sql = 'Select ' + @column + ' From #temp_CTCMaster Union Select ' +  @column_Sum + ' From #temp_CTCMaster_Sum group by Emp_Full_Name  order by Cmp_ID DESC';
						
					----PRINT @w_sql
					EXEC(@w_sql); 
	end
	else 
	begin
		
		Declare @String_1 Varchar(Max)
		Declare @String_4 Varchar(Max)
		Set @String_1 = ''
		If exists (Select 1 from sys.objects where name = 'tempgroup2')
			drop TABLE tempgroup2
		
		If exists (Select 1 from sys.objects where name = 'tempgroup3')
			drop TABLE tempgroup3
			
		if @summary2 is not null
			Begin
				Set @String_2 = 'Select (CASE WHEN '+ @summary2 +'=''0'' THEN ''Branch'' When '+ @summary2 +' =''1'' Then ''Grade'' When '+ @Summary2 +' =''2'' Then ''Category'' When '+ @summary2 +' =''3'' Then ''Department'' When '+ @summary2 +' =''4'' Then ''Designation'' When '+ @summary2 +' =''5'' Then ''TypeName'' When '+ @summary2 +' =''6'' Then ''Division'' When '+ @Summary2 +' =''7'' Then ''sub_vertical'' When '+ @Summary2 +' =''8'' Then ''sub_branch'' When '+ @summary2 +' =''9'' Then ''Segment_Name'' When '+ @summary2 +' =''10'' Then ''Center_Code'' End ) as Description into tempgroup2'
				exec(@String_2)
				Select @String_2 = Description From tempgroup2
				set @String_4 = @String_2
				Set @String_2 = ','+ @String_2
			End 
			
		if @summary3 is not null
			Begin
				Set @String_3 = 'Select (CASE WHEN '+ @summary3 +'=''0'' THEN ''Branch'' When '+ @summary3 +' =''1'' Then ''Grade'' When '+ @summary3 +' =''2'' Then ''Category'' When '+ @summary3 +' =''3'' Then ''Department'' When '+ @summary3 +' =''4'' Then ''Designation'' When '+ @summary3 +' =''5'' Then ''TypeName'' When '+ @summary3 +' =''6'' Then ''Division'' When '+ @summary3 +' =''7'' Then ''sub_vertical'' When '+ @summary3 +' =''8'' Then ''sub_branch'' When '+ @summary3 +' =''9'' Then ''Segment_Name'' When '+ @summary3 +' =''10'' Then ''Center_Code'' End ) as Description into tempgroup3'
				exec(@String_3)
				Select @String_3 = Description From tempgroup3
				Set @String_3 = ','+ @String_3
			End		
	--Added By Jimit 18012018

		IF @TYPE = '5' 
			BEGIN
					If exists (Select 1 from sys.objects where name = 'tempgroup')
						drop TABLE tempgroup
					
					DECLARE @STRING1 AS VARCHAR(MAX)

					--delete from #CTCMAST where Net_Amount = 0

					--select	* 
					--from	#CTCMast CM Inner JOIN
					--		T0200_MONTHLY_SALARY MS ON Ms.EMP_Id = Cm.Emp_Id and month(month_End_date) = 
					--		month(@To_date) and Year(month_End_date) = year(@To_date)	
	
					IF @SUMMARY IS NOT NULL
					BEGIN
						SET @STRING1 = 'SELECT (CASE WHEN '+ @SUMMARY +'=''0'' THEN ''BRANCH'' WHEN '+ @SUMMARY +' =''1'' THEN ''GRADE'' WHEN '+ @SUMMARY +' =''2'' THEN ''CATEGORY'' WHEN '+ @SUMMARY +' =''3'' THEN ''DEPARTMENT'' WHEN '+ @SUMMARY +' =''4'' THEN ''DESIGNATION'' WHEN '+ @SUMMARY +' =''5'' THEN ''TYPENAME'' WHEN '+ @SUMMARY +' =''6'' THEN ''DIVISION'' WHEN '+ @SUMMARY +' =''7'' THEN ''SUB_VERTICAL'' WHEN '+ @SUMMARY +' =''8'' THEN ''SUB_BRANCH'' WHEN '+ @SUMMARY +' =''9'' THEN ''SEGMENT_NAME'' WHEN '+ @SUMMARY +' =''10'' THEN ''CENTER_CODE'' END ) AS DESCRIPTION INTO TEMPGROUP'
						EXEC(@STRING1)
						SELECT @STRING1 = DESCRIPTION FROM TEMPGROUP	
					END 
					
					DECLARE @GROUP_1 VARCHAR(64) 
					DECLARE @GROUP_2 VARCHAR(64) 
					SET @GROUP_2 = Isnull(@STRING_4,'.Not Assigned')
					SET @GROUP_1 = @STRING1

					CREATE TABLE #ROWDATA
					(
						EMP_ID	NUMERIC,
						GROUP1	VARCHAR(64),
						GROUP2	VARCHAR(64),
						GROUPVALUE NUMERIC(18,4)
					)

					CREATE TABLE #GROUPDATA
					(
						ROW_ID	    INT,
						GROUPLABEL	VARCHAR(64),
						LABEL	    VARCHAR(64),						
						LABELVALUE  NUMERIC(18,4)
					)		

					SET @AVG_EMP = DATEDIFF(MM,@FROM_DATE,@TO_DATE) + 1					
					
					DECLARE @MONTH Varchar(2)
					DECLARE @YEAR Varchar(4)

					SET @MONTH = MONTH(@TO_DATE)
					SET @YEAR = YEAR(@TO_DATE)

					

					DECLARE @SQL AS NVARCHAR(MAX)
					SET @SQL = 'INSERT	INTO #ROWDATA(EMP_ID, GROUP1, GROUP2, GROUPVALUE)
								SELECT	CM.EMP_ID,' + @GROUP_1 + ', ' + @GROUP_2 + ',CM.NET_AMOUNT 
								FROM	#CTCMAST	CM Inner JOIN
										T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON Ms.EMP_Id = Cm.Emp_Id and month(month_End_date) = 
											'+ @MONTH +' AND YEAR(MONTH_END_DATE) = '+ @YEAR + ''										

					EXEC SP_EXECUTESQL @SQL 
					
					
					INSERT INTO #GROUPDATA (ROW_ID,GROUPLABEL, LABEL, LABELVALUE)
					SELECT	ROW_NUMBER() OVER(ORDER BY GROUP1,GROUP2,ID) AS ROW_ID,GROUP1, LABEL, LABELVALUE
					FROM	(SELECT	1 AS ID,GROUP1 ,  GROUP2 + '#SALARY' AS LABEL, SUM(GROUPVALUE) AS LABELVALUE ,GROUP2
							
							 FROM #ROWDATA 
							 GROUP BY GROUP1,GROUP2
							 UNION ALL
							 SELECT 2 AS ID,GROUP1,  GROUP2 + '#NO OF EMPLOYEE' AS LABEL, COUNT(1) AS LABELVALUE ,GROUP2
							 FROM #ROWDATA 
							 GROUP BY GROUP1,GROUP2) T
							 											
					
					
					DECLARE @SUMCOL VARCHAR(MAX)
					SELECT	@COLS = COALESCE(@COLS + ',','')  + '[' + ISNULL(PL.LABEL,'')  + ']'
					FROM	(
								SELECT		distinct LABEL
								FROM		#GROUPDATA									
							) PL
					ORDER BY LABEL

					SELECT	@SUMCOL = COALESCE(@SUMCOL + ',','')  + 'SUM(' + ISNULL('[' + PL.LABEL + ']','')  + ')'
					FROM	(
								SELECT		distinct LABEL
								FROM		#GROUPDATA									
							) PL
					ORDER BY LABEL
														
																	
					SET @STRING = '	SELECT  ROW_NUMBER() OVER (ORDER BY GROUPLABEL) AS SR_NO,*											 
									INTO	##SALARY_FINAL
									FROM	(
												SELECT  GROUPLABEL,LABEL,LABELVALUE
												FROM	#GROUPDATA
											) T
											PIVOT (
												MAX(LABELVALUE) FOR LABEL IN (' + @COLS + ')
											) PVT'				
																		
					EXEC (@STRING)
					
					DECLARE @COUNT  NUMERIC = 3
					DECLARE @MONTH_YEAR DATETIME
					
					DECLARE @COLUMN_NAME VARCHAR(MAX)
					DECLARE @SUMMONTHCOL VARCHAR(MAX)
					

					WHILE(@COUNT > 0)
						BEGIN
							 SET @MONTH_YEAR = DATEADD(M,-@COUNT,@To_date)
							 SET @COLUMN_NAME = '[LAST 3 MONTH SALARY#' + LEFT(DATENAME(M,@MONTH_YEAR),3) + '_' + CONVERT(VARCHAR(4),DATEPART(YEAR,@MONTH_YEAR)) + ']'

							 SET @COLS = COALESCE(@COLS + ',','')  + @COLUMN_NAME
							 SET @SUMMONTHCOL = COALESCE(@SUMMONTHCOL + ',','')  + 'SUM(ISNULL([LAST 3 MONTH SALARY#' + LEFT(DATENAME(M,@MONTH_YEAR),3) + '_' + CONVERT(VARCHAR(4),DATEPART(YEAR,@MONTH_YEAR)) + '],0))'

							 SET @SQL = 'ALTER TABLE  ##SALARY_FINAL ADD ' +  @COLUMN_NAME + ' NUMERIC(18,2) DEFAULT 0'
							 
							 EXEC SP_EXECUTESQL @SQL					 

							 

							 SET @SQL = 'UPDATE R
										SET    ' + @COLUMN_NAME + ' = Q.Net_Amount									
										FROM   ##SALARY_FINAL R INNER JOIN
												(
													SELECT	SUM(ISNULL(NET_AMOUNT,0)) AS NET_AMOUNT,R.GROUP1 AS LABEL_NAME
													FROM	T0200_MONTHLY_SALARY MS WITH (NOLOCK) Inner join  
															#ROWDATA R ON R.Emp_Id = Ms.Emp_Id 
													WHERE	MONTH(MOnth_END_DATE) = ' + CONVERT(VARCHAR(15),MONTH(@MONTH_YEAR),103) + ' AND
															YEAR(MOnth_END_DATE) = ' + CONVERT(VARCHAR(15),YEAR(@MONTH_YEAR),103) + ' and
															CMP_ID = ' + CONVERT(VARCHAR(5),@COMPANY_ID) + '
													GROUP BY R.GROUP1
												)Q ON Q.LABEL_NAME = R.GROUPLABEL'	
							 Print 	@SQL									
							 EXEC SP_EXECUTESQL @SQL						 
							 SET @COUNT = @COUNT - 1
						END
						
						
												
						SET @SQL = 'INSERT INTO ##SALARY_FINAL
									SELECT MAX(SR_NO) + 1,''GRAND TOTAL'',' + @SUMCOL + ',' + @SUMMONTHCOL + '
									FROM  ##SALARY_FINAL'
					

						--PRINT @SQL
						EXEC SP_EXECUTESQL @SQL	

						SET @SQL = 'EXEC tempdb..sp_rename ''dbo.##SALARY_FINAL.[GROUPLABEL]'',''' + @GROUP_1 + ''',''COLUMN'''
						--PRINT @SQL
						EXEC SP_EXECUTESQL @SQL

						

						SELECT * FROM ##SALARY_FINAL
						Order By SR_NO
						

						DROp TABLE ##SALARY_FINAL

					RETURN				
			END
		--Ended
		
		if @Summary='0' --------for GroupBy Branch---------------------------
		begin
		
		if @Type = '3' -- For Employee Detail & Summary 
			Begin
				
				
				
				--Set @String_1 = 'select 0 as flag,CM.Alpha_Emp_Code,CM.Emp_Full_Name, CM.Branch_ID,CM.Branch as Branch_Name'+ @String_2 +''+ @String_3 +',1 As Total_Emp, CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Other_Allow as Other_Allowance,CM.Actual_CTC as CTC,CM.Gratuity_Amount as Gratuity_Amount,CM.arear_amount as Arear_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,CM.Settl_Salary as Settlement_Salary,cm.net_amount as Net_Amount,CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holidy_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''
		
				--Set @String_1 = @String_1 + ' from #CTCMast CM Where Sal_Cal_Day <> 0'
				
				--set @String = ' select 1 as flag,'''' as Alpha_Emp_Code, '''' as Emp_Full_Name, CM.Branch_ID,CM.Branch as Branch_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Uniform_Refund_Amount) as Uniform_Refund_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(isnull(cm.Uniform_Dedu_Amount,0)) as Uniform_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days'+ @sum_of_allownaces_earning_reim +''

				--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By Branch_Id,branch '+ @String_2 +''+ @String_3 +' Order By Branch_Id,branch'+ @String_2 +''+ @String_3 +',flag'
			
				--exec(@String_1 +' Union ALL ' + @String)

			
				
				Set @String_1 = 'select 0 as flag, ROW_NUMBER() OVER (Order by CM.Branch) As Row_ID, CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.Branch as Branch_Name'+ @String_2 +''+ @String_3 +',1 As Total_Emp, 
				CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gratuity_Amount as Gratuity_Amount,Total_Earning As Total_Earning,Basic_Arrear As Basic_Arrear'
				+ @allownaces_earning_arear +',Total_Earning_Arrear as Total_Earning_Arrear, CM.Other_Allow as Other_Allowance, CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Actual_CTC as CTC,cm.advance_amount as Advance_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.M_HO_OT_Hours as Holiday_OT_Hours,cm.M_HO_OT_Amount as Holiday_OT_Amount,cm.M_WO_OT_Hours as Weekoff_OT_Hours,cm.M_WO_OT_Amount as Weekoff_OT_Amount, cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,ISNULL(Total_Deduction,0) as Total_Deduction '
				+ @allownaces_deduct_arear + ',Arear_Deduction As Arear_Deduction, Net_Total_Deduction as Net_Total_Deduction,cm.net_amount as Net_Amount,Net_Round As Net_Round, Total_Net As Total_Net '+ @Allownaces_Earning_CTC +' ,(Net_Round + CM.Gross_Salary '+ @Allownaces_Earning_CTC_Total +') AS Total_Amount,
				CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holiday_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +',CM.Date_of_Left as Emp_Left_Date,(CASE WHEN CM.IS_FNF =1 THEN ''FNF'' ELSE CM.salary_status END) as Salary_Status'

				--Set @String_1 = @String_1 + ' INTO ##BRANCH from #CTCMast CM' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput
				
				IF(ISNULL(@REPORT_TYPE,0) = 1)
					BEGIN
						Set @String_1 = @String_1 + ' INTO ##BRANCH from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput cera	REQUI
					END
				ELSE IF(ISNULL(@Report_type,0) = 2)
					BEGIN
						Set @String_1 = @String_1 + ' INTO ##BRANCH from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 ' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput
					END
				ELSE
					BEGIN
						Set @String_1 = @String_1 + ' INTO ##BRANCH from #CTCMast CM WHERE Sal_Cal_Day <> 0  ' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput
					END 
				 
				EXEC(@String_1)
				
				
				
				--if @String_2 <> '' and @String_3 <> ''
				--	Begin
				--		Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
				--	End
				--Else if @String_2 <> ''
				--	Begin
				--		Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
				--	End 
				--Else if @String_3 <> ''
				--	Begin
				--		Set @String_3 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
				--	End
				
				IF EXISTS(SELECT 1 FROM ##BRANCH)
					BEGIN
							
						set @String = 'Insert into ##BRANCH select 1 as flag,(IsNull(Max(Row_ID),0)+1),'''' As Alpha_Emp_Code ,''Total'' As Emp_Full_Name,Branch_Name as Branch_Name'+ @String_2 +''+ @String_3 +',1 As Total_Emp,
						SUM(Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(Other_Allowance)as Other_Allowance, SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CTC) as CTC,SUM(advance_amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(revenue_amount) as Revenue_Amount,SUM(lwf_amount)as LWF_Amount,SUM(isnull(Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_Day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +','''' as Emp_Left_Date,count(1) AS Total_Salary_Status  
						FROM ##BRANCH Group by Branch_Name' + @String_2 +''+ @String_3
						
						exec(@String)
						
						set @String = 'Select * FROM ##BRANCH Order By Branch_Name '+ @String_2 +''+ @String_3 +',flag';
						
						exec(@String)
						
						set @String = 'DROP TABLE ##BRANCH';	
					
						exec(@String)
					 END
				 ELSE
					 BEGIN
						set @String = 'DROP TABLE ##BRANCH';	
						exec(@String)
					 END
					
				
				
			End
		Else   -- For Only Summary Grouping Wise 
			Begin
				
				--set @String = ' select 0 as flag, CM.Branch_ID,CM.Branch as Branch_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

				--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By Branch_Id,branch'+ @String_2 +''+ @String_3 +''
			
				--exec(@String)


					set @Avg_Emp = DATEDIFF(MM,@From_Date,@To_Date) + 1
					
					set @String = ' select 0 as Flag, ROW_NUMBER() OVER (Order by CM.Branch) As Row_ID,CM.Branch as Branch_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
					Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
					+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
					+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
					SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

					--set @String = @String + ' INTO ##BRANCH from #CTCMast CM  group By Branch'+ @String_2 +''+ @String_3 +'' COMMENTED BY RAJPUT ON 22062018
					IF(ISNULL(@REPORT_TYPE,0) = 1)
						BEGIN
							set @String = @String + ' INTO ##BRANCH from #CTCMast CM WHERE CM.IS_FNF <> 1  group By Branch'+ @String_2 +''+ @String_3 +''
							
						END
					ELSE IF(ISNULL(@Report_type,0) = 2)
						BEGIN
							set @String = @String + ' INTO ##BRANCH from #CTCMast CM WHERE CM.IS_FNF = 1  group By Branch'+ @String_2 +''+ @String_3 +''
						END
					ELSE
						BEGIN
							set @String = @String + ' INTO ##BRANCH from #CTCMast CM  group By Branch'+ @String_2 +''+ @String_3 +''
						END 
						
					exec(@String)
					
					if @String_2 <> '' and @String_3 <> ''
						Begin
							Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
						End
					Else if @String_2 <> ''
						Begin
							Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
						End 
					Else if @String_3 <> ''
						Begin
							Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
						End
					
					IF EXISTS(SELECT 1 FROM ##BRANCH)
						BEGIN
							set @String = 'Insert into ##BRANCH Select 0 as Flag,(IsNull(Max(Row_ID),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),Round((Sum(Total_Emp)/'  + cast(@Avg_Emp as varchar(10)) +'),0) ,Sum(Basic_Salary) ' + @sum_of_allownaces_earning + ',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning, Sum(Basic_Arrear) As Basic_Arrear'
							+ @sum_of_allownaces_earning_Arear + ',Sum(Total_Earning_Arrear) as Total_Earning_Arrear,SUM(Other_Allowance)as Other_Allowance,SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CTC) as CTC,SUM(Advance_Amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(Revenue_Amount) as Revenue_Amount,SUM(LWF_Amount)as LWF_Amount,SUM(Gate_Pass_Amount) as Gate_Pass_Amount,SUM(Asset_Installment_Amount) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction'
							+@sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,Sum(Total_Amount) AS Total_Amount,
							SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(Total_Paid_Leave_Days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##BRANCH';

							exec(@String)
							
							set @String = 'Select * FROM ##BRANCH Order By Row_ID';
							
							exec(@String)
							
							set @String = 'DROP TABLE ##BRANCH';	
							
							exec(@String)
						end
					ELSE
						 BEGIN
							set @String = 'DROP TABLE ##BRANCH';	
							exec(@String)
						 END
						
					
				
			End
		end
		else if @Summary='1' --------for GroupBy Grade---------------------------
		begin
		
		if @Type = '3' -- For Employee Detail & Summary 
			Begin
				--Set @String_1 = 'select 0 as flag,CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.Grade as Grade'+ @String_2 +''+ @String_3 +',1 As Total_Emp, CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Other_Allow as Other_Allowance,CM.Actual_CTC as CTC,cm.advance_amount as Advance_Amount,CM.arear_amount as Arear_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,CM.Settl_Salary as Settlement_Salary,cm.net_amount as Net_Amount,CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holidy_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''
		
				--Set @String_1 = @String_1 + ' from #CTCMast CM Where Sal_Cal_Day <> 0'
				
				--set @String = 'select 1 as flag,'''' as Alpha_Emp_Code, '''' as Emp_Full_Name, CM.Grade as Grade'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

				--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By Grade'+ @String_2 +''+ @String_3 +' Order By Grade'+ @String_2 +''+ @String_3 +',flag'
			
				--exec(@String_1 +' Union ALL ' + @String)

				Set @String_1 = 'select 0 as flag, ROW_NUMBER() OVER (Order by CM.Grade) As Row_ID, CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.Grade as Grade'+ @String_2 +''+ @String_3 +',1 As Total_Emp, 
					CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gratuity_Amount as Gratuity_Amount,Total_Earning As Total_Earning,Basic_Arrear As Basic_Arrear'
					+ @allownaces_earning_arear +',Total_Earning_Arrear as Total_Earning_Arrear, CM.Other_Allow as Other_Allowance, CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Actual_CTC as CTC,cm.advance_amount as Advance_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.M_HO_OT_Hours as Holiday_OT_Hours,cm.M_HO_OT_Amount as Holiday_OT_Amount,cm.M_WO_OT_Hours as Weekoff_OT_Hours,cm.M_WO_OT_Amount as Weekoff_OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,ISNULL(Total_Deduction,0) as Total_Deduction '
					+ @allownaces_deduct_arear + ',Arear_Deduction As Arear_Deduction, Net_Total_Deduction as Net_Total_Deduction,cm.net_amount as Net_Amount,Net_Round As Net_Round, Total_Net As Total_Net '+ @Allownaces_Earning_CTC +' ,(Net_Round + CM.Gross_Salary '+ @Allownaces_Earning_CTC_Total +') AS Total_Amount,
					CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holiday_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''

				--Set @String_1 = @String_1 + ' INTO ##GRADE from #CTCMast CM ' COMMENTED ON 25062018
				---- ADDED BY RAJPUT ON 25062018 ----
				IF(ISNULL(@REPORT_TYPE,0) = 1) 
					BEGIN
						Set @String_1 = @String_1 + ' INTO ##GRADE from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput cera	REQUI
					END
				ELSE IF(ISNULL(@Report_type,0) = 2)
					BEGIN
						Set @String_1 = @String_1 + ' INTO ##GRADE from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 ' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput
					END
				ELSE
					BEGIN
						Set @String_1 = @String_1 + ' INTO ##GRADE from #CTCMast CM WHERE Sal_Cal_Day <> 0  ' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput
					END 
				 
				EXEC(@String_1)
				---- END -----
				
				if @String_2 <> '' and @String_3 <> ''
					Begin
						Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
					End
				Else if @String_2 <> ''
					Begin
						Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
					End 
				Else if @String_3 <> ''
					Begin
						Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
					End
				
				
				IF EXISTS(SELECT 1 FROM ##GRADE)
					BEGIN
						set @String = 'Insert into ##GRADE select 0 as flag,(IsNull(Max(Row_ID),0)+1),'''' As Alpha_Emp_Code ,''Total'' As Emp_Full_Name,''Total'' as Grade'+ @String_2 +''+ @String_3 +',1 As Total_Emp,
						SUM(Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,sum(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(Other_Allowance)as Other_Allowance, SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CTC) as CTC,SUM(advance_amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(revenue_amount) as Revenue_Amount,SUM(lwf_amount)as LWF_Amount,SUM(isnull(Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_Day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##GRADE'

						exec(@String)
						
						set @String = 'Select * FROM ##GRADE Order By Row_ID';
						
						exec(@String)
						
						set @String = 'DROP TABLE ##GRADE';	
					
						exec(@String)			
					END
				ELSE
					BEGIN
						
						set @String = 'DROP TABLE ##GRADE';	
						exec(@String)		
					
					END	
			End
		Else
			Begin
				--set @String = ' select 0 as flag, CM.Grade as Grade'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

				--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By Grade'+ @String_2 +''+ @String_3 +''

				--exec(@String)

					set @Avg_Emp = DATEDIFF(MM,@From_Date,@To_Date) + 1
					
					set @String = ' select 0 as Flag, ROW_NUMBER() OVER (Order by CM.Grade) As Row_ID,CM.Grade as Grade'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
					Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
					+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,
					SUM(cm.M_HO_OT_Hours) as Holiday_OT_Hours,SUM(cm.M_HO_OT_Amount) as Holiday_OT_Amount,SUM(cm.M_WO_OT_Hours) as Weekoff_OT_Hours,SUM(cm.M_WO_OT_Amount) as Weekoff_OT_Amount
					,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
					+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
					SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '


					--set @String = @String + ' INTO ##GRADE from #CTCMast CM  group By Grade'+ @String_2 +''+ @String_3 +'' -- COMMENTED BY RAJPUT ON 25062018
					
					---- ADDED BY RAJPUT ON 25062018 ----
					IF(ISNULL(@REPORT_TYPE,0) = 1) 
						BEGIN
							Set @String = @String + ' INTO ##GRADE from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1 group By Grade'+ @String_2 +''+ @String_3 +'' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput cera	REQUI
						END
					ELSE IF(ISNULL(@Report_type,0) = 2)
						BEGIN
							Set @String = @String + ' INTO ##GRADE from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 group By Grade'+ @String_2 +''+ @String_3 +'' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput
						END
					ELSE
						BEGIN
							Set @String = @String + ' INTO ##GRADE from #CTCMast CM WHERE Sal_Cal_Day <> 0  group By Grade'+ @String_2 +''+ @String_3 +'' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput
						END 
					
					exec(@String)
					--- END ----
					
					if @String_2 <> '' and @String_3 <> ''
						Begin
							Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
						End
					Else if @String_2 <> ''
						Begin
							Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
						End 
					Else if @String_3 <> ''
						Begin
							Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
						End
					
					
					IF EXISTS(SELECT 1 FROM ##GRADE)
						BEGIN
							set @String = 'Insert into ##GRADE Select 0 as Flag,(IsNull(Max(Row_ID),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),Round((Sum(Total_Emp)/'  + cast(@Avg_Emp as varchar(10)) +'),0) ,Sum(Basic_Salary) ' + @sum_of_allownaces_earning + ',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning, Sum(Basic_Arrear) As Basic_Arrear'
							+ @sum_of_allownaces_earning_Arear + ',Sum(Total_Earning_Arrear) as Total_Earning_Arrear,SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(Other_Allowance)as Other_Allowance,SUM(CTC) as CTC,SUM(Advance_Amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(Revenue_Amount) as Revenue_Amount,SUM(LWF_Amount)as LWF_Amount,SUM(Gate_Pass_Amount) as Gate_Pass_Amount,SUM(Asset_Installment_Amount) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction'
							+@sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,Sum(Total_Amount) AS Total_Amount,
							SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(Total_Paid_Leave_Days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##GRADE';

							exec(@String)
							
							set @String = 'Select * FROM ##GRADE Order By Row_ID';
							
							exec(@String)
							
							set @String = 'DROP TABLE ##GRADE';	
							
							exec(@String)		
						END		
					ELSE
						BEGIN
							set @String = 'DROP TABLE ##GRADE';	
							exec(@String)		
						END
			End
		
		end
		else if @Summary='2' --------for GroupBy Category_Name---------------------------
		begin
			if @Type = '3' -- For Employee Detail & Summary 
				Begin
					--Set @String_1 = 'select 0 as flag,CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.Category'+ @String_2 +''+ @String_3 +',1 As Total_Emp, CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Other_Allow as Other_Allowance,CM.Actual_CTC as CTC,cm.advance_amount as Advance_Amount,CM.arear_amount as Arear_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,CM.Settl_Salary as Settlement_Salary,cm.net_amount as Net_Amount,CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holidy_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''
			
					--Set @String_1 = @String_1 + ' from #CTCMast CM Where Sal_Cal_Day <> 0'
					
					--set @String = ' select 1 as flag,'''' as Alpha_Emp_Code, '''' as Emp_Full_Name, CM.Category'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

					--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By Category'+ @String_2 +''+ @String_3 +' Order By Category'+ @String_2 +''+ @String_3 +',flag'
				
					--exec(@String_1 +' Union ALL ' + @String)

					Set @String_1 = 'select 0 as flag, ROW_NUMBER() OVER (Order by CM.Category) As Row_ID, CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.Category as Category'+ @String_2 +''+ @String_3 +',1 As Total_Emp, 
						CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gratuity_Amount as Gratuity_Amount,Total_Earning As Total_Earning,Basic_Arrear As Basic_Arrear'
						+ @allownaces_earning_arear +',Total_Earning_Arrear as Total_Earning_Arrear, CM.Other_Allow as Other_Allowance, CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Actual_CTC as CTC,CM.advance_amount as advance_amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.M_HO_OT_Hours as Holiday_OT_Hours,cm.M_HO_OT_Amount as Holiday_OT_Amount,cm.M_WO_OT_Hours as Weekoff_OT_Hours,cm.M_WO_OT_Amount as Weekoff_OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,ISNULL(Total_Deduction,0) as Total_Deduction '
						+ @allownaces_deduct_arear + ',Arear_Deduction As Arear_Deduction, Net_Total_Deduction as Net_Total_Deduction,cm.net_amount as Net_Amount,Net_Round As Net_Round, Total_Net As Total_Net '+ @Allownaces_Earning_CTC +' ,(Net_Round + CM.Gross_Salary '+ @Allownaces_Earning_CTC_Total +') AS Total_Amount,
						CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holiday_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''

					--Set @String_1 = @String_1 + ' INTO ##CATEGORY from #CTCMast CM ' COMMENTED BY RAJPUT ON 25062018
					
					---- ADDED BY RAJPUT ON 25062018 ----
					IF(ISNULL(@REPORT_TYPE,0) = 1)
						BEGIN
							Set @String_1 = @String_1 + ' INTO ##CATEGORY from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput cera	REQUI
						END
					ELSE IF(ISNULL(@Report_type,0) = 2)
						BEGIN
							Set @String_1 = @String_1 + ' INTO ##CATEGORY from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 ' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput
						END
					ELSE
						BEGIN
							Set @String_1 = @String_1 + ' INTO ##CATEGORY from #CTCMast CM WHERE Sal_Cal_Day <> 0  ' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput
						END 
					EXEC(@String_1)
					
					---- END ----
					
					if @String_2 <> '' and @String_3 <> ''
						Begin
							Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
						End
					Else if @String_2 <> ''
						Begin
							Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
						End 
					Else if @String_3 <> ''
						Begin
							Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
						End
					
					IF EXISTS(SELECT 1 FROM ##CATEGORY)
						BEGIN
							set @String = 'Insert into ##CATEGORY select 0 as flag,(IsNull(Max(Row_ID),0)+1),'''' As Alpha_Emp_Code ,''Total'' As Emp_Full_Name,''Total'' as Category'+ @String_2 +''+ @String_3 +',1 As Total_Emp,
							SUM(Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
							+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(Other_Allowance)as Other_Allowance, SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CTC) as CTC,SUM(advance_amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(revenue_amount) as Revenue_Amount,SUM(lwf_amount)as LWF_Amount,SUM(isnull(Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
							+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
							SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_Day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##CATEGORY'

							exec(@String)
							
							set @String = 'Select * FROM ##CATEGORY Order By Row_ID';
							
							exec(@String)
							
							set @String = 'DROP TABLE ##CATEGORY';	
						
							exec(@String)			
						END
					ELSE
						BEGIN
							set @String = 'DROP TABLE ##CATEGORY';	
							exec(@String)	
						END	
					
				End
			Else
				Begin
					--set @String = ' select 0 as flag, CM.Category'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
					--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By Category'+ @String_2 +''+ @String_3 +''
					--exec(@String)

					set @Avg_Emp = DATEDIFF(MM,@From_Date,@To_Date) + 1
					
					set @String = ' select 0 as Flag, ROW_NUMBER() OVER (Order by CM.Category) As Row_ID,CM.Category as Category'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
					Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
					+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,
					SUM(cm.M_HO_OT_Hours) as Holiday_OT_Hours,SUM(cm.M_HO_OT_Amount) as Holiday_OT_Amount,SUM(cm.M_WO_OT_Hours) as Weekoff_OT_Hours,SUM(cm.M_WO_OT_Amount) as Weekoff_OT_Amount
					,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
					+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
					SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '


					-- set @String = @String + ' INTO ##CATEGORY from #CTCMast CM  group By Category'+ @String_2 +''+ @String_3 +'' COMMENTED BY RAJPUT ON 25062018
					
					---- ADDED BY RAJPUT ON 25062018 ----
					IF(ISNULL(@REPORT_TYPE,0) = 1)
						BEGIN
							Set @String = @String + ' INTO ##CATEGORY from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1 group By Category'+ @String_2 +''+ @String_3 +'' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput cera	REQUI
						END
					ELSE IF(ISNULL(@Report_type,0) = 2)
						BEGIN
							Set @String = @String + ' INTO ##CATEGORY from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 group By Category'+ @String_2 +''+ @String_3 +'' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput
						END
					ELSE
						BEGIN
							Set @String = @String + ' INTO ##CATEGORY from #CTCMast CM WHERE Sal_Cal_Day <> 0  group By Category'+ @String_2 +''+ @String_3 +'' --Where Sal_Cal_Day <> 0 commented on 11062018 by rajput
						END 
					EXEC(@String)
					---- END ----
					
					if @String_2 <> '' and @String_3 <> ''
						Begin
							Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
						End
					Else if @String_2 <> ''
						Begin
							Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
						End 
					Else if @String_3 <> ''
						Begin
							Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
						End
					
					IF EXISTS(SELECT 1 FROM ##CATEGORY)
						BEGIN
						
							set @String = 'Insert into ##CATEGORY Select 0 as Flag,(IsNull(Max(Row_ID),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),Round((Sum(Total_Emp)/'  + cast(@Avg_Emp as varchar(10)) +'),0) ,Sum(Basic_Salary) ' + @sum_of_allownaces_earning + ',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning, Sum(Basic_Arrear) As Basic_Arrear'
							+ @sum_of_allownaces_earning_Arear + ',Sum(Total_Earning_Arrear) as Total_Earning_Arrear,SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(Other_Allowance)as Other_Allowance,SUM(CTC) as CTC,SUM(Advance_Amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(Revenue_Amount) as Revenue_Amount,SUM(LWF_Amount)as LWF_Amount,SUM(Gate_Pass_Amount) as Gate_Pass_Amount,SUM(Asset_Installment_Amount) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction'
							+@sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,Sum(Total_Amount) AS Total_Amount,
							SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(Total_Paid_Leave_Days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##CATEGORY';

							exec(@String)
							
							set @String = 'Select * FROM ##CATEGORY Order By Row_ID';
							
							exec(@String)
							
							set @String = 'DROP TABLE ##CATEGORY';	
							
							exec(@String)			
						END
					ELSE
						BEGIN
							set @String = 'DROP TABLE ##CATEGORY';	
							exec(@String)		
						END	
					
				End
		end
		else if @Summary='3' --------for GroupBy Department---------------------------
		begin
		
			if @Type = '3' -- For Employee Detail & Summary 
				Begin
					
					
					--set @Avg_Emp = DATEDIFF(MM,@From_Date,@To_Date) + 1
					
					--Set @String_1 = 'select 0 as flag,CM.Alpha_Emp_Code,CM.Emp_Full_Name, CM.Department as Department'+ @String_2 +''+ @String_3 +',1 As Total_Emp,0 AS Avg_Emp, CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Other_Allow as Other_Allowance,CM.Actual_CTC as CTC,CM.Gratuity_Amount as Gratuity_Amount,CM.arear_amount as Arear_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,CM.Settl_Salary as Settlement_Salary,cm.net_amount as Net_Amount,Net_Round as Net_Round '+ @Allownaces_Earning_CTC +' ,(Net_Round + CM.Gross_Salary '+ @Allownaces_Earning_CTC_Total +') AS Total_Amount ,CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holiday_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''
			
					--Set @String_1 = @String_1 + ' from #CTCMast CM Where Sal_Cal_Day <> 0'
										
					--set @String = ' select 1 as Flag,'''' as Alpha_Emp_Code, '''' as Emp_Full_Name, CM.Department as Department'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount, SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

					--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By Department'+ @String_2 +''+ @String_3 +' Order By Department'+ @String_2 +''+ @String_3 +',flag'
													
					--exec(@String_1 +' Union ALL ' + @String)
					
						Set @String_1 = 'select 0 as flag, ROW_NUMBER() OVER (Order by CM.Department) As Row_ID, CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.Department as Department'+ @String_2 +''+ @String_3 +',1 As Total_Emp, 
							CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gratuity_Amount as Gratuity_Amount,Total_Earning As Total_Earning,Basic_Arrear As Basic_Arrear'
							+ @allownaces_earning_arear +',Total_Earning_Arrear as Total_Earning_Arrear, CM.Other_Allow as Other_Allowance, CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Actual_CTC as CTC,CM.advance_amount as Advance_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.M_HO_OT_Hours as Holiday_OT_Hours,cm.M_HO_OT_Amount as Holiday_OT_Amount,cm.M_WO_OT_Hours as Weekoff_OT_Hours,cm.M_WO_OT_Amount as Weekoff_OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,ISNULL(Total_Deduction,0) as Total_Deduction '
							+ @allownaces_deduct_arear + ',Arear_Deduction As Arear_Deduction, Net_Total_Deduction as Net_Total_Deduction,cm.net_amount as Net_Amount,Net_Round As Net_Round, Total_Net As Total_Net '+ @Allownaces_Earning_CTC +' ,(Net_Round + CM.Gross_Salary '+ @Allownaces_Earning_CTC_Total +') AS Total_Amount,
							CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holiday_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''

						--Set @String_1 = @String_1 + ' INTO ##DEPT from #CTCMast CM ' COMMENTED BY RAJPUT ON 25062018
						
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##DEPT from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1'
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##DEPT from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 ' 
							END
						ELSE
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##DEPT from #CTCMast CM WHERE Sal_Cal_Day <> 0  ' 
							END 
						 
						EXEC(@String_1)

						---- END ----
						 
						
						
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
					
						IF EXISTS(SELECT 1 FROM ##DEPT)
							BEGIN
								set @String = 'Insert into ##DEPT select 0 as flag,(IsNull(Max(Row_ID),0)+1),'''' As Alpha_Emp_Code ,''Total'' As Emp_Full_Name,''Total'' as Department'+ @String_2 +''+ @String_3 +',1 As Total_Emp,
								SUM(Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
								+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(Other_Allowance)as Other_Allowance, SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CTC) as CTC,SUM(advance_amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(revenue_amount) as Revenue_Amount,SUM(lwf_amount)as LWF_Amount,SUM(isnull(Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
								+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
								SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_Day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##DEPT'
								
								exec(@String)
								
								set @String = 'Select * FROM ##DEPT Order By Row_ID';
								
								exec(@String)
								
								set @String = 'DROP TABLE ##DEPT';	
							
								exec(@String)
							END
						ELSE
							BEGIN
								set @String = 'DROP TABLE ##DEPT';	
								exec(@String)
							END
				
				End
			Else
				BEGIN
					
					--select (Count(Emp_ID) / (DATEDIFF(MM,@From_Date,@To_Date) + 1) )AS Avg_Emp FROM #CTCMast
					
					--(Count(Emp_ID) / (DATEDIFF(MM,@From_Date,@To_Date) + 1) )AS Avg_Emp
					--Declare @Avg_Emp Numeric
					set @Avg_Emp = DATEDIFF(MM,@From_Date,@To_Date) + 1
					
					--set @String = ' select CM.Deptartment as Department,Count(Emp_ID) As Total_Emp,
					--(Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' )AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount,SUM(cm.Loan_Amount)as Loan_Amount,SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round '+ @Sum_Of_Allownaces_Earning_CTC +' ,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '
					
					
					
					set @String = ' select 0 as Flag, ROW_NUMBER() OVER (Order by CM.Department) As Row_ID,CM.Department as Department'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
					Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
					+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,
					SUM(cm.M_HO_OT_Hours) as Holiday_OT_Hours,SUM(cm.M_HO_OT_Amount) as Holiday_OT_Amount,SUM(cm.M_WO_OT_Hours) as Weekoff_OT_Hours,SUM(cm.M_WO_OT_Amount) as Weekoff_OT_Amount
					,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
					+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
					SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '


					--set @String = @String + ' INTO ##DEPT from #CTCMast CM  group By Department'+ @String_2 +''+ @String_3 +''
					
					---- ADDED BY RAJPUT ON 25062018 ----				
					IF(ISNULL(@REPORT_TYPE,0) = 1)
						BEGIN
							Set @String = @String + ' INTO ##DEPT from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1 group By Department'+ @String_2 +''+ @String_3 +''
						END
					ELSE IF(ISNULL(@Report_type,0) = 2)
						BEGIN
							Set @String = @String + ' INTO ##DEPT from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 group By Department'+ @String_2 +''+ @String_3 +'' 
						END
					ELSE
						BEGIN
							Set @String = @String + ' INTO ##DEPT from #CTCMast CM WHERE Sal_Cal_Day <> 0 group By Department'+ @String_2 +''+ @String_3 +'' 
						END 
					 
					EXEC(@String)
					---- END ----
					

					
					if @String_2 <> '' and @String_3 <> ''
						Begin
							Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
						End
					Else if @String_2 <> ''
						Begin
							Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
						End 
					Else if @String_3 <> ''
						Begin
							Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
						End
					
					
					IF EXISTS(SELECT 1 FROM ##DEPT)
						BEGIN
							set @String = 'Insert into ##DEPT Select 0 as Flag,(IsNull(Max(Row_ID),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),Round((Sum(Total_Emp)/'  + cast(@Avg_Emp as varchar(10)) +'),0) ,Sum(Basic_Salary) ' + @sum_of_allownaces_earning + ',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning, Sum(Basic_Arrear) As Basic_Arrear'
							+ @sum_of_allownaces_earning_Arear + ',Sum(Total_Earning_Arrear) as Total_Earning_Arrear,SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(Other_Allowance)as Other_Allowance,SUM(CTC) as CTC,SUM(Advance_Amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(Revenue_Amount) as Revenue_Amount,SUM(LWF_Amount)as LWF_Amount,SUM(Gate_Pass_Amount) as Gate_Pass_Amount,SUM(Asset_Installment_Amount) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction'
							+@sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,Sum(Total_Amount) AS Total_Amount,
							SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(Total_Paid_Leave_Days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##DEPT';
							
							exec(@String)
							
							set @String = 'Select * FROM ##DEPT Order By Row_ID';
							
							exec(@String)
							
							set @String = 'DROP TABLE ##DEPT';	
							
							exec(@String)
						END
					ELSE
						BEGIN
							set @String = 'DROP TABLE ##DEPT';	
							exec(@String)
						END
			End
		end
		else if @Summary='4' --------for GroupBy designation---------------------------
			begin
				set @Avg_Emp = DATEDIFF(MM,@From_Date,@To_Date) + 1
				
				if @Type = '3' -- For Employee Detail & Summary 
					Begin
						Set @String_1 = 'select 0 as flag, ROW_NUMBER() OVER (Order by CM.Designation) As Row_ID, CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.Designation as Designation'+ @String_2 +''+ @String_3 +',1 As Total_Emp, 
							CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gratuity_Amount as Gratuity_Amount,Total_Earning As Total_Earning,Basic_Arrear As Basic_Arrear'
							+ @allownaces_earning_arear +',Total_Earning_Arrear as Total_Earning_Arrear, CM.Other_Allow as Other_Allowance, CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Actual_CTC as CTC,CM.advance_amountas Advance_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.M_HO_OT_Hours as Holiday_OT_Hours,cm.M_HO_OT_Amount as Holiday_OT_Amount,cm.M_WO_OT_Hours as Weekoff_OT_Hours,cm.M_WO_OT_Amount as Weekoff_OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,ISNULL(Total_Deduction,0) as Total_Deduction '
							+ @allownaces_deduct_arear + ',Arear_Deduction As Arear_Deduction, Net_Total_Deduction as Net_Total_Deduction,cm.net_amount as Net_Amount,Net_Round As Net_Round, Total_Net As Total_Net '+ @Allownaces_Earning_CTC +' ,(Net_Round + CM.Gross_Salary '+ @Allownaces_Earning_CTC_Total +') AS Total_Amount,
							CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holiday_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''
							
							
						--set @String_1 = ' select 0 as flag,CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.Designation as Designation'+ @String_2 +''+ @String_3 +',1 As Total_Emp,
						--SUM(CM.Basic_Salary) as Basic_Salary '+ @allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						--+ @allownaces_earning_arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						--+ @allownaces_deduct_arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Allownaces_Earning_CTC_Total +') AS Total_Amount,
						--SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @allownaces_earning_reim +' '

			
						--Set @String_1 = @String_1 + ' from #CTCMast CM Where Sal_Cal_Day <> 0'
						--Set @String_1 = @String_1 + ' INTO ##DESIG from #CTCMast CM ' COMMENTED BY RAJPUT ON 25062018
						
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##DESIG from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1'
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##DESIG from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 ' 
							END
						ELSE
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##DESIG from #CTCMast CM WHERE Sal_Cal_Day <> 0  ' 
							END 
						 
						EXEC(@String_1)
						---- END ----
						
						
						----set @String = ' select 1 as flag,'''' as Alpha_Emp_Code, '''' as Emp_Full_Name, CM.Designation as Designation'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
						

						--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By CM.Alpha_Emp_Code,CM.Emp_Full_Name,Designation'+ @String_2 +''+ @String_3 +' Order By Designation'+ @String_2 +''+ @String_3 +',flag'
					
						--exec(@String_1 +' Union ALL ' + @String)
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						
						
						--set @String = 'Insert into ##DESIG Select 0 as Flag,(IsNull(Max(Row_ID),0)+1),''Total'''+ @String_2 +', Sum(Basic_Salary) ' + @sum_of_allownaces_earning + ',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,Sum(Total_Earning) As Total_Earning, Sum(Basic_Arrear) As Basic_Arrear'
						--+ @sum_of_allownaces_earning_Arear + ',Sum(Total_Earning_Arrear) as Total_Earning_Arrear,SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(Other_Allowance)as Other_Allowance,SUM(CTC) as CTC,SUM(Advance_Amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(Revenue_Amount) as Revenue_Amount,SUM(LWF_Amount)as LWF_Amount,SUM(Gate_Pass_Amount) as Gate_Pass_Amount,SUM(Asset_Installment_Amount) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction'
						--+@sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,Sum(Total_Amount) AS Total_Amount,
						--SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(Total_Paid_Leave_Days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##DESIG';
						IF EXISTS(SELECT 1 FROM ##DESIG)
							BEGIN
								set @String = 'Insert into ##DESIG select 0 as flag,(IsNull(Max(Row_ID),0)+1),'''' As Alpha_Emp_Code ,''Total'' As Emp_Full_Name,''Total'' as Designation'+ @String_2 +''+ @String_3 +',1 As Total_Emp,
								SUM(Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
								+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(Other_Allowance)as Other_Allowance, SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CTC) as CTC,SUM(advance_amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(revenue_amount) as Revenue_Amount,SUM(lwf_amount)as LWF_Amount,SUM(isnull(Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
								+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
								SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_Day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##DESIG'

								exec(@String)
								
								set @String = 'Select * FROM ##DESIG Order By Row_ID';
								
								exec(@String)
								
								set @String = 'DROP TABLE ##DESIG';	
							
								exec(@String)
							END
						ELSE
							BEGIN
								set @String = 'DROP TABLE ##DESIG';	
							
								exec(@String)
							END
					End
				Else
					Begin
						--set @String = ' select 0 as flag,CM.Designation as Designation'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +''
						
						set @String = ' select 0 as Flag, ROW_NUMBER() OVER (Order by CM.Designation) As Row_ID,CM.Designation as Designation'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,
						SUM(cm.M_HO_OT_Hours) as Holiday_OT_Hours,SUM(cm.M_HO_OT_Amount) as Holiday_OT_Amount,SUM(cm.M_WO_OT_Hours) as Weekoff_OT_Hours,SUM(cm.M_WO_OT_Amount) as Weekoff_OT_Amount
						,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '


						--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By Designation'+ @String_2 +''+ @String_3 +''
						
						--set @String = @String + ' INTO ##DESIG from #CTCMast CM  group By Designation'+ @String_2 +''+ @String_3 +'' COMMENTED BY RAJPUT ON 25062018
						
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String = @String + ' INTO ##DESIG from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1 group By Designation'+ @String_2 +''+ @String_3 +''
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String = @String + ' INTO ##DESIG from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 group By Designation'+ @String_2 +''+ @String_3 +'' 
							END
						ELSE
							BEGIN
								Set @String = @String + ' INTO ##DESIG from #CTCMast CM WHERE Sal_Cal_Day <> 0  group By Designation'+ @String_2 +''+ @String_3 +'' 
							END 
						 
						exec(@String)
						---- END ----
						
						
						
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						
						IF EXISTS(SELECT 1 FROM ##DESIG)
							BEGIN
								set @String = 'Insert into ##DESIG Select 0 as Flag,(IsNull(Max(Row_ID),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),Round((Sum(Total_Emp)/'  + cast(@Avg_Emp as varchar(10)) +'),0) ,Sum(Basic_Salary) ' + @sum_of_allownaces_earning + ',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning, Sum(Basic_Arrear) As Basic_Arrear'
								+ @sum_of_allownaces_earning_Arear + ',Sum(Total_Earning_Arrear) as Total_Earning_Arrear,SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(Other_Allowance)as Other_Allowance,SUM(CTC) as CTC,SUM(Advance_Amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(Revenue_Amount) as Revenue_Amount,SUM(LWF_Amount)as LWF_Amount,SUM(Gate_Pass_Amount) as Gate_Pass_Amount,SUM(Asset_Installment_Amount) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction'
								+@sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,Sum(Total_Amount) AS Total_Amount,
								SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(Total_Paid_Leave_Days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##DESIG';

								
								exec(@String)
								
								set @String = 'Select * FROM ##DESIG Order By Row_ID';
								
								exec(@String)
								
								set @String = 'DROP TABLE ##DESIG';	
							
								exec(@String)
							END
						ELSE
							BEGIN
								set @String = 'DROP TABLE ##DESIG';	
							
								exec(@String)
							END
					End
			end
		else if @Summary='5' --------for GroupBy TypeName---------------------------
			begin
			
				if @Type = '3' -- For Employee Detail & Summary 
					Begin
						--Set @String_1 = 'select 0 as flag,CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.TypeName as Type_Name'+ @String_2 +''+ @String_3 +',1 As Total_Emp, CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Other_Allow as Other_Allowance,CM.Actual_CTC as CTC,CM.Gratuity_Amount as Gratuity_Amount,CM.arear_amount as Arear_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,CM.Settl_Salary as Settlement_Salary,cm.net_amount as Net_Amount,CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holidy_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''
			
						--Set @String_1 = @String_1 + ' from #CTCMast CM Where Sal_Cal_Day <> 0'
						
						--set @String = ' select 1 as flag,'''' as Alpha_Emp_Code, '''' as Emp_Full_Name,CM.TypeName as Type_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

						--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By TypeName'+ @String_2 +''+ @String_3 +' Order By TypeName'+ @String_2 +''+ @String_3 +',flag'
					
						--exec(@String_1 +' Union ALL ' + @String)
						
						Set @String_1 = 'select 0 as flag, ROW_NUMBER() OVER (Order by CM.TypeName) As Row_ID, CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.TypeName as Type_Name'+ @String_2 +''+ @String_3 +',1 As Total_Emp, 
							CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gratuity_Amount as Gratuity_Amount,Total_Earning As Total_Earning,Basic_Arrear As Basic_Arrear'
							+ @allownaces_earning_arear +',Total_Earning_Arrear as Total_Earning_Arrear, CM.Other_Allow as Other_Allowance, CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Actual_CTC as CTC,CM.advance_amountas Advance_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.M_HO_OT_Hours as Holiday_OT_Hours,cm.M_HO_OT_Amount as Holiday_OT_Amount,cm.M_WO_OT_Hours as Weekoff_OT_Hours,cm.M_WO_OT_Amount as Weekoff_OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,ISNULL(Total_Deduction,0) as Total_Deduction '
							+ @allownaces_deduct_arear + ',Arear_Deduction As Arear_Deduction, Net_Total_Deduction as Net_Total_Deduction,cm.net_amount as Net_Amount,Net_Round As Net_Round, Total_Net As Total_Net '+ @Allownaces_Earning_CTC +' ,(Net_Round + CM.Gross_Salary '+ @Allownaces_Earning_CTC_Total +') AS Total_Amount,
							CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holiday_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''

						--Set @String_1 = @String_1 + ' INTO ##TYPE from #CTCMast CM ' COMMENTED BY RAJPUT ON 25062018
						
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##TYPE from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1'
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##TYPE from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 ' 
							END
						ELSE
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##TYPE from #CTCMast CM WHERE Sal_Cal_Day <> 0  ' 
							END 
						 
						EXEC(@String_1)
						---- END ----
 
						
						
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						
						
						IF EXISTS(SELECT 1 FROM ##TYPE)
							BEGIN
								set @String = 'Insert into ##TYPE select 0 as flag,(IsNull(Max(Row_ID),0)+1),'''' As Alpha_Emp_Code ,''Total'' As Emp_Full_Name,''Total'' as Type_Name'+ @String_2 +''+ @String_3 +',1 As Total_Emp,
								SUM(Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
								+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(Other_Allowance)as Other_Allowance, SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CTC) as CTC,SUM(advance_amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(revenue_amount) as Revenue_Amount,SUM(lwf_amount)as LWF_Amount,SUM(isnull(Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
								+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
								SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_Day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##TYPE'

								exec(@String)
								
								set @String = 'Select * FROM ##TYPE Order By Row_ID';
								
								exec(@String)
								
								set @String = 'DROP TABLE ##TYPE';	
							
								exec(@String)		
							END
						ELSE
							BEGIN
								set @String = 'DROP TABLE ##TYPE';	
							
								exec(@String)	
							END
											
					End
				Else
					Begin
						--set @String = ' select 0 as flag,CM.TypeName as Type_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +''
						--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By TypeName'+ @String_2 +''+ @String_3 +''
						--exec(@String)
						
						set @Avg_Emp = DATEDIFF(MM,@From_Date,@To_Date) + 1
						
						set @String = ' select 0 as Flag, ROW_NUMBER() OVER (Order by CM.TypeName) As Row_ID,CM.TypeName as Type_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,
						SUM(cm.M_HO_OT_Hours) as Holiday_OT_Hours,SUM(cm.M_HO_OT_Amount) as Holiday_OT_Amount,SUM(cm.M_WO_OT_Hours) as Weekoff_OT_Hours,SUM(cm.M_WO_OT_Amount) as Weekoff_OT_Amount
						,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '


						--set @String = @String + ' INTO ##TYPE from #CTCMast CM  group By TypeName'+ @String_2 +''+ @String_3 +'' COMMENTED BY RAJPUT ON 25062018
						
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String = @String + ' INTO ##TYPE from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1 group By TypeName'+ @String_2 +''+ @String_3 +''
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String = @String + ' INTO ##TYPE from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 group By TypeName'+ @String_2 +''+ @String_3 +'' 
							END
						ELSE
							BEGIN
								Set @String = @String + ' INTO ##TYPE from #CTCMast CM WHERE Sal_Cal_Day <> 0 group By TypeName'+ @String_2 +''+ @String_3 +'' 
							END 
						 
						exec(@String)
						---- END ----
						
						
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						
						
						IF EXISTS(SELECT 1 FROM ##TYPE)
							BEGIN
								set @String = 'Insert into ##TYPE Select 0 as Flag,(IsNull(Max(Row_ID),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),Round((Sum(Total_Emp)/'  + cast(@Avg_Emp as varchar(10)) +'),0) ,Sum(Basic_Salary) ' + @sum_of_allownaces_earning + ',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning, Sum(Basic_Arrear) As Basic_Arrear'
								+ @sum_of_allownaces_earning_Arear + ',Sum(Total_Earning_Arrear) as Total_Earning_Arrear,SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(Other_Allowance)as Other_Allowance,SUM(CTC) as CTC,SUM(Advance_Amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(Revenue_Amount) as Revenue_Amount,SUM(LWF_Amount)as LWF_Amount,SUM(Gate_Pass_Amount) as Gate_Pass_Amount,SUM(Asset_Installment_Amount) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction'
								+@sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,Sum(Total_Amount) AS Total_Amount,
								SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(Total_Paid_Leave_Days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##TYPE';

								exec(@String)
								
								set @String = 'Select * FROM ##TYPE Order By Row_ID';
								
								exec(@String)
								
								set @String = 'DROP TABLE ##TYPE';	
								
								exec(@String)			
							END
						ELSE
							BEGIN
								
								set @String = 'DROP TABLE ##TYPE';	
								exec(@String)		
							
							END			
					End
			end
		else if @Summary='6' -----for division wise-------------------
			begin
				if @Type = '3' -- For Employee Detail & Summary 
					Begin
						--Set @String_1 = 'select 0 as flag,CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.Division as Division'+ @String_2 +''+ @String_3 +',1 As Total_Emp, CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Other_Allow as Other_Allowance,CM.Actual_CTC as CTC,CM.Gratuity_Amount as Gratuity_Amount,CM.arear_amount as Arear_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,CM.Settl_Salary as Settlement_Salary,cm.net_amount as Net_Amount,CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holidy_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''
						--Set @String_1 = @String_1 + ' from #CTCMast CM Where Sal_Cal_Day <> 0'
						--set @String = ' select 1 as flag,'''' as Alpha_Emp_Code, '''' as Emp_Full_Name,CM.Division as Division'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +''
						--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By Division'+ @String_2 +''+ @String_3 +' Order By Division'+ @String_2 +''+ @String_3 +',flag'
						--exec(@String_1 +' Union ALL ' + @String)
						
						Set @String_1 = 'select 0 as flag, ROW_NUMBER() OVER (Order by CM.Division) As Row_ID, CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.Division as Division'+ @String_2 +''+ @String_3 +',1 As Total_Emp, 
							CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gratuity_Amount as Gratuity_Amount,Total_Earning As Total_Earning,Basic_Arrear As Basic_Arrear'
							+ @allownaces_earning_arear +',Total_Earning_Arrear as Total_Earning_Arrear, CM.Other_Allow as Other_Allowance, CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Actual_CTC as CTC,CM.advance_amountas Advance_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.M_HO_OT_Hours as Holiday_OT_Hours,cm.M_HO_OT_Amount as Holiday_OT_Amount,cm.M_WO_OT_Hours as Weekoff_OT_Hours,cm.M_WO_OT_Amount as Weekoff_OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,ISNULL(Total_Deduction,0) as Total_Deduction '
							+ @allownaces_deduct_arear + ',Arear_Deduction As Arear_Deduction, Net_Total_Deduction as Net_Total_Deduction,cm.net_amount as Net_Amount,Net_Round As Net_Round, Total_Net As Total_Net '+ @Allownaces_Earning_CTC +' ,(Net_Round + CM.Gross_Salary '+ @Allownaces_Earning_CTC_Total +') AS Total_Amount,
							CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holiday_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''

						--Set @String_1 = @String_1 + ' INTO ##DIVISION from #CTCMast CM ' COMMENTED BY RAJPUT ON 25062018
						
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##DIVISION from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1'
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##DIVISION from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 ' 
							END
						ELSE
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##DIVISION from #CTCMast CM WHERE Sal_Cal_Day <> 0  ' 
							END 
						EXEC(@String_1)
						---- END ---- 
						 
						
						
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						
						
					IF EXISTS(SELECT 1 FROM ##DIVISION)
						BEGIN
							set @String = 'Insert into ##DIVISION select 0 as flag,(IsNull(Max(Row_ID),0)+1),'''' As Alpha_Emp_Code ,''Total'' As Emp_Full_Name,''Total'' as Division'+ @String_2 +''+ @String_3 +',1 As Total_Emp,
							SUM(Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
							+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(Other_Allowance)as Other_Allowance, SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CTC) as CTC,SUM(advance_amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(revenue_amount) as Revenue_Amount,SUM(lwf_amount)as LWF_Amount,SUM(isnull(Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
							+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
							SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_Day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##DIVISION'

							exec(@String)
							
							set @String = 'Select * FROM ##DIVISION Order By Row_ID';
							
							exec(@String)
							
							set @String = 'DROP TABLE ##DIVISION';	
						
							exec(@String)	
						END
					ELSE
						BEGIN
						
							set @String = 'DROP TABLE ##DIVISION';	
							exec(@String)	
							
						END						
							
					End
				Else
					Begin
						--set @String = ' select 0 as flag,CM.Division as Division'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +''
						--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By Division'+ @String_2 +''+ @String_3 +''
						--exec(@String)

						set @Avg_Emp = DATEDIFF(MM,@From_Date,@To_Date) + 1
						
						set @String = ' select 0 as Flag, ROW_NUMBER() OVER (Order by CM.Division) As Row_ID,CM.Division as Division'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,
						SUM(cm.M_HO_OT_Hours) as Holiday_OT_Hours,SUM(cm.M_HO_OT_Amount) as Holiday_OT_Amount,SUM(cm.M_WO_OT_Hours) as Weekoff_OT_Hours,SUM(cm.M_WO_OT_Amount) as Weekoff_OT_Amount
						,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '


						--set @String = @String + ' INTO ##DIVISION from #CTCMast CM  group By Division'+ @String_2 +''+ @String_3 +'' COMMENTED BY RAJPUT ON 25062018
						
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String = @String + ' INTO ##DIVISION from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1 group By Division'+ @String_2 +''+ @String_3 +''
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String = @String + ' INTO ##DIVISION from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 group By Division'+ @String_2 +''+ @String_3 +'' 
							END
						ELSE
							BEGIN
								Set @String = @String + ' INTO ##DIVISION from #CTCMast CM WHERE Sal_Cal_Day <> 0 group By Division'+ @String_2 +''+ @String_3 +'' 
							END 
						exec(@String)
						---- END ---- 
						
						
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						
						
						IF EXISTS(SELECT 1 FROM ##DIVISION)
							BEGIN
								set @String = 'Insert into ##DIVISION Select 0 as Flag,(IsNull(Max(Row_ID),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),Round((Sum(Total_Emp)/'  + cast(@Avg_Emp as varchar(10)) +'),0) ,Sum(Basic_Salary) ' + @sum_of_allownaces_earning + ',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning, Sum(Basic_Arrear) As Basic_Arrear'
								+ @sum_of_allownaces_earning_Arear + ',Sum(Total_Earning_Arrear) as Total_Earning_Arrear,SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(Other_Allowance)as Other_Allowance,SUM(CTC) as CTC,SUM(Advance_Amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(Revenue_Amount) as Revenue_Amount,SUM(LWF_Amount)as LWF_Amount,SUM(Gate_Pass_Amount) as Gate_Pass_Amount,SUM(Asset_Installment_Amount) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction'
								+@sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,Sum(Total_Amount) AS Total_Amount,
								SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(Total_Paid_Leave_Days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##DIVISION';

								exec(@String)
								
								set @String = 'Select * FROM ##DIVISION Order By Row_ID';
								
								exec(@String)
								
								set @String = 'DROP TABLE ##DIVISION';	
								
								exec(@String)	
							END
						ELSE
							BEGIN
								set @String = 'DROP TABLE ##DIVISION';	
								
								exec(@String)	
							END					
						
					End
			end
		else if @Summary='7' --------for GroupBy Vertical Wise---------------------------
			begin
				if @Type = '3' -- For Employee Detail & Summary 
					Begin
						--Set @String_1 = 'select 0 as flag,CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.sub_vertical as Sub_Department'+ @String_2 +''+ @String_3 +',1 As Total_Emp, CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Other_Allow as Other_Allowance,CM.Actual_CTC as CTC,CM.Gratuity_Amount as Gratuity_Amount,CM.arear_amount as Arear_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,CM.Settl_Salary as Settlement_Salary,cm.net_amount as Net_Amount,CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holidy_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''
						--Set @String_1 = @String_1 + ' from #CTCMast CM Where Sal_Cal_Day <> 0'
						--set @String = ' select 1 as flag,'''' as Alpha_Emp_Code, '''' as Emp_Full_Name,CM.sub_vertical as Sub_Department'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
						--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By sub_vertical'+ @String_2 +''+ @String_3 +' Order By sub_vertical'+ @String_2 +''+ @String_3 +',flag'
						--exec(@String_1 +' Union ALL ' + @String)

						Set @String_1 = 'select 0 as flag, ROW_NUMBER() OVER (Order by CM.sub_vertical) As Row_ID, CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.sub_vertical as Sub_Department'+ @String_2 +''+ @String_3 +',1 As Total_Emp, 
							CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gratuity_Amount as Gratuity_Amount,Total_Earning As Total_Earning,Basic_Arrear As Basic_Arrear'
							+ @allownaces_earning_arear +',Total_Earning_Arrear as Total_Earning_Arrear, CM.Other_Allow as Other_Allowance, CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Actual_CTC as CTC,CM.Advance_Amount as Advance_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.M_HO_OT_Hours as Holiday_OT_Hours,cm.M_HO_OT_Amount as Holiday_OT_Amount,cm.M_WO_OT_Hours as Weekoff_OT_Hours,cm.M_WO_OT_Amount as Weekoff_OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,ISNULL(Total_Deduction,0) as Total_Deduction '
							+ @allownaces_deduct_arear + ',Arear_Deduction As Arear_Deduction, Net_Total_Deduction as Net_Total_Deduction,cm.net_amount as Net_Amount,Net_Round As Net_Round, Total_Net As Total_Net '+ @Allownaces_Earning_CTC +' ,(Net_Round + CM.Gross_Salary '+ @Allownaces_Earning_CTC_Total +') AS Total_Amount,
							CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holiday_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''

						--Set @String_1 = @String_1 + ' INTO ##SUBVERTICAL from #CTCMast CM ' COMMENTED BY RAJPUT ON 25062018
						
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##SUBVERTICAL from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1'
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##SUBVERTICAL from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 ' 
							END
						ELSE
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##SUBVERTICAL from #CTCMast CM WHERE Sal_Cal_Day <> 0  ' 
							END 
						 
						EXEC(@String_1)

						---- END ----

 
						
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						
						IF EXISTS(SELECT 1 FROM ##SUBVERTICAL)
							BEGIN
								set @String = 'Insert into ##SUBVERTICAL select 0 as flag,(IsNull(Max(Row_ID),0)+1),'''' As Alpha_Emp_Code ,''Total'' As Emp_Full_Name,''Total'' as Sub_Department'+ @String_2 +''+ @String_3 +',1 As Total_Emp,
								SUM(Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
								+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(Other_Allowance)as Other_Allowance, SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CTC) as CTC,SUM(advance_amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(revenue_amount) as Revenue_Amount,SUM(lwf_amount)as LWF_Amount,SUM(isnull(Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
								+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
								SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_Day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##SUBVERTICAL'

								exec(@String)
								
								set @String = 'Select * FROM ##SUBVERTICAL Order By Row_ID';
								
								exec(@String)
								
								set @String = 'DROP TABLE ##SUBVERTICAL';	
							
								exec(@String)			
							END
						ELSE
							BEGIN
								
								set @String = 'DROP TABLE ##SUBVERTICAL';	
							
								exec(@String)	
							END					
					End
				Else
					Begin
						--set @String = ' select 0 as flag,CM.sub_vertical as Sub_Department'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
						--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By sub_vertical'+ @String_2 +''+ @String_3 +''
						--exec(@String)
						set @Avg_Emp = DATEDIFF(MM,@From_Date,@To_Date) + 1
						
						set @String = ' select 0 as Flag, ROW_NUMBER() OVER (Order by CM.sub_vertical) As Row_ID,CM.sub_vertical as Sub_Department'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,
						SUM(cm.M_HO_OT_Hours) as Holiday_OT_Hours,SUM(cm.M_HO_OT_Amount) as Holiday_OT_Amount,SUM(cm.M_WO_OT_Hours) as Weekoff_OT_Hours,SUM(cm.M_WO_OT_Amount) as Weekoff_OT_Amount
						,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '


						--set @String = @String + ' INTO ##SUBVERTICAL from #CTCMast CM  group By sub_vertical'+ @String_2 +''+ @String_3 +'' COMMENTED BY RAJPUT ON 25062018
						
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String = @String + ' INTO ##SUBVERTICAL from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1 group By sub_vertical'+ @String_2 +''+ @String_3 +''
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String = @String + ' INTO ##SUBVERTICAL from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 group By sub_vertical'+ @String_2 +''+ @String_3 +'' 
							END
						ELSE
							BEGIN
								Set @String = @String + ' INTO ##SUBVERTICAL from #CTCMast CM WHERE Sal_Cal_Day <> 0 group By sub_vertical'+ @String_2 +''+ @String_3 +'' 
							END 
						 
						exec(@String)
						---- END ----
						
						
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						
						IF EXISTS(SELECT 1 FROM ##SUBVERTICAL)
							BEGIN
								set @String = 'Insert into ##SUBVERTICAL Select 0 as Flag,(IsNull(Max(Row_ID),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),Round((Sum(Total_Emp)/'  + cast(@Avg_Emp as varchar(10)) +'),0) ,Sum(Basic_Salary) ' + @sum_of_allownaces_earning + ',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning, Sum(Basic_Arrear) As Basic_Arrear'
								+ @sum_of_allownaces_earning_Arear + ',Sum(Total_Earning_Arrear) as Total_Earning_Arrear,SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(Other_Allowance)as Other_Allowance,SUM(CTC) as CTC,SUM(Advance_Amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(Revenue_Amount) as Revenue_Amount,SUM(LWF_Amount)as LWF_Amount,SUM(Gate_Pass_Amount) as Gate_Pass_Amount,SUM(Asset_Installment_Amount) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction'
								+@sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,Sum(Total_Amount) AS Total_Amount,
								SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(Total_Paid_Leave_Days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##SUBVERTICAL';

								exec(@String)
								
								set @String = 'Select * FROM ##SUBVERTICAL Order By Row_ID';
								
								exec(@String)
								
								set @String = 'DROP TABLE ##SUBVERTICAL';	
								
								exec(@String)
							END
						ELSE
							BEGIN
								set @String = 'DROP TABLE ##SUBVERTICAL';	
								exec(@String)
								
							END						
					End
			end
		else if @Summary='8' --------for GroupBy SuB Branch---------------------------
			begin
				if @Type = '3' -- For Employee Detail & Summary 
					Begin
						--Set @String_1 = 'select 0 as flag,CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.sub_branch as Sub_Branch'+ @String_2 +''+ @String_3 +',1 As Total_Emp, CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Other_Allow as Other_Allowance,CM.Actual_CTC as CTC,CM.Gratuity_Amount as Gratuity_Amount,CM.arear_amount as Arear_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,CM.Settl_Salary as Settlement_Salary,cm.net_amount as Net_Amount,CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holidy_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''
						--Set @String_1 = @String_1 + ' from #CTCMast CM Where Sal_Cal_Day <> 0'
						--set @String = ' select 1 as flag,'''' as Alpha_Emp_Code, '''' as Emp_Full_Name,CM.sub_branch as Sub_Branch'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
						--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By sub_branch'+ @String_2 +''+ @String_3 +' Order By sub_branch'+ @String_2 +''+ @String_3 +',flag'
						--exec(@String_1 +' Union ALL ' + @String)
						Set @String_1 = 'select 0 as flag, ROW_NUMBER() OVER (Order by CM.Sub_Branch) As Row_ID, CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.Sub_Branch as Sub_Branch'+ @String_2 +''+ @String_3 +',1 As Total_Emp, 
							CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gratuity_Amount as Gratuity_Amount,Total_Earning As Total_Earning,Basic_Arrear As Basic_Arrear'
							+ @allownaces_earning_arear +',Total_Earning_Arrear as Total_Earning_Arrear, CM.Other_Allow as Other_Allowance, CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Actual_CTC as CTC,CM.Advance_Amount as Advance_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.M_HO_OT_Hours as Holiday_OT_Hours,cm.M_HO_OT_Amount as Holiday_OT_Amount,cm.M_WO_OT_Hours as Weekoff_OT_Hours,cm.M_WO_OT_Amount as Weekoff_OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,ISNULL(Total_Deduction,0) as Total_Deduction '
							+ @allownaces_deduct_arear + ',Arear_Deduction As Arear_Deduction, Net_Total_Deduction as Net_Total_Deduction,cm.net_amount as Net_Amount,Net_Round As Net_Round, Total_Net As Total_Net '+ @Allownaces_Earning_CTC +' ,(Net_Round + CM.Gross_Salary '+ @Allownaces_Earning_CTC_Total +') AS Total_Amount,
							CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holiday_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''

						--Set @String_1 = @String_1 + ' INTO ##SUBBRANCH from #CTCMast CM ' COMMENTED BY RAJPUT ON 25062018
						
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##SUBBRANCH from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1'
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##SUBBRANCH from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 ' 
							END
						ELSE
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##SUBBRANCH from #CTCMast CM WHERE Sal_Cal_Day <> 0  ' 
							END 
						 
						EXEC(@String_1)
						---- END ----
						
						
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 = ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						
						
						IF EXISTS(SELECT 1 FROM ##SUBBRANCH)
							BEGIN
								set @String = 'Insert into ##SUBBRANCH select 0 as flag,(IsNull(Max(Row_ID),0)+1),'''' As Alpha_Emp_Code ,''Total'' As Emp_Full_Name,''Total'' as Sub_Branch'+ @String_2 +''+ @String_3 +',1 As Total_Emp,
								SUM(Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
								+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(Other_Allowance)as Other_Allowance, SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CTC) as CTC,SUM(advance_amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(revenue_amount) as Revenue_Amount,SUM(lwf_amount)as LWF_Amount,SUM(isnull(Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
								+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
								SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_Day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##SUBBRANCH'

								exec(@String)
								
								set @String = 'Select * FROM ##SUBBRANCH Order By Row_ID';
								
								exec(@String)
								
								set @String = 'DROP TABLE ##SUBBRANCH';	
							
								exec(@String)
							END
						ELSE
							BEGIN
								
								set @String = 'DROP TABLE ##SUBBRANCH';	
							
								exec(@String)
							END
															
						
					End
				Else
					Begin
						--set @String = ' select 0 as flag,CM.sub_branch as Sub_Branch'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
						--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By sub_branch'+ @String_2 +''+ @String_3 +''
						--exec(@String)
						set @Avg_Emp = DATEDIFF(MM,@From_Date,@To_Date) + 1
						
						set @String = ' select 0 as Flag, ROW_NUMBER() OVER (Order by CM.Sub_Branch) As Row_ID,CM.Sub_Branch as Sub_Branch'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,
						SUM(cm.M_HO_OT_Hours) as Holiday_OT_Hours,SUM(cm.M_HO_OT_Amount) as Holiday_OT_Amount,SUM(cm.M_WO_OT_Hours) as Weekoff_OT_Hours,SUM(cm.M_WO_OT_Amount) as Weekoff_OT_Amount
						,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '


						--set @String = @String + ' INTO ##SUBBRANCH from #CTCMast CM  group By Sub_Branch'+ @String_2 +''+ @String_3 +''
						
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String = @String + ' INTO ##SUBBRANCH from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1 group By Sub_Branch'+ @String_2 +''+ @String_3 +''
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String = @String + ' INTO ##SUBBRANCH from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 group By Sub_Branch'+ @String_2 +''+ @String_3 +'' 
							END
						ELSE
							BEGIN
								Set @String = @String + ' INTO ##SUBBRANCH from #CTCMast CM WHERE Sal_Cal_Day <> 0 group By Sub_Branch'+ @String_2 +''+ @String_3 +'' 
							END 
						 
						exec(@String)
						---- END ----
						
						
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						
						
						
					IF EXISTS(SELECT 1 FROM ##SUBBRANCH)
						BEGIN
							set @String = 'Insert into ##SUBBRANCH Select 0 as Flag,(IsNull(Max(Row_ID),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),Round((Sum(Total_Emp)/'  + cast(@Avg_Emp as varchar(10)) +'),0) ,Sum(Basic_Salary) ' + @sum_of_allownaces_earning + ',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning, Sum(Basic_Arrear) As Basic_Arrear'
							+ @sum_of_allownaces_earning_Arear + ',Sum(Total_Earning_Arrear) as Total_Earning_Arrear,SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(Other_Allowance)as Other_Allowance,SUM(CTC) as CTC,SUM(Advance_Amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(Revenue_Amount) as Revenue_Amount,SUM(LWF_Amount)as LWF_Amount,SUM(Gate_Pass_Amount) as Gate_Pass_Amount,SUM(Asset_Installment_Amount) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction'
							+@sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,Sum(Total_Amount) AS Total_Amount,
							SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(Total_Paid_Leave_Days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##SUBBRANCH';

							exec(@String)
							
							set @String = 'Select * FROM ##SUBBRANCH Order By Row_ID';
							
							exec(@String)
							
							set @String = 'DROP TABLE ##SUBBRANCH';	
							
							exec(@String)		
						END
					ELSE
						BEGIN
							set @String = 'DROP TABLE ##SUBBRANCH';	
							
							exec(@String)	
						END				
						
					End
			end
		else if @Summary='9' ----------for GroupBy Business Segment--------------
			begin
				if @Type = '3' -- For Employee Detail & Summary 
					Begin
						--Set @String_1 = 'select 0 as flag,CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.Segment_Name as Segment_Name'+ @String_2 +''+ @String_3 +',1 As Total_Emp, CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Other_Allow as Other_Allowance,CM.Actual_CTC as CTC,CM.Gratuity_Amount as Gratuity_Amount,CM.arear_amount as Arear_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,CM.Settl_Salary as Settlement_Salary,cm.net_amount as Net_Amount,CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holidy_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''
						--Set @String_1 = @String_1 + ' from #CTCMast CM Where Sal_Cal_Day <> 0'
						--set @String = ' select 1 as flag,'''' as Alpha_Emp_Code, '''' as Emp_Full_Name,CM.Segment_Name as Segment_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
						--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By Segment_Name'+ @String_2 +''+ @String_3 +' Order By Segment_Name'+ @String_2 +''+ @String_3 +',flag'
						--exec(@String_1 +' Union ALL ' + @String)
						
						Set @String_1 = 'select 0 as flag, ROW_NUMBER() OVER (Order by CM.Segment_Name) As Row_ID, CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.Segment_Name as Segment_Name'+ @String_2 +''+ @String_3 +',1 As Total_Emp, 
							CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gratuity_Amount as Gratuity_Amount,Total_Earning As Total_Earning,Basic_Arrear As Basic_Arrear'
							+ @allownaces_earning_arear +',Total_Earning_Arrear as Total_Earning_Arrear, CM.Other_Allow as Other_Allowance, CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Actual_CTC as CTC,CM.Advance_Amount as Advance_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.M_HO_OT_Hours as Holiday_OT_Hours,cm.M_HO_OT_Amount as Holiday_OT_Amount,cm.M_WO_OT_Hours as Weekoff_OT_Hours,cm.M_WO_OT_Amount as Weekoff_OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,ISNULL(Total_Deduction,0) as Total_Deduction '
							+ @allownaces_deduct_arear + ',Arear_Deduction As Arear_Deduction, Net_Total_Deduction as Net_Total_Deduction,cm.net_amount as Net_Amount,Net_Round As Net_Round, Total_Net As Total_Net '+ @Allownaces_Earning_CTC +' ,(Net_Round + CM.Gross_Salary '+ @Allownaces_Earning_CTC_Total +') AS Total_Amount,
							CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holiday_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''

						--Set @String_1 = @String_1 + ' INTO ##SEGMENT from #CTCMast CM ' COMMENTED BY RAJPUT ON 25062018
						
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##SEGMENT from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1'
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##SEGMENT from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 ' 
							END
						ELSE
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##SEGMENT from #CTCMast CM WHERE Sal_Cal_Day <> 0  ' 
							END 
						 
						EXEC(@String_1)
						---- END ---- 
						
						
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						
						

						IF EXISTS(SELECT 1 FROM ##SEGMENT)
							BEGIN

								set @String = 'Insert into ##SEGMENT select 0 as flag,(IsNull(Max(Row_ID),0)+1),'''' As Alpha_Emp_Code ,''Total'' As Emp_Full_Name,''Total'' as Segment_Name'+ @String_2 +''+ @String_3 +',1 As Total_Emp,
								SUM(Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
								+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(Other_Allowance)as Other_Allowance, SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CTC) as CTC,SUM(advance_amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(revenue_amount) as Revenue_Amount,SUM(lwf_amount)as LWF_Amount,SUM(isnull(Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
								+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
								SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_Day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##SEGMENT'

								exec(@String)
								
								set @String = 'Select * FROM ##SEGMENT Order By Row_ID';
								
								exec(@String)
								
								set @String = 'DROP TABLE ##SEGMENT';	
							
								exec(@String)			
							END
						ELSE
							BEGIN
								set @String = 'DROP TABLE ##SEGMENT';	
							
								exec(@String)	
							END					
						
					End
				Else
					Begin
						--set @String = 'select 0 as flag,CM.Segment_Name as Segment_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
						--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By Segment_Name'+ @String_2 +''+ @String_3 +''
						--exec(@String)
						set @Avg_Emp = DATEDIFF(MM,@From_Date,@To_Date) + 1
						
						set @String = ' select 0 as Flag, ROW_NUMBER() OVER (Order by CM.Segment_Name) As Row_ID,CM.Segment_Name as Segment_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,
						SUM(cm.M_HO_OT_Hours) as Holiday_OT_Hours,SUM(cm.M_HO_OT_Amount) as Holiday_OT_Amount,SUM(cm.M_WO_OT_Hours) as Weekoff_OT_Hours,SUM(cm.M_WO_OT_Amount) as Weekoff_OT_Amount
						,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '


						--set @String = @String + ' INTO ##SEGMENT from #CTCMast CM  group By Segment_Name'+ @String_2 +''+ @String_3 +'' COMMENTED BY RAJPUT ON 25062018
						
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String = @String + ' INTO ##SEGMENT from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1 group By Segment_Name'+ @String_2 +''+ @String_3 +''
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String = @String + ' INTO ##SEGMENT from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 group By Segment_Name'+ @String_2 +''+ @String_3 +'' 
							END
						ELSE
							BEGIN
								Set @String = @String + ' INTO ##SEGMENT from #CTCMast CM WHERE Sal_Cal_Day <> 0 group By Segment_Name'+ @String_2 +''+ @String_3 +'' 
							END 
						 
						exec(@String)
						---- END ---- 
						
						
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						

						IF EXISTS(SELECT 1 FROM ##SEGMENT)
							BEGIN

								set @String = 'Insert into ##SEGMENT Select 0 as Flag,(IsNull(Max(Row_ID),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),Round((Sum(Total_Emp)/'  + cast(@Avg_Emp as varchar(10)) +'),0) ,Sum(Basic_Salary) ' + @sum_of_allownaces_earning + ',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning, Sum(Basic_Arrear) As Basic_Arrear'
								+ @sum_of_allownaces_earning_Arear + ',Sum(Total_Earning_Arrear) as Total_Earning_Arrear,SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(Other_Allowance)as Other_Allowance,SUM(CTC) as CTC,SUM(Advance_Amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(Revenue_Amount) as Revenue_Amount,SUM(LWF_Amount)as LWF_Amount,SUM(Gate_Pass_Amount) as Gate_Pass_Amount,SUM(Asset_Installment_Amount) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction'
								+@sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,Sum(Total_Amount) AS Total_Amount,
								SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(Total_Paid_Leave_Days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##SEGMENT';

								exec(@String)
								
								set @String = 'Select * FROM ##SEGMENT Order By Row_ID';
								
								exec(@String)
								
								set @String = 'DROP TABLE ##SEGMENT';	
								
								exec(@String)			
							END
						ELSE
							BEGIN
								
								set @String = 'DROP TABLE ##SEGMENT';	
								
								exec(@String)	
							
							END				
					End
			end
		else if @Summary='10' ----------for GroupBy Business Segment--------------
			begin
			----PRINT 'a'
		
				if @Type = '3' -- For Employee Detail & Summary 
					Begin
						--set @Avg_Emp = DATEDIFF(MM,@From_Date,@To_Date) + 1
						--Set @String_1 = 'select 0 as flag,CM.Alpha_Emp_Code,CM.Emp_Full_Name,CM.Center_Code as Center_Code'+ @String_2 +''+ @String_3 +',1 As Total_Emp,0 AS Avg_Emp, CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Other_Allow as Other_Allowance,CM.Actual_CTC as CTC,CM.Gratuity_Amount as Gratuity_Amount,CM.arear_amount as Arear_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,CM.Settl_Salary as Settlement_Salary,cm.net_amount as Net_Amount,Net_Round as Net_Round '+ @Allownaces_Earning_CTC +' ,(Net_Round + CM.Gross_Salary '+ @Allownaces_Earning_CTC_Total +') AS Total_Amount ,CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holiday_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days '+ @allownaces_earning_reim +' '
						--Set @String_1 = @String_1 + ' from #CTCMast CM Where Sal_Cal_Day <> 0'
						--set @String = ' select 1 as Flag,'''' as Alpha_Emp_Code, '''' as Emp_Full_Name, CM.Center_Code as Center_Code'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount, SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
						--set @String = @String + ' from #CTCMast CM Where Sal_Cal_Day <> 0 group By Center_Code '+ @String_2 +''+ @String_3 +' Order By Center_Code '+ @String_2 +''+ @String_3 +',flag'
						--exec(@String_1 +' Union ALL ' + @String)

						Set @String_1 = 'select 0 as flag, ROW_NUMBER() OVER (Order by CM.Center_Code) As Row_ID, CM.Alpha_Emp_Code,CM.Emp_Full_Name'+ @String_2 +''+ @String_3 +',1 As Total_Emp, 
							CM.Basic_Salary as Basic_Salary '+ @allownaces_earning +',CM.Production_Bonus as Production_Bonus,CM.Leave_Encash_Amount as Leave_Encash_Amount,CM.Gratuity_Amount as Gratuity_Amount,Total_Earning As Total_Earning,Basic_Arrear As Basic_Arrear'
							+ @allownaces_earning_arear +',Total_Earning_Arrear as Total_Earning_Arrear, CM.Other_Allow as Other_Allowance, CM.Gross_Salary as Gross_Salary '+ @allownaces_deduct +',CM.Actual_CTC as CTC,cm.advance_amount as Advance_Amount,CM.PT_Amount as PT_Amount'+ @Loan_Amount_Str +',cm.ot_rate as OT_Rate,cm.ot_hours as OT_Hours,cm.ot_amount as OT_Amount,cm.M_HO_OT_Hours as Holiday_OT_Hours,cm.M_HO_OT_Amount as Holiday_OT_Amount,cm.M_WO_OT_Hours as Weekoff_OT_Hours,cm.M_WO_OT_Amount as Weekoff_OT_Amount,cm.WO_HO_Fix_OT_Rate as WO_HO_Fix_OT_Rate,cm.revenue_amount as Revenue_Amount,cm.lwf_amount as LWF_Amount,isnull(cm.Gate_Pass_Amount,0) as Gate_Pass_Amount,isnull(cm.Asset_Installment_Amount,0) as Asset_Installment_Amount,ISNULL(Cm.Late_Deduction_Amount,0) as Late_Deduction_Amount,ISNULL(Total_Deduction,0) as Total_Deduction '
							+ @allownaces_deduct_arear + ',Arear_Deduction As Arear_Deduction, Net_Total_Deduction as Net_Total_Deduction,cm.net_amount as Net_Amount,Net_Round As Net_Round, Total_Net As Total_Net '+ @Allownaces_Earning_CTC +' ,(Net_Round + CM.Gross_Salary '+ @Allownaces_Earning_CTC_Total +') AS Total_Amount,
							CM.Present_Day as Present_Days,CM.Arear_Day as Arear_Days,CM.Absent_Day as Absent_Day,CM.Holiday_Day as Holiday_day,CM.WeekOff_Day as Week_Off_Days, CM.Sal_Cal_Day as Sal_cal_Day,cm.total_leave_days as Total_leave_Days, CM.total_paid_leave_days as Total_Paid_Leave_Days'+ @allownaces_earning_reim +''

						-- Set @String_1 = @String_1 + ' INTO ##CenterCode from #CTCMast CM ' COMMENTED BY RAJPUT ON 25062018
						 
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##CenterCode from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1'
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##CenterCode from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 ' 
							END
						ELSE
							BEGIN
								Set @String_1 = @String_1 + ' INTO ##CenterCode from #CTCMast CM WHERE Sal_Cal_Day <> 0  ' 
							END 
						 
						EXEC(@String_1)

						---- END ----
						
						
						
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						
						

						IF EXISTS(SELECT 1 FROM ##CenterCode)
							BEGIN
								set @String = 'Insert into ##CenterCode select 0 as flag,(IsNull(Max(Row_ID),0)+1),'''' As Alpha_Emp_Code ,''Total'' As Emp_Full_Name'+ @String_2 +''+ @String_3 +',1 As Total_Emp,
								SUM(Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
								+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(Other_Allowance)as Other_Allowance, SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CTC) as CTC,SUM(advance_amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(revenue_amount) as Revenue_Amount,SUM(lwf_amount)as LWF_Amount,SUM(isnull(Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
								+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
								SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_Day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##CenterCode'

								exec(@String)
								
								set @String = 'Select * FROM ##CenterCode Order By Row_ID';
								
								exec(@String)
								
								set @String = 'DROP TABLE ##CenterCode';	
							
								exec(@String)			
							END
						ELSE
							BEGIN
								set @String = 'DROP TABLE ##CenterCode';	
								exec(@String)		
								
							END				
					End
				Else
					Begin
						set @Avg_Emp = DATEDIFF(MM,@From_Date,@To_Date) + 1
						
						set @String = ' select 0 as Flag, ROW_NUMBER() OVER (Order by CM.Center_Code) As Row_ID '+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
						Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
						+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,
						SUM(cm.M_HO_OT_Hours) as Holiday_OT_Hours,SUM(cm.M_HO_OT_Amount) as Holiday_OT_Amount,SUM(cm.M_WO_OT_Hours) as Weekoff_OT_Hours,SUM(cm.M_WO_OT_Amount) as Weekoff_OT_Amount
						,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
						+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
						SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '

						set @String = @String + ' INTO ##CenterCode from #CTCMast CM  group By Center_Code'+ @String_2 +''+ @String_3 +''
						
						---- ADDED BY RAJPUT ON 25062018 ----				
						IF(ISNULL(@REPORT_TYPE,0) = 1)
							BEGIN
								Set @String = @String + ' INTO ##CenterCode from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF <> 1 group By Center_Code'+ @String_2 +''+ @String_3 +''
							END
						ELSE IF(ISNULL(@Report_type,0) = 2)
							BEGIN
								Set @String = @String + ' INTO ##CenterCode from #CTCMast CM WHERE Sal_Cal_Day <> 0 AND CM.IS_FNF = 1 group By Center_Code'+ @String_2 +''+ @String_3 +'' 
							END
						ELSE
							BEGIN
								Set @String = @String + ' INTO ##CenterCode from #CTCMast CM WHERE Sal_Cal_Day <> 0 group By Center_Code'+ @String_2 +''+ @String_3 +'' 
							END 
						 
						exec(@String)

						---- END ----
						
						
						if @String_2 <> '' and @String_3 <> ''
							Begin
								Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						Else if @String_2 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',CM.',''),',','') +''
							End 
						Else if @String_3 <> ''
							Begin
								Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',CM.',''),',','') + ''
							End
						
						

						IF EXISTS(SELECT 1 FROM ##CenterCode)
							BEGIN
								set @String = 'Insert into ##CenterCode Select 0 as Flag,(IsNull(Max(Row_ID),0)+1) '+ @String_2 +', Sum(Total_Emp),Round((Sum(Total_Emp)/'  + cast(@Avg_Emp as varchar(10)) +'),0) ,Sum(Basic_Salary) ' + @sum_of_allownaces_earning + ',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Gratuity_Amount) as Gratuity_Amount,Sum(Total_Earning) As Total_Earning, Sum(Basic_Arrear) As Basic_Arrear'
								+ @sum_of_allownaces_earning_Arear + ',Sum(Total_Earning_Arrear) as Total_Earning_Arrear,SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(Other_Allowance)as Other_Allowance,SUM(CTC) as CTC,SUM(Advance_Amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(Revenue_Amount) as Revenue_Amount,SUM(LWF_Amount)as LWF_Amount,SUM(Gate_Pass_Amount) as Gate_Pass_Amount,SUM(Asset_Installment_Amount) as Asset_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction'
								+@sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,Sum(Total_Amount) AS Total_Amount,
								SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(Total_Paid_Leave_Days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##CenterCode';

								exec(@String)
								
								set @String = 'Select * FROM ##CenterCode Order By Row_ID';
								
								exec(@String)
								
								set @String = 'DROP TABLE ##CenterCode';	
								
								exec(@String)			
							END
						ELSE
							BEGIN
								set @String = 'DROP TABLE ##CenterCode';	
								
								exec(@String)	
								
							END				

				End
			end
		end
	--PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 15'
	--select CM.Cmp_ID,CM.Emp_ID,Emp_code,Alpha_Emp_Code,Emp_Full_Name,Branch,Deptartment,Designation,Grade,TypeName,Present_Day,CM.Arear_Day,Absent_Day,Holiday_Day,WeekOff_Day,Leave_Day,Sal_Cal_Day,Actual_CTC,CM.Basic_Salary,Settl_Salary,Other_Allow,Branch_Id,CM.CA,CM.CCA,CM.CEA,CM.HRA,CM.MED,CM.TA,CM.WORKER_HRA,CM.Arear_Amount,
	--Gross_Salary,PT_Amount,Loan_Amount,Advance_Amount,ms.M_HO_OT_Hours as Holiday_OT_Hours ,ms.M_HO_OT_Amount as holiday_OT_Amount,ms.M_WO_OT_Hours as Weekoff_OT_Hours,ms.M_WO_OT_Amount as Weekoff_OT_Amount,
	--CM.OT_Rate,OT_Hours,OT_Amount,CM.PF,Revenue_Amount,LWF_Amount,CM.Other_Dedu,CM.Total_Deduction,CM.Net_Amount
	--from #CTCMast CM left join T0200_Monthly_Salary ms on CM.Emp_ID =MS.emp_ID 
	--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
	--Order by CM.Emp_code
	
	--Select CM.*,MS.Salary_Status From #CTCMast CM Inner join T0200_MONTHLY_SALARY MS on CM.Emp_ID = MS.Emp_ID 
	--	where Month(MS.Month_st_date) = Month(@From_Date) and Year(MS.Month_st_date) = Year(@From_Date)
	--Order by CM.Emp_code
Return


