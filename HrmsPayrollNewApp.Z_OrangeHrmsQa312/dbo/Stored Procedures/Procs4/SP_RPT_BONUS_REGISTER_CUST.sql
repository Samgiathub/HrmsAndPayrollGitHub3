---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_RPT_BONUS_REGISTER_CUST]
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
	,@Constraint	varchar(MAX) = ''
	,@Report_Type tinyint=0
	,@Order_By   varchar(30) = 'Code' --Added by Jimit 28/09/2015 (To sort by Code/Name/Enroll No)

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 

	

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
			select distinct I.Emp_Id from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
					Inner Join dbo.T0180_BONUS B WITH (NOLOCK) on I.Emp_ID = B.Emp_ID
					Inner Join dbo.T0190_BONUS_DETAIL BD WITH (NOLOCK) on B.Bonus_ID = BD.Bonus_ID
			Where I.Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			--And B.From_Date >= @From_Date And B.To_Date <= @To_Date
			And (BD.Month_Date Between @From_Date and @To_Date)
		end

	IF @Report_Type = 1
		BEGIN
			-- Changed By Ali 22112013 EmpName_Alias
			Select E.Emp_ID ,E.Alpha_Emp_Code,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) as Emp_Full_Name ,Comp_Name,Branch_Address
			, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,Q_I.Branch_id,Q_I.Dept_Id,Q_I.Grd_Id,Q_I.Desig_Id, Q_I.Type_id
			,Type_Name
			,CMP_NAME,CMP_ADDRESS
			,@From_Date as P_From_date ,@To_Date as P_To_Date	
			From @Emp_Cons EC INNER JOIN  dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID =E.EMP_ID  INNER JOIN 
			( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Type_ID,I.Emp_ID FROM dbo.T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)	-- Ankit 11092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
			E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID INNER JOIN 
			dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.CMP_ID = E.CMP_ID Left outer join 
			dbo.T0040_Type_Master tm WITH (NOLOCK) on Q_I.Type_ID = tm.Type_ID 
			
			return 
		END

			
		
		Create table #Emp_All 
		(
			Sr_No Numeric identity,
			Emp_Code  Varchar(100),
			Emp_Full_Name  varchar(200),
			Emp_Father_Name  Varchar(150),
			Branch Varchar(150),
			Designation  Varchar(100),
			Department  Varchar(100),
			Emp_ID	numeric,
			Desig_dis_No    numeric(18,0) DEFAULT 0,   --added jimit 28/09/2015
			Enroll_No       VARCHAR(50)	DEFAULT ''		 --added jimit 28/09/2015 
			,Segment_Name  Varchar(500) default ''
			,Left_date     varchar(15) default ''
		)	


		Declare @Temp_For_Date as Datetime
		Set @Temp_For_Date = @From_Date
		Declare @val as Varchar(8000)
		Declare @MonthName as varchar(50)
		Declare @MonthBasic as varchar(50)
		Declare @valBW as Varchar(8000)
		Declare @Basicwages as varchar(50)
		
		While @Temp_For_Date <= @To_Date
			Begin
				Set @MonthName = ''
				Set @MonthName = Cast(Upper(Left(DATENAME(MONTH,@Temp_For_Date),3)) as varchar(4)) + '_' + Cast(YEAR(@Temp_For_Date) as varchar(50)) +'_'+ 'NO_OF_DAYS'
				
				Set @val = 'Alter table  #Emp_All Add ' + @MonthName + ' varchar(50)'
				exec (@val)	
				
				Set @Basicwages = ''
				Set @Basicwages = Cast(Upper(Left(DATENAME(MONTH,@Temp_For_Date),3)) as varchar(4)) + '_' + Cast(YEAR(@Temp_For_Date) as varchar(50)) + '_'+ 'BASIC_WAGES'
				
				Set @valBW = 'Alter table  #Emp_All Add ' + @Basicwages + ' varchar(50)'
				exec (@valBW)	
				
				Set @Basicwages = ''
				Set @Basicwages = Cast(Upper(Left(DATENAME(MONTH,@Temp_For_Date),3)) as varchar(4)) + '_' + Cast(YEAR(@Temp_For_Date) as varchar(50)) + '_'+ 'Ex_Gratia_WAGES'
				
				Set @valBW = 'Alter table  #Emp_All Add ' + @Basicwages + ' varchar(50)'
				exec (@valBW)	

				Set @Temp_For_Date = DATEADD(M,1,@Temp_For_Date)
			End
--

Set @val = ''
Set @val = 'Alter table  #Emp_All Add TOTAL_PRESENT_DAYS Numeric(18,2)'
exec (@val)	

Set @val = ''
Set @val = 'Alter table  #Emp_All Add BONUS_PERCENTAGE Numeric(18,2)'  -- Added by rohit on 09082016
exec (@val)	

Set @val = ''
Set @val = 'Alter table  #Emp_All Add TOTAL_WAGES Numeric(18,2)'
exec (@val)	

Set @val = ''
Set @val = 'Alter table  #Emp_All Add LEGAL_BONUS Numeric(18,2)'
exec (@val)	

Set @val = ''
Set @val = 'Alter table  #Emp_All Add TOTAL_EX_GRATIA_WAGES Numeric(18,2)'
exec (@val)	

Set @val = ''
Set @val = 'Alter table  #Emp_All Add EX_GRATIA_BONUS Numeric(18,2)'
exec (@val)	


Set @val = ''
Set @val = 'Alter table  #Emp_All Add Punja_other_cust_bonus_paid Numeric(18,2)'
exec (@val)	

Set @val = ''
Set @val = 'Alter table  #Emp_All Add Intrime_advance_bonus_paid Numeric(18,2)'
exec (@val)	

Set @val = ''
Set @val = 'Alter table  #Emp_All Add Deduction_mis_Amount Numeric(18,2)'
exec (@val)	

Set @val = ''
Set @val = 'Alter table  #Emp_All Add Income_Tax_on_Bonus Numeric(18,2)'
exec (@val)	

Set @val = ''
Set @val = 'Alter table  #Emp_All Add Total_Deduction Numeric(18,2)'
exec (@val)	

Set @val = ''
Set @val = 'Alter table  #Emp_All Add Net_Payable Numeric(18,2)'
exec (@val)	

--


		Declare @Emp_Id_Cur as Numeric
		Declare @For_Date as Datetime
		Declare @Count as numeric
		Declare @Dept_Name as varchar(100)
		Declare @Desig_Name as varchar(100)
		Declare @Branch_Name as varchar(150)
		Declare @Total_Present_Days Numeric(18,2)
		Declare @Total_Wages Numeric(18,2)
		Declare @Branch_Id_Cur as Numeric
		Declare @Max_Bonus_Salary_Amount as Numeric(18,2)
		Declare @Bonus_Generated_Count as Numeric
		Declare @Bonus_Percentage as Numeric(18,3)
		Declare @Legal_Bonus as Numeric(18,2)
		Declare @Ex_Gratia_Bonus as Numeric(18,2)
		Declare @Total_Legal_Bonus as Numeric(18,2)
		Declare @Total_Ex_Gratia_Bonus as Numeric(18,2)
		Declare @Total_Bonus_Amount as Numeric(18,2)
		Declare @Bonus_Calculated_Amount as Numeric(18,2)
		Declare @Bonus_Entitle_Limit as Numeric(18,2)
		Declare @Desig_Dis_No  as NUMERIC(18,0)   --added jimit 28/09/2015
				
		Declare @Ex_Gratia_Calculated_Amount as Numeric(18,2)
		Declare @Ex_Gratia_Bonus_Amount as Numeric(18,2)
		declare @segment as varchar(500)
		
		
			
		Declare @Punja_other_cust_bonus_paid as Numeric(18,2)
		Declare @Intrime_advance_bonus_paid as Numeric(18,2)
		Declare @Deduction_mis_Amount as Numeric(18,2)
		Declare @Income_Tax_on_Bonus as Numeric(18,2)
		
		Declare @Net_Payable  as Numeric(18,2)
	
		
		Set @Ex_Gratia_Calculated_Amount = 0
		Set @Ex_Gratia_Bonus_Amount = 0

		
		Set @Count = 1

       Insert Into #Emp_All (Emp_ID)
		Select Emp_ID From  @Emp_Cons
		
		Declare curEmp cursor for                    
			Select Emp_Id From @Emp_Cons
		open curEmp                      
		fetch next from curEmp into @Emp_Id_Cur 
		while @@fetch_status = 0                    
		begin                    
           
		Set @Ex_Gratia_Calculated_Amount = 0
		Set @Ex_Gratia_Bonus_Amount = 0
		
			Set @Dept_Name = ''
			Set @Desig_Name = ''
			Set @val = ''
			Set @valBW =''
			set @segment =''
			
			
			-- Changed By Ali 22112013 EmpName_Alias
			Update #Emp_All Set Emp_Code = E.Alpha_Emp_Code
				, Emp_Full_Name = ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name), 
				Emp_Father_Name = E.Father_name
				,Enroll_No = E.Enroll_No  --added jimit 28/09/2015
				,left_date = convert(varchar(15),E.emp_left_date,103)
			From dbo.T0080_EMP_MASTER E Inner Join #Emp_All EM on E.Emp_ID = EM.Emp_ID
			
			Set @Max_Bonus_Salary_Amount = 0
			

			Set @Branch_Id_Cur = 0
			
			Select @Dept_Name = Dept_Name, @Desig_Name = Desig_Name,@Branch_Name = Branch_Name,
				@Branch_Id_Cur = I.Branch_ID
				,@Desig_Dis_No = DG.Desig_Dis_No  --added jimit 28/09/2015
				,@segment = BS.segment_name
			FROM dbo.T0095_Increment I WITH (NOLOCK) inner join       
				 (SELECT max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)		-- Ankit 11092014 for Same Date Increment
				  WHERE  Increment_Effective_date <= @To_Date      
				  AND Cmp_ID = @Cmp_ID      
				  GROUP BY emp_ID) Qry on      
				 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID      
				 Left Outer Join dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = I.Dept_ID
				 Left Outer Join dbo.T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = I.Desig_Id
				 Inner Join dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID = I.Branch_ID
				 left join T0040_Business_Segment BS WITH (NOLOCK) on I.segment_id = BS.segment_id
			WHERE I.Emp_ID = @Emp_Id_Cur

			Update #Emp_All Set Department = @Dept_Name, Designation = @Desig_Name, Branch = @Branch_Name,Desig_dis_No = @Desig_Dis_No
			,Segment_Name =@segment
			Where Emp_ID = @Emp_Id_Cur

			Select @Max_Bonus_Salary_Amount = Isnull(Max_Bonus_Salary_Amount,0), @Bonus_Entitle_Limit = ISNULL(Bonus_Entitle_Limit,0)
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    And Branch_ID = @Branch_Id_Cur
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Cmp_ID = @Cmp_ID And Branch_ID = @Branch_Id_Cur)    


			Set @Total_Legal_Bonus = 0
			Set @Total_Ex_Gratia_Bonus = 0
			Set @Legal_Bonus = 0
			Set @Ex_Gratia_Bonus = 0  
			Set @Bonus_Calculated_Amount = 0
	
			Set @Temp_For_Date = @From_Date
			While @Temp_For_Date <= @To_Date
				Begin
					Set @Legal_Bonus = 0
					Set @Ex_Gratia_Bonus = 0                    
					Set @Bonus_Calculated_Amount = 0
					
					Set @MonthName = ''
					Set @MonthName =Cast(Upper(Left(DATENAME(MONTH,@Temp_For_Date),3)) as varchar(4)) + '_' + Cast(YEAR(@Temp_For_Date) as varchar(50)) +'_'+ 'NO_OF_DAYS'
					
					Set @val = '' 
					Set @val = 'Update #Emp_All Set ' + @MonthName + ' = BD.Present_Days
								From #Emp_All E inner join 								
										dbo.T0180_BONUS B   on E.Emp_ID = B.Emp_ID  								
										Inner Join T0190_BONUS_DETAIL BD
								
								On B.Bonus_ID = BD.Bonus_ID
								Where BD.Month_Date = ''' + cast(@Temp_For_Date as varchar(20)) + ''' And E.Emp_Id = ' + Cast(@Emp_Id_Cur as varchar(10)) 
					exec (@val)
				
					Set @Basicwages = ''
					Set @Basicwages =Cast(Upper(Left(DATENAME(MONTH,@Temp_For_Date),3)) as varchar(4)) + '_' + Cast(YEAR(@Temp_For_Date) as varchar(50)) + '_'+ 'BASIC_WAGES'
					
					Set @valBW = '' 
					Set @valBW = 'Update #Emp_All Set ' + @Basicwages + ' = BD.Bonus_Calculated_Amount
								From #Emp_All E inner join 								
										dbo.T0180_BONUS B   on E.Emp_ID = B.Emp_ID  								
										Inner Join T0190_BONUS_DETAIL BD
								
								On B.Bonus_ID = BD.Bonus_ID
								Where BD.Month_Date = ''' + cast(@Temp_For_Date as varchar(20)) + ''' And E.Emp_Id = ' + Cast(@Emp_Id_Cur as varchar(10)) 
					exec (@valBW)
				
					Set @Basicwages = ''
					Set @Basicwages =Cast(Upper(Left(DATENAME(MONTH,@Temp_For_Date),3)) as varchar(4)) + '_' + Cast(YEAR(@Temp_For_Date) as varchar(50)) + '_'+ 'Ex_Gratia_WAGES'
					
					Set @valBW = '' 
					Set @valBW = 'Update #Emp_All Set ' + @Basicwages + ' = BD.Monthly_Ex_Gratia_Calculated_Amt
								From #Emp_All E inner join 								
										dbo.T0180_BONUS B   on E.Emp_ID = B.Emp_ID  								
										Inner Join T0190_BONUS_DETAIL BD
								
								On B.Bonus_ID = BD.Bonus_ID
								Where BD.Month_Date = ''' + cast(@Temp_For_Date as varchar(20)) + ''' And E.Emp_Id = ' + Cast(@Emp_Id_Cur as varchar(10)) 
					exec (@valBW)

					--Select @Bonus_Calculated_Amount = Isnull(BD.Bonus_Calculated_Amount,0),
					--	@Bonus_Percentage = Isnull(Bonus_Percentage,0)
					--From dbo.T0180_BONUS B
					--Inner Join T0190_BONUS_DETAIL BD
					--On B.Bonus_ID = BD.Bonus_ID
					--Where BD.Month_Date = @Temp_For_Date And Emp_Id = @Emp_Id_Cur
					
					--If @Max_Bonus_Salary_Amount <= @Bonus_Calculated_Amount And @Bonus_Percentage > 0 And @Max_Bonus_Salary_Amount > 0
					--	Begin
					--		Set @Legal_Bonus = Round((@Max_Bonus_Salary_Amount * @Bonus_Percentage)/100,0)
					--		Set @Total_Legal_Bonus = @Total_Legal_Bonus + @Legal_Bonus
							
					--		Set @Ex_Gratia_Bonus = Round((@Bonus_Calculated_Amount - @Max_Bonus_Salary_Amount) * @Bonus_Percentage/100,0)
					--		Set @Total_Ex_Gratia_Bonus = @Total_Ex_Gratia_Bonus + @Ex_Gratia_Bonus
					--	End
					--Else
					--	Begin
					--		Set @Legal_Bonus = Round((@Bonus_Calculated_Amount * @Bonus_Percentage)/100,0)
					--		Set @Total_Legal_Bonus = @Total_Legal_Bonus + @Legal_Bonus
					--	End
				
				
					Set @Temp_For_Date = DATEADD(M,1,@Temp_For_Date)
				End                    


					Set @Total_Present_Days = 0
					Set @Total_Wages = 0
					Set @Total_Bonus_Amount = 0
					
					set @Bonus_Percentage = 0 -- Added by rohit on 09082016
					
					set @Punja_other_cust_bonus_paid = 0
					set @Intrime_advance_bonus_paid = 0
					set @Deduction_mis_Amount = 0
					set @Income_Tax_on_Bonus = 0
					
					set @Net_Payable = 0
				
					
					Select @Total_Wages = SUM(Isnull(B.Bonus_Calculated_Amount,0)),
						@Total_Bonus_Amount = SUM(B.Bonus_Amount),
							@Ex_Gratia_Calculated_Amount = Sum(Isnull(B.Ex_Gratia_Calculated_Amount,0)),
						@Ex_Gratia_Bonus_Amount = Sum(Isnull(B.Ex_Gratia_Bonus_Amount,0))
						,@Bonus_Percentage = Bonus_Percentage   -- Added by rohit on 09082016
							,@Punja_other_cust_bonus_paid =  isnull(Sum(B.Punja_other_cust_bonus_paid),0)
						,@Intrime_advance_bonus_paid =  isnull(Sum(B.Intrime_advance_bonus_paid),0)
						,@Deduction_mis_Amount =  isnull(Sum(B.Deduction_mis_Amount),0)
						,@Income_Tax_on_Bonus =  isnull(Sum(B.Income_Tax_on_Bonus),0)
						,@Net_Payable =  isnull(Sum(B.Net_Payable_Bonus),0)
						
					From dbo.T0180_BONUS B WITH (NOLOCK)
					Where From_Date >= @From_Date And To_Date <= @To_Date And Emp_Id = @Emp_Id_Cur
					Group by Bonus_Percentage
					
					Select @Total_Present_Days = Sum(Isnull(Present_days,0)) 
					From dbo.T0180_BONUS B WITH (NOLOCK)
					Inner Join T0190_BONUS_DETAIL BD WITH (NOLOCK)
					On B.Bonus_ID = BD.Bonus_ID
					Where From_Date >= @From_Date And To_Date <= @To_Date And Emp_Id = @Emp_Id_Cur
					Group by Bonus_Percentage
					
					Update #Emp_All Set TOTAL_PRESENT_DAYS = Isnull(@Total_Present_Days,0),
					 Total_Wages = Isnull(@Total_Wages,0),
					 	--Total_Wages = case when isnull(@Total_Present_Days,0) < 30 then 0 else @Total_Wages end,
						Total_Ex_Gratia_Wages = @Ex_Gratia_Calculated_Amount
						--Total_Ex_Gratia_Wages = case when isnull(@Total_Present_Days,0) < 30 then 0 else @Ex_Gratia_Calculated_Amount end
						--, Ex_Gratia_Bonus = @Ex_Gratia_Bonus_Amount,
						, Ex_Gratia_Bonus = case when isnull(@Total_Present_Days,0) < 30 then 0 else @Ex_Gratia_Bonus_Amount end,
						--Legal_Bonus=@Total_Bonus_Amount
						Legal_Bonus = case when isnull(@Total_Present_Days,0) < 30 then 0 else @Total_Bonus_Amount end
						,Bonus_Percentage =@Bonus_Percentage   -- Added by rohit on 09082016
							,Punja_other_cust_bonus_paid = @Punja_other_cust_bonus_paid 
						,Intrime_advance_bonus_paid = @Intrime_advance_bonus_paid 
						,Deduction_mis_Amount = @Deduction_mis_Amount 
						,Income_Tax_on_Bonus = @Income_Tax_on_Bonus 
						,Total_Deduction = @Punja_other_cust_bonus_paid + @Intrime_advance_bonus_paid + @Deduction_mis_Amount + @Income_Tax_on_Bonus
						,Net_Payable = case when isnull(@Total_Present_Days,0) < 30 then 0 else @Net_Payable end
					Where Emp_Id = @Emp_Id_Cur


					--If Isnull(@Max_Bonus_Salary_Amount,0) > 0 And ISNULL(@Bonus_Percentage,0) > 0
					--	Begin
					--		Set @Legal_Bonus = Round((@Max_Bonus_Salary_Amount * @Bonus_Percentage) /100,0) * @Bonus_Generated_Count
					--		--Set @Ex_Gratia_Bonus = ((Isnull(@Total_Wages,0) - Isnull(@Max_Bonus_Salary_Amount * @Bonus_Generated_Count,0)) * @Bonus_Percentage)/100
					--		If @Total_Bonus_Amount >= @Legal_Bonus
					--			Set @Ex_Gratia_Bonus = @Total_Bonus_Amount - @Legal_Bonus

							--Update #Emp_All Set Legal_Bonus= Isnull(@Total_Legal_Bonus,0), Ex_Gratia_Bonus = Isnull(@Total_Ex_Gratia_Bonus,0)
							--Where Emp_Id = @Emp_Id_Cur
					--	End
					--Else
					--	Begin
					--		Set @Legal_Bonus = @Total_Bonus_Amount

					--		Update #Emp_All Set Legal_Bonus= Isnull(@Legal_Bonus,0), Ex_Gratia = 0
					--		Where Emp_Id = @Emp_Id_Cur
					--	End
														


			fetch next from curEmp into @Emp_Id_Cur
	    end                    
		close curEmp                    
		deallocate curEmp 
		Update #Emp_All set Emp_Code = '="' + Emp_Code + '"'  -- Added By Gadriwala Muslim 03052014
		--Select DISTINCT * from #Emp_All --order by sr_no Asc
		
		
		--added jimit 28/09/2015-------
		--Commented by Nimesh on 19-Jun-2017 (Order_By & Order_By1 column is not needed in customize Report)
		--Select DISTINCT *,(CASE WHEN  @Order_By = 'Enroll_No' THEN #Emp_All.Enroll_No  
		--					WHEN @Order_By = 'Name' THEN #Emp_All.Emp_Full_Name 
		--					When @Order_By = 'Designation' then (CASE WHEN #Emp_All.Desig_dis_No  = 0 THEN #Emp_All.Designation ELSE RIGHT(REPLICATE('0',21) + CAST(#Emp_All.Desig_dis_No AS VARCHAR), 21)   END) 
		--					--ELSE RIGHT(REPLICATE(N' ', 500) + #Emp_All.Emp_Code, 500) 
		--				End) as Order_By,(Case When IsNumeric(Replace(Replace(#Emp_All.Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(#Emp_All.Emp_Code,'="',''),'"',''), 20)
		--						 When IsNumeric(Replace(Replace(#Emp_All.Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(#Emp_All.Emp_Code,'="',''),'"','') + Replicate('',21), 20)
		--						 Else Replace(Replace(#Emp_All.Emp_Code,'="',''),'"','') End ) as Order_By1
		--				 from #Emp_All ORDER BY Order_By,Order_By1						 
		--				 --RIGHT(REPLICATE(N' ', 500) + #Emp_All.Emp_Code, 500) 
		------------------------------------		
		SELECT	*
		FROM	#EMP_ALL 
		ORDER BY 
				(CASE WHEN  @Order_By = 'Enroll_No' THEN #Emp_All.Enroll_No  
									WHEN @Order_By = 'Name' THEN #Emp_All.Emp_Full_Name 
									When @Order_By = 'Designation' then (CASE WHEN #Emp_All.Desig_dis_No  = 0 THEN #Emp_All.Designation ELSE RIGHT(REPLICATE('0',21) + CAST(#Emp_All.Desig_dis_No AS VARCHAR), 21)   END) 							
								End),
				(Case When IsNumeric(Replace(Replace(#Emp_All.Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(#Emp_All.Emp_Code,'="',''),'"',''), 20)
							When IsNumeric(Replace(Replace(#Emp_All.Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(#Emp_All.Emp_Code,'="',''),'"','') + Replicate('',21), 20)
							Else Replace(Replace(#Emp_All.Emp_Code,'="',''),'"','') End ) 
	RETURN



