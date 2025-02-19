


---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Rpt_Salary_Settetment_GPF_CPS]
	 @Company_id	Numeric
	,@From_Date	Datetime
	,@To_Date Datetime
	,@Branch_ID	Numeric
	,@Grade_ID Numeric
	,@Type_ID Numeric
	,@Dept_ID Numeric
	,@Desig_ID Numeric
	,@Emp_ID Numeric
	,@Constraint	Varchar(max)
	,@Cat_ID Numeric = 0
	,@is_column	Numeric = 0
	,@CPS_Flag Numeric = 0
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Branch_ID = 0
		set @Branch_ID = null
	
	If @Grade_ID = 0
		set @Grade_ID = null
		
	If @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
		
	If @Dept_ID = 0
		set @Dept_ID = null
		
	If @Cat_ID = 0
		set @Cat_ID = null
		
	If @Type_id = 0
		set @Type_id = null
		
	if Object_ID('tempdb..#Emp_Cons') is not null
		drop table #Emp_Cons
		
	Create Table #Emp_Cons
	(
		Emp_ID Numeric
	)
		
	if @Constraint <> ''
	Begin
		Insert Into #Emp_Cons
		Select data From dbo.Split(@Constraint,'#')
	End
	
	if Object_ID('tempdb..#Dynamic_Allowance') is not null
		Begin
			drop table #Dynamic_Allowance
		End
	
	Create Table #Dynamic_Allowance
	(
		AD_ID Numeric(18,0),
		AD_SORT_NAME Varchar(100),
		AD_Flag Varchar(5),
		DEF_ID Numeric(4,0)
	)
	
	Insert into #Dynamic_Allowance
	Select 0,'Basic','I',0
	
	Insert into #Dynamic_Allowance
	Select DISTINCT MAD.AD_ID,AD_SORT_NAME,M_AD_Flag,Isnull(AD.AD_DEF_ID,0) As AD_DEF_ID From #Emp_Cons EC Inner join 
	T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) ON EC.Emp_ID = MS.Emp_ID
	Inner Join T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) On MAD.Sal_Tran_ID = MS.Sal_Tran_ID
	Inner Join T0050_AD_MASTER AD WITH (NOLOCK) ON AD.AD_ID = MAD.AD_ID
	Where S_Eff_Date Between @From_Date AND @To_Date
	and Isnull(MAD.S_Sal_Tran_ID,0) <> 0 and M_AD_Amount <> 0 and M_AD_Flag <> 'D'
	
	if Object_ID('tempdb..#Salary_Sett_Allowance') is not null
		Begin
			drop table #Salary_Sett_Allowance
		End
		
	Create Table #Salary_Sett_Allowance
	(
		Cmp_ID Numeric(18,0),
		Emp_ID Numeric(18,0),
		Label Varchar(200),
		AD_Amount Numeric(18,2),
		Increment_Period Varchar(50),
		Net_Amount Numeric(18,2),
		S_Eff_Date Datetime,
		Increment_ID Numeric(5,0),
		Sort_ID Numeric(5,0),
		AD_ID Numeric(5,0),
		Sal_Tran_ID Numeric(7,0),
		Sett_Month Numeric(5,0),
		Gross_Salary Numeric(18,2),
		Total_Gross_Amount Numeric(18,2),
		DEF_ID Numeric(4,0),
		Total_HMDA_CPS Numeric(18,2),
		Total_EPS Numeric(18,2),
		Total_CPS Numeric(18,2)
	)
	
	Declare @Cur_Emp_ID Numeric(18,0)
	Declare @Cur_Cmp_ID Numeric(18,0)
	Declare @Cur_Eff_Date Datetime
	Declare @Cur_Increment_ID Numeric(18,0)
	Declare @Sal_Tran_ID Numeric(7,0)
	Set @Sal_Tran_ID = 0
	
	
	Declare Cur_Emp Cursor For
	Select DISTINCT MS.Cmp_ID,EC.Emp_ID,MS.S_Eff_Date,MS.Increment_ID,MS.Sal_Tran_ID
	From #Emp_Cons EC Inner join T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) ON EC.Emp_ID = MS.Emp_ID
	Inner JOIN(
				Select MIN(Sal_Tran_ID) as Sal_Tran_ID,Emp_ID,S_Eff_Date,Increment_ID From T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) Where 
				S_Eff_Date Between @From_Date AND @To_Date
				Group By Emp_ID,S_Eff_Date,Increment_ID
			  ) as Qry
	ON Qry.Sal_Tran_ID = MS.Sal_Tran_ID and Qry.Emp_ID = MS.Emp_ID and Qry.S_Eff_Date = MS.S_Eff_Date and Qry.Increment_ID = MS.Increment_ID
	Where MS.S_Eff_Date Between @From_Date AND @To_Date
	Open Cur_Emp
		fetch next from Cur_Emp into @Cur_Cmp_ID,@Cur_Emp_ID,@Cur_Eff_Date,@Cur_Increment_ID,@Sal_Tran_ID
		while @@fetch_status = 0
			Begin
				Insert into #Salary_Sett_Allowance
				Select @Cur_Cmp_ID,@Cur_Emp_ID,AD_SORT_NAME,0,'',0,@Cur_Eff_Date,@Cur_Increment_ID,1,AD_ID,@Sal_Tran_ID,0,0,0,DEF_ID,0,0,0 from #Dynamic_Allowance where AD_Flag = 'I'
				
				Insert into #Salary_Sett_Allowance
				Select @Cur_Cmp_ID,@Cur_Emp_ID,AD_SORT_NAME,0,'',0,@Cur_Eff_Date,@Cur_Increment_ID,2,AD_ID,@Sal_Tran_ID,0,0,0,DEF_ID,0,0,0 from #Dynamic_Allowance where AD_Flag = 'I'
				
				Insert into #Salary_Sett_Allowance
				Select @Cur_Cmp_ID,@Cur_Emp_ID,AD_SORT_NAME,0,'',0,@Cur_Eff_Date,@Cur_Increment_ID,3,AD_ID,@Sal_Tran_ID,0,0,0,DEF_ID,0,0,0 from #Dynamic_Allowance where AD_Flag = 'I'
				
				fetch next from Cur_Emp into @Cur_Cmp_ID,@Cur_Emp_ID,@Cur_Eff_Date,@Cur_Increment_ID,@Sal_Tran_ID
			End
	Close Cur_Emp
	deallocate Cur_Emp
	
	Update TS1 Set Increment_Period = Qry.Month_Period,
	Sett_Month = Qry.Period
	From #Salary_Sett_Allowance TS1
		Inner Join
		(
			Select Cast(datename(month, Min(S_Month_End_Date)) as varchar(3)) + ' ' + cast(year(Min(S_Month_End_Date)) as varchar(4)) + ' - ' + Cast(datename(month, max(S_Month_End_Date)) as varchar(3)) + ' ' + cast(year(max(S_Month_End_Date)) as varchar(4)) as Month_Period,
			MSS.Emp_ID,MSS.Increment_ID,Count(1) as Period
			From T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
			Inner Join #Salary_Sett_Allowance TS
			ON TS.Emp_ID = MSS.Emp_ID and TS.S_Eff_Date = Mss.S_Eff_Date and TS.Sort_ID = 1 and ts.ad_id=0 and MSS.Increment_ID = TS.Increment_ID
			Group by MSS.Emp_ID,MSS.Increment_ID
		)as Qry
	ON Qry.Emp_ID = Ts1.Emp_ID And Qry.Increment_ID = TS1.Increment_ID
	
	
	
	Update TS1 Set AD_Amount = Qry.basic
	From #Salary_Sett_Allowance TS1
	Inner Join
		(	
			Select Isnull(MS.Basic_Salary,0) + Isnull(S_Basic_Salary,0) As basic,MS.Emp_ID,TS.Increment_ID
			From T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
			Inner Join T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MSS.Sal_Tran_ID = MS.Sal_Tran_ID and MSS.Emp_ID = MS.Emp_ID
			Inner Join #Salary_Sett_Allowance TS
			ON TS.Emp_ID = MSS.Emp_ID and TS.S_Eff_Date = Mss.S_Eff_Date And TS.Sal_Tran_ID = MSS.Sal_Tran_ID and TS.Increment_ID = MSS.Increment_ID
			Where  TS.Sort_ID = 1 and ts.ad_id=0
		)as Qry
	ON TS1.Emp_ID = Qry.Emp_ID and TS1.Increment_ID = Qry.Increment_ID 
	Where  TS1.AD_ID = 0 and TS1.Sort_ID = 1
	
	
	Update TS1 Set AD_Amount = Qry.basic
	From #Salary_Sett_Allowance TS1
		Inner Join
		(	
			Select Isnull(MS.Basic_Salary,0) As basic,MS.Emp_ID,TS.Increment_ID
			From T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
			Inner Join T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MSS.Sal_Tran_ID = MS.Sal_Tran_ID and MSS.Emp_ID = MS.Emp_ID
			Inner Join #Salary_Sett_Allowance TS
			ON TS.Emp_ID = MSS.Emp_ID and TS.S_Eff_Date = Mss.S_Eff_Date And TS.Sal_Tran_ID = MSS.Sal_Tran_ID and TS.Increment_ID = MSS.Increment_ID
			Where  TS.Sort_ID = 2 and ts.ad_id=0
		)as Qry
	ON TS1.Emp_ID = Qry.Emp_ID and TS1.Increment_ID = Qry.Increment_ID 
	Where TS1.AD_ID = 0 and TS1.Sort_ID = 2
	

	
	Update TS1 Set AD_Amount = Qry.M_AD_Amount
	From #Salary_Sett_Allowance TS1
		Inner Join
		(	
			Select SUM(M_AD_Amount) as M_AD_Amount,TS.AD_ID,TS.Emp_ID,TS.Increment_ID
			From T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) Inner Join T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
			On MS.Sal_Tran_ID = MAD.Sal_Tran_ID
			Inner Join #Salary_Sett_Allowance TS 
			On TS.Emp_ID = MS.Emp_ID and TS.AD_ID = MAD.AD_ID And TS.Sal_Tran_ID = MAD.Sal_Tran_ID
			Where TS.Sort_ID = 1
			GROUP By TS.AD_ID,TS.Emp_ID,TS.Increment_ID
		) as Qry
	ON TS1.AD_ID = Qry.AD_ID and TS1.Emp_ID = Qry.Emp_ID and TS1.Increment_ID = Qry.Increment_ID
	Where TS1.Sort_ID = 1
	
	
	Update TS1 Set AD_Amount = Qry.M_AD_Amount
	From #Salary_Sett_Allowance TS1
		Inner Join
		(	
			Select SUM(M_AD_Amount) as M_AD_Amount,TS.AD_ID,TS.Emp_ID,TS.Increment_ID
			From T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) Inner Join T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
			On MS.Sal_Tran_ID = MAD.Sal_Tran_ID
			Inner Join #Salary_Sett_Allowance TS 
			On TS.Emp_ID = MS.Emp_ID and TS.AD_ID = MAD.AD_ID And TS.Sal_Tran_ID = MAD.Sal_Tran_ID
			Where TS.Sort_ID = 2 AND MAD.S_Sal_Tran_ID is null
			GROUP By TS.AD_ID,TS.Emp_ID,TS.Increment_ID
		) as Qry
	ON TS1.AD_ID = Qry.AD_ID and TS1.Emp_ID = Qry.Emp_ID and TS1.Increment_ID = Qry.Increment_ID
	Where TS1.Sort_ID = 2
	
	--Update ts Set AD_Amount = (qry.AD_Amount - qry_1.AD_Amount)
	--From #Salary_Sett_Allowance ts
	--Inner Join(Select AD_Amount,Emp_ID,Label,Sort_ID,Increment_ID From #Salary_Sett_Allowance Where Sort_ID = 1) as qry ON ts.Emp_ID = qry.Emp_ID and ts.Label = qry.Label and qry.Increment_ID = ts.Increment_ID --and ts.Sort_ID = qry.Sort_ID
	--Inner Join(Select AD_Amount,Emp_ID,Label,Sort_ID,Increment_ID From #Salary_Sett_Allowance Where Sort_ID = 2) as qry_1 ON ts.Emp_ID = qry_1.Emp_ID and ts.Label = qry_1.Label and qry.Increment_ID = ts.Increment_ID --and ts.Sort_ID = qry_1.Sort_ID
	--Where ts.Sort_ID = 3 and ts.Increment_ID = qry.Increment_ID
	
	Update ts Set AD_Amount = (qry.AD_Amount - qry_1.AD_Amount)
	From #Salary_Sett_Allowance ts
	Inner Join(Select SUM(AD_Amount) as AD_Amount,Emp_ID,Label,Sort_ID,Increment_ID,AD_ID From #Salary_Sett_Allowance Where Sort_ID = 1 GROUP BY Emp_ID,Label,Sort_ID,Increment_ID,AD_ID ) as qry ON ts.Emp_ID = qry.Emp_ID and ts.Label = qry.Label and qry.Increment_ID = ts.Increment_ID --and ts.Sort_ID = qry.Sort_ID
	Inner Join(Select SUM(AD_Amount) as AD_Amount,Emp_ID,Label,Sort_ID,Increment_ID,AD_ID From #Salary_Sett_Allowance Where Sort_ID = 2 GROUP BY Emp_ID,Label,Sort_ID,Increment_ID,AD_ID ) as qry_1 ON ts.Emp_ID = qry_1.Emp_ID and ts.Label = qry_1.Label and qry_1.Increment_ID = ts.Increment_ID --and ts.Sort_ID = qry_1.Sort_ID
	Where ts.Sort_ID = 3 and ts.Increment_ID = qry.Increment_ID  
	
	
	--Update ts Set Net_Amount = Qry.Amount
	--From #Salary_Sett_Allowance ts
	--Inner JOIN(
	--			Select SUM(t.AD_Amount) as Amount,t.Emp_ID From #Salary_Sett_Allowance t 
	--			WHERE t.Sort_ID = 3 GROUP By t.Emp_ID
	--		   ) as Qry
	--ON Qry.Emp_ID = ts.Emp_ID
	--Where ts.Sort_ID = 1
	
	
	
	Update ts Set Gross_Salary = (Case When ts.Sort_ID = 1 Then Qry.Amount when ts.Sort_ID = 2 THEN (Qry.Amount - Qry_1.Amount) ELSE Qry_1.Amount END),
				  Total_Gross_Amount = (Case When ts.Sort_ID = 1 then (Qry_1.Amount * ts.Sett_Month) Else NULL END),
				  Net_Amount = (Case When ts.Sort_ID = 1 then (Qry_1.Amount * ts.Sett_Month) Else NULL END)
	From #Salary_Sett_Allowance ts
	Inner JOIN(
				Select SUM(t.AD_Amount) as Amount,t.Emp_ID,t.Increment_ID From #Salary_Sett_Allowance t 
				WHERE t.Sort_ID = 1 GROUP By t.Emp_ID,t.Increment_ID
			   ) as Qry ON Qry.Emp_ID = ts.Emp_ID and Qry.Increment_ID = ts.Increment_ID
	Inner JOIN(
				Select SUM(t.AD_Amount) as Amount,t.Emp_ID,t.Increment_ID From #Salary_Sett_Allowance t 
				WHERE t.Sort_ID = 3 GROUP By t.Emp_ID,t.Increment_ID
			   ) as Qry_1 ON Qry_1.Emp_ID = ts.Emp_ID and Qry_1.Increment_ID = ts.Increment_ID
			   
	   
	if @CPS_Flag = 1	
		Begin
			Update ts Set Total_HMDA_CPS = (Case When ts.Sort_ID = 1 then (Qry.Amount * ts.Sett_Month) Else NULL END),
				  Total_EPS = (Case When ts.Sort_ID = 1 then (Qry.Amount * ts.Sett_Month) Else NULL END),
	              Total_CPS = (Case When ts.Sort_ID = 1 then (Qry.Amount * ts.Sett_Month) * 2 Else NULL END)
			From #Salary_Sett_Allowance ts
			Inner JOIN(
						Select SUM(t.AD_Amount) as Amount,t.Emp_ID,t.Increment_ID From #Salary_Sett_Allowance t 
						WHERE t.Sort_ID = 3 AND t.DEF_ID = 15 
						GROUP By t.Emp_ID,t.Increment_ID
					   ) as Qry ON Qry.Emp_ID = ts.Emp_ID and Qry.Increment_ID = ts.Increment_ID
		End
		   
	
	Declare @colsPivot_Add varchar(max)
	Set @colsPivot_Add = ''
	
	select @colsPivot_Add = coalesce(@colsPivot_Add+' ',' ') + Label + ','
	from (select Distinct t.Label, ISNULL(ad.AD_LEVEL, T.AD_ID) AS AD_LEVEL, T.AD_ID
		from #Salary_Sett_Allowance t LEFT OUTER JOIN T0050_AD_MASTER ad WITH (NOLOCK) on t.AD_ID=ad.AD_ID
	) T
	ORDER BY T.AD_LEVEL
	
	Set @colsPivot_Add = LEFT(@colsPivot_Add, LEN(@colsPivot_Add) - 1)
	
	Declare @colsPivot_Sum varchar(max)
	Set @colsPivot_Sum = ''
	
	select @colsPivot_Sum = coalesce(@colsPivot_Sum +' ',' ') + ( 'NULL' + ' AS ' + Label) + ','
	from (select Distinct t.Label, ISNULL(ad.AD_LEVEL, T.AD_ID) AS AD_LEVEL, T.AD_ID
		from #Salary_Sett_Allowance t LEFT OUTER JOIN T0050_AD_MASTER ad WITH (NOLOCK) on t.AD_ID=ad.AD_ID
	) T
	ORDER BY T.AD_LEVEL

	Declare @Months varchar(10)
	Set @Months = 'Months';
	Declare @query varchar(max)
	set @query = ''
	
	if @CPS_Flag <> 1
		Begin
			if @is_column = 1
				BEGIN
					set @query = 'select 0 as flag, Alpha_Emp_Code,Emp_Full_Name,Increment_Period as Period,'+ @colsPivot_Add +',Gross_Salary as Gross, Sett_Month as Increment_Months ,Total_Gross_Amount,Net_Amount
						from (select EM.Alpha_Emp_Code,EM.Emp_Full_Name,Label, AD_Amount,Gross_Salary,Sett_Month,Total_Gross_Amount,Net_Amount,Sort_ID,Increment_Period from #Salary_Sett_Allowance TS inner join T0080_Emp_Master EM WITH (NOLOCK) ON TS.EMP_ID = EM.Emp_ID)
						as data pivot
						( sum(AD_Amount)
						for Label in ('+ @colsPivot_Add +') ) p
						order by Gross_Salary DESC'
					exec (@query)
				End
			Else
				Begin
					set @query = 'select 0 as flag,Emp_ID, Alpha_Emp_Code,Emp_Full_Name,Increment_Period as Period,'+ @colsPivot_Add +',Gross_Salary as Gross,Sett_Month as Increment_Months,Total_Gross_Amount,Net_Amount,Sort_ID,Increment_ID
						from (select EM.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,Label, AD_Amount,Gross_Salary,Sett_Month,Total_Gross_Amount,Net_Amount,Sort_ID,Increment_Period,TS.Increment_ID from #Salary_Sett_Allowance TS inner join T0080_Emp_Master EM WITH (NOLOCK) ON TS.EMP_ID = EM.Emp_ID)
						as data pivot
						( sum(AD_Amount)
						for Label in ('+ @colsPivot_Add +') ) p
						union
						select 1 as flag,Emp_ID, ''Total'' as Alpha_Emp_Code,'''' as Emp_Full_Name,''''as Period,'+ @colsPivot_Sum +' NULL AS Gross,NULL AS Increment_Months,NULL AS Total_Gross_Amount,Net_Amount,4 as Sort_ID,Increment_ID
						from (select EM.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,Label, AD_Amount,Gross_Salary,Sett_Month,Total_Gross_Amount,Net_Amount,Sort_ID,Increment_Period,TS.Increment_ID from #Salary_Sett_Allowance TS inner join T0080_Emp_Master EM WITH (NOLOCK) ON TS.EMP_ID = EM.Emp_ID where TS.Sort_id = 1)
						as data pivot
						( sum(AD_Amount)
						for Label in ('+ @colsPivot_Add +') ) p
						order by Emp_ID,Increment_ID,Sort_ID'
					exec (@query)
				End
		End
	Else
		Begin
			if @is_column = 1
				BEGIN
					set @query = 'select 0 as flag, Alpha_Emp_Code,Emp_Full_Name,Increment_Period as Period,'+ @colsPivot_Add +',Gross_Salary as Gross, Sett_Month as Increment_Months ,Total_Gross_Amount,0 As Total_HMDA_CPS, 0 As Total_EPS,0 As Total_CPS,0 as Net_Amount
						from (select EM.Alpha_Emp_Code,EM.Emp_Full_Name,Label, AD_Amount,Gross_Salary,Sett_Month,Total_Gross_Amount,Net_Amount,Sort_ID,Increment_Period from #Salary_Sett_Allowance TS inner join T0080_Emp_Master EM WITH (NOLOCK) ON TS.EMP_ID = EM.Emp_ID)
						as data pivot
						( sum(AD_Amount)
						for Label in ('+ @colsPivot_Add +') ) p
						order by Gross_Salary DESC'
					exec (@query)
				End
			Else
				Begin
					set @query = 'select 0 as flag,Emp_ID, Alpha_Emp_Code,Emp_Full_Name,Increment_Period as Period,'+ @colsPivot_Add +',Gross_Salary as Gross,Sett_Month as Increment_Months,Total_Gross_Amount,Total_HMDA_CPS,Total_EPS,Total_CPS,(Net_Amount - Total_CPS) as Net_Amount,Sort_ID,Increment_ID
						from (select EM.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,Label, AD_Amount,Gross_Salary,Sett_Month,Total_Gross_Amount,Net_Amount,Sort_ID,Increment_Period,Total_HMDA_CPS,Total_EPS,Total_CPS,TS.Increment_ID from #Salary_Sett_Allowance TS inner join T0080_Emp_Master EM WITH (NOLOCK) ON TS.EMP_ID = EM.Emp_ID)
						as data pivot
						( sum(AD_Amount)
						for Label in ('+ @colsPivot_Add +') ) p
						union
						select 1 as flag,Emp_ID, ''Total'' as Alpha_Emp_Code,'''' as Emp_Full_Name,''''as Period,'+ @colsPivot_Sum +' NULL AS Gross,NULL AS Increment_Months,Total_Gross_Amount,NULL AS Total_HMDA_CPS,NULL AS Total_EPS,Total_CPS,(Net_Amount - Total_CPS) as Net_Amount,4 as Sort_ID,Increment_ID
						from (select EM.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,Label, AD_Amount,Gross_Salary,Sett_Month,Total_Gross_Amount,Net_Amount,Sort_ID,Increment_Period,Total_HMDA_CPS,Total_EPS,Total_CPS,TS.Increment_ID from #Salary_Sett_Allowance TS inner join T0080_Emp_Master EM WITH (NOLOCK) ON TS.EMP_ID = EM.Emp_ID where TS.Sort_id = 1)
						as data pivot
						( sum(AD_Amount)
						for Label in ('+ @colsPivot_Add +') ) p
						order by Emp_ID,Increment_ID,Sort_ID'
					exec (@query)
				End
		End
END
