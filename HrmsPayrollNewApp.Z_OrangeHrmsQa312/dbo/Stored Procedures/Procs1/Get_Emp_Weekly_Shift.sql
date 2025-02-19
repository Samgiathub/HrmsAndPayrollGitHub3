




--Alpesh 17-Aug-2012
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Emp_Weekly_Shift]
   
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Week_St_Date  datetime 
	,@Branch_ID		numeric = 0
	,@Cat_ID		numeric = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric = 0
	,@Dept_ID		numeric = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric = 0
	,@Constraint	varchar(5000) = ''
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
		
	Declare @Cur_EmpId numeric
	Declare @Cur_CmpId numeric
	Declare @tmp_Date datetime
	Declare @Week_End_Date datetime
	Declare @Month_St_Date datetime
	Declare @i int
	Declare @qry nvarchar(max)
	Declare @qry2 nvarchar(max)
	
	
	Set @tmp_Date = @Week_St_Date
	Set @Week_End_Date = DATEADD(d,6,@Week_St_Date)
	
	CREATE table #Weekly_Shift
	(
		Emp_ID	numeric		
	)
	
	
	Declare @Emp_Cons Table
		(
			Emp_ID	numeric
		)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else if @Emp_ID > 0
		begin
			Insert Into @Emp_Cons values (@Emp_ID)
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
				or @To_Date >= left_date  and  @From_Date <= left_date) 	
		End
		
	  
		Insert Into #Weekly_Shift(Emp_ID)
		Select Emp_ID from @Emp_Cons order by Emp_ID	
	  
	    	    
	   
		While @tmp_Date <= @Week_End_Date
			Begin
				---- Add Date as a column name
				Set @qry = 'CREATE table #Weekly_Shift ADD '+ replace(CONVERT(VARCHAR(11), @tmp_Date, 100),' ','_') +' varchar(10)'
				exec (@qry)
				set @qry = ''								
				
				--- Set Shift for @tmp_Date
				Set @qry = 'Update #Weekly_Shift Set '+ replace(CONVERT(VARCHAR(11), @tmp_Date, 100),' ','_') +'= isnull(Shift_ID,0) from #Weekly_Shift w inner join 
				(Select Emp_ID,Shift_ID from T0100_EMP_SHIFT_DETAIL s WITH (NOLOCK) Where For_Date='''+ CAST(@tmp_Date as varchar(11)) +''') qry on qry.Emp_ID = w.Emp_ID'  
									
				exec (@qry)
				set @qry=''
			
				--- Set Week Off, Alternate Full/Half Week Off
				Set @Month_St_Date = dbo.GET_MONTH_ST_DATE(MONTH(@tmp_Date),YEAR(@tmp_Date))
				
				Set @qry2 = 'Update #Weekly_Shift Set '+ replace(CONVERT(VARCHAR(11), @tmp_Date, 100),' ','_') +'=9999 from #Weekly_Shift w inner join 
				(Select Emp_ID,For_Date from T0100_WEEKOFF_ADJ WITH (NOLOCK) where Cmp_ID='+ CAST(@Cmp_ID as varchar) +' and 
				(
				  CHARINDEX(DATENAME(DW,'''+ CAST(@tmp_Date as varchar(11)) +'''),replace(Weekoff_Day,Alt_W_Name,''''))>0 
					or 
				 (CHARINDEX(DATENAME(DW,'''+ CAST(@tmp_Date as varchar(11)) +'''),Alt_W_Name)>0 and CHARINDEX(cast(DATEPART(wk,'''+ CAST(@tmp_Date as varchar(11)) +''') - DATEPART(wk,'''+ CAST(@Month_St_Date as varchar(11)) +''') + (case when DATENAME(dw,'''+ CAST(@tmp_Date as varchar(11)) +''')=''Sunday'' then 0 else 1 end) as varchar),Alt_W_Full_Day_Cont)>0)
					or 
				 (CHARINDEX(DATENAME(DW,'''+ CAST(@tmp_Date as varchar(11)) +'''),Alt_W_Name)>0 and CHARINDEX(cast(DATEPART(wk,'''+ CAST(@tmp_Date as varchar(11)) +''') - DATEPART(wk,'''+ CAST(@Month_St_Date as varchar(11)) +''') + (case when DATENAME(dw,'''+ CAST(@tmp_Date as varchar(11)) +''')=''Sunday'' then 0 else 1 end) as varchar),Alt_W_Half_Day_Cont)>0)
				) and For_Date>='''+ CAST(@Week_St_Date as varchar(11)) +''' and For_Date<='''+ CAST(@Week_End_Date as varchar(11)) +''') qry on qry.Emp_ID = w.Emp_ID'
												
				exec (@qry2)
				set @qry2 = ''
				
				--- Make Shift_ID Zero If Null
				Set @qry = 'Update #Weekly_Shift Set '+ replace(CONVERT(VARCHAR(11), @tmp_Date, 100),' ','_') +'= 0 Where '+ replace(CONVERT(VARCHAR(11), @tmp_Date, 100),' ','_') +' is null'
				exec(@qry)
				set @qry = ''
				
				Set @tmp_Date = DATEADD(d,1,@tmp_Date)					
			End		
			
						

		Select * from #Weekly_Shift
		
		Drop Table #Weekly_Shift

	RETURN




