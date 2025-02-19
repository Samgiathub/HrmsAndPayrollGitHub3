


CREATE PROCEDURE [dbo].[P0210_ESIC_On_Not_Effect_on_Salary_Record_Get]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	varchar(max)
	,@Cat_ID 		VARCHAR(MAX) = ''
	,@Grd_ID 		VARCHAR(MAX) = ''
	,@Type_ID 		VARCHAR(MAX) = ''
	,@Dept_ID 		VARCHAR(MAX) = ''
	,@Desig_ID 		VARCHAR(MAX) = ''
	,@Vertical_ID		VARCHAR(MAX) = ''
	,@SubVertical_ID	VARCHAR(MAX) = ''
	,@Segment_Id VARCHAR(MAX) = ''	
	,@SubBranch_ID	VARCHAR(MAX) = ''	
	,@Emp_ID 		numeric = 0
	,@constraint 	varchar(MAX) = ''
	,@AD_ID			numeric = 0
AS
 		Set Nocount on 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

 
 	IF @Branch_ID = '0' or @Branch_ID = ''
		set @Branch_ID = null
		
	IF @Cat_ID = '0'  or @Cat_ID = '' 
		set @Cat_ID = null

	IF @Grd_ID = '0'  or @Grd_ID = ''
		set @Grd_ID = null

	IF @Type_ID = '0'  or @Type_ID = ''  
		set @Type_ID = null

	IF @Dept_ID = '0'  or @Dept_ID = ''
		set @Dept_ID = null

	IF @Desig_ID = '0' or @Desig_ID = ''  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
		

	CREATE TABLE #EMP_CONS 
	(
		EMP_ID	NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC 
	)
	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,'',0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_ID,0,0,0,'0',0,0               

	CREATE TABLE #ESIC_Temp_Table
	(
		Emp_ID	numeric,
		AD_Id   Numeric,
		Month   Numeric,
		Year	Numeric,
		Amount Numeric(18,2),
		ESIC Numeric(18,2),
		Net_Amount Numeric(18,2),
		Comp_ESIC Numeric(18,2)
	)
	
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into @Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
			
			
	--		Insert Into @Emp_Cons

	--		select distinct I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
	--		Where Cmp_ID = @Cmp_ID 
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
						
			
	--	end
	
	  Declare @Sal_St_Date   Datetime    
	  Declare @Sal_end_Date   Datetime  
	  declare @manual_salary_Period as numeric(18,0) -- Comment and added By rohit on 11022013 
	  
		If @Branch_ID is null
			Begin 
				select Top 1 @Sal_St_Date  = Sal_st_Date,@manual_salary_Period= isnull(manual_salary_Period ,0) 
				  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
			End
		Else
			Begin
				select @Sal_St_Date  =Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0)
				  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID in (Select	Cast(data as numeric) as Branch_ID 	FROM	dbo.Split(@Branch_ID,'#'))--@Branch_ID    
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) 
									where For_Date <=@From_Date and Branch_ID  in (Select	Cast(data as numeric) as Branch_ID 	FROM	dbo.Split(@Branch_ID,'#'))--= @Branch_ID 
											and Cmp_ID = @Cmp_ID)    
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
	 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
	   	   if @manual_salary_Period =0 
			Begin
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   Set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_End_Date  
			 end
		else
			begin
				select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period WITH (NOLOCK) where month= month(@From_Date) and YEAR=year(@From_Date)							   
			     Set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_End_Date    
			End	  
	 
	 
	 declare @Esic_AD_Id as Numeric
	 declare @ESIC_Limit as Numeric
	 Declare @M_AD_Percentage as Numeric(18,2)
	 declare @Comp_Esic_AD_Id as Numeric
	 declare @Comp_ESIC_Limit as Numeric
	 Declare @Comp_M_AD_Percentage as Numeric(18,2)
	
	 -- Commented by rohit on 26112015
	 --select @Esic_AD_Id = isnull(Ad_id,0),@ESIC_Limit = isnull(AD_MAX_LIMIT,0),@M_AD_Percentage =AD_PERCENTAGE  from T0050_AD_MASTER where CMP_ID=@Cmp_ID and AD_DEF_ID = 3 -- For Get Ad_Id Of Esic
	 --select @Comp_Esic_AD_Id = isnull(Ad_id,0),@Comp_ESIC_Limit = isnull(AD_MAX_LIMIT,0),@Comp_M_AD_Percentage =AD_PERCENTAGE  from T0050_AD_MASTER where CMP_ID=@Cmp_ID and AD_DEF_ID = 6 -- For Get Ad_Id Of Esic
	 
	 ---Added By Jimit 26062019	
		SELECT	@Comp_M_AD_Percentage = G1.ESIC_Employer_Contribution
		FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK)
				LEFT OUTER JOIN (
									Select	Cast(data as numeric) as Branch_ID 
									FROM	dbo.Split(@Branch_ID,'#')
								) T ON		T.Branch_ID = G1.Branch_ID
		WHERE	For_Date = (
								SELECT	Max(For_Date) 
								FROM	T0040_GENERAL_SETTING G2 WITH (NOLOCK)															
								WHERE	For_Date < @to_date and G2.Branch_ID = ISNULL(T.Branch_Id,G2.Branch_ID) AND G1.Cmp_ID=G2.Cmp_ID
							) AND G1.Cmp_ID=@Cmp_ID
	
		
		SELECT	@M_AD_Percentage = Cast(mad.M_AD_Percentage as Numeric(5,2))
		FROM	t0210_Monthly_Ad_Detail mad WITH (NOLOCK) 
				inner join T0050_AD_MASTER AM WITH (NOLOCK) ON mad.AD_ID = AM.AD_ID AND AM.CMP_ID = Mad.CMP_ID
		WHERE	AM.CMP_ID = @CMP_ID AND AD_DEF_ID = 3 AND EMP_ID = CASE WHEN @Emp_ID <> 0 THEN @Emp_ID ELSE EMP_ID END
				and month(Mad.for_date) = Month(@From_Date) and year(Mad.for_date) = Year(@From_Date)

	 --Ended


	 select @Esic_AD_Id = isnull(Ad_id,0),@ESIC_Limit = 21000 --,@M_AD_Percentage =1.75  
	 from	T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@Cmp_ID and AD_DEF_ID = 3 -- For Get Ad_Id Of Esic
	 
	 select @Comp_Esic_AD_Id = isnull(Ad_id,0),@Comp_ESIC_Limit = 21000---,@Comp_M_AD_Percentage =4.75  
	 from	T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@Cmp_ID and AD_DEF_ID = 6 -- For Get Ad_Id Of Esic
	 
	 
	 
	 Declare @is_Calculate_On_Imported_Value tinyint
	 set @is_Calculate_On_Imported_Value = 0
	 Declare @Auto_ded_Tds tinyint
	 set @Auto_ded_Tds = 0
	 Declare @is_hide_report tinyint
	 Set @is_hide_report = 0
	 declare @new_constrint as nvarchar(max)
	 Declare @from_date_tds as datetime
	 Declare @To_date_tds as datetime
	 declare @Calculate_On varchar(100)
	 declare @Ad_Name varchar(500)
	 DECLARE @AD_EFFECT_ON_ESIC TINYINT -- ADDED BY HARDIK 23/11/2020 FOR VIVO WEST BENGAL AS THEY HAVE NO ESIC ON INCETIVE ALLOWANCE BUT STILL ESIC DEDUCTED SO CHECK THIS OPTION FOR DEDUCTION
	 SET @AD_EFFECT_ON_ESIC = 0

			
	 set @from_date_tds = dateadd(month, datediff(month, 0, @To_Date) - (12 + datepart(month, @To_Date) - 4) % 12, 0)
	 set @To_date_tds =  dateadd(month, datediff(month, 0, @To_Date) - (12 + datepart(month, @To_Date) - 4) % 12 + 12, -1)

	 select @is_Calculate_On_Imported_Value = isnull(Is_Calculated_On_Imported_Value,0),@Auto_ded_Tds = auto_ded_tds,
		@is_hide_report = isnull(Hide_In_Reports,0), @Calculate_On = AD_CALCULATE_ON, @Ad_Name = AD_NAME,
		@AD_EFFECT_ON_ESIC = ISNULL(@AD_EFFECT_ON_ESIC,0)
	 from T0050_AD_MASTER WITH (NOLOCK)  Where cmp_id=@cmp_id and AD_ID= @ad_id
	 
	  CREATE TABLE #tbl_Taxable_Income 
				(	cmp_id numeric(18,0),
					Emp_Id Numeric(18,0),
					taxble_amount Numeric(18,2),
					gender varchar(10),
					percentage numeric(18,2),
					TDS_Amount Numeric(18,2) default 0
				)
	 create clustered index ix_tbl_Taxable_Income on #tbl_Taxable_Income(cmp_id,Emp_Id);		


	 
	--Added by Jaina 08-08-2017 Start
	create table #Emp_Overtime
	(
		Emp_Id numeric(18,0),
		OT_W_Hour numeric(18,4),
		OT_Amount numeric(18,2),
		OT_WO_Hour numeric(18,4),
		OT_WO_Amount numeric(18,2),
		OT_HO_Hour numeric(18,4),
		OT_HO_Amount numeric(18,2),
		Basic_OT_Salary numeric(18,2),
		Working_Days numeric(18,2),
		OT_Hour_Rate numeric(18,4),
		Shift_Sec numeric(18,0)
	)
	
	
	declare @Setting_Value numeric = 0
	declare @Total_OT_Amount numeric(18,2)
	declare @E_ID numeric(18,0)
	
	SELECT @Setting_Value = Setting_Value FROM T0040_SETTING WITH (NOLOCK) where Setting_Name='After Salary Overtime Payment Process' AND Cmp_ID=@Cmp_Id
	
	
	if @Setting_Value = 1 and @Calculate_On='Transfer OT'
	begin
		
		set @E_ID = isnull(@EMP_ID,0)
		insert INTO #Emp_Overtime
		exec SP_Calculate_Overtime_After_Salary @Cmp_id=@Cmp_id,@FROM_DATE=@From_Date,@TO_DATE=@TO_DATE,@BRANCH_ID=@BRANCH_ID,@CAT_ID=@CAT_ID,@Grd_ID=@Grd_ID,@TYPE_ID=@TYPE_ID,@DEPT_ID=@DEPT_ID,
												@DESIG_ID=@DESIG_ID,@Vertical_ID=@Vertical_ID,@SubVertical_ID=@SubVertical_ID,
												@Segment_Id=@Segment_Id,@SubBranch_ID=@SubBranch_ID,@EMP_ID=@E_ID,@CONSTRAINT=@CONSTRAINT,@Total_OT_Amount=@Total_OT_Amount output
		--select * from #Emp_Overtime
		
		--select Md.Emp_ID AS EId,MD.*,AM.AD_PERCENTAGE,MD.To_date,MD.For_Date  from T0210_MONTHLY_AD_DETAIL MD inner join 
		--					T0050_AD_MASTER AM on MD.ad_id = AM.AD_ID and MD.Cmp_ID = Am.CMP_ID and Am.AD_DEF_ID = 3 --and Isnull(AM.Ad_Effect_On_Esic,0) = 1
		--					and Md.Cmp_ID=@Cmp_Id and to_date >=@From_Date and to_date <=@To_Date and MD.M_AD_Amount  >0
	
		

		Select distinct 
		EO.Emp_Id
		,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Grd_Name,Alpha_Emp_Code as Alpha_Emp_Code,Type_Name,Dept_Name,Desig_Name --AD_Name,AD_LEVEL
		,cmp_Name,Cmp_Address,Branch_Address,Comp_name,branch_name,E.Vertical_ID 
		,@from_Date as P_From_Date , @To_date as P_To_Date,EC.Branch_ID,E.Pan_No,I_Q.Basic_Salary
		,(isnull(EO.OT_Amount,0) + isnull(EO.OT_WO_Amount,0) + isnull(EO.OT_HO_Amount,0)) as Amount
		,Case When isnull((isnull(EO.OT_Amount,0) + isnull(EO.OT_WO_Amount,0) + isnull(EO.OT_HO_Amount,0)),0) > 0 then isnull(ceiling((((EO.OT_Amount + EO.OT_WO_Amount + EO.OT_HO_Amount) * Esic.M_AD_PERCENTAGE)/100)),0) else 0 End as Esic
	    ,0 as TDS
	    ,Case When ISNULL((isnull(EO.OT_Amount,0) + isnull(EO.OT_WO_Amount,0) + isnull(EO.OT_HO_Amount,0)),0) > 0 then
				 isnull(isnull(EO.OT_Amount,0) + isnull(EO.OT_WO_Amount,0) + isnull(EO.OT_HO_Amount,0),0) - ISNULL((ceiling((((isnull(EO.OT_Amount,0) + isnull(EO.OT_WO_Amount,0) + isnull(EO.OT_HO_Amount,0)) * Esic.M_AD_PERCENTAGE)/100))),0)  End as Net_Amount
		,Case When isnull(Comp_ESIC.M_AD_Amount,0) > 0 then ceiling((((isnull(EO.OT_Amount,0) + isnull(EO.OT_WO_Amount,0) + isnull(EO.OT_HO_Amount,0)) * Comp_ESIC.M_AD_PERCENTAGE)/100)) else 0 End as Comp_Esic
		, (isnull(EO.OT_W_Hour,0) + isnull(EO.OT_WO_Hour,0) + isnull(EO.OT_HO_Hour,0)) as Ot_Hours
		,0 As Loan_Amount,0 as taxble_amount,0 as percentage,@Ad_Id as AD_ID,@Ad_Name as AD_NAME,EO.Basic_OT_Salary
		,EO.Working_Days,ESN.Tran_Id,EO.OT_Hour_Rate,EO.Shift_Sec
		 From #Emp_Overtime EO Inner JOIN 
		T0080_EMP_MASTER E WITH (NOLOCK) on EO.emp_ID = E.emp_ID INNER  JOIN 
			#EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
			T0095_Increment I_Q WITH (NOLOCK) On EC.INCREMENT_ID= I_Q.Increment_ID Inner Join
			--( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,Basic_Salary from T0095_Increment I inner join 
			--		( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
			--		where Increment_Effective_date <= @To_Date
			--		and Cmp_ID = @Cmp_ID
			--		group by emp_ID  ) Qry on
			--		I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				--on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id left outer join
					T0040_Vertical_Segment VM WITH (NOLOCK) ON I_Q.Vertical_ID = VM.Vertical_ID 
					Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  Inner join
					T0010_company_Master cm WITH (NOLOCK) on E.Cmp_ID = cm.cmp_ID  
					Left Outer join 
						(Select Tran_Id,ESN.Emp_Id From T0210_ESIC_On_Not_Effect_on_Salary ESN WITH (NOLOCK) 
						Where MONTH(ESN.For_Date) = MONTH(@To_Date) 
						and YEAR(ESN.For_Date)=YEAR(@To_Date) AND ESN.Cmp_Id=@Cmp_Id) ESN 
					ON EO.Emp_ID = ESN.Emp_Id 	
					left join 
						(												
							select Md.Emp_ID AS EId,AM.AD_PERCENTAGE,MD.Cmp_ID,M_AD_PERCENTAGE  from T0210_MONTHLY_AD_DETAIL MD WITH (NOLOCK) inner join 
							T0050_AD_MASTER AM WITH (NOLOCK) on MD.ad_id = AM.AD_ID and MD.Cmp_ID = Am.CMP_ID and Am.AD_DEF_ID = 3 --and Isnull(AM.Ad_Effect_On_Esic,0) = 1
							and Md.Cmp_ID=@Cmp_Id and month(to_date) = month(@To_Date) and year(to_date) = year(@To_Date) and MD.M_AD_Amount  >0
							
						) ESIC 
						on  E.cmp_id = Esic.Cmp_ID and EO.emp_id = Esic.EId
				   left join 
					   (
					        select EMP_ID, MD.CMP_ID, AM.AD_PERCENTAGE,M_AD_Amount,M_AD_PERCENTAGE  from T0210_MONTHLY_AD_DETAIL MD WITH (NOLOCK) inner join 
							T0050_AD_MASTER AM WITH (NOLOCK) on MD.ad_id = AM.AD_ID and MD.Cmp_ID = Am.CMP_ID and Am.AD_DEF_ID = 6  and MD.M_AD_Amount  >0 
							--and Isnull(AM.Ad_Effect_On_Esic,0) = 1
							and Md.Cmp_ID=@Cmp_Id and month(to_date) = month(@To_Date) and year(to_date) = year(@To_Date)
				       ) Comp_ESIC 
					   on  E.cmp_id = Comp_ESIC.Cmp_ID and E.emp_id = Comp_ESIC.emp_id
					 								
		WHERE E.Cmp_ID = @Cmp_Id 
		and ESN.Tran_Id Is NULL
		order by E.Alpha_Emp_code			
	end
	else --Added by Jaina 08-08-2017 END
	begin	
	 if @is_Calculate_On_Imported_Value = 0 
	 begin
		Select distinct 
		MAD.*,
		ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Grd_Name,Alpha_Emp_Code as Alpha_Emp_Code,Type_Name,Dept_Name,Desig_Name,AD_Name,AD_LEVEL
		,cmp_Name,Cmp_Address,Branch_Address,Comp_name,branch_name,E.Vertical_ID    ---added by aswini 12/01/2024
		,@from_Date as P_From_Date , @To_date as P_To_Date,EC.Branch_ID,E.Pan_No,I_Q.Basic_Salary
		,MAD.M_AD_Amount + ISNULL(SETT_AMOUNT,0)  as Amount
		,Case When isnull(Esic.M_AD_Amount,0) > 0 then ceiling(((MAD.M_AD_Amount * Esic.M_AD_PERCENTAGE)/100)) else 0 End as Esic
	    ,case when isnull(TI.TDS_Amount,0)=0 THEN ceiling((MAD.M_AD_Amount * isnull(TI.percentage,0))/100) else TI.TDS_Amount end as TDS
	  	,Case When isnull(Esic.M_AD_Amount,0) > 0 then MAD.M_AD_Amount - (ceiling(((MAD.M_AD_Amount * Esic.M_AD_PERCENTAGE)/100))) - (case when isnull(TI.TDS_Amount,0)=0 THEN ceiling((MAD.M_AD_Amount * isnull(TI.percentage,0))/100) else TI.TDS_Amount end) - Isnull(Loan_Int_Amt,0) else ceiling(MAD.M_AD_Amount) - Isnull(Loan_Int_Amt,0) - (case when isnull(TI.TDS_Amount,0)=0 THEN ceiling((MAD.M_AD_Amount * isnull(TI.percentage,0))/100) else TI.TDS_Amount end) End as Net_Amount
		,Case When isnull(Comp_ESIC.M_AD_Amount,0) > 0 then ceiling(((MAD.M_AD_Amount * Comp_ESIC.M_AD_PERCENTAGE)/100)) else 0 End as Comp_Esic
		, case when ADM.AD_CALCULATE_ON='Transfer OT' then isnull(ms.OT_Hours,0) +isnull(ms.M_HO_OT_Hours,0) + isnull(ms.M_WO_OT_Hours,0) else 0 end as Ot_Hours
		,Ti.*
		,Isnull(Loan_Int_Amt,0) As Loan_Amount,0 as Basic_OT_Salary,0 as Working_Days,0 as OT_Hour_Rate,0 as Shift_Sec
		 From T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) Inner join 
			  T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN 
				T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN 
			#EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
			T0095_Increment I_Q WITH (NOLOCK) On EC.INCREMENT_ID= I_Q.Increment_ID Inner Join
			--( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,Basic_Salary from T0095_Increment I inner join 
			--		( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
			--		where Increment_Effective_date <= @To_Date
			--		and Cmp_ID = @Cmp_ID
			--		group by emp_ID  ) Qry on
			--		I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				--on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id LEFT OUTER JOIN
					T0040_Vertical_Segment VM WITH (NOLOCK) ON I_Q.Vertical_ID = VM.Vertical_ID  ---added by aswini 12/01/2024
					Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  Inner join
					T0010_company_Master cm WITH (NOLOCK) on MAD.Cmp_ID = cm.cmp_ID  
					
					left join 
						(
							select MD.*,AM.AD_PERCENTAGE  from T0210_MONTHLY_AD_DETAIL MD WITH (NOLOCK) inner join 
							T0050_AD_MASTER AM WITH (NOLOCK) on MD.ad_id = AM.AD_ID and MD.Cmp_ID = Am.CMP_ID and Am.AD_DEF_ID = 3 --and Isnull(AM.Ad_Effect_On_Esic,0) = 1
							and Md.Cmp_ID=@Cmp_Id and to_date >=@From_Date and to_date <=@To_Date and MD.M_AD_Amount  >0
						) ESIC 
						on  Mad.cmp_id = Esic.Cmp_ID and Mad.emp_id = Esic.emp_id
				   left join 
					   (
					        select MD.*,AM.AD_PERCENTAGE  from T0210_MONTHLY_AD_DETAIL MD WITH (NOLOCK) inner join 
							T0050_AD_MASTER AM WITH (NOLOCK) on MD.ad_id = AM.AD_ID and MD.Cmp_ID = Am.CMP_ID and Am.AD_DEF_ID = 6  and MD.M_AD_Amount  >0 
							--and Isnull(AM.Ad_Effect_On_Esic,0) = 1
							and Md.Cmp_ID=@Cmp_Id and to_date >=@From_Date and to_date <=@To_Date
				       ) Comp_ESIC 
					   on  Mad.cmp_id = Comp_ESIC.Cmp_ID and Mad.emp_id = Comp_ESIC.emp_id
				
					left join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MAD.Sal_tran_id = Ms.Sal_Tran_ID 
					left join T0210_ESIC_On_Not_Effect_on_Salary ESN WITH (NOLOCK) on MAD.Emp_ID = ESN.Emp_Id and MAD.AD_ID = ESN.Ad_Id and MONTH(MAD.To_date) = MONTH(ESN.For_Date) and year(MAD.to_date) =YEAR(ESN.For_Date) and isnull(ESN.Tran_Id,0) =0	
					left join #tbl_Taxable_Income TI on E.Emp_ID = TI.Emp_Id and e.Cmp_ID =Ti.Cmp_id
					Left OUTER JOIN 
					(
						--Select SUM(Case When LA.Loan_Apr_Pending_Amount > LA.Loan_Apr_Installment_Amount THEN LA.Loan_Apr_Installment_Amount ELSE LA.Loan_Apr_Pending_Amount END) as Loan_Int_Amt, LA.Emp_ID
						--From T0120_LOAN_APPROVAL LA
						--Where LA.Loan_Apr_Pending_Amount > 0  AND LA.Loan_Apr_Deduct_From_Sal = 2 and LA.AD_ID = @AD_ID
						--AND LA.Loan_Apr_Date <= @TO_DATE
						--Group BY LA.Emp_ID
						Select 
						(Case When SUM(isnull(qry.New_Install_Amount,0)) > 0 Then 
							SUM(qry.New_Install_Amount)
						Else
							SUM(Case When LA.Loan_Apr_Pending_Amount > LA.Loan_Apr_Installment_Amount 
									THEN LA.Loan_Apr_Installment_Amount 
								ELSE 
									--Isnull(LA.Loan_Apr_Pending_Amount,0)
									(Case When LA.Loan_Apr_Intrest_Type = 'REDUCING' 
											Then 
												(case when ((LA.Loan_Apr_Pending_Amount * LA.Loan_Apr_Intrest_Per)/1200) + Isnull(LA.Loan_Apr_Pending_Amount,0) > isnull(LA.Loan_Apr_Installment_Amount,0) 
													then isnull(LA.Loan_Apr_Installment_Amount,0)
												Else
													((LA.Loan_Apr_Pending_Amount * LA.Loan_Apr_Intrest_Per)/1200) + Isnull(LA.Loan_Apr_Pending_Amount,0)
												End)
										  When LA.Loan_Apr_Intrest_Type = 'FIX' 
											Then 
												(Case When ((LA.Loan_Apr_Amount * LA.Loan_Apr_Intrest_Per)/1200) + Isnull(LA.Loan_Apr_Pending_Amount,0) > isnull(LA.Loan_Apr_Installment_Amount,0) 
													then isnull(LA.Loan_Apr_Installment_Amount,0) 
												Else
													((LA.Loan_Apr_Amount * LA.Loan_Apr_Intrest_Per)/1200) + Isnull(LA.Loan_Apr_Pending_Amount,0)
												End)
									END)
								END) 
						End)	as Loan_Int_Amt, 
						LA.Emp_ID
						From T0120_LOAN_APPROVAL LA WITH (NOLOCK)
							Left Outer join 
							(
								Select MLS.Emp_ID,Loan_Apr_ID,New_Install_Amount From T0090_Change_Request_Approval CRA WITH (NOLOCK) 
								INNER JOIN T0100_Monthly_Loan_Skip_Approval MLS WITH (NOLOCK) ON CRA.Request_Apr_ID = MLS.Request_Apr_ID
								Where CRA.Cmp_id = @Cmp_Id and Request_Type_id = 17	
								and Loan_Month = Month(@From_Date) and Loan_Year = YEAR(@From_Date)
								and MLS.Final_Approval = 1 AND CRA.Request_status = 'A'
							) as qry ON LA.Emp_ID = qry.Emp_ID and LA.Loan_Apr_ID = qry.Loan_Apr_ID
							Where LA.Loan_Apr_Pending_Amount > 0  AND LA.Loan_Apr_Deduct_From_Sal = 2 and LA.AD_ID = @AD_ID and LA.Loan_Apr_Status = 'A'
							AND LA.Loan_Apr_Date <= @TO_DATE and LA.Installment_Start_Date <= @TO_DATE
							Group BY LA.Emp_ID
						) As LA_Qry ON LA_Qry.Emp_ID = E.Emp_ID
						LEFT OUTER JOIN --- Added by Hardik 05/01/2021 for Cera
						(SELECT MSS.EMP_ID, SUM(MAD.M_AD_Amount) AS SETT_AMOUNT
						FROM T0201_MONTHLY_SALARY_SETT MSS INNER JOIN 
							T0210_MONTHLY_AD_DETAIL MAD ON MSS.S_Sal_Tran_ID = MAD.S_Sal_Tran_ID INNER JOIN
							#EMP_CONS EC ON MSS.EMP_ID = EC.EMP_ID
						WHERE MSS.CMP_ID=@Cmp_ID AND MSS.Effect_On_Salary=1 AND MSS.S_Eff_Date BETWEEN @From_Date AND @To_Date
							AND  mad.AD_ID = isnull(@AD_ID,Mad.AD_ID)
						GROUP BY MSS.EMP_ID) SETT ON SETT.Emp_ID = MAD.Emp_ID

		WHERE E.Cmp_ID = @Cmp_Id	 and MAD.to_date >=@From_Date and MAD.to_date <=@To_Date
				and  mad.AD_ID = isnull(@AD_ID,Mad.AD_ID) and MAD.M_AD_Amount <> 0
				and MAD.S_Sal_Tran_ID is null and MAD.L_Sal_Tran_ID is null
				and ADM.AD_NOT_EFFECT_SALARY = 1
				-- added '>0' condition by Falak on 12-JAN-2011 to avoid hidden salary amount in summation.	
				
		order by E.Alpha_Emp_code				
	  end
	else
	begin
	
		Declare @CurCMP_ID as Numeric
		Declare @CurEmp_Id as Numeric 
		Declare @CurAd_Id as Numeric 
		Declare @Curmonth As Numeric
		Declare @CurYear as Numeric
		Declare @CurAmount as Numeric(18,2)

		IF @AD_EFFECT_ON_ESIC = 1 -- ADDED BY HARDIK 23/11/2020 FOR VIVO WEST BENGAL
			BEGIN
				Declare ESICMST cursor for	                  
					select CMP_ID,MAD.Emp_Id,Ad_Id,month,Year,Amount 
					from T0190_MONTHLY_AD_DETAIL_IMPORT  MAD WITH (NOLOCK)
						Inner Join #EMP_CONS EC  On MAD.Emp_ID=EC.EMP_ID
					where month = month(@to_date) and Year = year(@to_date) and Ad_Id=@ad_id 
				Open ESICMST
				Fetch next from ESICMST into @CurCMP_ID,@CurEmp_Id,@CurAd_Id,@Curmonth,@CurYear,@CurAmount
				While @@fetch_status = 0                    
					Begin  
		
						DECLARE @sal_tran_id1 NUMERIC(18,0)  
						Declare @M_AD_Amount Numeric(18,0)
						Declare @Comp_M_AD_Amount numeric(18,2)
			
						set @M_AD_Amount = 0
						set @Comp_M_AD_Amount = 0
			

						SET  @sal_tran_id1=0           
						IF @Curmonth >= 4 AND @Curmonth < = 9 
						BEGIN
						SELECT @sal_tran_id1=M_AD_tran_id FROM  dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
								WHERE emp_id=@CurEmp_Id AND MAD.cmp_id=@CurCMP_ID	AND @CurYear=YEAR(MAD.for_date) AND @Curmonth=month(MAD.for_date) 
								AND @Curmonth >= 4 AND @Curmonth <= 9  AND M_Ad_amount > 0  and AD_ID = @Esic_AD_Id 
						END
						IF 	MONTH(@From_Date)>= 10 AND MONTH(@From_Date)< = 12 
						BEGIN 

						SELECT @sal_tran_id1=M_AD_tran_id FROM  dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
						WHERE emp_id=@CurEmp_Id AND MAD.cmp_id=@CurCMP_ID	AND @CurYear=YEAR(MAD.for_date) AND @Curmonth=month(MAD.for_date) 
						AND @Curmonth >= 10 AND @Curmonth <= 12  AND M_Ad_amount > 0  and AD_ID = @Esic_AD_Id 

						END
						IF	MONTH(@From_Date)>= 1 AND MONTH(@From_Date)< = 3 
						BEGIN 
								SELECT @sal_tran_id1=M_AD_tran_id FROM  dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
								WHERE emp_id=@CurEmp_Id AND MAD.cmp_id=@CurCMP_ID	AND @CurYear=YEAR(MAD.for_date) AND @Curmonth=month(MAD.for_date)  
								AND @Curmonth >= 1 AND @Curmonth <= 3  AND M_Ad_amount > 0  and AD_ID = @Esic_AD_Id 
							  IF @Curmonth= 1
									BEGIN
										SELECT @sal_tran_id1=M_AD_tran_id FROM  dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
										WHERE emp_id=@CurEmp_Id AND MAD.cmp_id=@CurCMP_ID	AND @CurYear -1 =YEAR(MAD.for_date) 
										AND @Curmonth >= 1 AND @Curmonth <= 3  AND M_Ad_amount > 0  and AD_ID = @Esic_AD_Id 
									END
							END

					-- Added by Hardik 02/02/2021 for Cera
					Declare @ESIC_Actual_Gross_Salary_Term Numeric(18,2)
					Set @ESIC_Actual_Gross_Salary_Term=0
					If  @sal_tran_id1 = 0
						Begin
							select @ESIC_Actual_Gross_Salary_Term = Gross_Salary
							From T0095_Increment I
							Where I.Emp_ID = @Emp_ID and Increment_ID in (SELECT Increment_Id FROM T0200_MONTHLY_SALARY MS 
														WHERE	MS.Emp_ID=@Emp_Id AND  month(Month_End_Date) = month(@to_date) and Year(Month_End_Date) = year(@to_date))
							If @ESIC_Actual_Gross_Salary_Term < @ESIC_Limit And @ESIC_Actual_Gross_Salary_Term > 0 
								Set @sal_tran_id1 = -2
						End		
		
		
					--if (@CurAmount <= @ESIC_Limit) and @sal_tran_id1 <> 0
					if  @sal_tran_id1 <> 0
					begin
						SET @M_AD_Amount = CEILING(CAST((@CurAmount * @M_AD_Percentage/100) AS NUMERIC(18,2))) 
						SET @Comp_M_AD_Amount = CEILING(CAST((@CurAmount * @Comp_M_AD_Percentage/100) AS NUMERIC(18,2))) 
					end
		
					insert INto #ESIC_Temp_Table 
					values(@CurEmp_Id,@CurAd_Id,@Curmonth,@CurYear,@CurAmount,@M_AD_Amount,@CurAmount - @M_AD_Amount ,@Comp_M_AD_Amount)
		
					Fetch next from ESICMST into @CurCMP_ID,@CurEmp_Id,@CurAd_Id,@Curmonth,@CurYear,@CurAmount
				end
				close ESICMST                    
				deallocate ESICMST
			END
		ELSE
			BEGIN
				INSERT INTO #ESIC_Temp_Table 
				SELECT MAD.EMP_ID,MAD.AD_ID,MONTH,YEAR,AMOUNT,0,AMOUNT,0 
				FROM T0190_MONTHLY_AD_DETAIL_IMPORT  MAD
					INNER JOIN #EMP_CONS EC  ON MAD.EMP_ID=EC.EMP_ID
					INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID AND MAD.CMP_ID = AM.CMP_ID
				WHERE MONTH = MONTH(@TO_DATE) AND YEAR = YEAR(@TO_DATE) AND MAD.AD_ID=@AD_ID
			END
		
	If OBJECT_ID('tempdb..#Taxable_Payment_Process') is not NULL	
		Drop TABLE #Taxable_Payment_Process
		
	CREATE TABLE #Taxable_Payment_Process
	(
		Emp_ID				NUMERIC,
		NewTaxableAmount	NUMERIC(18,2),
		NewTaxAmount		NUMERIC(18,2),
		NewEdCessAmount		NUMERIC(18,2),
		NewSurchargeAmount	NUMERIC(18,2),
		NewRebateAmount		NUMERIC(18,2),
		NewTotalTaxAmount	NUMERIC(18,2),
		TaxableAmount		NUMERIC(18,2),
		TotalTaxAmount		NUMERIC(18,2),
		TotalTaxPaidAmount	NUMERIC(18,2),
		TDSToBeDeduct		NUMERIC(18,2)
	)
	CREATE UNIQUE CLUSTERED INDEX IX_Taxable_Payment_Process ON #Taxable_Payment_Process(Emp_ID)
	
	if @Auto_ded_Tds = 1
		begin

			select @new_constrint = COALESCE(@new_constrint + '#', '') +  '' + cast(Emp_ID as varchar(50))+ ''
			From #ESIC_Temp_Table
 
		-- COMMENTED BY HARDIK 23/11/2020 AS THIS TEMP TABLE IS NOT USING ANYWHERE AND CLIENT ENTERED TDS MANUALLY
 		--	insert into #tbl_Taxable_Income
		--	EXEC SP_IT_TAX_PREPARATION @Cmp_ID=@Cmp_ID,@From_Date=@from_date_tds,@To_Date=@To_date_tds,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint=@new_constrint,@Product_ID=0,@Taxable_Amount_Cond=0,@Form_ID=13,@Salary_Cycle_id=0,@Segment_ID=0,@Vertical=0,@SubVertical=0,@subBranch=0,@Sp_Call_For='Taxable_Amount'
	
	
/*			UPDATE #tbl_Taxable_Income
			SET percentage = isnull(TL.Percentage,0)
			FROM #tbl_Taxable_Income TI inner join 
			T0040_TAX_LIMIT as TL on TI.cmp_id = Tl.Cmp_ID and TI.gender =TL.Gender  and TL.From_Limit <= TI.taxble_amount and Tl.To_Limit >= TI.taxble_amount inner join 
			(SELECT max(for_date) as for_date,Gender,Cmp_ID from T0040_TAX_LIMIT  group by gender,Cmp_ID ) max_limit on TL.For_Date = max_limit.for_date and TL.Gender = max_limit.Gender and tl.Cmp_ID=max_limit.Cmp_ID 
*/
	
		end 

		UPDATE TPS
		SET TDSToBeDeduct = Isnull(TIS.TDS_Amount,0)
		FROM T0190_TAX_IMPORT_ON_NOT_EFFECT_SALARY TIS WITH (NOLOCK) INNER JOIN
			#Taxable_Payment_Process TPS ON TIS.Emp_id = TPS.Emp_ID
		WHERE dbo.GET_MONTH_ST_DATE(TIS.Month,TIS.Year) <= @to_date AND 
			dbo.GET_MONTH_ST_DATE(TIS.Month,TIS.Year)>=@from_date_tds AND dbo.GET_MONTH_ST_DATE(TIS.Month,TIS.Year) <= @To_date_tds 
			and TIS.Ad_Id = @AD_ID
		
/*		
		 insert INTO #tbl_Taxable_Income
		 select 0,EC.Emp_Id,0,NULL,NULL,0 
		 from #EMP_CONS EC 
		 left JOIN #tbl_Taxable_Income LTI on EC.Emp_ID =LTI.Emp_id
		 where isnull(LTI.emp_id,0) = 0
		
		;WITH CTE(tran_id,cmp_id,emp_id, month,year,St_Date,TDS_Amount,Is_Repeat)
		as
		( SELECT tran_id,cmp_id,TIS.emp_id, month,year,dbo.GET_MONTH_ST_DATE(Month,year),TDS_Amount,Is_Repeat
		from T0190_TAX_IMPORT_ON_NOT_EFFECT_SALARY TIS
		inner join  #EMP_CONS EC on TIS.Emp_id = EC.emp_id
		where dbo.GET_MONTH_ST_DATE(Month,year) <= @to_date AND 
		dbo.GET_MONTH_ST_DATE(Month,year)>=@from_date_tds AND dbo.GET_MONTH_ST_DATE(Month,year) <= @To_date_tds 
		and TIS.Ad_Id = @AD_ID
		)

		UPDATE #tbl_Taxable_Income
		set TDS_Amount = CTE.TDS_Amount
		,cmp_id = CTE.cmp_id
		from #tbl_Taxable_Income as TTI inner JOIN  
		CTE on TTI.EMP_ID =CTE.EMP_ID inner join
		(select MAX(st_date) as st_date,emp_id from CTE  group BY emp_id )as STE ON cte.emp_id = STE.emp_id and CTE.ST_DATE =STE.ST_DATE
		where 
		1 = (CASE when MONTH(@to_date)=CTE.month  and YEAR(@to_date) =CTE.year THEN 1 WHEN cte.Is_repeat = 1 then 1 else 0 end)


*/

		Select 
			MAD.Emp_ID,mad.AD_ID,mad.Amount,mad.Comp_ESIC,mad.ESIC,mad.Month ,mad.Year
			--,case when isnull(TI.TDS_Amount,0)=0 THEN ceiling((MAD.Amount * isnull(TI.percentage,0))/100) else TI.TDS_Amount end as TDS
			,ISNULL(TI.TDSToBeDeduct,0) as TDS
			--,mad.Net_Amount - case when isnull(TI.TDS_Amount,0)=0 THEN ceiling((MAD.Amount * isnull(TI.percentage,0))/100) else TI.TDS_Amount end as Net_Amount
			,mad.Net_Amount - Isnull(TI.TDSToBeDeduct,0) as Net_Amount
			,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Grd_Name,Alpha_Emp_Code as Alpha_Emp_Code,Type_Name,Dept_Name,Desig_Name,AD_Name,AD_LEVEL
			,cmp_Name,Cmp_Address,Branch_Address,Comp_name,branch_name,E.Vertical_ID 
			,@from_Date as P_From_Date , @To_date as P_To_Date,EC.Branch_ID,E.Pan_No,I_Q.Basic_Salary
			--,MAD.Amount as Amount
			--,mad.ESIC as Esic
			--,MAD.net_amount as Net_Amount
			NewTaxableAmount, NewTaxAmount,NewEdCessAmount, NewSurchargeAmount,NewRebateAmount,NewTotalTaxAmount,TaxableAmount As Taxble_Amount, TotalTaxAmount, TotalTaxPaidAmount, TDSToBeDeduct,
			0 As Percentage,0 as Ot_Hours,0 as Loan_Amount,0 as Basic_OT_Salary ,0 as Working_Days,0 as OT_Hour_Rate,0 as Shift_Sec
		From #ESIC_Temp_Table  MAD Inner join 
			T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN 
			T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN 
			#EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
			T0095_Increment I_Q WITH (NOLOCK) On EC.INCREMENT_ID= I_Q.Increment_ID Inner Join
			--( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,Basic_Salary from T0095_Increment I inner join 
			--		( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
			--		where Increment_Effective_date <= @To_Date
			--		and Cmp_ID = @Cmp_ID
			--		group by emp_ID  ) Qry on
			--		I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				--on E.Emp_ID = I_Q.Emp_ID  inner join
			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
			T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id left outer join
			T0040_Vertical_Segment VM WITH (NOLOCK) ON I_Q.Vertical_ID = VM.Vertical_ID 
			Inner join 
			T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  Inner join
			T0010_company_Master cm WITH (NOLOCK) on E.Cmp_ID = cm.cmp_ID
			--left  join #tbl_Taxable_Income TI on MAD.Emp_ID = TI.Emp_Id 
			Left Outer Join #Taxable_Payment_Process TI On MAD.Emp_ID = TI.Emp_ID
			left outer join T0210_ESIC_On_Not_Effect_on_Salary ESN WITH (NOLOCK) on MAD.Emp_ID = ESN.Emp_Id and MAD.AD_ID = ESN.Ad_Id 
			and MAD.Month = MONTH(ESN.For_Date) and MAD.year =YEAR(ESN.For_Date)
		WHERE E.Cmp_ID = @Cmp_Id	 and MAD.Month = month(@to_date) and MAD.year <=year(@To_Date)
			and  mad.AD_ID = isnull(@AD_ID,Mad.AD_ID) and MAD.Amount <> 0
			and ADM.AD_NOT_EFFECT_SALARY = 1
			and isnull(ESN.Tran_Id,0) =0	
		
		order by E.Alpha_Code,E.Emp_code
	end
end	
	 
RETURN 



