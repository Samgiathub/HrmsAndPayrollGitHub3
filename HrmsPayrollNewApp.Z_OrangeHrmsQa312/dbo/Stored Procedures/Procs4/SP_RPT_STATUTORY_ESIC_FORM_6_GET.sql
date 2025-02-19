
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_ESIC_FORM_6_GET]
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
	,@Constraint 	varchar(MAX)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
	Declare @Employer_share_Cont numeric(5,2)
	set @Employer_share_Cont = 4.75
	 
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
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK) ) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
		end
		 
		Declare @Month numeric 
		Declare @Year numeric  
		if	exists (select * from [tempdb].dbo.sysobjects where name like '#ESIC_FORM' )		
			begin
				drop table #ESIC_FORM 
			end
			 
		--Modified by Nimesh 29-May-2015 (numeric(5,1) to numeric(10,1) and numeric(7,2) to numeric(15,2))
		CREATE table #ESIC_FORM 
			(
				Row_ID				numeric IDENTITY (1,1) not null,
				Cmp_ID				numeric ,
				Emp_Id				numeric ,
				Month_1_Days		numeric(10,1) default 0,
				Month_1_Wages		numeric(15,2) Default 0,
				Month_1_Esic_Amt	numeric(15,2) Default 0,
				Month_1_C_Esic_Amt	numeric(15,2) Default 0,
				Month_2_Days		numeric(10,1) default 0,
				Month_2_Wages		numeric(15,2) Default 0,
				Month_2_Esic_Amt	numeric(15,2) Default 0,
				Month_2_C_Esic_Amt	numeric(15,2) Default 0,
				Month_3_Days		numeric(10,1) default 0,
				Month_3_Wages		numeric(15,2) Default 0,
				Month_3_Esic_Amt	numeric(15,2) Default 0,
				Month_3_C_Esic_Amt	numeric(15,2) Default 0,
				Month_4_Days		numeric(10,1) default 0,
				Month_4_Wages		numeric(15,2) Default 0,
				Month_4_Esic_Amt	numeric(15,2) Default 0,
				Month_4_C_Esic_Amt	numeric(15,2) Default 0,
				Month_5_Days		numeric(10,1) default 0,
				Month_5_Wages		numeric(15,2) Default 0,
				Month_5_Esic_Amt	numeric(15,2) Default 0,
				Month_5_C_Esic_Amt	numeric(15,2) Default 0,
				Month_6_Days		numeric(10,1) default 0,
				Month_6_Wages		numeric(15,2) Default 0,
				Month_6_Esic_Amt	numeric(15,2) Default 0,
				Month_6_C_Esic_Amt	numeric(15,2) Default 0,
				Total_Days			numeric(10,1) default 0,
				Total_Wages			numeric(10,2) Default 0,
				Total_Esic_Amt		numeric(10,2) Default 0,
				Total_C_Esic_Amt	numeric(18,2) Default 0,
				AD_ID				numeric, 
				
			)
	
			
			
		insert into #ESIC_FORM (Cmp_ID,Emp_ID,AD_ID)
		select DISTINCT @Cmp_ID,EC.emp_ID,MAD.AD_ID From @Emp_Cons EC	INNER JOIN  
			T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON EC.EMP_ID = MAD.EMP_ID INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID
		  WHERE AD_DEF_ID =3 AND ad_not_effect_salary <> 1 and  FOR_DATE >=@fROM_dATE AND FOR_dATE <=@TO_DATE 
			and M_AD_Amount > 0
 	
		declare @Temp_Date datetime
		Declare @count numeric 
		set @Temp_Date = @From_Date 
		set @count = 1 
		while @Temp_Date <=@To_Date 
			Begin
				set @Month =month(@Temp_date)
				set @Year = year(@Temp_Date)
						
				if @count = 1 
					begin
						
						Update #ESIC_FORM 
						set Month_1_Days = Sal_cal_days ,
							Month_1_Wages =  M_AD_Calculated_Amount,
							Month_1_Esic_Amt = M_AD_AMOUNT 
						From #ESIC_FORM  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
							AND YS.AD_ID = MAD.AD_ID inner join T0200_MONTHLY_SALARY MS on mad.sal_tran_ID = ms.Sal_Tran_ID
						Where Month(FOR_DATE) = @Month and Year(FOR_DATE) = @Year					
					end
				else if @count = 2
					begin
						Update #ESIC_FORM 
						set Month_2_Days = Sal_cal_days ,
							Month_2_Wages =  M_AD_Calculated_Amount,
							Month_2_Esic_Amt = M_AD_AMOUNT 
						From #ESIC_FORM  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
							AND YS.AD_ID = MAD.AD_ID inner join T0200_MONTHLY_SALARY MS on mad.sal_tran_ID = ms.Sal_Tran_ID
						Where Month(FOR_DATE) = @Month and Year(FOR_DATE) = @Year					

					end	
				else if @count = 3
					begin
						Update #ESIC_FORM 
						set Month_3_Days = Sal_cal_days ,
							Month_3_Wages =  M_AD_Calculated_Amount,
							Month_3_Esic_Amt = M_AD_AMOUNT 
						From #ESIC_FORM  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
							AND YS.AD_ID = MAD.AD_ID inner join T0200_MONTHLY_SALARY MS on mad.sal_tran_ID = ms.Sal_Tran_ID
						Where Month(FOR_DATE) = @Month and Year(FOR_DATE) = @Year					
					end	
				else if @count = 4
					begin
						Update #ESIC_FORM 
						set Month_4_Days = Sal_cal_days ,
							Month_4_Wages =  M_AD_Calculated_Amount,
							Month_4_Esic_Amt = M_AD_AMOUNT 
						From #ESIC_FORM  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
							AND YS.AD_ID = MAD.AD_ID inner join T0200_MONTHLY_SALARY MS on mad.sal_tran_ID = ms.Sal_Tran_ID
						Where Month(FOR_DATE) = @Month and Year(FOR_DATE) = @Year					
					end	
				else if @count = 5
					begin
						Update #ESIC_FORM 
						set Month_5_Days = Sal_cal_days ,
							Month_5_Wages =  M_AD_Calculated_Amount,
							Month_5_Esic_Amt = M_AD_AMOUNT 
						From #ESIC_FORM  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
							AND YS.AD_ID = MAD.AD_ID inner join T0200_MONTHLY_SALARY MS on mad.sal_tran_ID = ms.Sal_Tran_ID
						Where Month(FOR_DATE) = @Month and Year(FOR_DATE) = @Year					
					
					end	
				else if @count = 6
					begin
						Update #ESIC_FORM 
						set Month_6_Days = Sal_cal_days ,
							Month_6_Wages =  M_AD_Calculated_Amount,
							Month_6_Esic_Amt = M_AD_AMOUNT 
						From #ESIC_FORM  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
							AND YS.AD_ID = MAD.AD_ID inner join T0200_MONTHLY_SALARY MS on mad.sal_tran_ID = ms.Sal_Tran_ID
						Where Month(FOR_DATE) = @Month and Year(FOR_DATE) = @Year					
					end	
						 
																																			
				set @Temp_Date = dateadd(m,1,@Temp_date)
				set @count = @count + 1  
			End
	
		UPDATE #ESIC_FORM
		SET Total_Days		= Month_1_Days + Month_2_Days + Month_3_Days + Month_4_Days + Month_5_Days + Month_6_Days,
			Total_Wages		= Month_1_Wages + Month_2_Wages + Month_3_Wages + Month_4_Wages + Month_5_Wages + Month_6_Wages ,
			Total_Esic_Amt  = Month_1_Esic_Amt + Month_2_Esic_Amt + Month_3_Esic_Amt + Month_4_Esic_Amt + Month_5_Esic_Amt + Month_6_Esic_Amt

		UPDATE #ESIC_FORM
		SET Month_1_C_Esic_Amt = ceiling(Month_1_Wages  * @Employer_share_Cont/100),
			Month_2_C_Esic_Amt = ceiling(Month_2_Wages *@Employer_share_Cont/100),
			Month_3_C_Esic_Amt = ceiling(Month_3_Wages * @Employer_share_Cont/100),
			Month_4_C_Esic_Amt = ceiling(Month_4_Wages * @Employer_share_Cont/100),
			Month_5_C_Esic_Amt = ceiling(Month_5_Wages * @Employer_share_Cont/100),
			Month_6_C_Esic_Amt = ceiling(Month_6_Wages * @Employer_share_Cont/100)
			
		
		-- Changed By Ali 25112013 EmpName_Alias
		select  Ys.*,Grd_NAme,Dept_Name,Desig_Name,Branch_NAme,Type_NAme 
			,Cmp_NAme,Cmp_Address,Emp_Code,ISNULL(EmpName_Alias_ESIC,Emp_Full_Name) as Emp_full_Name,date_of_join,emp_left_date,
			@From_Date P_From_Date , @To_Date P_To_Date,SIN_No as ESIC_No
			,Insurance_No,Religion,Height,Emp_Mark_Of_Identification,Despencery,Doctor_Name,DespenceryAddress
				,DBO.F_GET_AGE (Date_of_Birth,getdate(),'N','N')as Emp_Age
		from #ESIC_FORM  Ys inner join 
		( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	WITH (NOLOCK) -- Ankit 09092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)IQ on
				ys.emp_Id = iq.emp_Id inner join
					T0080_EMP_MASTER EM WITH (NOLOCK) ON YS.EMP_ID = EM.EMP_ID INNER JOIN 
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON IQ.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON IQ.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON IQ.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON IQ.Dept_Id = DM.Dept_Id Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on IQ.Branch_ID = BM.Branch_ID inner join 
					T0010_COMPANY_MASTER cm WITH (NOLOCK) on ys.cmp_Id = cm.cmp_Id
				 
		order by ys.Emp_ID ,Row_ID
			
					
	RETURN 




