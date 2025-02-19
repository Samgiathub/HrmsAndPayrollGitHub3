CREATE PROCEDURE [dbo].[SP_RPT_BONUS_FORMC_NEW]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint		varchar(MAX) = ''
	,@Report_Type tinyint=0
	,@Bank_Id        numeric = 0  --Added By Jimit 14052019 as parameter is passing from page level so default value is set to 0 
AS
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON ;
	SET NOCOUNT ON;   

	

	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
		 
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
		
		Declare @Dumy_From_date datetime
		Declare @Dumy_To_date datetime
		declare @While_date datetime
		
	
	
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

			--select I.Emp_Id from dbo.T0095_Increment I inner join 
			--		( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment
			--		where Increment_Effective_date <= @To_Date
			--		and Cmp_ID = @Cmp_ID
			--		group by emp_ID  ) Qry on
			--		I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			--Where Cmp_ID = @Cmp_ID 
			--and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			--and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			--and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			--and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			--and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			--and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			--and I.Emp_ID in 
			--	( select Emp_Id from
			--	--(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
			--	(select EM.emp_id, EM.cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from dbo.T0080_EMP_MASTER As EM Inner Join dbo.T0110_EMP_LEFT_JOIN_TRAN As EL ON EM.Emp_Id=El.Emp_Id Where EM.Is_Yearly_Bonus=1 And EM.Is_Emp_FNF<>1) qry  --Nikunj 29-Sep-2010
			--	where cmp_ID = @Cmp_ID   and  
			--	(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
			--	or ( @To_Date  >= join_Date  and @To_Date <= left_date )
			--	or Left_date is null and @To_Date >= Join_Date)
			--	or @To_Date >= left_date  and  @From_Date <= left_date ) 
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
			
		
		--Declare @Emp_Basic Table
		--(
		--	Emp_ID	numeric,
		--	for_date datetime,
		--	Actual_Bacic_Salary numeric(22,2)
		--)
		
		--Declare @Emp_All Table
		--(
		--	Emp_ID	numeric,
		--	for_date datetime,
		--	Actual_Earn_Salary numeric(22,2),
		--	Bonus_Salary numeric(22,2),
		--	Ex_Gratia_Salary numeric(22,2),
		--	Bonus_Amount numeric(22,2),
		--	Ex_Gratia_Amount numeric(22,2)
		--)	

		
		--select @Dumy_From_date = dbo.GET_MONTH_ST_DATE(month(@From_Date),year(@From_Date))
		--select @Dumy_To_date = dbo.GET_MONTH_END_DATE(month(@TO_Date),year(@TO_Date))
		
		--select @While_date = dbo.GET_MONTH_END_DATE(month(@From_date),year(@From_date))

		--while @Dumy_From_date <=@Dumy_To_date 
		--	Begin
		--			--select @Dumy_From_date,@Dumy_To_date,@While_date
		--		Insert into @Emp_Basic 
		--		select Emp_ID,@Dumy_From_date,Basic_Salary from dbo.T0200_MONTHLY_SALARY where Cmp_ID=@Cmp_ID And Month_st_date >=@Dumy_From_date 
		--		And Month_End_date <=@While_date And Emp_ID in(select Emp_ID from @Emp_Cons)
				
				
		--		Update @Emp_Basic 
		--		set Actual_Bacic_Salary=Actual_Bacic_Salary+isnull(S_Basic_Salary,0)  from @Emp_Basic MSS inner join
		--		(select Emp_ID,S_Basic_Salary from T0201_MONTHLY_SALARY_SETT where S_Month_St_Date>=@Dumy_From_date And S_Month_End_Date<=@While_date)Q
		--		on MSS.Emp_ID=Q.Emp_ID where for_date= @Dumy_From_date And MSS.Emp_ID=Q.Emp_ID 
				

				
		--		insert into @Emp_All
		--		select Emp_ID,@Dumy_From_date,Sum(salary_amount),0,0,0,0 from dbo.T0200_MONTHLY_SALARY where Cmp_ID=@Cmp_ID And Month_st_date >=@Dumy_From_date 
		--		And Month_End_date <=@While_date And Emp_ID in(select Emp_ID from @Emp_Cons) Group by Emp_ID
				
				
				
		--		Update @Emp_All 
		--		set Actual_Earn_Salary=Actual_Earn_Salary+isnull(S_salary_amount,0)  from @Emp_All MSS inner join
		--		(select Emp_ID,S_salary_amount from T0201_MONTHLY_SALARY_SETT where S_Month_St_Date>=@Dumy_From_date And S_Month_End_Date<=@While_date)Q
		--		on MSS.Emp_ID=Q.Emp_ID where for_date= @Dumy_From_date And MSS.Emp_ID=Q.Emp_ID 
				
				
		--		set @Dumy_From_date = dateadd(m,1,@Dumy_From_date)            
		--		set @While_date =  dbo.GET_MONTH_END_DATE(month(dateadd(m,1,@While_date)),Year(dateadd(m,1,@While_date)))  
				
				
				
				   
		--	End

		--Declare @New_Emp_ID numeric
		--Declare @New_Branch_ID numeric
		--Declare @Bonus_Min_Limit numeric
		--Declare @Bonus_Max_Limit numeric
		--Declare @Bonus_Per numeric(18,2)
		--Declare @Actual_Bacic_Salary numeric
		--Declare @Yearly_Limit numeric
		--Declare @For_Date datetime

		--declare curBonus cursor for                    
		--select Emp_ID,For_Date,Actual_Bacic_Salary from @Emp_Basic        
		--open curBonus                      
		--fetch next from curBonus into @New_Emp_ID,@For_Date,@Actual_Bacic_Salary
		--while @@fetch_status = 0                    
		--begin                    
		----	select @New_Emp_ID,@For_Date,@Actual_Bacic_Salary
  --         select @New_Branch_ID=Branch_ID from dbo.T0095_Increment I inner join 
		--			( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment
		--			where Increment_Effective_date <= @To_Date
		--			and Cmp_ID = @Cmp_ID
		--			group by emp_ID ) Qry on I.Emp_ID=Qry.Emp_ID
		
		--  select 	@Bonus_Min_Limit=isnull(Bonus_Min_Limit,0),
		--			@Bonus_Max_Limit=isnull(Bonus_Max_Limit,0),
		--			@Bonus_Per=isnull(Bonus_Per,0)
		--  from dbo.t0040_general_setting where branch_ID=@New_Branch_ID
		  
		--  --set @Yearly_Limit = isnull(@Bonus_Min_Limit,0) * 12
		--  Declare @New_Actual_Earn_Salary numeric 
		--			select @New_Actual_Earn_Salary = Actual_Earn_Salary from @Emp_All where Emp_ID=@New_emp_id And for_date=@For_Date
			
		----	select @New_Actual_Earn_Salary = @New_Actual_Earn_Salary + isnull(s_salary_amount,0) from t0201_MONTHLY_SALARY_SETT where Emp_ID=@New_emp_id and s_month_st_date = @For_Date

		
		--  if (isnull(@Actual_Bacic_Salary,0) <= @Bonus_Max_Limit)
		--	Begin	
					
		--			if @New_Actual_Earn_Salary >= @Bonus_Min_Limit
		--				Begin
		--					Update @Emp_All set Bonus_Salary = @Bonus_Min_Limit ,Ex_Gratia_Salary=(Actual_Earn_Salary-@Bonus_Min_Limit) 
		--					where Emp_ID=@New_Emp_ID And for_date=@For_Date 		
		--				End
		--			else
		--				Begin
		--					Update @Emp_All set Bonus_Salary = Actual_Earn_Salary 
		--					where Emp_ID=@New_Emp_ID And for_date=@For_Date 	
		--				End	
		--			--
		--			--And Actual_Earn_Salary >= @Yearly_Limit
		--	End
		--  /*else if (isnull(@Actual_Bacic_Salary,0) < @Bonus_Min_Limit) 
		--	Begin 
		--		Update @Emp_All set Bonus_Salary = Actual_Earn_Salary where Emp_ID=@New_Emp_ID
		--	End	*/
		--  else if (isnull(@Actual_Bacic_Salary,0) > @Bonus_Max_Limit) 	
		--	Begin 
		--		Update @Emp_All set Ex_Gratia_Salary = Actual_Earn_Salary where Emp_ID=@New_Emp_ID And for_date=@For_Date 
		--	End	
			
		--	Update @Emp_All set Ex_Gratia_Amount = (Ex_Gratia_Salary * @Bonus_Per)/100  where Emp_ID=@New_Emp_ID And for_date=@For_Date 
		--	Update @Emp_All set Bonus_Amount = (Bonus_Salary * @Bonus_Per)/100  where Emp_ID=@New_Emp_ID And for_date=@For_Date 
			
		--fetch next from curBonus into @New_Emp_ID,@For_Date,@Actual_Bacic_Salary
	 --   end                    
		--close curBonus                    
		--deallocate curBonus 
		
		--	Declare @Emp_All_Final Table
		--(
		--	Emp_ID	numeric,
		--	for_date datetime,
		--	Actual_Earn_Salary numeric(22,2),
		--	Bonus_Salary numeric(22,2),
		--	Ex_Gratia_Salary numeric(22,2),
		--	Bonus_Amount numeric(22,2),
		--	Ex_Gratia_Amount numeric(22,2)
		--)	
		
	

		
		--insert into @Emp_All_Final
		--select Emp_ID,@From_Date ,SUM(Actual_Earn_Salary),SUM(Bonus_Salary),SUM(Ex_Gratia_Salary),SUM(Bonus_Amount),SUM(Ex_Gratia_Amount) from @Emp_All group by Emp_ID 
		

		
		--if @Report_Type =1
		--	Begin
		--		select I_Q.* ,EA.*,I_q.Basic_Salary as Actual_Bacic_Salary, E.Emp_Code,E.Emp_Full_Name as Emp_Full_Name,BM.branch_name,BM.branch_address,BM.Comp_name,CM.Cmp_Name,CM.Cmp_Address,Dept_Name,Desig_Name,grd_name,type_name,
		--@From_Date P_From_Date ,@To_Date P_To_Date ,B_Q.PRESENT_DAYS,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),@From_Date) AS AGE
		--from dbo.T0080_EMP_MASTER E 
		--  inner join 
		--@Emp_All_Final EA on E.Emp_ID=EA.Emp_ID  inner join 
		--     dbo.T0010_Company_master CM on E.Cmp_ID =Cm.Cmp_ID inner join
		--    			( select I.Emp_Id , Grd_ID,Branch_ID,I.Basic_Salary,Cat_ID,Desig_ID,Dept_ID,Type_ID from dbo.T0095_Increment I inner join 
		--			( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment
		--			where Increment_Effective_date <= @To_Date
		--			and Cmp_ID = @Cmp_ID
		--			group by emp_ID  ) Qry on
		--			I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
		--		on E.Emp_ID = I_Q.Emp_ID  inner join
		--						(SELECT SUM(ISNULL(Sal_Cal_Days,0))AS PRESENT_DAYS,EMP_ID FROM dbo.T0200_MONTHLY_SALARY  
		--	WHERE MONTH_ST_DATE >=@from_date AND MONTH_END_DATE <= @to_date GROUP BY EMP_ID)B_Q
		--		ON I_Q.EMP_ID = B_Q.EMP_ID INNER JOIN 
		--			dbo.T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
		--			dbo.T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
		--			dbo.T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
		--			dbo.T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
		--			dbo.T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID Left outer join
		--			dbo.t0040_general_setting GS on BM.Branch_ID=GS.Branch_ID
		--WHERE E.Cmp_ID = @Cmp_Id  And isnull(EA.Bonus_Amount,0) > 0 And E.Emp_ID in (select Emp_ID From @Emp_Cons) order by E.Emp_Code asc -- And  isnull(Actual_Earn_Salary,0) <= (isnull(GS.Bonus_Min_Limit,0)*12) 
		--	End
		--else
		--	Begin
			
		--		select I_Q.* ,EA.*,I_q.Basic_Salary as Actual_Bacic_Salary, E.Emp_Code,E.Emp_Full_Name as Emp_Full_Name,BM.branch_name,BM.branch_address,BM.Comp_name,CM.Cmp_Name,CM.Cmp_Address,Dept_Name,Desig_Name,grd_name,type_name,
		--@From_Date P_From_Date ,@To_Date P_To_Date ,B_Q.PRESENT_DAYS,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),@From_Date) AS AGE
		--from dbo.T0080_EMP_MASTER E 
		--inner join 
		--@Emp_All_Final EA on E.Emp_ID=EA.Emp_ID  inner join 
		--     dbo.T0010_Company_master CM on E.Cmp_ID =Cm.Cmp_ID inner join
		--    			( select I.Emp_Id ,I.Increment_ID,I.Basic_Salary , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from dbo.T0095_Increment I inner join 
		--			( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment
		--			where Increment_Effective_date <= @To_Date
		--			and Cmp_ID = @Cmp_ID
		--			group by emp_ID  ) Qry on
		--			I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
		--		on E.Emp_ID = I_Q.Emp_ID  inner join
		--						(SELECT SUM(ISNULL(Sal_Cal_Days,0))AS PRESENT_DAYS,EMP_ID FROM dbo.T0200_MONTHLY_SALARY  
		--	WHERE MONTH_ST_DATE >=@from_date AND MONTH_END_DATE <= @to_date GROUP BY EMP_ID)B_Q
		--		ON I_Q.EMP_ID = B_Q.EMP_ID INNER JOIN 
		--			dbo.T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
		--			dbo.T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
		--			dbo.T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
		--			dbo.T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
		--			dbo.T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID inner join 
		--			dbo.T0100_EMP_EARN_DEDUCTION ED on I_Q.Increment_ID=ED.Increment_ID inner join
		--			dbo.T0050_AD_MASTER AM on ED.Ad_ID=Am.ad_ID 
		--WHERE E.Cmp_ID = @Cmp_Id And AM.ad_def_id=17 And   E.Emp_ID in (select Emp_ID From @Emp_Cons) order by E.Emp_Code asc 
		--	End	
		if @Report_Type =1
		begin
		select I_Q.* ,Bonus_Effect_Month,Bonus_Effect_Year, E.Emp_Code,E.alpha_Emp_code,E.Emp_Full_Name as Emp_Full_Name,BM.branch_name,BM.branch_address,BM.Comp_name,CM.Cmp_Name,CM.Cmp_Address,Dept_Name,Desig_Name,grd_name,type_name,B.Bonus_Calculated_amount,B.Bonus_amount,
		B.From_Date as P_From_Date ,B.To_Date as P_To_Date ,B_Q.PRESENT_DAYS,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),@From_Date) AS AGE,B_Q.Day_Year
		,dbo.F_GET_Emp_Count(@Cmp_ID,@From_Date,@To_Date) as emp_count,B.Ex_Gratia_Bonus_Amount,B.Ex_Gratia_Calculated_Amount
		,B.Punja_other_cust_bonus_paid,b.Intrime_advance_bonus_paid,b.Deduction_mis_Amount,b.Income_Tax_on_Bonus,b.Net_Payable_Bonus 
		,E.Emp_Left_Date,VS.Vertical_Name,SV.SubVertical_Name,sb.SubBranch_Name
		from T0080_EMP_MASTER E WITH (NOLOCK) inner join 
		     t0180_bonus B WITH (NOLOCK) on E.Emp_ID =B.Emp_Id inner join
		     T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID inner join
		    			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Vertical_ID,subBranch_ID,SubVertical_ID,Payment_Mode from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  Inner join
								(SELECT SUM(ISNULL(SAL_CAL_DAYS,0))AS PRESENT_DAYS,MS.Emp_ID 
								,SUM(ISNULL(SAL_CAL_DAYS,0)-(ISNULL(HOLIDAY_DAYS,0) + ISNULL(Weekoff_Days,0))) as Day_Year
								FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK) Left Outer join
								T0180_BONUS BN WITH (NOLOCK) on MS.Emp_ID = BN.Emp_ID
								and Bn.From_Date >= @From_date and Bn.To_Date <= @to_date --added jimit 21062016
			WHERE MONTH_ST_DATE >= BN.From_Date AND MONTH_END_DATE <= BN.To_Date GROUP BY MS.Emp_ID)B_Q
				ON I_Q.EMP_ID = B_Q.EMP_ID INNER JOIN 
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID left join
					T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = VS.Vertical_ID left join 
					T0050_SubVertical SV  WITH (NOLOCK) on I_Q.SubVertical_ID = SV.SubVertical_ID left join
					T0050_SubBranch SB WITH (NOLOCK) on I_Q.subBranch_ID = SB.SubBranch_ID
		WHERE E.Cmp_ID = @Cmp_Id and  
		--b.Bonus_effect_Month = month(@From_Date)	 and b.bonus_effect_Year=  year(@From_Date)
		b.From_Date >= @From_Date and b.To_Date<= @To_Date
				And E.Emp_ID in (select Emp_ID From @Emp_Cons) 
				and (b.Bonus_Amount>0)
				order by E.Emp_Code asc 
		end
		else if @report_type=2
		begin
			--If Exists(Select 1 From T0180_BONUS B Inner Join @Emp_Cons EC on B.Emp_ID = EC.Emp_ID Where b.From_Date >= @From_Date and b.To_Date<= @To_Date) ---- Added by Hardik 03/11/2017 for Havmor
			--	BEGIN
					select I_Q.* ,Bonus_Effect_Month,Bonus_Effect_Year, E.Emp_Code,E.alpha_Emp_code,E.Emp_Full_Name as Emp_Full_Name,BM.branch_name,BM.branch_address,BM.Comp_name,CM.Cmp_Name,CM.Cmp_Address,Dept_Name,Desig_Name,grd_name,type_name,
					B.Bonus_Calculated_amount,B.Bonus_amount,
					B.From_Date as P_From_Date ,B.To_Date as P_To_Date ,B_Q.PRESENT_DAYS,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),@From_Date) AS AGE,B_Q.Day_Year
					,dbo.F_GET_Emp_Count(@Cmp_ID,@From_Date,@To_Date) as emp_count,B.Ex_Gratia_Bonus_Amount,B.Ex_Gratia_Calculated_Amount
					,B.Punja_other_cust_bonus_paid,b.Intrime_advance_bonus_paid,b.Deduction_mis_Amount,b.Income_Tax_on_Bonus,b.Net_Payable_Bonus
					,E.Emp_Left_Date,VS.Vertical_Name,SV.SubVertical_Name,sb.SubBranch_Name
					from T0080_EMP_MASTER E WITH (NOLOCK) inner join 
						 t0180_bonus B WITH (NOLOCK) on E.Emp_ID =B.Emp_Id 
						 --left OUTER JOIN T0210_MONTHLY_AD_DETAIL MD ON MD.Emp_ID = E.Emp_ID  --Added by Jaina 3-11-2017
						 inner join T0010_Company_master CM on E.Cmp_ID =Cm.Cmp_ID inner join
		    						( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Vertical_ID,subBranch_ID,SubVertical_ID,Payment_Mode from T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
								where Increment_Effective_date <= @To_Date
								and Cmp_ID = @Cmp_ID
								group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
							on E.Emp_ID = I_Q.Emp_ID  Inner join
											(SELECT SUM(ISNULL(SAL_CAL_DAYS,0))AS PRESENT_DAYS,MS.Emp_ID 
											,SUM(ISNULL(SAL_CAL_DAYS,0)-(ISNULL(HOLIDAY_DAYS,0) + ISNULL(Weekoff_Days,0))) as Day_Year
											FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK) Left Outer join
											T0180_BONUS BN WITH (NOLOCK) on MS.Emp_ID = BN.Emp_ID
											and Bn.From_Date >= @From_date and Bn.To_Date <= @to_date --added jimit 21062016
											--Added by Jaina 3-11-2017 Start
											--LEFT OUTER JOIN T0210_MONTHLY_AD_DETAIL MAD ON MAD.Emp_ID = MS.Emp_ID
											--INNER JOIN T0050_AD_MASTER A ON MAD.AD_ID = A.AD_ID AND A.AD_DEF_ID=19 
											--			AND MAD.For_Date BETWEEN @From_date AND @to_date
											--Added by Jaina 3-11-2017 End
						WHERE MONTH_ST_DATE >= BN.From_Date AND MONTH_END_DATE <= BN.To_Date GROUP BY MS.Emp_ID)B_Q
							ON I_Q.EMP_ID = B_Q.EMP_ID INNER JOIN 
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
								T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID left join
								T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = VS.Vertical_ID left join 
								T0050_SubVertical SV WITH (NOLOCK) on I_Q.SubVertical_ID = SV.SubVertical_ID left join
								T0050_SubBranch SB WITH (NOLOCK) on I_Q.subBranch_ID = SB.SubBranch_ID
					WHERE E.Cmp_ID = @Cmp_Id and  
					--b.Bonus_effect_Month = month(@From_Date)	 and b.bonus_effect_Year=  year(@From_Date)
					b.From_Date >= @From_Date and b.To_Date<= @To_Date
							And E.Emp_ID in (select Emp_ID From @Emp_Cons) 
							and (b.Bonus_Amount>0 )
							--order by E.Emp_Code asc 
				--END
			--ELSE
			--	BEGIN
				Union All   ---- Added by Hardik 03/11/2017 for Havmor
					SELECT I_Q.* ,Month(Qry.For_Date) As Bonus_Effect_Month, Year(Qry.For_Date) As Bonus_Effect_Year, 
						E.Emp_Code,E.Alpha_Emp_Code,E.Emp_Full_Name as Emp_Full_Name,BM.Branch_Name,BM.Branch_Address,BM.Comp_Name,CM.Cmp_Name,
						CM.Cmp_Address,DM.Dept_Name,DGM.Desig_Name,GM.Grd_Name,ETM.Type_Name,B_Q.Bonus_Calculated_amount,Qry.Bonus_Amount,
						@From_Date as P_From_Date ,@To_Date as P_To_Date ,B_Q.PRESENT_DAYS,DATEDIFF(YY,ISNULL(E.Date_Of_Birth,getdate()),@From_Date) AS AGE,B_Q.Day_Year
						,dbo.F_GET_Emp_Count(@Cmp_ID,@From_Date,@To_Date) as emp_count,0 As Ex_Gratia_Bonus_Amount,0 As Ex_Gratia_Calculated_Amount
						,0 As Punja_other_cust_bonus_paid, 0 As Intrime_advance_bonus_paid, 0 As Deduction_mis_Amount,0 As Income_Tax_on_Bonus,0 As Net_Payable_Bonus
						,E.Emp_Left_Date,VS.Vertical_Name,SV.SubVertical_Name,sb.SubBranch_Name
					from T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN
						@Emp_Cons EC On E.Emp_ID=EC.Emp_ID Inner JOIN
							(
								SELECT Qry1.Emp_ID,Sum(Qry1.Bonus_amount) As Bonus_Amount, Qry1.For_Date  FROM (
							SELECT MAD.Emp_ID,Sum(MAD.M_AD_Amount) as Bonus_amount,Max(MAD.For_Date) As For_Date
							FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) Inner Join T0050_AD_MASTER AM WITH (NOLOCK) On MAD.AD_ID=AM.AD_ID
								INNER JOIN EMP_FNF_ALLOWANCE_DETAILS EF WITH (NOLOCK) On MAD.AD_ID=EF.Ad_ID And Mad.Emp_ID = EF.Emp_ID
							WHERE MAD.CMP_ID=@Cmp_Id And MAD.For_Date BETWEEN @From_Date And @To_Date And MAD.FOR_FNF=1 And M_AD_Flag='I' and MAD.M_AD_Amount>0 And AM.AD_DEF_ID=19
								And EF.From_Date>= @From_Date And EF.To_Date<= @To_Date
							GROUP By MAD.Emp_ID
							UNION ALL
							SELECT Emp_ID,Sum(Net_Amount) as Bonus_amount,For_Date
							FROM MONTHLY_EMP_BANK_PAYMENT WITH (NOLOCK) where Cmp_Id=@Cmp_Id and Process_Type='Bonus' 
								And Payment_Date BETWEEN @From_Date And @To_Date And Net_Amount>0
							GROUP By Emp_ID,For_Date) Qry1 GROUP By Qry1.Emp_ID, Qry1.For_Date
							) Qry On E.Emp_ID = Qry.Emp_ID Inner join				
					 
						 T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID inner join
		    						( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Vertical_ID,subBranch_ID,SubVertical_ID,Payment_Mode from T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
								where Increment_Effective_date <= @To_Date
								and Cmp_ID = @Cmp_ID
								group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
							on E.Emp_ID = I_Q.Emp_ID  Inner join
											(SELECT SUM(ISNULL(PRESENT_DAYS,0))AS PRESENT_DAYS,MS.Emp_ID 
												,SUM(ISNULL(SAL_CAL_DAYS,0)-(ISNULL(HOLIDAY_DAYS,0) + ISNULL(Weekoff_Days,0))) as Day_Year,
												Sum(MS.Salary_Amount) As Bonus_Calculated_amount
											FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK) Left Outer join
												@Emp_Cons EC on MS.Emp_ID = EC.Emp_ID
											WHERE MONTH_ST_DATE >= @From_Date AND MONTH_END_DATE <= @To_Date GROUP BY MS.Emp_ID)B_Q
							ON I_Q.EMP_ID = B_Q.EMP_ID INNER JOIN 
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
								T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID left join
								T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = VS.Vertical_ID left join 
								T0050_SubVertical SV WITH (NOLOCK) on I_Q.SubVertical_ID = SV.SubVertical_ID left join
								T0050_SubBranch SB WITH (NOLOCK) on I_Q.subBranch_ID = SB.SubBranch_ID
					WHERE E.Cmp_ID = @Cmp_Id  
					--order by E.Emp_Code asc 
				--END
		end
		else if @report_type = 3
		begin
		select I_Q.* ,Bonus_Effect_Month,Bonus_Effect_Year, E.Emp_Code,E.alpha_Emp_code,E.Emp_Full_Name as Emp_Full_Name,BM.branch_name,BM.branch_address,BM.Comp_name,CM.Cmp_Name,CM.Cmp_Address,Dept_Name,Desig_Name,grd_name,type_name,B.Bonus_Calculated_amount,B.Bonus_amount,
		B.From_Date as P_From_Date ,B.To_Date as P_To_Date ,B_Q.PRESENT_DAYS,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),@From_Date) AS AGE,B_Q.Day_Year
		,dbo.F_GET_Emp_Count(@Cmp_ID,@From_Date,@To_Date) as emp_count,B.Ex_Gratia_Bonus_Amount,B.Ex_Gratia_Calculated_Amount
		,B.Punja_other_cust_bonus_paid,b.Intrime_advance_bonus_paid,b.Deduction_mis_Amount,b.Income_Tax_on_Bonus,b.Net_Payable_Bonus
		,E.Emp_Left_Date,VS.Vertical_Name,SV.SubVertical_Name,sb.SubBranch_Name
		from T0080_EMP_MASTER E WITH (NOLOCK) inner join 
		     t0180_bonus B WITH (NOLOCK) on E.Emp_ID =B.Emp_Id inner join
		     T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID inner join
		    			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Vertical_ID,subBranch_ID,SubVertical_ID,Payment_Mode from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  Inner join
								(SELECT SUM(ISNULL(SAL_CAL_DAYS,0))AS PRESENT_DAYS,MS.Emp_ID 
								,SUM(ISNULL(SAL_CAL_DAYS,0)-(ISNULL(HOLIDAY_DAYS,0) + ISNULL(Weekoff_Days,0))) as Day_Year
								FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK) Left Outer join
								T0180_BONUS BN WITH (NOLOCK) on MS.Emp_ID = BN.Emp_ID
								and Bn.From_Date >= @From_date and Bn.To_Date <= @to_date --added jimit 21062016
			WHERE MONTH_ST_DATE >= BN.From_Date AND MONTH_END_DATE <= BN.To_Date GROUP BY MS.Emp_ID)B_Q
				ON I_Q.EMP_ID = B_Q.EMP_ID INNER JOIN 
				
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID left join
					T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = VS.Vertical_ID left join 
					T0050_SubVertical SV WITH (NOLOCK) on I_Q.SubVertical_ID = SV.SubVertical_ID left join
					T0050_SubBranch SB WITH (NOLOCK) on I_Q.subBranch_ID = SB.SubBranch_ID
		WHERE E.Cmp_ID = @Cmp_Id and  
		--b.Bonus_effect_Month = month(@From_Date)	 and b.bonus_effect_Year=  year(@From_Date)
		b.From_Date >= @From_Date and b.To_Date<= @To_Date
				And E.Emp_ID in (select Emp_ID From @Emp_Cons) 
				and (b.Ex_Gratia_Bonus_Amount>0)
				order by E.Emp_Code asc 
		end
		else
		begin
		select I_Q.* ,Bonus_Effect_Month,Bonus_Effect_Year, E.Emp_Code,E.alpha_Emp_code,E.Emp_Full_Name as Emp_Full_Name,BM.branch_name,BM.branch_address,BM.Comp_name,CM.Cmp_Name,CM.Cmp_Address,Dept_Name,Desig_Name,grd_name,type_name,B.Bonus_Calculated_amount,B.Bonus_amount,
		B.From_Date as P_From_Date ,B.To_Date as P_To_Date ,B_Q.PRESENT_DAYS,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),@From_Date) AS AGE,B_Q.Day_Year
		,dbo.F_GET_Emp_Count(@Cmp_ID,@From_Date,@To_Date) as emp_count,B.Ex_Gratia_Bonus_Amount,B.Ex_Gratia_Calculated_Amount
		,B.Punja_other_cust_bonus_paid,b.Intrime_advance_bonus_paid,b.Deduction_mis_Amount,b.Income_Tax_on_Bonus,b.Net_Payable_Bonus
		,E.Emp_Left_Date,VS.Vertical_Name,SV.SubVertical_Name,sb.SubBranch_Name
		from T0080_EMP_MASTER E WITH (NOLOCK) inner join 
		     t0180_bonus B WITH (NOLOCK) on E.Emp_ID =B.Emp_Id inner join
		     T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID inner join
		    			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Vertical_ID,subBranch_ID,SubVertical_ID,Payment_Mode from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  Inner join
								(SELECT SUM(ISNULL(SAL_CAL_DAYS,0))AS PRESENT_DAYS,MS.Emp_ID 
								,SUM(ISNULL(SAL_CAL_DAYS,0)-(ISNULL(HOLIDAY_DAYS,0) + ISNULL(Weekoff_Days,0))) as Day_Year
								FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK) Left Outer join
								T0180_BONUS BN WITH (NOLOCK) on MS.Emp_ID = BN.Emp_ID
								and Bn.From_Date >= @From_date and Bn.To_Date <= @to_date --added jimit 21062016
			WHERE MONTH_ST_DATE >= BN.From_Date AND MONTH_END_DATE <= BN.To_Date GROUP BY MS.Emp_ID)B_Q
				ON I_Q.EMP_ID = B_Q.EMP_ID INNER JOIN 
				
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID left join
					T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = VS.Vertical_ID left join 
					T0050_SubVertical SV WITH (NOLOCK) on I_Q.SubVertical_ID = SV.SubVertical_ID left join
					T0050_SubBranch SB WITH (NOLOCK) on I_Q.subBranch_ID = SB.SubBranch_ID
		WHERE E.Cmp_ID = @Cmp_Id and  
		--b.Bonus_effect_Month = month(@From_Date)	 and b.bonus_effect_Year=  year(@From_Date)
		b.From_Date >= @From_Date and b.To_Date<= @To_Date
				And E.Emp_ID in (select Emp_ID From @Emp_Cons) 
				and (
				b.Bonus_Amount>0 --or b.Ex_Gratia_Bonus_Amount>0
				)
				order by E.Emp_Code asc 
		end
		
	RETURN

















