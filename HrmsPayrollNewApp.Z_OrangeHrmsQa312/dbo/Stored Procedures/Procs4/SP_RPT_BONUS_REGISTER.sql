



---Author : Hardik Barot 
---Date : 12/04/2013
---Description : For Bonus Month Wise Detail
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_RPT_BONUS_REGISTER]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   
	,@Cat_ID		numeric  
	,@Grd_ID		numeric 
	,@Type_ID		numeric 
	,@Dept_ID		numeric 
	,@Desig_ID		numeric 
	,@Emp_ID		numeric 
	,@Constraint		varchar(5000) = ''
	,@Report_Type tinyint= 0
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
			select distinct I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
					Inner Join T0180_BONUS B WITH (NOLOCK) on I.Emp_ID = B.Emp_ID
					Inner Join T0190_BONUS_DETAIL BD WITH (NOLOCK) on B.Bonus_ID = BD.Bonus_ID
			Where I.Cmp_ID = @Cmp_ID 
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
			And B.From_Date >= @From_Date And B.To_Date <= @To_Date
		end

		
		CREATE table #Emp_All 
		(
			Emp_ID	numeric,
			for_date datetime,
			Gross_Salary Numeric(22,2),
			Earned_Gross_Salary Numeric(22,2),
			Working_Days Numeric(18,2),
			Present_Days Numeric(18,2),
			Bonus_Applicable_Salary Numeric(22,2),
			Bonus_Amount Numeric(22,2),
			Wages_Type varchar(15)
		)	

		CREATE table #Date
		(
			For_Date Datetime
		)	

		Declare @Temp_For_Date as Datetime
		Set @Temp_For_Date = @From_Date

	
		While @Temp_For_Date <= @To_Date
			Begin
				Insert Into #Date
				Select @Temp_For_Date	   
				   
				Set @Temp_For_Date = DATEADD(M,1,@Temp_For_Date)
			End

		Insert Into #Emp_All 
		Select Emp_Id,For_Date,0,0,0,0,0,0,'' From @Emp_Cons Cross Join #Date

		
		Declare @Emp_Id_Cur as Numeric
		Declare @For_Date as Datetime
		Declare @Increment_Id as Numeric
		Declare @Wages_Type as Varchar(15)
		Declare @Effect_Allow_Amount as Numeric(18,2)
		Declare @Basic_Salary as Numeric(18,2)
		
		Declare curBonus cursor for                    
			Select Emp_ID,for_date from #Emp_All
		open curBonus                      
		fetch next from curBonus into @Emp_Id_Cur,@For_Date
		while @@fetch_status = 0                    
		begin                    

			Set @Basic_Salary = 0
			Set @Effect_Allow_Amount = 0
			Set @Increment_Id = 0
			Set @Wages_Type = ''
			
			Select @Increment_Id = Increment_Id, @Wages_Type = Wages_Type
				FROM T0095_Increment I WITH (NOLOCK) inner join       
				 (SELECT max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)       
				  WHERE  Increment_Effective_date <= @Temp_For_Date      
				  AND Cmp_ID = @Cmp_ID      
				  GROUP BY emp_ID) Qry on      
				 I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date      
			WHERE I.Emp_ID = @Emp_Id_Cur
			
			Select @Basic_Salary = isnull(sum(basic_salary),0)
			from T0200_MONTHLY_SALARY WITH (NOLOCK) where cmp_id=@Cmp_ID and emp_id=@Emp_Id_Cur 
			and Month(month_end_date) = Month(@For_Date) and Year(month_end_date) = Year(@For_Date)


			Select @Effect_Allow_Amount = Isnull(Sum(E_AD_AMOUNT),0) 
			From T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join
				T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = AM.AD_ID 
			Where AD_EFFECT_ON_BONUS = 1 And EED.Cmp_ID=@Cmp_ID and Emp_id= @Emp_Id_Cur 
				And INCREMENT_ID = @Increment_Id
			
			Update #Emp_All Set Bonus_Applicable_Salary =  BD.Bonus_Calculated_Amount,Bonus_Amount = BD.Bonus_Amount,
				Present_Days = BD.Present_Days, Working_Days = BD.Working_Days, Wages_Type = @Wages_Type,
				Gross_Salary = @Basic_Salary + @Effect_Allow_Amount, 
			Earned_Gross_Salary = Case When BD.Working_Days > 0 Then 
				((@Basic_Salary + @Effect_Allow_Amount)* BD.Present_Days)/BD.Working_Days
				Else 0 End
			From T0180_BONUS B Inner Join T0190_BONUS_DETAIL BD
				On B.Bonus_ID = BD.Bonus_ID Inner Join 
			#Emp_All E On BD.Month_Date = E.for_date And E.Emp_ID = B.Emp_ID
			Where BD.Month_Date = @For_Date
			
			
			fetch next from curBonus into @Emp_Id_Cur,@For_Date
	    end                    
		close curBonus                    
		deallocate curBonus 
		
		
		select I_Q.* ,EA.*,I_q.Basic_Salary as Actual_Bacic_Salary, E.Emp_Code,E.Emp_Full_Name as Emp_Full_Name,BM.branch_name,BM.branch_address,BM.Comp_name,CM.Cmp_Name,CM.Cmp_Address,Dept_Name,Desig_Name,grd_name,type_name,
			@From_Date P_From_Date ,@To_Date P_To_Date ,B_Q.PRESENT_DAYS,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),@From_Date) AS AGE
		from dbo.T0080_EMP_MASTER E WITH (NOLOCK) inner join 
		#Emp_All EA on E.Emp_ID=EA.Emp_ID  inner join 
		 dbo.T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID inner join
		    			( select I.Emp_Id , Grd_ID,Branch_ID,I.Basic_Salary,Cat_ID,Desig_ID,Dept_ID,Type_ID from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  inner join
								(SELECT SUM(ISNULL(Sal_Cal_Days,0))AS PRESENT_DAYS,EMP_ID FROM dbo.T0200_MONTHLY_SALARY  WITH (NOLOCK)
			WHERE MONTH_ST_DATE >=@from_date AND MONTH_END_DATE <= @to_date GROUP BY EMP_ID)B_Q
				ON I_Q.EMP_ID = B_Q.EMP_ID INNER JOIN 
					dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID Left outer join
					dbo.t0040_general_setting GS WITH (NOLOCK) on BM.Branch_ID=GS.Branch_ID
		WHERE E.Cmp_ID = @Cmp_Id And E.Emp_ID in (select Emp_ID From @Emp_Cons) 
		order by E.Emp_Code asc 
		
	RETURN




