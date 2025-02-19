
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_UNIFORM_RECORD_GET]
	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME 
	,@Branch_ID		NUMERIC   = 0
	,@Cat_ID		VARCHAR(MAX) = '' 
	,@Grd_ID		VARCHAR(MAX) = '' 
	,@Type_ID		NUMERIC  = 0
	,@Dept_ID		VARCHAR(MAX) = '' 
	,@Desig_ID		VARCHAR(MAX) = '' 
	,@Emp_ID		NUMERIC  = 0
	,@Constraint	VARCHAR(MAX) = ''
	,@Salary_Status	VARCHAR(10)='All'
	,@Salary_Cycle_id  NUMERIC  = 0
	,@Branch_Constraint VARCHAR(MAX) = '' 
	,@Segment_ID VARCHAR(MAX) = '' 
	,@Vertical VARCHAR(MAX) = '' 
	,@SubVertical VARCHAR(MAX) = '' 
	,@subBranch VARCHAR(MAX) = '' 
	,@Uniform_id numeric(18,0) = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Dept_ID='0' 
		set @Dept_ID=null	             
 
	IF @Vertical='0' 
		set @Vertical=null	

	IF @SubVertical='0' 
		set @SubVertical=null	
	
	IF @Branch_Constraint='0' 
		set @Branch_Constraint=null	
		
	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)  
	
	IF @Constraint <> ''
		Begin		
			INSERT INTO #Emp_Cons
			SELECT cast(data  as numeric),0,0 FROM dbo.Split(@Constraint,'#') T  
		End
	Else
		Begin
			EXEC SP_EMP_SALARY_Constraint @Cmp_ID, @From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID	,@Desig_ID,@Emp_ID,@Salary_Cycle_id ,@Branch_Constraint,@Segment_ID,@Vertical,@SubVertical,@subBranch,@Constraint	-- Changed By Gadriwala 11092013
		End
	--select * from #Emp_Cons
	Declare @Uni_Rate Numeric(18,2)
	Declare @Uni_Deduct_Installment Numeric(18,0)
	Declare @Uni_Refund_Installment Numeric(18,0)
	
	Set	@Uni_Rate = 0
	Set @Uni_Deduct_Installment = 0
	Set @Uni_Refund_Installment = 0
	
	Select @Uni_Rate = Uni_Rate,@Uni_Refund_Installment = UMD.Uni_Refund_Installment,@Uni_Deduct_Installment=UMD.Uni_Deduct_Installment  
	From V0050_Uniform_Master_Detail UMD
	Where UMD.Uni_ID = @Uniform_id and UMD.Cmp_Id = @Cmp_ID
		
	Select EM.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,@Uni_Rate as Uni_Rate,
	@Uni_Deduct_Installment as Uni_Ded_Install,@Uni_Refund_Installment as Uni_Ref_Install
	,0 as Uni_Pieces,0.00 as Uni_Amount --added by mansi
	
	From #Emp_Cons EC Inner JOIN T0080_Emp_Master EM WITH (NOLOCK)
	ON EM.Emp_ID = EC.Emp_ID	
		  
	RETURN
