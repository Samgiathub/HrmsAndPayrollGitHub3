

---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_MONTHLY_DA_REVISED]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(max)
	,@AD_ID			numeric = 0
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  numeric = 0		
	,@Vertical_Id numeric = 0		 
	,@SubVertical_Id numeric = 0	 
	,@SubBranch_Id numeric = 0		 
	,@Show_Hidden_Allowance  bit = 1   --Added by Jaina 16-05-2017            	 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
 
	set @Show_Hidden_Allowance = 0
	 
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null

	IF @AD_ID = 0
		set @AD_ID = null
		
	IF @Salary_Cycle_id = 0	 -- Added By Gadriwala Muslim 21082013
	set @Salary_Cycle_id = null	
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubBranch_Id = null	
	
		
	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			
			
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 21082013
			and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 21082013
			and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 21082013
			and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 21082013
			
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
						
			
		end
	
	  Declare @Sal_St_Date   Datetime    
	  Declare @Sal_end_Date   Datetime  
	  declare @manual_salary_Period as numeric(18,0)
	  
		If @Branch_ID is null
			Begin 
				select Top 1 @Sal_St_Date  = Sal_st_Date,@manual_salary_Period= isnull(manual_salary_Period ,0) 
				  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
			End
		Else
			Begin
				select @Sal_St_Date  =Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0)
				  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
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
	 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
	   	   if @manual_salary_Period =0 
			Begin
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   Set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_End_Date  
			 end
		else
			begin
				select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)							   
			     Set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_End_Date    
			End	  
	 
	Create table #Tbl_Get_AD
	(
		Emp_ID numeric(18,0),
		Ad_ID numeric(18,0),
		for_date datetime,
		E_Ad_Percentage numeric(18,5),
		M_Ad_Amount numeric(18,2)
		
	)
	
	INSERT INTO #Tbl_Get_AD
		Exec P_Emp_Revised_Allowance_Get @Cmp_ID,@To_Date
		
	
	
	Declare @prev_month as datetime		
	select @prev_month= DATEADD(MONTH, DATEDIFF(MONTH, 0, @To_Date)-1, 0)	
	declare @prev_mnth_name as varchar(100)
	declare @Cur_mnth_name as varchar(100)
	select @prev_mnth_name= convert(varchar(3),@prev_month,107) + '-' + CAST(year(@prev_month) as varchar(20))
	select @Cur_mnth_name= convert(varchar(3),@To_Date,107) + '-' + CAST(year(@To_Date) as varchar(20))
	
	Create table #Tbl_Get_AD_OLD
	(
		Emp_ID_OLD numeric(18,0),
		Ad_ID_OLD numeric(18,0),
		for_date_OLD datetime,
		E_Ad_Percentage_OLD numeric(18,5),
		M_Ad_Amount_OLD numeric(18,2)
		
	)
	INSERT INTO #Tbl_Get_AD_OLD
		Exec P_Emp_Revised_Allowance_Get @Cmp_ID,@prev_month
		
	
	
	Create table #Tbl_Get_Details
	(
		Emp_ID numeric(18,0),
		Ad_ID numeric(18,0),
		Ad_Cur_Amount numeric(18,3),
		Ad_old_Amount numeric(18,3),
		Diff_Amount numeric(18,3),
		Month_Name varchar(100),
		Month_old_name varchar(100)
	)
	
	insert into #Tbl_Get_Details
		select TG.Emp_ID,TG.Ad_ID,TG.M_Ad_Amount,TGD.M_Ad_Amount_OLD,(TG.M_Ad_Amount - TGD.M_Ad_Amount_OLD),@prev_mnth_name,@Cur_mnth_name from #Tbl_Get_AD TG
			inner join #Tbl_Get_AD_OLD TGD on TGD.Emp_ID_OLD=TG.Emp_ID
			and TGD.Ad_ID_OLD=TG.Ad_ID
			inner join @Emp_Cons Ec on Tg.Emp_ID=EC.Emp_ID
	
	
	select Em.Alpha_Emp_Code,Em.Emp_ID,Em.Emp_Full_Name,Bm.Branch_Name,SB.SubBranch_Name,cm.Cmp_Name,Cm.Cmp_Address,am.AD_NAME,
	 am.AD_ID,@From_Date as From_Date,@To_Date as To_Date,TGD.Ad_Cur_Amount As M_Ad_Amount,
	 TGD.Ad_old_Amount as M_Ad_old_Amount,TGD.Diff_Amount,TGD.Month_Name as Cur_Month_Name
	 ,TGD.Month_old_name as Month_Prev_Name
	 ,VS.Vertical_Name,DGM.Desig_Name,GM.Grd_Name,Tm.Type_Name,DM.Dept_Name
	 ,sv.SubVertical_Name,BM.Branch_ID
	 from #Tbl_Get_Details TGD
	inner join T0050_AD_MASTER AM WITH (NOLOCK) on AM.AD_ID=TGD.Ad_ID
	inner join T0080_EMP_MASTER EM WITH (NOLOCK) on Em.Emp_ID=TGD.Emp_ID
	inner join @Emp_Cons EC on EC.Emp_ID=Em.Emp_ID
	inner join 
	(select I.Emp_ID,I.Grd_ID,I.Branch_ID,I.Desig_Id,I.Cmp_ID,I.Vertical_ID,I.subBranch_ID,I.Type_ID,I.Dept_ID,i.SubVertical_ID from T0095_INCREMENT I WITH (NOLOCK) inner join
		(select max(increment_id) as Increment_ID,Emp_id from T0095_INCREMENT WITH (NOLOCK)
			where Increment_Effective_Date <= @to_date and Cmp_ID=@Cmp_ID group by Emp_ID ) Qry
			on Qry.Emp_ID=I.Emp_ID and i.Increment_ID=Qry.Increment_ID) I_Q 
	on I_Q.Emp_ID=Em.Emp_ID	inner join
	T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID=BM.Branch_ID 	
	left join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
	LEFT join T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id =DGM.Desig_ID
	left join T0010_company_Master cm WITH (NOLOCK) on I_Q.Cmp_ID = cm.cmp_ID 
	Left join T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID=I_Q.Vertical_ID
	left join T0050_SubBranch SB WITH (NOLOCK) on SB.SubBranch_ID=I_Q.subBranch_ID
	left join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on dm.Dept_Id=I_Q.dept_id
	left join T0040_TYPE_MASTER Tm WITH (NOLOCK) on TM.Type_ID=I_Q.Type_ID
	left join T0050_SubVertical sv WITH (NOLOCK) on sv.SubVertical_ID=i_q.SubVertical_ID
	where TGD.Ad_ID=isnull(@AD_ID,TGD.Ad_ID)
			AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0  AND  AM.HIDE_IN_REPORTS = 1 AND AM.AD_NOT_EFFECT_SALARY=1 THEN 0 ELSE 1 END )=1  --CHANGE BY JAINA 16-05-2017
		
	drop table #Tbl_Get_AD
	drop table #Tbl_Get_AD_OLD
	drop table #Tbl_Get_Details
	
	
	--Select MAD.*,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Grd_Name,Alpha_Emp_Code as EMP_CODE,Type_Name,Dept_Name,Desig_Name,AD_Name,AD_LEVEL
	--,cmp_Name,Cmp_Address,Branch_Address,Comp_name,branch_name
	--,@from_Date as P_From_Date , @To_date as P_To_Date,BM.Branch_ID,E.Pan_No,I_Q.Basic_Salary
	--,E.Emp_First_Name,E.Alpha_Emp_Code  --added jimit 26062015
	--	 From T0210_MONTHLY_AD_DETAIL  MAD Inner join 
	--		  T0050_AD_MASTER ADM ON MAD.AD_ID = ADM.AD_ID INNER JOIN 
	--		  T0200_MONTHLY_SALARY MS ON MS.Sal_Tran_ID = MAD.Sal_Tran_ID INNER JOIN	
	--	T0080_EMP_MASTER E on MAD.emp_ID = E.emp_ID INNER  JOIN 
	--		@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
	--		( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,Basic_Salary from T0095_Increment I inner join 
	--				( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
	--			on E.Emp_ID = I_Q.Emp_ID  inner join
	--				T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
	--				T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
	--				T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
	--				T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id Inner join 
	--				T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID  Inner join
	--				T0010_company_Master cm on MAD.Cmp_ID = cm.cmp_ID 
					
	--	WHERE E.Cmp_ID = @Cmp_Id	 and For_date >=@From_Date and For_date <=@To_Date
	--			and  mad.AD_ID = isnull(@AD_ID,Mad.AD_ID) and MAD.M_AD_Amount <> 0
	--			and S_Sal_Tran_ID is null and L_Sal_Tran_ID is null
	--			and MS.Is_FNF <> 1 --Ankit 06072015
				
				-- added '>0' condition by Falak on 12-JAN-2011 to avoid hidden salary amount in summation.	
					
	RETURN 


