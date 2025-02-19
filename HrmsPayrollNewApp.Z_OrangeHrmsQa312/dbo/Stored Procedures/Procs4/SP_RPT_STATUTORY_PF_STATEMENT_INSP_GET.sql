




-- =============================================
-- Author:		<Falak,,Ornage Technolab>
-- ALTER date: <23-SEP=2010>
-- Description:	<PF summary monthwise>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_PF_STATEMENT_INSP_GET]
	@Cmp_ID  numeric    
	,@From_Date  datetime    
	,@To_Date  datetime    
	,@Branch_ID  numeric    
	,@Cat_ID  numeric    =0 
	,@Grd_ID  numeric    =0
	,@Type_ID  numeric   =0 
	,@Dept_ID  numeric   =0 
	,@Desig_ID  numeric  =0 
	,@Emp_ID  numeric    =0
	,@constraint  varchar(5000)  = ''
	
AS

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	IF @Branch_ID = 0      
		set @Branch_ID = null    
	
    Declare @PF_summ  table
    (
		for_Date datetime,
		Cmp_ID numeric,
		Branch_Id numeric,
		Payment_Date datetime,
		Total_Subscriber numeric,
		Total_Wages_Due numeric,
		AC_1 numeric,
		AC_2 numeric,
		AC_10 numeric,
		AC_21 numeric,
		AC_22 numeric,
		AC_Total numeric,
		AC_1_Employee Numeric,
		Total_Family_Pension_Wages_Amount Numeric,
		Total_EDLI_Wages_Amount Numeric
			
	)
    
    
    Declare @Temp_To_date datetime
    Declare @Temp_From_date datetime
    
    set @Temp_From_date = @From_Date 
    set @Temp_To_date = @To_Date
    
    while @Temp_From_date < @Temp_To_date 
		begin
			
			Insert into @PF_summ 
				(for_Date,Cmp_ID ,Branch_Id,Payment_Date  ,Total_Subscriber ,Total_Wages_Due ,AC_1 ,AC_2 ,AC_10 ,AC_21 ,AC_22 ,AC_Total ,AC_1_Employee,Total_Family_Pension_Wages_Amount,Total_EDLI_Wages_Amount)
				values
				(@Temp_From_date,@Cmp_ID ,@Branch_ID,null  ,0,0,0,0,0,0,0,0,0,0,0 )
			set @Temp_From_date = DATEADD (m,1,@Temp_From_date )
		end
	
	
	Update @PF_summ 
	set Total_Subscriber = PF.Total_SubScriber ,
		Total_Wages_Due = PF.Total_Wages_Due ,
		Payment_Date = PF.Payment_Date ,
		AC_1 = qry.T_AC_1 ,
		AC_2 = qry.T_AC_2 ,
		AC_10 = qry .T_AC_10 ,
		AC_21 = qry.T_AC_21 ,
		AC_22 = qry.T_AC_22 ,
		AC_Total = qry.T_AC_Total, 
		Total_Family_Pension_Wages_Amount = PF.Total_Family_Pension_Wages_Amount,
		Total_EDLI_Wages_Amount = PF.Total_EDLI_Wages_Amount
	
	from @PF_summ as PF_Summ ,--inner join
	T0220_PF_CHALLAN as PF inner join --on Month(PF_Summ.for_Date ) = PF.Month inner join
	( select PF1.pf_challan_id,pf1.month, pf1.year, sum(PF_D.AC_1)as T_AC_1, 
		SUM(PF_D.AC_2) as T_AC_2, SUM(PF_D.AC_10) as T_AC_10,
			SUM(PF_D.AC_21) as T_AC_21 , SUM(PF_D.AC_22) as T_AC_22, SUM(PF_D.AC_Total) as T_AC_Total
		from T0230_PF_CHALLAN_DETAIL as PF_D WITH (NOLOCK) inner join T0220_PF_Challan as PF1 WITH (NOLOCK) on PF_D.PF_challan_ID = PF1.pf_challan_ID
		where isnull(PF1 .Branch_ID,0) = isnull(@Branch_ID,0) and PF1 .Cmp_ID = @Cmp_ID 
		group by pf1.month,pf1.year,PF1.Pf_Challan_ID) as qry on qry.Pf_Challan_ID = PF.Pf_Challan_ID 
	where Month(PF_Summ.for_Date ) = PF.Month and Year(PF_Summ.for_Date ) = PF.Year 
	and isnull(PF.Branch_ID,0) = isnull(@Branch_ID,0)	and PF.Cmp_ID = @Cmp_ID 


		Update @PF_summ Set AC_1 = Qry.AC_1  -----Add for AC 1 sapration : employee 13032012 hardik-hasmukh
		From @PF_summ as PF_Summ inner join 
		(Select pf1.month,pf1.year,sum(PF_D.AC_1) As AC_1
		from T0230_PF_CHALLAN_DETAIL as PF_D WITH (NOLOCK) inner join T0220_PF_Challan as PF1 WITH (NOLOCK) on PF_D.PF_challan_ID = PF1.pf_challan_ID 
		inner join @PF_summ as PF_Summ on Month(PF_Summ.for_Date ) = PF1.Month and Year(PF_Summ.for_Date ) = PF1.Year 
		and isnull(PF1.Branch_ID,0) = isnull(@Branch_ID,0)	and PF1.Cmp_ID = @Cmp_ID
		where isnull(PF1 .Branch_ID,0) = isnull(@Branch_ID,0) and PF1 .Cmp_ID = @Cmp_ID  and Payment_Head like '%Employer%'
		group by pf1.month,pf1.year,PF1.Pf_Challan_ID,Payment_Head) Qry on Month(PF_Summ.for_Date) = qry.Month And Year(PF_Summ.for_Date) = qry.Year



		Update @PF_summ Set AC_1_Employee = Qry.AC_1_Employee -----Add for AC 1 sapration : employee 13032012 hardik-hasmukh
		From @PF_summ as PF_Summ inner join 
		(Select pf1.month,pf1.year,sum(PF_D.AC_1) As AC_1_Employee
		from T0230_PF_CHALLAN_DETAIL as PF_D WITH (NOLOCK) inner join T0220_PF_Challan as PF1 WITH (NOLOCK) on PF_D.PF_challan_ID = PF1.pf_challan_ID 
		inner join @PF_summ as PF_Summ on Month(PF_Summ.for_Date ) = PF1.Month and Year(PF_Summ.for_Date ) = PF1.Year 
		and isnull(PF1.Branch_ID,0) = isnull(@Branch_ID,0)	and PF1.Cmp_ID = @Cmp_ID
		where isnull(PF1 .Branch_ID,0) = isnull(@Branch_ID,0) and PF1 .Cmp_ID = @Cmp_ID  and Payment_Head like '%Employee%'
		group by pf1.month,pf1.year,PF1.Pf_Challan_ID,Payment_Head) Qry on Month(PF_Summ.for_Date) = qry.Month And Year(PF_Summ.for_Date) = qry.Year
		
	select PF.*,CM.Cmp_Name ,CM.Cmp_Address ,CM.Cmp_City ,CM.Cmp_PinCode,cm.PF_No as CPF_No,BR.Comp_Name ,BR.Branch_Address,@From_Date as From_date,@To_date as To_Date   
	from @PF_summ as PF inner join
	T0010_COMPANY_MASTER as CM WITH (NOLOCK) on PF.Cmp_ID = CM.Cmp_Id Left outer join
	T0030_BRANCH_MASTER BR WITH (NOLOCK) on isnull(PF.Branch_Id,0) = BR.Branch_ID 
	where PF.Cmp_ID = @Cmp_ID and ISNULL(PF.branch_id,0) = ISNULL(@Branch_ID ,0)
	
Return




