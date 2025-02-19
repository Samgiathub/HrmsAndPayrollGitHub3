



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_DEFAULT_INOUT_INSERT]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   
	,@Cat_ID		numeric  
	,@Grd_ID		numeric 
	,@Type_ID		numeric 
	,@Dept_ID		numeric 
	,@Desig_ID		numeric 
	,@Emp_ID		numeric 
	,@Constraint	varchar(1000) = ''
	,@Ip_Address	varchar(15) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If @Branch_ID = 0
		set @Branch_ID = null
	If @Cat_ID = 0
		set @Cat_ID = null
		 
	If @Type_ID = 0
		set @Type_ID = null
	If @Dept_ID = 0
		set @Dept_ID = null
	If @Grd_ID = 0
		set @Grd_ID = null
	If @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
		
	Declare @For_Date datetime
	declare @In_Date as datetime
	declare @Out_Date as datetime
	declare @Shift_St_Time as varchar(10)
	declare @Shift_End_Time as varchar(10)
	declare @varShift_St_Date as varchar(22)
	declare @varShift_End_Date as varchar(22)
	declare @In_Duration as varchar(12)	
	Declare @IO_Tran_ID		numeric 
	
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
					I.Emp_ID = Qry.Emp_ID	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			
		end

		
		Declare Cur_emp Cursor For
			Select Emp_ID From @Emp_Cons
		open Cur_emp
		Fetch next from Cur_emp into @Emp_ID
		While @@Fetch_Status  =0
			Begin
				delete from T0150_EMP_INOUT_RECORD where emp_id = @emp_id AND For_date >= @From_Date and for_date <= @To_Date
				
				
								
				set @For_Date = @From_Date
				while @For_Date <= @To_Date
					begin
						EXEC SP_CURR_T0100_EMP_SHIFT_GET @EMP_ID,@CMP_ID,@FOR_DATE,@Shift_St_Time OUTPUT,@Shift_End_Time OUTPUT,@In_Duration OUTPUT
						SET @varShift_St_Date  = cast(@For_Date as varchar(11)) + ' ' + @Shift_St_Time 
						SET @varShift_End_Date = cast(@For_Date as varchar(11)) + ' ' + @Shift_End_Time 
						
						set @In_Date  = cast(@varShift_st_Date as datetime)
						set @Out_Date = cast(@varShift_End_Date as datetime)
						
						select  @IO_Tran_ID = Isnull(max(IO_Tran_ID),0) + 1 From T0150_EMP_INOUT_RECORD WITH (NOLOCK)
						Insert Into T0150_EMP_INOUT_RECORD (IO_Tran_ID,Emp_ID,Cmp_ID,For_Date,In_Time,Out_time,Duration,Ip_Address)
						values(@IO_Tran_ID,@emp_ID,@Cmp_ID,@for_Date,@In_Date,@Out_Date,@In_Duration,@Ip_Address)
						
						Set @For_Date = dateadd(d,1,@For_Date)
					end
				Fetch Next From Cur_emp into @Emp_ID
			End
		Close cur_emp
		Deallocate Cur_emp
		
		
		
	RETURN

/*
declare @Emp_Inout table
 ( 
	P_Id 	numeric IDENTITY (1,1) not null,
	emp_ID	numeric ,
	Cmp_Id	numeric ,
	For_Date	Datetime,
	In_Time		Datetime,
	Out_Time	datetime ,
	Duration	varchar(10)
 )

set nocount on 

Declare @for_Date datetime 
Declare @In_Time_str varchar(22)
Declare @out_Time_str varchar(22)
Declare @In_time datetime 
Declare @Out_time Datetime 

set @for_Date = '01-jan-2008'

while @For_Date <='31-dec-2008'
	begin
		set @In_Time_str = @for_Date + ' 10:00'
		set @out_Time_str = @for_Date + ' 18:00'
		set @In_Time = cast(@In_Time_Str as datetime)	
		set @Out_Time = cast(@Out_Time_Str as datetime)	

		insert into @Emp_inout(Emp_ID,Cmp_ID,For_date,In_time,Out_Time,Duration)
		select emp_ID,cmp_Id ,@for_date,@In_time,@Out_Time,'08:00' From T0080_emp_Master 
			where cmp_ID = 27
		
		print @for_Date
		set @For_Date =dateadd(d,1,@for_Date)
		
	end

Insert Into T0150_EMP_INOUT_RECORD (IO_Tran_ID,Emp_ID,Cmp_ID,For_Date,In_Time,Out_time,Duration,Ip_Address)
select P_ID + 13755,Emp_Id,Cmp_Id,For_Date,In_Time,Out_Time,Duration,'192.168.1.35' From @Emp_inout
*/ 




