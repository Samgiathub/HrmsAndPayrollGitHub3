
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0220_GET_TDS_CHALLAN]
@cmp_id numeric(18,0),
@Month  numeric(18,0),
@Year numeric(18,0),
--@Branch numeric(18,0)=0  --Mukti 30112015
@Branch_Id varchar(max)='',  --Added by Jaina 15-02-2019
@Grade_Id varchar(max) = '',  --Added by Jaina 15-02-2019
@Cat_Id varchar(max) = '',  --Added by Jaina 15-02-2019
@Challan_Status varchar(50) = 'All'
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @Branch_Id = '' or @Branch_Id = '0'
	set @Branch_Id=null
IF @Grade_Id = '' OR @Grade_Id = '0'
	set @Grade_Id = NULL
if @Cat_Id = ''  or @Cat_Id = '0'
	set @Cat_Id = NULL
	

	
	--Added by Jaina 15-02-2019
	Declare @From_Date datetime
	Declare @To_Date datetime
	
	
	set @From_Date = dbo.GET_MONTH_ST_DATE(@Month,@Year)
	set @To_Date = dbo.GET_MONTH_END_DATE(@Month,@Year)
	
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	) 
	EXEC dbo.SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grade_Id,'','','',0,'',0,0,0,'','','',0,0,0,'0',0,0    
	
	Declare @IT_AD_Id numeric
	Declare @Ed_cess_per_amount numeric(18,2)
	Declare @IT_AD_Id_Extra numeric
	
	--set @Ed_cess_per_amount = 3
	
	--Added by Hardik 06/07/2018 for Enlume	
	Declare @Fin_St_Date datetime
	Declare @Fin_End_Date datetime
	Declare @Financial_Year varchar(20)
	select  @Fin_St_Date = dbo.GET_YEAR_START_DATE(@Year,@Month,0)
	select  @Fin_End_Date = dbo.GET_YEAR_END_DATE(@Year,@Month,0)
	SET @Financial_Year = Cast(Year(@Fin_St_Date) As varchar(4)) + '-' + Cast(Year(@Fin_End_Date) As varchar(4))
	SELECT @Ed_cess_per_amount = Isnull(Field_Value,4) from T0100_IT_FORM_DESIGN WITH (NOLOCK) where Cmp_ID=@cmp_id and Financial_Year = @Financial_Year And Default_Def_Id = 104 -- For ED Cess Percentage

	
	select @IT_AD_Id = AD_ID from T0050_AD_MASTER WITH (NOLOCK) where CMP_ID = @cmp_id and AD_DEF_ID = 1
	select @IT_AD_Id_Extra = AD_ID from T0050_AD_MASTER WITH (NOLOCK) where CMP_ID = @cmp_id and AD_DEF_ID = 13
	
	CREATE TABLE #Emp_TDS_Challan 
		( 
			Emp_ID					numeric,
			cmp_id				numeric,
			Emp_Code				varchar(50),
			Emp_Name				Varchar(100),
			month					numeric,
			year					numeric,						
			Tax						Numeric(18,2),			
			Ed_Cess					Numeric(18,2),
			Total					Numeric(18,2),			
			Total_Tax_Amount		Numeric(18,2),			
			Total_ED_Cess_Amount	Numeric(18,2),
			Final_Total_Tax			Numeric(18,2),
			Branch_Id				numeric(18,0),  --Added by Jaina 08-02-2019 Start
			Branch_Name				varchar(500),
			Dept_Id					numeric(18,0),
			Dept_Name				varchar(500),
			Desig_Id				numeric(18,0),
			Desig_Name				varchar(500),    --Added by Jaina 08-02-2019 End
			Tax_Paid				numeric(18,2),
			Additional_Amount		numeric(18,2)
		)
		
		CREATE TABLE #Emp_TDS 
		( 
			Emp_ID					numeric,
			cmp_id				numeric,
			Emp_Code				varchar(50),
			Emp_Name				Varchar(100),
			_month					numeric,
			_year					numeric,						
			Amount						Numeric(18,2)
		
		)
		
		
		declare @st_date datetime
		select @st_date = Month_St_Date from T0200_MONTHLY_SALARY WITH (NOLOCK) where MONTH(Month_End_Date) = @Month and YEAR(Month_End_Date) = @Year and Cmp_ID = @cmp_id

-- Commented and Added by rohit on 22072015 for Show extra TDS in Challen.

		--Insert into @Emp_TDS_Challan 
		
		--Select MAD.Emp_id, MAD.cmp_id, E.Alpha_Emp_Code, E.Emp_Full_Name, Month(to_date), Year(to_date), 
		--		Round(isnull(M_AD_AMOUNT - (M_AD_AMOUNT * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0) Tax_Amount, 
		--		Round(isnull((M_AD_AMOUNT * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0) Ed_Cess, M_AD_AMOUNT, 
		--			(Select Sum(Round(isnull(M_AD_AMOUNT - (M_AD_AMOUNT * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount) ,0),0)) From T0210_MONTHLY_AD_DETAIL
		--			Where cmp_id = @cmp_id and month(to_date) = @Month and year(to_date) = @Year and Ad_id = @IT_AD_Id),
		--			(Select Sum(Round(isnull((M_AD_AMOUNT * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0)) From T0210_MONTHLY_AD_DETAIL
		--			Where cmp_id = @cmp_id and month(to_date) = @Month and year(to_date) = @Year and Ad_id = @IT_AD_Id),
		--			(Select Sum(Round(isnull(M_AD_AMOUNT,0),0)) From T0210_MONTHLY_AD_DETAIL
		--			Where cmp_id = @cmp_id and month(to_date) = @Month and year(to_date) = @Year and Ad_id = @IT_AD_Id)
		--From T0210_MONTHLY_AD_DETAIL MAD inner join T0080_EMP_MASTER E on MAD.Emp_Id = E.Emp_id		
		--Where MAD.cmp_id = @cmp_id and month(to_date) = @Month and year(to_date) = @Year and mad.AD_ID = @IT_AD_Id
		--and mad.M_AD_Amount > 0
		--Order by MAD.Emp_id
		
		Insert into #Emp_TDS
		select emp_id,Cmp_ID,Alpha_Emp_Code,Emp_Full_Name,_Month,_Year,round(sum(isnull(total,0)),0) from 
		(
		Select MAD.Emp_id, MAD.cmp_id, E.Alpha_Emp_Code, E.Emp_Full_Name, Month(to_date) as _Month, Year(to_date) as _Year, 
				 M_AD_AMOUNT as total
		From T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) inner join T0080_EMP_MASTER E WITH (NOLOCK) on MAD.Emp_Id = E.Emp_id	
		 INNER JOIN #EMP_CONS EC ON EC.EMP_ID = E.EMP_ID	--Added by Jaina 15-02-2019
		Where MAD.cmp_id = @cmp_id and month(to_date) = @Month and year(to_date) = @Year and mad.AD_ID = @IT_AD_Id
		and mad.M_AD_Amount > 0
		
		union all
		
		Select MAD.Emp_id, MAD.cmp_id, E.Alpha_Emp_Code, E.Emp_Full_Name, Month(to_date) as _Month, Year(to_date) _Year, 
				M_AD_AMOUNT as total 
		From T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) inner join T0080_EMP_MASTER E WITH (NOLOCK) on MAD.Emp_Id = E.Emp_id	
		 INNER JOIN #EMP_CONS EC ON EC.EMP_ID = E.EMP_ID	--Added by Jaina 15-02-2019
		Where MAD.cmp_id = @cmp_id and month(to_date) = @Month and year(to_date) = @Year and mad.AD_ID = @IT_AD_Id_Extra
		and mad.M_AD_Amount > 0
				
		union all
		
		Select MAD.Emp_id, MAD.cmp_id, E.Alpha_Emp_Code, E.Emp_Full_Name, Month(For_Date) as _Month, Year(For_Date) as _Year, 
				sum(TDS) as total
		From T0210_ESIC_On_Not_Effect_on_Salary MAD WITH (NOLOCK) inner join T0080_EMP_MASTER E WITH (NOLOCK) on MAD.Emp_Id = E.Emp_id		
			 INNER JOIN #EMP_CONS EC ON EC.EMP_ID = E.EMP_ID  --Added by Jaina 15-02-2019
		Where MAD.cmp_id = @cmp_id and month(For_Date) = @Month and year(For_Date) = @Year 
		and mad.TDS > 0 group by MAD.Emp_id, MAD.cmp_id, E.Alpha_Emp_Code, E.Emp_Full_Name, Month(For_Date), Year(For_Date)
		) TDS group by emp_id,Cmp_ID,Alpha_Emp_Code,Emp_Full_Name,_Month,_Year
		order by emp_id
		
		if @Challan_Status = 'Submitted' 
		BEGIN
			Insert into #Emp_TDS_Challan 
			Select MAD.Emp_id, MAD.cmp_id, E.Alpha_Emp_Code, E.Emp_Full_Name, _month, _year, 
				CASE WHEN isnull(TD.TDS_Amount,0) = 0 THEN
						 --CONVERT(varchar,CAST(Round(isnull(Amount - (Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0) AS money),1)
						 Round(isnull(Amount - (Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0) 
					 ELSE CONVERT(varchar,0) END as Tax_Amount, 
				--CONVERT(varchar,CAST(Round(isnull((Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0) as money),1) Ed_Cess, 
				CASE WHEN ISNULL(TD.TDS_Amount,0) = 0 THEN 
					Round(isnull((Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0) 
				else 0 END AS Ed_Cess,
					
				CASE WHEN ISNULL(TD.TDS_Amount,0) = 0 THEN 
						  --CONVERT(varchar,CAST(Amount as money),1)
						  Amount
					 Else CONVERT(varchar,0) END as Amount, 
					(Select Sum(Round(isnull(Amount - (Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount) ,0),0)) From #Emp_TDS
					Where cmp_id = @cmp_id and _month = @Month and _year= @Year ),
					(Select Sum(Round(isnull((Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0)) From #Emp_TDS
					Where cmp_id = @cmp_id and _month = @Month and _year= @Year ),
					(Select Sum(Round(isnull(Amount,0),0)) From #Emp_TDS
					Where cmp_id = @cmp_id and _month = @Month and _year = @Year ),
					I.Branch_ID,B.Branch_Name,I.Dept_ID,D.Dept_Name,I.Desig_Id,Ds.Desig_Name  --Added by Jaina 08-02-2019
					,isnull(TD.TDS_Amount,0)+ isnull(TD.Additional_Amount,0) as Tax_Paid, 0 as Additional_Amount
			From #Emp_TDS MAD 
			inner join T0080_EMP_MASTER E WITH (NOLOCK) on MAD.Emp_Id = E.Emp_id	
			 INNER JOIN #EMP_CONS EC ON EC.EMP_ID = E.EMP_ID	
			--Added By Mukti(start)30112015
			inner join T0095_Increment I WITH (NOLOCK) on I.Emp_id=MAD.Emp_Id
			and I.Increment_Id=(SELECT MAX(Increment_Id) AS Increment_Id   
									FROM T0095_Increment WITH (NOLOCK)
									WHERE  Cmp_ID = @Cmp_ID and emp_id=MAD.Emp_Id GROUP BY emp_ID)  
			--Added By Mukti(end)30112015
			 --Added by Jaina 08-02-2019 Start
			left JOIN T0030_BRANCH_MASTER B WITH (NOLOCK) ON B.Branch_ID = I.Branch_ID
			left JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON D.Dept_Id = I.Dept_ID
			left JOIN T0040_DESIGNATION_MASTER Ds WITH (NOLOCK) ON Ds.Desig_ID = I.Desig_Id
			--Added by Jaina 08-02-2019 End
			 inner JOIN 			 
			 --(	SELECT TC.TDS_Amount,TC.Additional_Amount,EM.Emp_ID 
				--FROM T0220_TDS_CHALLAN T INNER JOIN
				--T0230_TDS_CHALLAN_DETAIL TC on T.Challan_Id = TC.Challan_Id INNER JOIN
				--#Emp_Cons EM on EM.Emp_ID = TC.Emp_ID
				--WHERE T.Month = @Month and T.Year = @Year
				(SELECT sum(isnull(TC.TDS_Amount,0)) as TDS_Amount ,
				   sum(isnull(TC.Additional_Amount,0)) as Additional_Amount,EM.Emp_ID 
				FROM T0220_TDS_CHALLAN T WITH (NOLOCK) INNER JOIN
					T0230_TDS_CHALLAN_DETAIL TC WITH (NOLOCK) on T.Challan_Id = TC.Challan_Id INNER JOIN
					#Emp_Cons EM on EM.Emp_ID = TC.Emp_ID			
				WHERE T.Month = @Month and T.Year = @Year
				group BY EM.Emp_ID
			 )As TD ON TD.Emp_ID = EC.Emp_ID
			Where MAD.cmp_id = @cmp_id and _month = @Month and _year = @Year 
			and mad.Amount > 0 
			
			--and I.Branch_id=isnull(@Branch,I.Branch_id) --Branch_Id condition added By Mukti 30112015  --Comment by Jaina 15-02-2019
			Order by MAD.Emp_id
		
			-- Ended by rohit on 22072015	
		END
		else if @Challan_Status = 'Pending' 
		BEGIN
			Insert into #Emp_TDS_Challan 
			Select MAD.Emp_id, MAD.cmp_id, E.Alpha_Emp_Code, E.Emp_Full_Name, _month, _year, 
				  --CONVERT(varchar,CAST(Round(isnull(Amount - (Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0) AS money),1)as Tax_Amount, 					
				  Round(isnull(Amount - (Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0) Tax_Amount, 
				  --CONVERT(varchar,CAST(Round(isnull((Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0) as money),1) Ed_Cess, 
				  Round(isnull((Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0) Ed_Cess,
				  --CONVERT(varchar,CAST(Amount as money),1)as Amount, 					  
				  Amount,
					(Select Sum(Round(isnull(Amount - (Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount) ,0),0)) From #Emp_TDS
					Where cmp_id = @cmp_id and _month = @Month and _year= @Year ),
					(Select Sum(Round(isnull((Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0)) From #Emp_TDS
					Where cmp_id = @cmp_id and _month = @Month and _year= @Year ),
					(Select Sum(Round(isnull(Amount,0),0)) From #Emp_TDS
					Where cmp_id = @cmp_id and _month = @Month and _year = @Year ),
					I.Branch_ID,B.Branch_Name,I.Dept_ID,D.Dept_Name,I.Desig_Id,Ds.Desig_Name  --Added by Jaina 08-02-2019
					,0 as Tax_Paid,0 as Additional_Amount
			From #Emp_TDS MAD 
			inner join T0080_EMP_MASTER E WITH (NOLOCK) on MAD.Emp_Id = E.Emp_id	
			 INNER JOIN #EMP_CONS EC ON EC.EMP_ID = E.EMP_ID	
			--Added By Mukti(start)30112015
			inner join T0095_Increment I WITH (NOLOCK) on I.Emp_id=MAD.Emp_Id
			and I.Increment_Id=(SELECT MAX(Increment_Id) AS Increment_Id   
									FROM T0095_Increment WITH (NOLOCK)
									WHERE  Cmp_ID = @Cmp_ID and emp_id=MAD.Emp_Id GROUP BY emp_ID)  
			--Added By Mukti(end)30112015
			 --Added by Jaina 08-02-2019 Start
			left JOIN T0030_BRANCH_MASTER B WITH (NOLOCK) ON B.Branch_ID = I.Branch_ID
			left JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON D.Dept_Id = I.Dept_ID
			left JOIN T0040_DESIGNATION_MASTER Ds WITH (NOLOCK) ON Ds.Desig_ID = I.Desig_Id
			--Added by Jaina 08-02-2019 End
			 left JOIN 
			 (	
				SELECT sum(isnull(TC.TDS_Amount,0)) as TDS_Amount ,
					   sum(isnull(TC.Additional_Amount,0)) as Additional_Amount,EM.Emp_ID 
				FROM T0220_TDS_CHALLAN T WITH (NOLOCK) INNER JOIN
					T0230_TDS_CHALLAN_DETAIL TC WITH (NOLOCK) on T.Challan_Id = TC.Challan_Id INNER JOIN
					#Emp_Cons EM on EM.Emp_ID = TC.Emp_ID			
				WHERE T.Month = @Month and T.Year = @Year
				group BY EM.Emp_ID
			 )As TD ON TD.Emp_ID = EC.Emp_ID
			Where MAD.cmp_id = @cmp_id and _month = @Month and _year = @Year 
			and mad.Amount > 0 and isnull(TD.TDS_Amount,0) = 0
			
			--and I.Branch_id=isnull(@Branch,I.Branch_id) --Branch_Id condition added By Mukti 30112015  --Comment by Jaina 15-02-2019
			Order by MAD.Emp_id
			
		-- Ended by rohit on 22072015	
		End
		Else if @Challan_Status = 'All'
		Begin
											
			Insert into #Emp_TDS_Challan 
		Select MAD.Emp_id, MAD.cmp_id, E.Alpha_Emp_Code, E.Emp_Full_Name, _month, _year, 
				CASE WHEN isnull(TD.TDS_Amount,0) = 0 THEN
						 --CONVERT(varchar,CAST(Round(isnull(Amount - (Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0) AS money),1)
						 Round(isnull(Amount - (Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0)
					 ELSE CONVERT(varchar,0) END as Tax_Amount, 
				--CONVERT(varchar,CAST(Round(isnull((Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0) as money),1) Ed_Cess, 
				--Round(isnull((Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0) Ed_Cess,
				CASE WHEN ISNULL(TD.TDS_Amount,0) = 0 THEN 
					Round(isnull((Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0) 
				else 0 END AS Ed_Cess,
				CASE WHEN ISNULL(TD.TDS_Amount,0) = 0 THEN 
						  --CONVERT(varchar,CAST(Amount as money),1)
						  Amount
					 Else CONVERT(varchar,0) END as Amount, 
					(Select Sum(Round(isnull(Amount - (Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount) ,0),0)) 
					 From #Emp_TDS
					Where cmp_id = @cmp_id and _month = @Month and _year= @Year ),
					(Select Sum(Round(isnull((Amount * @Ed_cess_per_amount)/(100 + @Ed_cess_per_amount),0),0)) From #Emp_TDS
					Where cmp_id = @cmp_id and _month = @Month and _year= @Year ),
					(Select Sum(Round(isnull(Amount,0),0)) From #Emp_TDS
					Where cmp_id = @cmp_id and _month = @Month and _year = @Year ),
					I.Branch_ID,B.Branch_Name,I.Dept_ID,D.Dept_Name,I.Desig_Id,Ds.Desig_Name  --Added by Jaina 08-02-2019
					,(isnull(TD.TDS_Amount,0)+ isnull(TD.Additional_Amount,0)+ ISNULL(td.ed_cess,0)) as Tax_Paid,0 as Additional_Amount
		From #Emp_TDS MAD 
		inner join T0080_EMP_MASTER E WITH (NOLOCK) on MAD.Emp_Id = E.Emp_id	
		 INNER JOIN #EMP_CONS EC ON EC.EMP_ID = E.EMP_ID	
		--Added By Mukti(start)30112015
		inner join T0095_Increment I WITH (NOLOCK) on I.Emp_id=MAD.Emp_Id
		and I.Increment_Id=(SELECT MAX(Increment_Id) AS Increment_Id   
								FROM T0095_Increment WITH (NOLOCK)
								WHERE  Cmp_ID = @Cmp_ID and emp_id=MAD.Emp_Id GROUP BY emp_ID)  
		--Added By Mukti(end)30112015
		 --Added by Jaina 08-02-2019 Start
		left JOIN T0030_BRANCH_MASTER B WITH (NOLOCK) ON B.Branch_ID = I.Branch_ID
		left JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON D.Dept_Id = I.Dept_ID
		left JOIN T0040_DESIGNATION_MASTER Ds WITH (NOLOCK) ON Ds.Desig_ID = I.Desig_Id
		--Added by Jaina 08-02-2019 End
		 left JOIN 
		 (	SELECT sum(isnull(TC.TDS_Amount,0)) as TDS_Amount ,
				   sum(isnull(TC.Additional_Amount,0)) as Additional_Amount,
				   SUM(ISNULL(tc.Ed_Cess,0)) as Ed_Cess, EM.Emp_ID 
			FROM T0220_TDS_CHALLAN T WITH (NOLOCK) INNER JOIN
			T0230_TDS_CHALLAN_DETAIL TC WITH (NOLOCK) on T.Challan_Id = TC.Challan_Id INNER JOIN
			#Emp_Cons EM on EM.Emp_ID = TC.Emp_ID			
			WHERE T.Month = @Month and T.Year = @Year
			group BY EM.Emp_ID
			
		 )As TD ON TD.Emp_ID = EC.Emp_ID
		Where MAD.cmp_id = @cmp_id and _month = @Month and _year = @Year 
		and mad.Amount > 0 
		
		--and I.Branch_id=isnull(@Branch,I.Branch_id) --Branch_Id condition added By Mukti 30112015  --Comment by Jaina 15-02-2019
		Order by MAD.Emp_id
		
	-- Ended by rohit on 22072015	
		End
		
		
		select * from #Emp_TDS_Challan
		
	

RETURN




