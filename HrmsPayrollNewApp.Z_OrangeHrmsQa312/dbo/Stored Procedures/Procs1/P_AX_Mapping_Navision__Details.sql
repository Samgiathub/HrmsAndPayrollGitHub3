
CREATE PROCEDURE [dbo].[P_AX_Mapping_Navision__Details]
	 @Cmp_Id		NUMERIC  
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID		VARCHAR(MAX) = ''		
	,@Cat_ID		varchar(Max) = ''
	,@Grd_ID		varchar(Max) = ''
	,@Type_ID		varchar(Max) = ''
	,@Dept_ID		varchar(Max) = ''
	,@Desig_ID		varchar(Max) = ''
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  varchar(Max) = ''	
	,@Vertical_Id varchar(Max) = ''	 
	,@SubVertical_Id varchar(Max) = ''	
	,@SubBranch_Id varchar(Max) = ''
	,@Status INT	
AS
BEGIN
	
	--Created by ronakk 06092022 

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;
		
	DECLARE @columns VARCHAR(MAX)
	DECLARE @query nVARCHAR(MAX)

	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID		NUMERIC ,     
	   Branch_ID	NUMERIC,
	   Increment_ID NUMERIC    
	 )    
	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'',0,0    


		Select EMP.alpha_emp_code as Employee_ID,YEAR(For_Date) as 'Year',Month(For_Date) as 'Month',AXM.Head_Name as Head 
		,AD.M_AD_Amount + ISNULL(AD.M_AREAR_AMOUNT,0) as Amount
		,case when AD.M_AD_Flag = 'I' then 'DR'
		       when AD.M_AD_Flag = 'D' then 'CR'
		  else '' 
		  end as DRCR
		,CCM.Center_Name as Divison,EMP.dept_name as Department,EMP.branch_name as Branch , EMP.grd_name as Grade,
		EMP.emp_category as Category ,EMP.desig_name as Designation ,TM.Type_Name as Type,BM.Bank_Name,AXM.Ad_id,EMP.emp_id
		,A.AD_DEF_ID
		into #AXNAV
		from T0210_MONTHLY_AD_DETAIL ad
		 join  T9999_Ax_Mapping AXM on ad.AD_ID = AXM.Ad_id
		 join T0050_AD_MASTER A on AD.AD_ID = A.AD_ID
		 left join V0080_EMP_MASTER_INCREMENT_GET EMP on EMP.emp_id = AD.Emp_ID
		 left join T0040_COST_CENTER_MASTER CCM on CCM.Center_ID = EMP.center_id
		 left join T0040_TYPE_MASTER TM on EMP.type_id= TM.Type_ID
		 left join T0040_BANK_MASTER BM on BM.Bank_ID = EMP.bank_id
		where EMP.emp_id in (select Emp_ID from #Emp_Cons) and Month(AD.For_Date)  = Month(@From_Date) and Year(AD.For_Date)  = Year(@From_Date)
		order by  AD.M_AD_Tran_ID
		
			        --Select Employee_ID,Year,Month,'Basic Salary',0,'DR',Divison,Department,
					--Branch,Grade,Category,Designation,Type,Bank_Name ,2003,emp_id
					--from  #AXNAV
					--group by Employee_ID,Year,Month,Divison,Department,
					--Branch,Grade,Category,Designation,Type,Bank_Name,emp_id

		

				DECLARE @count INT
				DECLARE @limit INT
				Declare @CNT int
				SET @count = 0
				SET @limit = 1;

				select @CNT= count(1) from (Select  emp_id from  #AXNAV group by emp_id) as R

	
				
           
				    
				WHILE @count< @CNT
				BEGIN
				
				declare @eid int
				Declare @EAlphaCode nvarchar(max) 
				Declare @Year  int
				declare @Month int
				Declare @CostCenter nvarchar(max) 
				Declare @Department nvarchar(max)
				Declare @Branch nvarchar(max) 
				Declare @Grade nvarchar(max) 
				Declare @Cat nvarchar(max) 
				Declare @Desig nvarchar(max) 
				Declare @Type nvarchar(max) 
				Declare @BankName nvarchar(max) 



					Select 
					 @EAlphaCode =Employee_ID
					,@Year = Year
					,@Month = Month
					--,'Basic Salary'
					--,0
					--,'DR'
					,@CostCenter = Divison
					,@Department = Department
					,@Branch = Branch
					,@Grade = Grade
					,@Cat = Category
					,@Desig = Designation
					,@Type = Type
					,@BankName = Bank_Name
					--,2003
					,@eid= emp_id
					from  #AXNAV
					group by Employee_ID,Year,Month,Divison,Department,
					Branch,Grade,Category,Designation,Type,Bank_Name,emp_id
					ORDER BY Employee_ID
					OFFSET @count ROWS
					FETCH NEXT @limit ROWS ONLY
					SET @count = @count + 1

					------------------------------------------------- Start For Basic Amount -----------------------------------------------

					Declare @BasicAmount as numeric(18,2) 
					Declare @BasicStalment as numeric(18,2) 

					set @BasicAmount = 0
					set @BasicAmount = 0

					IF exists (select 1 from T9999_Ax_Mapping where Cmp_id=@Cmp_Id and Ad_id=2003)
					Begin

							SELECT  @BasicAmount = isnull(SUM(MS.Salary_Amount),0) + isnull(SUM(MS.Arear_Basic ),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
							inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) 
							INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
							INNER JOIN ( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)
											WHERE INCREMENT_EFFECTIVE_DATE <= @To_Date
											AND CMP_ID = @Cmp_Id 
											GROUP BY EMP_ID  ) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) 
								AS INC ON INC.EMP_ID = MS.EMP_ID
							inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
							where  MONTH(month_end_date) = Month(@From_Date)  and YEAR(month_end_date) = Year(@From_Date)  
							--and isnull(ms.is_FNF,0)  = 0  
							and EM.Emp_ID = @eid



							SELECT @BasicStalment =  isnull(SUM(MS.S_Salary_Amount),0) FROM  T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
							inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) 
							INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
							INNER JOIN ( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) 
											WHERE INCREMENT_EFFECTIVE_DATE <= @To_Date AND CMP_ID = @Cmp_Id 
											GROUP BY EMP_ID  ) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) 
							    AS INC ON INC.EMP_ID = MS.EMP_ID 
								inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
								where  MONTH(S_Eff_Date) = Month(@From_Date) and YEAR(S_Eff_Date) = year(@From_Date) and EM.Emp_ID = @eid

							insert into #AXNAV (Employee_ID,Year,Month,Head,Amount,DRCR,Divison,Department,Branch,
							Grade,Category,Designation,Type,Bank_Name,Ad_id,emp_id) values
							(@EAlphaCode,@Year,@Month,'Basic Salary',@BasicAmount+@BasicStalment,'DR',@CostCenter,@Department,
							@Branch,@Grade,@Cat,@Desig,@Type,@BankName,2003,@eid)


				End
				
			------------------------------------------------- End For Basic Amount -----------------------------------------------


			------------------------------------------------- Start For Gross Salary -----------------------------------------------
			
			Declare @GrossSal as numeric(18,2) 
			set @GrossSal = 0
			
			IF exists (select 1 from T9999_Ax_Mapping where Cmp_id=@Cmp_Id and Ad_id=1002)
			Begin
			
					SELECT @GrossSal = (isnull(SUM(MS.Gross_Salary),0) - (Isnull(Sum(MS.Leave_Salary_Amount),0) + ISNULL(Sum(Ms.Gratuity_Amount),0) + ISNULL(Sum(Qry2.M_AD_Amount),0)))
					FROM  T0200_MONTHLY_SALARY MS 
					INNER JOIN (SELECT I.EMP_ID FROM T0095_INCREMENT I WITH (NOLOCK)
								INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
								INNER JOIN (SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)
															WHERE INCREMENT_EFFECTIVE_DATE <= @From_Date AND CMP_ID = @CMP_ID 
															GROUP BY EMP_ID ) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC
											ON INC.EMP_ID = MS.EMP_ID
								LEFT OUTER JOIN (SELECT MAD.EMP_ID, ISNULL(SUM(MAD.M_AD_AMOUNT),0) AS M_AD_AMOUNT , MAD.TO_DATE 
								                 FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
												INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID
												WHERE  
												AD.AD_NOT_EFFECT_SALARY  = 1 AND MAD.M_AD_NOT_EFFECT_SALARY = 0 AND 
												MONTH(MAD.To_date) = MONTH(@From_Date)  AND YEAR(MAD.To_date) = YEAR(@From_Date)
												GROUP BY MAD.Emp_ID , MAD.TO_DATE
												) QRY2 
												on Qry2.Emp_ID = MS.Emp_ID and MONTH(Qry2.To_date) = MONTH(@From_Date) and YEAR(Qry2.To_date) = YEAR(@From_Date)
					WHERE  MONTH(MONTH_END_DATE) = MONTH(@From_Date)  AND YEAR(MONTH_END_DATE) = YEAR(@From_Date) and 
					INC.Emp_ID = @eid
			
			
							insert into #AXNAV (Employee_ID,Year,Month,Head,Amount,DRCR,Divison,Department,Branch,
							Grade,Category,Designation,Type,Bank_Name,Ad_id,emp_id) values
							(@EAlphaCode,@Year,@Month,'Gross Salary',@GrossSal,'DR',@CostCenter,@Department,
							@Branch,@Grade,@Cat,@Desig,@Type,@BankName,1002,@eid)
			
			End
			------------------------------------------------- End For Gross Salary -----------------------------------------------

			------------------------------------------------- Start For Net Salary -----------------------------------------------
			
			Declare @NetSal as numeric(18,2) 
			set @NetSal = 0
			
			IF exists (select 1 from T9999_Ax_Mapping where Cmp_id=@Cmp_Id and Ad_id=1003)
			Begin

					SELECT @NetSal =   isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
						INNER JOIN (SELECT I.EMP_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK)
						INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
						INNER JOIN 
									( 
										SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)
										WHERE INCREMENT_EFFECTIVE_DATE <= @To_Date
										AND CMP_ID = @CMP_ID 
										GROUP BY EMP_ID
									) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where  MS.Cmp_ID = @CMP_ID and MONTH(month_end_date) = MONTH(@From_Date)  
						and YEAR(month_end_date) = YEAR(@From_Date)  and  MS.Emp_ID =@eid


						insert into #AXNAV (Employee_ID,Year,Month,Head,Amount,DRCR,Divison,Department,Branch,
							Grade,Category,Designation,Type,Bank_Name,Ad_id,emp_id) values
							(@EAlphaCode,@Year,@Month,'Net Salary',@NetSal,'CR',@CostCenter,@Department,
							@Branch,@Grade,@Cat,@Desig,@Type,@BankName,1003,@eid)

					
			End

			------------------------------------------------- End For Net Salary -----------------------------------------------


			------------------------------------------------- Start For Total Earnings  -----------------------------------------------
			
			Declare @TotEarnSal as numeric(18,2) 
			set @TotEarnSal = 0
			
			IF exists (select 1 from T9999_Ax_Mapping where Cmp_id=@Cmp_Id and Ad_id=2004)
			Begin

						select @TotEarnSal =  sum(M_AD_Amount) from T0210_MONTHLY_AD_DETAIL where Cmp_ID =@Cmp_Id and Emp_ID=@eid  and
						Month(For_Date)  = Month(@From_Date) and Year(For_Date)  = Year(@From_Date)
						and M_AD_Flag='I'


						insert into #AXNAV (Employee_ID,Year,Month,Head,Amount,DRCR,Divison,Department,Branch,
							Grade,Category,Designation,Type,Bank_Name,Ad_id,emp_id) values
							(@EAlphaCode,@Year,@Month,'Total Earning',@TotEarnSal,'DR',@CostCenter,@Department,
							@Branch,@Grade,@Cat,@Desig,@Type,@BankName,2004,@eid)



			ENd
			------------------------------------------------- End For Total Earning -----------------------------------------------


			------------------------------------------------- Start For Total Deductions -----------------------------------------------
			Declare @TotDedSal as numeric(18,2) 
			set @TotDedSal = 0
			
			IF exists (select 1 from T9999_Ax_Mapping where Cmp_id=@Cmp_Id and Ad_id=2005)
			Begin
						
						select @TotDedSal = sum(M_AD_Amount) from T0210_MONTHLY_AD_DETAIL where Cmp_ID =@Cmp_Id and  Emp_ID=@eid  and
 						Month(For_Date)  = Month(@From_Date) and Year(For_Date)  = Year(@From_Date)
						and M_AD_Flag='D'



						insert into #AXNAV (Employee_ID,Year,Month,Head,Amount,DRCR,Divison,Department,Branch,
							Grade,Category,Designation,Type,Bank_Name,Ad_id,emp_id) values
							(@EAlphaCode,@Year,@Month,'Total Deductions',@TotDedSal,'CR',@CostCenter,@Department,
							@Branch,@Grade,@Cat,@Desig,@Type,@BankName,2005,@eid)


			ENd
			------------------------------------------------- End For Total Deductions -----------------------------------------------

			------------------------------------------------- Start For Professional Tax -----------------------------------------------
			
			Declare @PTAMT as numeric(18,2) 
			set @PTAMT = 0
			IF exists (select 1 from T9999_Ax_Mapping where Cmp_id=@Cmp_Id and Ad_id=1001)
			Begin
						
						
						select @PTAMT = PT_Amount from T0200_MONTHLY_SALARY where Cmp_ID =@Cmp_Id and  Emp_ID=@eid  and
 						Month(Month_St_Date)  = Month(@From_Date) and Year(Month_St_Date)  = Year(@From_Date)


						insert into #AXNAV (Employee_ID,Year,Month,Head,Amount,DRCR,Divison,Department,Branch,
							Grade,Category,Designation,Type,Bank_Name,Ad_id,emp_id) values
							(@EAlphaCode,@Year,@Month,'Professional Tax',@PTAMT,'CR',@CostCenter,@Department,
							@Branch,@Grade,@Cat,@Desig,@Type,@BankName,1001,@eid)


			ENd
			------------------------------------------------- End For Professional Tax -----------------------------------------------


			
			------------------------------------------------- Start For LWF -----------------------------------------------
			
			Declare @LWF as numeric(18,2) 
			declare @LWFREV as numeric(18,2)
			set @LWF = 0
			set @LWFREV = 0
			IF exists (select 1 from T9999_Ax_Mapping where Cmp_id=@Cmp_Id and Ad_id=1006)
			Begin
						
						
						select @LWF = LWF_Amount from T0200_MONTHLY_SALARY where Cmp_ID =@Cmp_Id and  Emp_ID=@eid  and
 						Month(Month_St_Date)  = Month(@From_Date) and Year(Month_St_Date)  = Year(@From_Date)


						insert into #AXNAV (Employee_ID,Year,Month,Head,Amount,DRCR,Divison,Department,Branch,
							Grade,Category,Designation,Type,Bank_Name,Ad_id,emp_id) values
							(@EAlphaCode,@Year,@Month,'LWF',@LWF,'CR',@CostCenter,@Department,
							@Branch,@Grade,@Cat,@Desig,@Type,@BankName,1006,@eid)


							---Added by ronakk 01112022 for Reverse entry
							
							if @LWF>0
							Begin
							select @LWFREV = 
							LWF_Max_Amount
							from T0040_GENERAL_SETTING GS
							where Cmp_ID=@Cmp_Id and Branch_ID = (select Branch_ID from V0080_EMP_MASTER_INCREMENT_GET where Emp_ID=@eid)
							and  For_Date in (SELECT Max(For_Date) 
							FROM   T0040_GENERAL_SETTING 
							WHERE  For_Date <= Getdate() AND cmp_id = @Cmp_Id
							GROUP  BY Branch_ID)
							End
							 
						     insert into #AXNAV (Employee_ID,Year,Month,Head,Amount,DRCR,Divison,Department,Branch,Grade,Category,Designation,Type,Bank_Name,Ad_id,emp_id)
						     select @EAlphaCode,@Year,@Month,'Welfare Fund',@LWFREV,'CR',@CostCenter,@Department,@Branch,@Grade,@Cat,@Desig,@Type,@BankName,1006,@eid
						     union
						     select @EAlphaCode,@Year,@Month,'Employer LWF',@LWFREV,'DR',@CostCenter,@Department,@Branch,@Grade,@Cat,@Desig,@Type,@BankName,1006,@eid



							---End by ronakk 01112022





			ENd
			------------------------------------------------- End For LWF -----------------------------------------------


			--------------------------------------------Added  by ronakk 11 11 2022 For Loan Deduction Amount ----------------------------

			If exists (select 1 from T9999_Ax_Mapping where Cmp_id=@Cmp_Id and Type='Loan')
			Begin

					insert into #AXNAV (Employee_ID,Year,Month,Head,Amount,DRCR,Divison,Department,Branch,Grade,Category,Designation,Type,Bank_Name,Ad_id,emp_id)
					select @EAlphaCode,@Year,@Month,AM.Head_Name,MLP.Loan_Pay_Amount,'CR',@CostCenter,@Department,@Branch,@Grade,@Cat,@Desig,@Type,@BankName,0,@eid
					from T0210_MONTHLY_LOAN_PAYMENT MLP
					inner join T0120_LOAN_APPROVAL LA WITH (NOLOCK) ON MLP.LOAN_APR_ID = LA.LOAN_APR_ID 
					inner join T9999_Ax_Mapping AM on AM.Loan_id = LA.Loan_ID
					where MLP.Cmp_ID=@Cmp_Id and Sal_Tran_ID=(select Sal_Tran_ID from T0200_MONTHLY_SALARY where Emp_ID=@eid
					and Month(Month_St_Date)  = Month(@From_Date) and Year(Month_St_Date)  = Year(@From_Date))

			End

			--------------------------------------------End  by ronakk 11 11 2022 For Loan Deduction Amount ----------------------------

			------------------------------------------------- Start For Interest of Loan -----------------------------------------------
			
			Declare @IntofLoan as numeric(18,2) 
			set @IntofLoan = 0

			IF exists (select 1 from T9999_Ax_Mapping where Cmp_id=@Cmp_Id and Ad_id=2052)
			Begin
						
						
						select @IntofLoan = LOAN_INTREST_AMOUNT from T0200_MONTHLY_SALARY where Cmp_ID =@Cmp_Id and  Emp_ID=@eid  and
 						Month(Month_St_Date)  = Month(@From_Date) and Year(Month_St_Date)  = Year(@From_Date)


						insert into #AXNAV (Employee_ID,Year,Month,Head,Amount,DRCR,Divison,Department,Branch,
							Grade,Category,Designation,Type,Bank_Name,Ad_id,emp_id) values
							(@EAlphaCode,@Year,@Month,'Interest of Loan',@IntofLoan,'CR',@CostCenter,@Department,
							@Branch,@Grade,@Cat,@Desig,@Type,@BankName,2052,@eid)


			ENd
			------------------------------------------------- End For Interest of Loan -----------------------------------------------


			------------------------------------------------- Start For Leave Encashment -----------------------------------------------
			
			Declare @LeaveEncaseAmt numeric(18,2) 
			set @LeaveEncaseAmt = 0

			IF exists (select 1 from T9999_Ax_Mapping where Cmp_id=@Cmp_Id and Ad_id=1030)
			Begin
						
						
						select @LeaveEncaseAmt = Leave_Salary_Amount from T0200_MONTHLY_SALARY where Cmp_ID =@Cmp_Id and  Emp_ID=@eid  and
 						Month(Month_St_Date)  = Month(@From_Date) and Year(Month_St_Date)  = Year(@From_Date)


						insert into #AXNAV (Employee_ID,Year,Month,Head,Amount,DRCR,Divison,Department,Branch,
							Grade,Category,Designation,Type,Bank_Name,Ad_id,emp_id) values
							(@EAlphaCode,@Year,@Month,'Leave Encashment',@LeaveEncaseAmt,'DR',@CostCenter,@Department,
							@Branch,@Grade,@Cat,@Desig,@Type,@BankName,1030,@eid)


			ENd
			------------------------------------------------- End For Leave Encashment-----------------------------------------------

			------------------------------------------------- Start For Advance -----------------------------------------------
			
			Declare @AdvAmt numeric(18,2) 
			set @AdvAmt = 0

			IF exists (select 1 from T9999_Ax_Mapping where Cmp_id=@Cmp_Id and Ad_id=1015)
			Begin
						
						
						select @AdvAmt = Advance_Amount from T0200_MONTHLY_SALARY where Cmp_ID =@Cmp_Id and  Emp_ID=@eid  and
 						Month(Month_St_Date)  = Month(@From_Date) and Year(Month_St_Date)  = Year(@From_Date)


						insert into #AXNAV (Employee_ID,Year,Month,Head,Amount,DRCR,Divison,Department,Branch,
							Grade,Category,Designation,Type,Bank_Name,Ad_id,emp_id) values
							(@EAlphaCode,@Year,@Month,'Advance',@AdvAmt,'CR',@CostCenter,@Department,
							@Branch,@Grade,@Cat,@Desig,@Type,@BankName,1015,@eid)


			ENd
			------------------------------------------------- End For Advance-----------------------------------------------


			--------------------------------------------------start for other allownce settlement-------------------------------------


			If exists (select 1 from T0201_MONTHLY_SALARY_SETT MSS  where Emp_ID=@eid and S_Eff_Date = @From_Date)
			Begin
			
			       
					select sum(M_AD_Amount) as SetAMt,S.AD_ID,ad.AD_NAME
					into #TempAllowSett
					from T0201_MONTHLY_SALARY_SETT MSS 
					left join T0210_MONTHLY_AD_DETAIL S on mss.S_Sal_Tran_ID = s.S_Sal_Tran_ID
					left join T0050_AD_MASTER AD on s.AD_ID = ad.AD_ID
					where S_Eff_Date = @From_Date and Mss.Emp_ID  = @eid
					group by s.AD_ID,ad.AD_NAME


                        Update AX set AX.Amount= AX.Amount + ST.SetAMt 
						from #AXNAV AX
						inner join #TempAllowSett ST on ST.AD_ID = AX.Ad_id
						where AX.emp_id = @eid and ST.AD_ID = AX.Ad_id


			
			end




			--------------------------------------------------End for other allownce settlement-------------------------------------

		






	END


		
		
  ----------------------------------------------------------FOR Reverce Entry 01112022 ------------------------------------
  --Added by ronakk 01112022


  if Exists(select 1 from #AXNAV where AD_DEF_ID in (6,5))
  Begin
		



							insert into #AXNAV (Employee_ID,Year,Month,Head,Amount,DRCR,Divison,Department,Branch,
							Grade,Category,Designation,Type,Bank_Name,Ad_id,emp_id)
							select Employee_ID,Year,Month
							,case when AD_DEF_ID=5 then 'PF Payable' 
								  when  AD_DEF_ID=6 then 'ESIC  Payable'
							 end
							,Amount,'CR',Divison,Department,Branch,Grade,Category,Designation,Type,Bank_Name,Ad_id,emp_id
							from #AXNAV where AD_DEF_ID in (5,6)
							


  End



  -----------------------------------------------------------------------------END-----------------------------------------------


	





		--select Emp_ID from #Emp_Cons


		Select Employee_ID,Year,Month,Head,Amount,DRCR,Divison,Department,
		Branch,Grade,Category,Designation,Type,Bank_Name 
		from  #AXNAV
		order by  Employee_ID

		drop table #AXNAV



End
