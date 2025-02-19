

-------------------------------------------------------------------------
------created by Sumit for Bhaskar Bankwise Salary Summary report--------
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[Rpt_Salary_BankWise_Summary]  
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
	,@Summary varchar(max)=''
	,@Salary_type varchar(20)
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Arear_Days as Numeric(18,2)
	Declare @Basic_Salary As Numeric(22,2)
	Declare @Total_Deduction As Numeric(22,2)
	Declare @PT As Numeric(22,2)
	Declare @Loan As Numeric(22,2)
	Declare @Advance As Numeric(22,2)	
	Declare @Net_Salary As Numeric(22,2)	
	Declare @Revenue_Amt As Numeric(22,2)	
	Declare @LWF_Amt As Numeric(22,2)	
	Declare @Other_Dedu As Numeric(22,2)	
		
	
	
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
			   
		  end     
	 else if day(@Sal_St_Date) =1
		  begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
		end     
	

	
 Declare @Emp_Cons Table
	(
		Emp_ID	numeric ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC 
	)
	
	
		
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
		
		
		INSERT INTO @Emp_Cons

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
						
			DELETE  FROM @Emp_Cons WHERE Increment_ID NOT IN (SELECT MAX(Increment_ID) FROM T0095_Increment WITH (NOLOCK)
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
	   ,Deptartment		nvarchar(100)
	   ,Designation		nvarchar(100)
	   ,Grade			nvarchar(100)
	   ,TypeName		nvarchar(100)
	   ,Cat_Name		nvarchar(100)
	   ,Division		nvarchar(100)
	   ,sub_vertical	nvarchar(100)
	   ,sub_branch		nvarchar(100)	   
	   ,Actual_CTC		Numeric(18,0)
	   ,Basic_Salary	numeric(18,2)
	   ,Bank_Ac_No		Varchar(50)
	   ,Pan_No			Varchar(50)
	   ,Segment_Name	nvarchar(100)
	   ,Net_Amount		numeric(18,2)
	   ,Branch_Id       Numeric(18,0)
	   ,p_from_date		datetime
	   ,p_to_date		datetime	
	   ,cmp_name		varchar(200)
	   ,cmp_address		varchar(500)
	   ,Hold_Amount		numeric(18,2)
	)
	
	Declare @Columns nvarchar(4000)
	Declare @Leave_Columns nvarchar(Max)
	Declare @Leave_Name nvarchar(30)
	set @Leave_Columns = ''
	Set @Columns = '#'
	declare @count_leave as numeric(18,2)
	set @count_leave = 0
	
	declare @String as varchar(max)
	set @string=''
		
	Insert Into #CTCMast 
	SELECT e.Cmp_ID,e.Emp_ID,e.Emp_code,e.Alpha_Emp_Code,
		ISNULL(e.EmpName_Alias_Salary,e.Emp_Full_Name)
		,bm.Branch_Name,dm.Dept_Name,dnm.Desig_Name,ga.Grd_Name,tm.Type_Name,CT.Cat_Name,VT.Vertical_Name,ST.SubVertical_Name,SB.SubBranch_Name,
		 0,0,
		 Case Upper(Payment_Mode) When 'BANK TRANSFER' THEN BAm.Bank_Name
		When 'CASH' Then 'CASH' Else 'CHEQUE' end
		,Pan_No
		,BSG.Segment_Name,0,BM.Branch_ID,@From_Date,@To_Date,cm.Cmp_Name,cm.Cmp_Address,0
		from T0080_EMP_MASTER e	WITH (NOLOCK) inner join
		( select I.Emp_id,I.Basic_Salary,I.CTC,I.Inc_Bank_AC_No,I.Cmp_ID,I.Bank_ID,I.bank_branch_name,Payment_Mode,I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_Id,I.Type_ID,I.Cat_ID,I.Vertical_ID,I.SubVertical_ID,I.subBranch_ID,I.Segment_ID from T0095_Increment I WITH (NOLOCK) inner join 
			( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
			where Increment_Effective_date <= @To_Date
			and cmp_id = @Company_id
			group by emp_ID  ) Qry on
			I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID 
	inner join @Emp_Cons ec on e.Emp_ID = ec.Emp_ID
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
	left outer join T0040_BANK_MASTER BAM WITH (NOLOCK) on BAM.Bank_ID=Inc_Qry.bank_id
	left outer join T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.Cmp_Id=Inc_Qry.Cmp_ID
	
	

	-----------------------------------------------------------------------------------
	Declare @CTC_CMP_ID numeric(18,0)
	Declare @CTC_EMP_ID numeric(18,0)
	Declare @CTC_BASIC numeric(18,2)
	declare @Hold_Amount numeric(18,2)
	
	Declare @AD_NAME_DYN nvarchar(100)
	declare @val nvarchar(500)
	Declare CTC_UPDATE CURSOR FOR
		select Cmp_Id,Emp_Id,Basic_Salary from #CTCMast
	OPEN CTC_UPDATE
	fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID,@CTC_BASIC
	while @@fetch_status = 0
		Begin	
		Set @Net_Salary  = 0	
							
									
					Declare @GatePass_Amount as numeric(18,2) 
					set @GatePass_Amount = 0
					
					select @Total_Deduction = sum(Total_Dedu_Amount) ,@PT = sum(PT_Amount) ,@Loan =  sum(( Loan_Amount + Loan_Intrest_Amount ) )
							,@Advance =  sum(Isnull(Advance_Amount,0)) ,@Net_Salary = sum(Net_Amount) ,@Revenue_Amt = sum(Isnull(Revenue_amount,0)),@LWF_Amt =sum(Isnull(LWF_Amount,0)),@Other_Dedu= sum(Isnull(Other_Dedu_Amount,0))
							,@Arear_Days = Sum(Isnull(Arear_Day,0)),@GatePass_Amount = SUM(isnull(GatePass_Amount,0))
					from T0200_Monthly_salary WITH (NOLOCK) where Emp_ID = @CTC_EMP_ID 
							and Month_st_date between @From_Date and @To_Date
							--and salary_status<>'Hold'
							group by Emp_ID
							
					select @Total_Deduction = sum(Total_Dedu_Amount) ,@PT = sum(PT_Amount) ,@Loan =  sum(( Loan_Amount + Loan_Intrest_Amount ) )
							,@Advance =  sum(Isnull(Advance_Amount,0)) ,@Hold_Amount =ISNULL(sum(Net_Amount),0) ,@Revenue_Amt = sum(Isnull(Revenue_amount,0)),@LWF_Amt =sum(Isnull(LWF_Amount,0)),@Other_Dedu= sum(Isnull(Other_Dedu_Amount,0))
							,@Arear_Days = Sum(Isnull(Arear_Day,0)),@GatePass_Amount = SUM(isnull(GatePass_Amount,0))
					from T0200_Monthly_salary WITH (NOLOCK) where Emp_ID = @CTC_EMP_ID 
							and Month_st_date between @From_Date and @To_Date
							and salary_status='Hold'
							group by Emp_ID		
										
										
					update  #CTCMast set Basic_Salary = Basic_Salary + @Basic_Salary					
					    ,Net_Amount =Net_Amount + @Net_Salary
						where #CTCMast.Cmp_ID = @CTC_CMP_ID and #CTCMast.Emp_ID = @CTC_EMP_ID
						
					update  #CTCMast set Basic_Salary = Basic_Salary + @Basic_Salary					
					    ,Hold_Amount =isnull(@Hold_Amount,0)
						where #CTCMast.Cmp_ID = @CTC_CMP_ID and #CTCMast.Emp_ID = @CTC_EMP_ID	
					
				fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID,@CTC_BASIC
				End
	close CTC_UPDATE	
	deallocate CTC_UPDATE
	
	update #CTCMast set Bank_Ac_No= ' ' + Bank_Ac_No Where Bank_Ac_No <> 'CASH' and Bank_Ac_No <>'CHEQUE'-- and Reim_Type <>'Total_Amount' and Reim_Type <>'Currency_Rate'
		
		
	if @Summary=''
	begin
	Select CM.*,inc.inc_bank_ac_No as inc_bank_ac_No from #CTCMast CM
	inner join t0080_emp_master em WITH (NOLOCK) on cm.emp_id = em.emp_id
	inner join t0095_increment Inc WITH (NOLOCK) on em.increment_id = inc.increment_id	
	Order by CM.Emp_code
	end
	else 
	begin
		
		if @Summary='0' --------for GroupBy Branch---------------------------
		begin			
		set @String = ' select CM.Branch as Unit,0 as unit_name,Cm.Bank_Ac_No,Cm.p_from_date,cm.p_to_date,cm.cmp_name,cm.cmp_address,'+CAST(case when @salary_type='0' then 0 else 1 end as varchar(20)) +' as sal_type, SUM(CM.Basic_Salary) as Basic_Salary ,SUM(CM.Actual_CTC) as CTC,SUM(cm.net_amount)as Net_Amount,SUM(cm.Hold_amount)as Hold_Amount'

		set @String = @String + ' from #CTCMast CM group By Branch_Id,branch,Bank_Ac_No,p_from_date,p_to_date,cmp_name,cmp_address'
		exec(@String)
		end
		else if @Summary='1' --------for GroupBy Grade---------------------------
		begin
		set @String = ' select CM.Grade as Unit,1 as unit_name,Cm.Bank_Ac_No,Cm.p_from_date,cm.p_to_date,cm.cmp_name,cm.cmp_address,'+CAST(case when @salary_type='0' then 0 else 1 end as varchar(20)) +' as sal_type, SUM(CM.Basic_Salary) as Basic_Salary ,SUM(CM.Actual_CTC) as CTC,SUM(cm.net_amount)as Net_Amount,SUM(cm.Hold_amount)as Hold_Amount'

		set @String = @String + ' from #CTCMast CM group By Grade,Bank_Ac_No,p_from_date,p_to_date,cmp_name,cmp_address'
		exec(@String)

		end
		else if @Summary='2' --------for GroupBy Category_Name---------------------------
		begin
		set @String = ' select CM.Cat_Name as Unit,2 as unit_name,Cm.Bank_Ac_No,Cm.p_from_date,cm.p_to_date,cm.cmp_name,cm.cmp_address,'+CAST(case when @salary_type='0' then 0 else 1 end as varchar(20)) +' as sal_type, SUM(CM.Basic_Salary) as Basic_Salary ,SUM(CM.Actual_CTC) as CTC,SUM(cm.net_amount)as Net_Amount,SUM(cm.Hold_amount)as Hold_Amount'

		set @String = @String + ' from #CTCMast CM group By Cat_Name,Bank_Ac_No,p_from_date,p_to_date,cmp_name,cmp_address'
		exec(@String)

		end
		else if @Summary='3' --------for GroupBy Department---------------------------
		begin
		set @String = ' select CM.Deptartment as Unit,3 as unit_name,Cm.Bank_Ac_No,Cm.p_from_date,cm.p_to_date,cm.cmp_name,cm.cmp_address,'+CAST(case when @salary_type='0' then 0 else 1 end as varchar(20)) +' as sal_type, SUM(CM.Basic_Salary) as Basic_Salary  ,SUM(CM.Actual_CTC) as CTC,SUM(cm.net_amount)as Net_Amount,SUM(cm.Hold_amount)as Hold_Amount'

		set @String = @String + ' from #CTCMast CM group By Deptartment,Bank_Ac_No,p_from_date,p_to_date,cmp_name,cmp_address'
		exec(@String)

		end
		else if @Summary='4' --------for GroupBy designation---------------------------
		begin
		set @String = ' select CM.Designation as Unit,4 as unit_name,Cm.Bank_Ac_No,Cm.p_from_date,cm.p_to_date,cm.cmp_name,cm.cmp_address,'+CAST(case when @salary_type='0' then 0 else 1 end as varchar(20)) +' as sal_type, SUM(CM.Basic_Salary) as Basic_Salary ,SUM(CM.Actual_CTC) as CTC,SUM(cm.net_amount)as Net_Amount,SUM(cm.Hold_amount)as Hold_Amount'

		set @String = @String + ' from #CTCMast CM group By Designation,Bank_Ac_No,p_from_date,p_to_date,cmp_name,cmp_address'
		exec(@String)

		end
		else if @Summary='5' --------for GroupBy TypeName---------------------------
		begin
		set @String = ' select CM.TypeName as Unit,5 as unit_name,Cm.Bank_Ac_No,Cm.p_from_date,cm.p_to_date,cm.cmp_name,'+CAST(case when @salary_type='0' then 0 else 1 end as varchar(20)) +' as sal_type,cm.cmp_address, SUM(CM.Basic_Salary) as Basic_Salary ,SUM(CM.Actual_CTC) as CTC,SUM(cm.net_amount)as Net_Amount,SUM(cm.Hold_amount)as Hold_Amount'

		set @String = @String + ' from #CTCMast CM group By TypeName,Bank_Ac_No,p_from_date,p_to_date,cmp_name,cmp_address'
		exec(@String)

		end
		else if @Summary='6' -----for division wise-------------------
		begin
		set @String = ' select CM.Division as Unit,6 as unit_name,Cm.Bank_Ac_No,Cm.p_from_date,cm.p_to_date,'+CAST(case when @salary_type='0' then 0 else 1 end as varchar(20)) +' as sal_type,cm.cmp_name,cm.cmp_address, SUM(CM.Basic_Salary) as Basic_Salary ,SUM(CM.Actual_CTC) as CTC,SUM(cm.net_amount)as Net_Amount,SUM(cm.Hold_amount)as Hold_Amount'
		set @String = @String + ' from #CTCMast CM group By Division,Bank_Ac_No,p_from_date,p_to_date,cmp_name,cmp_address'
		
		exec(@String)

		end
		else if @Summary='7' --------for GroupBy Vertical Wise---------------------------
		begin
		set @String = ' select CM.sub_vertical as Unit,7 as unit_name,Cm.Bank_Ac_No,'+CAST(case when @salary_type='0' then 0 else 1 end as varchar(20)) +' as sal_type,Cm.p_from_date,cm.p_to_date,cm.cmp_name,cm.cmp_address,SUM(CM.Basic_Salary) as Basic_Salary ,SUM(CM.Actual_CTC) as CTC,SUM(cm.net_amount)as Net_Amount,SUM(cm.Hold_amount)as Hold_Amount'

		set @String = @String + ' from #CTCMast CM group By sub_vertical,Bank_Ac_No,p_from_date,p_to_date,cmp_name,cmp_address'
		exec(@String)

		end
		else if @Summary='8' --------for GroupBy SuB Branch---------------------------
		begin
		set @String = ' select CM.sub_branch as Unit,8 as unit_name,'+CAST(case when @salary_type='0' then 0 else 1 end as varchar(20)) +' as sal_type,Cm.Bank_Ac_No,Cm.p_from_date,cm.p_to_date,cm.cmp_name,cm.cmp_address,SUM(CM.Basic_Salary) as Basic_Salary ,SUM(CM.Actual_CTC) as CTC,SUM(cm.net_amount)as Net_Amount,SUM(cm.Hold_amount)as Hold_Amount'

		set @String = @String + ' from #CTCMast CM group By sub_branch,Bank_Ac_No,p_from_date,p_to_date,cmp_name,cmp_address'
		exec(@String)

		end
		else if @Summary='9' ----------for GroupBy Business Segment--------------
		begin
		set @String = 'select CM.Segment_Name as Unit,'+CAST(case when @salary_type='0' then 0 else 1 end as varchar(20)) +' as sal_type, 9 as unit_name,Cm.Bank_Ac_No,Cm.p_from_date,cm.p_to_date,cm.cmp_name,cm.cmp_address,SUM(CM.Basic_Salary) as Basic_Salary ,SUM(CM.Actual_CTC) as CTC,SUM(cm.net_amount)as Net_Amount,SUM(cm.Hold_amount)as Hold_Amount'
		set @String = @String + ' from #CTCMast CM group By Segment_Name,Bank_Ac_No,p_from_date,p_to_date,cmp_name,cmp_address'
		exec(@String)
		end
		end
	
	
	
Return




