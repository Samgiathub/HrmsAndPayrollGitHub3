
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_ESIC_COMPONENTS]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@Branch_ID		varchar(Max) = ''
	,@Cat_ID		varchar(Max) = ''
	,@Grd_ID		varchar(Max) = ''
	,@Type_ID		varchar(Max) = ''
	,@Dept_Id		varchar(Max) = ''
	,@Desig_Id		varchar(Max) = ''
	,@Emp_ID		numeric  = 0
	,@AD_ID			numeric(18,0)=0
	,@Constraint	varchar(MAX)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

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


	CREATE TABLE #Emp_Cons 	
		 (      
		   Emp_ID numeric ,     
		   Branch_ID numeric,
		   Increment_ID numeric    
		 )	
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0 ,0 ,0 ,0 
	
	     Select distinct 
	     e.Alpha_Emp_Code as Emp_Code,e.Emp_Full_name,tn.for_date,tn.Hours,tn.Esic,tn.Amount,tn.Net_Amount,bnk.Bank_Name,GM.Grd_Name,Branch_Name
	                      ,Dept_Name,Desig_Name,type_Name,Cmp_Name,Cmp_Address,comp_name,branch_name,branch_address ,BM.Branch_ID
	                      ,ad.ad_name,Inc_Bank_AC_No
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
			
			where tn.Ad_Id=@AD_ID and For_Date >= @From_Date and for_date <= @To_Date		
		
		
		
    	RETURN 


