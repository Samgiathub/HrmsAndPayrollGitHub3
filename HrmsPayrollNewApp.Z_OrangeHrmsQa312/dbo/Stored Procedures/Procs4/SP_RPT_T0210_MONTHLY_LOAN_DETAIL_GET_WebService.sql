


-- =============================================
-- Author:		Ripal Patel
-- Create date: 01-Oct-2014
-- Description:	<Description,,>
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_T0210_MONTHLY_LOAN_DETAIL_GET_WebService]
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
,@constraint 	varchar(MAX)
,@Sal_Type		numeric = 0
,@Loan_Id       numeric=0
,@Salary_Cycle_id numeric = 0
,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 24072013
,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 24072013
,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 24072013
,@SubBranch_Id numeric = 0 -- mitesh on 07082013
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

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
		
	If @Loan_Id =0 
		Set @Loan_Id= NULL	
		
	if @Segment_Id = 0 
		set @Segment_Id = null
		
	IF @Vertical_Id= 0 
		set @Vertical_Id = null
		
	if @SubVertical_Id = 0 
		set @SubVertical_Id= Null

	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )
   

insert into #Emp_Cons
EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 

Select LA.Loan_Apr_ID,LA.Loan_Apr_Date,LA.Emp_ID,E.alpha_Emp_code,E.Emp_Full_Name,LA.Loan_ID,
	   LOAN_NAME,LA.Loan_Apr_Amount,
	   LQry.Loan_Pay_Amount,(LA.Loan_Apr_Amount - LQry.Loan_Pay_Amount) as Loan_Closing
From T0120_LOAN_APPROVAL LA WITH (NOLOCK) INNER JOIN 
	 T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.LOAN_ID = LM.LOAN_ID  INNER JOIN  
	 T0080_EMP_MASTER E WITH (NOLOCK) on LA.emp_ID = E.emp_ID  inner join
	 #Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join
	(select LA.Emp_ID,LA.Loan_ID,LA.Loan_Apr_ID,sum(MLD.Loan_Pay_Amount) as Loan_Pay_Amount from 
				  T0120_LOAN_APPROVAL LA WITH (NOLOCK)  INNER JOIN 
				  T0210_MONTHLY_LOAN_PAYMENT MLD WITH (NOLOCK) ON LA.LOAN_APR_ID = MLD.LOAN_APR_ID 
		where LA.Cmp_ID = @Cmp_ID and MLD.Loan_Payment_Date <= @To_Date And LA.Emp_ID in(select Emp_ID from #Emp_Cons)
		group by LA.Cmp_ID,LA.Emp_ID,LA.Loan_Apr_ID,LA.Loan_ID) as LQry on LQry.Emp_ID = E.Emp_ID and LQry.Loan_ID = LA.Loan_ID and 
																		   LQry.Loan_Apr_ID = LA.Loan_Apr_ID

where  LA.Loan_ID = isnull(@Loan_Id,LA.Loan_ID)



	---- Changed By Ali 22112013 EmpName_Alias		
	--Select MLD.*,LA.Loan_Apr_Date,LA.Loan_Apr_No_of_Installment,LA.Loan_Apr_Installment_Amount,LA.Loan_Apr_Installment_Amount,E.Emp_Id,
	--	   ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Branch_Address,Comp_name,Grd_Name,EMP_CODE,Type_Name,Dept_Name,
	--	   Desig_Name,LOAN_NAME,Cmp_Name,Branch_Name,Loan_apr_amount,Loan_Apr_pending_amount,Cmp_Address,LQry.Loan_Closing ,
	--	   (Loan_apr_amount - LA.Loan_Apr_Installment_Amount - Loan_Apr_pending_amount) As Loan_Paid, BM.Branch_ID,E.alpha_Emp_code			
	--	 From dbo.T0210_MONTHLY_LOAN_PAYMENT MLD Inner join 
	--		  dbo.T0120_LOAN_APPROVAL LA ON MLD.LOAN_APR_ID = LA.LOAN_APR_ID INNER JOIN 
	--		  dbo.T0040_LOAN_MASTER LM ON LA.LOAN_ID = LM.LOAN_ID  INNER JOIN  
	--		  dbo.T0080_EMP_MASTER E on LA.emp_ID = E.emp_ID  Left outer  JOIN 
	--		  #Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join
	--				(
	--				select SUM(Loan_Pay_Amount) as loan_pay_amount,Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,T0120_LOAN_APPROVAL.Loan_Apr_Amount as Loan_amount ,
	--					(T0120_LOAN_APPROVAL.Loan_Apr_Amount-SUM(Loan_Pay_Amount)) as Loan_Closing
	--					from T0210_MONTHLY_LOAN_PAYMENT 
	--					inner join T0120_LOAN_APPROVAL on 
	--					T0210_MONTHLY_LOAN_PAYMENT.Loan_Apr_ID=T0120_LOAN_APPROVAL.Loan_Apr_ID
	--					where T0210_MONTHLY_LOAN_PAYMENT.Loan_Payment_Date <=@To_Date
	--					group by Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,T0120_LOAN_APPROVAL.Loan_Apr_Amount						
	--					)  as LQry on LQry.Emp_ID = ec.Emp_ID and LQry.Loan_ID = la.Loan_ID 
	--					and LQry.Loan_Apr_ID=mld.Loan_Apr_ID
						
	--	WHERE E.Cmp_ID = @Cmp_Id and Loan_payment_Date >=@From_Date and Loan_payment_Date <=@To_Date
	--			And Isnull(LM.Loan_Id,0) = isnull(@Loan_Id ,Isnull(LM.Loan_Id,0))
	--			and isnull(mld.Sal_Tran_ID,0) <> 0
	--	order by E.Emp_Id,LM.Loan_Id

END

