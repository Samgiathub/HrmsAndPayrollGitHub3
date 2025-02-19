

CREATE PROCEDURE [dbo].[SP_RPT_COMPOFF_Avail_Balance] 
	 @Cmp_ID		Numeric
	,@To_Date		Datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	--,@Leave_ID		Numeric --commented by mansi 22-02-2022
	,@Constraint	varchar(max)
	,@Flag			bit = 'false' -- Added by nilesh patel for Compoff Popup Ess Side on 02082016
	,@Email_Flag    bit = 'false' -- Added by nilesh patel for Send Email of Laps Email Remainder on 09092016
	,@Admin_Flag    bit = 'false' -- Added by nilesh patel for Show Compoff Laps Details Admin Side
	,@Reminder_Days Numeric(3,0) = 0 -- Added by milesh patel for Show Compoff Laps Details base on remainder days
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
		
		declare @Leave_ID		Numeric--added by mansi
	----commented by mansi start 22-02-22
	set @Leave_ID = 0 
	
	select @leave_ID = leave_ID from dbo.T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and isnull(Default_Short_Name,'') = 'COMP'
	----commented by mansi end 22-02-22

	CREATE TABLE #Emp_Cons
		(
			Emp_ID	numeric
		)		
	if @Constraint <> ''
		begin
			
			Insert Into #Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
			
		end
	else
		begin
			Insert Into #Emp_Cons
			select I.Emp_Id from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
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
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from dbo.T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @To_Date  >= join_Date  and  @To_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @To_Date <= left_date ) 
		end
		

		   create table #temp_CompOff
		(
			Leave_opening	decimal(18,2),
			Leave_Used		decimal(18,2),
			Leave_Closing	decimal(18,2),
			Leave_Code		varchar(max),
			Leave_Name		varchar(max),
			Leave_ID		numeric,
			CompOff_String  varchar(max) default null -- Added by Gadriwala 18022015
		)	
					
			CREATE TABLE #General_OT
			(
					Leave_Tran_ID			numeric,
					Cmp_ID					numeric,
					Emp_ID					numeric,
					For_Date				datetime,
					CompOff_Credit			numeric(18,2),
					CompOff_Debit			numeric(18,2),
					CompOff_balance			numeric(18,2),
					Branch_ID				numeric,
					Is_CompOff				numeric,
					CompOff_Days_Limit		numeric,
					CompOff_Type			varchar(2),
					Total_Balance			numeric(18,2)
			)
			
			 
			
			declare @Comp_Emp_ID numeric(18,0)
			
			Declare curCompOffBalance  cursor fast_forward for 
				select Emp_ID from #Emp_Cons Order by Emp_ID  
			open curCompOffBalance  
			fetch next from curCompOffBalance into @Comp_Emp_ID  
			while @@fetch_status = 0  
				begin  
				 
					Insert into #General_OT	
					exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Comp_Emp_ID,@leave_ID,0,0,0	
				--	exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Comp_Emp_ID,@leave_ID,0,0,0	--commented by mansi 
									
					fetch next from curCompOffBalance into @Comp_Emp_ID  
				end   
			close curCompOffBalance  
			deallocate curCompOffBalance  	
									
							
	if @Flag = 'true'
		Begin
			Declare @Setting_Value tinyint
			Set @Setting_Value = 0 
			SELECT @Setting_Value = Setting_Value FROM T0040_SETTING WITH (NOLOCK) Where Cmp_Id =@Cmp_Id And Setting_Name='Show Comp-off Lapse Notification(ESS)'
			if @Setting_Value = 1 and @Email_Flag = 'false'
				Begin
					Select  E.Alpha_Emp_Code as Emp_code, E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
					,Branch_Name , Dept_Name ,Grd_Name , Desig_Name,REPLACE(CONVERT(VARCHAR(11),@To_Date,103),' ','/') as P_From_date ,REPLACE(CONVERT(VARCHAR(11),@To_Date,103),' ','/') as P_To_Date ,BM.BRANCH_ID
					,cm.cmp_name , cm.cmp_address,(GT.CompOff_Days_Limit -  DATEDIFF(d,GT.For_date,@To_Date)) as Remain_Days, GT.CompOff_Days_Limit,GT.CompOff_Type, GT.CompOff_Credit,GT.CompOff_Debit,GT.CompOff_balance,REPLACE(CONVERT(VARCHAR(11),GT.For_Date,103),' ','/') as For_Date,GT.Emp_ID,GT.Total_Balance
					,e.Emp_First_Name,TM.Type_Name,
					REPLACE(CONVERT(VARCHAR(11),Dateadd(d,GT.CompOff_Days_Limit,GT.For_Date),103),' ','/') as Due_Date
						 --added jimit 21052015
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
					where GT.Cmp_ID = @Cmp_ID and (GT.CompOff_Days_Limit -  DATEDIFF(d,GT.For_date,@To_Date)) >= 1 and (GT.CompOff_Days_Limit -  DATEDIFF(d,GT.For_date,@To_Date)) <= 10
					Order by Emp_code,From_Date
				End
			if @Email_Flag = 'true'
				Begin
				
					Insert INTO #Emp_Compoff_Details(Emp_ID,Cmp_ID,Emp_Code,Emp_Name,Designation,For_date,Balance,Due_Date,Remaining_Days)
					Select E.Emp_ID,E.Cmp_ID,E.Alpha_Emp_Code, E.Emp_Full_Name,Desig_Name,REPLACE(CONVERT(VARCHAR(11),GT.For_Date,103),' ','/') as For_Date,GT.CompOff_balance,REPLACE(CONVERT(VARCHAR(11),Dateadd(d,GT.CompOff_Days_Limit,GT.For_Date),103),' ','/'),(GT.CompOff_Days_Limit -  DATEDIFF(d,GT.For_date,@To_Date))
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
					where GT.Cmp_ID = @Cmp_ID and (GT.CompOff_Days_Limit -  DATEDIFF(d,GT.For_date,@To_Date)) >= 1 and (GT.CompOff_Days_Limit -  DATEDIFF(d,GT.For_date,@To_Date)) <= 10
					Order by Emp_code,From_Date
				End		
		End
	Else if @Flag = 'false' and @Admin_Flag = 'true'
		Begin
			
			Select  E.Alpha_Emp_Code as Emp_code, E.Emp_Full_Name as Emp_Full_Name ,Desig_Name,
					GT.CompOff_balance,REPLACE(CONVERT(VARCHAR(11),GT.For_Date,103),' ','/') as For_Date,
					REPLACE(CONVERT(VARCHAR(11),Dateadd(d,GT.CompOff_Days_Limit,GT.For_Date),103),' ','/') as Due_Date,
					(GT.CompOff_Days_Limit - DATEDIFF(d,GT.For_date,@To_Date)) as Remain_Days
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
				where GT.Cmp_ID = @Cmp_ID and ( GT.CompOff_Days_Limit -  DATEDIFF(d,GT.For_date,@To_Date)) = @Reminder_Days
				Order by Emp_code,From_Date	
		End
	Else
		Begin
			Select  E.Alpha_Emp_Code as Emp_code, E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
					,Branch_Name , Dept_Name ,Grd_Name , Desig_Name,REPLACE(CONVERT(VARCHAR(11),@To_Date,103),' ','/') as P_From_date ,REPLACE(CONVERT(VARCHAR(11),@To_Date,103),' ','/') as P_To_Date ,BM.BRANCH_ID
					,cm.cmp_name , cm.cmp_address,( GT.CompOff_Days_Limit -  DATEDIFF(d,GT.For_date,@To_Date)) as Remain_Days, GT.CompOff_Days_Limit,GT.CompOff_Type, GT.CompOff_Credit,GT.CompOff_Debit,GT.CompOff_balance,REPLACE(CONVERT(VARCHAR(11),GT.For_Date,103),' ','/') as For_Date,GT.Emp_ID,GT.Total_Balance
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
		End			
END


