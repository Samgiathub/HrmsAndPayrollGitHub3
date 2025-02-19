
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_Salary_Register_for_WebService]  
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
	   ,Absent_Day		numeric(18,2)
	   ,Holiday_Day		numeric(18,2)
	   ,WeekOff_Day		numeric(18,2)
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
	
		
	
	Insert Into #CTCMast 
	SELECT e.Cmp_ID,e.Emp_ID,e.Emp_code,e.Alpha_Emp_Code,
		ISNULL(e.EmpName_Alias_Salary,e.Emp_Full_Name)
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
			( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)  --Changed by Hardik 10/09/2014 for Same Date Increment
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
	
	
		Set @val = ''
		SET @val_update = '';
		DECLARE Leave_Cursor CURSOR FOR
			Select Leave_Name
				 from T0120_Leave_Approval la WITH (NOLOCK)
				 inner join #Emp_Cons ec on la.emp_ID = ec.emp_ID 
				 Inner join  T0130_Leave_Approval_Detail Lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID 
				 inner join T0080_Emp_Master e WITH (NOLOCK) on la.emp_ID= e.emp_ID 
				 inner join T0040_Leave_Master LM WITH (NOLOCK) on LM.Leave_ID = Lad.Leave_ID
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
					
		 
		Set @val = '';
		Set @val = @val + 'Alter table  #CTCMast Add Total_Paid_Leave_Days numeric(18,2) default 0; 
						   Alter table  #CTCMast Add Total_Leave_Days numeric(18,2) default 0;
						   Alter table  #CTCMast Add Late_Days numeric(18,2) default 0;
						   Alter table  #CTCMast Add Early_Days numeric(18,2) default 0'
		exec (@val);
		

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

	Set @val = ''
	SET @val_update = '';
	
		
		DECLARE Allow_Dedu_Cursor CURSOR FOR
			Select AD_SORT_NAME,AD_LEVEL 
				from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK)
				Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
			Where --M_AD_Amount <> 0 And 
					T.Cmp_ID = @Company_Id
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
		
		/*	NO NEED OF SEPARATE COLUMN OF ARREAR AS CLIENT WANT IT IN SAME COLUMN - ORIGINAL ALLOWANCE NAME COLUMN
		
		Set @val = ''
		SET @val_update = '';
		DECLARE Allow_Dedu_Cursor CURSOR FOR
			Select AD_SORT_NAME,AD_LEVEL from T0210_MONTHLY_AD_DETAIL T Inner Join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
			Where --(M_AREAR_AMOUNT<>0 OR M_AREAR_AMOUNT_Cutoff <> 0)  And 
					T.Cmp_ID = @Company_Id
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
	
		--New Portion Added By Ramiz on 29/05/2019
		Set @val = ''
		SET @val_update = '';
		
		DECLARE Allow_Dedu_Cursor CURSOR FOR
			Select AD_SORT_NAME,AD_LEVEL from T0210_MONTHLY_AD_DETAIL T 
					INNER JOIN T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
			Where 	T.Cmp_ID = @Company_Id
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
					Set @AD_NAME_DYN = @AD_NAME_DYN + '_Total'
					set @sum_of_allownaces_earning_Arear=@sum_of_allownaces_earning_Arear + ',sum([' + @AD_NAME_DYN + ']) as [' + @AD_NAME_DYN +']'
					Set @allownaces_earning_arear =@allownaces_earning_arear + ',[' + @AD_NAME_DYN + '] as [' + @AD_NAME_DYN +']'
					
					Set @val = @val + 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) null;'
					SET @val_update = @val_update+ 'UPDATE  #CTCMast SET [' + REPLACE(@AD_NAME_DYN,' ','_') + '] = 0; '
					Set @Columns = @Columns +  '[' + REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + ']#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
				End
		close Allow_Dedu_Cursor	
		deallocate Allow_Dedu_Cursor
		
		exec (@val);
		exec (@val_update);	
		*/
		

		
		Set @val = ''
		Set @val = '--Alter table  #CTCMast Add Production_Bonus numeric(18,2) default 0 not null;
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
	
		--UPDATE   CM 						
		--SET		Production_Bonus = Q.Amount
		--FROM	dbo.#CTCMast CM 
		--		INNER JOIN (
		--					SELECT	ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID
		--					FROM	T0210_MONTHLY_AD_DETAIL MAD 
		--							INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID												
		--					WHERE	MAD.Cmp_ID= @Company_Id 
		--								AND MONTH(MAD.For_Date) =  Month(@From_Date) and YEAR(MAD.For_Date) = Year(@From_Date)
		--								AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0 
		--								AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id
		--								--AND MAD.Emp_ID = @EMp_Id_Production
		--					GROUP BY Mad.Emp_ID
		--				  )Q On CM.Emp_ID = Q.Emp_ID 
	
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
	

	

	Set @val = ''
	set @val_update = '';
	
		Declare Allow_Dedu_Cursor CURSOR FOR
			Select AD_SORT_NAME,Ad_Level from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK)
				INNER JOIN T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
			Where 
				T.Cmp_ID = @Company_Id 
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
		/*
		Set @val = ''
		SET @val_update = '';
		DECLARE Allow_Dedu_Cursor CURSOR FOR
		Select AD_SORT_NAME,AD_LEVEL from T0210_MONTHLY_AD_DETAIL T Inner Join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where --(M_AREAR_AMOUNT<>0 OR M_AREAR_AMOUNT_Cutoff <> 0)  And 
				T.Cmp_ID = @Company_Id
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

		--New Code Added By Ramiz on 28/05/2019
		SET @val = ''
		SET @val_update = '';
		
		DECLARE Allow_Dedu_Cursor CURSOR FOR
			SELECT AD_SORT_NAME,AD_LEVEL from T0210_MONTHLY_AD_DETAIL T Inner Join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
			WHERE 	T.Cmp_ID = @Company_Id
					and T.For_Date >= @From_Date and T.To_date <= @To_Date
					and isnull(A.Ad_Not_Effect_Salary,0) = 0
					and Ad_Active = 1 and AD_Flag = 'D'
					and T.S_Sal_Tran_ID is Null
			Group by AD_SORT_NAME ,AD_LEVEL
			ORDER BY AD_LEVEL,A.AD_SORT_NAME ASC
		OPEN Allow_Dedu_Cursor
			FETCH NEXT FROM Allow_Dedu_Cursor INTO @AD_NAME_DYN,@AD_LEVEL
			while @@fetch_status = 0
				Begin
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')
					Set @AD_NAME_DYN = @AD_NAME_DYN + '_Total'
					set @sum_of_allownaces_deduct_Arear=@sum_of_allownaces_deduct_Arear + ',sum([' + @AD_NAME_DYN + ']) as [' + @AD_NAME_DYN +']'
					Set @allownaces_deduct_arear =@allownaces_deduct_arear + ',[' + @AD_NAME_DYN + '] as [' + @AD_NAME_DYN +']'
					
					Set @val = @val + 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) null;'
					SET @val_update = @val_update+ 'UPDATE  #CTCMast SET [' + REPLACE(@AD_NAME_DYN,' ','_') + '] = 0; '
					Set @Columns = @Columns +  '[' + REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + ']#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
				End
		close Allow_Dedu_Cursor	
		deallocate Allow_Dedu_Cursor
	
		exec (@val);
		exec (@val_update);	
		*/
		
		Set @val = ''
		Set @val = 'Alter table  #CTCMast Add LWF_Amount numeric(18,2) default 0  not null;
					Alter table  #CTCMast Add Other_Deduction numeric(18,2) default 0 not null;
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
		
			
	SET @val = ''
		DECLARE CTC_Allow_Dedu_Cursor CURSOR FOR
			SELECT AD_SORT_NAME,AD_LEVEL 
			FROM   T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK)
					INNER JOIN T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
			WHERE	T.Cmp_ID = @Company_Id and T.For_Date >= @From_Date and T.To_date <= @To_Date
					and ISNULL(A.Ad_Not_Effect_Salary,0) = 1 AND A.Allowance_Type <> 'R' and Ad_Active = 1 --and AD_Flag = 'I'   
					and (CASE WHEN @Show_Hidden_Allowance = 0  and  A.Hide_In_Reports = 1 THEN 0 else 1 END ) = 1  --Change By Jaina 20-12-2016
					and T.S_Sal_Tran_ID IS NULL   --added by jimit 25012016 to resolve the case of RK 
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
	
		
		SET @val = ''
		DECLARE Allow_Dedu_Reim_Cursor CURSOR FOR
			SELECT  a.AD_SORT_NAME ,AD_LEVEL
			FROM T0210_MONTHLY_AD_DETAIL AS m  WITH (NOLOCK)
						INNER JOIN T0050_AD_MASTER AS a WITH (NOLOCK) ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID
			WHERE   (m.For_Date = @From_Date) and   M.Cmp_ID = @Company_Id  And
			(m.M_AD_Flag = 'I') and A.Allowance_Type = 'R'
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
		CLOSE Allow_Dedu_Reim_Cursor	
		DEALLOCATE Allow_Dedu_Reim_Cursor	
		
		EXEC (@val);
	

	
	--added by jimit 27032017
		Set @val = ''
		Set @val = 'Alter table  #CTCMast Add Salary_Status Varchar(10) default 0 not null;
					Alter table  #CTCMast Add Is_FNF numeric default 0 not null;' --Added by rajput on 15032018
		exec (@val)	
	---ended
	


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
			   Select Isnull(SUM(M_Arear_Amount) + SUM(M_AREAR_AMOUNT_Cutoff),0) as Arrear_Earn_Amt,M.Emp_ID 
			   From T0210_MONTHLY_AD_DETAIL M WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON M.Emp_ID=EC.Emp_ID -- ADDED BY RAJPUT ON 11062018 CODE OPTIMIZE
			   Where For_Date >= @From_Date And To_Date <= @To_Date And M_AD_Flag = 'I' and M_AD_NOT_EFFECT_SALARY = 0
						and S_Sal_Tran_ID is Null   --added by jimit 25012016 to resolve the case of RK 
			   Group BY M.Emp_ID
			   ) As t 
			   ON M.Emp_ID = t.Emp_ID
	Inner JOIN(
			   Select Isnull(SUM(M_Arear_Amount) + SUM(M_AREAR_AMOUNT_Cutoff),0) as Arrear_Ded_Amt,M.Emp_ID 
			   From T0210_MONTHLY_AD_DETAIL  M WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON M.Emp_ID=EC.Emp_ID
			   Where For_Date >= @From_Date And To_Date <= @To_Date And M_AD_Flag = 'D' and M_AD_NOT_EFFECT_SALARY = 0
						and S_Sal_Tran_ID is Null   --added by jimit 25012016 to resolve the case of RK 
			   GROUP By M.Emp_ID 
			   ) as t2 
			   ON M.Emp_ID = t2.Emp_ID
	Inner JOIN(
				Select Isnull(Arear_Basic,0) + isnull(basic_salary_arear_cutoff,0) as Arrear_Basic,M.Emp_ID 
				From T0200_MONTHLY_SALARY M WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON M.Emp_ID=EC.Emp_ID
				Where Month_St_Date >= @From_Date And Month_End_Date <= @To_Date
			   ) As t3 
			   ON M.Emp_ID = t3.Emp_ID
	
	
--SELECT * FROM #CTCMast
--RETURN
	
	
		UPDATE CM
		SET Basic_Salary = Qry.Salary_Amount,
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
			Total_Deduction = Qry.Dedu_Amount + Qry.Advance_Amount + Qry.PT_Amount + Qry.LWF_Amount + Qry.Other_Dedu_Amount + Qry.Asset_Installment  + qry.Late_Deduction_Amount + Qry.Loan, --+ Qry.Travel_Advance_Amount 
			PT_Amount = Qry.PT_Amount,
			--Loan_Amount = Qry.Loan, 
			Advance_Amount = Qry.Advance_Amount, 
			--Revenue_Amount = Qry.Revenue_amount, 
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
			--Gate_Pass_Amount = Qry.GatePass_Amount,				
			--Asset_Installment_Amount = Qry.Asset_Installment,				
			Net_Round = Qry.Net_Salary_Round_Diff_Amount, --Added by Hardik 08/02/2018 for Cera
			--Travel_Advance_Amount = Qry.Travel_Advance_Amount,
			Travel_Amount= Qry.Travel_Amount,
			Leave_Encash_Amount = Qry.Leave_Encash_Amount,
			Late_Days = Qry.Late_Days,
			Early_Days = Qry.Early_Days,
			Total_Paid_Leave_Days = Qry.total_paid_leave_cur,
			Salary_Status = qry.Salary_Status,        --added by jimit 27032017
			Is_FNF = qry.Is_FNF,        --added by Rajput 15032018
			--Uniform_Dedu_Amount=qry.Uniform_Dedu_Amount,
			--Uniform_Refund_Amount=qry.Uniform_Refund_Amount
			-- Late_Deduction_Amount = qry.Late_Deduction_Amount,  ---added by Jimit 29072017
			Total_Earning = Qry.Gross_Salary --Added by Hardik 08/02/2018 for Cera
			,Net_Total_Deduction = Qry.Total_Dedu_Amount--Added by Hardik 08/02/2018 for Cera
			,Total_Net = Qry.Net_Amount --Added by Hardik 08/02/2018 for Cera
			,Gratuity_Amount = qry.Gratuity_Amount --Added by rajput on 13062018
	from #CTCMast CM 
		INNER JOIN	(SELECT GS.Branch_ID,GS.ot_fix_shift_hours
					 FROM T0040_GENERAL_SETTING GS WITH (NOLOCK)
						INNER JOIN (
										SELECT max(for_date) as For_Date,Cmp_ID,Branch_ID 
										FROM T0040_General_Setting WITH (NOLOCK)
										GROUP BY Cmp_ID,Branch_ID
									) qry_1
						on qry_1.Cmp_ID = GS.Cmp_ID and qry_1.Branch_ID = GS.Branch_ID and GS.For_Date = qry_1.For_Date
					) As qry_2 on CM.Branch_id = qry_2.Branch_ID
		INNER JOIN (
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
					--Isnull(sum(MS.Revenue_amount),0) As Revenue_amount, 
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
					
					--isnull(SUM(MS.GatePass_Amount),0) As GatePass_Amount,				
					isnull(SUM(MS.Asset_Installment),0) As Asset_Installment,				
					Isnull(sum(MS.Net_Salary_Round_Diff_Amount),0) As Net_Salary_Round_Diff_Amount,
					--Isnull(SUM(MS.Travel_Advance_Amount),0) As Travel_Advance_Amount,
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
	
	--updating basic_total
	--UPDATE	CM
	--SET		Basic_Total = CM.Basic_Arrear + CM.Basic_Salary
	--FROM	#CTCMast CM
	UPDATE	CM
	SET		CM.Basic_Salary =  CM.Basic_Salary + CM.Basic_Arrear
	FROM	#CTCMast CM
	

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
				BEGIN				
						BEGIN
								Set @CTC_COLUMNS = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@CTC_COLUMNS)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
																		
								BEGIN
										--REGULAR AMOUNT
										Insert INTO #Emp_Allowance
										SELECT ded.EMP_ID,ded.AD_ID,
												isnull(sum(case when ded.ReimAmount >0  then ded.ReimAmount 
																else (ISNULL(ded.M_AD_Amount,0) + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) 
																end),0) As Amount   --Added by Jaina 01-03-2017  Bug id = 5532
										FROM T0210_MONTHLY_AD_DETAIL  ded WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON ded.Emp_ID=EC.Emp_ID -- ADDED BY RAJPUT ON 11062018 CODE OPETIMIZE
											INNER JOIN T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id 
											INNER JOIN T0200_MONTHLY_SALARY m WITH (NOLOCK) on ded.Sal_Tran_ID= m.Sal_Tran_ID and 
											Isnull(ded.FOR_FNF,0)= Case when ad.AD_NOT_EFFECT_SALARY = 1 then  isnull(m.Is_FNF,0) else Isnull(ded.FOR_FNF,0) end
										WHERE  
										(Case When Allowance_Type = 'A' THEN '[' + Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_Sort_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_') +']'
										 ELSE
										 '[' + Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_Sort_Name + '_' + 'Credit')),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_') + ']'
										 END) = @CTC_COLUMNS 
										and ded.For_Date >= @From_Date and ded.To_date <= @To_Date and ded.Cmp_ID = @Company_Id
										and S_Sal_Tran_ID is Null    --added by jimit 25012016 to resolve the case of RK 
										group by ded.EMP_ID , ded.AD_Id

										----ARREAR AMOUNT
										--Insert INTO #Emp_Allowance
										--select ded.EMP_ID,ded.AD_ID,
										--isnull(sum(case when ded.ReimAmount >0  then ded.ReimAmount else (isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0))  end),0) As Amount   --Added by Jaina 01-03-2017  Bug id = 5532
										--from T0210_MONTHLY_AD_DETAIL  ded INNER JOIN #Emp_Cons EC ON ded.Emp_ID=EC.Emp_ID -- ADDED ON 11062018 BY RAJPUT CODE OPTIMIZE
										--inner join T0050_AD_MASTER ad on ded.AD_Id = ad.AD_Id
										--WHere  
										--(Case When Allowance_Type = 'A' THEN '[' + Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_Sort_Name + '_Arrear')),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_') +']'
										-- ELSE
										-- '[' + Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_Sort_Name + '_' + 'Credit_Arrear')),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_') + ']'
										-- END) = @CTC_COLUMNS 
										--and ded.For_Date >= @From_Date and ded.To_date <= @To_Date and ded.Cmp_ID = @Company_Id --And (M_AREAR_AMOUNT<>0 OR M_AREAR_AMOUNT_Cutoff <> 0) 
										--and S_Sal_Tran_ID is Null 
										--group by ded.EMP_ID , ded.AD_Id
										
										
										--TOTAL AMOUNT
										--Insert INTO #Emp_Allowance
										--SELECT	ded.EMP_ID,ded.AD_ID,
										--		isnull(sum(case when ded.ReimAmount >0  then ded.ReimAmount else (ISNULL(ded.M_AD_Amount,0) + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0))  end),0) As Amount   --Added by Jaina 01-03-2017  Bug id = 5532
										--FROM T0210_MONTHLY_AD_DETAIL  ded 
										--		INNER JOIN #Emp_Cons EC ON ded.Emp_ID=EC.Emp_ID -- ADDED ON 11062018 BY RAJPUT CODE OPTIMIZE
										--		inner join T0050_AD_MASTER ad on ded.AD_Id = ad.AD_Id
										--WHERE  
										--'[' + Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_Sort_Name + '_Total')),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_') +']'
										-- = @CTC_COLUMNS 
										--AND Allowance_Type = 'A'--NOT TAKING REIMBURESMENT AS OF NOW
										--and ded.For_Date >= @From_Date and ded.To_date <= @To_Date and ded.Cmp_ID = @Company_Id --And (M_AREAR_AMOUNT<>0 OR M_AREAR_AMOUNT_Cutoff <> 0) 
										--and S_Sal_Tran_ID is Null 
										--group by ded.EMP_ID , ded.AD_Id
									
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
		

		Select CM.*
		into #temp_CTCMaster from #CTCMast CM
		inner join t0080_emp_master em WITH (NOLOCK)on cm.emp_id = em.emp_id
		inner join t0095_increment Inc WITH (NOLOCK) on em.increment_id = inc.increment_id	
		order by CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(CM.Enroll_No AS VARCHAR(20)), 21)  
								WHEN @Order_By='Name' THEN CM.Emp_Full_Name 
								When @Order_By = 'Designation' then (CASE WHEN CM.Desig_dis_No  = 0 THEN CM.Designation ELSE RIGHT(REPLICATE('0',21) + CAST(CM.Desig_dis_No AS VARCHAR), 21)   END)
							End ,Case When IsNumeric(Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"',''), 20)
									 When IsNumeric(Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
									 Else Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','') End 
	
		ALTER TABLE #Temp_CTCMaster
		ADD Salary_Hold NUMERIC(18,2)
		
		UPDATE #Temp_CTCMaster
		SET Salary_Hold = NET_AMOUNT ,
			NET_AMOUNT = 0,
			Total_Net = 0
		WHERE SALARY_STATUS = 'Hold'
		
			
		SELECT * FROM #Temp_CTCMaster
	
	--Update #CTCMast set Alpha_Emp_Code = '="' + Alpha_Emp_Code + '"'      -- Added by Gadriwala 03052014
	
	
	--DECLARE @COLS VARCHAR(MAX) --ADDED BY JIMIT 18012019	
	
	--	declare @drop_cols varchar(max)
	--	declare @Con_Name as varchar(50)
	--	declare @Con_col_Name as varchar(50)
		
		
	--	Select CM.*
	--	into #temp_CTCMaster from #CTCMast CM
	--	inner join t0080_emp_master em on cm.emp_id = em.emp_id
	--	inner join t0095_increment Inc on em.increment_id = inc.increment_id	
	--	order by CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(CM.Enroll_No AS VARCHAR(20)), 21)  
	--							WHEN @Order_By='Name' THEN CM.Emp_Full_Name 
	--							When @Order_By = 'Designation' then (CASE WHEN CM.Desig_dis_No  = 0 THEN CM.Designation ELSE RIGHT(REPLICATE('0',21) + CAST(CM.Desig_dis_No AS VARCHAR), 21)   END)
	--						End ,Case When IsNumeric(Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"',''), 20)
	--								 When IsNumeric(Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
	--								 Else Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','') End 
						
							
	--				 Declare @column nvarchar(max)
	--				 Declare @column_Sum nvarchar(max)
					 
					 
					 
	--				 Select * into #temp_CTCMaster_Sum From #temp_CTCMaster
						
					 
	--				 Update #temp_CTCMaster_Sum
	--					SET Cmp_ID = '0',Emp_ID = '0',Emp_Code = '0',Branch_ID = '0',Desig_dis_No = '0',
	--					Emp_Full_Name ='Total'
					 
	--				 SET @column = ''
	--				 SET @column_Sum = ''
					
	--				 SELECT 	@column_Sum = 
	--								CASE WHEN @column_Sum = '' Then
	--									(case system_type_id when 108 then 
	--										'Sum(isnull(' + QUOTENAME(name) + ',0)) as [' + name + ']'
	--										else
	--										','''' as '+ name +'' 
	--									end)
	--								Else
	--									@column_Sum +
	--									(case system_type_id when 108 then 
	--												', Sum(isnull(' + QUOTENAME(name) + ',0)) as [' + name + ']'
	--											else
	--												','''' as '+ name +'' 
	--									end)	
	--								End,
							
	--							@column = 
	--								(CASE WHEN @column = '' Then 'isnull(' + QUOTENAME(name) + ',0) as [' + name + ']'
	--							Else
	--								@column + ',isnull(' + QUOTENAME(name) + ',0) as [' + name + ']'
	--							End)
							
	--						FROM tempdb.sys.columns
	--						WHERE [object_id] = OBJECT_ID('tempdb..#temp_CTCMaster') 
							
							
	--						--Set @column_Sum = Replace(@column_Sum,''' as Emp_Full_Name','''Emp_Full_Name'' as Emp_Full_Name')
	--						Set @column_Sum = Replace(@column_Sum,''''' as Emp_Full_Name','Emp_Full_Name')
						
	--				--Select @column_Sum
					
	--				Declare @w_sql varchar(max)
	--				SET @w_sql = ''	

	--				SET @w_sql = 'Select ' + @column + ' From #temp_CTCMaster Union Select ' +  @column_Sum + ' From #temp_CTCMaster_Sum group by Emp_Full_Name  order by Cmp_ID DESC';
						
	--				EXEC(@w_sql); 

	
RETURN


