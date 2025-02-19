
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_COPH_Avail_Balance] 
	 @Cmp_ID		Numeric
	,@To_Date		Datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	,@Default_Short_Name varchar(25)		
	,@Constraint	varchar(max)
AS
BEGIN

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
		
	Declare @Leave_ID numeric(18,0)
	set @Leave_ID = 0 
	
	select @leave_ID = leave_ID from dbo.T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and isnull(Default_Short_Name,'') = 'COPH'
	
	  CREATE table #Emp_Cons 
	  (
		  Emp_ID numeric ,  
		  Branch_ID numeric,
		  Increment_ID numeric    
	  )
	  exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@To_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,0,0,0,0,0,0,0,'0',0,0
	--if @Constraint <> ''
	--	begin
			
	--		Insert Into @Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
			
	--	end
	--else
	--	begin
	--		Insert Into @Emp_Cons
	--		select I.Emp_Id from dbo.T0095_Increment I inner join 
	--				( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment
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
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from dbo.T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @To_Date  >= join_Date  and  @To_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @To_Date <= left_date ) 
	--	end
		
		
		   create table #temp_COPH
		(
			Leave_opening	decimal(18,2),
			Leave_Used		decimal(18,2),
			Leave_Closing	decimal(18,2),
			Leave_Code		varchar(max),
			Leave_Name		varchar(max),
			Leave_ID		numeric,
			COPH_String  varchar(max) default null -- Added by Gadriwala 18022015
		)	
					
			CREATE TABLE #General_OT
			(
					Leave_Tran_ID			numeric,
					Cmp_ID					numeric,
					Emp_ID					numeric,
					For_Date				datetime,
					COPH_Credit			numeric(18,2),
					COPH_Debit			numeric(18,2),
					COPH_balance			numeric(18,2),
					Branch_ID				numeric,
					Is_COPH				numeric,
					COPH_Days_Limit		numeric,
					COPH_Type			varchar(4),					
					Selected			tinyint,
					Total_Balance		numeric(18,2)
			)
			
			
			declare @Comp_Emp_ID numeric(18,0)
			
								Declare curCOPHBalance  cursor fast_forward for
								 select Emp_ID from #Emp_Cons Order by Emp_ID  
									open curCOPHBalance  
										fetch next from curCOPHBalance into @Comp_Emp_ID  
											while @@fetch_status = 0  
												begin  
												    	
													Insert into #General_OT	
														exec GET_COPH_DETAILS @For_Date = @To_Date,@Cmp_ID = @Cmp_ID,@Emp_ID = @Comp_Emp_ID,@leave_ID = @leave_ID,@Leave_Application_ID = 0,@Exec_For = 0	
													
													fetch next from curCOPHBalance into @Comp_Emp_ID  
											   end   
									close curCOPHBalance  
									deallocate curCOPHBalance  	
									
					
			
	Select  E.Alpha_Emp_Code as Emp_code, E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
				, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,REPLACE(CONVERT(VARCHAR(11),@To_Date,103),' ','/') as P_From_date ,REPLACE(CONVERT(VARCHAR(11),@To_Date,103),' ','/') as P_To_Date ,BM.BRANCH_ID
				 , cm.cmp_name , cm.cmp_address,( GT.COPH_Days_Limit -  DATEDIFF(d,GT.For_date,@To_Date)) as Remain_Days, GT.COPH_Days_Limit,GT.COPH_Type, GT.COPH_Credit,GT.COPH_Debit,GT.COPH_balance,REPLACE(CONVERT(VARCHAR(11),GT.For_Date,103),' ','/') as For_Date,GT.Emp_ID,GT.Total_Balance
				,e.Emp_First_Name,TM.Type_Name     --added jimit 21052015
				from #General_OT  GT
				Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON GT.EMP_ID = E.EMP_ID
				INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Type_ID FROM dbo.T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
				E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
				dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
				dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
				dbo.T0040_TYPE_MASTER TM WITH (NOLOCK) ON Q_I.Type_Id = TM.Type_ID LEFT OUTER JOIN           --added jimit 10062015
				dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID   Inner join 
				dbo.T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.cmp_id = GT.cmp_id Inner join
				#Emp_Cons ec on ec.Emp_ID = GT.Emp_ID
				where GT.Cmp_ID = @Cmp_ID 
				Order by Emp_code,From_Date
				
				
END


