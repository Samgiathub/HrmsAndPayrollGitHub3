


-- =============================================
-- Author:		Gadriwala Muslim
-- Create date: <07/09/2014>
-- Description:	COMP OFF DETAILS Reports
--	WITH HOLIDAY,WEEKDAY,WEEKOFF COMPOFF LIMIT
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_COMPOFF_DETAILS] 
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
	,@Default_Short_Name varchar(25) = 'COMP'
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

	Declare @Leave_ID  numeric(18,0)
	
	set @Leave_ID = 0 
	
	--select @leave_ID = leave_ID from T0040_LEAVE_MASTER where Cmp_ID = @Cmp_ID and isnull(Default_Short_Name,'') = 'COMP'
	select @leave_ID = leave_ID from T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and isnull(Default_Short_Name,'') = @Default_Short_Name
	CREATE table #Emp_Cons 
	  (
		  Emp_ID numeric ,  
		  Branch_ID numeric,
		  Increment_ID numeric    
	  )
	  exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@To_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,0,0,0,0,0,0,0,'0',0,0
	--Declare @Emp_Cons Table
	--	(
	--		Emp_ID	numeric
	--	)		
	--if @Constraint <> ''
	--	begin
			
	--		Insert Into @Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
			
	--	end
	--else
	--	begin
	--		Insert Into @Emp_Cons
	--		select I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
							
	--		Where Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @From_Date <= left_date ) 
	--	end
		
			
	Select  E.Alpha_Emp_Code as Emp_code, E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
				, bm.Branch_Name , Dept_Name ,Grd_Name , Desig_Name,REPLACE(CONVERT(VARCHAR(11),@From_Date,103),' ','/') as P_From_date ,REPLACE(CONVERT(VARCHAR(11),@To_Date,103),' ','/') as P_To_Date ,BM.BRANCH_ID
				 , cm.cmp_name , cm.cmp_address
				, REPLACE(CONVERT(VARCHAR(11),VL.Application_Date,103),' ','/') as Application_Date ,REPLACE(CONVERT(VARCHAR(11),VL.Approval_date,103),' ','/') as Approval_date ,REPLACE(CONVERT(VARCHAR(11),VL.From_Date,103),' ','/') as From_Date ,REPLACE(CONVERT(VARCHAR(11),VL.To_Date,103),' ','/') as To_Date , VL.Leave_Period ,Leave_CompOff_Dates 
				,@Default_Short_Name as LeaveName
				from V0120_LEAVE_APPROVAL VL 
				Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON VL.EMP_ID = E.EMP_ID
				INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM dbo.T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
				E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
				dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
				dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
				dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID   Inner join 
				T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.cmp_id = VL.cmp_id Inner join
				#Emp_Cons ec on ec.Emp_ID = VL.Emp_ID 
				
				where Leave_ID = @leave_ID and 
				--Approval_Date >= @From_Date and 
				--Approval_Date <= @To_Date and 
				VL.From_Date >= @From_Date and 
				VL.To_Date <= @To_Date and 
				VL.Cmp_ID = @Cmp_ID and Approval_Status ='A' 
				
				Order by Emp_code,Approval_Date,From_Date
				
				
END

