

CREATE PROCEDURE [dbo].[Get_Salary_Settlement_Amount]
 @Company_Id		numeric
,@From_Date		datetime
,@To_Date		datetime 
,@Branch_ID		numeric   = 0
,@Cat_ID		numeric  = 0
,@Grade_ID		numeric = 0
,@Type_ID		numeric  = 0
,@Dept_ID		numeric  = 0
,@Desig_ID		numeric = 0
,@Emp_ID		numeric  = 0
,@Constraint	varchar(max) = ''
,@Sal_Type    numeric
,@Salary_Cycle_id numeric = 0
 ,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 21082013
 ,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013
 ,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 21082013	
 ,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013	
 ,@flag numeric = 0	
AS
	    SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
	
	Declare @Payement varchar(50) 
	Declare @Transaction_ID Numeric
	
	set @Payement = ''
	set @Transaction_ID=0
	
	 if isnull(@Payement,'') = ''
		set  @Payement = ''
		
	Declare @Row_id as numeric
	Declare @Label_Name as varchar(100)
	Declare @Total_Allowance as numeric(22,2) 
	Declare @Is_Search as varchar(30)
	Declare @Basic_salary as numeric(22,2)
	Declare @Total_Allow as numeric (22,2)
	declare @Value_String as varchar(250)
	Declare @Amount as numeric (22,2)

	Declare @OTher_Allow as numeric(22,2)
	Declare @CO_Amount as numeric(22,2)
	Declare @Total_Deduction as numeric(22,2)
	Declare @Other_Dedu as numeric(22,2)
	Declare @Loan as numeric(22,2)
	Declare @Advance as numeric(22,2)
	Declare @Net_Salary as numeric(22,2)
	Declare @Revenue_amt numeric(10)
	Declare @Lwf_amt numeric(10)
	Declare @PT as numeric(22,2)
	Declare @LWF as numeric(22,2)
	Declare @Revenue as numeric(22,2)
	Declare @Allow_Name as varchar(100)
	Declare @P_Days as numeric(22,2)
	Declare @A_Days as numeric(22,2)
	Declare @Act_Gross_salary as numeric(18,2)
	DEclare @month as numeric(18,0)
	Declare @Year as numeric(18,0)
	Declare @S_Eff_Date datetime
	DEclare @For_Date as datetime
	Declare @TDS numeric(18,2)
	Declare @Gross_salary as numeric(18,2)
	
	CREATE table #Temp_report_Label
	(
	Row_ID  numeric(18, 0) NOt null,
	Label_Name  varchar(200) not null,
	Income_Tax_ID numeric(18, 0) null,
	Is_Active	varchar(1) null
	)
		
	CREATE table #Temp_Salary_Muster_Report		
	(
	Emp_ID numeric(18, 0) Not Null,
	Cmp_ID numeric(18, 0) Not Null,
	Transaction_ID numeric(18, 0) Not Null,
	Month numeric(18, 0) Not Null,
	Year numeric(18, 0) Not Null,
	Label_Name varchar(200) Not Null,
	Amount numeric(18, 2) null,
	Value_String varchar(250) Not Null,
	INCOME_TAX_ID numeric(18, 0)  Null,
	Row_id numeric(18, 0) Null,
	S_Eff_Month numeric(18, 0)  Null,
	S_Eff_Year numeric(18, 0) Null
	
	)
		
	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
		 
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grade_ID = 0
		set @Grade_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
	if @Salary_Cycle_id = 0
		set @Salary_Cycle_id = NULL
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubBranch_Id = null	
		
	DECLARE @S_month numeric
	set @month = month(@to_Date)
	set @Year = Year(@to_Date)
	set @S_month =MONTH(@From_Date)
	  
	EXEC Set_Salary_register_Lable_Settlement @Company_Id ,@month , @Year
	
	CREATE TABLE #Emp_Cons -- Ankit 05092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Company_Id,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
	 
	--Declare #Emp_Cons Table
	--	(
	--		Emp_ID	numeric
	--	)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else 
	--	begin
	--		Insert Into #Emp_Cons

	--		select I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Company_Id
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
	--		Where Cmp_ID = @Company_Id 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grade_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--		and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--		and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 21082013
	--		and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 21082013
            
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Company_Id   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @From_Date <= left_date ) 
	--	end
	
	DECLARE @S_Sal_Tran_ID NUMERIC	--Ankit 18022016
	SET @S_Sal_Tran_ID = 0	
	
	--commented By Mukti(25062016)start		
		--DECLARE CUR_EMP CURSOR FOR			
		--	SELECT sg.EMP_ID,sg.S_Month_End_Date,SG.S_Sal_Tran_ID  FROM T0201_MONTHLY_SALARY_SETT SG INNER JOIN
		--		T0080_EMP_MASTER E ON sg.EMP_ID =e.EMP_ID 
		--		INNER JOIN /*	EMP_OTHER_DETAIL eod ON e.EMP_ID = eod.EMP_ID Inner join*/ #Emp_Cons ec on E.Emp_ID = Ec.Emp_ID  
		--		--Inner join ( select T0095_Increment.Emp_Id ,Type_ID ,Grd_ID,Dept_ID,Desig_Id,Branch_ID,Cat_ID,Payment_Mode from t0095_Increment inner join 
		--		--								( select max(Increment_ID) as Increment_ID , Emp_ID from t0095_Increment
		--		--								where Increment_Effective_date <= @To_Date
		--		--								and Cmp_ID = @Company_Id
		--		--								group by emp_ID  ) Qry
		--		--								on t0095_Increment.Emp_ID = Qry.Emp_ID and
		--		--								t0095_Increment.Increment_ID   = Qry.Increment_ID	
		--		--						where Cmp_ID = @Company_Id ) I_Q on 
		--		--				e.Emp_ID = I_Q.Emp_ID
		--	WHERE  sg.Cmp_ID = @Company_Id AND Month(sg.S_Eff_Date) = @MONTH AND Year(sg.S_Eff_Date) = @YEAR 
			--AND Payment_Mode LIKE isnull(@PAYEMENT,Payment_Mode)
	--commented By Mukti(25062016)end	
	
	--Added By Mukti(25062016)start	
	
		
				
		if(@flag=0)--For Admin side to show all salary.		
			BEGIN
				
				DECLARE CUR_EMP CURSOR FOR	
				SELECT sg.EMP_ID,sg.S_Month_End_Date,SG.S_Sal_Tran_ID,month(sg.S_Month_End_Date)  FROM T0201_MONTHLY_SALARY_SETT SG WITH (NOLOCK)
					INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON sg.EMP_ID =e.EMP_ID 
					INNER JOIN #Emp_Cons ec on E.Emp_ID = Ec.Emp_ID  					
				WHERE  sg.Cmp_ID = @Company_Id AND Month(sg.S_Month_End_Date) between @S_month and @MONTH AND Year(sg.S_Month_End_Date) = @YEAR 
				
			END
		else			
			BEGIN	
				DECLARE CUR_EMP CURSOR FOR
				SELECT sg.EMP_ID,sg.S_Month_End_Date,SG.S_Sal_Tran_ID,month(sg.S_Month_End_Date)  FROM T0201_MONTHLY_SALARY_SETT SG WITH (NOLOCK)
						INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON sg.EMP_ID =e.EMP_ID 
						INNER JOIN #Emp_Cons ec on E.Emp_ID = Ec.Emp_ID  
						INNER JOIN T0250_SALARY_PUBLISH_ESS SPE WITH (NOLOCK) ON SG.Emp_ID=SPE.Emp_ID AND SPE.Cmp_ID=SG.Cmp_ID and SPE.[Month]=Month(SG.S_Month_End_Date) and SPE.[Year]=Year(SG.S_Month_End_Date) AND SPE.Sal_Type='Settlement' and SPE.Is_Publish =1	
				WHERE  sg.Cmp_ID = @Company_Id AND Month(sg.S_Month_End_Date) between @S_month and @MONTH AND Year(sg.S_Month_End_Date) = @YEAR
				--and SPE.Is_Publish = (case when @flag =1 then 1 else SPE.Is_Publish end)	 
			END						
	--Added By Mukti(25062016)end
	OPEN  CUR_EMP
	FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@S_Eff_Date,@S_Sal_Tran_ID,@month
	WHILE @@FETCH_STATUS = 0
		BEGIN
						
						SET @Allow_Name = ''
						SET @Row_id  = 0
						SET @Label_Name  = ''
						SET @Total_Allowance = 0
						SET @Is_Search = ''
						SET @Basic_salary = 0
						SET @Total_Allow = 0
						SET @Value_String = ''
						SET @Amount = 0 
						SET @OTher_Allow =0
						set @CO_Amount = 0
						SET @Total_Deduction =0
						SET @Other_Dedu =0
						SET @Loan =0
						SET @Advance =0
						SET @Net_Salary =0
						SET @PT =0
						SET @LWF =0
						SET @Revenue = 0
						set @P_Days = 0
						Set @A_Days=0
						set @Revenue_amt =0
						set @Lwf_amt  =0
						set @Act_Gross_salary = 0
						set @TDS=0
						Set @Gross_salary = 0
						
					
					--select @P_Days = Present_Days + Holiday_Days , @Basic_Salary = Salary_Amount from Salary_Generation where Emp_ID = @Emp_ID and Month = @Month and Year = @Year
					select @P_Days = isnull(S_Sal_cal_Days,0) , @Basic_Salary = S_Salary_Amount, @Act_Gross_salary = S_Actually_Gross_salary,@TDS=S_M_IT_TAX, @Gross_salary = S_Gross_Salary 
					from T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) 
					where Emp_ID = @Emp_ID 
						AND Month(@S_Eff_Date) = MONTH(s_Month_End_Date) and Year(@S_Eff_Date) = year(s_Month_End_Date)
						AND Month(s_Month_End_Date)= @MONTH AND Year(s_Month_End_Date) = @YEAR	---- Same Month Sett. Ankit 05122015
					
										
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,S_Eff_Month,S_Eff_Year)
					VALUES     (@Emp_ID, @Company_Id, @Transaction_ID, @Month, @Year, 'P_Days', @P_Days,'',2,Month(@S_Eff_Date),Year(@S_Eff_Date))
					
					/*INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,S_Eff_Month,S_Eff_Year)
					VALUES     (@Emp_ID, @Company_Id, @Transaction_ID, @Month, @Year, 'TDS', @TDS,'',3,Month(@S_Eff_Date),Year(@S_Eff_Date))*/
					
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,S_Eff_Month,S_Eff_Year)
					VALUES     (@Emp_ID, @Company_Id, @Transaction_ID, @Month, @Year, 'Basic', @Basic_Salary,'',5,Month(@S_Eff_Date),Year(@S_Eff_Date))
				
					
					
					Declare Cur_Label cursor for 
					SELECT Label_Name ,Row_ID FROM #TEMP_REPORT_LABEL where Row_ID > 5
					open Cur_label
					fetch next from Cur_label into @Label_Name ,@Row_ID
					while @@fetch_Status = 0
						begin
							
							INSERT INTO #Temp_Salary_Muster_Report
							(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,S_Eff_Month,S_Eff_Year)
							VALUES     (@Emp_ID, @Company_Id, @Transaction_ID, @Month, @Year, @Label_Name, 0,'',@Row_ID,Month(@S_Eff_Date),Year(@S_Eff_Date))
							fetch next from Cur_label into @Label_Name,@Row_ID
						end
					close Cur_Label
					deallocate Cur_Label
					
				
					--set @Label_Name  = ''
							
					
						declare Cur_Allow   cursor for
						select Ad_Sort_Name ,M_Ad_Amount,MAD.To_date from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.Sal_Tran_ID=MSS.Sal_Tran_ID and MAD.S_Sal_Tran_ID = MSS.S_Sal_Tran_ID inner join ----and MAD.S_Sal_Tran_ID = MSS.S_Sal_Tran_ID	--Ankit 05122015
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
							MAD.Cmp_ID = @Company_Id and month(MSS.S_Month_End_Date) =  @Month and Year(MSS.S_Month_End_Date) = @Year
							and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I' And sal_type=1
							and MAD.S_Sal_Tran_ID = @S_Sal_Tran_ID		--Ankit 18022016
					open cur_allow
					fetch next from cur_allow  into @Allow_Name ,@Amount,@For_Date
					while @@fetch_status = 0
						begin
							
							select @Row_ID = Row_ID from #Temp_report_label where Label_Name like @Allow_Name 
							
 							UPDATE    #Temp_Salary_Muster_Report
 							SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
 												  Amount = @Amount, Value_String = ''--,S_eff_Month=Month(@S_Eff_Date),S_eff_year=Year(@S_Eff_Date)
 							where   Label_Name = @Allow_Name and Row_id = @row_Id and   S_eff_Month = Month(@For_Date) and S_eff_year=Year(@For_Date)               
 									and Emp_ID = @Emp_ID  
							fetch next from cur_allow  into @Allow_Name,@Amount,@For_Date
						end
					close cur_Allow
					deallocate Cur_Allow
					
															
					------------REIMBURSEMENT Allowance not effect on salary----------
					declare Cur_Allow_Rem   cursor for
						
						select Ad_Sort_Name ,M_Ad_Amount,MAD.To_date from t0210_monthly_ad_detail MAD WITH (NOLOCK)inner join
							T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.Sal_Tran_ID=MSS.Sal_Tran_ID and MAD.S_Sal_Tran_ID = MSS.S_Sal_Tran_ID inner join ----and MAD.S_Sal_Tran_ID = MSS.S_Sal_Tran_ID	--Ankit 05122015
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
							MAD.Cmp_ID = @Company_Id and month(MSS.S_Month_End_Date) =  @Month and Year(MSS.S_Month_End_Date) = @Year
							and Ad_Active = 1 
							and MAD.S_Sal_Tran_ID = @S_Sal_Tran_ID		
							AND MAD.M_AD_NOT_EFFECT_SALARY=1 and t0050_ad_master.Allowance_Type='R'	
						union ALL					
						select Ad_Sort_Name ,M_Ad_Amount,MAD.To_date from t0210_monthly_ad_detail MAD WITH (NOLOCK)inner join
							T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.Sal_Tran_ID=MSS.Sal_Tran_ID and MAD.S_Sal_Tran_ID = MSS.S_Sal_Tran_ID inner join ----and MAD.S_Sal_Tran_ID = MSS.S_Sal_Tran_ID	--Ankit 05122015
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
							
						where 
							MAD.Cmp_ID = @Company_Id and month(MSS.S_Month_End_Date) =  @Month and Year(MSS.S_Month_End_Date) = @Year
							and Ad_Active = 1 
							and MAD.S_Sal_Tran_ID = @S_Sal_Tran_ID		
							AND MAD.M_AD_NOT_EFFECT_SALARY=1 and t0050_ad_master.Allowance_Type='A'
					open Cur_Allow_Rem
					fetch next from Cur_Allow_Rem  into @Allow_Name ,@Amount,@For_Date
					while @@fetch_status = 0
						begin
							
							select @Row_ID = max(Row_ID)+1 from #Temp_report_label
							
 						INSERT INTO #Temp_Salary_Muster_Report
							(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,S_Eff_Month,S_Eff_Year)
						VALUES     (@Emp_ID, @Company_Id, @Transaction_ID, @Month, @Year, @Allow_Name, @Amount,'',@Row_ID,Month(@S_Eff_Date),Year(@S_Eff_Date))
							fetch next from Cur_Allow_Rem  into @Allow_Name,@Amount,@For_Date
						end
					close Cur_Allow_Rem
					deallocate Cur_Allow_Rem
					-----------------------------------------------------
					
					--select * from #Temp_report_Label
												
					declare CUR_REIMB   cursor for
 						SELECT DISTINCT RIMB_NAME FROM T0100_RIMBURSEMENT_DETAIL WITH (NOLOCK) INNER JOIN
						T0055_REIMBURSEMENT WITH (NOLOCK) ON T0055_REIMBURSEMENT.RIMB_ID = T0100_RIMBURSEMENT_DETAIL.RIMB_ID AND
						T0055_REIMBURSEMENT.Cmp_ID = T0055_REIMBURSEMENT.Cmp_ID
						WHERE T0100_RIMBURSEMENT_DETAIL.Cmp_ID =@Company_Id
							AND month(T0100_RIMBURSEMENT_DETAIL.For_Date) = @MONTH
							AND year(T0100_RIMBURSEMENT_DETAIL.For_Date) = @YEAR
							AND T0100_RIMBURSEMENT_DETAIL.EMP_ID = @EMP_ID
							
					open CUR_REIMB
					fetch next from CUR_REIMB into @Allow_Name
					while @@fetch_status = 0
						begin
							
							select @Row_ID = Row_ID from #Temp_report_label where Label_Name like @Allow_Name 

							UPDATE    #Temp_Salary_Muster_Report
							SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											 Amount = @Amount, Value_String = '' ,S_eff_Month=Month(@S_Eff_Date),S_eff_year=Year(@S_Eff_Date)
							where   Label_Name = @Allow_Name and Row_id = @row_Id and   S_eff_Month = Month(@S_Eff_Date) and S_eff_year=Year(@S_Eff_Date)                   
									and Emp_ID = @Emp_ID
							fetch next from CUR_REIMB into @Allow_Name,@AMOUNT
						end
					close CUR_REIMB
					deallocate CUR_REIMB
						
					
						select @Total_Allowance = S_Allow_Amount ,@Other_Allow  = S_Other_Allow_Amount  
							--@CO_Amount = isnull(Extra_Days_Amount,0)
						from T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) 
						where Emp_ID = @Emp_ID and Month(@S_eff_Date) = Month(s_Month_End_Date) and Year(@S_eff_Date) = Year(s_Month_End_Date)
								and S_Sal_Tran_ID = @S_Sal_Tran_ID		--Ankit 18022016
					 	
					 	
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Oth A'		

						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Other_Allow, Value_String = ''--,S_eff_Month=Month(@S_Eff_Date),S_eff_year=Year(@S_Eff_Date)
						where   Label_Name = 'Oth A' and Row_id = @row_Id  and   S_eff_Month = Month(@S_Eff_Date) and S_eff_year=Year(@S_Eff_Date)                  
								and Emp_ID = @Emp_ID

						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'CO A'		

						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @CO_Amount, Value_String = '',S_eff_Month=Month(@S_Eff_Date),S_eff_year=Year(@S_Eff_Date)
						where   Label_Name = 'CO A' and Row_id = @row_Id  and   S_eff_Month = Month(@S_Eff_Date) and S_eff_year=Year(@S_Eff_Date)                  
								and Emp_ID = @Emp_ID
								
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Gross'

						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Gross_salary, Value_String = ''--,S_eff_Month=Month(@S_Eff_Date),S_eff_year=Year(@S_Eff_Date)
						WHERE     (Label_Name = 'Gross') AND (Row_id = @Row_ID) and   S_eff_Month = Month(@S_Eff_Date) and S_eff_year=Year(@S_Eff_Date)
								  and Emp_ID = @Emp_ID

						/*select @Amount = M_Ad_Calculated_Amount From t0210_monthly_ad_detail where Emp_Id =@Emp_ID and Month(For_Date)=  @month and YEar(For_Date) = @Year and Ad_ID =2
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'PF Salary'	*/	
					
						
						/*UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Amount, Value_String = ''
						where   Label_Name = 'PF Salary' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
								*/
						set @Amount =0

						/*select @Amount = M_AD_Calculated_Amount From t0210_monthly_ad_detail where Emp_Id = @Emp_ID and Month(For_Date)=  @month and YEar(For_Date) = @Year and Ad_ID =3 and M_Ad_Amount >0
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'ESIC Salary'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Amount, Value_String = ''
						where   Label_Name = 'ESIC Salary' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID*/

															
					declare Cur_Dedu   cursor for
						select Ad_Sort_Name ,M_Ad_Amount,mad.To_date from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.sal_Tran_id = MSS.Sal_Tran_id inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Company_Id and Month(MSS.S_Month_End_Date) =  @Month and Year(MSS.S_Month_End_Date) = @Year
						and Ad_Active = 1 and AD_Flag = 'D' and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0)=0 And sal_Type=1
						and MAD.S_Sal_Tran_ID = @S_Sal_Tran_ID		--Ankit 18022016
						
					open Cur_Dedu
					fetch next from cur_DEDU  into @Allow_Name ,@Amount,@For_Date
					while @@fetch_status = 0
						begin
							--if @Allow_Name = 'PF'
							--SELECT @Allow_Name ,@Amount,@For_Date
						
							select @Row_ID = Row_ID from #Temp_report_label where Label_Name like @Allow_Name 
							
							UPDATE    #Temp_Salary_Muster_Report
							SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Amount, 
												  Value_String = ''--,S_eff_Month=Month(@S_Eff_Date),S_eff_year=Year(@S_Eff_Date)
							WHERE     (Label_Name = @Allow_Name) AND (Row_id = @Row_ID) and   S_eff_Month = Month(@For_Date) and S_eff_year=Year(@For_Date)
									and Emp_ID = @Emp_ID
							fetch next from Cur_Dedu into @Allow_Name,@Amount,@For_Date
						end
					close Cur_Dedu
					deallocate Cur_Dedu

						select @Total_Deduction = S_Total_Dedu_Amount ,@PT = S_PT_Amount ,@Loan =  ( S_Loan_Amount + S_Loan_Intrest_Amount ) 
								,@Advance =  S_Advance_Amount ,@Net_Salary = S_Net_Amount ,@Revenue_Amt =S_Revenue_amount,@LWF_Amt =S_LWF_Amount
						from T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
						where Emp_ID = @Emp_ID and 
							Month(@S_eff_Date) = Month(s_Month_End_Date) and Year(@S_eff_Date) = Year(s_Month_End_Date)
							AND Month(S_Month_End_Date) = @MONTH AND Year(S_Month_End_Date) = @YEAR	---- Same Month Sett. Ankit 05122015
							and S_Sal_Tran_ID = @S_Sal_Tran_ID		--Ankit 18022016
						
						Select @Other_Dedu  = 0
						
						set @Loan = @Loan + @Advance

		--				select @Row_ID = Row_ID from Temp_report_label where Label_Name like 'Other Dedu'

		--				INSERT INTO Temp_Salary_Muster_Report


		--						   (Emp_ID, Company_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
		--				VALUES     (@Emp_ID, @Company_ID, @Transaction_ID, @Month, @Year, 'Other Dedu', @Other_Dedu,'',@Row_ID)
						
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'PT'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @PT, 
											  Value_String = '',S_eff_Month=Month(@S_Eff_Date),S_eff_year=Year(@S_Eff_Date)
						WHERE     (Label_Name = 'PT') AND (Row_id = @Row_ID) and   S_eff_Month = Month(@S_Eff_Date) and S_eff_year=Year(@S_Eff_Date)
								and Emp_ID = @Emp_ID
								
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'LN/AD'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Loan, 
											  Value_String = '',S_eff_Month=Month(@S_Eff_Date),S_eff_year=Year(@S_Eff_Date)
						WHERE     (Label_Name = 'LN/AD') AND (Row_id = @Row_ID) and   S_eff_Month = Month(@S_Eff_Date) and S_eff_year=Year(@S_Eff_Date)
								and Emp_ID = @Emp_ID
						
						
						if @Revenue_Amt >0
							begin
								select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Revenue'
								
								UPDATE    #Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Revenue_Amt, 
													  Value_String = '',S_eff_Month=Month(@S_Eff_Date),S_eff_year=Year(@S_Eff_Date)
								WHERE     (Label_Name = 'Revenue') AND (Row_id = @Row_ID) and   S_eff_Month = Month(@S_Eff_Date) and S_eff_year=Year(@S_Eff_Date)
										and Emp_ID = @Emp_ID
							end
						if @LWF_amt > 0
							begin
								select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'LWF'
								
								UPDATE    #Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @lwf_Amt, 
													  Value_String = '',S_eff_Month=Month(@S_Eff_Date),S_eff_year=Year(@S_Eff_Date)
								WHERE     (Label_Name = 'LWF') AND (Row_id = @Row_ID) and   S_eff_Month = Month(@S_Eff_Date) and S_eff_year=Year(@S_Eff_Date)
										and Emp_ID = @Emp_ID
							end	
													
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'TDS'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @TDS, 
											  Value_String = ''
						WHERE     (Label_Name = 'TDS') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
										
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Oth De'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Other_Dedu, 
											  Value_String = '',S_eff_Month=Month(@S_Eff_Date),S_eff_year=Year(@S_Eff_Date)
						WHERE     (Label_Name = 'Oth De') AND (Row_id = @Row_ID) and   S_eff_Month = Month(@S_Eff_Date) and S_eff_year=Year(@S_Eff_Date)
								and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Deduction'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Total_Deduction, Value_String = '',S_eff_Month=Month(@S_Eff_Date),S_eff_year=Year(@S_Eff_Date)
						WHERE     (Label_Name = 'Deduction') AND (Row_id = @Row_ID) and   S_eff_Month = Month(@S_Eff_Date) and S_eff_year=Year(@S_Eff_Date)
								and Emp_ID = @Emp_ID	
								
						-- Aded by rohit for allowance add which effect net salary but not add in gross salary on 08072016
						
							declare Cur_Dedu   cursor for
						select Ad_Sort_Name ,M_Ad_Amount,mad.To_date from t0210_monthly_ad_detail MAD WITH (NOLOCK)inner join
							T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.sal_Tran_id = MSS.Sal_Tran_id inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Company_Id and Month(MSS.S_Month_End_Date) =  @Month and Year(MSS.S_Month_End_Date) = @Year
						and Ad_Active = 1 and AD_Flag = 'I' and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0)=1 And sal_Type=1 and effect_net_salary = 1
						and MAD.S_Sal_Tran_ID = @S_Sal_Tran_ID		
						
					open Cur_Dedu
					fetch next from cur_DEDU  into @Allow_Name ,@Amount,@For_Date
					while @@fetch_status = 0
						begin
						
							select @Row_ID = Row_ID from #Temp_report_label where Label_Name like @Allow_Name 
							
							UPDATE    #Temp_Salary_Muster_Report
							SET     Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Amount, 
												  Value_String = ''
							WHERE     (Label_Name = @Allow_Name) AND (Row_id = @Row_ID) and   S_eff_Month = Month(@For_Date) and S_eff_year=Year(@For_Date)
									and Emp_ID = @Emp_ID
							fetch next from Cur_Dedu into @Allow_Name,@Amount,@For_Date
						end
					close Cur_Dedu
					deallocate Cur_Dedu			
								
					
						declare Cur_Dedu   cursor for
						select Ad_Sort_Name ,M_Ad_Amount,mad.To_date from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.sal_Tran_id = MSS.Sal_Tran_id inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Company_Id and Month(MSS.S_Month_End_Date) =  @Month and Year(MSS.S_Month_End_Date) = @Year
						and Ad_Active = 1 and AD_Flag = 'D' and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0)=1 And sal_Type=1 and effect_net_salary = 1
						and MAD.S_Sal_Tran_ID = @S_Sal_Tran_ID	
						
					open Cur_Dedu
					fetch next from cur_DEDU  into @Allow_Name ,@Amount,@For_Date
					while @@fetch_status = 0
						begin
						
							select @Row_ID = Row_ID from #Temp_report_label where Label_Name like @Allow_Name 
							
							UPDATE    #Temp_Salary_Muster_Report
							SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Amount, 
												  Value_String = ''
							WHERE     (Label_Name = @Allow_Name) AND (Row_id = @Row_ID) and   S_eff_Month = Month(@For_Date) and S_eff_year=Year(@For_Date)
									and Emp_ID = @Emp_ID
							fetch next from Cur_Dedu into @Allow_Name,@Amount,@For_Date
						end
					close Cur_Dedu
					deallocate Cur_Dedu			
									
				-- Ended by rohit on 08072016		
								
						
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Net_Salary'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Company_Id, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Net_Salary, 
											  Value_String = '',S_eff_Month=Month(@S_Eff_Date),S_eff_year=Year(@S_Eff_Date)
						WHERE     (Label_Name = 'Net_Salary') AND (Row_id = @Row_ID) and   S_eff_Month = Month(@S_Eff_Date) and S_eff_year=Year(@S_Eff_Date)
								and Emp_ID = @Emp_ID
								
								
			FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@S_Eff_Date ,@S_Sal_Tran_ID,@month
		END
	Close Cur_Emp
	Deallocate Cur_emp	

		
		
			select #Temp_Salary_Muster_Report.*,E.Alpha_Emp_Code,E.Emp_Full_Name,
					Label_Name As Allowance_Name,BM.Branch_Name,ds.Desig_Name,isnull(Dept_Name,'') As Dept_Name,GM.Grd_Name
			 into #settlement from   #Temp_Salary_Muster_Report Inner join
			T0080_Emp_Master E WITH (NOLOCK) on #Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
			( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID, Branch_ID from t0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment WITH (NOLOCK)	-- Ankit 05092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Company_Id
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
			E.Emp_ID = Inc_Qry.Emp_ID left outer join t0040_department_Master WITH (NOLOCK)
			on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID  left outer join T0030_BRANCH_MASTER BM WITH (NOLOCK)
			on Inc_Qry.Branch_ID= BM.Branch_ID inner join 
			T0040_DESIGNATION_MASTER ds WITH (NOLOCK) on Inc_Qry.Desig_Id = ds.Desig_ID inner JOIN
			T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_ID = GM.Grd_ID inner JOIN
			t0010_company_master CM WITH (NOLOCK) on E.cmp_id=CM.cmp_id
			where Amount > 0 
			order by Row_ID,S_eff_month
			
			
			
			DECLARE @cols AS NVARCHAR(MAX),
					@query  AS NVARCHAR(MAX)

			select @cols = STUFF((SELECT ',' + QUOTENAME(Allowance_Name) 
			        from #settlement
                    group by Allowance_Name,Row_id
                    order by Row_id
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')
			
set @query = 'SELECT emp_id,Alpha_Emp_Code,Emp_Full_Name,Branch_Name,Desig_Name,Dept_Name,Grd_Name,' + @cols + ' from 
             (
                select emp_id,Alpha_Emp_Code,Emp_Full_Name,Branch_Name,Desig_Name,Dept_Name,Grd_Name,Allowance_Name,Amount from #settlement
            ) x
            pivot 
            (
                sum(Amount)
                for Allowance_Name in (' + @cols + ')
            ) p '

execute(@query);
	
	RETURN




