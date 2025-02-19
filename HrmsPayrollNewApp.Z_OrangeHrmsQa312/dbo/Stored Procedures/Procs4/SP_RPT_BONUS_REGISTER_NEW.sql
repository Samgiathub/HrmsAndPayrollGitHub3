---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_BONUS_REGISTER_NEW]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 	
	,@Branch_ID		varchar(max)  
	,@Cat_ID		varchar(max)  
	,@Grd_ID		varchar(max)  
	,@Type_ID		varchar(max)  
	,@Dept_ID		varchar(max)  
	,@Desig_ID		varchar(max) 
	,@Emp_ID		numeric 
	,@Constraint		varchar(MAX) = ''
	,@Report_Type tinyint=0
	,@Order_By   varchar(30) = 'Code' --Added by Jimit 28/09/2015 (To sort by Code/Name/Enroll No)

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 

	Declare @Dumy_From_date datetime
	Declare @Dumy_To_date datetime
	declare @While_date datetime
	

	CREATE TABLE #Emp_Cons	-- Ankit 10092014 for Same Date Increment
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)   
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0


	IF @Report_Type = 1
		BEGIN
			-- Changed By Ali 22112013 EmpName_Alias
			Select E.Emp_ID ,E.Alpha_Emp_Code,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) as Emp_Full_Name 
			,Comp_Name,Branch_Address
			, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,  Q_I.Branch_id,Q_I.Dept_Id,Q_I.Grd_Id,Q_I.Desig_Id, Q_I.Type_id
			, Q_I.Cat_ID -- Added By Sajid 06102021			
			,E.Date_Of_Join -- Added By Sajid 06102021
			,E.Emp_Left_Date -- Added By Sajid 06102021
			,Q_I.Inc_Bank_AC_No -- Added By Sajid 06102021
			,Type_Name
			,Category -- Added By Sajid 06102021
			,E.Ifsc_Code -- Added By Sajid 06102021
			,CMP_NAME,CMP_ADDRESS
			,@From_Date as P_From_date ,@To_Date as P_To_Date	
			,E.Vertical_ID,E.SubVertical_ID   --Added By Jaina 7-10-2015
			From #Emp_Cons EC 
					INNER JOIN  dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID =E.EMP_ID  INNER JOIN 
			( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Type_ID,I.Emp_ID,I.Cat_ID,I.Inc_Bank_AC_No FROM dbo.T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
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
			Left outer join dbo.T0030_CATEGORY_MASTER CTM WITH (NOLOCK) ON Q_I.Cat_ID = CTM.Cat_ID -- Added By Sajid 06102021
			 Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20) -- Added By Mukti 07112014
						When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
						Else e.Alpha_Emp_Code
						End
			return 
		END

			
		IF OBJECT_ID('tempdb..#Emp_All') is null
			CREATE TABLE #Emp_All 
			(
				Sr_No Numeric default 0,
				Emp_Code  Varchar(100),
				Emp_Full_Name  varchar(200),
				Emp_Father_Name  Varchar(150),
				Branch Varchar(150),
				Designation  Varchar(100),
				Department  Varchar(100),
				Category  Varchar(100), -- Added By Sajid 06102021
				Joining_Date  Varchar(100), -- Added By Sajid 06102021
				Left_Date  Varchar(100), -- Added By Sajid 06102021
				Bank_Acc_No  Varchar(100), -- Added By Sajid 06102021
				IFSC_Code  Varchar(100), -- Added By Sajid 06102021
				Column_Name Varchar(100),
				Emp_ID	numeric,
				Desig_dis_No    numeric(18,0) DEFAULT 0,   --added jimit 28/09/2015
				Enroll_No       VARCHAR(50)	DEFAULT '',		 --added jimit 28/09/2015 
				Sort_Index	Int
			)	


		CREATE TABLE #Field 
		(
			Name varchar(100),
			Sort_Index	INT
		)	


		Insert Into #Field
		--Select 'Gross Salary'
		SELECT 'Earned Bonus Salary',1
		
		Insert Into #Field
		Select 'Earned Gross Salary',2
		
		Insert Into #Field
		Select 'Total Month Days',3
		
		Insert Into #Field
		Select 'Total Present Days',4

		Insert Into #Field
		Select 'Bonus Applicable Salary',5

		Insert Into #Field
		Select 'Bonus Amount',6

		Declare @Temp_For_Date as Datetime
		Set @Temp_For_Date = @From_Date
		Declare @val as Varchar(8000)
		Declare @MonthName as varchar(50)

	
		While @Temp_For_Date <= @To_Date
			Begin
				Set @MonthName = ''

				Set @MonthName = Cast(Upper(Left(DATENAME(MONTH,@Temp_For_Date),3)) as varchar(4)) + '_' + Cast(YEAR(@Temp_For_Date) as varchar(50))

				Set @val = 'Alter table  #Emp_All Add ' + @MonthName + ' varchar(50)'
				exec (@val)	
				   
				Set @Temp_For_Date = DATEADD(M,1,@Temp_For_Date)
			End

			Set @val = 'Alter table  #Emp_All Add Total Numeric(18,2) default 0'
			exec (@val)	

--		Insert Into #Emp_All (Emp_ID,Column_Name)
--		Select Emp_Id,Name From #Emp_Cons Cross Join #Field 

			 
		--Declare @Emp_Id_Cur as Numeric

		Declare @For_Date as Datetime
		--Declare @Increment_Id as Numeric
		--Declare @Wages_Type as Varchar(15)
		--Declare @Effect_Allow_Amount as Numeric(18,2)
		--Declare @Basic_Salary as Numeric(18,2)
		--Declare @Dept_Name as varchar(100)
		--Declare @Desig_Name as varchar(100)
		--Declare @Branch_Name as varchar(150)
		--Declare @Count as numeric
  --      Declare @Effect_Allow_Amount_earning as Numeric(18,2)
  --      Declare @Basic_Salary_earning as Numeric(18,2)
  --      Declare @Other_Allow_Amount as Numeric(18,2)
		--Declare @Desig_Dis_No  as NUMERIC(18,0)   --added jimit 28/09/2015
		--DECLARE @Gross_Salary AS NUMERIC(18,2)
		--Declare @Settlement_Basic Numeric(18,2) --Hardik 08/02/2018
		
		--Set @Count = 1
		
		
		CREATE TABLE #BONUS
		(
			Emp_ID				Numeric,
			Increment_ID		Numeric(18,2),
			Basic_Salary		Numeric(18,2),
			Settlement_Basic	Numeric(18,2),
			Other_Allow_Amount	Numeric(18,2),
			Basic_Salary_earning	Numeric(18,2),
			Gross_Salary		Numeric(18,2),
			Effect_Allow_Amount Numeric(18,2),
			Effect_Allow_Amount_Earning Numeric(18,2)
		)
		
		
		--Declare curEmp cursor for                    
		--	--Select Distinct Emp_ID from #Emp_All
		--	Select  Emp_Id From #Emp_Cons
		--open curEmp                      
		--fetch next from curEmp into @Emp_Id_Cur 
		--while @@fetch_status = 0                    
		--begin                    
           
		Insert Into #Emp_All (Emp_ID,Column_Name,Sort_Index)
		Select EMP_ID,Name,Sort_Index From  #Field f CROSS JOIN #Emp_Cons EC
					
		UPDATE	EA 
		SET		Emp_Code = E.Alpha_Emp_Code,
				Emp_Full_Name = e.Emp_Full_Name, 
				Emp_Father_Name = E.Father_name, 
				Sr_No = ROW_ID,
				Enroll_No = E.Enroll_No --added jimit 28/09/2015
				,Joining_Date = E.Date_Of_Join -- Added By Sajid 06102021
				,Left_Date = E.Emp_Left_Date -- Added By Sajid 06102021
				,IFSC_Code = E.Ifsc_Code -- Added By Sajid 06102021
		From	#Emp_All EA 
				INNER JOIN (SELECT EMP_ID,Alpha_Emp_Code,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) Emp_Full_Name, Father_name,Enroll_No
				,REPLACE(CONVERT(VARCHAR,Date_Of_Join,106),' ','-') AS Date_Of_Join  -- Added By Sajid 06102021
				,REPLACE(CONVERT(VARCHAR,Emp_Left_Date,106),' ','-') AS Emp_Left_Date  -- Added By Sajid 06102021
				,E.Ifsc_Code  -- Added By Sajid 06102021
				, ROW_NUMBER() OVER(ORDER BY Alpha_Emp_Code) AS ROW_ID
							FROM	dbo.T0080_EMP_MASTER E WITH (NOLOCK))E on E.Emp_ID = EA.Emp_ID		
				
		INSERT INTO #BONUS(Emp_ID)
		SELECT Emp_ID FROM #Emp_Cons
		
		

		--Set @Basic_Salary = 0
		--Set @Effect_Allow_Amount = 0
		--Set @Increment_Id = 0
		--Set @Wages_Type = ''
		--Set @Dept_Name = ''
		--Set @Desig_Name = ''
		--Set @val = ''
  --      Set @Effect_Allow_Amount_earning = 0
  --      Set @Basic_Salary_earning = 0 
		--Set @Other_Allow_Amount = 0
		--set @Gross_Salary = 0
		--Set @Settlement_Basic=0
				
			

		SET @Temp_For_Date = @From_Date
		
		WHILE @Temp_For_Date <= @To_Date
			BEGIN            
				Set @MonthName = Cast(Upper(Left(DATENAME(MONTH,@Temp_For_Date),3)) as varchar(4)) + '_' + Cast(YEAR(@Temp_For_Date) as varchar(50))
				
				UPDATE	B
				SET		Increment_ID = I1.Increment_ID
				FROM	#BONUS B
						INNER JOIN (SELECT	MAX(I1.Increment_ID) As Increment_ID, I1.Emp_ID
									FROM	T0095_INCREMENT I1 WITH (NOLOCK)
											INNER JOIN (SELECT	MAX(I2.Increment_Effective_Date) As Increment_Effective_Date, I2.Emp_ID
														FROM	T0095_INCREMENT I2 WITH (NOLOCK)
																INNER JOIN #Emp_Cons EC On I2.Emp_ID = EC.Emp_ID
														WHERE	I2.Increment_Effective_Date <= DATEADD(D, -1, DATEADD(MM,1,@Temp_For_Date)) 
														GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID = I2.Emp_ID And I1.Increment_Effective_Date = I2.Increment_Effective_Date
									GROUP BY I1.EMP_ID) I1 ON B.EMP_Id=I1.EMP_ID
									
				--Select @Increment_Id = I.Increment_ID, @Wages_Type = Wages_Type,@Dept_Name = Dept_Name, @Desig_Name = Desig_Name,
				--		@Branch_Name = Branch_Name, @Basic_Salary = Basic_Salary
				--		,@Desig_Dis_No = DG.Desig_Dis_No  --added jimit 28/09/2015
				--FROM dbo.T0095_Increment I inner join       
				--	 (SELECT max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment  -- Ankit 10092014 for Same Date Increment    
				--	  WHERE  Increment_Effective_date <= @Temp_For_Date      
				--	  AND Cmp_ID = @Cmp_ID      
				--	  GROUP BY emp_ID) Qry on      
				--	 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID      
				--	 Left Outer Join dbo.T0040_DEPARTMENT_MASTER DM on DM.Dept_Id = I.Dept_ID
				--	 Left Outer Join dbo.T0040_DESIGNATION_MASTER DG on DG.Desig_ID = I.Desig_Id
				--	 Inner Join dbo.T0030_BRANCH_MASTER BM on BM.Branch_ID = I.Branch_ID
				--WHERE I.Emp_ID = @Emp_Id_Cur
				
				UPDATE	B
				SET		Settlement_Basic = IsNull(S_Salary_Amount,0)
				FROM	#BONUS B
						LEFT OUTER JOIN (SELECT	MS.EMP_ID, ISNULL(SUM(S_Salary_Amount),0) AS S_Salary_Amount
										 FROM	T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
												INNER JOIN #EMP_CONS EC ON MS.EMP_ID=EC.EMP_ID
										 WHERE	Month(S_Eff_Date)=Month(@Temp_For_Date) and Year(S_Eff_Date)= Year(@Temp_For_Date)
										 GROUP BY MS.EMP_ID) T ON B.EMP_ID=T.EMP_ID
						
						
					--Added by Hardik 08/02/2018 for AIA
					--select @Settlement_Basic = Isnull(Sum(S_Salary_Amount),0)
					--from T0201_MONTHLY_SALARY_SETT 
					--where emp_id=@Emp_Id_Cur and Month(S_Eff_Date)=Month(@Temp_For_Date) and Year(S_Eff_Date)= Year(@Temp_For_Date)
					
				UPDATE	B
				SET		Basic_Salary =			IsNull(CASE WHEN WAGES_TYPE = 'Monthly' Then T.Basic_Salary ELSE I.Basic_Salary END,0),
						Other_Allow_Amount =	IsNull(T.Other_Allow_Amount,0),
						Basic_Salary_earning =	IsNull(T.Basic_Salary_earning,0) + IsNull(B.Settlement_Basic,0),
						Gross_Salary =			IsNull(T.Gross_Salary,0)
				FROM	#BONUS B
						LEFT OUTER JOIN (SELECT	MS.EMP_ID, ISNULL(SUM(BASIC_SALARY),0) AS basic_salary,isnull(sum(Other_Allow_Amount),0) Other_Allow_Amount, 
												isnull(sum(salary_amount),0) + isnull(sum(Arear_Basic),0)  Basic_Salary_earning,
												ISNULL(sum(Gross_Salary),0) Gross_Salary
										 FROM	dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK)
												INNER JOIN  #EMP_CONS EC ON MS.EMP_ID=EC.EMP_ID
										 WHERE	MONTH(month_end_date) = MONTH(@Temp_For_Date) and Year(month_end_date) = Year(@Temp_For_Date)
										 GROUP BY MS.EMP_ID) T ON B.EMP_ID=T.EMP_ID
						INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON B.INCREMENT_ID=I.INCREMENT_ID	 

					
					--Select @Basic_Salary = Case When @wages_Type = 'Monthly' Then  isnull(sum(basic_salary),0) Else @Basic_Salary End ,
     --                  @Other_Allow_Amount =isnull(sum(Other_Allow_Amount),0) , 
     --                  @Basic_Salary_earning = isnull(sum(salary_amount),0) + isnull(sum(Arear_Basic),0) + Isnull(@Settlement_Basic,0) ,
     --                  @Gross_Salary = ISNULL(sum(Gross_Salary),0)
					--from dbo.T0200_MONTHLY_SALARY 
					--where cmp_id=@Cmp_ID and emp_id=@Emp_Id_Cur 
					--and Month(month_end_date) = Month(@Temp_For_Date) and Year(month_end_date) = Year(@Temp_For_Date)
					
				UPDATE	B
				SET		Effect_Allow_Amount =  IsNull(T.Effect_Allow_Amount,0)
				FROM	#BONUS B
						LEFT OUTER JOIN (SELECT	EED.EMP_ID, Isnull(Sum(E_AD_AMOUNT),0) Effect_Allow_Amount
										 From	dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
												INNER JOIN dbo.T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID 
												INNER JOIN #BONUS B1 ON EED.EMP_ID=B1.EMP_ID AND EED.Increment_ID=B1.Increment_ID
										 Where	AD_EFFECT_ON_BONUS = 1 											
										 GROUP BY EED.EMP_ID) T ON B.EMP_ID=T.EMP_ID						
				
					--Select @Effect_Allow_Amount = Isnull(Sum(E_AD_AMOUNT),0) 
					--From dbo.T0100_EMP_EARN_DEDUCTION EED Inner Join
					--	dbo.T0050_AD_MASTER AM on EED.AD_ID = AM.AD_ID 
					--Where AD_EFFECT_ON_BONUS = 1 And EED.Cmp_ID=@Cmp_ID and Emp_id= @Emp_Id_Cur 
					--	And INCREMENT_ID = @Increment_Id
				
				UPDATE	B
				SET		Effect_Allow_Amount_Earning =  IsNull(T.Effect_Allow_Amount_Earning,0)
				FROM	#BONUS B
						LEFT OUTER JOIN (SELECT	MAD.EMP_ID, Isnull(Sum(M_AD_AMOUNT),0) + Isnull(Sum(M_AREAR_AMOUNT ),0)   Effect_Allow_Amount_Earning
										 From	dbo.T0210_Monthly_ad_detail MAD WITH (NOLOCK)
												INNER JOIN dbo.T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = AM.AD_ID 
												INNER JOIN #BONUS B1 ON MAD.EMP_ID=B1.EMP_ID
										 Where	AD_EFFECT_ON_BONUS = 1	
												And Month(For_date) = Month(@Temp_For_Date) and Year(For_date) = Year(@Temp_For_Date)
										 GROUP BY MAD.EMP_ID) T ON B.EMP_ID=T.EMP_ID						
				

     --               Select @Effect_Allow_Amount_earning = Isnull(Sum(M_AD_AMOUNT),0) + Isnull(Sum(M_AREAR_AMOUNT ),0)  
					--From dbo.T0210_Monthly_ad_detail MAD Inner Join
					--	dbo.T0050_AD_MASTER AM on MAD.AD_ID = AM.AD_ID 
					--Where AD_EFFECT_ON_BONUS = 1 And MAD.Cmp_ID=@Cmp_ID and Emp_id= @Emp_Id_Cur 
					--	And Month(For_date) = Month(@Temp_For_Date) and Year(For_date) = Year(@Temp_For_Date)


					
					Set @val = 'UPDATE	EA
								SET		' + @MonthName + ' = Basic_Salary_Earning + Effect_Allow_Amount_earning,
										Total += Basic_Salary_earning + Effect_Allow_Amount_earning
								FROM	#Emp_All EA 
										INNER JOIN #BONUS B ON EA.EMP_ID=B.EMP_ID
										INNER JOIN T0095_INCREMENT I ON B.Increment_ID=I.Increment_ID 
								WHERE	Column_Name = ''Earned Bonus Salary'' AND I.Wages_Type = ''Monthly'' '
					
					exec (@val)
					
					
					Set @val = 'UPDATE	EA
								SET		' + @MonthName + ' = Basic_Salary_Earning + Effect_Allow_Amount_earning,
										Total += Basic_Salary_earning + Effect_Allow_Amount_earning
								FROM	#Emp_All EA 
										INNER JOIN #BONUS B ON EA.EMP_ID=B.EMP_ID
										INNER JOIN T0095_INCREMENT I ON B.Increment_ID=I.Increment_ID 
										INNER JOIN dbo.T0180_BONUS B1 ON EA.Emp_ID = B1.Emp_ID  	
										INNER JOIN dbo.T0190_BONUS_DETAIL BD ON B1.Bonus_ID = BD.Bonus_ID
								WHERE	Column_Name = ''Earned Bonus Salary'' AND I.Wages_Type <> ''Monthly'' 
										AND Month(BD.Month_Date) = ''' + cast(Month(@Temp_For_Date) as varchar(20)) + ''' 
										AND Year(BD.Month_Date) = ''' + cast(Year(@Temp_For_Date) as varchar(20)) + ''''
					
					exec (@val)
					
					
					------Ankit For Earn Bonus Calculated Amount	--17122015
					--If @Wages_Type= 'Monthly'
     --                    Begin
     --     					Set @val = 'Update #Emp_All Set ' + @MonthName + ' = ' + Cast(@Basic_Salary_earning + @Effect_Allow_Amount_earning as varchar(100)) + ' , Total += ' +  Cast(@Basic_Salary_earning + @Effect_Allow_Amount_earning as varchar(100)) 
		   --  				+ ' Where Column_Name = ''Earned Bonus Salary'' And Emp_ID = ' + Cast(@Emp_Id_Cur as varchar(10))
     --                    End
     --               Else
     --                    Begin
					--		Set @val = 'Update #Emp_All Set ' + @MonthName + ' = ' + Cast(@Basic_Salary_earning  + @Other_Allow_Amount + @Effect_Allow_Amount_earning as varchar(40)) + ' , Total += ' + Cast(@Basic_Salary_earning  + @Other_Allow_Amount + @Effect_Allow_Amount_earning as varchar(40)) 
					--		+ ' From #Emp_All E inner join 								
					--				dbo.T0180_BONUS B   on E.Emp_ID = B.Emp_ID  								
					--				Inner Join T0190_BONUS_DETAIL BD
							
					--		On B.Bonus_ID = BD.Bonus_ID
					--		Where Column_Name = ''Earned Bonus Salary'' And Month(BD.Month_Date) = ''' + cast(Month(@Temp_For_Date) as varchar(20)) + ''' 
					--		And Year(BD.Month_Date) = ''' + cast(Year(@Temp_For_Date) as varchar(20)) + '''
					--		And E.Emp_Id = ' + Cast(@Emp_Id_Cur as varchar(10)) 
					--		exec (@val)
					
					
     --                    End
					--exec (@val)

					

					Set @val = 'Update #Emp_All Set ' + @MonthName + ' = BD.Bonus_Calculated_Amount , Total += BD.Bonus_Calculated_Amount
								From #Emp_All E inner join 								
										dbo.T0180_BONUS B   on E.Emp_ID = B.Emp_ID  								
										Inner Join T0190_BONUS_DETAIL BD On B.Bonus_ID = BD.Bonus_ID
								Where Column_Name = ''Bonus Applicable Salary'' And Month(BD.Month_Date) = ''' + cast(Month(@Temp_For_Date) as varchar(20)) + ''' 
								And Year(BD.Month_Date) = ''' + cast(Year(@Temp_For_Date) as varchar(20)) + ''''

					exec (@val)

					Set @val = '' 
					
					Set @val = 'Update #Emp_All Set ' + @MonthName + ' = BD.Bonus_Amount , Total += BD.Bonus_Amount
							From #Emp_All E inner join 								
									dbo.T0180_BONUS B   on E.Emp_ID = B.Emp_ID  								
									Inner Join T0190_BONUS_DETAIL BD On B.Bonus_ID = BD.Bonus_ID
							Where Column_Name = ''Bonus Amount'' And Month(BD.Month_Date) = ''' + cast(Month(@Temp_For_Date) as varchar(20)) + ''' 
							And Year(BD.Month_Date) = ''' + cast(Year(@Temp_For_Date) as varchar(20)) + ''''

					exec (@val)

					Set @val = '' 
					
					
					Set @val = 'Update #Emp_All Set ' + @MonthName + ' = Gross_Salary , Total += Gross_Salary
								From #Emp_All E inner join 								
									dbo.T0180_BONUS B ON E.Emp_ID = B.Emp_ID  								
									Inner Join T0190_BONUS_DETAIL BD On B.Bonus_ID = BD.Bonus_ID
									INNER JOIN #BONUS B1 ON E.EMP_ID=B1.EMP_ID
								Where Column_Name = ''Earned Gross Salary'' And Month(BD.Month_Date) = ''' + cast(Month(@Temp_For_Date) as varchar(20)) + ''' 
								And Year(BD.Month_Date) = ''' + cast(Year(@Temp_For_Date) as varchar(20)) + ''''
							
					exec (@val)
					

					Set @val = '' 
					Set @val = 'Update #Emp_All Set ' + @MonthName + ' = BD.Present_Days , Total += BD.Present_Days
								From #Emp_All E inner join 								
										dbo.T0180_BONUS B   on E.Emp_ID = B.Emp_ID  								
										Inner Join T0190_BONUS_DETAIL BD On B.Bonus_ID = BD.Bonus_ID
								Where Column_Name = ''Total Present Days'' And Month(BD.Month_Date) = ''' + cast(Month(@Temp_For_Date) as varchar(20)) + ''' 
								And Year(BD.Month_Date) = ''' + cast(Year(@Temp_For_Date) as varchar(20)) + '''' 

					exec (@val)


					Set @val = ''  /* Total Updated QA Mantis ID :0004305 - Ankit 04082016 */
					Set @val = 'Update #Emp_All Set ' + @MonthName + ' = BD.Working_Days , Total += BD.Working_Days 
								From #Emp_All E inner join 								
										dbo.T0180_BONUS B   on E.Emp_ID = B.Emp_ID  								
										Inner Join T0190_BONUS_DETAIL BD On B.Bonus_ID = BD.Bonus_ID
								Where Column_Name = ''Total Month Days''  And Month(BD.Month_Date) = ''' + cast(Month(@Temp_For_Date) as varchar(20)) + ''' 
								And Year(BD.Month_Date) = ''' + cast(Year(@Temp_For_Date) as varchar(20)) + ''''
								
					exec (@val)
					
				
					Set @Temp_For_Date = DATEADD(M,1,@Temp_For_Date)
				End                    

					

				Update EA 
				Set		Department = D.Dept_Name, 
						Designation = DG.Desig_Name, 
						Branch = BM.Branch_Name,
						Desig_dis_No = DG.Desig_Dis_No,
						Category = CT.Cat_Name -- Added By Sajid 06102021
						--,Bank_Acc_No=I.Inc_Bank_AC_No -- Added By Sajid 06102021
						,Bank_Acc_No =  ( '="' + I.Inc_Bank_AC_No + '"')  -- Added By Sajid 06102021
				FROM	#Emp_All EA
						INNER JOIN #BONUS B ON EA.Emp_ID=B.Emp_ID
						INNER JOIN T0095_INCREMENT I ON B.Increment_ID=I.Increment_ID
						INNER JOIN T0040_DEPARTMENT_MASTER D ON I.Dept_ID = D.Dept_Id
						INNER JOIN T0030_BRANCH_MASTER BM ON I.Branch_ID=BM.Branch_ID
						LEFT OUTER JOIN T0040_DESIGNATION_MASTER DG ON I.Desig_Id = DG.Desig_ID
						LEFT OUTER JOIN T0030_CATEGORY_MASTER CT ON I.Cat_ID = CT.Cat_ID -- Added By Sajid 06102021
				--Where Emp_ID = @Emp_Id_Cur --And Column_Name = 'Gross Salary'

		--	fetch next from curEmp into @Emp_Id_Cur
	 --   end                    
		--close curEmp                    
		--deallocate curEmp 
		

		
		Update #Emp_All set Emp_Code = '="' + Emp_Code + '"' -- Added By Gadriwala 03052014
		
		
		Select  *, ROW_NUMBER() OVER(ORDER BY CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(#Emp_All.Enroll_No AS VARCHAR), 21)  
							WHEN @Order_By='Name' THEN #Emp_All.Emp_Full_Name 
							When @Order_By = 'Designation' then 
								(CASE	WHEN #Emp_All.Desig_dis_No  = 0 
											THEN #Emp_All.Designation 
										ELSE	RIGHT(REPLICATE('0',21) + CAST(#Emp_All.Desig_dis_No AS VARCHAR), 21)   
								END) 
							ELSE 
								Case	When IsNumeric(Replace(Replace(#Emp_All.Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(#Emp_All.Emp_Code,'="',''),'"',''), 20)
										When IsNumeric(Replace(Replace(#Emp_All.Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(#Emp_All.Emp_Code,'="',''),'"','') + Replicate('',21), 20)
										Else Replace(Replace(#Emp_All.Emp_Code,'="',''),'"','')
								END
						End, Sort_Index) AS Sort_ID
		into	#tmpBonus
		from	#Emp_All 
		
			
		Alter Table #tmpBonus DROP COLUMN Sort_Index			
		
		Update	#tmpBonus
		SET		Emp_Code = NULL, Emp_Full_Name = NULL, Emp_Father_Name = NULL, Branch = NULL, Department=NULL, Designation=NULL, Category=NULL, Joining_Date=NULL , Left_Date=NULL , Bank_Acc_No=NULL , IFSC_Code=NULL ,Sr_No=0 -- Added By Sajid 06102021
		Where	Column_Name <> 'Earned Bonus Salary'
		
		select * from #tmpBonus  Order By Sort_ID
	RETURN



--GO
--EXEC [SP_RPT_BONUS_REGISTER_NEW]
--	@Cmp_ID		= 2
--	,@From_Date		= '2017-04-01'
--	,@To_Date		= '2018-03-31' 	
--	,@Branch_ID		= ''
--	,@Cat_ID		= ''
--	,@Grd_ID		= ''
--	,@Type_ID		= ''
--	,@Dept_ID		= ''
--	,@Desig_ID		= ''
--	,@Emp_ID		= 0
--	,@Constraint	= ''
--	,@Report_Type	=0
--	,@Order_By   = 'Code' --A
	
	
	
