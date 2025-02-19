--exec P0210_Final_Retaining_Payment_record_Get @cmp_id=120, @From_Date ='2021-01-01 00:00:00.000',@To_Date ='2022-03-31 00:00:00.000',@Branch_ID=0

-- =============================================
-- Author:		Deepali Mhaske
-- Create date: 04-02-2022 
-- Description:	Create Procedure  [P0210_Final_Retaining_Payment_record_Get]
-- =============================================
CREATE PROCEDURE [dbo].[P0210_Final_Retaining_Payment_record_Get]

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
		Retain_Amount Numeric(18,2),
		ESIC Numeric(18,2),
		Net_Amount Numeric(18,2),
		Comp_ESIC Numeric(18,2),
		EPF Numeric(18,2),
		CPF Numeric(18,2),
		VPF Numeric(18,2)
	)	
	
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
		begin
			Declare @new_constrint varchar(1000)
			select @new_constrint = COALESCE(@new_constrint + '#', '') +  '' + cast(Emp_ID as varchar(50))+ ''
			From #ESIC_Temp_Table
 
		end 
		-------------------------Commented old Gradewise Allowance Calculation- by Deepali as per discussion with sandip bhai - 3008-2022 -Start-------------------------------------------------------

		--isnull((select isnull(Sum(Amount),0) from T0210_Retaining_Payment_Detail where Emp_id= Re.Emp_ID and Re.Ad_id= @Ad_Id )*((select isnull(AD_Percentage,0) from T0120_GRADEWISE_ALLOWANCE where AD_id in(select Ad_ID from T0050_AD_MASTER 
		--	where AD_DEF_ID = 2  and CMP_ID =@CMP_ID) and Grd_ID = (select grd_id from T0080_EMP_MASTER where Emp_Id =  Re.Emp_ID and  CMP_ID = @CMP_ID))/100),0)
		--	 as EPF,
		--	 isnull((select isnull(Sum(Amount),0) from T0210_Retaining_Payment_Detail where Emp_id= Re.Emp_ID and Re.Ad_id= @Ad_Id )*((select isnull(AD_Percentage,0) from T0120_GRADEWISE_ALLOWANCE where AD_id in(select Ad_ID from T0050_AD_MASTER 
		--	where AD_DEF_ID = 5 and CMP_ID =@CMP_ID) and Grd_ID = (select grd_id from T0080_EMP_MASTER where Emp_Id =  Re.Emp_ID and  CMP_ID = @CMP_ID))/100),0)
		--	 as CPF,
		--	isnull( (select isnull(Sum(Amount),0) from T0210_Retaining_Payment_Detail where Emp_id= Re.Emp_ID and Re.Ad_id= @Ad_Id )*((select isnull(AD_Percentage,0) from T0120_GRADEWISE_ALLOWANCE where AD_id in(select Ad_ID from T0050_AD_MASTER 
		--	where AD_DEF_ID = 4  and CMP_ID =@CMP_ID) and Grd_ID = (select grd_id from T0080_EMP_MASTER where Emp_Id =  Re.Emp_ID and  CMP_ID = @CMP_ID))/100),0)
		--	 as VPF,
		--	isnull( (select  Sum(Amount) from T0210_Retaining_Payment_Detail where Emp_id= Re.Emp_ID) -(select isnull(Sum(Amount),0) from T0210_Retaining_Payment_Detail where Emp_id= Re.Emp_ID and Re.Ad_id= @Ad_Id )*((select isnull(AD_Percentage,0) from T0120_GRADEWISE_ALLOWANCE where AD_id in(select Ad_ID from T0050_AD_MASTER 
		--	where AD_DEF_ID = 2  and CMP_ID =@CMP_ID) and Grd_ID = (select grd_id from T0080_EMP_MASTER where Emp_Id =  Re.Emp_ID and  CMP_ID = @CMP_ID))/100)
		--	-(select isnull(Sum(Amount),0) from T0210_Retaining_Payment_Detail where Emp_id= Re.Emp_ID and Re.Ad_id= @Ad_Id )*((select isnull(AD_Percentage,0) from T0120_GRADEWISE_ALLOWANCE where AD_id in(select Ad_ID from T0050_AD_MASTER 
		--	where AD_DEF_ID = 4  and CMP_ID =@CMP_ID) and Grd_ID = (select grd_id from T0080_EMP_MASTER where Emp_Id =  Re.Emp_ID and  CMP_ID = @CMP_ID))/100),0)
		--	as Net_Amount

		---------------------------Commented old Gradewise Allowance Calculation- by Deepali as per discussion with sandip bhai - 3008-2022 -End-------------------------------------------------------------
		Select 
			 distinct Re.Emp_ID,Re.AD_ID,Alpha_Emp_Code as Alpha_Emp_Code, 
				 (select  Sum(Calculation_Amount) from T0210_Retaining_Payment_Detail where Emp_id= Re.Emp_ID) as Amount,
				 (select  Sum(Amount) from T0210_Retaining_Payment_Detail where Emp_id= Re.Emp_ID) as Retain_Amount,
				(select top 1 For_Date from T0210_Retaining_Payment_Detail where Emp_id= Re.emp_id) as for_date,
				(select top 1 Start_Date from T0210_Retaining_Payment_Detail where Emp_id= Re.emp_id) as P_From_Date,
				(select top 1 End_date from T0210_Retaining_Payment_Detail where Emp_id= Re.emp_id order by End_date desc) as  P_To_Date ,
				(select  Sum(Period) from T0210_Retaining_Payment_Detail where Emp_id= Re.Emp_ID)  as Period ,
				(select top 1 Ret_Tran_Id from T0210_Retaining_Payment_Detail where Emp_id= Re.Emp_ID)  as Ret_Tran_Id ,

			0 as TDS,
			--  AD_DEF_ID = 2-EPF 5-CPF 4 VPF
			ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Grd_Name,Type_Name,Dept_Name,Desig_Name,AD_Name,AD_LEVEL
			,cmp_Name,Cmp_Address,Branch_Address,Comp_name,branch_name			
			,EC.Branch_ID,E.Pan_No,I_Q.Basic_Salary
			NewTaxableAmount,0 As Percentage,0 as Ot_Hours,0 as Basic_OT_Salary 
			,0 as Working_Days,

			round(isnull((select isnull(Sum(Amount),0) from T0210_Retaining_Payment_Detail RPD where Emp_id= Re.Emp_ID and RPD.Ad_id= @Ad_Id  )*
			((select top 1 isnull(E_AD_Percentage,0) from T0100_EMP_EARN_DEDUCTION  ed , T0095_INCREMENT Inc where ed.emp_id = Inc.emp_id and ed.emp_id = Re.Emp_ID 
			and Inc.Increment_ID in (select top 1(Increment_ID) from T0095_INCREMENT  where emp_id = Re.Emp_ID and FOR_DATE <=Re.Start_date)
			and AD_id in(select top 1 Ad_ID from T0050_AD_MASTER where AD_DEF_ID = 2  and CMP_ID =@CMP_ID)))/100,0),2)
			 as EPF,

			 	round(isnull((select isnull(Sum(Amount),0) from T0210_Retaining_Payment_Detail RPD where Emp_id= Re.Emp_ID and RPD.Ad_id= @Ad_Id  )*
			((select top 1 isnull(E_AD_Percentage,0) from T0100_EMP_EARN_DEDUCTION  ed , T0095_INCREMENT Inc where ed.emp_id = Inc.emp_id and ed.emp_id = Re.Emp_ID 
			and Inc.Increment_ID in (select top 1(Increment_ID) from T0095_INCREMENT  where emp_id = Re.Emp_ID and FOR_DATE <=Re.Start_date)
			and AD_id in(select top 1 Ad_ID from T0050_AD_MASTER where AD_DEF_ID = 5  and CMP_ID =@CMP_ID)))/100,0),2)
			 as CPF,

			 	round(isnull((select isnull(Sum(Amount),0) from T0210_Retaining_Payment_Detail RPD where Emp_id= Re.Emp_ID and RPD.Ad_id= @Ad_Id  )*
			((select top 1 isnull(E_AD_Percentage,0) from T0100_EMP_EARN_DEDUCTION  ed , T0095_INCREMENT Inc where ed.emp_id = Inc.emp_id and ed.emp_id = Re.Emp_ID 
			and Inc.Increment_ID in (select top 1(Increment_ID) from T0095_INCREMENT  where emp_id = Re.Emp_ID and FOR_DATE <=Re.Start_date)
			and AD_id in(select top 1 Ad_ID from T0050_AD_MASTER where AD_DEF_ID = 4  and CMP_ID =@CMP_ID)))/100,0),2)
			 as VPF,

			 isnull( (select  Sum(Amount) from T0210_Retaining_Payment_Detail where Emp_id= Re.Emp_ID) -
			 isnull((select isnull(Sum(Amount),0) from T0210_Retaining_Payment_Detail RPD where Emp_id= Re.Emp_ID and RPD.Ad_id= @Ad_Id  )*
			((select top 1 isnull(E_AD_Percentage,0) from T0100_EMP_EARN_DEDUCTION  ed , T0095_INCREMENT Inc where ed.emp_id = Inc.emp_id and ed.emp_id = Re.Emp_ID 
			and Inc.Increment_ID in (select top 1(Increment_ID) from T0095_INCREMENT  where emp_id = Re.Emp_ID and FOR_DATE <=Re.Start_date)
			and AD_id in(select top 1 Ad_ID from T0050_AD_MASTER where AD_DEF_ID = 2  and CMP_ID =@CMP_ID)))/100,2)
			-isnull((select isnull(Sum(Amount),0) from T0210_Retaining_Payment_Detail RPD where Emp_id= Re.Emp_ID and RPD.Ad_id= @Ad_Id  )*
			((select top 1 isnull(E_AD_Percentage,0) from T0100_EMP_EARN_DEDUCTION  ed , T0095_INCREMENT Inc where ed.emp_id = Inc.emp_id and ed.emp_id = Re.Emp_ID 
			and Inc.Increment_ID in (select top 1(Increment_ID) from T0095_INCREMENT  where emp_id = Re.Emp_ID and FOR_DATE <=Re.Start_date)
			and AD_id in(select top 1 Ad_ID from T0050_AD_MASTER where AD_DEF_ID = 4  and CMP_ID =@CMP_ID)))/100,2),2)
			as Net_Amount


		From T0210_Retaining_Payment_Detail  Re Inner join 
			T0050_AD_MASTER ADM WITH (NOLOCK) ON Re.AD_ID = ADM.AD_ID INNER JOIN 
			T0080_EMP_MASTER E WITH (NOLOCK) on Re.emp_ID = E.emp_ID INNER  JOIN 
			#EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
			T0095_Increment I_Q WITH (NOLOCK) On EC.INCREMENT_ID= I_Q.Increment_ID Inner Join
			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID Inner Join
			T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID Inner Join
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id Inner Join
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner Join 
			T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  Inner Join
			T0010_company_Master cm WITH (NOLOCK) on E.Cmp_ID = cm.cmp_ID
			--left  join #tbl_Taxable_Income TI on MAD.Emp_ID = TI.Emp_Id 
					--left outer join T0210_Final_Retaining_Payment F WITH (NOLOCK) on Re.Emp_ID = F.Emp_Id and Re.AD_ID = F.Ad_Id 
			--and MAD.Month = MONTH(F.For_Date) and MAD.year =YEAR(F.For_Date)
		WHERE E.Cmp_ID = @Cmp_Id	
		--and MAD.Month = month(@to_date) 
			--and MAD.year <=year(@To_Date)
			--and  mad.AD_ID = isnull(@AD_ID,Mad.AD_ID) and MAD.Retain_Amount <> 0
			--and ADM.AD_NOT_EFFECT_SALARY = 1
			--and isnull(F.Tran_Id,0) =0	
		group by E.Alpha_Emp_Code, Re.Emp_Id, Re.AD_ID,
		EmpName_Alias_Salary,Emp_Full_Name,Grd_Name,Type_Name,Dept_Name,Desig_Name,AD_Name,AD_LEVEL
	,cmp_Name,Cmp_Address,Branch_Address,Comp_name,branch_name,RE.for_date,Re.Start_date, Re.End_date,Re.Period,EC.Branch_ID,E.Pan_No,I_Q.Basic_Salary,Re.Ret_Tran_Id
		order by E.Alpha_Emp_Code, Re.Emp_Id
	--end

RETURN 



