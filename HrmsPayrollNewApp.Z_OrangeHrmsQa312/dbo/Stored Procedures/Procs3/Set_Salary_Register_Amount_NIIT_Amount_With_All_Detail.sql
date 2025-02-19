
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Set_Salary_Register_Amount_NIIT_Amount_With_All_Detail]
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
,@PBranch_ID    varchar(5000) = '0'
,@Salary_Cycle_id numeric = 0
,@Segment_ID Numeric = 0 -- Added By mitesh 07082013
,@Vertical_ID Numeric = 0 -- Added By mitesh 07082013
,@SubVertical_ID Numeric = 0 -- Added By mitesh 07082013
,@subBranch_ID Numeric = 0 -- Added By mitesh 07082013

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
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
	Declare @Gross_Salary as numeric(22,2) 
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
		SET @ROUNDING = 0
		
	IF	EXISTS (SELECT * FROM [tempdb].dbo.sysobjects where name like '#Temp_report_Label')		
			BEGIN
				DROP TABLE #Temp_report_Label
			END
		IF	EXISTS (SELECT * FROM [tempdb].dbo.sysobjects where name like '#Temp_Salary_Muster_Report')		
			BEGIN
				DROP TABLE #Temp_Salary_Muster_Report
			END
						
			
	
	CREATE TABLE #Temp_report_Label
	(
	Row_ID  numeric(18, 0) NOt null,
	Label_Name  varchar(200) not null,
	Income_Tax_ID numeric(18, 0) null,
	Is_Active	varchar(1) null
	)
	
	--ALTER index idx_1 on #Temp_report_Label (Row_ID)
	CREATE CLUSTERED INDEX ind_temp ON #Temp_report_Label(Row_ID)
	CREATE NONCLUSTERED INDEX ind_temp6 ON #Temp_report_Label(Label_Name)

		
	CREATE TABLE #Temp_Salary_Muster_Report		
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
		
	)
	CREATE CLUSTERED INDEX ind_temp1	ON #Temp_Salary_Muster_Report(Row_id)
	CREATE NONCLUSTERED INDEX ind_temp2 ON #Temp_Salary_Muster_Report(Emp_ID)
	CREATE NONCLUSTERED INDEX ind_temp3 ON #Temp_Salary_Muster_Report(Cmp_ID)
	CREATE NONCLUSTERED INDEX ind_temp4 ON #Temp_Salary_Muster_Report(Label_Name)
	CREATE NONCLUSTERED INDEX ind_temp5 ON #Temp_Salary_Muster_Report(Value_String)
		
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
			begin    
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

	  
	--EXEC Set_Salary_Register_Lable @Cmp_ID ,@month , @Year
	exec Set_Salary_register_Lable_New @Cmp_ID ,@month , @Year
	
	CREATE TABLE #Emp_Cons 
		(
			Emp_ID	numeric,     
			Branch_ID NUMERIC,
			Increment_ID NUMERIC   
		)
	
	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			select  CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC)  from dbo.Split (@Constraint,'#') 
		end
	else 
		begin
			
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
	
	DECLARE CUR_EMP CURSOR FOR
	SELECT sg.EMP_ID  FROM dbo.T0200_MONTHLY_SALARY SG WITH (NOLOCK)
	--INNER JOIN	T0080_EMP_MASTER E ON sg.EMP_ID =e.EMP_ID 
	INNER JOIN #Emp_Cons ec on SG.Emp_ID = Ec.Emp_ID 
	--Inner join ( select dbo.T0095_Increment.Emp_Id ,Type_ID ,Grd_ID,Dept_ID,Desig_Id,Branch_ID,Cat_ID,Payment_Mode from t0095_Increment inner join 
	--								( select max(Increment_ID) as Increment_ID , Emp_ID from t0095_Increment
	--								where Increment_Effective_date <= @To_Date
	--								and Cmp_ID = @Cmp_ID
	--								group by emp_ID  ) Qry
	--								on t0095_Increment.Emp_ID = Qry.Emp_ID and
	--								t0095_Increment.Increment_ID   = Qry.Increment_ID	
	--						where Cmp_ID = @Cmp_ID ) I_Q on 
	--				e.Emp_ID = I_Q.Emp_ID
	WHERE  sg.Cmp_ID = @Cmp_ID 
	AND Month(sg.Month_End_Date) = @MONTH AND Year(sg.Month_End_Date) = @YEAR And isnull(sg.is_FNF,0)=0
		--AND Payment_Mode LIKE isnull(@PAYEMENT,Payment_Mode)
	OPEN  CUR_EMP
	FETCH NEXT FROM CUR_EMP INTO @EMP_ID
	WHILE @@FETCH_STATUS = 0
		BEGIN
						
						SET @Allow_Name = ''
						SET @Row_id  = 0
						SET @Label_Name  = ''
						SET @Total_Allowance = 0
						SET @Gross_Salary = 0
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
						Declare @OT_Amount as numeric(18,2)
						set @OT_Amount = 0 -- Added by Gadriwala Muslim 10112014
						Declare @Sal as numeric(18,0)
						set @Sal =0
						Declare @GatePass_Deduct_Days numeric(18,2) -- Added by Gadriwala Muslim 09012015
						Declare @GatePass_Amount numeric(18,2) -- Added by Gadriwala Muslim 09012015
						set @GatePass_Deduct_Days = 0
						set @GatePass_Amount = 0 
						Declare @Asset_Installment numeric(18,2) -- Added by Mukti 01042015
						set @Asset_Installment=0  -- Added by Mukti 01042015
						
						Declare @sal_cal_day as Numeric(18,2)
						Declare @Holiday_Days as Numeric(18,2)
						Declare @Weekoff_Days as Numeric(18,2)
						Declare @Outof_Days  As numeric(18,2)
						
						set @sal_cal_day = 0
						set @Holiday_Days = 0
						set @Weekoff_Days = 0
						set @Outof_Days  = 0
						
					If @Sal_Type = 0
						Begin
							--select @P_Days = Present_Days + Holiday_Days , @Basic_Salary = Salary_Amount from Salary_Generation where Emp_ID = @Emp_ID and Month = @Month and Year = @Year
							select @P_Days = isnull(Present_Days,0) ,@Sal= case when i.Wages_Type ='Daily' then ms.Day_Salary else ms.Basic_Salary end,@A_Days = isnull(Absent_Days,0),@TDS=isnull(M_IT_TAX,0), @Basic_Salary = (isnull(Salary_Amount,0) + isnull(Arear_Basic,0)+ isnull(Basic_Salary_Arear_cutoff ,0)), @Act_Gross_salary = Actually_Gross_salary,@Settl = Settelement_Amount,@OTher_Allow = ISNULL(Other_Allow_Amount,0),@Total_Allowance = Allow_Amount,
							@Gross_Salary = isnull(MS.Gross_Salary,0) ,
							 @Leave_Amount = isnull(Leave_Salary_Amount,0),
								@Round_Value = Isnull(Total_Earning_Fraction ,0) , @Net_Round_Value = ISNULL(Net_Salary_Round_Diff_Amount,0),@OT_Amount = (ISNULL(OT_Amount,0) + ISNULL(M_WO_OT_Amount,0) + isnull(M_HO_OT_Amount,0)) ,@GatePass_Deduct_Days = ISNULL(GatePass_Deduct_Days,0),@GatePass_Amount = ISNULL(GatePass_Amount,0), -- Added by Gadriwala Muslim 10112014
								@Asset_Installment=Asset_Installment --Added By Mukti 01042015
								,@sal_cal_day = Sal_Cal_Days,@Holiday_Days = Holiday_Days,@Weekoff_Days = Weekoff_Days,@Outof_Days =Outof_Days
							from dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK)
							inner join dbo.T0095_Increment I WITH (NOLOCK) On MS.increment_id = i.Increment_ID
							where MS.Emp_ID = @Emp_ID and Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year 
						End
					Else
						Begin
							select @P_Days = isnull(S_Sal_Cal_Days,0) ,@Sal=S_Basic_Salary,@A_Days = 0,@TDS=isnull(S_M_IT_TAX,0), @Basic_Salary = S_Salary_Amount, @Act_Gross_salary = S_Actually_Gross_salary,@Settl = 0,@OTher_Allow = ISNULL(S_Other_Allow_Amount,0),@Total_Allowance = S_Allow_Amount, @Leave_Amount = 0 , @OT_Amount = ISNULL(S_OT_Amount,0)
							
							from dbo.T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(S_Month_End_date) = @Month and Year(S_Month_End_date) = @Year 
						End
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'P Days', @P_Days,'',2,'P')
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'A Days', @A_Days,'',3,'P')
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Weekoff', @Weekoff_Days,'',4,'P')
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Holiday', @Holiday_Days,'',5,'P')
					
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Paid Days', @sal_cal_day,'',6,'P')
					
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Total Days', @Outof_Days,'',7,'P')
					
				/*	INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Gross', @Act_Gross_salary,'',4)*/

					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Rate)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'Basic', @Basic_Salary,'',8,'I',@Sal)
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Settl', @Settl,'',9,'I')
					
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Other', @OTher_Allow,'',10,'I')

					--INSERT INTO dbo.#Temp_Salary_Muster_Report
					--(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					--VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Asset Installment Amount', @OTher_Allow,'',8,'I')
				 
					
					Declare Cur_Label cursor for 
					SELECT Label_Name ,Row_ID FROM dbo.#TEMP_REPORT_LABEL where Row_ID > 10
					open Cur_label
					fetch next from Cur_label into @Label_Name ,@Row_ID
					while @@fetch_Status = 0
						begin
							INSERT INTO dbo.#Temp_Salary_Muster_Report
							(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
							VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, @Label_Name, 0,'',@Row_ID,'')
							fetch next from Cur_label into @Label_Name,@Row_ID
						end
					close Cur_Label
					deallocate Cur_Label
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

							
					Declare @AD_Flage as char(1)
					Declare @AD_percentage as varchar(1000)
					set @Label_Name  = ''
					
					   Declare @Percentage as numeric(19,2)
						declare Cur_Allow   cursor for
						select Distinct Ad_Sort_Name ,case WHEN isnull(MAD.ReimShow,0) = 1 then ReimAmount else 
						(isnull(MAD.M_AD_Amount,0) + isnull(MAD.M_AREAR_AMOUNT,0) + isnull(MAD.M_AREAR_AMOUNT_Cutoff,0)) End,t0050_ad_master.AD_Flag, --change by Ripal 21Nov2014
						  Case 
						     when   MAD.M_AD_PERCENTAGE > 0 then MAD.M_AD_PERCENTAGE
						     Else   MAD.M_AD_Actual_per_Amount
						   End  
						     
						 from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID  inner join #Temp_Salary_Muster_Report
							on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID 
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Cmp_ID and month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
						and (isnull(ad_not_effect_salary,0)=0 or isnull(ReimShow,0) =1)   and Ad_Active = 1 and AD_Flag = 'I'
						and MAD.Emp_ID  = @Emp_ID and Sal_Type = @Sal_Type
					open cur_allow
					fetch next from cur_allow  into @Allow_Name ,@Amount,@AD_Flage,@Percentage
					while @@fetch_status = 0
						begin
							
							select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like @Allow_Name --And 
							--select * From #TEMP_REPORT_LABEL where Label_Name like @Allow_Name 
							--Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID,
 							UPDATE    dbo.#Temp_Salary_Muster_Report
 							SET              Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
 												  Amount =  Amount + @Amount, Value_String = '',M_AD_Flage=@AD_Flage,Rate =@Percentage --change by Ripal 21Nov2014
 							where   Label_Name = @Allow_Name and Row_id = @row_Id                  
 									and Emp_ID = @Emp_ID  
							fetch next from cur_allow  into @Allow_Name,@Amount,@AD_Flage,@Percentage
						end
					close cur_Allow
					deallocate Cur_Allow

					
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

								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Leave Amt'		

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Leave_Amount, Value_String = '',M_AD_Flage='I' 
						where   Label_Name = 'Leave Amt' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gross'

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											 --Amount = @Total_Allowance+@Basic_Salary+isnull(@Settl,0)+ISNULL(@OTher_Allow,0)+isnull(@CO_Amount,0) + ISNULL(@Leave_Amount,0) + isnull(@OT_Amount,0), Value_String = ''
											 Amount = @Gross_Salary
											 ,M_AD_Flage='I'
						WHERE     (Label_Name = 'Gross') AND (Row_id = @Row_ID)
								  and Emp_ID = @Emp_ID
						
				
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gross Round'

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
										 Amount = ISNULL(@Round_Value , 0), 
										 Value_String = '',M_AD_Flage='I'
						WHERE     (Label_Name = 'Gross Round') AND (Row_id = @Row_ID)
								  and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Total Gross'

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
										 --Amount = ISNULL(@Round_Value , 0) + Isnull(@Total_Allowance,0) + Isnull(@Basic_Salary,0) + isnull(@Settl,0)+ISNULL(@OTher_Allow,0)+isnull(@CO_Amount,0) + ISNULL(@Leave_Amount,0)+ isnull(@OT_Amount,0), 
										 Amount = ISNULL(@Round_Value , 0) + @Gross_Salary,
										 Value_String = '',M_AD_Flage='I'
						WHERE     (Label_Name = 'Total Gross') AND (Row_id = @Row_ID)
								  and Emp_ID = @Emp_ID
							
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
					
					declare Cur_Dedu   cursor for
						select Ad_Sort_Name 
						, (isnull(MAD.M_AD_Amount,0) + isnull(MAD.M_AREAR_AMOUNT,0) + isnull(MAD.M_AREAR_AMOUNT_Cutoff,0)) as M_Ad_Amount
						,t0050_ad_master.AD_Flag,  
						Case 
						     when   t0050_ad_master.AD_PERCENTAGE > 0 then t0050_ad_master.AD_PERCENTAGE
						     Else   MAD.M_AD_Actual_Per_Amount
						   End 
						  from t0210_monthly_ad_detail MAD WITH (NOLOCK)  inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID inner  join #Temp_Salary_Muster_Report
							on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID 
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID and Sal_Type = @Sal_Type
						where 
						MAD.Cmp_ID = @Cmp_ID and Month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
						and Ad_Active = 1 and AD_Flag = 'D' and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0)=0 
						and MAD.Emp_ID  = @Emp_ID
					open Cur_Dedu
					fetch next from cur_DEDU  into @Allow_Name ,@Amount,@AD_Flage,@Percentage
					while @@fetch_status = 0
						begin
							select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like @Allow_Name 
							
							
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Amount, 
												  Value_String = '',M_AD_Flage=@AD_Flage,Rate =@Percentage
								WHERE     (Label_Name = @Allow_Name) AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
									
						
									
							fetch next from Cur_Dedu into @Allow_Name,@Amount,@AD_Flage,@Percentage
						end
					close Cur_Dedu
					deallocate Cur_Dedu
					
					-- Added by rohit on 26052016
					declare Cur_Dedu   cursor for
						select Ad_Sort_Name 
						, (isnull(MAD.M_AD_Amount,0) + isnull(MAD.M_AREAR_AMOUNT,0) + isnull(MAD.M_AREAR_AMOUNT_Cutoff,0)) as M_Ad_Amount
						,t0050_ad_master.AD_Flag,  
						Case 
						     when   t0050_ad_master.AD_PERCENTAGE > 0 then t0050_ad_master.AD_PERCENTAGE
						     Else   MAD.M_AD_Actual_Per_Amount
						   End 
						  from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID inner  join #Temp_Salary_Muster_Report
							on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID 
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID and Sal_Type = @Sal_Type
						where 
						MAD.Cmp_ID = @Cmp_ID and Month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
						and Ad_Active = 1 and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0)=1  and effect_net_salary=1
						and MAD.Emp_ID  = @Emp_ID
					open Cur_Dedu
					fetch next from cur_DEDU  into @Allow_Name ,@Amount,@AD_Flage,@Percentage
					while @@fetch_status = 0
						begin
							select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like @Allow_Name 
							
							
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Amount, 
												  Value_String = '',M_AD_Flage=@AD_Flage,Rate =@Percentage
								WHERE     (Label_Name = @Allow_Name) AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
									
						
									
							fetch next from Cur_Dedu into @Allow_Name,@Amount,@AD_Flage,@Percentage
						end
					close Cur_Dedu
					deallocate Cur_Dedu
				
				
					-- ended by rohit on 26052016
				

					-- Added by rohit on 29062015
					declare Cur_Leave   cursor for
						select leave_code ,sum(leave_Used) as leave_used,'L',0  
						   from t0040_leave_master LM WITH (NOLOCK) left join
							 t0140_leave_transaction LT WITH (NOLOCK) on LT.Leave_Id = LM.Leave_Id inner  join #Temp_Salary_Muster_Report
							on LT.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID and Label_Name = @Allow_Name
							and LT.Cmp_ID = LM.Cmp_Id
							and LT.Emp_ID  = @Emp_ID 
						where 
						LT.Cmp_ID = @Cmp_ID and Month(LT.For_Date) =  @Month and Year(LT.For_Date) = @Year
						and LT.Emp_ID  = @Emp_ID group by leave_code
						
					open Cur_Leave
					fetch next from Cur_Leave  into @Allow_Name ,@Amount,@AD_Flage,@Percentage
					while @@fetch_status = 0
						begin
							select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like @Allow_Name 
							
							
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Amount, 
												  Value_String = '',M_AD_Flage=@AD_Flage,Rate =@Percentage
								WHERE     (Label_Name = @Allow_Name) AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
									
						
									
							fetch next from Cur_Leave into @Allow_Name,@Amount,@AD_Flage,@Percentage
						end
					close Cur_Leave
					deallocate Cur_Leave
					
					-- ended by rohit on 29062015
					
					Update  #Temp_Salary_Muster_Report
					  set M_AD_Flage ='L' from #Temp_Salary_Muster_Report E1
					  --inner join T0210_MONTHLY_AD_DETAIL E on E1.Emp_ID =E.Emp_ID 
					  inner join T0040_LEAVE_MASTER  LM
					  on E1.Label_Name =LM.leave_code where E1.Emp_ID =@Emp_ID and E1.Cmp_ID=@Cmp_ID
					   and E1.M_AD_Flage =''
					   
					-- Select * from #Temp_Salary_Muster_Report
					  Update  #Temp_Salary_Muster_Report
					  set M_AD_Flage ='D' from #Temp_Salary_Muster_Report E1
					  inner join T0210_MONTHLY_AD_DETAIL E on E1.Emp_ID =E.Emp_ID inner join T0050_AD_MASTER AD
					  on AD.AD_ID =E.AD_ID where E1.Emp_ID =@Emp_ID and E1.Cmp_ID=@Cmp_ID
					   and E1.M_AD_Flage ='' 
					
					
					
					  Update  #Temp_Salary_Muster_Report
					  set M_AD_Flage =AD_Flag from #Temp_Salary_Muster_Report E1
					  inner join T0050_AD_MASTER AD
					  on AD.Ad_Sort_Name =E1.Label_Name where E1.Emp_ID =@Emp_ID and E1.Cmp_ID=@Cmp_ID
					   and E1.M_AD_Flage ='' 
					 
					   
						If @Sal_Type = 0
							select @Total_Deduction = Total_Dedu_Amount ,@PT = PT_Amount ,@Loan =  ( Loan_Amount + Loan_Intrest_Amount ) 
									,@Advance =  Advance_Amount ,@Net_Salary = Net_Amount ,@Revenue_Amt =Revenue_amount,@LWF_Amt =LWF_Amount,@Other_Dedu=Other_Dedu_Amount,
									@Deficit_Amt = Isnull(Deficit_Dedu_Amount,0),@Asset_Installment=Asset_Installment
									,@Late_Deduction = Late_Dedu_Amount
							from T0200_Monthly_salary WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
						Else
							select @Total_Deduction = S_Total_Dedu_Amount ,@PT = S_PT_Amount ,@Loan =  (S_Loan_Amount + S_Loan_Intrest_Amount ) 
									,@Advance =  S_Advance_Amount ,@Net_Salary = S_Net_Amount ,@Revenue_Amt =S_Revenue_Amount,@LWF_Amt =S_LWF_Amount,@Other_Dedu=S_Other_Dedu_Amount
							from T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(S_Month_End_Date) = @Month and Year(S_Month_End_Date) = @Year
							
				
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
								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Loan'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Loan, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Loan') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
								
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Advnc'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Advance, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Advnc') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						
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
							--end							
								
					
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'TDS'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @TDS, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'TDS') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Oth De'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Other_Dedu, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Oth De') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Deficit Amt'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Deficit_Amt, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Deficit Amt') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID

						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Dedu'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Total_Deduction, Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Dedu') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID	
						
						--added by jimit 28072017
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Late Dedu.'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Late_Deduction, Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Late Dedu.') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID	
						--ended
							
						--Added by Gadriwala Muslim 09012015 - Start		
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gate Pass'
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @GatePass_Amount, 
											  Value_String = '',M_AD_Flage='D'
								WHERE     (Label_Name = 'Gate Pass') AND (Row_id = @Row_ID)
									and Emp_ID = @Emp_ID			
						--Added by Gadriwala Muslim 09012015 - End
						
						--Added by Mukti 01042015 - Start	
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Asset Inst.'
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Asset_Installment, 
											  Value_String = '',M_AD_Flage='D'
								WHERE     (Label_Name = 'Asset Inst.') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID			
						--Added by Mukti 01042015 - End
						
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
						
								
						Select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Net Round'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = Isnull(@Net_Round_Value, 0),
											  Value_String = '',M_AD_Flage='N'
						WHERE     (Label_Name = 'Net Round') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
						
						Select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Net Payable'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Net_Salary ,
											  Value_String = '',M_AD_Flage='N'
						WHERE     (Label_Name = 'Net Payable') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
								
			FETCH NEXT FROM CUR_EMP INTO @EMP_ID
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
	
		CREATE TABLE #Exist_Column
	(
	Label_Name  varchar(200) not null,
	)

	
	insert into #Exist_Column
	Select Distinct Label_name from dbo.#Temp_Salary_Muster_Report  
	where dbo.#Temp_Salary_Muster_Report.Amount > 0
	 order by Label_name

	---Record set 1 for Regular record
	-- Changed By Ali 22112013 EmpName_Alias
	select dbo.#Temp_Salary_Muster_Report.* ,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) as Emp_Full_Name ,E.Alpha_Emp_Code as 'Emp_Code',GM.Grd_name,ETM.Type_name,DGM.Desig_Name,DM.Dept_Name,BM.Branch_Name, 
	E.Dept_ID,Cmp_Name,Cmp_Address,isnull(Inc_Qry.Inc_Bank_Ac_no,0),isnull(Inc_Qry.Payment_Mode,'') as Payment_Mode,E.Father_name ,E.Alpha_Emp_Code, RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) as Ord_Emp_code,E.Emp_First_Name as ord_Name,isnull(VS.Vertical_Name,'') as Vertical_Name , isnull(SV.SubVertical_Name,'') as SubVertical_Name
	,DGM.Desig_Dis_No  
	,BM.Comp_Name,BM.Branch_Address --add by chetan 27-12-16
		 from dbo.#Temp_Salary_Muster_Report Inner join 
		T0080_Emp_Master E WITH (NOLOCK) on dbo.#Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
		( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Inc_Bank_Ac_no,Branch_ID,Type_ID,Payment_Mode,Vertical_ID ,SubVertical_ID from t0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID left outer join t0040_department_Master WITH (NOLOCK)
		on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID LEFT OUTER JOIN
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_ID = GM.Grd_ID					LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON Inc_Qry.Type_ID = ETM.Type_ID				LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Inc_Qry.Desig_Id = DGM.Desig_Id		LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Inc_Qry.Dept_Id = DM.Dept_Id			INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.BRANCH_ID = BM.BRANCH_ID			LEFT OUTER JOIN
					T0040_Vertical_Segment VS WITH (NOLOCK) on Inc_Qry.Vertical_ID = VS.Vertical_ID	LEFT OUTER JOIN			--Added By Ramiz on 13022015
					T0050_SubVertical SV WITH (NOLOCK) on Inc_Qry.SubVertical_ID = SV.SubVertical_ID							--Added By Ramiz on 13022015
		
		 inner join t0010_company_master CM WITH (NOLOCK) on E.cmp_id=CM.cmp_id
		 inner join #Exist_Column EC on #Temp_Salary_Muster_Report.Label_Name =  EC.Label_Name
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End,Row_ID
		--order by RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500),Row_ID

	---Record set 2 for Labels only
	Select Distinct Label_name,Row_ID,M_AD_Flage  from dbo.#Temp_Salary_Muster_Report  
	   where dbo.#Temp_Salary_Muster_Report.Amount > 0
	 order by Row_ID
	
	---Record set 3 for Total amount
	Select Sum(Amount) as Amount ,Sum(Rate) as Rate,Row_ID,#Temp_Salary_Muster_Report.Label_Name,M_AD_Flage from dbo.#Temp_Salary_Muster_Report
	inner join #Exist_Column EC on #Temp_Salary_Muster_Report.Label_Name =  EC.Label_Name
	Group by #Temp_Salary_Muster_Report.Label_Name,Row_ID,M_AD_Flage 
	order by Row_ID

	---Record set 4 for Payment Record
		Declare @Payment table
		(
		    Amount  numeric(18,2),
		    Row_ID  numeric(18,2),
		    Payment_Mode varchar(50),
			emp_id numeric(18,0)
		   
		)
		insert into @Payment(Amount,Row_ID,Payment_Mode,emp_id)
		select Sum(Amount) as Amount,Row_ID,Inc_Qry.Payment_Mode,#Temp_Salary_Muster_Report.emp_id from dbo.#Temp_Salary_Muster_Report Inner join
		T0080_Emp_Master E WITH (NOLOCK) on dbo.#Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
		( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Inc_Bank_Ac_no,Branch_ID,Type_ID,Payment_Mode from t0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID 
		 where Label_Name='Net'
		 Group by Inc_Qry.Payment_Mode,Row_ID,E.Emp_code,#Temp_Salary_Muster_Report.emp_id
		order by Emp_code,Row_ID
		
		
		Select Sum(Amount) as Amount,Row_ID,Payment_Mode,emp_id from @Payment group by Payment_Mode,Row_ID,emp_id

	---Record set 5 for Total Rate Record
	Select	
	Sum(Amount) as Amount ,Sum(Rate) as Rate,Row_ID,#Temp_Salary_Muster_Report.Label_Name,M_AD_Flage from dbo.#Temp_Salary_Muster_Report
	inner join #Exist_Column EC on #Temp_Salary_Muster_Report.Label_Name =  EC.Label_Name
	where M_AD_Flage='I'
	Group by #Temp_Salary_Muster_Report.Label_Name,Row_ID,M_AD_Flage 
	order by Row_ID
		
	SET NOCOUNT OFF;
	RETURN
