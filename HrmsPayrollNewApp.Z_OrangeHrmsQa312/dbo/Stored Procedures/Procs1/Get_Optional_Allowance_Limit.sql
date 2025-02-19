


  ---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Optional_Allowance_Limit]    	
	 @Cmp_ID NUMERIC(18,0) 
	,@Emp_ID NUMERIC(18,0) 
	,@for_Date Datetime  
	
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

   Declare @desig_ID as numeric(18,0)
   Declare @grd_ID as numeric(18,0)
   Declare @Eligibility_Limit as numeric(18,2)
   Declare @Grd_Eligibility_Limit as numeric(18,2)
   Declare @Check_Eligibility_Design_Wise as int
   set @Check_Eligibility_Design_Wise =0
   Declare @Basic_Salary as  numeric(18,2)
   
   select @desig_ID =E.Desig_Id,
		  @grd_ID=E.Grd_ID,
		  @Basic_Salary=I_Q.Basic_Salary 	from dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
				( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID, I.Basic_Salary from dbo.T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)	
						where Increment_Effective_date <= @for_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
					on E.Emp_ID = I_Q.Emp_ID
	where E.Emp_ID=@Emp_ID	
	
	select @Eligibility_Limit = isnull(Optional_allow_per,0)
	 from T0040_DESIGNATION_MASTER WITH (NOLOCK) where Desig_ID=@desig_ID and Cmp_ID=@cmp_ID
	 
	 select @Grd_Eligibility_Limit = isnull(Eligibility_Amount,0)
	 from T0040_GRADE_MASTER WITH (NOLOCK) where Grd_ID=@grd_ID and Cmp_ID=@cmp_ID
	 
	
	
    if isnull(@Grd_Eligibility_Limit,0) =0
    begin	
		select Ad_ID,Ad_Name,0 as AR_AppDetail_ID,AD_MODE ,isnull(AD_PERCENTAGE,0.00)AD_PERCENTAGE,isnull(AD_AMOUNT,0.00)AD_AMOUNT,Ad_Flag,	
                                               isnull(AD_MAX_LIMIT,0.0)AD_MAX_LIMIT_NotNull,'' as Comments,
                                               Grd_ID,
                                               Emp_Full_Name_new,
                                               cast(ROUND((@Basic_Salary *   (@Eligibility_Limit/100)),0) AS decimal(7,2)) as Eligibility_Amount,
                                               Cmp_ID,Emp_ID,
                                               AD_CALCULATE_ON,
                                               AD_Code,Allowance_Type 
                                               from VOptionalAllowanceGradewise
                     where Emp_id =@Emp_ID  and cmp_id=@Cmp_ID and Is_Optional = 1 order by Ad_ID
	end
	else
	BEGIN
	
	select Ad_ID,Ad_Name,0 as AR_AppDetail_ID,AD_MODE ,isnull(AD_PERCENTAGE,0.00)AD_PERCENTAGE,isnull(AD_AMOUNT,0.00)AD_AMOUNT,Ad_Flag,	
                                               isnull(AD_MAX_LIMIT,0.0)AD_MAX_LIMIT_NotNull,'' as Comments,
                                               Grd_ID,
                                               Emp_Full_Name_new,
                                               @Grd_Eligibility_Limit as Eligibility_Amount,
                                               Cmp_ID,Emp_ID,
                                               AD_CALCULATE_ON,
                                               AD_Code,Allowance_Type 
                                               from VOptionalAllowanceGradewise
                     where Emp_id =@Emp_ID  and cmp_id=@Cmp_ID and Is_Optional = 1 order by Ad_ID
	
	end
 RETURN

