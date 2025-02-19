


CREATE PROCEDURE  [dbo].[Check_Eligible_Formula_Wise]
	@Cmp_ID	NUMERIC ,
	@EMP_ID NUMERIC ,	
	@AD_ID Numeric(18,0),
	@For_date Datetime,
	@Earning_Gross numeric(18,3) = 0,
	@Salary_Cal_Day numeric(18,3) = 0,
	@Out_Of_Days numeric(18,3) = 0,	
	@is_Eligible tinyint output,
	@Absent_days numeric(18,3) = 0,
	@Salary_Amount Numeric(18,3) = 0,
	@arrear_Day Numeric(18,2)=0,
	@Present_Days Numeric(18,2)=0, 
	@To_Date Datetime = null
AS
	SET NOCOUNT ON	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 

BEGIN Try

		DECLARE @FROM_DATE AS DATETIME
		DECLARE @PRORATA_BASIC_SAL	AS NUMERIC(18,3)
		DECLARE @PRORATA_GROSS_SAL	AS NUMERIC(18,3)
		DECLARE @PRORATA_CTC_SAL	AS NUMERIC(18,3)
		DECLARE @DATE_OF_JOIN AS DATETIME
		DECLARE @FORMULA_ELIGIBLE AS NVARCHAR(1000)
		DECLARE @FORMULA_EVAL AS NVARCHAR(1000)

		set @from_date = @For_date
		set @is_Eligible = 0

		If @To_Date Is NULL 
			SET @to_date= DATEADD(d,@Out_Of_Days - 1,@for_date) 
	
		CREATE TABLE #early_late_count
		(
			Emp_ID numeric,
			Count_Type varchar(max) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Count_Value numeric
		)
		
		CREATE TABLE #Tbl_Formula_Eligible
		(
			Formula_Id numeric,
			Formula_Name nvarchar(max) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Formula_Value nvarchar(max)COLLATE SQL_Latin1_General_CP1_CI_AS		
		)
	
		SET @Prorata_Basic_Sal = 0
		SET @Prorata_Gross_Sal = 0
		SET @Prorata_CTC_Sal = 0

		select @Prorata_Basic_Sal = I.Basic_Salary,@Prorata_Gross_Sal= I.Gross_Salary,@Prorata_CTC_Sal = I.CTC,@Date_of_Join=date_of_join
		From T0095_Increment I WITH (NOLOCK) inner join     
				 ( select max(Increment_ID) as Increment_ID from T0095_Increment WITH (NOLOCK)      --Changed by Hardik 10/09/2014 for Same Date Increment 
				 where Increment_Effective_date <= @to_date    --@For_Date    --Commented By Ramiz as Eligible Allowance was not coming in Mid-Joining case
				 and Cmp_ID = @Cmp_ID and Emp_ID= @Emp_ID ) Qry on    
				 I.Increment_ID = Qry.Increment_ID 
				 inner join T0080_EMP_MASTER EM WITH (NOLOCK)  on  I.emp_id= Em.emp_id  
		Where I.Emp_ID = @Emp_ID
		

		SELECT @Formula_Eligible =  Actual_AD_Formula_Eligible 
		FROM T0040_AD_Formula_Eligible_Setting WITH (NOLOCK)  where ad_id = @AD_ID and Actual_AD_Formula_Eligible <> ''
		 
		If @Formula_Eligible is null
			Return 

		set @Formula_Eligible = REPLACE(@Formula_Eligible,' ','')

		insert into #Tbl_Formula_Eligible
		select row_id , items,items from Split2(@Formula_Eligible,'#')
		
		If exists(select 1 From #Tbl_Formula_Eligible where Formula_Value = 'Sum_Early' or Formula_Value = 'Sum_Late' Or Formula_Value = 'Max_Early' Or Formula_Value = 'Max_Late' Or Formula_Value = 'Early_Going' Or Formula_Value = 'Late_Count')
			Begin
				insert into #early_late_count
				exec SP_RPT_EMP_ATTENDANCE_MUSTER_IN_EXCEL_New
				@cmp_id = @Cmp_ID 
					,@from_date = @from_date
					,@to_date = @to_date
					,@branch_id = 0
					,@Cat_ID = 0
					,@grd_id = 0
					,@Type_id = 0
					,@dept_ID = 0
					,@desig_ID = 0
					,@emp_id = @emp_id
					,@constraint = ''
					,@Report_For = 'Late_early'
					,@Export_Type = ''
					,@Type = 0
			End
				 

		--update #Tbl_Formula_Eligible set Formula_Value = isnull(tbl.Leave_Days,0)
		--from #Tbl_Formula_Eligible tfe inner join
		--(
		--	select lm.leave_code, (select isnull(sum(leave_days),0) from T0210_MONTHLY_LEAVE_DETAIL mld where mld.cmp_id = @cmp_id and mld.emp_id = @emp_id and mld.leave_id = lm.leave_id and for_date = @for_date)  as Leave_days
		--	from t0040_leave_master lm 	 
		--		where lm.cmp_id = @cmp_id 
		--)	as tbl on tfe.Formula_Name COLLATE SQL_Latin1_General_CP1_CI_AS = tbl.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS
		
		update #Tbl_Formula_Eligible set Formula_Value = isnull(tbl.Leave_Days,0)
		from #Tbl_Formula_Eligible tfe inner join
		(
			select lm.leave_code, (
						SELECT Sum(CASE WHEN LM1.Apply_Hourly = 0 THEN (Case When Isnull(Half_Paid,0)=1 and Isnull(Half_Payment_Days,0)=0 then LeavE_Used/2 else Leave_Used End ) ELSE case when (Case When Isnull(Half_Paid,0)=1 and Isnull(Half_Payment_Days,0)=0 then LeavE_Used/2 else Leave_Used End ) * 0.125 > 1 then 1 else (Case When Isnull(Half_Paid,0)=1 and Isnull(Half_Payment_Days,0)=0 then LeavE_Used/2 else Leave_Used End) * 0.125 end END) 
						From dbo.T0140_leave_Transaction LT WITH (NOLOCK) 
					Inner join dbo.T0040_Leave_Master LM1  WITH (NOLOCK) on LT.Leave_ID = LM1.Leave_ID and (isnull(eff_in_salary,0) <> 1 
							or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) <= 0) 
							or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) >= 0 and (isnull(Leave_Used,0) > 0))) and isnull(LM1.Default_Short_Name,'') <> 'COMP' 
					WHERE Emp_ID = @Emp_ID and For_Date >=@From_Date and For_Date <=@To_date and LM1.Leave_ID = LM.Leave_ID
					GROUP BY Emp_ID
					)  as Leave_days
			from t0040_leave_master lm 	 
				where lm.cmp_id = @cmp_id  and isnull(LM.Default_Short_Name,'') <> 'COMP' 
		)	as tbl on tfe.Formula_Name COLLATE SQL_Latin1_General_CP1_CI_AS = tbl.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS
			
		update #Tbl_Formula_Eligible set Formula_Value = isnull(tbl.Leave_Days,0)
		from #Tbl_Formula_Eligible tfe inner join
		(
			select lm.leave_code, (
			 select isnull(sum(isnull(CASE WHEN Apply_Hourly = 0 THEN case when CompOff_Used >= Leave_Encash_Days then CompOff_Used - Leave_Encash_Days else CompOff_Used end ELSE case when CompOff_Used >= Leave_Encash_Days then (CompOff_Used - Leave_Encash_Days) * 0.125 Else CompOff_Used * 0.125 End END,0)),0)
				
				from dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) 
				Inner join dbo.T0040_Leave_Master LM1  WITH (NOLOCK) on LT.Leave_ID = LM1.Leave_ID and (isnull(eff_in_salary,0) <> 1 
				or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) <= 0) 
				or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) >= 0 and (isnull(CompOff_Used,0) > 0))) and isnull(LM1.Default_Short_Name,'') = 'COMP'
				where For_Date >= @From_Date and For_Date <= @To_Date and Emp_ID = @Emp_ID 
				GROUP BY Emp_ID
		)  as Leave_days
			from t0040_leave_master lm WITH (NOLOCK)  	 
				where lm.cmp_id = @cmp_id and isnull(LM.Default_Short_Name,'') = 'COMP'
		)	as tbl on tfe.Formula_Name COLLATE SQL_Latin1_General_CP1_CI_AS = tbl.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS

		
		update #Tbl_Formula_Eligible set Formula_Value=Count_Value
		from #Tbl_Formula_Eligible tfe inner join 
		#early_late_count elc on tfe.formula_name COLLATE SQL_Latin1_General_CP1_CI_AS = elc.count_type COLLATE SQL_Latin1_General_CP1_CI_AS
		
		update #Tbl_Formula_Eligible set Formula_Value = tbl.M_AD_Amount
		from #Tbl_Formula_Eligible tfe inner join
		(
			select isnull(mad.m_ad_amount,0) m_ad_amount ,am.ad_sort_name from T0210_MONTHLY_AD_DETAIL mad WITH (NOLOCK) 
			inner join t0050_Ad_master am WITH (NOLOCK)  on am.ad_id = mad.AD_ID
			where mad.cmp_id = @cmp_id and emp_id = @emp_id and for_date = @for_date
		)	as tbl on tfe.Formula_Name  COLLATE SQL_Latin1_General_CP1_CI_AS = tbl.ad_sort_name COLLATE SQL_Latin1_General_CP1_CI_AS
				
		Declare @Is_Cancel_weekoff as Numeric(18,0)  
		Declare @Is_Cancel_Holiday as Numeric(18,0)  
		declare @emp_Branch as numeric(18,0)  
		declare @Holiday_days as numeric(18,2)  
		declare @Weekoff_Days as numeric(18,2)  
		set @Holiday_days =0  
		set @Weekoff_Days =0  
		select @emp_Branch  = Branch_id from T0080_EMP_MASTER WITH (NOLOCK)  where Emp_ID=@EMP_ID  

		Select @Is_Cancel_weekoff = Is_Cancel_weekoff   
		,@Is_Cancel_Holiday = Is_Cancel_Holiday   
		From dbo.T0040_GENERAL_SETTING WITH (NOLOCK)  where cmp_ID = @cmp_ID and Branch_ID = @emp_Branch      
		and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK)  where For_Date <=@To_Date and Branch_ID = @emp_Branch and Cmp_ID = @Cmp_ID)      

		IF  NOT EXISTS (SELECT * FROM sys.tables WHERE name = N'#Emp_Holiday' AND type = 'U')    
			begin 
				CREATE TABLE #Emp_Holiday
				  (
						Emp_Id		numeric , 
						Cmp_ID		numeric,
						For_Date	datetime,
						H_Day		numeric(3,1),
						is_Half_day tinyint
				  )	  

			end 

		DECLARE @StrWeekoff_Date varchar(MAX)
		DECLARE @StrHoliday_Date Varchar(MAX)


		Exec dbo.SP_EMP_HOLIDAY_DATE_GET @emp_id,@Cmp_ID,@For_date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date OUTPUT,@Holiday_days OUTPUT,0,1,0,''  
		Exec dbo.SP_EMP_WEEKOFF_DATE_GET @emp_id,@Cmp_ID,@For_date,@To_Date,null,null,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date OUTPUT,@Weekoff_Days OUTPUT,0     
		  
		
		Update #Tbl_Formula_Eligible set Formula_Value=isnull(@Prorata_Basic_Sal,0) where Replace(Replace(Formula_Value,'{',''),'}','') ='BasicSalary'	
		Update #Tbl_Formula_Eligible set Formula_Value=isnull(@Prorata_Gross_Sal,0) where Replace(Replace(Formula_Value,'{',''),'}','')='GrossSalary'
		Update #Tbl_Formula_Eligible set Formula_Value=isnull(@Prorata_CTC_Sal,0) where Replace(Replace(Formula_Value,'{',''),'}','')='CTC'
		Update #Tbl_Formula_Eligible set Formula_Value=@Present_Days where Replace(Replace(Formula_Value,'{',''),'}','')='PresentDays'
		Update #Tbl_Formula_Eligible set Formula_Value=@Salary_Cal_Day where Replace(Replace(Formula_Value,'{',''),'}','')='SalaryCalculateDays'
		Update #Tbl_Formula_Eligible set Formula_Value=@Earning_Gross where Replace(Replace(Formula_Value,'{',''),'}','')='ActualGross'
		Update #Tbl_Formula_Eligible set Formula_Value=@Salary_Amount where Replace(Replace(Formula_Value,'{',''),'}','')='ActualBasic'
		Update #Tbl_Formula_Eligible set Formula_Value=@Absent_days where Replace(Replace(Formula_Value,'{',''),'}','')='AbsentDays'
		Update #Tbl_Formula_Eligible set Formula_Value=@Out_Of_Days where Replace(Replace(Formula_Value,'{',''),'}','')='MonthDays'
		Update #Tbl_Formula_Eligible set Formula_Value=@Date_of_Join where Replace(Replace(Formula_Value,'{',''),'}','')='DateofJoining'
		Update #Tbl_Formula_Eligible set Formula_Value=@arrear_Day where Replace(Replace(Formula_Value,'{',''),'}','')='ArrearDays' 
		Update #Tbl_Formula_Eligible Set Formula_Value=ISNULL(@Weekoff_Days,0) where Replace(Replace(Formula_Value,'{',''),'}','')='WeekOff' 
		Update #Tbl_Formula_Eligible Set Formula_Value=ISNULL(@Holiday_days,0) where Replace(Replace(Formula_Value,'{',''),'}','')='Holiday' 
		  
		set @Formula_Eval = ''

		-- Added by rohit on 30072015 for check if allowance not Recieved then Its Consider as 0 amount.
		update #Tbl_Formula_Eligible set Formula_Value = 0
		from #Tbl_Formula_Eligible tfe inner join
		(select Ad_Name from t0050_Ad_master WITH (NOLOCK)  where CMP_ID = @Cmp_ID) 
		as tbl on tfe.Formula_Value  COLLATE SQL_Latin1_General_CP1_CI_AS = tbl.Ad_Name COLLATE SQL_Latin1_General_CP1_CI_AS
		-- Ended by rohit on 30072015 

		SELECT @Formula_Eval = COALESCE(@Formula_Eval+'', '') + Formula_Value from #Tbl_Formula_Eligible order by Formula_Id ASC

		set @Formula_Eval = replace(@Formula_Eval,'&',' and ')
		set @Formula_Eval = replace(@Formula_Eval,'|',' OR ')
		set @Formula_Eval = ' if ' + replace(@Formula_Eval,'#',' ') + ' select 1 else  select 0 '

		
		CREATE TABLE #Result
		( 
			Result numeric(18,3)
		)

		insert into #Result
		exec(@Formula_Eval)

		select @is_Eligible = result from #Result
		    
END Try
Begin Catch
	set @is_Eligible = 0
End Catch


