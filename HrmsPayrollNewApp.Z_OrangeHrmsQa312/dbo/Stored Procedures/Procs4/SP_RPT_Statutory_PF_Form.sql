



--====================================================
-- Created By Rohit For PF Report on 22-nov-2012
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--====================================================
CREATE  PROCEDURE [dbo].[SP_RPT_Statutory_PF_Form]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @PF_LIMIT as numeric
	Declare @PF_DEF_ID		numeric 
	set @PF_DEF_ID =2
		
	set @PF_LIMIT = 15000	
	
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
			
			Insert Into @Emp_Cons
			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
					inner join T0100_lefT_emp Le WITH (NOLOCK) on i.emp_Id = le.emp_ID
			Where I.Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
					and Left_date >=@From_Date and Left_Date <=@to_Date
			
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
	 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
		begin    
		   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
		   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
		   set @From_Date = @Sal_St_Date
		   Set @To_Date = @Sal_end_Date   
		End
	
	
	 Declare @AC_1_1 numeric(10,2)    
	 Declare @AC_1_2 numeric(10,2)    
	 Declare @AC_2_3 numeric(10,2)    
	 Declare @AC_10_1 numeric(10,2)    
	 Declare @AC_21_1 numeric(10,2)    
	 Declare @AC_22_3 numeric(10,4)    
	 Declare @AC_22_4 numeric(10,4)    
	 Declare @AC_10_1_Max_Limit numeric(10,2)     
	 
	     
	 Set @AC_1_1  = 0    
	 Set @AC_1_2  = 0    
	 Set @AC_2_3  = 0    
	 Set @AC_10_1 = 0    
	 Set @AC_21_1 = 0    
	 Set @AC_22_3 = 0    
	 Set @AC_22_4 = 0  
	 	    
	Declare @PF_Pension_Age as numeric(18,2)
			
	SELECT TOP 1 @PF_Pension_Age = isnull(PF_Pension_Age,0), @PF_Limit = ISNULL(ACC_10_1_Max_Limit ,0) ,@AC_10_1 = ISNULL(ACC_10_1,0)
	FROM T0040_General_setting gs WITH (NOLOCK) inner join     
		T0050_General_Detail gd WITH (NOLOCK) on gs.gen_Id =gd.gen_ID     
		where gs.Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID)    
			and For_Date in (select max(For_Date) from T0040_General_setting  g WITH (NOLOCK) inner join     
			T0050_General_Detail d WITH (NOLOCK) on g.gen_Id =d.gen_ID       
		where g.Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID)    
	and For_Date <=@To_Date )  	  
    	
	--------
	DECLARE @TEMP_DATE AS DATETIME	
	
	DECLARE @PF_REPORT TABLE
		(
			MONTH		NUMERIC ,
			YEAR		NUMERIC ,
			FOR_DATE	DATETIME
		)
	
	SET @TEMP_DATE = @FROM_DATE
	
	WHILE @TEMP_DATE <= @TO_DATE
		BEGIN
			
			INSERT INTO @PF_REPORT (MONTH,YEAR,FOR_DATE)
				VALUES(MONTH(@TEMP_DATE),YEAR(@TEMP_DATE),@TEMP_DATE)	
			
			SET @TEMP_DATE = DATEADD(m,1,@TEMP_DATE)
		END

	if	exists (select * from [tempdb].dbo.sysobjects where name like '#EMP_PF_REPORT' )		
			begin
				drop table #EMP_PF_REPORT
			end
			
	CREATE table #EMP_PF_REPORT 
		(
			CMP_ID	NUMERIC,
			EMP_CODE	NUMERIC,
			EMP_ID		NUMERIC,
			EMP_NAME	VARCHAR(200),
			PF_NO		VARCHAR(50),
			MONTH		NUMERIC,
			YEAR		NUMERIC,
			FOR_DATE	DATETIME
		)
		
	INSERT INTO  #EMP_PF_REPORT
	
	SELECT  QRY.CMP_ID,QRY.EMP_CODE,QRY.EMP_ID,EMP_full_NAME,PF_NO ,t.month, t.year, t.for_Date from @PF_Report t cross join 
	( SELECT DISTINCT SG.CMP_ID,SG.EMP_ID ,E.EMP_CODE ,E.EMP_full_NAME ,SSN_NO as PF_NO FROM    T0200_MONTHLY_SALARY  SG WITH (NOLOCK) INNER JOIN 
			( select Emp_ID , M_AD_Percentage as PF_PER , M_AD_Amount as PF_Amount ,sal_Tran_ID
					from T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID where AD_DEF_ID = @PF_DEF_ID 
					and ad_not_effect_salary <> 1
					and AD.CMP_ID = @CMP_ID) MAD on SG.Emp_ID = MAD.Emp_ID 
						and SG.Sal_Tran_ID = MAD.Sal_Tran_ID INNER JOIN
				T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID INNER JOIN
				@EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID				
		WHERE   e.CMP_ID = @CMP_ID 
				and SG.Month_End_Date >=@From_Date  and SG.Month_End_Date <= @To_Date )QRY -- Added By Ali 07012014  Month_St_Date -> Month_End_Date
	
	
	IF	EXISTS (select * from [tempdb].dbo.sysobjects where name like '#EMP_SALARY' )		
		begin
			drop table #EMP_SALARY
		end
	
		CREATE table #EMP_SALARY 
			(
				EMP_ID					NUMERIC,
				MONTH					NUMERIC,
				YEAR					NUMERIC,
				SALARY_AMOUNT			NUMERIC,
				OTHER_PF_SALARY			NUMERIC,
				MONTH_ST_DATE			DATETIME,
				MONTH_END_DATE			DATETIME,
				PF_PER					NUMERIC(18,2),
				PF_AMOUNT				NUMERIC,
				PF_SALARY_AMOUNT		NUMERIC,
				PF_LIMIT				numeric,
				PF_367					NUMERIC,
				PF_833					NUMERIC,
				PF_DIFF_6500			NUMERIC,
				VPF                  	NUMERIC,
				Emp_Age					NUMERIC,
				Sal_Cal_Day				Numeric(18,2), -- Added by Falak on 09-MAY-2011
				Absent_days				NUMERIC(18,2),
				Is_Sett                 TinyINt Default 0,    --Nikunj 25-04-2011
				Sal_Effec_Date          DateTime Default GetDate(), --Nikunj 25-04-2011
				EDLI_Wages				Numeric,
				Arear_Day				Numeric(18,2),
				arrear_days				numeric(18,1),
				VPF_PER					Numeric(18,2)
			 )
			
			
			-- (m_ad_Calculated_Amount + Arear_Basic) added by mitesh on 08/02/2012
			
		    INSERT INTO #EMP_SALARY
		    
		    SELECT  SG.EMP_ID,MONTH(MONTH_ST_DATe),YEAR(MONTH_ST_DATE),SG.Salary_Amount 
				 ,0 ,sg.Month_st_Date,SG.Month_End_date
				 ,MAD.PF_PER,MAD.PF_AMOUNT,(m_ad_Calculated_Amount + Isnull(Arear_Basic,0)) as m_ad_Calculated_Amount,@PF_Limit,0,0,0,isnull(CMD.VPF,0),dbo.F_GET_AGE(Date_of_Birth,MONTH_ST_DATE,'N','N')
				 ,SG.Sal_Cal_Days,0,0,NULL,0,Isnull(sg.Arear_Day,0) -- Added by Falak on 09-MAY-2011
				 ,SG.arear_day,VPF_PER -- added by mitesh on 18/02/2012
				FROM    T0200_MONTHLY_SALARY  SG  WITH (NOLOCK) INNER JOIN 
				(Select Emp_ID , m_ad_Percentage as PF_PER , (m_ad_Amount + Isnull(M_AREAR_AMOUNT,0)) as PF_Amount , m_ad_Calculated_Amount ,SAL_tRAN_ID from 
					T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = @PF_DEF_ID  And ad_not_effect_salary <> 1 and sal_type<>1
					and AD.CMP_ID = @CMP_ID ) MAD on SG.Emp_ID = MAD.Emp_ID  
					AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN
					T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join
				@EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID
				left outer join
				(Select Emp_ID,(m_ad_Amount + isnull(M_AREAR_AMOUNT,0)) as VPF,SAL_tRAN_ID,AD.M_AD_Percentage as VPF_PER  from 
					T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = 4  And ad_not_effect_salary <> 1 and sal_type<>1
					and AD.CMP_ID = @CMP_ID) CMD on SG.Emp_ID= CMD.Emp_ID AND SG.SAL_tRAN_ID = CMD.SAL_TRAN_ID				
		WHERE   e.CMP_ID = @CMP_ID --changed by Falak on 04-JAN-2010 due error in condition and more than one record for same emp binds.
 				and SG.Month_End_Date >=@From_Date  and SG.Month_End_Date <= @To_Date   -- Added By Ali 07012014  Month_St_Date -> Month_End_Date

		
		
--In form 3a you have to saw March Challn Paid in April.for This Setting you can see in Report Leval Formula.Nikunj
-----By nikunj 25-04-2011 For Settlement Pf Effect In Form 3A--------------------------Start
If Exists(Select S_Sal_Tran_Id From dbo.T0201_monthly_salary_sett WITH (NOLOCK) where S_Eff_Date Between @From_Date And @To_Date And Cmp_Id=@Cmp_Id)
	Begin 
				INSERT INTO #EMP_SALARY
				SELECT  SG.EMP_ID,MONTH(S_MONTH_ST_DATe),YEAR(S_MONTH_ST_DATE),SG.s_Salary_Amount,0,sg.S_Month_st_Date,SG.S_Month_End_date
					 ,MAD.PF_PER,MAD.PF_AMOUNT,m_ad_Calculated_Amount ,@PF_Limit,0,0,0,isnull(CMD.VPF,0),dbo.F_GET_AGE(Date_of_Birth,S_MONTH_ST_DATE,'N','N'),
					 SG.S_Sal_Cal_Days,0,1,SG.S_Eff_date,0,0,0,0-- Added by Falak on 09-MAY-2011
					FROM t0201_monthly_salary_sett  SG  WITH (NOLOCK) INNER JOIN 
					( select Emp_ID , m_ad_Percentage as PF_PER , (m_ad_Amount + isnull(M_AREAR_AMOUNT,0)) as PF_Amount , m_ad_Calculated_Amount ,SAL_tRAN_ID from 
						T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = @PF_DEF_ID And ad_not_effect_salary <> 1 And ad.sal_type=1
						and AD.CMP_ID = @CMP_ID) MAD on SG.Emp_ID = MAD.Emp_ID 
						AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN
						T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join
					@EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID	
					left outer join
					(Select Emp_ID,(m_ad_Amount + isnull(M_AREAR_AMOUNT,0)) as VPF,SAL_tRAN_ID  from 
						T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = 4  And ad_not_effect_salary <> 1 and sal_type=1
						and AD.CMP_ID = @CMP_ID) CMD on SG.Emp_ID= CMD.Emp_ID AND SG.SAL_tRAN_ID = CMD.SAL_TRAN_ID
			WHERE   e.CMP_ID = @CMP_ID 
						And S_Eff_Date Between @From_Date And @To_Date
 					--and SG.s_Month_St_Date >=@From_Date  and SG.s_Month_End_Date <= @To_Date 
				Update #EMP_SALARY Set 
				Salary_Amount= ES.Salary_Amount+Qry.Salary_Amount,
				PF_Amount=ES.PF_Amount+Qry.PF_Amount,
				PF_Salary_Amount=ES.PF_Salary_Amount+Qry.PF_Salary_Amount,
				VPF = es.VPF + Qry.VPF From 
				#EMP_SALARY As ES INNER JOIN
				(Select SUM(Salary_Amount) As Salary_Amount,SUM(PF_Amount) As PF_Amount,SUM(PF_Salary_Amount) As PF_Salary_Amount,SUM(VPF) as VPF,Emp_Id,Sal_Effec_Date From #EMP_SALARY where Is_Sett=1 Group By Emp_Id,Sal_Effec_Date ) As Qry ON ES.Emp_Id=Qry.Emp_ID And ES.Month=Month(Qry.Sal_Effec_Date) And ES.Year=Year(Qry.Sal_Effec_Date)

				Delete From #EMP_SALARY where Is_Sett=1
	End		
------------------------------------------------------------------------------------------End

		--Declare @PF_Pension_Age as numeric(18,2)
			
		--select Top 1	@PF_Pension_Age = isnull(PF_Pension_Age,0), @PF_Limit = ISNULL(ACC_10_1_Max_Limit ,0) ,@AC_10_1 = ISNULL(ACC_10_1,0)
		--from T0040_General_setting gs inner join     
		--	T0050_General_Detail gd on gs.gen_Id =gd.gen_ID     
		--	where gs.Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID)    
		--		and For_Date in (select max(For_Date) from T0040_General_setting  g inner join     
		--		T0050_General_Detail d on g.gen_Id =d.gen_ID       
		--	where g.Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID)    
		--and For_Date <=@To_Date )  		
/* Commented by Falak on 18102011 due to error in calculation 
	UPDATE #EMP_SALARY SET PF_Limit = CASE
          WHEN PF_SALARY_AMOUNT >6500  THEN 6500
           WHEN PF_SALARY_AMOUNT < = 6500  THEN PF_SALARY_AMOUNT * 0.12         
           END
*/	 
	
	Set @AC_10_1_Max_Limit = round(@PF_Limit * @AC_10_1/100,0)   
	                
	update #EMP_SALARY
	set	  PF_833 = round(PF_SALARY_AMOUNT * 0.0833,0)
		 ,PF_367 = PF_Amount - round(PF_SALARY_AMOUNT * 0.0833,0)
	where PF_SALARY_AMOUNT <= PF_Limit

	Update #EMP_SALARY
	set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit
		,PF_833 = ISNULL(@AC_10_1_Max_Limit,0)
		,PF_367 = PF_Amount - ISNULL(@AC_10_1_Max_Limit,0)
	where PF_SALARY_AMOUNT > PF_Limit
	
	Update #EMP_SALARY    
		set PF_833 = 0    
			,PF_367 = PF_Amount  
			,PF_LIMIT =0   
		where Emp_Age >= @PF_PEnsion_Age and @PF_PEnsion_Age>0   
		
	Update #EMP_SALARY    
		set PF_833 =   0    
		  ,PF_LIMIT =  0   
		where PF_833 = 0
		
	Update #EMP_SALARY 
	  set PF_LIMIT = PF_SALARY_AMOUNT
	 where PF_SALARY_AMOUNT < @PF_Limit
		 
	 Update #EMP_SALARY 
		set EDLI_Wages = PF_SALARY_AMOUNT
	 
	 Update #EMP_SALARY 
		set EDLI_Wages = @PF_Limit
	 where PF_SALARY_AMOUNT > @PF_Limit
			
	 Update #EMP_SALARY 
		set PF_Amount = PF_Amount 
		    
		SELECT distinct  RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500) as PF_No_Order,
		-- EPF.*--, (SALARY_AMOUNT + ISNULL(OTHER_PF_SALARY,0) ) as SALARY_AMOUNT
			EPF.CMP_ID,EPF.EMP_CODE,EPF.EMP_ID,EPF.EMP_NAME,EPF.PF_NO
				,(PF_AMOUNT) PF_AMOUNT	,PF_PER,PF_Limit,EDLI_Wages , PF_SALARY_AMOUNT,PF_833,PF_367
				,PF_Diff_6500,ES.VPF
				,Grd_Name,Type_Name,dept_Name,DGM.Desig_Name,Cmp_Name,Cmp_Address,cm.PF_No as CPF_NO
				,@From_Date P_From_Date ,@To_Date P_To_Date,Le.Left_Date,Le.Left_Reason
				--,MS.Absent_Days
				--,ES.Sal_Cal_Day
				--,ES.arrear_days,ES.VPF_PER
				--,EMP_SECOND_NAME,E.Basic_Salary,E.Emp_code,Emp_Full_Name,Father_Name
				
				--,ED.Address as ED_Address,ed.BirthDate as ED_BirtDate,ed.Name as ED_Name,ed.D_Age as ED_Age,ed.RelationShip as ED_Relationship,ed.Share as ED_Share,ed.Is_Resi as Ed_IS_residence
				----------added jimit 29082016-------------------------------------
				,(Select STUFF((SELECT ',' + EDM.Address From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0090_EMP_DEPENDANT_DETAIL EDM WITH (NOLOCK) ON E.Emp_ID=EDM.Emp_id
					  WHERE Q_I.Emp_ID=EDM.Emp_id FOR XML PATH('')), 1,1,'')) as ED_Address
				,(Select STUFF((SELECT ',' + Convert(varchar(20),EDM.BirthDate,103) From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0090_EMP_DEPENDANT_DETAIL EDM WITH (NOLOCK) ON E.Emp_ID=EDM.Emp_id
					  WHERE Q_I.Emp_ID=EDM.Emp_id FOR XML PATH('')), 1,1,'')) as ED_BirtDate
				,(Select STUFF((SELECT ',' + EDM.Name From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0090_EMP_DEPENDANT_DETAIL EDM WITH (NOLOCK) ON E.Emp_ID=EDM.Emp_id
					  WHERE Q_I.Emp_ID=EDM.Emp_id FOR XML PATH('')), 1,1,'')) as ED_Name	  	 
				,(Select STUFF((SELECT ',' + Convert(varchar(20),EDM.D_Age) From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0090_EMP_DEPENDANT_DETAIL EDM WITH (NOLOCK) ON E.Emp_ID=EDM.Emp_id
					  WHERE Q_I.Emp_ID=EDM.Emp_id FOR XML PATH('')), 1,1,'')) as ED_Age
				,(Select STUFF((SELECT ',' + EDM.RelationShip From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0090_EMP_DEPENDANT_DETAIL EDM WITH (NOLOCK) ON E.Emp_ID=EDM.Emp_id
					  WHERE Q_I.Emp_ID=EDM.Emp_id FOR XML PATH('')), 1,1,'')) as ED_Relationship
				,(Select STUFF((SELECT ',' + Convert(varchar(20),EDM.Share) From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0090_EMP_DEPENDANT_DETAIL EDM WITH (NOLOCK) ON E.Emp_ID=EDM.Emp_id
					  WHERE Q_I.Emp_ID=EDM.Emp_id FOR XML PATH('')), 1,1,'')) as ED_Share
				,(Select STUFF((SELECT ',' + Convert(varchar(20),EDM.Is_Resi) From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0090_EMP_DEPENDANT_DETAIL EDM WITH (NOLOCK) ON E.Emp_ID=EDM.Emp_id
					  WHERE Q_I.Emp_ID=EDM.Emp_id FOR XML PATH('')), 1,1,'')) as Ed_IS_residence
					  					  					  	  	 
				,eed.Desig_Name as EED_Desig_name,EED.Employer_Name as EED_Employer_Name,EED.St_Date as EED_ST_Date,EED.End_Date as EED_Ed_Date
				--,ECD.C_Age as ECD_Age,ECD.Date_Of_Birth as ECD_Birth_Date,ECD.Gender as ECD_gender,ECD.Is_Dependant as ECD_Dependannt,ECD.Name as ECD_Name,ECD.Relationship as ECD_Relation,ECD.Is_Resi as ECD_resi
				----------added jimit 29082016-------------------------------------
				,(Select STUFF((SELECT ',' + Convert(varchar(20),EDM.C_Age) From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0090_EMP_CHILDRAN_DETAIL EDM WITH (NOLOCK) ON E.Emp_ID=EDM.Emp_id
					  WHERE Q_I.Emp_ID=EDM.Emp_id FOR XML PATH('')), 1,1,'')) as ECD_Age
				,(Select STUFF((SELECT ',' + Convert(varchar(20),EDM.Date_Of_Birth,103) From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0090_EMP_CHILDRAN_DETAIL EDM WITH (NOLOCK) ON E.Emp_ID=EDM.Emp_id
					  WHERE Q_I.Emp_ID=EDM.Emp_id FOR XML PATH('')), 1,1,'')) as ECD_Birth_Date
				,(Select STUFF((SELECT ',' + EDM.Gender From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0090_EMP_CHILDRAN_DETAIL EDM WITH (NOLOCK) ON E.Emp_ID=EDM.Emp_id
					  WHERE Q_I.Emp_ID=EDM.Emp_id FOR XML PATH('')), 1,1,'')) as ECD_gender	  	 
				,(Select STUFF((SELECT ',' + Convert(varchar(20),EDM.Is_Dependant) From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0090_EMP_CHILDRAN_DETAIL EDM WITH (NOLOCK) ON E.Emp_ID=EDM.Emp_id
					  WHERE Q_I.Emp_ID=EDM.Emp_id FOR XML PATH('')), 1,1,'')) as ECD_Dependannt
				,(Select STUFF((SELECT ',' + EDM.Name From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0090_EMP_CHILDRAN_DETAIL EDM WITH (NOLOCK) ON E.Emp_ID=EDM.Emp_id
					  WHERE Q_I.Emp_ID=EDM.Emp_id FOR XML PATH('')), 1,1,'')) as ECD_Name
				,(Select STUFF((SELECT ',' +EDM.Relationship From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0090_EMP_CHILDRAN_DETAIL EDM WITH (NOLOCK) ON E.Emp_ID=EDM.Emp_id
					  WHERE Q_I.Emp_ID=EDM.Emp_id FOR XML PATH('')), 1,1,'')) as ECD_Relation
				,(Select STUFF((SELECT ',' + Convert(varchar(20),EDM.Is_Resi) From T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN  T0090_EMP_CHILDRAN_DETAIL EDM WITH (NOLOCK) ON E.Emp_ID=EDM.Emp_id
					  WHERE Q_I.Emp_ID=EDM.Emp_id FOR XML PATH('')), 1,1,'')) as ECD_resi
				----------------ended---------------------------------------------------					  
				,BM.Branch_Name as BRanch_Name
				,BM.Branch_Address as BM_Address,BM.Branch_City as BM_City,BM.State_ID as BM_State_Id,BM_SM.State_Name as BM_State_Name
				,E.*
				--,E_BM.bank_name as E_BM_Bank_name,E_BM.bank_code as E_BM_Bank_Code,E_BM.Bank_Ac_No as E_BM_ACC,E_BM.Bank_Address as E_BM_Address,E_BM.Bank_Branch_Name as E_BM_Branch_name
				,E_BM.bank_name as E_BM_Bank_name,E_BM.bank_code as E_BM_Bank_Code,Q_I.Inc_Bank_AC_No as E_BM_ACC,Q_I.Bank_Branch_Name as E_BM_Branch_name
			--,ED.Name
			,E.DBRD_Code,E.Mobile_No,E.Work_Email,CM.Cmp_Email,CM.Cmp_Phone
			,LOC.Loc_name,Q_I.is_physical,IMM.Imm_Issue_Date,IMM.Imm_Date_of_Expiry,IMM.Imm_No,E.UAN_No	--Added by Nimesh 07-Jul-2015 (For New format of PF Form 11)   --UAN NO is Added By Ramiz on 22/08/2015
			,cm.Registration_No --added jimit 29082016			
			,cm.Cmp_City,cm.Cmp_TAN_No,cm.Cmp_PAN_No -- added by jimit 29112016
			,(CASE WHEN LE.IS_DEATH = 1 THEN 'DEATH' 
				   WHEN LE.IS_RETIRE = 1 THEN 'RETIREMENT'
				   WHEN LE.IS_TERMINATE = 1  THEN 'TERMINATE'
				   ELSE 'RESIGNATION' END)AS LEFT_REASON_TYPE   -- added by jimit 30112016
		   ,cm.From_Date,E_BM.Bank_Address  --added by chetan 160817
		    --added by chetan 15122017
			,cm.ESIC_No,ISNULL(cm.PF_No,'')+ISNULL(E.SSN_No,'') AS Account_No,E.EmpName_Alias_PF
			,CASE WHEN CHARINDEX(Emp_Last_Name,Father_name) > 0 THEN E.Father_name ELSE LTRIM(ISNULL(E.Father_name,'') +' '+ ISNULL(E.Emp_Last_Name,''))END AS Father_Name_With_Surname
			,E.Date_Of_Birth,CASE WHEN E.Gender='M' THEN 'MALE' ELSE 'FEMALE' END AS GENDER
		  FROM #EMP_PF_REPORT EPF 
		  INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID left outer join
		  T0100_left_emp LE WITH (NOLOCK) on E.Emp_ID =Le.Emp_ID 
		  LEFT OUTER JOIN 	
		  (select sum((PF_AMOUNT)) PF_AMOUNT,PF_PER,PF_Limit,EDLI_Wages , PF_SALARY_AMOUNT,sum(PF_833) as PF_833,sum(PF_367) as PF_367
				,sum(PF_Diff_6500) as PF_Diff_6500,VPF,EMP_ID from #EMP_SALARY group by PF_PER,PF_Limit,EDLI_Wages,VPF,emp_id,PF_SALARY_AMOUNT) ES 
		  
		  ON EPF.EMP_ID = ES.EMP_ID 
		  --AND EPF.MONTH = ES.MONTH AND EPF.YEAR = ES.YEAR 
						--	left outer join T0200_MONTHLY_SALARY MS on ES.EMP_ID=MS.Emp_ID and ES.MONTH=month(MS.Month_St_Date) and  
						--ES.YEAR =year(MS.Month_St_Date)
						 INNER JOIN 
						( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,Type_ID,I.is_physical,I.Inc_Bank_AC_No,I.Bank_Branch_Name,I.Bank_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK)	-- Ankit 09092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON	-- Ankit 09092014 for Same Date Increment
		E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
		T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Left outer join 
		T0040_Type_Master TM WITH (NOLOCK) on Q_I.Type_ID = Tm.Type_Id  Inner join 
		T0010_company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_Id left join
		T0090_EMP_DEPENDANT_DETAIL ED WITH (NOLOCK) on e.Emp_ID =ED.Emp_ID and NomineeFor in (0,1) left Join
		T0090_EMP_EXPERIENCE_DETAIL EED WITH (NOLOCK) on E.Emp_ID=EED.Emp_ID and e.Cmp_ID=eed.Cmp_ID left join
		T0090_EMP_CHILDRAN_DETAIL ECD WITH (NOLOCK) on e.Emp_ID=ECD.Emp_ID and e.Cmp_ID=ECD.Cmp_ID left join
		T0020_STATE_MASTER BM_SM WITH (NOLOCK) on bm_sm.State_ID=BM.State_ID LEFT JOIN
		T0040_BANK_MASTER E_BM WITH (NOLOCK) on Q_I.BANK_ID=E_BM.BANK_ID and E.CMP_ID=E_BM.CMP_ID LEFT OUTER JOIN
		T0001_LOCATION_MASTER LOC WITH (NOLOCK) ON E.LOC_ID=LOC.Loc_ID LEFT OUTER JOIN
			(
				SELECT	IM.Cmp_ID,IM.Emp_ID,IM.Imm_Issue_Date,IM.Imm_Date_of_Expiry,IM.Imm_No 
				FROM	T0090_EMP_IMMIGRATION_DETAIL IM WITH (NOLOCK) INNER JOIN (
					SELECT	MAX(Imm_Issue_Date) AS Imm_Issue_Date,Cmp_ID,Emp_ID
					FROM	T0090_EMP_IMMIGRATION_DETAIL IM1 WITH (NOLOCK)				
					GROUP BY Cmp_ID,Emp_ID	
				  ) IM1 ON IM1.Cmp_ID=IM.Cmp_ID AND IM1.Emp_ID=IM.Emp_ID AND IM1.Imm_Issue_Date=IM.Imm_Issue_Date
			) IMM  ON E.Cmp_ID=IMM.Cmp_ID AND E.Emp_ID=IMM.Emp_ID
		order by RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)


		Drop Table #EMP_PF_REPORT
		Drop Table #EMP_SALARY

RETURN




