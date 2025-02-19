---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Set_Salary_Register_Amount_NIIT_Amount]
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
,@Constraint	varchar(MAX) = ''
,@Sal_Type    numeric
,@PBranch_ID    varchar(max) = '0'
,@Salary_Cycle_id numeric = 0
,@Segment_ID Numeric = 0 -- Added By mitesh 07082013
,@Vertical_ID Numeric = 0 -- Added By mitesh 07082013
,@SubVertical_ID Numeric = 0 -- Added By mitesh 07082013
,@subBranch_ID Numeric = 0 -- Added By mitesh 07082013
,@SHOW_HIDDEN_ALLOWANCE bit = 0
,@Group_Name	integer = 4  --added Hardik 17/04/2019 for Chiripal
,@Summary_Option  Int =-1 --- Add by Jignesh Patel 30-Sep-2021---- For Chiripal (1  For Summary)

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	-------- Add by Jignesh Patel 04-10-2021---- For Chiripal (1  For Summary)
	--If Isnull(@Group_Name,4) = 4
	--	Begin
	--		SET @Summary_Option = 1
	--	ENd

	If Isnull(@Summary_Option,0)=8
	Begin
		SET @Summary_Option =0
	End
	Else
	Begin
		SET @Summary_Option =@Summary_Option+1
	ENd
	------------------------- End ------------------------

	set @SHOW_HIDDEN_ALLOWANCE = 0
	
	if @Salary_Cycle_id = 0
		set @Salary_Cycle_id = NULL
		
		if @Salary_Cycle_id = 0
		set @Salary_Cycle_id = NULL
		
	IF @Segment_ID = 0 
		SET @Segment_ID = Null
	IF @Vertical_ID = 0 
		SEt @Vertical_ID = Null
	IF @SubVertical_ID = 0 
		Set @SubVertical_ID  = Null
	if @subBranch_ID = 0
		set @subBranch_ID = Null
		
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
	Declare @Leave_Amount as numeric(22,2)
	Declare @Total_Deduction as numeric(22,2)
	Declare @Late_Deduction as numeric(22,2)
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
	DEclare @TDS numeric(18,2)
	Declare @Settl numeric(22,2)
	Declare @Deficit_Amt as Numeric (18,2)	--- Added by Hardik 14/11/2013 for Pakistan
	Declare @Round_Value as numeric(22,2)	--Ankit 15072014
	Declare @Total_Gross as numeric(22,2)	--Ankit 15072014
	Declare @Net_Round_Value As numeric(22,2)	--Ankit 15072014
	Declare @Total_Net_Payable As numeric(22,2)	--Ankit 15072014
	DECLARE @ROUNDING AS NUMERIC(18,0)			--Ankit 15072014
	Declare @Sal as numeric(18,0)
	Declare @GatePass_Deduct_Days numeric(18,2) -- Added by Gadriwala Muslim 09012015
	Declare @GatePass_Amount numeric(18,2) -- Added by Gadriwala Muslim 09012015
	Declare @Asset_Installment numeric(18,2) -- Added by Mukti 01042015
	Declare @TravelAdvanceAmt numeric(18,3)
	Declare @TravelAmount numeric(18,3) --Added by Sumit 24092015
	Declare @OT_Amount as numeric(18,2)	
	Declare @Bonus as numeric(18,2) -- Added by Gadriwala Muslim 23122016
	
	Declare @Arear_Days as Numeric(18,2)
	Declare @Arear_Basic As Numeric(18,2)
	Declare @Arear_Earn_Amount as Numeric(18,2)
	Declare @Arear_Dedu_Amount as Numeric(18,2)
	Declare @Arear_Net As Numeric(18,2)	
	Declare @Uniform_Installment numeric(18,2) --Mukti(23052017)
	Declare @Uniform_Refund_Installment numeric(18,2) --Mukti(23052017)
	DECLARE @Claim_Amount NUMERIC(18,2) --Mukti(28062017)
	SET @ROUNDING = 0
	
	IF	EXISTS (SELECT 1 FROM [tempdb].dbo.sysobjects where name like '#Temp_report_Label')		
			BEGIN
				DROP TABLE #Temp_report_Label
			END
		IF	EXISTS (SELECT 1 FROM [tempdb].dbo.sysobjects where name like '#Temp_Salary_Muster_Report')		
			BEGIN
				DROP TABLE #Temp_Salary_Muster_Report
			END
						
			
	
	CREATE table #Temp_report_Label
	(
	Row_ID  numeric(18, 0) NOt null,
	Label_Name  varchar(200) not null,
	Income_Tax_ID numeric(18, 0) null,
	Is_Active	varchar(1) null
	)
	
	--ALTER index idx_1 on #Temp_report_Label (Row_ID)
	Create CLUSTERED INDEX ind_temp ON #Temp_report_Label(Row_ID)
	Create NONCLUSTERED INDEX ind_temp6 ON #Temp_report_Label(Label_Name)

		
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
		INCOME_TAX_ID numeric(18, 0)  Default 0,
		Row_id numeric(18, 0) Null,
		M_AD_Flage char(1),
		Rate  numeric(18, 2) Default 0,
		S_Sal_Tran_Id	numeric(18, 0) Null,	--Ankit 07122015
		
	)
	Create CLUSTERED INDEX ind_temp1	ON #Temp_Salary_Muster_Report(Row_id)
	Create NONCLUSTERED INDEX ind_temp2 ON #Temp_Salary_Muster_Report(Emp_ID)
	Create NONCLUSTERED INDEX ind_temp3 ON #Temp_Salary_Muster_Report(Cmp_ID)
	Create NONCLUSTERED INDEX ind_temp4 ON #Temp_Salary_Muster_Report(Label_Name)
	Create NONCLUSTERED INDEX ind_temp5 ON #Temp_Salary_Muster_Report(Value_String)
	
	
		
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

		  Declare @Sal_St_Date   Datetime    
		  Declare @Sal_end_Date   Datetime  
		  
		  -- Comment and added By rohit on 11022013
		  declare @manual_salary_period as numeric(18,0)
		  set @manual_salary_period = 0
		  
		   declare @is_salary_cycle_emp_wise as tinyint -- added by mitesh on 03072013
		   set @is_salary_cycle_emp_wise = 0
		   
		   select @is_salary_cycle_emp_wise = isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name = 'Salary Cycle Employee Wise'
		   
  
		  if @is_salary_cycle_emp_wise = 1 and isnull(@Salary_Cycle_id,0) > 0
			begin
				--declare @Salary_Cycle_id as numeric
				--set @Salary_Cycle_id  = 0
				
				--SELECT @Salary_Cycle_id = salDate_id from T0095_Emp_Salary_Cycle where emp_id = @Emp_Id AND effective_date in
				--(SELECT max(effective_date) as effective_date from T0095_Emp_Salary_Cycle 
				--where emp_id = @Emp_Id AND effective_date <=  @Month_End_Date
				--GROUP by emp_id)
				
				SELECT @Sal_St_Date = SALARY_ST_DATE FROM t0040_salary_cycle_master WITH (NOLOCK) where tran_id = @Salary_Cycle_id
				
			end
		else
			begin
				If @Branch_ID is null
					Begin 
						select Top 1 @Sal_St_Date  = Sal_st_Date,@manual_salary_period=isnull(Manual_Salary_Period ,0) -- Comment and added By rohit on 11022013 
						  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
						  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
					End
				Else
					Begin
						select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) -- Comment and added By rohit on 11022013
						  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID
						  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
					End    
			end
		  
		       
		 if isnull(@Sal_St_Date,'') = ''    
			BEGIN
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			end     
		 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
			begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			end     
		 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
			begin    
			   -- Comment and added By rohit on 11022013
			   --set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   --set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   --set @From_Date = @Sal_St_Date
			   --Set @To_Date = @Sal_end_Date 
			   
			   			   
			    if @manual_salary_period = 0   
					Begin
					   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
					   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
					   Set @From_Date = @Sal_St_Date
					   Set @To_Date = @Sal_End_Date
					End
				Else
					Begin
						select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)
						Set @From_Date = @Sal_St_Date
						Set @To_Date = @Sal_End_Date 
					End    
			-- Ended By rohit on 11022013  
			End
		
	 
	set @month = month(@To_Date)
	set @Year = Year(@To_Date)


	EXEC Set_Salary_Register_Lable @Cmp_ID ,@month , @Year
	print CONVERT(varchar(20),getdate(),114)	
	
	create table #Emp_Cons 
		(
			Emp_ID	numeric,     
			Branch_ID NUMERIC,
			Increment_ID NUMERIC   
		)
		--select * from #TEMP_REPORT_LABEL
	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			select  CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC)  from dbo.Split (@Constraint,'#') 
		end
	else 
		BEGIN
			if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0  -- added by mitesh on 02042012
				begin
				
					Insert Into #Emp_Cons
					 SELECT DISTINCT emp_id,branch_id,Increment_ID FROM V_Emp_Cons 
			  left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
							inner join 
							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= @To_Date
							GROUP BY emp_id) Qry
							on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
		       ON QrySC.eid = V_Emp_Cons.Emp_ID
			  WHERE 
		      cmp_id=@Cmp_ID 				
		       AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))      
		  -- AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)      
		   AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)      
		   AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))      
		   AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))      
		   AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
		   and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id  ,isnull(QrySC.SalDate_id,0))  
		   and Branch_ID in (select cast(data as numeric) from dbo.Split(@PBranch_ID,'#')) 
		   And ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,IsNull(Segment_ID,0))
		   And ISNULL(Vertical_ID,0) = ISNULL(@Vertical_ID,IsNull(Vertical_ID,0))
		   And ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,IsNull(SubVertical_ID,0))
		   And ISNULL(subBranch_ID,0) = ISNULL(@subBranch_ID,IsNull(subBranch_ID,0)) -- Added on 06082013
		    AND Emp_Id = ISNULL(@Emp_Id,Emp_Id) 
		      AND Increment_Effective_Date <= @To_Date 
		      AND 
                       ( (@From_Date  >= join_Date  AND  @From_Date <= left_date )      
						OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )      
						OR (Left_date IS NULL AND @To_Date >= Join_Date)      
						OR (@To_Date >= left_date  AND  @From_Date <= left_date )
						OR 1=(case when (   (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
						)
						ORDER BY Emp_ID
						
			DELETE  FROM #Emp_Cons WHERE Increment_ID NOT IN (SELECT MAX(Increment_ID) FROM T0095_Increment WITH (NOLOCK)
				WHERE  Increment_effective_Date <= @to_date
				GROUP BY emp_ID )
					--select I.Emp_Id from dbo.T0095_Increment I inner join 
					--		( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment
					--		where Increment_Effective_date <= @To_Date
					--		and Cmp_ID = @Cmp_ID
					--		group by emp_ID  ) Qry on
					--		I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
					--Where Cmp_ID = @Cmp_ID 
					--and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
					----and Branch_ID = isnull(@Branch_ID ,Branch_ID)
					--and Grd_ID = isnull(@Grd_ID ,Grd_ID)
					--and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
					--and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
					--and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
					--and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
					--and Branch_ID in (select cast(data as numeric) from dbo.Split(@PBranch_ID,'#'))
					--and I.Emp_ID in 
					--	( select Emp_Id from
					--	(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
					--	where cmp_ID = @Cmp_ID   and  
					--	(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
					--	or ( @To_Date  >= join_Date  and @To_Date <= left_date )
					--	or Left_date is null and @To_Date >= Join_Date)
					--	or @To_Date >= left_date  and  @From_Date <= left_date ) 
				end
			else
				begin
				
					Insert Into #Emp_Cons
					
					  SELECT DISTINCT emp_id,branch_id,Increment_ID FROM V_Emp_Cons 
			  left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
							inner join 
							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= @To_Date
							GROUP BY emp_id) Qry
							on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
		       ON QrySC.eid = V_Emp_Cons.Emp_ID
			  WHERE 
		      cmp_id=@Cmp_ID 				
		       AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))      
		   AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)      
		   AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)      
		   AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))      
		   AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))      
		   AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
		   and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id  ,isnull(QrySC.SalDate_id,0))   
		   And ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,IsNull(Segment_ID,0))
		   And ISNULL(Vertical_ID,0) = ISNULL(@Vertical_ID,IsNull(Vertical_ID,0))
		   And ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,IsNull(SubVertical_ID,0))
		   And ISNULL(subBranch_ID,0) = ISNULL(@subBranch_ID,IsNull(subBranch_ID,0)) -- Added on 06082013
		    AND Emp_Id = ISNULL(@Emp_Id,Emp_Id) 
		      AND Increment_Effective_Date <= @To_Date 
		      AND 
                       ( (@From_Date  >= join_Date  AND  @From_Date <= left_date )      
						OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )      
						OR (Left_date IS NULL AND @To_Date >= Join_Date)      
						OR (@To_Date >= left_date  AND  @From_Date <= left_date )
						OR 1=(case when (  (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
						)
						ORDER BY Emp_ID
						
			DELETE  FROM #Emp_Cons WHERE Increment_ID NOT IN (SELECT MAX(Increment_ID) FROM T0095_Increment WITH (NOLOCK)
				WHERE  Increment_effective_Date <= @to_date
				GROUP BY emp_ID )
					
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
					--	(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
					--	where cmp_ID = @Cmp_ID   and  
					--	(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
					--	or ( @To_Date  >= join_Date  and @To_Date <= left_date )
					--	or Left_date is null and @To_Date >= Join_Date)
					--	or @To_Date >= left_date  and  @From_Date <= left_date ) 
				end
		end

		
	DECLARE @Curr_S_Sal_Tran_ID	NUMERIC	--Twise Settlement Register	--Ankit 07122015
	
	IF @Sal_Type = 1 
		BEGIN	
			DECLARE CUR_EMP CURSOR FOR
			SELECT sg.EMP_ID ,SG.S_Sal_Tran_ID FROM dbo.T0201_MONTHLY_SALARY_SETT SG WITH (NOLOCK) INNER JOIN
			T0080_EMP_MASTER E WITH (NOLOCK) ON sg.EMP_ID =e.EMP_ID 
			INNER JOIN  #Emp_Cons ec on E.Emp_ID = Ec.Emp_ID 
			WHERE  sg.Cmp_ID = @Cmp_ID 
							AND Month(sg.S_Month_End_Date) = @MONTH AND Year(sg.S_Month_End_Date) = @YEAR
		END
	ELSE
		BEGIN
			DECLARE CUR_EMP CURSOR FOR
			SELECT sg.EMP_ID ,SG.Sal_Tran_ID FROM dbo.T0200_MONTHLY_SALARY SG WITH (NOLOCK) INNER JOIN
			T0080_EMP_MASTER E WITH (NOLOCK) ON sg.EMP_ID =e.EMP_ID 
			INNER JOIN /*	EMP_OTHER_DETAIL eod ON e.EMP_ID = eod.EMP_ID Inner join*/ #Emp_Cons ec on E.Emp_ID = Ec.Emp_ID 
			Inner join ( select dbo.T0095_Increment.Emp_Id ,Type_ID ,Grd_ID,Dept_ID,Desig_Id,Branch_ID,Cat_ID,Payment_Mode from t0095_Increment WITH (NOLOCK) inner join 
											( select max(I.Increment_ID) as Increment_ID , I.Emp_ID from t0095_Increment I WITH (NOLOCK) Inner Join #Emp_Cons ec on I.Emp_ID = Ec.Emp_ID
											where I.Increment_Effective_date <= @To_Date
											and I.Cmp_ID = @Cmp_ID
											group by I.emp_ID  ) Qry
											on t0095_Increment.Emp_ID = Qry.Emp_ID and
											t0095_Increment.Increment_ID   = Qry.Increment_ID	
									where Cmp_ID = @Cmp_ID ) I_Q on 
							e.Emp_ID = I_Q.Emp_ID
			WHERE  sg.Cmp_ID = @Cmp_ID 
			AND Month(sg.Month_End_Date) = @MONTH AND Year(sg.Month_End_Date) = @YEAR And isnull(sg.is_FNF,0)=0
				--AND Payment_Mode LIKE isnull(@PAYEMENT,Payment_Mode)
		END	
	OPEN  CUR_EMP
	FETCH NEXT FROM CUR_EMP INTO @EMP_ID ,@Curr_S_Sal_Tran_ID
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
						Set @Leave_Amount = 0
						SET @Total_Deduction =0
						SET @Late_Deduction = 0
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
						set @Settl=0
						Set @Deficit_Amt = 0
						Set @Round_Value = 0
						Set @Total_Gross = 0
						Set @Net_Round_Value = 0
						Set @Total_Net_Payable = 0
						set @OT_Amount = 0 -- Added by Gadriwala Muslim 10112014
						set @Sal =0
						set @GatePass_Deduct_Days = 0
						set @GatePass_Amount = 0 
						set @Asset_Installment=0  -- Added by Mukti 01042015
						set @TravelAmount=0
						set @TravelAdvanceAmt=0
						set @Bonus = 0 -- Added by Gadriwala Muslim 23122016
						Set @Arear_Days = 0	
						Set @Arear_Basic = 0 
						Set @Arear_Earn_Amount = 0
						Set @Arear_Dedu_Amount = 0
						Set @Arear_Net = 0 
						set @Uniform_Installment = 0
						set @Uniform_Refund_Installment = 0 
						set @Claim_Amount = 0 
													
					If @Sal_Type = 0
						Begin
							--select @P_Days = Present_Days + Holiday_Days , @Basic_Salary = Salary_Amount from Salary_Generation where Emp_ID = @Emp_ID and Month = @Month and Year = @Year
							select @P_Days = isnull(Present_Days,0) ,@Sal=Basic_Salary,@A_Days = isnull(Absent_Days,0),@TDS=isnull(M_IT_TAX,0), @Basic_Salary = Salary_Amount + Isnull(Basic_Salary_Arear_cutoff,0), @Act_Gross_salary = Actually_Gross_salary,@Settl = Settelement_Amount,@OTher_Allow = ISNULL(Other_Allow_Amount,0),@Total_Allowance = Allow_Amount, @Leave_Amount = isnull(Leave_Salary_Amount,0),
								@Round_Value = Isnull(Total_Earning_Fraction ,0) , @Net_Round_Value = ISNULL(Net_Salary_Round_Diff_Amount,0),@OT_Amount = (ISNULL(OT_Amount,0) + ISNULL(M_WO_OT_Amount,0) + isnull(M_HO_OT_Amount,0)) ,@GatePass_Deduct_Days = ISNULL(GatePass_Deduct_Days,0),@GatePass_Amount = ISNULL(GatePass_Amount,0), -- Added by Gadriwala Muslim 10112014
								@Asset_Installment=Asset_Installment --Added By Mukti 01042015
								,@TravelAmount=Travel_Amount --Added by Sumit 24092015
								,@TravelAdvanceAmt=Travel_Advance_Amount,@Bonus = Isnull(Bonus_Amount,0),@Arear_Days=isnull(Arear_Day,0)
								,@Arear_Basic=ISNULL(Arear_Basic,0),@Uniform_Installment=Uniform_Dedu_Amount,@Uniform_Refund_Installment=Uniform_Refund_Amount,@Claim_Amount=Total_Claim_Amount
							from dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year 
						End
					Else
						Begin
							select @P_Days = isnull(S_Sal_Cal_Days,0) ,@Sal=S_Basic_Salary,@A_Days = 0,@TDS=isnull(S_M_IT_TAX,0), @Basic_Salary = S_Salary_Amount, @Act_Gross_salary = S_Actually_Gross_salary,@Settl = 0,@OTher_Allow = ISNULL(S_Other_Allow_Amount,0),@Total_Allowance = S_Allow_Amount, @Leave_Amount = 0 , @OT_Amount = ISNULL(S_OT_Amount,0)
							from dbo.T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
							where Emp_ID = @Emp_ID and Month(S_Month_End_date) = @Month and Year(S_Month_End_date) = @Year 
									and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
						End
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,S_Sal_Tran_ID)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'P Days', @P_Days,'',2,'P' ,@Curr_S_Sal_Tran_ID)
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,S_Sal_Tran_ID)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'A Days', @A_Days,'',3,'P',@Curr_S_Sal_Tran_ID)
					
				/*	INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Gross', @Act_Gross_salary,'',4)*/

					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Rate,S_Sal_Tran_ID)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'Basic', @Basic_Salary,'',5,'I',@Sal,@Curr_S_Sal_Tran_ID)
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,S_Sal_Tran_ID)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Settl', @Settl,'',6,'I',@Curr_S_Sal_Tran_ID)
					
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,S_Sal_Tran_ID)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Other', @OTher_Allow,'',7,'I',@Curr_S_Sal_Tran_ID)

					--INSERT INTO dbo.#Temp_Salary_Muster_Report
					--(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					--VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Asset Installment Amount', @OTher_Allow,'',8,'I')
				 
					--SELECT Label_Name ,Row_ID FROM dbo.#TEMP_REPORT_LABEL where Row_ID > 7

					--Added by Hardik 02/01/2016 for Performance
					INSERT INTO dbo.#Temp_Salary_Muster_Report
						(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,S_Sal_Tran_ID)
					Select @Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, Label_Name, 0,'',Row_ID,'',@Curr_S_Sal_Tran_ID 
					from dbo.#TEMP_REPORT_LABEL where Row_ID > 7
					
					--Commented by Hardik 02/01/2016 for Performance
					--Declare Cur_Label cursor for 
					--SELECT Label_Name ,Row_ID FROM dbo.#TEMP_REPORT_LABEL where Row_ID > 7
					--open Cur_label
					--fetch next from Cur_label into @Label_Name ,@Row_ID
					--while @@fetch_Status = 0
					--	begin
					--		INSERT INTO dbo.#Temp_Salary_Muster_Report
					--		(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,S_Sal_Tran_ID)
					--		VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, @Label_Name, 0,'',@Row_ID,'',@Curr_S_Sal_Tran_ID)
							
					--		fetch next from Cur_label into @Label_Name,@Row_ID
					--	end
					--close Cur_Label
					--deallocate Cur_Label
					
					
					--select 'Temp'
					--Select * From #Temp_Salary_Muster_Report
					--Select 'Temp'
					--select Ad_Sort_Name ,M_Ad_Amount,t0050_ad_master.AD_Flag,MAD.Emp_Id, Case when t0050_ad_master.AD_PERCENTAGE > 0 then t0050_ad_master.AD_PERCENTAGE Else MAD.M_AD_Actual_per_Amount End  						     
					--	r from t0210_monthly_ad_detail MAD inner join
					--		t0050_ad_master on MAD.Ad_Id = t0050_ad_master.Ad_ID  Left Outer join #Temp_Salary_Muster_Report
					--		on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID 
					--		and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
					--		and MAD.Emp_ID  = @Emp_ID
					--	where 
					--	MAD.Cmp_ID = @Cmp_ID and month(MAD.For_Date) =  @Month and Year(MAD.For_Date) = @Year
					--	and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I' and MAD.Emp_ID  = @Emp_ID

					  Update  #Temp_Salary_Muster_Report
					  set M_AD_Flage ='I' from #Temp_Salary_Muster_Report E1
					  inner join T0050_AD_MASTER AD
					  on AD.AD_SORT_NAME =E1.Label_Name and ad.cmp_id = e1.cmp_id--Falak,Hardik,Nikunj 16-05-2011
					  where E1.Emp_ID =@Emp_ID and E1.Cmp_ID=@Cmp_ID
					   and AD.AD_Flag ='I'  
					   and E1.S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID		
					   


					Declare @AD_Flage as char(1)
					Declare @AD_percentage as varchar(1000)
					set @Label_Name  = ''


					If @Sal_Type = 1
						BEGIN
 							UPDATE    dbo.#Temp_Salary_Muster_Report
 							SET Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
								Amount =  Amount + MAD.M_AD_Amount + Isnull(MAD.M_AREAR_AMOUNT,0) + Isnull(MAD.M_AREAR_AMOUNT_Cutoff,0) , Value_String = '',M_AD_Flage=AD_FLAG,
								Rate = Case when   MAD.M_AD_PERCENTAGE > 0 then MAD.M_AD_PERCENTAGE Else   MAD.M_AD_Actual_per_Amount End 
							From t0210_monthly_ad_detail MAD inner join
									t0050_ad_master on MAD.Ad_Id = t0050_ad_master.Ad_ID  inner join #Temp_Salary_Muster_Report
									on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID and MAD.S_Sal_Tran_ID = #Temp_Salary_Muster_Report.S_Sal_Tran_Id
									and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
									and MAD.Emp_ID  = @Emp_ID
									and #Temp_Salary_Muster_Report.S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
									and Label_Name = T0050_AD_MASTER.AD_SORT_NAME
							where MAD.Cmp_ID = @Cmp_ID and month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
								and (isnull(ad_not_effect_salary,0)=0 or isnull(ReimShow,0) =1)   and Ad_Active = 1 and AD_Flag = 'I'
								and MAD.Emp_ID  = @Emp_ID and Sal_Type = @Sal_Type
						End
					Else
						BEGIN
 							UPDATE    dbo.#Temp_Salary_Muster_Report
 							SET Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
								Amount =  Amount + MAD.M_AD_Amount + Isnull(MAD.M_AREAR_AMOUNT,0) + Isnull(MAD.M_AREAR_AMOUNT_Cutoff,0), Value_String = '',M_AD_Flage=AD_FLAG,
								Rate = Case when   MAD.M_AD_PERCENTAGE > 0 then MAD.M_AD_PERCENTAGE Else   MAD.M_AD_Actual_per_Amount End 
							From t0210_monthly_ad_detail MAD inner join
									t0050_ad_master on MAD.Ad_Id = t0050_ad_master.Ad_ID  inner join #Temp_Salary_Muster_Report
									on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID and MAD.Sal_Tran_ID = #Temp_Salary_Muster_Report.S_Sal_Tran_Id
									and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
									and MAD.Emp_ID  = @Emp_ID
									and Label_Name = T0050_AD_MASTER.AD_SORT_NAME
							where MAD.Cmp_ID = @Cmp_ID and month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
								and (isnull(ad_not_effect_salary,0)=0 or isnull(ReimShow,0) =1)   and Ad_Active = 1 and AD_Flag = 'I'
								and MAD.Emp_ID  = @Emp_ID and Sal_Type = @Sal_Type
						End
					
				
								
--Added By Mukti(start)24032017
					Declare @AD_Id as Numeric
					Declare @Percentage as numeric(18,2)
					Declare @M_AREAR_AMOUNT as Numeric(18,2)	
					Declare @S_Total_Deduction_1 as Numeric(18,2)
					Declare @With_Arear_Amount tinyint
					Set @With_Arear_Amount = 0

					Set @S_Total_Deduction_1 = 0		
					
					declare Cur_Allow   cursor for
						select distinct Ad_Sort_Name ,M_Ad_Amount+ Isnull(MAD.M_AREAR_AMOUNT,0) + Isnull(MAD.M_AREAR_AMOUNT_Cutoff,0),t0050_ad_master.AD_Flag,
						  Case 
						     when   MAD.M_AD_PERCENTAGE > 0 then MAD.M_AD_PERCENTAGE
						     Else   MAD.M_AD_Actual_per_Amount
						   End  
						   ,M_AREAR_AMOUNT	--Alpesh 3-Aug-2012  
						 from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID  inner join #Temp_Salary_Muster_Report
							on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID 
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Cmp_ID and month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
						and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I'
						and (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0 AND t0050_ad_master.Hide_In_Reports=1  THEN 0 ELSE 1 END) = 1
						--and AD_DEF_ID <> @ProductionBonus_Ad_Def_Id
					open cur_allow
					fetch next from cur_allow  into @Allow_Name,@Amount,@AD_Flage,@Percentage,@M_AREAR_AMOUNT	--Alpesh 3-Aug-2012
					while @@fetch_status = 0
						begin
							
							select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like @Allow_Name --And 
							--select * From #TEMP_REPORT_LABEL where Label_Name like @Allow_Name 
							--Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID,
 							UPDATE    dbo.#Temp_Salary_Muster_Report
 							SET              Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
 												  Amount = @Amount, Value_String = '',M_AD_Flage=@AD_Flage,Rate =@Percentage
 							where   Label_Name = @Allow_Name and Row_id = @row_Id                  
 									and Emp_ID = @Emp_ID  
 									
 							Set @Arear_Earn_Amount = @Arear_Earn_Amount	+ isnull(@M_AREAR_AMOUNT,0)	--Alpesh 3-Aug-2012 
 							
 							
							fetch next from cur_allow  into @Allow_Name,@Amount,@AD_Flage,@Percentage,@M_AREAR_AMOUNT	--Alpesh 3-Aug-2012
						end
					close cur_Allow
					deallocate Cur_Allow


					declare Cur_Dedu   cursor for
						select distinct  t0050_ad_master.AD_ID,Ad_Sort_Name ,M_Ad_Amount+ Isnull(MAD.M_AREAR_AMOUNT,0) + Isnull(MAD.M_AREAR_AMOUNT_Cutoff,0),t0050_ad_master.AD_Flag,  
						   Case 
						     when   t0050_ad_master.AD_PERCENTAGE > 0 then t0050_ad_master.AD_PERCENTAGE
						     Else   MAD.M_AD_Actual_Per_Amount
						   End ,M_AREAR_AMOUNT	
						  from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID inner  join #Temp_Salary_Muster_Report
							on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID 
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Cmp_ID and Month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
						and Ad_Active = 1 and AD_Flag = 'D' and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0)=0 
					open Cur_Dedu
					fetch next from cur_DEDU  into @Ad_Id, @Allow_Name ,@Amount,@AD_Flage,@Percentage,@M_AREAR_AMOUNT	--Alpesh 3-Aug-2012
					while @@fetch_status = 0
						begin
							Set @S_Total_Deduction_1 = 0
							
							If @With_Arear_Amount = 1
								Begin
									
									Select  @S_Total_Deduction_1 = Isnull(SUM(M_AD_Amount),0)  
									From t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
										T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.Sal_Tran_ID=MSS.Sal_Tran_ID inner join 
										T0050_AD_MASTER WITH (NOLOCK) on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
										and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
									Where MAD.Cmp_ID = @Cmp_ID and month(MSS.S_Eff_Date) =  MONTH(@To_Date) and Year(MSS.S_Eff_Date) = YEAR(@To_Date)
										and isnull(T0050_AD_MASTER.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 
										and AD_Flag = 'D' And Sal_Type = 1
										And MAD.AD_ID = @Ad_Id And MAD.Emp_ID  = @Emp_ID
								End
						
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like @Allow_Name 
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Amount + Isnull(@S_Total_Deduction_1,0), 
												  Value_String = '',M_AD_Flage=@AD_Flage,Rate =@Percentage
								WHERE     (Label_Name = @Allow_Name) AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
									
									--select * from #Temp_Salary_Muster_Report
							Set @Arear_Dedu_Amount = @Arear_Dedu_Amount	+ isnull(@M_AREAR_AMOUNT,0)
							
																
							fetch next from cur_DEDU  into @Ad_Id, @Allow_Name ,@Amount,@AD_Flage,@Percentage,@M_AREAR_AMOUNT	--Alpesh 3-Aug-2012
						end
					close Cur_Dedu
					deallocate Cur_Dedu
					
					--Set @Arear_Net = (@Arear_Basic + @Arear_Earn_Amount) - @Arear_Dedu_Amount	
					Set @Arear_Net = (@Arear_Basic + @Arear_Earn_Amount) --Mukti(24032017)
										
					Select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Arr.Amt'
					UPDATE    dbo.#Temp_Salary_Muster_Report
					SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
										 Amount = @Arear_Net, Value_String = '',M_AD_Flage='I'
					WHERE     (Label_Name = 'Arr.Amt') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
					--Added By Mukti(end)24032017

					--   Declare @Percentage as numeric(19,2)
					--	declare Cur_Allow  cursor fast_forward for
					--		select Distinct Ad_Sort_Name ,case WHEN isnull(MAD.ReimShow,0) = 1 then ReimAmount else MAD.M_AD_Amount End,t0050_ad_master.AD_Flag, --change by Ripal 21Nov2014
					--	  Case 
					--	     when   MAD.M_AD_PERCENTAGE > 0 then MAD.M_AD_PERCENTAGE
					--	     Else   MAD.M_AD_Actual_per_Amount
					--	   End  
						     
					--	 from t0210_monthly_ad_detail MAD inner join
					--		t0050_ad_master on MAD.Ad_Id = t0050_ad_master.Ad_ID  inner join #Temp_Salary_Muster_Report 
					--		on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID 
					--		and MAD.S_Sal_Tran_ID = #Temp_Salary_Muster_Report.S_Sal_Tran_Id and
					--		 MAD.Cmp_ID = t0050_ad_master.Cmp_Id
					--		and MAD.Emp_ID  = @Emp_ID
					--		and #Temp_Salary_Muster_Report.S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
					--	where 
					--	MAD.Cmp_ID = @Cmp_ID and month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
					--	and (isnull(ad_not_effect_salary,0)=0 or isnull(ReimShow,0) =1)   and Ad_Active = 1 and AD_Flag = 'I'
					--	and MAD.Emp_ID  = @Emp_ID and Sal_Type = @Sal_Type
					--open cur_allow
					--fetch next from cur_allow  into @Allow_Name ,@Amount,@AD_Flage,@Percentage
					--while @@fetch_status = 0
					--	begin
							
					--		select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like @Allow_Name --And 
					--		--select * From #TEMP_REPORT_LABEL where Label_Name like @Allow_Name 
					--		--Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID,
							
 				--			UPDATE    dbo.#Temp_Salary_Muster_Report
 				--			SET              Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
 				--								  Amount =  Amount + @Amount, Value_String = '',M_AD_Flage=@AD_Flage,Rate =@Percentage --change by Ripal 21Nov2014
 				--			where   Label_Name = @Allow_Name and Row_id = @row_Id                  
 				--					and Emp_ID = @Emp_ID  
 				--					--and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
 									
					--		fetch next from cur_allow  into @Allow_Name,@Amount,@AD_Flage,@Percentage
					--	end
					--close cur_Allow
					--deallocate Cur_Allow
					
				--Select * From #Temp_Salary_Muster_Report Where emp_Id=1 And MONTH=2 And Year=2011


						/*select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Oth A'		

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Other_Allow, Value_String = ''
						where   Label_Name = 'Oth A' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID*/

						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'CO A'		

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @CO_Amount, Value_String = '',M_AD_Flage='I' 
						where   Label_Name = 'CO A' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
								and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID

								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Leave Amt'		

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Leave_Amount, Value_String = '',M_AD_Flage='I' 
						where   Label_Name = 'Leave Amt' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
								and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gross'

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											 Amount = @Total_Allowance+@Basic_Salary+isnull(@Settl,0)+ISNULL(@OTher_Allow,0)+isnull(@CO_Amount,0) + ISNULL(@Leave_Amount,0) + isnull(@OT_Amount,0) + isnull(@Arear_Net,0), Value_String = '',M_AD_Flage='I'
						WHERE     (Label_Name = 'Gross') AND (Row_id = @Row_ID)
								  and Emp_ID = @Emp_ID
								  and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
						
				
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gross Round'

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
										 Amount = ISNULL(@Round_Value , 0), 
										 Value_String = '',M_AD_Flage='I'
						WHERE     (Label_Name = 'Gross Round') AND (Row_id = @Row_ID)
								  and Emp_ID = @Emp_ID
								  and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Total Gross'

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
										 Amount = ISNULL(@Round_Value , 0) + Isnull(@Total_Allowance,0) + Isnull(@Basic_Salary,0) + isnull(@Settl,0)+ISNULL(@OTher_Allow,0)+isnull(@CO_Amount,0) + ISNULL(@Leave_Amount,0)+ isnull(@OT_Amount,0), 
										 Value_String = '',M_AD_Flage='I'
						WHERE     (Label_Name = 'Total Gross') AND (Row_id = @Row_ID)
								  and Emp_ID = @Emp_ID
								  and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
							
						/*select @Amount = M_Ad_Calculated_Amount From t0210_monthly_ad_detail where Emp_Id =@Emp_ID and Month(For_Date)=  @month and YEar(For_Date) = @Year and Ad_ID =2
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'PF Salary'	*/	
					
						
						/*UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Amount, Value_String = ''
						where   Label_Name = 'PF Salary' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
								*/
						set @Amount =0

						/*select @Amount = M_AD_Calculated_Amount From t0210_monthly_ad_detail where Emp_Id = @Emp_ID and Month(For_Date)=  @month and YEar(For_Date) = @Year and Ad_ID =3 and M_Ad_Amount >0
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'ESIC Salary'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Amount, Value_String = ''
						where   Label_Name = 'ESIC Salary' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID*/
					--commented by Mukti(start)27032017
					--If @Sal_Type = 1
					--	BEGIN
					--			UPDATE    dbo.#Temp_Salary_Muster_Report
 				--					SET Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
					--					Amount =  Amount + MAD.M_AD_Amount, Value_String = '',M_AD_Flage=AD_FLAG,
					--					Rate = Case when   MAD.M_AD_PERCENTAGE > 0 then MAD.M_AD_PERCENTAGE Else   MAD.M_AD_Actual_per_Amount End 
					--				From t0210_monthly_ad_detail MAD inner join
					--						t0050_ad_master on MAD.Ad_Id = t0050_ad_master.Ad_ID  inner join #Temp_Salary_Muster_Report
					--						on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID and MAD.S_Sal_Tran_ID = #Temp_Salary_Muster_Report.S_Sal_Tran_Id
					--						and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
					--						and MAD.Emp_ID  = @Emp_ID
					--						and #Temp_Salary_Muster_Report.S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
					--						and Label_Name = T0050_AD_MASTER.AD_SORT_NAME
					--				where MAD.Cmp_ID = @Cmp_ID and month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
					--					and isnull(ad_not_effect_salary,0)=0   and Ad_Active = 1 and AD_Flag = 'D'
					--					and MAD.Emp_ID  = @Emp_ID and Sal_Type = @Sal_Type
					--	END
					--ELSE
					--	BEGIN
					--			UPDATE    dbo.#Temp_Salary_Muster_Report
 				--					SET Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
					--					Amount =  Amount + MAD.M_AD_Amount, Value_String = '',M_AD_Flage=AD_FLAG,
					--					Rate = Case when   MAD.M_AD_PERCENTAGE > 0 then MAD.M_AD_PERCENTAGE Else   MAD.M_AD_Actual_per_Amount End 
					--				From t0210_monthly_ad_detail MAD inner join
					--						t0050_ad_master on MAD.Ad_Id = t0050_ad_master.Ad_ID  inner join #Temp_Salary_Muster_Report
					--						on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID and MAD.Sal_Tran_ID = #Temp_Salary_Muster_Report.S_Sal_Tran_Id
					--						and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
					--						and MAD.Emp_ID  = @Emp_ID
					--						and Label_Name = T0050_AD_MASTER.AD_SORT_NAME
					--				where MAD.Cmp_ID = @Cmp_ID and month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
					--					and isnull(ad_not_effect_salary,0)=0   and Ad_Active = 1 and AD_Flag = 'D'
					--					and MAD.Emp_ID  = @Emp_ID and Sal_Type = @Sal_Type
					--	END
					--commented by Mukti(end)27032017
					
					--declare Cur_Dedu   cursor fast_forward for
					--	select Ad_Sort_Name ,M_Ad_Amount,t0050_ad_master.AD_Flag,  
					--	Case 
					--	     when   t0050_ad_master.AD_PERCENTAGE > 0 then t0050_ad_master.AD_PERCENTAGE
					--	     Else   MAD.M_AD_Actual_Per_Amount
					--	   End 
					--	  from t0210_monthly_ad_detail MAD inner join
					--		t0050_ad_master on MAD.Ad_Id = t0050_ad_master.Ad_ID inner  join #Temp_Salary_Muster_Report
					--		on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID 
					--		and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
					--		and MAD.Emp_ID  = @Emp_ID and Sal_Type = @Sal_Type
					--	where 
					--	MAD.Cmp_ID = @Cmp_ID and Month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
					--	and Ad_Active = 1 and AD_Flag = 'D' and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0)=0 
					--	and MAD.Emp_ID  = @Emp_ID
					--	and #Temp_Salary_Muster_Report.S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
					--open Cur_Dedu
					--fetch next from cur_DEDU  into @Allow_Name ,@Amount,@AD_Flage,@Percentage
					--while @@fetch_status = 0
					--	begin
					--		select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like @Allow_Name 
							
							
					--			UPDATE    dbo.#Temp_Salary_Muster_Report
					--			SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Amount, 
					--							  Value_String = '',M_AD_Flage=@AD_Flage,Rate =@Percentage
					--			WHERE     (Label_Name = @Allow_Name) AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
					--				and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
									
						
									
					--		fetch next from Cur_Dedu into @Allow_Name,@Amount,@AD_Flage,@Percentage
					--	end
					--close Cur_Dedu
					--deallocate Cur_Dedu
					
					-- Select * from #Temp_Salary_Muster_Report
					  Update  #Temp_Salary_Muster_Report
					  set M_AD_Flage ='D' from #Temp_Salary_Muster_Report E1
					  inner join T0210_MONTHLY_AD_DETAIL E on E1.Emp_ID =E.Emp_ID inner join T0050_AD_MASTER AD
					  on AD.AD_ID =E.AD_ID where E1.Emp_ID =@Emp_ID and E1.Cmp_ID=@Cmp_ID
					   and E1.M_AD_Flage ='' 
					   and E1.S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
					
					  Update  #Temp_Salary_Muster_Report
					  set M_AD_Flage =AD_Flag from #Temp_Salary_Muster_Report E1
					  inner join T0050_AD_MASTER AD
					  on AD.Ad_Sort_Name =E1.Label_Name where E1.Emp_ID =@Emp_ID and E1.Cmp_ID=@Cmp_ID
					   and E1.M_AD_Flage ='' 
					   and E1.S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
					 
					   
						If @Sal_Type = 0
							select @Total_Deduction = Total_Dedu_Amount ,@PT = PT_Amount ,@Loan =  ( Loan_Amount + Loan_Intrest_Amount ) 
									,@Advance =  Advance_Amount ,@Net_Salary = Net_Amount ,@Revenue_Amt =Revenue_amount,@LWF_Amt =LWF_Amount,@Other_Dedu=Other_Dedu_Amount,
									@Deficit_Amt = Isnull(Deficit_Dedu_Amount,0),@Asset_Installment=Asset_Installment
									,@TravelAmount=Travel_Amount,@TravelAdvanceAmt=Travel_Advance_Amount
									,@Uniform_Installment=Uniform_Dedu_Amount,@Uniform_Refund_Installment=Uniform_Refund_Amount,@Claim_Amount=Total_Claim_Amount
									,@Late_Deduction = Late_Dedu_Amount
							from T0200_Monthly_salary WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
						Else
							select @Total_Deduction = S_Total_Dedu_Amount ,@PT = S_PT_Amount ,@Loan =  (S_Loan_Amount + S_Loan_Intrest_Amount ) 
									,@Advance =  S_Advance_Amount ,@Net_Salary = S_Net_Amount ,@Revenue_Amt =S_Revenue_Amount,@LWF_Amt =S_LWF_Amount,@Other_Dedu=S_Other_Dedu_Amount
							from T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
							where Emp_ID = @Emp_ID and Month(S_Month_End_Date) = @Month and Year(S_Month_End_Date) = @Year
								and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
							
				
						--Select @Other_Dedu  = 0
						
					--	set @Loan = @Loan + @Advance

		--				select @Row_ID = Row_ID from Temp_report_label where Label_Name like 'Other Dedu'

		--				INSERT INTO Temp_Salary_Muster_Report


		--						   (Emp_ID, Company_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
		--				VALUES     (@Emp_ID, @Company_ID, @Transaction_ID, @Month, @Year, 'Other Dedu', @Other_Dedu,'',@Row_ID)
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'PT'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @PT, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'PT') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Loan'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Loan, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Loan') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
								
								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Advnc'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Advance, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Advnc') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
						
						
						--if @Revenue_Amt >0
							--begin
								--select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Revenue'
								
								--UPDATE    dbo.#Temp_Salary_Muster_Report
								--SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Revenue_Amt, 
								--					  Value_String = '', M_AD_Flage ='P'
								--WHERE     (Label_Name = 'Revenue') AND (Row_id = @Row_ID)
								--		and Emp_ID = @Emp_ID
										
							--end
							--Else
							 --begin
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Revenue'
								
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Revenue_Amt, 
													  Value_String = '', M_AD_Flage ='D'
								WHERE     (Label_Name = 'Revenue') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
										and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
										
							--end
							
						--if @LWF_amt > 0
							--begin
							--	select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'LWF'
								
							--	UPDATE    dbo.#Temp_Salary_Muster_Report
								--SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @lwf_Amt, 
								--					  Value_String = '',M_AD_Flage ='P'
							--	WHERE     (Label_Name = 'LWF') AND (Row_id = @Row_ID)
							--			and Emp_ID = @Emp_ID
							--end		
						  --else
						   -- begin
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'LWF'
								
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @lwf_Amt, 
													  Value_String = '',M_AD_Flage ='D'
								WHERE     (Label_Name = 'LWF') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
										and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
							--end							
								
					
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'TDS'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @TDS, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'TDS') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Oth De'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Other_Dedu, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Oth De') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Deficit Amt'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Deficit_Amt, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Deficit Amt') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID

						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Dedu'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Total_Deduction, Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Dedu') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID	
								and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
						
						
						--added by jimit 28072017
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Late Dedu.'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Late_Deduction, Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Late Dedu.') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID	
								and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
						--ended		
						
						--Added by Gadriwala Muslim 09012015 - Start		
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gate Pass'
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @GatePass_Amount, 
											  Value_String = '',M_AD_Flage='D'
								WHERE     (Label_Name = 'Gate Pass') AND (Row_id = @Row_ID)
									and Emp_ID = @Emp_ID	
									and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID		
						--Added by Gadriwala Muslim 09012015 - End
						
						--Added by Mukti 01042015 - Start	
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Asset Inst.'
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Asset_Installment, 
											  Value_String = '',M_AD_Flage='D'
								WHERE     (Label_Name = 'Asset Inst.') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID	
									and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID		
								
						--Added by Sumit 24092015 - Start	
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Travel Amt'
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @TravelAmount, 
											  Value_String = '',M_AD_Flage='I'
								WHERE     (Label_Name = 'Travel Amt') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID		
									and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID			
						
						--Added by Sumit 24092015 - Start	
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'TravelAdAmt'
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @TravelAdvanceAmt, 
											  Value_String = '',M_AD_Flage='D'
								WHERE     (Label_Name = 'TravelAdAmt') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'OT'
						
							--ADDED BY GADRIWALA MUSLIM 23122016 - START
							Update dbo.#Temp_Salary_Muster_Report
							SET  Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
												   Amount = @OT_Amount, Value_String = '',M_AD_Flage='I' 
							where   Label_Name = 'OT' and Row_id = @row_Id                    
									and Emp_ID = @Emp_ID
									and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
							--ADDED BY GADRIWALA MUSLIM 23122016 - END
							select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Bonus'
							
							--ADDED BY GADRIWALA MUSLIM 23122016 - START
							Update dbo.#Temp_Salary_Muster_Report
							SET  Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
												   Amount = @Bonus, Value_String = '',M_AD_Flage='I' 
							where   Label_Name = 'Bonus' and Row_id = @row_Id                    
									and Emp_ID = @Emp_ID
									and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
							--ADDED BY GADRIWALA MUSLIM 23122016 - END
							
						--Added by Mukti 23052017 - Start	
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Uni.Inst.'
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Uniform_Installment, 
											  Value_String = '',M_AD_Flage='D'
								WHERE     (Label_Name = 'Uni.Inst.') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID	
									and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID		
					
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Uni.Refund Inst.'
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Uniform_Refund_Installment, 
											  Value_String = '',M_AD_Flage='I'
								WHERE     (Label_Name = 'Uni.Refund Inst.') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID	
									and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID					
						--Added by Mukti 23052017 - end	
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Claim Amt'
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Claim_Amount, 
											  Value_String = '',M_AD_Flage='I'
								WHERE     (Label_Name = 'Claim Amt') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID	
									and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID					
						--select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Net'
						
						--UPDATE    dbo.#Temp_Salary_Muster_Report
						--SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Net_Salary, 
						--					  Value_String = '',M_AD_Flage='N'
						--WHERE     (Label_Name = 'Net') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Net'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = Isnull(@Net_Salary,0) - Isnull(@Net_Round_Value,0), 
											  Value_String = '',M_AD_Flage='N'
						WHERE     (Label_Name = 'Net') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
								and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
						
								
						Select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Net Round'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = Isnull(@Net_Round_Value, 0),
											  Value_String = '',M_AD_Flage='N'
						WHERE     (Label_Name = 'Net Round') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
								and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
						
						Select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Net Payable'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Net_Salary ,
											  Value_String = '',M_AD_Flage='N'
						WHERE     (Label_Name = 'Net Payable') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
								and S_Sal_Tran_ID = @Curr_S_Sal_Tran_ID
								
			FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@Curr_S_Sal_Tran_ID
		END
	Close Cur_Emp
	Deallocate Cur_emp	
	
	
	Update dbo.#Temp_Salary_Muster_Report Set Month = MONTH(@To_Date), Year = YEAR(@To_Date)

	-- Ankit 15072014 --

	If @Round_Value = 0
		Begin
			Delete From dbo.#Temp_Salary_Muster_Report Where Label_Name = 'Gross Round'
			Delete From dbo.#Temp_Salary_Muster_Report Where Label_Name = 'Total Gross'
		End 
	
	If	@Net_Round_Value = 0
		Begin
			Delete From dbo.#Temp_Salary_Muster_Report Where Label_Name = 'Net Payable'
			Delete From dbo.#Temp_Salary_Muster_Report Where Label_Name = 'Net Round'
		End
		
	-- Ankit 15072014 --
	
	delete #Temp_Salary_Muster_Report Where Row_Id in (Select Row_Id from #Temp_Salary_Muster_Report where row_id >7 group by Row_Id having sum(amount)=0 )
	
	--SELECT * from #Temp_Salary_Muster_Report
	---Record set 1 for Regular record
	-- Changed By Ali 22112013 EmpName_Alias
	select dbo.#Temp_Salary_Muster_Report.* 
	,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) as Emp_Full_Name ,E.Alpha_Emp_Code as 'Emp_Code',GM.Grd_name,ETM.Type_name,DGM.Desig_Name,DM.Dept_Name,BM.Branch_Name, 
	E.Dept_ID,Cmp_Name,Cmp_Address,isnull(Inc_Qry.Inc_Bank_Ac_no,'')as Inc_Bank_Ac_no,isnull(Inc_Qry.Payment_Mode,'') as Payment_Mode,E.Father_name ,E.Alpha_Emp_Code, RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) as Ord_Emp_code,E.Emp_First_Name as ord_Name,isnull(VS.Vertical_Name,'') as Vertical_Name , isnull(SV.SubVertical_Name,'') as SubVertical_Name
		,DGM.Desig_Dis_No,E.Emp_First_Name  --Added by Gadriwala Muslim 23122016        --added jimit 24082015
		,BM.Comp_Name,BM.Branch_Address, --add by chetan 27-12-16
		E.Worker_Adult_no,ISNULL(BA.bank_name,'')as Bank_Name,case when e.Gender='M' then 'Male' else 'Female' end as[Gender], Inc_Qry.Grd_ID,Inc_Qry.Type_ID,Inc_Qry.Desig_Id,
		Inc_Qry.Branch_ID,Inc_Qry.Vertical_ID,Inc_Qry.SubVertical_ID, Inc_Qry.subBranch_ID,SB.SubBranch_Name, E.Date_Of_Join,E.SIn_No
	Into #Temp_Salary_Muster_Report1 -- Added by Hardik 17/04/2019
	from dbo.#Temp_Salary_Muster_Report Inner join 
		T0080_Emp_Master E WITH (NOLOCK) on dbo.#Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID 
		inner join
		 	(select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Inc_Bank_Ac_no,Branch_ID,Type_ID,Payment_Mode,Vertical_ID ,SubVertical_ID,Bank_ID, I.subBranch_ID 
		 	   from t0095_Increment I WITH (NOLOCK)
		 		INNER JOIN 
						( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
							FROM T0095_INCREMENT I WITH (NOLOCK)
							INNER JOIN #TEMP_SALARY_MUSTER_REPORT T ON T.EMP_ID = I.EMP_ID 
							INNER JOIN 
							(
									SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
									FROM T0095_INCREMENT I3 WITH (NOLOCK)
									WHERE I3.Increment_effective_Date <= @To_Date and I3.Cmp_ID = @Cmp_ID
									GROUP BY I3.EMP_ID  
								) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID	
						   where I.INCREMENT_EFFECTIVE_DATE <= @To_Date and I.Cmp_ID = @Cmp_ID 
						   group by I.emp_ID  
						) Qry on	I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID 
					)Inc_Qry on E.Emp_ID = Inc_Qry.Emp_ID -- code by Rohit Rajput 04032017 Ends
		left outer join t0040_department_Master WITH (NOLOCK)
		on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID LEFT OUTER JOIN
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_ID = GM.Grd_ID					LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON Inc_Qry.Type_ID = ETM.Type_ID				LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Inc_Qry.Desig_Id = DGM.Desig_Id		LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Inc_Qry.Dept_Id = DM.Dept_Id			INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.BRANCH_ID = BM.BRANCH_ID			LEFT OUTER JOIN
					T0040_Vertical_Segment VS WITH (NOLOCK) on Inc_Qry.Vertical_ID = VS.Vertical_ID	LEFT OUTER JOIN			--Added By Ramiz on 13022015
					T0050_SubVertical SV WITH (NOLOCK) on Inc_Qry.SubVertical_ID = SV.SubVertical_ID	LEFT OUTER JOIN			--Added By Ramiz on 13022015
					T0040_BANK_MASTER BA WITH (NOLOCK) on BA.bank_id=Inc_Qry.Bank_ID  LEFT OUTER JOIN  --Mukti(04032017)
					T0050_SubBranch SB WITH (NOLOCK) On Inc_Qry.subBranch_ID = SB.SubBranch_ID -- Added by Hardik 18/04/2019
		 inner join t0010_company_master CM WITH (NOLOCK) on E.cmp_id=CM.cmp_id
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End,Row_ID
		--order by RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500),Row_ID
	
	If @Summary_Option = 0
	Begin
		Select  *,1 as Emp_Count ,'' as ReportGroupName from #Temp_Salary_Muster_Report1
	End
	Else If @Summary_Option > 0
	Begin
	
	sET @Summary_Option =@Summary_Option - 1

	Declare @sSql as Varchar(max)
	Declare @sSqlSummaryOn as Varchar(5000)
	Declare @sGroupByName as Varchar(5000)
	
	Select @sSqlSummaryOn = Case When @Summary_Option= 0 then 'Grd_ID' 
							Else Case When @Summary_Option= 1 then 'Type_ID' 
							Else Case When @Summary_Option= 2 then 'Dept_ID' 
							Else Case When @Summary_Option= 3 then 'Desig_Id' 
							Else Case When @Summary_Option= 4 then 'Branch_ID' 

							Else Case When @Summary_Option= 5 then 'Vertical_ID' 
							Else Case When @Summary_Option= 6 then 'SubVertical_ID' 
							Else Case When @Summary_Option= 7 then 'subBranch_ID' 

							end end End end end End end end

   Select @sGroupByName = Case When @Summary_Option= 0 then 'Grd_name' 
							Else Case When @Summary_Option= 1 then 'Type_name' 
							Else Case When @Summary_Option= 2 then 'Dept_Name' 
							Else Case When @Summary_Option= 3 then 'Desig_Name' 
							Else Case When @Summary_Option= 4 then 'Branch_Name' 

							Else Case When @Summary_Option= 5 then 'Vertical_Name' 
							Else Case When @Summary_Option= 6 then 'SubVertical_Name' 
							Else Case When @Summary_Option= 7 then 'SubBranch_Name' 

							end end End end end End end end


		 SET @sSql = 'select  isnull(' + @sSqlSummaryOn +',0) as  Emp_ID ,Cmp_ID,Transaction_ID,Month,Year,Label_Name,Sum(Amount) as Amount ,Value_String,INCOME_TAX_ID, max(Row_id) as Row_id ,
		M_AD_Flage,	
		max(Rate) as rate , 
		isnull(' + @sSqlSummaryOn +',0)as S_Sal_Tran_Id, ' + @sGroupByName +' as  Emp_Full_Name, '''' as Emp_Code, '''' as Grd_name, '''' as Type_name, '''' as Desig_Name,
		---isnull(Dept_Name,'') as Dept_Name
		'''' as Dept_Name
		,'''' as Branch_Name,isnull(' + @sSqlSummaryOn +',0) as Dept_Id,Cmp_Name,Cmp_Address,
		'''' as Inc_Bank_Ac_no,'''' as Payment_Mode,'''' as Father_name,'''' as Alpha_Emp_Code,''''as Ord_Emp_code,'''' as ord_Name,
		'''' as Vertical_Name,''''as SubVertical_Name, '''' as Desig_Dis_No,
		'''' as Emp_First_Name,Comp_Name, 
		'''' as Branch_Address, '''' as Worker_Adult_no	, '''' as Bank_Name,NULL as Gender,0 as Grd_ID,0 as Type_ID,0 as Desig_Id,
		0 as Branch_ID	,
		0 as Vertical_ID	,0 as SubVertical_ID,0 as subBranch_ID, '''' as SubBranch_Name,NULL as Date_Of_Join ,max(SIn_No) as SIn_No
		,count(isnull(Emp_Count,0) ) as Emp_Count
		 ,''' + @sGroupByName +'''  as ReportGroupName
		From #Temp_Salary_Muster_Report1
		Left Outer Join (Select Isnull(Count(Distinct Emp_Id),0) as Emp_Count,' + @sSqlSummaryOn +' as cnt_dept_id From #Temp_Salary_Muster_Report1 Group By ' + @sSqlSummaryOn +' ) 
		AS tblCnt On #Temp_Salary_Muster_Report1.' + @sSqlSummaryOn +' = tblCnt.cnt_dept_id
		Group By 
		' + @sSqlSummaryOn +',Cmp_ID,Transaction_ID,Month,Year,Label_Name, Value_String,INCOME_TAX_ID,M_AD_Flage
		, ' + @sGroupByName +',Cmp_Name,Cmp_Address,Comp_Name

		Order by ' + @sGroupByName +' '
		---,Branch_Address,Branch_ID,Branch_Name

		--print @sSql

		exec (@sSql )
		SET @sSql =''

	End


	---Record set 2 for Labels only
	Select Distinct Label_name,Row_ID,M_AD_Flage  from dbo.#Temp_Salary_Muster_Report  
	   --where dbo.#Temp_Salary_Muster_Report.Amount > 0
	 order by Row_ID
	
	----Record set 3 for Total amount
	Select Sum(Amount) as Amount ,Sum(Rate) as Rate,Row_ID,Label_Name,M_AD_Flage from dbo.#Temp_Salary_Muster_Report
	Group by Label_Name,Row_ID,M_AD_Flage 
	order by Row_ID

	---Record set 4 for Payment Record
		Declare @Payment table
		(
		    Amount  numeric(18,2),
		    Row_ID  numeric(18,2),
		    Payment_Mode varchar(50)
		   
		)
		insert into @Payment(Amount,Row_ID,Payment_Mode)
		select Sum(Amount) as Amount,Row_ID,Inc_Qry.Payment_Mode from dbo.#Temp_Salary_Muster_Report Inner join
		T0080_Emp_Master E WITH (NOLOCK) on dbo.#Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
		( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Inc_Bank_Ac_no,Branch_ID,Type_ID,Payment_Mode from t0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID 
		 where Label_Name='Net'
		 Group by Inc_Qry.Payment_Mode,Row_ID,E.Emp_code
		order by Emp_code,Row_ID
		
		
		Select Sum(Amount) as Amount,Row_ID,Payment_Mode from @Payment group by Payment_Mode,Row_ID

	---Record set 5 for Total Rate Record
	Select	
	Sum(Amount) as Amount ,Sum(Rate) as Rate,Row_ID,Label_Name,M_AD_Flage from dbo.#Temp_Salary_Muster_Report
	where M_AD_Flage='I'
	Group by Label_Name,Row_ID,M_AD_Flage 
	order by Row_ID
	
	--Added By Mukti(start)07032017
	Select Sum(Amount) as Amount ,Sum(Rate) as Rate,Row_ID,Label_Name,M_AD_Flage from dbo.#Temp_Salary_Muster_Report
	where M_AD_Flage in('I','D')
	Group by Label_Name,Row_ID,M_AD_Flage 
	order by Row_ID	
	--Added By Mukti(end)07032017

	
	-- Added Below for Group wise Total by Hardik 17/04/2019 for Chiripal
	IF @Group_Name = 0	-- Grade wise
		BEGIN
			SELECT Row_ID, Label_Name, Sum(Amount) as Amount ,Sum(Rate) as Rate,M_AD_Flage,Grd_Name as Group_Name , Grd_Id As Group_Id
			FROM dbo.#Temp_Salary_Muster_Report1
			WHERE M_AD_Flage in('I','D')
			GROUP BY Label_Name,Row_ID,M_AD_Flage,Grd_Name,Grd_Id
			ORDER BY Row_ID	
		END
	ELSE IF @Group_Name = 1 -- Type Name wise
		BEGIN
			SELECT Row_ID, Label_Name, Sum(Amount) as Amount ,Sum(Rate) as Rate,M_AD_Flage,Type_Name as Group_Name , Type_Id As Group_Id
			FROM dbo.#Temp_Salary_Muster_Report1
			WHERE M_AD_Flage in('I','D')
			GROUP BY Label_Name,Row_ID,M_AD_Flage,Type_Name,Type_Id
			ORDER BY Row_ID	
		END
	ELSE IF @Group_Name = 2 -- Department wise
		BEGIN
			SELECT Row_ID, Label_Name, Sum(Amount) as Amount ,Sum(Rate) as Rate,M_AD_Flage,Dept_Name as Group_Name , Dept_Id As Group_Id
			FROM dbo.#Temp_Salary_Muster_Report1
			WHERE M_AD_Flage in('I','D')
			GROUP BY Label_Name,Row_ID,M_AD_Flage,Dept_Name,Dept_Id
			ORDER BY Row_ID	
		END
	ELSE IF @Group_Name = 3 -- Designation wise
		BEGIN
			SELECT Row_ID, Label_Name, Sum(Amount) as Amount ,Sum(Rate) as Rate,M_AD_Flage,Desig_Name as Group_Name , Desig_Id As Group_Id
			FROM dbo.#Temp_Salary_Muster_Report1
			WHERE M_AD_Flage in('I','D')
			GROUP BY Label_Name,Row_ID,M_AD_Flage,Desig_Name,Desig_Id
			ORDER BY Row_ID	
		END
	ELSE IF @Group_Name = 4  -- Branch Wise
		BEGIN
			SELECT Row_ID, Label_Name, Sum(Amount) as Amount ,Sum(Rate) as Rate,M_AD_Flage,Branch_Name as Group_Name , Branch_Id As Group_Id
			FROM dbo.#Temp_Salary_Muster_Report1
			WHERE M_AD_Flage in('I','D')
			GROUP BY Label_Name,Row_ID,M_AD_Flage,Branch_Name,Branch_Id
			ORDER BY Row_ID	
		END
	ELSE IF @Group_Name = 5  -- Vertical Wise
		BEGIN
			SELECT Row_ID, Label_Name, Sum(Amount) as Amount ,Sum(Rate) as Rate,M_AD_Flage,Vertical_Name as Group_Name , Vertical_Id As Group_Id
			FROM dbo.#Temp_Salary_Muster_Report1
			WHERE M_AD_Flage in('I','D')
			GROUP BY Label_Name,Row_ID,M_AD_Flage,Vertical_Name,Vertical_Id
			ORDER BY Row_ID	
		END
	ELSE IF @Group_Name = 6  -- Sub Vertical Wise
		BEGIN
			SELECT Row_ID, Label_Name, Sum(Amount) as Amount ,Sum(Rate) as Rate,M_AD_Flage,SubVertical_Name as Group_Name , SubVertical_Id As Group_Id
			FROM dbo.#Temp_Salary_Muster_Report1
			WHERE M_AD_Flage in('I','D')
			GROUP BY Label_Name,Row_ID,M_AD_Flage,SubVertical_Name,SubVertical_Id
			ORDER BY Row_ID	
		END
	ELSE IF @Group_Name = 7  -- Sub Branch Wise
		BEGIN
			SELECT Row_ID, Label_Name, Sum(Amount) as Amount ,Sum(Rate) as Rate,M_AD_Flage,SubBranch_Name as Group_Name , SubBranch_Id As Group_Id
			FROM dbo.#Temp_Salary_Muster_Report1
			WHERE M_AD_Flage in('I','D')
			GROUP BY Label_Name,Row_ID,M_AD_Flage,SubBranch_Name,SubBranch_Id
			ORDER BY Row_ID	
		END
	ELSE   -- No Group
		BEGIN
			SELECT Row_ID, Label_Name, Sum(Amount) as Amount ,Sum(Rate) as Rate,M_AD_Flage,Null as Group_Name , 0 As Group_Id
			FROM dbo.#Temp_Salary_Muster_Report1
			WHERE M_AD_Flage in('I','D')
			GROUP BY Label_Name,Row_ID,M_AD_Flage
			ORDER BY Row_ID	
		END

	
	RETURN




