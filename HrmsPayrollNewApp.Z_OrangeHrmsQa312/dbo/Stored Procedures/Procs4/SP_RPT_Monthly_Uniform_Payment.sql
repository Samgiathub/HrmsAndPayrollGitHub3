

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_Monthly_Uniform_Payment]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	,@Constraint	varchar(MAX)
	,@Uniform_ID	Numeric
	,@type			Numeric--varchar(25)
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
	
	IF @Uniform_ID = 0  
		set @Uniform_ID = null
		
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
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment	
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
							
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
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
		end
						
		if @type = 0 -- for 'Uniform Wise'
			BEGIN
			
				select distinct UI.Uni_Apr_Id,Uni_Id,Uni_Name,UI.Alpha_Emp_Code,UI.Emp_Full_Name,Uni_Piece,Uni_Rate,Uni_Amount,
					--case when mp.Uni_Flag=0 then MP.Payment_Amount else 0 end as Deduct_Paid_Amount,
					--case when mp.Uni_Flag=1 then MP.Payment_Amount else 0 end as Refund_Paid_Amount,
					CM.Cmp_Name,CM.Cmp_Address,GM.Grd_Name,ui.Issue_Date,Isnull(ui.Uni_Ded_Install,0) as Uni_Ded_Install,
					Isnull(ui.Uni_Ref_Install,0) as Uni_Ref_Install,
					Dept_Name,DGM.Desig_Name,Branch_Name,Branch_address,type_Name,
					uni_deduct_amount as EMI_deduct,
					uni_refund_amount as EMI_refund_amt,
					isnull(UM.total_deduct_payment,0) as total_deduct_payment,
					isnull(UM1.total_refund_payment,0) as total_refund_payment,
					bm.Comp_Name,dgm.Desig_Dis_No,em.Emp_First_Name
				from V0100_Uniform_Emp_Issue UI
				inner join @Emp_cons ec on UI.Emp_ID = ec.emp_ID 
				inner join T0080_EMP_MASTER em WITH (NOLOCK) on  UI.emp_id = em.emp_id 
				inner join T0010_Company_Master CM WITH (NOLOCK) on UI.Cmp_ID= CM.CMP_ID
				left join T0210_Uniform_Monthly_Payment MP WITH (NOLOCK) on MP.Uni_Apr_Id= UI.Uni_Apr_Id and MP.Payment_Date >=@From_Date and  Payment_Date <=@To_Date 
				left join 
				(select sum(Payment_Amount)as total_deduct_payment,
					Emp_ID,Uni_Apr_Id from T0210_Uniform_Monthly_Payment WITH (NOLOCK)
					where Payment_Date >= @from_date  and Payment_Date <= @To_Date	and Cmp_ID = @Cmp_ID and Uni_Flag=0 group by emp_ID,Uni_Apr_Id)as UM 
					on UM.Emp_ID=MP.Emp_ID and um.Uni_Apr_Id=mp.Uni_Apr_Id		
				left join 
				(select sum(Payment_Amount)as total_refund_payment,
					Emp_ID,Uni_Apr_Id from T0210_Uniform_Monthly_Payment WITH (NOLOCK)
					where Payment_Date >= @from_date  and Payment_Date <= @To_Date	and Cmp_ID = @Cmp_ID and Uni_Flag=1 group by emp_ID,Uni_Apr_Id)as UM1 
					on UM1.Emp_ID=MP.Emp_ID and UM1.Uni_Apr_Id=MP.Uni_Apr_Id		
				inner join
				(select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
					on ec.Emp_ID = I_Q.Emp_ID  inner join
						T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)  ON I_Q.Dept_Id = DM.Dept_Id Inner join 
						T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  
				where UI.Cmp_ID = @Cmp_ID And Isnull(ui.Uni_Id,0) = isnull(@Uniform_ID ,Isnull(ui.Uni_Id,0))
				and MP.Payment_Date >=@From_Date and  Payment_Date <=@To_Date  
			END
		ELSE  -- for 'Employee Wise'
			BEGIN
				select distinct UI.Uni_Apr_Id,Uni_Id,Uni_Name,UI.Alpha_Emp_Code,UI.Alpha_Emp_Code + '-' + UI.Emp_Full_Name as Emp_Full_Name,Uni_Piece,Uni_Rate,Uni_Amount,
					--case when mp.Uni_Flag=0 then MP.Payment_Amount else 0 end as Deduct_Paid_Amount,
					--case when mp.Uni_Flag=1 then MP.Payment_Amount else 0 end as Refund_Paid_Amount,
					CM.Cmp_Name,CM.Cmp_Address,ui.Issue_Date,GM.Grd_Name,
					Dept_Name,DGM.Desig_Name,Branch_Name,Branch_address,type_Name,
					Isnull(ui.Uni_Ded_Install,0) as Uni_Ded_Install,
					Isnull(ui.Uni_Ref_Install,0) as Uni_Ref_Install,
					Isnull(uni_deduct_amount,0) as EMI_deduct,
					Isnull(uni_refund_amount,0) as EMI_refund_amt,
					Isnull(UM.total_deduct_payment,0) As total_deduct_payment,
					Isnull(UM1.total_refund_payment,0) As total_refund_payment,
					bm.Comp_Name,
					dgm.Desig_Dis_No,em.Emp_First_Name
				
				from V0100_Uniform_Emp_Issue UI
				inner join @Emp_cons ec on UI.Emp_ID = ec.emp_ID 
				inner join T0080_EMP_MASTER em WITH (NOLOCK) on  UI.emp_id = em.emp_id 
				inner join T0010_Company_Master CM WITH (NOLOCK) on UI.Cmp_ID= CM.CMP_ID
				left join T0210_Uniform_Monthly_Payment MP WITH (NOLOCK) on MP.Uni_Apr_Id= UI.Uni_Apr_Id and MP.Payment_Date >=@From_Date and  Payment_Date <=@To_Date 
				--left join 
				--(select case when Uni_Flag=0 then sum(Payment_Amount) else 0 end as total_deduct_payment,
				--	case when Uni_Flag=1 then sum(Payment_Amount) else 0 end as total_refund_payment,
				--	Emp_ID,Uni_Apr_Id from T0210_Uniform_Monthly_Payment
				--	where Payment_Date <= @To_Date	and Cmp_ID = @Cmp_ID group by emp_ID,Uni_Apr_Id,Uni_Flag)as UM 
				--	on UM.Emp_ID=MP.Emp_ID and um.Uni_Apr_Id=mp.Uni_Apr_Id		
				left join 
				(select sum(Payment_Amount)as total_deduct_payment,
					Emp_ID,Uni_Apr_Id from T0210_Uniform_Monthly_Payment WITH (NOLOCK)
					where Payment_Date >= @from_date  and Payment_Date <= @To_Date	and Cmp_ID = @Cmp_ID and Uni_Flag=0 group by emp_ID,Uni_Apr_Id)as UM 
					on UM.Emp_ID=MP.Emp_ID and um.Uni_Apr_Id=mp.Uni_Apr_Id		
				left join 
				(select sum(Payment_Amount)as total_refund_payment,
					Emp_ID,Uni_Apr_Id from T0210_Uniform_Monthly_Payment WITH (NOLOCK)
					where Payment_Date >= @from_date  and Payment_Date <= @To_Date	and Cmp_ID = @Cmp_ID and Uni_Flag=1 group by emp_ID,Uni_Apr_Id)as UM1 
					on UM1.Emp_ID=MP.Emp_ID and UM1.Uni_Apr_Id=MP.Uni_Apr_Id		
				inner join
				(select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	 
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
					on ec.Emp_ID = I_Q.Emp_ID  inner join
						T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
						T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  
				where UI.Cmp_ID = @Cmp_ID And Isnull(ui.Uni_Id,0) = isnull(@Uniform_ID ,Isnull(ui.Uni_Id,0))
				and MP.Payment_Date >=@From_Date and  Payment_Date <=@To_Date 
			END
	RETURN
	
















