



-- Created by rohit for PF Trust on 02022016
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_FORM_3A_GET_PF_Trust]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		varchar(max)=''
	,@Cat_ID 		varchar(max)='' 
	,@Grd_ID 		varchar(max)=''
	,@Type_ID 		varchar(max)=''
	,@Dept_ID 		varchar(max)=''
	,@Desig_ID 		varchar(max)=''
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)=''
	,@Segment_Id  varchar(max)=''  
	,@Vertical_Id varchar(max)=''
	,@SubVertical_Id varchar(max)=''
	,@SubBranch_Id varchar(max)='' 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @PF_LIMIT as numeric
	Declare @PF_DEF_ID		numeric 
	set @PF_DEF_ID =2
		
	set @PF_LIMIT = 15000	
	
	IF @Branch_ID = '0' or @Branch_ID=''  
		set @Branch_ID = null
		
	IF @Cat_ID = '0' or   @Cat_ID=''
		set @Cat_ID = null

	IF @Grd_ID = '0' or  @Grd_ID=''
		set @Grd_ID = null

	IF @Type_ID = '0'  or @Type_ID=''
		set @Type_ID = null

	IF @Dept_ID = '0' or @Dept_ID=''
		set @Dept_ID = null

	IF @Desig_ID = '0'  or @Desig_ID=''
		set @Desig_ID = null			

	IF @Emp_ID = 0  
		set @Emp_ID = null
		
	If @Segment_Id = '0' or @Segment_Id=''		
	set @Segment_Id = null
	If @Vertical_Id = '0' or @Vertical_Id=''		 
	set @Vertical_Id = null
	If @SubVertical_Id = '0' or @SubVertical_Id='' 	 
	set @SubVertical_Id = null	
	If @SubBranch_Id = '0' or @SubBranch_Id=''	
	set @SubBranch_Id = null	

	CREATE TABLE #Emp_Cons
	(
		Emp_ID	numeric,
		Branch_ID numeric,  
	   Increment_ID numeric 
	)
	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'',0,0    	
	
	-- Added by rohit for PF trust employee filter
		delete from #EMP_CONS where Emp_ID in(select Emp_ID from T0080_EMP_MASTER where isnull(is_PF_Trust ,0) = 0)
	--ended by rohit for pf trust filter
	
	Declare @Sal_St_Date   Datetime    
    Declare @Sal_end_Date   Datetime  
    Declare @IS_NCP_PRORATA as int  
  
  		   
	Set @IS_NCP_PRORATA = 0
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date, @PF_LIMIT =  PF_LIMIT, @IS_NCP_PRORATA = IS_NCP_PRORATA
			  from T0040_GENERAL_SETTING GS WITH (NOLOCK) Inner Join T0050_GENERAL_DETAIL GD WITH (NOLOCK) On GS.Gen_ID = GD.GEN_ID And GS.Cmp_ID = GD.CMP_ID
			  where GS.Cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)
		End
	Else
		Begin
					  
			select @Sal_St_Date  =Sal_st_Date, @PF_LIMIT =  PF_LIMIT , @IS_NCP_PRORATA = IS_NCP_PRORATA
			  from T0040_GENERAL_SETTING GS WITH (NOLOCK) Inner Join T0050_GENERAL_DETAIL GD WITH (NOLOCK) On GS.Gen_ID = GD.GEN_ID And GS.Cmp_ID = GD.CMP_ID
			  inner JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T ON T.Branch_ID=GS.Branch_ID 
			  where GS.Cmp_ID = @cmp_ID 
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING G1 WITH (NOLOCK)
			  inner JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T1 ON T1.Branch_ID=G1.Branch_ID 
			   where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)
				   
			--select @Sal_St_Date  =Sal_st_Date, @PF_LIMIT =  PF_LIMIT , @IS_NCP_PRORATA = IS_NCP_PRORATA
			--  from T0040_GENERAL_SETTING GS Inner Join T0050_GENERAL_DETAIL GD On GS.Gen_ID = GD.GEN_ID And GS.Cmp_ID = GD.CMP_ID
			--  where GS.Cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			--  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)
		End    
       
     
       
	 if isnull(@Sal_St_Date,'') = ''    
		begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date    
		end     
	 else if day(@Sal_St_Date) =1 
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
				
	-- Changed By Ali 23112013 EmpName_Alias
	INSERT INTO  #EMP_PF_REPORT	
	SELECT  QRY.CMP_ID,QRY.EMP_CODE,QRY.EMP_ID,EMP_full_NAME,PF_NO ,t.month, t.year, t.for_Date from @PF_Report t cross join 
	( SELECT DISTINCT SG.CMP_ID,SG.EMP_ID ,E.EMP_CODE ,ISNULL(E.EmpName_Alias_PF,E.Emp_Full_Name) as EMP_full_NAME ,SSN_NO as PF_NO FROM    T0200_MONTHLY_SALARY  SG  WITH (NOLOCK) INNER JOIN 
			( select Emp_ID , M_AD_Percentage as PF_PER , M_AD_Amount as PF_Amount ,sal_Tran_ID
					from T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID where AD_DEF_ID = @PF_DEF_ID 
					and ad_not_effect_salary <> 1
					and AD.CMP_ID = @CMP_ID) MAD on SG.Emp_ID = MAD.Emp_ID 
						and SG.Sal_Tran_ID = MAD.Sal_Tran_ID INNER JOIN
				T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID  INNER JOIN
				#EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID				
		WHERE   e.CMP_ID = @CMP_ID 
				and SG.Month_St_Date >=@From_Date  and SG.Month_End_Date <= @To_Date )QRY				

	
		
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
				Sal_Cal_Day				Numeric(18,2), 
				Absent_days				NUMERIC(18,2),
				Is_Sett                 TinyINt Default 0,    
				Sal_Effec_Date          DateTime Default GetDate(),
				EDLI_Wages				Numeric,
				Arear_Day				Numeric(18,2),
				arrear_days				numeric(18,1),
				VPF_PER					Numeric(18,2),
				Nationality				varchar(100),
				cmp_full_pf				Tinyint
			 )
			
			
			
		    INSERT INTO #EMP_SALARY
		    
		    SELECT  SG.EMP_ID,MONTH(MONTH_ST_DATe),YEAR(MONTH_ST_DATE),SG.Salary_Amount 
				 ,0 ,sg.Month_st_Date,SG.Month_End_date
				 ,MAD.PF_PER,MAD.PF_AMOUNT,(m_ad_Calculated_Amount + Isnull(Arear_Basic,0)+ Isnull(Basic_Salary_Arear_cutoff ,0) + isnull(CMD_new.Other_PF_Calculate,0)) as m_ad_Calculated_Amount,
				
				 (Select Top 1 PF_Limit From T0040_GENERAL_SETTING G WITH (NOLOCK) Inner Join T0050_General_Detail GD WITH (NOLOCK) on G.Gen_ID = GD.GEN_ID
					Where G.Cmp_ID = @Cmp_ID 
				
						and EXISTS (select Data from dbo.Split(@Branch_ID, '#') B Where cast(B.data as numeric)=Isnull(Branch_ID,0) or @Branch_id Is null)  --Added By Jaina 5-11-2015
					And For_Date = (Select Max(For_Date) From T0040_GENERAL_SETTING WITH (NOLOCK)
						Where Cmp_ID = @Cmp_ID 
				
						and EXISTS (select Data from dbo.Split(@Branch_ID, '#') B Where cast(B.data as numeric)=Isnull(Branch_ID,0) or @Branch_id Is null)   --Added By Jaina 5-11-2015
						 And For_Date<= Month_End_Date) )
				 
			
				 ,0,0,0,isnull(CMD.VPF,0),dbo.F_GET_AGE(Date_of_Birth,MONTH_ST_DATE,'N','N')
				 ,SG.Sal_Cal_Days,0,0,NULL,0,Isnull(sg.Arear_Day,0) 
				 ,SG.arear_day,VPF_PER, Nationality 
				 ,isnull(emp_auto_vpf,0) 
				FROM    T0200_MONTHLY_SALARY  SG  WITH (NOLOCK) INNER JOIN 
				(Select Emp_ID , m_ad_Percentage as PF_PER , (m_ad_Amount + Isnull(M_AREAR_AMOUNT,0) + Isnull(M_AREAR_AMOUNT_Cutoff,0)) as PF_Amount , m_ad_Calculated_Amount ,SAL_tRAN_ID from 
					T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = @PF_DEF_ID  And ad_not_effect_salary <> 1 and sal_type<>1
					and AD.CMP_ID = @CMP_ID ) MAD on SG.Emp_ID = MAD.Emp_ID  
					AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN
					T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID  inner join
					t0095_increment inc WITH (NOLOCK) on Sg.increment_id = inc.increment_id inner join
				#EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID
				left outer join
				(Select Emp_ID,(m_ad_Amount + isnull(M_AREAR_AMOUNT,0)+ Isnull(M_AREAR_AMOUNT_Cutoff,0)) as VPF,SAL_tRAN_ID,AD.M_AD_Percentage as VPF_PER  from 
					T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = 4  And ad_not_effect_salary <> 1 and sal_type<>1
					and AD.CMP_ID = @CMP_ID) CMD on SG.Emp_ID= CMD.Emp_ID AND SG.SAL_tRAN_ID = CMD.SAL_TRAN_ID				
				left outer join  
				(Select Emp_ID,(isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as Other_PF_Calculate ,SAL_tRAN_ID from 
					T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  
						where AD.ad_id = (SELECT top 1 EAM.AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER EAM WITH (NOLOCK)
												inner join T0050_AD_MASTER AM WITH (NOLOCK) on EAM.Effect_AD_ID = AM.AD_ID and EAM.CMP_ID = AM.CMP_ID
											WHERE AM.AD_DEF_ID  = @PF_DEF_ID AND Am.Cmp_ID  = @Cmp_ID )
							And ad_not_effect_salary <> 1 and sal_type<>1
					and AD.CMP_ID = @CMP_ID) CMD_new on SG.Emp_ID= CMD_new.Emp_ID AND SG.SAL_tRAN_ID = CMD_new.SAL_TRAN_ID					
		WHERE   e.CMP_ID = @CMP_ID 
 				and SG.Month_St_Date >=@From_Date  and SG.Month_End_Date <= @To_Date  

		
		
If Exists(Select S_Sal_Tran_Id From dbo.T0201_monthly_salary_sett WITH (NOLOCK) where S_Eff_Date Between @From_Date And @To_Date And Cmp_Id=@Cmp_Id)
	Begin 
				INSERT INTO #EMP_SALARY
				SELECT  SG.EMP_ID,MONTH(S_MONTH_ST_DATe),YEAR(S_MONTH_ST_DATE),SG.s_Salary_Amount,0,sg.S_Month_st_Date,SG.S_Month_End_date
					 ,MAD.PF_PER,MAD.PF_AMOUNT,m_ad_Calculated_Amount ,@PF_Limit,0,0,0,isnull(CMD.VPF,0),dbo.F_GET_AGE(Date_of_Birth,S_MONTH_ST_DATE,'N','N'),
					 SG.S_Sal_Cal_Days,0,1,SG.S_Eff_date,0,0,0,0,Nationality
					 ,isnull(emp_auto_vpf,0) 
					FROM t0201_monthly_salary_sett  SG  WITH (NOLOCK) INNER JOIN 
					( select Emp_ID , m_ad_Percentage as PF_PER , (m_ad_Amount + isnull(M_AREAR_AMOUNT,0)+ Isnull(M_AREAR_AMOUNT_Cutoff,0)) as PF_Amount , m_ad_Calculated_Amount ,SAL_tRAN_ID from 
						T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = @PF_DEF_ID And ad_not_effect_salary <> 1 And ad.sal_type=1
						and AD.CMP_ID = @CMP_ID) MAD on SG.Emp_ID = MAD.Emp_ID 
						AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN
						T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join
						t0095_increment inc WITH (NOLOCK) on Sg.increment_id = inc.increment_id inner join
					#EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID	
					left outer join
					(Select Emp_ID,(m_ad_Amount + isnull(M_AREAR_AMOUNT,0)+ Isnull(M_AREAR_AMOUNT_Cutoff,0)) as VPF,SAL_tRAN_ID  from 
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

		Declare @PF_Pension_Age as numeric(18,2)
		Declare @PF_Max_Limit_From_GS As Numeric(18,2)
		Declare @PF_NOT_FUll_AMT As Numeric(18,2)
		Declare @PF_541 As Numeric(18,2)
		
		Set @PF_Max_Limit_From_GS = 0
		Set @PF_541 = 0
		SET @PF_NOT_FUll_AMT = 0
		
			
		select Top 1	@PF_Pension_Age = isnull(PF_Pension_Age,0) , @PF_Max_Limit_From_GS = ISNULL(PF_LIMIT,0) from T0040_General_setting gs WITH (NOLOCK) inner join     
			T0050_General_Detail gd WITH (NOLOCK) on gs.gen_Id =gd.gen_ID     
			where gs.Cmp_Id=@cmp_Id 
					--and Branch_ID = isnull(@Branch_ID,Branch_ID)    
				and EXISTS (select Data from dbo.Split(@Branch_ID, '#') B Where cast(B.data as numeric)=Isnull(Branch_ID,0))   --Added By Jaina 5-11-2015
				and For_Date in (select max(For_Date) from T0040_General_setting  g WITH (NOLOCK) inner join     
				T0050_General_Detail d WITH (NOLOCK) on g.gen_Id =d.gen_ID       
			where g.Cmp_Id=@cmp_Id 
			--and Branch_ID = isnull(@Branch_ID,Branch_ID)    
			and EXISTS (select Data from dbo.Split(@Branch_ID, '#') B Where cast(B.data as numeric)=Isnull(Branch_ID,0))   --Added By Jaina 5-11-2015
		and For_Date <=@To_Date )  		
		
		
/* Commented by Falak on 18102011 due to error in calculation 
	UPDATE #EMP_SALARY SET PF_Limit = CASE
          WHEN PF_SALARY_AMOUNT >6500  THEN 6500
           WHEN PF_SALARY_AMOUNT < = 6500  THEN PF_SALARY_AMOUNT * 0.12         
           END
*/	
	Set @PF_541 = round(@PF_Max_Limit_From_GS * 0.0833,0)
	SET @PF_NOT_FUll_AMT = round(@PF_Limit * 12/100,0)
		                
	update #EMP_SALARY
	set	  PF_833 = round(PF_SALARY_AMOUNT * 0.0833,0)
		 ,PF_367 = PF_Amount - round(PF_SALARY_AMOUNT * 0.0833,0)
	where PF_SALARY_AMOUNT <= PF_Limit



	Update #EMP_SALARY
	set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit
		,PF_833 = round(PF_LIMIT * 0.0833,0) -- @PF_541 --541  --Commented by Hardik 19/05/2015 as PF Limit changed from Sept-2014
		,PF_367 = PF_Amount - round(PF_LIMIT * 0.0833,0) --@PF_541--541
	where PF_SALARY_AMOUNT > PF_Limit
	
	
	
	Update #EMP_SALARY    
		set PF_833 = 0    
			,PF_367 = PF_Amount  
			,PF_LIMIT =0   
		where Emp_Age >= @PF_PEnsion_Age and @PF_PEnsion_Age>0   
		

		
	Update #EMP_SALARY 
	  set PF_LIMIT = PF_SALARY_AMOUNT
	 where PF_SALARY_AMOUNT < @PF_Max_Limit_From_GS

	Update #EMP_SALARY    
		set PF_833 =   0    
		  ,PF_LIMIT =  0   
		where PF_833 = 0
				 
	 Update #EMP_SALARY 
		set EDLI_Wages = PF_SALARY_AMOUNT
	 
	 Update #EMP_SALARY 
		set EDLI_Wages = @PF_Max_Limit_From_GS
	 where PF_SALARY_AMOUNT > @PF_Max_Limit_From_GS 

-------------------------------Company Contribution in PF limit-----------------------------------------Hasmukh 06082013
	
	
	--Update #EMP_SALARY
	--set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit
	--	,PF_833 = @PF_541--541
	--	,PF_367 = round(PF_Limit * 12/100,0) - @PF_541--541
	--where PF_SALARY_AMOUNT > PF_Limit and cmp_full_pf = 0 and PF_Limit > 0	

	
	
	--Update #EMP_SALARY		-----Comment By Ankit 10082015
	--set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit
	--	,PF_833 = @PF_541--541
	--	,PF_367 = round(PF_Limit * 12/100,0) - @PF_541--541
	--where PF_SALARY_AMOUNT > PF_Limit and cmp_full_pf = 0 and PF_Limit > 0 and Is_Sett = 0

	Update #EMP_SALARY		--PF 8.33 and 3.67 Calculate On actual PF Amount deduct ----Condition Add By Ankit After discuss with Hardikbhai 10082015
	set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit
		,PF_833 = PF_Amount - round((PF_SALARY_AMOUNT * 3.67)/100 ,0) 
		,PF_367 = round((PF_SALARY_AMOUNT * 3.67)/100 ,0) 
	where PF_SALARY_AMOUNT > PF_Limit and cmp_full_pf = 0 and PF_Limit > 0	
	
	
	
	Update #EMP_SALARY    
	set PF_833 = 0    
		,PF_367 = PF_AMOUNT -- round(PF_LIMIT * 12/100,0) --@PF_NOT_FUll_AMT  ---Set Actual PF Amount (Employee arear case)--Ankit 10082015
		,PF_LIMIT =0   
	where Emp_Age >= @PF_PEnsion_Age and @PF_PEnsion_Age > 0 and PF_Amount >  round(PF_LIMIT * 12/100,0)-- @PF_NOT_FUll_AMT 
	and cmp_full_pf = 0 
-------------------------------Company Contribution in PF limit-----------------------------------------Hasmukh 06082013


  --Added by Hardik for Foreign Employee who pay full PF on 17/05/2012
  Update #EMP_SALARY    
  set   PF_833 = round(PF_SALARY_AMOUNT * 0.0833,0)    
    ,PF_367 = PF_Amount - round(PF_SALARY_AMOUNT * 0.0833,0)
    ,PF_DIFF_6500=0, PF_LIMIT = 0
  where  Nationality not like 'India%' and Nationality <> ''
  			
	 Update #EMP_SALARY 
		set PF_Amount = PF_Amount 
		
		-- Changed By Ali 23112013 EmpName_Alias
		--SELECT EPF.*--, (SALARY_AMOUNT + ISNULL(OTHER_PF_SALARY,0) ) as SALARY_AMOUNT
		--		,(PF_AMOUNT) PF_AMOUNT	,PF_PER,PF_Limit,EDLI_Wages , PF_SALARY_AMOUNT,PF_833,PF_367
		--		,PF_Diff_6500,EMP_SECOND_NAME,ES.VPF,E.Basic_Salary,E.Emp_code,
		--		ISNULL(EmpName_Alias_PF,Emp_Full_Name) as Emp_Full_Name,Grd_Name,Type_Name,dept_Name,Desig_Name,Cmp_Name,Cmp_Address,cm.PF_No as CPF_NO
		--		--,@From_Date P_From_Date ,@To_Date P_To_Date,Father_Name,Le.Left_Date,Le.Left_Reason,MS.Absent_Days,ES.Sal_Cal_Day
		--		,@From_Date P_From_Date ,@To_Date P_To_Date,Father_Name,Le.Left_Date,Le.Left_Reason,
		--	--	[dbo].[F_Get_NCP_Days] (@From_Date,@To_Date,(case when Sal_Cal_Day>0 then (Ms.Basic_Salary/Sal_cal_Day) else 0 end)/DATEDIFF(d,@From_Date,@To_Date) + 1,PF_SALARY_AMOUNT,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days ) as Absent_Days
		--		cast(Case When @IS_NCP_PRORATA = 1 Then CAST([dbo].[F_Get_NCP_Days] (@From_Date,@To_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days) As Varchar(2)) Else CAST(Cast(Ms.Absent_Days as Numeric(18,0)) As varchar(2)) End as numeric(18,0)) as Absent_Days,ES.Sal_Cal_Day
		--		,ES.arrear_days,ES.VPF_PER
		--		,BM.Branch_Name,date_of_join
		--		,date_of_birth,gender
		
		--select #EMP_PF_REPORT.CMP_ID from #EMP_PF_REPORT
		--select #EMP_PF_REPORT.EMP_CODE from #EMP_PF_REPORT
		----select #EMP_PF_REPORT.EMP_ID from #EMP_PF_REPORT
		----select #EMP_PF_REPORT.MONTH from #EMP_PF_REPORT
		----select #EMP_PF_REPORT.YEAR from #EMP_PF_REPORT
		
		/*
		Select Ms.Absent_Days,Cast(Ms.Absent_Days As INT) 
		FROM  #EMP_SALARY ES left outer join T0200_MONTHLY_SALARY MS on ES.EMP_ID=MS.Emp_ID and ES.MONTH=month(MS.Month_End_Date) and  
						ES.YEAR =year(MS.Month_End_Date) AND MS.Absent_Days % 1 > 0

		return;*/
		SELECT EPF.*
				,PF_AMOUNT	
				,PF_PER,PF_Limit,EDLI_Wages, PF_SALARY_AMOUNT,PF_833
				,PF_367 
				,PF_Diff_6500,EMP_SECOND_NAME,ES.VPF,E.Basic_Salary,E.Emp_code,
				ISNULL(EmpName_Alias_PF,Emp_Full_Name) as Emp_Full_Name,Grd_Name,Type_Name,dept_Name,Desig_Name,Cmp_Name,Cmp_Address,cm.PF_No as CPF_NO
				,@From_Date P_From_Date ,@To_Date P_To_Date,Father_Name,Le.Left_Date,Le.Left_Reason,
		
				CAST(
						(
							CASE WHEN (@IS_NCP_PRORATA = 1) Then 
								[dbo].[F_Get_NCP_Days] (@From_Date,@To_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days)
							Else 
								Ms.Absent_Days
							End
						) AS Numeric(18,2)) as Absent_Days,ES.Sal_Cal_Day 
		
				,ES.arrear_days,ES.VPF_PER
				,BM.Branch_Name,date_of_join
				,E.Alpha_Emp_Code,E.Emp_First_Name  
				,dgm.Desig_Dis_No  
				,E.PF_Trust_No                
				,vs.Vertical_Name,sv.SubVertical_Name   
				
				,Isnull(E.UAN_No,'')as UAN_No --added Jignesh 07-03-2020
				,'' as Format_Type --added Jignesh 07-03-2020
				,0 as Gross_Salary -- ES.Gross_Salary added Jignesh 07-03-2020
				
		  FROM #EMP_PF_REPORT EPF INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID left outer join
		  T0100_left_emp LE WITH (NOLOCK) on E.Emp_ID =Le.Emp_ID 
		  LEFT OUTER JOIN 	#EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID AND EPF.MONTH = ES.MONTH 
						AND EPF.YEAR = ES.YEAR 	left outer join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on ES.EMP_ID=MS.Emp_ID and ES.MONTH=month(MS.Month_End_Date) and  
						ES.YEAR =year(MS.Month_End_Date) INNER JOIN 
						( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,Type_ID,Wages_Type,I.Vertical_ID,I.SubVertical_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK)	
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
		E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
		T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Left outer join 
		T0040_Type_Master TM WITH (NOLOCK) on Q_I.Type_ID = Tm.Type_Id  Inner join 
		T0010_company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_Id LEFT OUTER join
		T0040_Vertical_Segment vs WITH (NOLOCK) On Q_i.Vertical_ID = vs.Vertical_ID Left Outer JOIN
		T0050_SubVertical sv WITH (NOLOCK) On Q_I.SubVertical_ID = sv.SubVertical_ID
		
		--Where ES.MONTH=MONTH(@To_Date) AND ES.YEAR=Year(@To_Date) --PF_Amount > 0
		order by RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)
	
		Drop Table #EMP_PF_REPORT
		Drop Table #EMP_SALARY

RETURN

