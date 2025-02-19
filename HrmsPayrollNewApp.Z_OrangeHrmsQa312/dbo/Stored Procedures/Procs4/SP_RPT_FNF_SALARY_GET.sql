CREATE PROCEDURE [dbo].[SP_RPT_FNF_SALARY_GET]
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
	,@PBranch_ID varchar(MAX) = '0'	
	,@Format        Varchar(20) = 'Default'   --added jimit 13062016
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

	If Isnull(@Emp_Id,0) > 0
		BEGIN
			Declare @Join_Date datetime
			Select @Join_Date =  Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Emp_Id = @Emp_Id
			
			If @Join_Date > @To_Date
				Set @To_Date = @Join_Date	
		END


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
			
		 if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
		   Begin
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
						( SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
							FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN 
									( SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
									  FROM	T0095_INCREMENT I3 WITH (NOLOCK)
									  WHERE	I3.Increment_Effective_Date <= @To_Date GROUP BY I3.Emp_ID
									) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
							WHERE	I2.Cmp_ID = @Cmp_Id GROUP BY I2.Emp_ID
						) I2 ON I.Emp_ID=I2.Emp_ID AND I.Increment_ID=I2.INCREMENT_ID	
						
					--( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
					--where Increment_Effective_date <= @To_Date
					--and Cmp_ID = @Cmp_ID
					--group by emp_ID  ) Qry on
					--I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
		  end
		 else
		  Begin
		    Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
							FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN 
									( SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
									  FROM	T0095_INCREMENT I3 WITH (NOLOCK)
									  WHERE	I3.Increment_Effective_Date <= @To_Date GROUP BY I3.Emp_ID
									) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
							WHERE	I2.Cmp_ID = @Cmp_Id GROUP BY I2.Emp_ID
					 ) I2 ON I.Emp_ID=I2.Emp_ID AND I.Increment_ID=I2.INCREMENT_ID	
						
					--( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
					--where Increment_Effective_date <= @To_Date
					--and Cmp_ID = @Cmp_ID
					--group by emp_ID  ) Qry on
					--I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)
		  end 
		end
		
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime  
	
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End
       
	 if isnull(@Sal_St_Date,'') = ''    
		begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date    
		end     
	 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
		begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date    
		end     
	 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1     
		begin    
		   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
		   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
		   set @From_Date = @Sal_St_Date
		   Set @To_Date = @Sal_end_Date   
		End
		
		--declare @I_ID as int
		--set @I_ID=(select max(I.Increment_ID) from T0095_INCREMENT I inner join  @Emp_Cons ec on I.emp_ID =ec.emp_ID )
		-- print @I_ID
		CREATE TABLE #Emp_Salary (
			Sal_Tran_ID 		numeric(18, 0) ,
			S_Sal_Tran_ID		numeric(18, 0) ,
			L_Sal_Tran_ID		numeric(18, 0) ,
			Sal_Receipt_No 		numeric(18, 0) ,
			Emp_ID 				numeric(18, 0) ,
			Cmp_ID 				numeric(18, 0) ,
			Increment_ID 		numeric(18, 0) ,
			Month_St_Date 		datetime ,
			Month_End_Date 		datetime ,
			Sal_Generate_Date 	datetime ,
			Sal_Cal_Days 		numeric(18, 2) ,
			Present_Days 		numeric(18, 2) ,
			Absent_Days 		numeric(18, 2) ,
			Holiday_Days 		numeric(18, 2) ,
			Weekoff_Days 		numeric(18, 2) ,
			Cancel_Holiday 		numeric(18, 2) ,
			Cancel_Weekoff 		numeric(18, 2) ,
			Working_Days 		numeric(18, 2) ,
			Outof_Days 			numeric(18, 2)  ,
			Total_Leave_Days 	numeric(18, 2) ,
			Paid_Leave_Days 	numeric(18, 2) ,
			Actual_Working_Hours 	varchar (20) ,
			Working_Hours 		varchar (20) ,
			Outof_Hours 		varchar (20) ,
			OT_Hours 			numeric(18, 2)  ,
			Total_Hours 		varchar (20) ,
			Shift_Day_Sec 		numeric(18, 0) ,
			Shift_Day_Hour 		varchar (20) ,
			Basic_Salary 		numeric(18, 2) ,
			Day_Salary 			numeric(18, 5)  ,
			Hour_Salary 		numeric(18, 5) ,
			Salary_Amount 		numeric(18, 2) ,
			Allow_Amount 		numeric(18, 2) ,
			OT_Amount 			numeric(18, 2)  ,
			Other_Allow_Amount 	numeric(18, 2) ,
			Gross_Salary 		numeric(18, 2) ,
			Dedu_Amount 		numeric(18, 2) ,
			Loan_Amount 		numeric(18, 2) ,
			Loan_Intrest_Amount 	numeric(18, 2) ,
			Advance_Amount 		numeric(18, 2) ,
			Other_Dedu_Amount 	numeric(18, 2) ,
			Total_Dedu_Amount 	numeric(18, 2) ,
			Due_Loan_Amount 	numeric(18, 2) ,
			Net_Amount 		numeric(18, 2) ,
			Actually_Gross_Salary 	numeric(18, 2) ,
			PT_Amount 		numeric(18, 0) ,
			PT_Calculated_Amount 	numeric(18, 0) ,
			Total_Claim_Amount 	numeric(18, 0) ,
			M_OT_Hours 		numeric(18, 1) ,
			M_Adv_Amount 		numeric(18, 0) ,
			M_Loan_Amount 		numeric(18, 0) ,
			M_IT_Tax 		numeric(18, 0) ,
			LWF_Amount 				numeric(18, 0) ,
			Revenue_Amount 			numeric(18, 0) ,
			PT_F_T_Limit 			varchar (20) ,
			Settelement_Amount 		numeric,
			Settelement_Comments	varchar(200), 
			Leave_Salary_Amount		numeric,	 
			Leave_Salary_Comments	varchar(200),	 
			Late_Sec				numeric, 
			Late_Dedu_Amount		numeric,	 
            Late_Extra_Dedu_Amount	numeric, 
            Late_Days				numeric, 
            Short_Fall_Days			numeric, 
            Short_Fall_Dedu_Amount	numeric, 
            Gratuity_Amount			numeric, 
            Is_FNF					int, 
			Bonus_Amount			numeric, 
            Incentive_Amount		numeric, 
            Trav_Earn_Amount		numeric, 
            Cust_Res_Earn_Amount	numeric, 
            Trav_Rec_Amount			numeric, 
            Mobile_Rec_Amount		numeric, 
            Cust_Res_Rec_Amount		numeric, 
            Uniform_Rec_Amount		numeric, 
            I_Card_Rec_Amount		numeric, 
            Excess_Salary_Rec_Amount	numeric,
            IS_PF					varchar(1) ,
            Is_ESIC					varchar(1),
            Last_Salary_Paid_Month		int,
            Last_Salary_Paid_Year		int,
            Arear_Days				numeric(18,2),  -- Added by Ali 10122013		
            Access_Leave_Recovery_Day numeric(18,2), -- Added By Ali 18022014  
            Extra_Day_Month numeric, -- Hardik 16/06/2014
            Extra_Day_Year Numeric, --Hardik 16/06/20014
            Access_Leave_Recovery_Type varchar(250), --Hardik 16/06/2014
            Net_Salary_Round_Diff_Amount numeric(18, 2),	--Ankit 09072014
            Total_Earning_Fraction numeric(18, 2),			--Ankit 09072014
            FNF_Comments			varchar(max) default null, --Added by Sumit 07112015
            Total_Yearly_Working_day	NUMERIC(18,2) DEFAULT 0,  --added jimit 01072016
            Total_Days_Worked_In_Fy     NUMERIC(18,2) DEFAULT  0  --added jimit 01072016
		)
		
		INSERT INTO #Emp_Salary
								  (Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days, 
								  Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days, 
								  Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary, 
								  Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount, 
								  Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Actually_Gross_Salary, PT_Amount, 
								  PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount, 
								  PT_F_T_Limit, Settelement_Amount, Settelement_Comments, Leave_Salary_Amount, Leave_Salary_Comments, Late_Sec, Late_Dedu_Amount, 
									Late_Extra_Dedu_Amount, Late_Days, Short_Fall_Days, Short_Fall_Dedu_Amount, Gratuity_Amount, Is_FNF, Bonus_Amount, Incentive_Amount, 
									Trav_Earn_Amount, Cust_Res_Earn_Amount, Trav_Rec_Amount, Mobile_Rec_Amount, Cust_Res_Rec_Amount, Uniform_Rec_Amount, 
									I_Card_Rec_Amount, Excess_Salary_Rec_Amount,Arear_Days,Access_Leave_Recovery_Day, Extra_Day_Month, Extra_Day_Year, Access_Leave_Recovery_Type,Net_Salary_Round_Diff_Amount,Total_Earning_Fraction,FNF_Comments) -- Added by Ali 18022014

				select Sal_Tran_ID, Sal_Receipt_No, ms.Emp_ID, Cmp_ID, (select max(I.Increment_ID) from T0095_INCREMENT I inner join  @Emp_Cons ec on I.emp_ID =ec.emp_ID )as Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days, 
								  Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days + isnull(OD_leave_days,0), 
								  Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary, 
								  Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, isnull(Gross_Salary,0), Dedu_Amount, Loan_Amount, Loan_Intrest_Amount, 
								  Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Actually_Gross_Salary, PT_Amount, 
								  PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount, 
								  PT_F_T_Limit, Settelement_Amount, Settelement_Comments, Leave_Salary_Amount, Leave_Salary_Comments, Late_Sec, Late_Dedu_Amount, 
									Late_Extra_Dedu_Amount, Late_Days, Short_Fall_Days, Short_Fall_Dedu_Amount, Gratuity_Amount, Is_FNF, Bonus_Amount, Incentive_Amount, 
									Trav_Earn_Amount, Cust_Res_Earn_Amount, Trav_Rec_Amount, Mobile_Rec_Amount, Cust_Res_Rec_Amount, Uniform_Rec_Amount, 
									I_Card_Rec_Amount, Excess_Salary_Rec_Amount,isnull(Arear_Day,0) + ISNULL(Arear_Day_Previous_month,0),Access_Leave_Recovery_Day, -- Added by Ali 18022014
									Arear_Month, Arear_Year, Access_Leave_Recovery_Type,Net_Salary_Round_Diff_Amount,Total_Earning_Fraction,FNF_Comments
				 From T0200_MONTHLY_SALARY ms WITH (NOLOCK) inner join @Emp_Cons ec on ms.emp_ID =ec.emp_ID 
				 Where ms.Cmp_ID = @Cmp_Id	
						and isnull(IS_FNF,0) = 1
						--and Month_St_Date >=@From_Date and Month_End_Date <=@To_Date    
						and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)  -- Changed By Gadriwala 28112013
												
						
	Update #Emp_Salary		
	set IS_PF ='Y'
	from #Emp_Salary es inner join T0100_EMP_EARN_DEDUCTION EED ON ES.INCREMENT_ID =EED.INCREMENT_ID INNER JOIN
		T0050_AD_MASTER AM ON EED.AD_ID = AM.AD_ID AND AD_DEF_ID =2
		
	Update #Emp_Salary		
	set IS_ESIC ='Y'
	from #Emp_Salary es inner join T0100_EMP_EARN_DEDUCTION EED ON ES.INCREMENT_ID =EED.INCREMENT_ID INNER JOIN
		T0050_AD_MASTER AM ON EED.AD_ID = AM.AD_ID AND AD_DEF_ID =3
		
	Update #Emp_Salary		
	set Last_Salary_Paid_Month =month((select max(SMS.Month_End_Date) from T0200_MONTHLY_SALARY SMS WITH (NOLOCK) where SMS.Emp_ID = MS.Emp_ID and isnull(sms.Is_FNF,0) = 0)),
		Last_Salary_Paid_Year =year((select max(SMS.Month_End_Date) from T0200_MONTHLY_SALARY SMS WITH (NOLOCK) where SMS.Emp_ID = MS.Emp_ID and isnull(sms.Is_FNF,0) = 0))
	from #Emp_Salary es inner join T0200_MONTHLY_SALARY MS ON ES.EMP_ID = MS.EMP_ID  --AND MS.Salary_Status='Hold'
		
	--added jimit 01072016
	
	if @Format = 'Format3'
		BEGIN		
		
		Declare @FromDate as DATETIME
		Declare @ToDate as DATETIME		
		
		SET @FromDate = dbo.GET_YEAR_START_DATE(year(@From_DAte) ,Month(@From_DAte),2)
		SET @ToDate = dbo.GET_YEAR_END_DATE(year(@From_DAte),Month(@From_DAte),2)
				
			
			IF OBJECT_ID('tempdb..#Emp_WeekOff_Holiday') IS NULL
				BEGIN	
					CREATE TABLE #Emp_WeekOff_Holiday
					(
						Emp_ID				NUMERIC,
						WeekOffDate			VARCHAR(Max),
						WeekOffCount		NUMERIC(4,1),
						HolidayDate			VARCHAR(Max),
						HolidayCount		NUMERIC(4,1),
						HalfHolidayDate		VARCHAR(Max),
						HalfHolidayCount	NUMERIC(4,1),
						OptHolidayDate		VARCHAR(Max),
						OptHolidayCount		NUMERIC(4,1)
					)
					CREATE UNIQUE CLUSTERED INDEX IX_Emp_WeekOff_Holiday_EMPID ON #Emp_WeekOff_Holiday(Emp_ID);
			END
			
		exec SP_GET_HW_ALL @Constraint = @Constraint,@Cmp_ID = @Cmp_ID,@From_Date = @FromDate,@To_Date = @ToDate
		,@All_Weekoff =0,@Is_FNF = 1,@Is_Leave_Cal = 0,@Allowed_Full_WeekOff_MidJoining = 0,@Type = 0,@Use_Table = 0
		,@Exec_Mode	= 0,@Delete_Cancel_HW = 1
		
		UPDATE	E
		SET		E.Total_Yearly_Working_day = Q.Total_Yearly_Working_day
		FROM #Emp_Salary E INNER JOIN
		(
			SELECT		ES.Emp_ID,(DATEDIFF(day,  @FromDate,  @ToDate) + 1) - (WeekOffCount)	as 	Total_Yearly_Working_day		
			FROM 		#Emp_Salary ES INNER join 
						#Emp_WeekOff_Holiday EW On Ew.Emp_ID = Es.Emp_ID			
		)Q ON Q.EMP_ID = E.EMP_ID	 
		 
		UPDATE	E
		SET		E.Total_Days_Worked_In_Fy = Q.Total_Days_Worked_In_Fy
		FROM #Emp_Salary E INNER JOIN
		(
			SELECT		ES.Emp_ID,sum(Isnull(Ms.Sal_Cal_Days,0)) as Total_Days_Worked_In_Fy
			FROM 		#Emp_Salary ES INNER join 
						T0080_EMP_MASTER EM WITH (NOLOCK) On EM.Emp_ID = Es.Emp_ID and Em.Cmp_ID = Es.Cmp_ID	INNER JOIN
						T0200_MONTHLY_SALARY Ms WITH (NOLOCK) On Ms.Emp_ID = Es.Emp_ID and ms.Cmp_ID = Es.Cmp_ID 
			where 		MS.Month_St_Date>= @FromDate
						and MS.Month_End_Date <= EM.Emp_Left_Date
			GROUP by    ES.Emp_ID
		)Q ON Q.EMP_ID = E.EMP_ID 
		END
	--ended		
	--Select * From #Emp_Salary		
		--datediff(yy,g.from_date,g.to_date) changed by Falak on 28-DEC-2010
	--Select MS.*,DBO.F_GET_AGE (g.from_date,g.to_date,'Y','N') as G_Days,Emp_full_Name,Branch_Address,Datediff(d,@From_Date,Left_Date) as days_work,Comp_name,Grd_Name,Month(Month_St_Date)as Month,YEar(Month_St_Date)as Year ,Branch_NAme
	-------------------------------------------------------------------------------------------------------
	--change By Deepali -05012022 change  DBO.F_GET_AGE (g.from_date,g.to_date,'Y','N') as G_Days to Cast(Isnull(g.Gr_Years,0)as varchar) as G_Days - to display Actual gratuity years
	Select MS.*, Cast(Isnull(g.Gr_Years,0)as varchar) as G_Days,Emp_full_Name,Branch_Address,Present_Days as days_work,Comp_name,Grd_Name,Month(Month_St_Date)as Month,YEar(Month_St_Date)as Year ,Branch_NAme
			,Alpha_Emp_Code as EMP_CODE,Type_Name,Dept_Name,Desig_Name,Inc_Bank_Ac_no,PAN_no,DAte_of_Birth,Date_of_Join,
			SSN_No as PF_No,SIN_No as ESIC_No ,dbo.F_Number_TO_Word(Net_Amount) as Net_Amount_In_Word
			,Bank_Name ,CMP_NAME,CMP_ADDRESS, cm.Image_name Cmp_Image_Name ,
			Branch_Code,left_date,Reg_Accept_Date,Is_Terminate,MSL.L_Sal_Cal_Days  as L_Days,cmp_logo,le.reg_Date,
			--,ISNULL(MPI.Extra_Day_Month,MONTH(MS.Month_End_Date)) as Extra_Day_Month -- Added by Ali 11122013
			--,ISNULL(MPI.Extra_Day_Year,YEAR(MS.Month_End_Date)) as Extra_Day_Year -- Added by Ali 11122013
			--,CASE ISNULL(MPI.Extra_Day_Month,0) WHEN 0 THEN convert(char(3),DATENAME(mm,DATEADD(mm,MONTH(MS.Month_End_Date),-1)), 0)
			-- ELSE convert(char(3),DATENAME(mm,DATEADD(mm,MPI.Extra_Day_Month,-1)), 0) END as 'ArearMonth' -- Added by Ali 11122013
			
			convert(char(3),DATENAME(mm,DATEADD(mm,MS.Extra_Day_Month,-1))) as 'ArearMonth', --Added by Hardik 16/06/2014
			BS.Segment_Name,
			E.Emp_Confirm_Date,ETM.[Type_Name] as Employee_Status,
			--(case when E.Emp_Notice_Period > 0 THEN 'YES' ELSE 'NO' END) as Norice_Period  --Comment by Jaina 27-06-2017
			(case when E.Emp_Notice_Period > 0 THEN cast(E.Emp_Notice_Period AS varchar)+' Days' ELSE 'NO' END) as Norice_Period   --Added by Jaina 27-06-2017
			,--Qm.Qual_Name as qualification     --commented jimit 14042016 for getting the more than one qulification
			(Select STUFF((SELECT ',' + Qm.Qual_Name From T0080_EMP_MASTER E WITH (NOLOCK) Left Outer JOIN
									 T0090_EMP_QUALIFICATION_DETAIL QED WITH (NOLOCK) On QED.Emp_ID = E.Emp_ID and QED.Cmp_ID = e.Cmp_ID Left Outer Join
									 T0040_QUALIFICATION_MASTER Qm WITH (NOLOCK) On Qm.Qual_ID = QED.Qual_ID
							WHERE  Qed.emp_Id = I_Q.Emp_ID FOR XML PATH('')), 1,1,''))
			as qualification,
			(Select top 1 E.EMP_FULL_NAME From T0080_EMP_MASTER E WITH (NOLOCK) 
							Left JOIN  T0090_EMP_REFERENCE_DETAIL M WITH (NOLOCK) ON E.Emp_ID=M.R_Emp_id 
							WHERE I_Q.Emp_ID=M.Emp_id and I_Q.Cmp_ID = M.Cmp_ID)
			as Reference
			,E.Training_Month,
			(Select STUFF((SELECT ',' + E.EMP_FULL_NAME From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0095_MANAGERS M WITH (NOLOCK) ON E.Emp_ID=M.Emp_id
					  WHERE  M.branch_id=I_Q.Branch_ID FOR XML PATH('')), 1,1,''))
			as Group_HOD,
			(Select STUFF((SELECT ',' + E.EMP_FULL_NAME From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0095_Department_Manager DM WITH (NOLOCK) ON E.Emp_ID=DM.Emp_id
					  WHERE  DM.Dept_Id=I_Q.Dept_ID FOR XML PATH('')), 1,1,''))
			as HOD
			,(Select STUFF((SELECT ',' + E.EMP_FULL_NAME From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0011_LOGIN DM WITH (NOLOCK) ON E.Emp_ID=DM.Emp_id
					  WHERE  DM.Cmp_ID=I_Q.Cmp_ID and DM.Is_HR =1 FOR XML PATH('')), 1,1,'')
			) As HR	
			,Pm.Prob_Date,Pm1.trainee_Date
			,Is_Death,Is_Retire
			,CCM.Center_Code,E.DBRD_Code as Dealer_Code,CCM.Center_Name,Ifsc_Code,  ---added jimit 01072016
			(case when upper([ETM].[Type_Name]) = 'PERMANENT' THEN	   ---added jimit 01072016
					   'Yes'
			 ELSE      'No' 
			 end) as Confirmed,
			 (case when E.Is_Gr_App = 1  THEN	   ---added jimit 01072016
					'Yes'
			  ELSE
					'No'
			  End) as Gratuity,
			  datediff(Day,E.Date_Of_Join,E.Emp_Left_Date) as Total_Service_Tenure		 ---added jimit 01072016
			  ,(case when LE.Is_Terminate = 1 THEN 'Termination'
				when Le.Is_Retire = 1 then 'Retirement'
				WHEN Le.Is_Death = 1 then 'Death'
				WHEN Le.Is_Absconded=1 then 'Absconded'
				Else 'Resignation'
				end) as Left_Reason,I_Q.Inc_Bank_AC_No,ELR.Reference_No,ELR.Issue_Date
			   --added jimit 20072016
		 From #Emp_Salary MS left outer join
		 T0100_GRATUITY G WITH (NOLOCK) on MS.Emp_ID=G.Emp_ID inner join
		T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID inner join 
			T0100_LEFT_EMP LE WITH (NOLOCK) ON E.EMP_ID = LE.EMP_ID INNER JOIN 
			T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID inner join 
			----Added By Mukti(start)16082016      
			--(SELECT	max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment  
			--  WHERE		Increment_Effective_date <= @From_Date      
			--  AND Cmp_ID = @Cmp_ID GROUP BY emp_ID) Qry on      
		 --     I_Q.Emp_ID = Qry.Emp_ID and I_Q.Increment_ID = Qry.Increment_ID inner join
		 --    --Added By Mukti(end)16082016			
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID Left outer Join 
					
					T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID left outer join 
					--T0040_Bank_master bk WITH (NOLOCK) on Bk.Cmp_Id = CM.Cmp_Id and bk.Is_Default='Y' Left outer join 
					T0040_Bank_master bk on I_Q.Bank_ID = bk.Bank_ID Left outer join 
					T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID=I_Q.Segment_ID left outer JOIN					
					--T0090_EMP_QUALIFICATION_DETAIL QED on QED.Emp_ID = E.Emp_ID and QED.Cmp_ID = e.Cmp_ID left outer JOIN
					--T0040_QUALIFICATION_MASTER QM on QM.Qual_ID = QED.Qual_ID  left outer JOIN
					--T0090_EMP_REFERENCE_DETAIL ERD	on ERD.Emp_ID = E.Emp_ID and e.Cmp_ID = ERD.Cmp_ID left join
					T0200_MONTHLY_SALARY_LEAVE MSL WITH (NOLOCK) on MS.Emp_ID=MSL.Emp_ID 
					and month(msl.l_month_end_date) = month(ms.month_end_date) 
					and Year(msl.l_month_end_date) = Year(ms.month_end_date) LEFT OUTER JOIN --Changed By Gadriwala 29112013		--and msl.l_month_st_date = ms.month_st_date and msl.l_month_end_date = ms.month_end_date
					
					--left outer join T0190_MONTHLY_PRESENT_IMPORT MPI on ms.Emp_ID = MPI.Emp_ID  -- Added by Ali 11122013
					--and MPI.Year = Year(ms.Month_End_Date)
					--and MPI.Month = Month(ms.Month_End_Date)
					(select Emp_ID ,max(New_Probation_EndDate)as Prob_Date
								from  T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
								where flag= 'Probation' and Cmp_ID = @Cmp_Id
								group by emp_Id) Pm On Pm.Emp_ID = E.Emp_ID	LEFT OUTER JOIN 
					(select Emp_ID ,max(New_Probation_EndDate)as trainee_Date
							from  T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
							where flag= 'Trainee' and Cmp_ID = @Cmp_Id
							group by emp_Id) Pm1 On Pm1.Emp_ID = E.Emp_ID	Left outer JOIN
					T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) On CCM.Center_ID = I_Q.Center_ID and CCM.Cmp_ID = I_q.Cmp_ID left join 
					T0081_Emp_LetterRef_Details ELR WITH (NOLOCK) on ELR.Emp_Id = e.Emp_ID and ELR.Letter_Name='F & F Letter' --Mukti(10012017)
		WHERE E.Cmp_ID = @Cmp_Id And isnull(MS.Is_FNF,0)=1 
			 
	
					
	RETURN 




	