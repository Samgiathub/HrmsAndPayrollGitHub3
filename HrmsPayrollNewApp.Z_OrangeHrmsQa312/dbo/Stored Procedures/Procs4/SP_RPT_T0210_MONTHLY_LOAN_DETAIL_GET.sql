CREATE PROCEDURE [dbo].[SP_RPT_T0210_MONTHLY_LOAN_DETAIL_GET]
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
,@constraint 	varchar(MAX)
,@Sal_Type		numeric = 0
,@Loan_Id       numeric=0
,@Salary_Cycle_id numeric = 0
,@Segment_Id  numeric = 0		 
,@Vertical_Id numeric = 0		 
,@SubVertical_Id numeric = 0	 
,@SubBranch_Id numeric = 0 
,@Status varchar(20) = ''		 
,@Report_Type  varchar(100) = ''  
,@Flag  numeric = 0 
,@Salary_Status  varchar(100) = ''

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	 
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
		
	If @Loan_Id =0 
		Set @Loan_Id= NULL	
		
	IF @Segment_Id = 0 
		SET @Segment_Id = null
	IF @Vertical_Id= 0 
		SET @Vertical_Id = null
	IF @SubVertical_Id = 0 
		SET @SubVertical_Id= Null

	CREATE TABLE #Emp_Cons 
	(      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	)   
	
	if @Constraint <> ''
		begin
		
			Insert Into #Emp_Cons
			Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
		end
	else
		Begin
			EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
		End

	--Added by Nimesh 19 May 2015
	--Filtering Employee Record according to Salary Status
	IF (@Status = 'Hold' OR @Status = 'Done') BEGIN
		DELETE	E
		FROM	#Emp_Cons E 
		WHERE	NOT EXISTS ( 
							SELECT Emp_ID FROM T0200_MONTHLY_SALARY S WITH (NOLOCK)
							WHERE	Month(S.Month_End_Date)=Month(@To_Date) 
									AND Year(S.Month_End_Date)=Year(@To_Date) 
									AND S.Cmp_ID=@Cmp_ID 
									AND S.Salary_Status=@Status AND s.Emp_ID=e.Emp_ID
						   )
	END
	
	--Added by Gadriwala Muslim 16072015 - Start
	CREATE TABLE #Loan_Installment_Status
	(
		Emp_ID numeric(18,0),
		Loan_ID numeric(18,0),
		Total_Installment numeric(18,0),
		Current_installment numeric(18,0),
		Loan_Apr_ID numeric(18,0)--Added by nilesh patel on 31082015 
	)
	
	CREATE NONCLUSTERED INDEX IX_Loan_Installment_Status ON #Loan_Installment_Status (Emp_ID, Loan_ID);
	
	if @Flag = 1 --Added by nilesh on 05022016 Flag = 1 than calculate Installment Detail other wise not consider it
		Begin
			INSERT INTO #Loan_Installment_Status
			EXEC dbo.SP_RPT_LOAN_STATEMENT_REPORT @cmp_ID,@from_date,@to_date,@branch_ID,@cat_ID,@grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,'','',1
		End 
		--Added by Gadriwala Muslim 16072015 - End
	
	

	IF @Report_Type = ''
	BEGIN

		UPDATE	LIS 
		SET Current_installment = Current_Count, 
			Total_Installment = No_of_Inst_Loan_Amt 
		FROM	#Loan_Installment_Status LIS 
				INNER JOIN(
							SELECT	COUNT(1) as Current_Count,LP.Loan_Apr_ID,LA.Emp_ID,ISNULL(LA.No_of_Inst_Loan_Amt,0) as No_of_Inst_Loan_Amt 
							From	T0210_MONTHLY_LOAN_PAYMENT LP WITH (NOLOCK) INNER JOIN T0120_LOAN_APPROVAL LA WITH (NOLOCK) ON LA.Loan_Apr_ID = LP.Loan_Apr_ID 
							WHERE	LP.Is_Loan_Interest_Flag = 1 and LP.Loan_Payment_Date <= @To_date and LA.Loan_Apr_Pending_Amount = 0
							GROUP BY LP.Loan_Apr_ID,LA.Emp_ID,No_of_Inst_Loan_Amt
						  ) QRY ON QRY.Loan_Apr_ID = LIS.Loan_Apr_ID AND QRY.Emp_ID = LIS.Emp_ID
		
		Select  DISTINCT MLD.Loan_Pay_ID,	
				MLD.Loan_Apr_ID,
				MLD.Cmp_ID,	
				MLD.Sal_Tran_ID,	
				MLD.S_Sal_Tran_ID,	
				MLD.L_Sal_Tran_ID,	
				(Case When MLD.Loan_Pay_Amount = 0 THEN ROund(MLD.Interest_Amount,0) ELSE MLD.Loan_Pay_Amount END) As Loan_Pay_Amount,	
				MLD.Loan_Pay_Comments,	
				MLD.Loan_Payment_Date,	
				MLD.Loan_Payment_Type,	
				MLD.Bank_Name,	
				MLD.Loan_Cheque_No,	
				MLD.Loan_Pay_Code,	
				MLD.Temp_Sal_Tran_ID,	
				MLD.Interest_Percent,	
				MLD.Interest_Amount,	
				MLD.Interest_Subsidy_Amount,	
				MLD.Is_Loan_Interest_Flag,LA.Loan_Apr_Date,LA.Loan_Apr_No_of_Installment,LA.Loan_Apr_Installment_Amount,LA.Loan_Apr_Installment_Amount,E.Emp_Id,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Branch_Address,Comp_name,Grd_Name
				,isnull(b.BandName,'') as BandName
				,EMP_CODE,Alpha_Emp_Code,Type_Name,Dept_Name,Desig_Name,
				LOAN_NAME + '' +(Case When MLD.Loan_Pay_Amount = 0 THEN ' (I)' Else '' END) as LOAN_NAME,
				Cmp_Name,Branch_Name
				,(Case When MLD.Loan_Pay_Amount = 0  THEN ROund(LA.Total_Loan_Int_Amount,0) Else isnull(LA.Loan_apr_amount + ISNULL(LA.CF_Loan_Amt,0),0) + Isnull(LA.Paid_Amount,0) END) as Loan_apr_amount,
				(Case When MLD.Loan_Pay_Amount = 0 THEN 0 Else LA.Loan_Apr_pending_amount end) as Loan_Apr_pending_amount,
				Cmp_Address 
				--,LNT.Loan_Closing 
				,(Case When MLD.Loan_Pay_Amount = 0 THEN LQry.Loan_Closing else LQry.Loan_Closing END) as Loan_Closing, 
				(Case When MLD.Loan_Pay_Amount = 0 THEN  ROund(isnull(Total_Loan_Int_Amount,0),0) - isnull(LA.Loan_Int_Installment_Amount,0) - isnull(Loan_Apr_Pending_Int_Amount,0)   else (Loan_apr_amount - LA.Loan_Apr_Installment_Amount - Loan_Apr_pending_amount  + Isnull(LA.Paid_Amount,0)) END) As Loan_Paid, 
				BM.Branch_ID,E.alpha_Emp_code
				,e.Emp_First_Name ,LIS.Current_installment,LIS.Total_Installment   -- Added by Gadriwala Muslim 16072015
				,dgm.Desig_Dis_No,E.SSN_No   --added jimit 01102015
				,isnull(LM.Gujarati_Alias,'') as Gujarati_Alias 
		 From	dbo.T0210_MONTHLY_LOAN_PAYMENT MLD WITH (NOLOCK) Inner join 
				  dbo.T0120_LOAN_APPROVAL LA WITH (NOLOCK) ON MLD.LOAN_APR_ID = LA.LOAN_APR_ID INNER JOIN 
				  dbo.T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.LOAN_ID = LM.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0 
				  INNER JOIN  dbo.T0080_EMP_MASTER E WITH (NOLOCK) on LA.emp_ID = E.emp_ID  Left outer  JOIN 
				#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join 
				(select I.Emp_Id , Grd_ID,Cmp_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,Band_Id from dbo.T0095_Increment I WITH (NOLOCK) inner join 
						(select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID) I_Q 
					on E.Emp_ID = I_Q.Emp_ID  inner join
						dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						dbo.tblBandMaster B WITH (NOLOCK) ON I_Q.Band_Id = B.BandId LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
						dbo.T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  Inner JOin
						dbo.T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID right outer join
						(
							SELECT	SUM(Loan_Pay_Amount) as loan_pay_amount,Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,
							MAX(Loan_Payment_Date)as for_date,T0120_LOAN_APPROVAL.Loan_Apr_Amount as Loan_amount ,
									T0120_LOAN_APPROVAL.Loan_Apr_Amount-SUM(Loan_Pay_Amount) - Sum(T0210_MONTHLY_LOAN_PAYMENT.SubSidy_Amount) as Loan_Closing
							FROM	T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) INNER JOIN T0120_LOAN_APPROVAL WITH (NOLOCK) ON T0210_MONTHLY_LOAN_PAYMENT.Loan_Apr_ID=T0120_LOAN_APPROVAL.Loan_Apr_ID						
									INNER JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) ON T0120_LOAN_APPROVAL.Loan_ID=LM.Loan_ID AND T0120_LOAN_APPROVAL.Cmp_ID=LM.Cmp_ID
							WHERE	T0210_MONTHLY_LOAN_PAYMENT.Loan_Payment_Date <= @to_date AND LM.Is_GPF = 0 and  T0210_MONTHLY_LOAN_PAYMENT.Is_Loan_Interest_Flag = 0 
							--and T0210_MONTHLY_LOAN_PAYMENT.Is_Loan_Interest_Flag = (Case WHEN T0120_LOAN_APPROVAL.Loan_Apr_Pending_Amount = 0 then 1 Else 0 END)
							GROUP BY Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,T0120_LOAN_APPROVAL.Loan_Apr_Amount
							HAVING T0120_LOAN_APPROVAL.Loan_Apr_Amount-SUM(Loan_Pay_Amount) > 0 or MAX(Loan_Payment_Date) >= @from_date
							UNION ALL
							SELECT	SUM(Loan_Pay_Amount) as loan_pay_amount,Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,MAX(Loan_Payment_Date)as for_date,(T0120_LOAN_APPROVAL.Loan_Apr_Amount + ISNULL(T0120_LOAN_APPROVAL.CF_Loan_Amt, 0)) as Loan_amount ,
									((T0120_LOAN_APPROVAL.Loan_Apr_Amount + ISNULL(T0120_LOAN_APPROVAL.CF_Loan_Amt, 0)) -SUM(Loan_Pay_Amount) -Sum(T0210_MONTHLY_LOAN_PAYMENT.SubSidy_Amount)) as Loan_Closing
							FROM	T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) INNER JOIN T0120_LOAN_APPROVAL WITH (NOLOCK) ON T0210_MONTHLY_LOAN_PAYMENT.Loan_Apr_ID=T0120_LOAN_APPROVAL.Loan_Apr_ID						
									INNER JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) ON T0120_LOAN_APPROVAL.Loan_ID=LM.Loan_ID AND T0120_LOAN_APPROVAL.Cmp_ID=LM.Cmp_ID
							WHERE	LM.Is_GPF=1 AND T0210_MONTHLY_LOAN_PAYMENT.Loan_Payment_Date <=@To_Date 
									AND T0120_LOAN_APPROVAL.Loan_Apr_ID NOT IN (SELECT LA1.CF_Loan_Apr_ID FROM T0120_LOAN_APPROVAL LA1 WITH (NOLOCK)
												INNER JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA1.Loan_ID=LM.Loan_ID AND LA1.Cmp_ID=LM.Cmp_ID
										WHERE	LA1.Cmp_ID=T0120_LOAN_APPROVAL.Cmp_ID AND LA1.Emp_ID=T0120_LOAN_APPROVAL.Emp_ID 
												AND LA1.CF_Loan_Apr_ID IS NOT NULL AND LA1.Loan_Apr_Date <= @From_date)
							GROUP BY Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,T0120_LOAN_APPROVAL.Loan_Apr_Amount,T0120_LOAN_APPROVAL.CF_Loan_Amt
							UNION ALL
							SELECT	SUM(Loan_Pay_Amount) as loan_pay_amount,Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,
							MAX(Loan_Payment_Date)as for_date,T0120_LOAN_APPROVAL.Total_Loan_Int_Amount as Loan_amount ,
									ROUND(T0120_LOAN_APPROVAL.Total_Loan_Int_Amount,0) - SUM(T0210_MONTHLY_LOAN_PAYMENT.Interest_Amount) -Sum(T0210_MONTHLY_LOAN_PAYMENT.SubSidy_Amount)
									as Loan_Closing
							FROM	T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) INNER JOIN T0120_LOAN_APPROVAL WITH (NOLOCK) ON T0210_MONTHLY_LOAN_PAYMENT.Loan_Apr_ID=T0120_LOAN_APPROVAL.Loan_Apr_ID						
									INNER JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) ON T0120_LOAN_APPROVAL.Loan_ID=LM.Loan_ID AND T0120_LOAN_APPROVAL.Cmp_ID=LM.Cmp_ID
							WHERE	T0210_MONTHLY_LOAN_PAYMENT.Loan_Payment_Date <= @To_Date AND LM.Is_GPF = 0 and  T0210_MONTHLY_LOAN_PAYMENT.Is_Loan_Interest_Flag = 1
							GROUP BY Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,T0120_LOAN_APPROVAL.Loan_Apr_Amount,T0120_LOAN_APPROVAL.Total_Loan_Int_Amount
							--HAVING ROUND(T0120_LOAN_APPROVAL.Total_Loan_Int_Amount,0) - SUM(T0210_MONTHLY_LOAN_PAYMENT.Interest_Amount) > 0					
																		
						)  as LQry on LQry.Emp_ID = ec.Emp_ID and LQry.Loan_ID = la.Loan_ID  and LQry.Loan_Apr_ID = LA.Loan_Apr_ID
							and LQry.Loan_Apr_ID = MLD.Loan_Apr_ID   -- Added by rohit on 24-11-2012
						left outer join #Loan_Installment_Status LIS on LIS.Emp_ID = LA.Emp_ID and LIS.Loan_ID = LA.Loan_ID and LIS.Loan_Apr_ID = LA.Loan_Apr_ID  -- Added by Gadriwala Muslim 16072015
						--left outer join
						--dbo.T0140_LOAN_TRANSACTION LNT on LNT.Emp_ID = ec.Emp_ID and LNT.For_Date = mld.Loan_Payment_Date and lnt.Loan_ID = lnt.Loan_ID
			WHERE E.Cmp_ID = @Cmp_Id and Loan_payment_Date >=@From_Date and Loan_payment_Date <=@To_Date
					--And not Sal_Tran_ID is null 
					And Isnull(LM.Loan_Id,0) = isnull(@Loan_Id ,Isnull(LM.Loan_Id,0))
					and isnull(mld.Sal_Tran_ID,0) <> 0 
					
			order by Loan_Pay_Amount DESC
					--LM.Loan_Id=@Loan_Id
			
		END	
	ELSE IF @Report_Type = 'Default' -- Changed By Ali 22112013 EmpName_Alias	
		BEGIN
			
			Select MLD.*,LA.Loan_Apr_Date,LA.Loan_Apr_No_of_Installment,LA.Loan_Apr_Installment_Amount,LA.Loan_Apr_Installment_Amount,E.Emp_Id,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Branch_Address,Comp_name,Grd_Name,isnull(BandName,'') as BandName,EMP_CODE,Alpha_Emp_Code,Type_Name,Dept_Name,Desig_Name,LOAN_NAME,Cmp_Name,Branch_Name
				,Loan_apr_amount,Loan_Apr_pending_amount,Cmp_Address 
				--,LNT.Loan_Closing 
				,LQry.Loan_Closing , (Loan_apr_amount - LA.Loan_Apr_Installment_Amount - Loan_Apr_pending_amount) As Loan_Paid, BM.Branch_ID,E.alpha_Emp_code			
				,e.Emp_First_Name,LIS.Current_installment,LIS.Total_Installment  -- Added by Gadriwala Muslim 16072015
				,dgm.Desig_Dis_No ,E.SSN_No  --added jimit 01102015
			 From dbo.T0210_MONTHLY_LOAN_PAYMENT MLD WITH (NOLOCK) Inner join 
				  dbo.T0120_LOAN_APPROVAL LA WITH (NOLOCK) ON MLD.LOAN_APR_ID = LA.LOAN_APR_ID INNER JOIN 
				  dbo.T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.LOAN_ID = LM.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0 
				  INNER JOIN  dbo.T0080_EMP_MASTER E WITH (NOLOCK) on LA.emp_ID = E.emp_ID  Left outer  JOIN 
				#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join 
				(select I.Emp_Id , Grd_ID,Cmp_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,Band_Id from dbo.T0095_Increment I WITH (NOLOCK) inner join 
						(select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID) I_Q 
					on E.Emp_ID = I_Q.Emp_ID  inner join
						dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						dbo.tblBandMaster B WITH (NOLOCK) ON I_Q.Band_Id = B.BandId LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
						dbo.T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  Inner JOin
						dbo.T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID right outer join
						(
						-- comment and add by rohit on 24-11-2012
						--select lnt.Loan_Closing,lnt.Emp_ID,lnt.For_Date,lnt.Loan_ID from T0140_LOAN_TRANSACTION lnt 
						--	inner join (select MAX(SLT.For_Date) as For_Date,Emp_ID,Loan_ID from T0140_LOAN_TRANSACTION SLT where SLT.For_Date <= @To_Date group by Emp_ID,Loan_ID) as qry
						--	on lnt.Emp_ID = qry.emp_id and lnt.For_Date = qry.for_date and lnt.Loan_ID = qry.loan_id
						--	and Cmp_ID= @Cmp_ID
						
						select SUM(Loan_Pay_Amount) as loan_pay_amount,Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,MAX(Loan_Payment_Date)as for_date,T0120_LOAN_APPROVAL.Loan_Apr_Amount as Loan_amount ,
							(T0120_LOAN_APPROVAL.Loan_Apr_Amount-SUM(Loan_Pay_Amount) - Sum(T0210_MONTHLY_LOAN_PAYMENT.SubSidy_Amount)) as Loan_Closing
							from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)
							inner join T0120_LOAN_APPROVAL WITH (NOLOCK) on 
							T0210_MONTHLY_LOAN_PAYMENT.Loan_Apr_ID=T0120_LOAN_APPROVAL.Loan_Apr_ID
							--where T0120_LOAN_APPROVAL.Emp_ID=59
							where T0210_MONTHLY_LOAN_PAYMENT.Loan_Payment_Date <=@To_Date
							group by Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,T0120_LOAN_APPROVAL.Loan_Apr_Amount
							-- comment ended by rohit on 24-11-2012
							
							)  as LQry on LQry.Emp_ID = ec.Emp_ID and LQry.Loan_ID = la.Loan_ID  and LQry.Loan_Apr_ID = LA.Loan_Apr_ID
							and LQry.Loan_Apr_ID=mld.Loan_Apr_ID -- Added by rohit on 24-11-2012
						left outer join #Loan_Installment_Status LIS on LIS.Emp_ID = LA.Emp_ID and LIS.Loan_ID = LA.Loan_ID and LIS.Loan_Apr_ID = LA.Loan_Apr_ID -- Added by Gadriwala Muslim 16072015
						
						--left outer join
						--dbo.T0140_LOAN_TRANSACTION LNT on LNT.Emp_ID = ec.Emp_ID and LNT.For_Date = mld.Loan_Payment_Date and lnt.Loan_ID = lnt.Loan_ID
			WHERE E.Cmp_ID = @Cmp_Id and Loan_payment_Date >=@From_Date and Loan_payment_Date <=@To_Date
					--And not Sal_Tran_ID is null 
					And Isnull(LM.Loan_Id,0) = isnull(@Loan_Id ,Isnull(LM.Loan_Id,0))
					and (isnull(mld.Sal_Tran_ID,0) <> 0 or ISNULL(MLD.Pay_Tran_ID,0) <> 0)
					--LM.Loan_Id=@Loan_Id
	
		END
	ELSE IF @Report_Type = 'Format1'
		BEGIN
			Select MLD.*,E.Emp_Id,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Branch_Address,Comp_name,Grd_Name,isnull(BandName,'') as BandName,EMP_CODE,Alpha_Emp_Code,Type_Name,Dept_Name,Desig_Name,
			LOAN_NAME,Cmp_Name,Branch_Name
				,Loan_apr_amount,Loan_Apr_pending_amount,Cmp_Address 
				--,LNT.Loan_Closing 
				,LQry.Loan_Closing , BM.Branch_ID,E.alpha_Emp_code			
			 ,e.Emp_First_Name,LIS.Current_installment,LIS.Total_Installment  -- Added by Gadriwala Muslim 16072015
			 ,dgm.Desig_Dis_No ,E.SSN_No   --added jimit 01102015
			 From dbo.T0210_MONTHLY_LOAN_PAYMENT MLD WITH (NOLOCK) Inner join 
				  dbo.T0120_LOAN_APPROVAL LA WITH (NOLOCK) ON MLD.LOAN_APR_ID = LA.LOAN_APR_ID INNER JOIN 
				  dbo.T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.LOAN_ID = LM.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0 INNER JOIN  dbo.T0080_EMP_MASTER E WITH (NOLOCK) on LA.emp_ID = E.emp_ID  Left outer  JOIN 
				#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join 
				(select I.Emp_Id , Grd_ID,Cmp_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,Band_Id from dbo.T0095_Increment I WITH (NOLOCK) inner join 
						(select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID) I_Q 
					on E.Emp_ID = I_Q.Emp_ID  inner join
						dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						dbo.tblBandMaster B WITH (NOLOCK) ON I_Q.Band_Id = B.BandId LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
						dbo.T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  Inner JOin
						dbo.T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID right outer join
						(
						-- comment and add by rohit on 24-11-2012
						--select lnt.Loan_Closing,lnt.Emp_ID,lnt.For_Date,lnt.Loan_ID from T0140_LOAN_TRANSACTION lnt 
						--	inner join (select MAX(SLT.For_Date) as For_Date,Emp_ID,Loan_ID from T0140_LOAN_TRANSACTION SLT where SLT.For_Date <= @To_Date group by Emp_ID,Loan_ID) as qry
						--	on lnt.Emp_ID = qry.emp_id and lnt.For_Date = qry.for_date and lnt.Loan_ID = qry.loan_id
						--	and Cmp_ID= @Cmp_ID
						
						select SUM(Loan_Pay_Amount) as loan_pay_amount,Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,MAX(Loan_Payment_Date)as for_date,T0120_LOAN_APPROVAL.Loan_Apr_Amount as Loan_amount ,
							(T0120_LOAN_APPROVAL.Loan_Apr_Amount-SUM(Loan_Pay_Amount)) as Loan_Closing
							from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)
							inner join T0120_LOAN_APPROVAL WITH (NOLOCK) on 
							T0210_MONTHLY_LOAN_PAYMENT.Loan_Apr_ID=T0120_LOAN_APPROVAL.Loan_Apr_ID
							--where T0120_LOAN_APPROVAL.Emp_ID=59
							where T0210_MONTHLY_LOAN_PAYMENT.Loan_Payment_Date <=@To_Date
							group by Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,T0120_LOAN_APPROVAL.Loan_Apr_Amount
							-- comment ended by rohit on 24-11-2012
							
							)  as LQry on LQry.Emp_ID = ec.Emp_ID and LQry.Loan_ID = la.Loan_ID 
							and LQry.Loan_Apr_ID=mld.Loan_Apr_ID -- Added by rohit on 24-11-2012
						LEFT OUTER JOIN #Loan_Installment_Status LIS on LIS.Emp_ID = LA.Emp_ID and LIS.Loan_ID = LM.Loan_ID and LIS.Loan_Apr_ID = LA.Loan_Apr_ID   -- Added by Gadriwala Muslim 16072015
						--left outer join
						--dbo.T0140_LOAN_TRANSACTION LNT on LNT.Emp_ID = ec.Emp_ID and LNT.For_Date = mld.Loan_Payment_Date and lnt.Loan_ID = lnt.Loan_ID
			WHERE E.Cmp_ID = @Cmp_Id and Loan_payment_Date >=@From_Date and Loan_payment_Date <=@To_Date
					--And not Sal_Tran_ID is null 
					And Isnull(LM.Loan_Id,0) = isnull(@Loan_Id ,Isnull(LM.Loan_Id,0))
					and isnull(mld.Sal_Tran_ID,0) <> 0
					--LM.Loan_Id=@Loan_Id
		END														
		
		ELSE IF @Report_Type = 'Yearly Loan Report'
		BEGIN
	
	
		--=========================================================================================================================



				Select distinct MLD.Emp_ID,Max(MLD.For_Date)as For_Date
					into #Advance_Pending
					From T0140_ADVANCE_TRANSACTION MLD WITH (NOLOCK) Inner join      
						 T0080_Emp_master E WITH (NOLOCK) on MLD.Emp_ID =E.Emp_ID left OUTER join
						 --Added By Jaina 26-10-2015 Start
						 T0100_ADVANCE_PAYMENT AP WITH (NOLOCK) ON AP.For_Date = MLD.For_Date and AP.Emp_ID=MLD.Emp_ID left OUTER JOIN
						 T0090_ADVANCE_PAYMENT_APPROVAL APA WITH (NOLOCK) ON APA.Application_Date = MLD.For_Date and MLD.Emp_ID=APA.Emp_ID left OUTER JOIN
						 T0040_Reason_Master R WITH (NOLOCK) ON R.Res_Id=IsNull(AP.Res_Id, APA.Res_Id)	--For Admin Advance Payment
						 
						 INNER JOIN
						 --Added By Jaina 26-10-2015 End
  							(select distinct I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Cmp_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
									( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
								on E.Emp_ID = I_Q.Emp_ID  inner join
									T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
									T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
									T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
									T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
									T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  inner join
									T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID 
						WHERE		E.Cmp_ID = @Cmp_Id and  MLD.For_Date >=@From_Date and MLD.For_Date <=@To_Date 
									And E.Emp_Id In (Select Emp_Id From #Emp_Cons) 
									And ( Adv_Issue>0 Or Adv_return >0)
									group  by MLD.Emp_ID--,MLD.Adv_Closing

									

--select * from #Advance_Pending
--return

		SELECT 
    T1.* into #T0140_ADVANCE_TRANSACTION
FROM
    T0140_ADVANCE_TRANSACTION T1
WHERE
    T1.For_Date = (SELECT 
            MAX(t2.For_Date)
        FROM
            T0140_ADVANCE_TRANSACTION T2
        WHERE
            T2.Emp_id = T1.Emp_id and  t1.Adv_Closing!= 0);
		
			--select * from #T0140_ADVANCE_TRANSACTION
			--return
			
		Select distinct 
		--ROW_NUMBER() OVER(PARTITION BY cm.cmp_id ORDER BY MLD.Emp_id ASC) as Rno
		(select Alpha_Emp_Code from T0080_emp_Master Where emp_id=MLD.Emp_ID and Cmp_ID=@Cmp_ID) as Alpha_Emp_Code
		,(select Emp_Full_Name from T0080_emp_Master Where emp_id=MLD.Emp_ID and Cmp_ID=@Cmp_ID) as Emp_Full_Name
		,Dm.Dept_Name
		,0 as Loan_Pending_Amount
		,MLD.Adv_Closing
		--(select top 1 Adv_Closing from  T0140_ADVANCE_TRANSACTION where Emp_id=MLD.Emp_ID order by 1 desc)
		,0 as 'Total Pending Amount'
		,cm.Cmp_Id
		,cm.Cmp_Name
		,cm.Cmp_Address
		--,MLD.For_Date as 'For Date'
		,@From_Date as 'For Date'
		,@To_Date as 'To Date'
		,MLD.Emp_ID as Emp_ID
		
					into #Advance_Pending1
					From #T0140_ADVANCE_TRANSACTION MLD WITH (NOLOCK) Inner join 
					
						 T0080_Emp_master E WITH (NOLOCK) on MLD.Emp_ID =E.Emp_ID left OUTER join
						 --Added By Jaina 26-10-2015 Start
						 T0100_ADVANCE_PAYMENT AP WITH (NOLOCK) ON AP.For_Date = MLD.For_Date and AP.Emp_ID=MLD.Emp_ID left OUTER JOIN
						 T0090_ADVANCE_PAYMENT_APPROVAL APA WITH (NOLOCK) ON APA.Application_Date = MLD.For_Date and MLD.Emp_ID=APA.Emp_ID left OUTER JOIN
						 T0040_Reason_Master R WITH (NOLOCK) ON R.Res_Id=IsNull(AP.Res_Id, APA.Res_Id)	--For Admin Advance Payment
						 
						 INNER JOIN
						 --Added By Jaina 26-10-2015 End
  							(select distinct I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Cmp_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
									( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
								on E.Emp_ID = I_Q.Emp_ID  inner join

									T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
									T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
									T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
									T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
									T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  inner join
									T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID 
									inner join #Advance_Pending AP1 WITH (NOLOCK) on Ap1.For_Date=MLD.For_Date 
									--inner join #Advance_Pending AP1 WITH (NOLOCK) on Ap1.For_Date=(select Max(For_date) from T0140_ADVANCE_TRANSACTION where emp_id=81 and Adv_Closing!=0 )
						WHERE		E.Cmp_ID = @Cmp_Id and  MLD.For_Date >=@From_Date and MLD.For_Date <=@To_Date 
									And E.Emp_Id In (Select Emp_Id From #Emp_Cons) 
									And ( Adv_Issue>0 Or Adv_return >0)
									--and MLD.For_Date=(select Max(For_Date) from T0140_ADVANCE_TRANSACTION where Cmp_Id=@Cmp_ID and Emp_ID=@Emp_ID)
									
									group  by MLD.Emp_ID
									,Dm.Dept_Name,cm.Cmp_Id,cm.Cmp_Name,cm.Cmp_Address,MLD.Adv_Closing
		----,cm.Cmp_Id
		----,cm.Cmp_Name
		----,cm.Cmp_Address
		----,MLD.For_Date as 'For Date'
		----,@From_Date 
		----,@To_Date 
		--,MLD.Emp_ID
									--,MLD.Adv_Closing

								
									
									
										select distinct ROW_NUMBER() OVER(PARTITION BY Cmp_Name ORDER BY Emp_id ASC) as Rno,* into #Pending_Advance from #Advance_Pending1 group  by Emp_ID
									,Dept_Name,Cmp_Id,Cmp_Name,Cmp_Address,Adv_Closing,Alpha_Emp_Code,Emp_Full_Name,Loan_Pending_Amount,[Total Pending Amount],[For Date],[To Date]
			
	--================================================================================================================================================================================================
		
		--=======================================
		 select   distinct
		 
		 E.alpha_Emp_code as Alpha_Emp_code ,e.Emp_full_Name
		 ,DM.Dept_Name
		
		 ,Sum(LQry.Loan_Closing) as Loan_Pending_Amount
		 --,ap1.Adv_Closing
		  ,0 as Adv_Closing
		 --,(isnull(Sum(LQry.Loan_Closing),0)+ isnull(ap1.Adv_Closing,0))as 'Total Pending Amount'
		 ,0 as 'Total Pending Amount'
		 ,cm.Cmp_Id
		 ,cm.Cmp_Name
		,cm.Cmp_Address
		,@From_Date as 'From Date',
		@To_Date as 'To Date'
		,E.Emp_id
		--(select distinct Emp_ID from T0080_emp_Master Where Alpha_Emp_Code=E.alpha_Emp_code and Cmp_Id=@Cmp_ID) as Emp_id
			into #LOANDATA
			from 
				(
					select distinct SUM(Loan_Pay_Amount) as loan_pay_amount,Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,Loan_Apr_Date as for_date,T0120_LOAN_APPROVAL.Loan_Apr_Amount as Loan_amount ,T0120_LOAN_APPROVAL.Loan_Apr_Installment_Amount,
						(T0120_LOAN_APPROVAL.Loan_Apr_Amount-SUM(ISNULL(Loan_Pay_Amount,0))) as Loan_Closing
						from T0120_LOAN_APPROVAL WITH (NOLOCK)
						left join 
						T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)  on 
						T0210_MONTHLY_LOAN_PAYMENT.Loan_Apr_ID=T0120_LOAN_APPROVAL.Loan_Apr_ID
						
						where Isnull(T0210_MONTHLY_LOAN_PAYMENT.Loan_Payment_Date,@To_Date) <= @To_Date and -- Uncommented by Rajput 12072017 - (Guide by Nimesh bhai) Due to Pending Loan Detail in Customized Report Wrong Generate(Mentis Error ID - 0006372 )    
							T0120_LOAN_APPROVAL.Loan_Apr_Date <=@To_Date
							
						group by Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,T0120_LOAN_APPROVAL.Loan_Apr_Amount,Loan_Apr_Date , T0120_LOAN_APPROVAL.Loan_Apr_Installment_Amount
												) LQry inner join
												 dbo.T0040_LOAN_MASTER LM WITH (NOLOCK) ON LQry.LOAN_ID = LM.LOAN_ID 
												 INNER JOIN  dbo.T0080_EMP_MASTER E WITH (NOLOCK) on LQry.emp_ID = E.emp_ID
												 Left outer  JOIN		#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID 
												 inner join 
								(select distinct I.Emp_Id , Grd_ID,Cmp_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from dbo.T0095_Increment I WITH (NOLOCK)
								inner join 
										(select distinct max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
										where Increment_Effective_date <= @To_Date
										and Cmp_ID = @Cmp_ID
										group by emp_ID) Qry on
										I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id) I_Q  --Changed by Hardik 09/09/2014 for Same Date Increment
				on E.Emp_ID = I_Q.Emp_ID  inner join
				
					dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
					dbo.T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  Inner JOin
					dbo.T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID inner join
					#Emp_Cons ECM on ECM.emp_id = LQry.emp_id
					--inner join #Advance_Pending Ap on ap.Emp_ID=LQry.emp_id
					--left outer join #Advance_Pending1 AP1 on Ap1.Alpha_Emp_Code=E.alpha_Emp_code
					WHERE E.Cmp_ID = @Cmp_Id 
				and LQry.for_date <=@To_Date
				And Isnull(LM.Loan_Id,0) = isnull(@Loan_Id ,Isnull(LM.Loan_Id,0))
				and LQry.loan_closing > 0 --and  Alpha_Emp_code not in (Select Alpha_Emp_Code from #Advance_Pending1)
				group by E.alpha_Emp_code,e.Emp_full_Name,DM.Dept_Name,cm.Cmp_Id,cm.Cmp_name,cm.Cmp_Address,E.Emp_id--,Ap1.Alpha_Emp_Code,ap1.Adv_Closing--,LM.LOAN_NAME

			--select * from #LOANDATA
		--return

				
		select ROW_NUMBER() OVER(PARTITION BY cmp_Name ORDER BY @From_Date ASC) as Rno,* into #LOAN_Data from #LOANDATA --here   Alpha_Emp_Code not in (select Alpha_Emp_code from #Pending_Advance)
						
		
	--=========================================================================================================================
		END	
		

		if exists(select distinct Emp_id from #LOAN_Data where Cmp_Id=@Cmp_ID and Emp_id in (select Emp_id from #Emp_Cons) )
		begin
		--select PA.alpha_Emp_code,PA.Emp_full_Name,PA.Dept_Name,PA.Loan_Pending_Amount,PA.Adv_Closing,0 as [Total Pending Amount],PA.Cmp_Name,LD.Cmp_Address,PA.[For Date] as 'From Date',PA.[To Date] from #Pending_Advance PA Left outer join #LOAN_Data LD on LD.emp_id=PA.Emp_ID where PA.Alpha_Emp_Code not in (select LD.alpha_Emp_code  from #LOAN_Data LD Left outer join #Pending_Advance PA on LD.emp_id=PA.Emp_ID)
		
		select distinct LD.alpha_Emp_code,LD.Emp_full_Name,LD.Dept_Name,LD.Loan_Pending_Amount,PA.Adv_Closing
		,(isnull(Sum(LD.Loan_Pending_Amount),0)+ isnull(PA.Adv_Closing,0)) as [Total Pending Amount],LD.Cmp_Name,LD.Cmp_Address,LD.[From Date],LD.[To Date] from #LOAN_Data LD Left outer join #Pending_Advance PA on LD.emp_id=PA.Emp_ID
		where LD.Loan_Pending_Amount>0
		group by LD.alpha_Emp_code,LD.Emp_full_Name,LD.Dept_Name,LD.Loan_Pending_Amount,PA.Adv_Closing,LD.[Total Pending Amount],LD.Cmp_Name,LD.Cmp_Address,LD.[From Date],LD.[To Date]

		--select * from #A
		union all

		select distinct PA.alpha_Emp_code,PA.Emp_full_Name,PA.Dept_Name,PA.Loan_Pending_Amount,PA.Adv_Closing,(isnull(Sum(PA.Loan_Pending_Amount),0)+ isnull(PA.Adv_Closing,0)) as [Total Pending Amount],PA.Cmp_Name,PA.Cmp_Address,PA.[For Date] as 'From Date',PA.[To Date] from #Pending_Advance PA Left outer join #LOAN_Data LD on LD.emp_id=PA.Emp_ID
		where PA.Alpha_Emp_Code not in
		(select distinct LD.alpha_Emp_code from #LOAN_Data LD Left outer join #Pending_Advance PA on LD.emp_id=PA.Emp_ID) and Pa. Adv_Closing>0 
		group by PA.alpha_Emp_code,PA.Emp_full_Name,PA.Dept_Name,PA.Loan_Pending_Amount,PA.Adv_Closing,pa.Loan_Pending_Amount,PA.Cmp_Name,PA.Cmp_Address,pa.[For Date],pa.[To Date]

		
		end
		else
		begin
			
		select PA.alpha_Emp_code,PA.Emp_full_Name,PA.Dept_Name,PA.Loan_Pending_Amount,PA.Adv_Closing,(isnull(Sum(PA.Loan_Pending_Amount),0)+ isnull(PA.Adv_Closing,0)) as [Total Pending Amount],PA.Cmp_Name,PA.Cmp_Address,PA.[For Date] as 'From Date',PA.[To Date] from #Pending_Advance PA Left outer join #LOAN_Data LD on LD.emp_id=PA.Emp_ID
		where Pa. Adv_Closing>0 
		group by PA.alpha_Emp_code,PA.Emp_full_Name,PA.Dept_Name,PA.Loan_Pending_Amount,PA.Adv_Closing,pa.Loan_Pending_Amount,PA.Cmp_Name,PA.Cmp_Address,pa.[For Date],pa.[To Date]
		

		end
		return
		
RETURN
