

-- created by rohit on 08072016
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Excel_Esic_Component]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
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
SET NOCOUNT ON 
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
		


	CREATE table #Emp_Cons 	
		 (      
		   Emp_ID numeric ,     
		   Branch_ID numeric,
		   Increment_ID numeric    
		 )	
	--EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,null,null,null,null,null,@Emp_ID ,@constraint ,0 ,0 ,0 ,0 ,0 ,0 
	--EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_ID ,@constraint=@constraint,@PBranch_ID=@Branch_ID  --Added by Jaina 22-05-2017
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,'',0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_ID,0,0,0,'0',0,0               
	
	CREATE table #Tbl_Get_AD
	(
		Emp_ID numeric(18,0),
		Ad_ID numeric(18,0),
		for_date datetime,
		E_Ad_Percentage numeric(18,5),
		M_Ad_Amount numeric(18,2)
		
	)
	
	INSERT INTO #Tbl_Get_AD
		Exec P_Emp_Revised_Allowance_Get @Cmp_ID,@To_Date
	

	
	Select distinct 
	     e.Alpha_Emp_Code as 'Employee Code',e.Emp_Full_name as 'Employee Full name',GM.Grd_Name as 'Grade Name',Branch_Name as 'Branch Name',Dept_Name as 'Department Name',Desig_Name as 'Designation Name',type_Name as 'Type Name',Cmp_Name as 'Company Name',convert(varchar(11),tn.for_date,103) as 'For Date',ad.ad_name as 'Head Name'
	     ,(isnull(I_Q.Basic_Salary,0) + isnull(TGA.M_Ad_Amount,0))  as Rate
	     ,tn.Hours as 'Hours',tn.Amount as 'Amount',tn.Esic as 'ESIC',tn.TDS as 'TDS',
	     tn.Net_Amount as 'Net Amount',bnk.Bank_Name as 'Bank Name'
	     ,Inc_Bank_AC_No as 'Bank Account No'
         from 
         --T0200_MONTHLY_SALARY la 
         t0210_ESIC_On_Not_Effect_on_Salary tn WITH (NOLOCK)
         inner join #Emp_Cons ec on tn.emp_ID = ec.Emp_ID 
         inner join T0010_Company_Master CM WITH (NOLOCK) on tn.CMP_ID= CM.CMP_ID
         inner join T0080_Emp_Master e WITH (NOLOCK) on ec.emp_ID= e.emp_ID 
         inner join
					( select I.Emp_Id ,i.Basic_Salary,i.Gross_Salary, Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,i.Type_ID,Increment_effective_Date,I.bank_id,Inc_Bank_AC_No from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @to_date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
						on Ec.Emp_ID = I_Q.Emp_ID  and I_Q.Cmp_ID=E.Cmp_ID left join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID left join
							--T0100_EMP_EARN_DEDUCTION ed on la.Emp_ID=ed.emp_id inner join 
							T0050_AD_MASTER ad WITH (NOLOCK) on ad.cmp_id=tn.cmp_id and ad.AD_ID=tn.AD_ID	left join
							t0040_bank_master bnk WITH (NOLOCK) on I_Q.Bank_ID=bnk.Bank_ID
			left join (select Tg.* from #Tbl_Get_AD TG inner join t0050_ad_master AM WITH (NOLOCK) on tg.ad_id =Am.AD_ID  
					where AD_DEF_ID = 11 ) as TGA on ec.emp_id = tga.Emp_ID				
			
			where tn.Ad_Id = isnull(@AD_ID,tn.Ad_Id) and tn.For_Date >= @From_Date and tn.for_date <= @To_Date		
					and ad.Hide_In_Reports = 0  --Added by Jaina 22-05-2017
	
    RETURN 




