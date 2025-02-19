
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[RPT_BONUS_REGISTER_NEW]
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
	,@Order_By   varchar(30) = 'Code' 
	,@Bank_Id        numeric = 0  --Added By Jimit 14052019 as parameter is passing from page level so default value is set to 0 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	

	CREATE TABLE #Emp_Cons	
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0
	
		
		
		CREATE TABLE #Emp_Bonus_Register 
		(
			Sr_No			Numeric default 0,
			EMp_Id			NUMERIC,
			Emp_Code		Varchar(100),
			Emp_Full_Name   varchar(200),						
			Month_1			numeric(18,2) default 0,
			Month_2			numeric(18,2) default 0,
			Month_3			numeric(18,2) default 0,
			Month_4			numeric(18,2) default 0,
			Month_5			numeric(18,2) default 0,
			Month_6			numeric(18,2) default 0,
			Month_7			numeric(18,2) default 0,
			Month_8			numeric(18,2) default 0,
			Month_9			numeric(18,2) default 0,
			Month_10		numeric(18,2) default 0,
			Month_11		numeric(18,2) default 0,
			Month_12		numeric(18,2) default 0					 
		)	
		Create Clustered index IX_Emp_Bonus_register on #Emp_Bonus_Register (Emp_ID,Emp_Code,Emp_Full_Name,Month_1,Month_2,Month_3,Month_4,Month_5,Month_6,Month_7,Month_8,Month_9,Month_10,Month_11,Month_12)

		

		Declare @Temp_For_Date as Datetime
		Set @Temp_For_Date = @From_Date
		Declare @val as Varchar(8000)
		Declare @MonthName as varchar(50)	
		Declare @Emp_Id_Cur as Numeric
		Declare @For_Date as Datetime
		Declare @Increment_Id as Numeric
		Declare @Wages_Type as Varchar(15)
		Declare @Effect_Allow_Amount as Numeric(18,2)
		Declare @Basic_Salary as Numeric(18,2)
		Declare @Dept_Name as varchar(100)
		Declare @Desig_Name as varchar(100)
		Declare @Branch_Name as varchar(150)
		Declare @Count as numeric
        Declare @Effect_Allow_Amount_earning as Numeric(18,2)
        Declare @Basic_Salary_earning as Numeric(18,2)
        Declare @Other_Allow_Amount as Numeric(18,2)
		Declare @Desig_Dis_No  as NUMERIC(18,0)  
		DECLARE @Gross_Salary AS NUMERIC(18,2)
		Declare @Str_Month as varchar(Max)
		Declare @PF_DEF_ID		numeric 
		set @PF_DEF_ID =2
		
		
	
		Declare curEmp cursor for                    
			--Select Distinct Emp_ID from #Emp_All
			Select Emp_Id From #Emp_Cons
		open curEmp                      
		fetch next from curEmp into @Emp_Id_Cur 
		while @@fetch_status = 0                    
		begin                    
           
        Insert Into #Emp_Bonus_Register (Emp_ID)
		Select @Emp_Id_Cur 

			Set @Basic_Salary = 0
			Set @Effect_Allow_Amount = 0
			Set @Increment_Id = 0
			Set @Wages_Type = ''
			Set @Dept_Name = ''
			Set @Desig_Name = ''
			Set @val = ''
            Set @Effect_Allow_Amount_earning = 0
            Set @Basic_Salary_earning = 0 
			Set @Other_Allow_Amount = 0
			set @Gross_Salary = 0

			
			
			-- Changed By Ali 22112013 EmpName_Alias
			Update	 #Emp_Bonus_Register Set Emp_Code = E.Alpha_Emp_Code
					,Emp_Full_Name = ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name)				
			From	dbo.T0080_EMP_MASTER E Inner Join #Emp_Bonus_Register EM on E.Emp_ID = EM.Emp_ID
			--Where Column_Name = 'Gross Salary'
			
			set @Str_Month = ''		
			Set @Count = 1
			
			Set @Temp_For_Date = @From_Date
			While @Temp_For_Date <= @To_Date
				Begin                    
				
					set @Str_Month = 'Month_' + CAST(@count as varchar(10))
				
					Set @Basic_Salary = 0
					Set @Effect_Allow_Amount = 0
					Set @Increment_Id = 0
					Set @Wages_Type = ''
					Set @Other_Allow_Amount = 0
				
					Select @Increment_Id = I.Increment_ID, @Wages_Type = Wages_Type--,@Dept_Name = Dept_Name, @Desig_Name = Desig_Name,
							--@Branch_Name = Branch_Name
							, @Basic_Salary = I.Basic_Salary --+ SG.Arear_Basic + Basic_Salary_Arear_cutoff
							--,@Desig_Dis_No = DG.Desig_Dis_No  
					FROM dbo.T0095_Increment I WITH (NOLOCK) inner join       
						 (SELECT max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
						  WHERE  Increment_Effective_date <= @Temp_For_Date      
						  AND Cmp_ID = @Cmp_ID      
						  GROUP BY emp_ID) Qry on      
						 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID      
						 Left Outer Join dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = I.Dept_ID
						 Left Outer Join dbo.T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = I.Desig_Id
						 Inner Join dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID = I.Branch_ID 
					WHERE I.Emp_ID = @Emp_Id_Cur

					Select @Basic_Salary = Case When @wages_Type = 'Monthly' Then  isnull(sum(basic_salary),0) Else @Basic_Salary End ,
                       @Other_Allow_Amount =isnull(sum(Other_Allow_Amount),0) ,
                       --@Basic_Salary_earning = isnull(sum(salary_amount),0) + isnull(sum(Arear_Basic),0) + Isnull(sum(Basic_Salary_Arear_cutoff),0),
						@Basic_Salary_earning = MAD.M_AD_Calculated_Amount,
                       @Gross_Salary = ISNULL(sum(Gross_Salary),0)
					from dbo.T0200_MONTHLY_SALARY SG WITH (NOLOCK)
						 INNER JOIN 
							( select Emp_ID , AD.Cmp_ID , m_ad_Calculated_Amount,SAL_TRAN_ID from 
								T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  
								where ad_DEF_id = @PF_DEF_ID And ad_not_effect_salary <> 1 And ad.sal_type <> 1
								and AD.CMP_ID = @CMP_ID and (m_ad_Amount + isnull(M_AREAR_AMOUNT,0)+ Isnull(M_AREAR_AMOUNT_Cutoff,0)) > 0 
							) MAD on SG.Emp_ID = MAD.Emp_ID AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID							
					where sg.cmp_id=@Cmp_ID and sg.emp_id = @Emp_Id_Cur 
							and Month(month_end_date) = Month(@Temp_For_Date) and Year(month_end_date) = Year(@Temp_For_Date)
					GROUP By M_AD_Calculated_Amount
				
					Select @Effect_Allow_Amount = Isnull(Sum(E_AD_AMOUNT),0) 
					From dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join
						dbo.T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = AM.AD_ID 
					Where AD_EFFECT_ON_BONUS = 1 And EED.Cmp_ID=@Cmp_ID and Emp_id= @Emp_Id_Cur 
						And INCREMENT_ID = @Increment_Id

                    Select @Effect_Allow_Amount_earning = Isnull(Sum(M_AD_AMOUNT),0) + Isnull(Sum(M_AREAR_AMOUNT ),0)  
					From dbo.T0210_Monthly_ad_detail MAD WITH (NOLOCK) Inner Join
						dbo.T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = AM.AD_ID 
					Where AD_EFFECT_ON_BONUS = 1 and  MAD.Cmp_ID=@Cmp_ID and Emp_id= @Emp_Id_Cur 
						And Month(For_date) = Month(@Temp_For_Date) and Year(For_date) = Year(@Temp_For_Date)

					print @Basic_Salary_earning
					If Exists(Select S_Sal_Tran_Id From dbo.T0201_monthly_salary_sett WITH (NOLOCK) where S_Eff_Date Between @From_Date And @To_Date And Cmp_Id=@Cmp_Id and emp_Id = @Emp_Id_Cur)
						Begin 
							Select	@Effect_Allow_Amount_earning = @Effect_Allow_Amount_earning + m_ad_Calculated_Amount from
									  t0201_monthly_salary_sett  SG  WITH (NOLOCK) INNER JOIN 
							( select Emp_ID , AD.Cmp_ID , m_ad_Calculated_Amount,SAL_TRAN_ID from 
								T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  
								where ad_DEF_id = @PF_DEF_ID And ad_not_effect_salary <> 1 And ad.sal_type = 1
								and AD.CMP_ID = @CMP_ID and (m_ad_Amount + isnull(M_AREAR_AMOUNT,0)+ Isnull(M_AREAR_AMOUNT_Cutoff,0)) > 0 
							) MAD on SG.Emp_ID = MAD.Emp_ID AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID
							WHERE MAD.CMP_ID = @CMP_ID and MAD.Emp_ID = @Emp_Id_Cur And S_Eff_Date Between @From_Date And @To_Date
							--group by Mad.emp_id
						END
					

					print @Effect_Allow_Amount_earning

					Set @MonthName = ''
					Set @MonthName = Cast(Upper(Left(DATENAME(MONTH,@Temp_For_Date),3)) as varchar(4)) + '_' + Cast(YEAR(@Temp_For_Date) as varchar(50))

					Set @val = '' 
					
				
					
					If @Wages_Type= 'Monthly'
                         Begin
          					Set @val = 'Update #Emp_Bonus_Register Set ' + @Str_Month + ' = ' + Cast(@Basic_Salary_earning + @Effect_Allow_Amount_earning as varchar(100)) + ' 
		     				 Where Emp_ID = ' + Cast(@Emp_Id_Cur as varchar(10))
                         End
                    Else
                         Begin
							Set @val = 'Update #Emp_Bonus_Register Set ' + @Str_Month + ' = ' + Cast(@Basic_Salary_earning  + @Other_Allow_Amount + @Effect_Allow_Amount_earning as varchar(40)) + ' 
							 From #Emp_Bonus_Register E inner join 								
									dbo.T0180_BONUS B   on E.Emp_ID = B.Emp_ID  								
									Inner Join T0190_BONUS_DETAIL BD
							
							On B.Bonus_ID = BD.Bonus_ID
							Where  BD.Month_Date = ''' + cast(@Temp_For_Date as varchar(20)) + ''' And E.Emp_Id = ' + Cast(@Emp_Id_Cur as varchar(10)) 
					--exec (@val)	
					--Bonus_Amt = ''Earned Bonus Salary'' And			  
                         End
					print @val
					exec (@val)
					

					--Set @val = 'Update #Emp_All Set ' + @MonthName + ' = BD.Bonus_Calculated_Amount , Total += BD.Bonus_Calculated_Amount
					--			From #Emp_All E inner join 								
					--					dbo.T0180_BONUS B   on E.Emp_ID = B.Emp_ID  								
					--					Inner Join T0190_BONUS_DETAIL BD
								
					--			On B.Bonus_ID = BD.Bonus_ID
					--			Where Column_Name = ''Bonus Applicable Salary'' And BD.Month_Date = ''' + cast(@Temp_For_Date as varchar(20)) + '''  And E.Emp_Id = ' + Cast(@Emp_Id_Cur as varchar(10)) 

					--exec (@val)

					--Set @val = '' 
					
					--Ankit 02102014
					--	Set @val = 'Update #Emp_All Set ' + @MonthName + ' = BD.Bonus_Amount , Total += BD.Bonus_Amount
					--			From #Emp_All E inner join 								
					--					dbo.T0180_BONUS B   on E.Emp_ID = B.Emp_ID  								
					--					Inner Join T0190_BONUS_DETAIL BD
								
					--			On B.Bonus_ID = BD.Bonus_ID
					--			Where Column_Name = ''Bonus Amount'' And BD.Month_Date = ''' + cast(@Temp_For_Date as varchar(20)) + '''  And E.Emp_Id = ' + Cast(@Emp_Id_Cur as varchar(10)) 

					--exec (@val)

					--Set @val = '' 
					--Ankit 02102014
					

     
					--Set @val = 'Update #Emp_All Set ' + @MonthName + ' = ' + Cast(@Gross_Salary as varchar(40)) + ' , Total += ' + Cast(@Gross_Salary as varchar(40)) + '
					--			From #Emp_All E inner join 								
					--					dbo.T0180_BONUS B   on E.Emp_ID = B.Emp_ID  								
					--					Inner Join T0190_BONUS_DETAIL BD
								
					--			On B.Bonus_ID = BD.Bonus_ID
					--			Where Column_Name = ''Earned Gross Salary'' And BD.Month_Date = ''' + cast(@Temp_For_Date as varchar(20)) + ''' And E.Emp_Id = ' + Cast(@Emp_Id_Cur as varchar(10)) 
					--exec (@val)
					
   

					--Set @val = '' 
					--Set @val = 'Update #Emp_All Set ' + @MonthName + ' = BD.Present_Days , Total += BD.Present_Days
					--			From #Emp_All E inner join 								
					--					dbo.T0180_BONUS B   on E.Emp_ID = B.Emp_ID  								
					--					Inner Join T0190_BONUS_DETAIL BD
								
					--			On B.Bonus_ID = BD.Bonus_ID
					--			Where Column_Name = ''Total Present Days'' And BD.Month_Date = ''' + cast(@Temp_For_Date as varchar(20)) + ''' And E.Emp_Id = ' + Cast(@Emp_Id_Cur as varchar(10)) 
					--exec (@val)


					--Set @val = ''  
					--Set @val = 'Update #Emp_All Set ' + @MonthName + ' = BD.Working_Days , Total += BD.Working_Days 
					--			From #Emp_All E inner join 								
					--					dbo.T0180_BONUS B   on E.Emp_ID = B.Emp_ID  								
					--					Inner Join T0190_BONUS_DETAIL BD
								
					--			On B.Bonus_ID = BD.Bonus_ID
					--			Where Column_Name = ''Total Month Days''  And BD.Month_Date = ''' + cast(@Temp_For_Date as varchar(20)) + ''' And E.Emp_Id = ' + Cast(@Emp_Id_Cur as varchar(10)) 
					--exec (@val)
					
				
					Set @Temp_For_Date = DATEADD(M,1,@Temp_For_Date)
					set @count = @count + 1  
				End                    
			fetch next from curEmp into @Emp_Id_Cur
	    end                    
		close curEmp                    
		deallocate curEmp 

		Select  *	into #tmpBonus
		from	#Emp_Bonus_Register 
		ORDER BY CASE WHEN @Order_By='Name' THEN #Emp_Bonus_Register.Emp_Full_Name 							
							ELSE 
								Case	When IsNumeric(Replace(Replace(#Emp_Bonus_Register.Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(#Emp_Bonus_Register.Emp_Code,'="',''),'"',''), 20)
										When IsNumeric(Replace(Replace(#Emp_Bonus_Register.Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(#Emp_Bonus_Register.Emp_Code,'="',''),'"','') + Replicate('',21), 20)
										Else Replace(Replace(#Emp_Bonus_Register.Emp_Code,'="',''),'"','')
								END
						End					
		
	
		
			Select		 T.*
						,Comp_Name,Branch_Address
						, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,Q_I.Branch_id,Q_I.Dept_Id,Q_I.Grd_Id,Q_I.Desig_Id, Q_I.Type_id
						,Type_Name
						,CMP_NAME,CMP_ADDRESS
						,@From_Date as P_From_date ,@To_Date as P_To_Date	
						,E.Vertical_ID,E.SubVertical_ID  
			From		#tmpBonus T inner JOIN #Emp_Cons EC On Ec.Emp_ID = T.emP_Id INNER JOIN  dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID =E.EMP_ID  INNER JOIN 
						(SELECT		I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Type_ID,I.Emp_ID
						 FROM		dbo.T0095_Increment I WITH (NOLOCK) inner join 
										(select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment	WITH (NOLOCK)
										 where Increment_Effective_date <= @To_Date
												and Cmp_ID = @Cmp_ID
										 group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID)Q_I ON
						E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID INNER JOIN 
						dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.CMP_ID = E.CMP_ID Left outer join 
						dbo.T0040_Type_Master tm WITH (NOLOCK) on Q_I.Type_ID = tm.Type_ID 
			Order by	Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
						When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
						Else e.Alpha_Emp_Code
						End
		
	RETURN
