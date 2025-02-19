



---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[IT_TaxPaid_Form16] 

	 @cmp_id				numeric
	,@From_Date				Datetime	
	,@To_Date				Datetime
	,@Branch_ID				numeric 	
	,@Grd_ID				numeric
	,@Type_ID				numeric
	,@Dept_ID				numeric
	,@Desig_Id				numeric
	,@Cat_ID 				numeric 
	,@Emp_ID				numeric
	,@Constraint			varchar(max)
	,@Product_ID			numeric
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Branch_ID = 0  
		set @Branch_ID = null		
	
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
		
	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Cat_ID = 0  
		set @Cat_ID = null

	Declare @Emp_Cons Table
	 (
		Emp_ID	numeric
	  )
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			Insert Into @Emp_Cons(Emp_ID)

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @cmp_id
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id	
							
			Where cmp_id = @cmp_id 
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 		
		end
		
		
		
	Select    Row_ID 	,FIELD_NAME,Amount_Col_Final,Tr.Emp_ID,isnull(Cheque_No,'-'),isnull(Bank_BSR_Code,'-'),Payment_Date,CIN_No , INC.Branch_ID
		From #Tax_Report tr 
	 inner Join @Emp_Cons EC on Tr.emp_Id = EC.emp_id
	 Left Outer Join	(Select Emp_Id,DateName(month,DateAdd(month,[Month],0)-1)MonthName,Cheque_No,Bank_BSR_Code,Payment_Date,CIN_No
		From T0220_TDS_CHALLAN TC WITH (NOLOCK) Inner Join T0230_TDS_Challan_Detail TDD WITH (NOLOCK) on TC.Challan_Id = TDD.Challan_Id) Qry on TR.Emp_Id = Qry.Emp_Id And TR.Field_name = Qry.MonthName
	
	inner JOIN (select I.Emp_Id , I.Branch_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id , Emp_ID From T0095_Increment WITH (NOLOCK)  --Changed by Hardik 10/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @cmp_id
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id	) as INC
	on inc.emp_id = tr.emp_id
	
		
	Where Is_TaxPaid_Rec =1
	order by tr.Emp_ID ,tr.Row_ID
	
RETURN




