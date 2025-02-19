

-- =============================================
-- Author:		Ripal Patel
-- Create date: 06 Jan 2013
-- Description:	<Description,,>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_EMP_ReimTransacation_RECORD_GET]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
	,@RC_ID			numeric(18,0) = 0
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
	If @Desig_ID = 0
		set @Desig_ID = null
				
	
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
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
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
				or @To_Date >= left_date and  @From_Date <= left_date ) 
			
		end
	
	IF @RC_ID  = 0 
	Begin
	
		SELECT LT.Reim_Tran_ID,LT.Emp_ID,AD.AD_NAME,LT.Reim_Opening,LT.Reim_Credit as Reim_Credit --LT.Reim_Credit + Isnull(LT.Reim_Sett_CR_Amount,0) as Reim_Credit, --Changed By Jimit 04092018
				,LT.Reim_Debit,LT.Reim_Closing,LT.For_Date,
				E.Emp_Full_Name, E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,
				BM.Comp_Name,BM.Branch_Address,Left_Reason,
				Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,
				Gender,@From_Date as From_Date ,@To_Date as To_Date,
				Cmp_Name,Cmp_Address,
				Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason
				,BM.Branch_ID --Added By Nimesh 11-Jul-2015 (To filter by multiple branch)
				,dgm.Desig_Dis_No,E.Enroll_No  --added jimit 29/09/2015				
		FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN 
			 T0050_AD_Master AD WITH (NOLOCK) ON LT.RC_ID = AD.AD_ID INNER JOIN
			 T0080_EMP_MASTER E WITH (NOLOCK) on LT.Emp_ID = E.Emp_ID INNER JOIN
			(select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
			   (select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
				where Increment_Effective_date <= @To_Date
				and Cmp_ID = @Cmp_ID
				group by emp_ID) Qry on
			 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID) I_Q 
			on E.Emp_ID = I_Q.Emp_ID LEFT OUTER JOIN
			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
			T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id LEFT OUTER JOIN
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID LEFT OUTER JOIN
			T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID 
						 
		WHERE --LT.EMP_ID in (select Emp_ID from T0120_RC_Approval where Apr_Date >= @From_Date and Apr_Date <= @To_Date And APR_Status=1) And
			  E.Emp_ID in (select Emp_ID From @Emp_Cons) AND
			  LT.FOR_DATE >= @From_Date AND LT.For_Date <= @To_Date
			  and AD.Allowance_Type = 'R'
		ORDER BY  LT.Emp_ID desc,LT.RC_ID,LT.For_Date
	End
	Else
	Begin
		SELECT LT.Reim_Tran_ID,LT.Emp_ID,AD.AD_NAME,LT.Reim_Opening,LT.Reim_Credit as Reim_Credit --LT.Reim_Credit + Isnull(LT.Reim_Sett_CR_Amount,0) as Reim_Credit --Changed By Jimit 04092018
				,LT.Reim_Debit,
			   LT.Reim_Closing,LT.For_Date,
				E.Emp_Full_Name, E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,
				BM.Comp_Name,BM.Branch_Address,Left_Reason,
				Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,
				Gender,@From_Date as From_Date ,@To_Date as To_Date,
				Cmp_Name,Cmp_Address,
				Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason
				,BM.Branch_ID --Added By Nimesh 11-Jul-2015 (To filter by multiple branch)
		FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN 
			 T0050_AD_Master AD WITH (NOLOCK) ON LT.RC_ID = AD.AD_ID INNER JOIN
			 T0080_EMP_MASTER E WITH (NOLOCK) on LT.Emp_ID = E.Emp_ID INNER JOIN
			(select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
			   (select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
				where Increment_Effective_date <= @To_Date
				and Cmp_ID = @Cmp_ID
				group by emp_ID) Qry on
			 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID) I_Q 
			on E.Emp_ID = I_Q.Emp_ID LEFT OUTER JOIN
			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
			T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id LEFT OUTER JOIN
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID LEFT OUTER JOIN
			T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID 
						 
		WHERE LT.RC_ID=@RC_ID AND
			  --LT.EMP_ID in (select Emp_ID from T0120_RC_Approval where Apr_Date >= @From_Date and Apr_Date <= @To_Date And APR_Status=1) And
			  E.Emp_ID in (select Emp_ID From @Emp_Cons) AND
			  LT.FOR_DATE >= @From_Date AND LT.For_Date <= @To_Date
			  and AD.Allowance_Type = 'R'
		ORDER BY  LT.Emp_ID desc,LT.RC_ID,LT.For_Date
	End
RETURN

--SELECT LT.Reim_Tran_ID,LT.Emp_ID,AD.AD_NAME,LT.Reim_Opening,LT.Reim_Credit,LT.Reim_Debit,
--		   LT.Reim_Closing,LT.For_Date,
--			E.Emp_Full_Name, E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,
--			BM.Comp_Name,BM.Branch_Address,Left_Reason,
--			Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,
--			Gender,@From_Date as From_Date ,@To_Date as To_Date,
--			Cmp_Name,Cmp_Address,cmp_logo,
--			Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason
				
--	FROM T0140_ReimClaim_Transacation LT INNER JOIN 
--		 T0050_AD_Master AD ON LT.RC_ID = AD.AD_ID INNER JOIN
--		 T0080_EMP_MASTER E on LT.Emp_ID = E.Emp_ID INNER JOIN
--		(select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I inner join 
--		   (select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
--			where Increment_Effective_date <= @To_Date
--			and Cmp_ID = @Cmp_ID
--			group by emp_ID) Qry on
--		 I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date) I_Q 
--		on E.Emp_ID = I_Q.Emp_ID LEFT OUTER JOIN
--		T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
--		T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
--		T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
--		T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id LEFT OUTER JOIN
--		T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
--		T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID LEFT OUTER JOIN
--		T0100_Left_Emp l on E.Emp_ID =  l.Emp_ID 
					 
--	WHERE LT.RC_ID=@RC_ID AND
--		  LT.EMP_ID in (select Emp_ID from T0120_RC_Approval where Apr_Date >= @From_Date and Apr_Date <= @To_Date And APR_Status=1) And
--		  E.Emp_ID in (select Emp_ID From @Emp_Cons) AND
--		  LT.FOR_DATE >= @From_Date AND LT.For_Date <= @To_Date
		  
--	ORDER BY  LT.Emp_ID desc,LT.Reim_Tran_ID
