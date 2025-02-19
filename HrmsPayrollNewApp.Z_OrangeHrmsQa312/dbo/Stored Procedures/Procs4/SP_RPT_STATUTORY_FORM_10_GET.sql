

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_FORM_10_GET]
 @Cmp_ID 	numeric
,@From_Date 	datetime
,@To_Date 	datetime
,@Branch_ID 	numeric
,@Cat_ID 	numeric 
,@Grd_ID 	numeric
,@Type_ID 	numeric
,@Dept_ID 	numeric
,@Desig_ID 	numeric
,@Emp_ID 	numeric
,@constraint 	varchar(max)

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @PF_DEF_ID		numeric 
	set @PF_DEF_ID =2
		
	
	
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

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join T0080_Emp_master e WITH (NOLOCK) on I.Emp_ID = E.Emp_ID inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where I.Cmp_ID = @Cmp_ID 
			and Isnull(I.Cat_ID,0) = Isnull(@Cat_ID ,Isnull(I.Cat_ID,0))
			and I.Branch_ID = isnull(@Branch_ID ,I.Branch_ID)
			and I.Grd_ID = isnull(@Grd_ID ,I.Grd_ID)
			and isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))
			and Isnull(I.Type_ID,0) = isnull(@Type_ID ,Isnull(I.Type_ID,0))
			and Isnull(I.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I.Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and not Emp_Left_Date is null
		end
		 
		
		DECLARE @COUNT AS INTEGER
		 
			Select @count = COUNT(*)
			FROM 
			( SELECT e.Emp_ID
				From T0080_Emp_Master e WITH (NOLOCK) inner join @Emp_Cons ec on e.emp_ID = ec.emp_ID inner join T0100_Left_emp LE WITH (NOLOCK) on
				 ec.Emp_ID =LE.Emp_ID inner join 
				 T0010_Company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_ID Inner join
					(Select min(for_date) as for_date,emp_id from t0050_ad_master AM  WITH (NOLOCK)
						inner join T0100_EMP_EARN_DEDUCTION eed WITH (NOLOCK) on am.ad_id = eed.ad_id where ad_def_id = 2 
					group by emp_id) Qry on E.Emp_Id = Qry.Emp_Id
				Where Emp_Left_Date >= @From_Date and Emp_Left_Date <= @To_Date
					and e.cmp_Id= @Cmp_ID
			
			UNION
			
			SELECT e.Emp_ID
				From T0080_Emp_Master e WITH (NOLOCK) inner join @Emp_Cons ec on e.emp_ID = ec.emp_ID inner join T0100_Left_emp LE WITH (NOLOCK) on
				 ec.Emp_ID =LE.Emp_ID inner join 
				 T0010_Company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_ID Inner join
					(Select min(for_date) as for_date,emp_id from t0050_ad_master AM WITH (NOLOCK)
						inner join T0110_EMP_EARN_DEDUCTION_REVISED eed WITH (NOLOCK) on am.ad_id = eed.ad_id where ad_def_id = 2 
					group by emp_id) Qry on E.Emp_Id = Qry.Emp_Id
				Where Emp_Left_Date >= @From_Date and Emp_Left_Date <= @To_Date
					and e.cmp_Id= @Cmp_ID
					
					
			)	qrcou
				
			if @count > 0 -- condition added by mitesh on 09/03/2012 for form 10 with Nill submission.
				begin
						SELECT DISTINCT * FROM 
						(
						Select ISNULL(EmpName_Alias_PF,Emp_Full_Name) as Emp_Full_Name,Emp_Code,Date_of_Join,Father_Name,Emp_Second_Name ,DBO.F_GET_AGE (Date_of_Birth,getdate(),'Y','N')as Age  
								,Marital_Status,E.Emp_ID,Emp_LefT_Date,Date_of_Birth,Gender
								,SSN_No as PF_No
								,Cmp_NAme,Cmp_Address,LE.Left_Reason
								,@From_Date P_From_Date ,@To_Date P_To_Date,cm.PF_No as cmp_pf_no
								,E.Emp_First_Name,E.Alpha_Emp_Code        --added jimit 17062015
						From T0080_Emp_Master e WITH (NOLOCK) inner join @Emp_Cons ec on e.emp_ID = ec.emp_ID inner join T0100_Left_emp LE WITH (NOLOCK) on
						 ec.Emp_ID =LE.Emp_ID inner join 
						 T0010_Company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_ID Inner join
							(Select min(for_date) as for_date,emp_id from t0050_ad_master AM WITH (NOLOCK)
								inner join T0100_EMP_EARN_DEDUCTION eed WITH (NOLOCK) on am.ad_id = eed.ad_id where ad_def_id = 2 
							group by emp_id) Qry on E.Emp_Id = Qry.Emp_Id
						Where Emp_Left_Date >= @From_Date and Emp_Left_Date <= @To_Date
							and e.cmp_Id= @Cmp_ID
						
						UNION 
						
						Select ISNULL(EmpName_Alias_PF,Emp_Full_Name) as Emp_Full_Name,Emp_Code,Date_of_Join,Father_Name,Emp_Second_Name ,DBO.F_GET_AGE (Date_of_Birth,getdate(),'Y','N')as Age  
								,Marital_Status,E.Emp_ID,Emp_LefT_Date,Date_of_Birth,Gender
								,SSN_No as PF_No
								,Cmp_NAme,Cmp_Address,LE.Left_Reason
								,@From_Date P_From_Date ,@To_Date P_To_Date,cm.PF_No as cmp_pf_no
								,E.Emp_First_Name,E.Alpha_Emp_Code        --added jimit 17062015
						From T0080_Emp_Master e WITH (NOLOCK) inner join @Emp_Cons ec on e.emp_ID = ec.emp_ID inner join T0100_Left_emp LE WITH (NOLOCK) on
						 ec.Emp_ID =LE.Emp_ID inner join 
						 T0010_Company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_ID Inner join
							(Select min(for_date) as for_date,emp_id from t0050_ad_master AM WITH (NOLOCK)
								inner join T0110_EMP_EARN_DEDUCTION_REVISED eed WITH (NOLOCK) on am.ad_id = eed.ad_id where ad_def_id = 2 
							group by emp_id) Qry on E.Emp_Id = Qry.Emp_Id
						Where Emp_Left_Date >= @From_Date and Emp_Left_Date <= @To_Date
							and e.cmp_Id= @Cmp_ID
						) qry
				end
			else
				begin
						Select 'Nil' as Emp_Full_Name, '' as Emp_Code,'' as Date_of_Join,'' as Father_Name,'' as Emp_Second_Name , '' as Age  
								,'' as Marital_Status,'' as Emp_ID, '' as Emp_LefT_Date,'' as Date_of_Birth,'' as Emp_ID,'' as Gender,'' as Marital_Status
								,'' as PF_No
								,Cmp_NAme,Cmp_Address,'' as Left_Reason
								,@From_Date P_From_Date ,@To_Date P_To_Date,cm.PF_No as cmp_pf_no
								,'' as Emp_First_Name,'' as Alpha_Emp_Code     --added jimit 17062015
						From 
							 T0010_Company_Master cm WITH (NOLOCK)
						Where 
							cm.cmp_Id= @Cmp_ID
				end
				
				
		--Select Emp_Full_Name,Emp_Code,Date_of_Join,Father_Name,Emp_Second_Name ,DBO.F_GET_AGE (Date_of_Birth,getdate(),'Y','N')as Age  
		--		,Marital_Status,E.Emp_ID,Emp_LefT_Date,Date_of_Birth,e.Emp_ID,Gender,Marital_Status
		--		,SSN_No as PF_No
		--		,Cmp_NAme,Cmp_Address,LE.Left_Reason
		--		,@From_Date P_From_Date ,@To_Date P_To_Date,cm.PF_No as cmp_pf_no
		--From T0080_Emp_Master e inner join @Emp_Cons ec on e.emp_ID = ec.emp_ID inner join T0100_Left_emp LE on
		-- ec.Emp_ID =LE.Emp_ID inner join 
		-- T0010_Company_Master cm on e.cmp_ID = cm.cmp_ID Inner join
		--	(Select min(for_date) as for_date,emp_id from t0050_ad_master AM 
		--		inner join T0100_EMP_EARN_DEDUCTION eed on am.ad_id = eed.ad_id where ad_def_id = 2 
		--	group by emp_id) Qry on E.Emp_Id = Qry.Emp_Id
		--Where Emp_Left_Date >= @From_Date and Emp_Left_Date <= @To_Date
		--	and e.cmp_Id= @Cmp_ID
			
RETURN




