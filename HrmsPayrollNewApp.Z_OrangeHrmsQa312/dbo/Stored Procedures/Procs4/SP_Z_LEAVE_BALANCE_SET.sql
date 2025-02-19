



---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Z_LEAVE_BALANCE_SET]
	@Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(max)
	,@Leave_ID		numeric
		
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

	if @Leave_ID = 0
		set @Leave_ID = null
		
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
					where Increment_Effective_date <= getdate()
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
		--	and I.Emp_ID in 
		--		( select Emp_Id from
		--		(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
		--		where cmp_ID = @Cmp_ID   and  
		--		(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
		--		or ( @To_Date  >= join_Date  and @To_Date <= left_date )
		--		or Left_date is null and @To_Date >= Join_Date)
		--		or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
		end
		
		

--	Begin Tran
	
	
	Declare @Leave_Closing	numeric(10,2)
	Declare @For_Date		datetime
	Declare @leave_Cf_Days	numeric(10,2)
	
	Update T0140_LEAVE_TRANSACTION
	set LeavE_Used = 0
	Where LeavE_Used < 0


	DECLARE CUR_EMP cursor for
		select lt.Emp_ID ,for_date , leave_ID from T0140_LEAVE_TRANSACTION  lt WITH (NOLOCK) inner join @Emp_Cons ec on lt.Emp_ID = ec.Emp_ID 
		Where Leave_ID = isnull(@Leave_ID,Leave_ID) and for_Date >=@From_Date
		order by lt.emp_ID , leave_ID ,For_date
	
	open cur_Emp
	fetch next from cur_emp into @emp_ID , @for_Date ,@Leave_ID
	while @@fetch_status =0
		begin
			Set   @Leave_Closing  = 0
			set   @leave_Cf_Days  = 0

		select @Leave_Closing = isnull(Leave_Closing,0) from 
				T0140_LEAVE_TRANSACTION LT	WITH (NOLOCK) Inner join 	( select Emp_ID,leave_ID,max(For_Date)For_Date from 
				T0140_LEAVE_TRANSACTION WITH (NOLOCK) where emp_id = @emp_ID and for_date <@For_date and leave_ID = @Leave_Id group by emp_ID,leave_ID)q on 
			lt.Emp_ID =q.Emp_ID and lt.LEave_ID =q.leave_ID and lt.For_Date =q.For_Date 
			Where lt.Emp_Id =@emp_ID and lt.leave_ID =@Leave_ID
				

	
			set @Leave_Closing = isnull(@Leave_Closing,0)



	 		select @leave_Cf_Days = CF_LEavE_Days From T0100_leave_CF_Detail WITH (NOLOCK) Where Emp_ID=@emp_ID and LEave_ID =@Leave_ID and CF_For_Date =@for_Date
	
			if exists (select emp_ID From T0095_Leave_Opening WITH (NOLOCK) Where Emp_ID = @Emp_ID and LEave_ID = @Leave_ID and For_Date = @For_Date )
			  Begin
				select @Leave_Closing = isnull(LeavE_Op_days,0) from T0095_Leave_Opening WITH (NOLOCK) where emp_id = @emp_ID and for_date = @For_date and leave_ID = @Leave_Id
				
				update  T0140_LEAVE_TRANSACTION
				set 	Leave_Opening = @Leave_Closing ,
					 Leave_Credit =  @leave_Cf_Days
				    	,Leave_Closing = @Leave_Closing + isnull(   @leave_Cf_Days   - ( isnull(Leave_Used,0)  - isnull(Leave_Adj_L_Mark,0)-isnull(LeavE_Posting,0)-isnull(Leave_Cancel,0)),0)
				where emp_ID = @Emp_id and leave_Id= @Leave_ID and For_Date = @For_date


			  End	
			else
			  begin
				

				update  T0140_LEAVE_TRANSACTION
				 set 	Leave_Opening = @Leave_Closing ,
					Leave_Credit = @leave_Cf_Days
			    	,Leave_Closing = @Leave_Closing + isnull(@leave_Cf_Days  - ( isnull(Leave_Used,0)  - isnull(Leave_Adj_L_Mark,0)-isnull(LeavE_Posting,0)-isnull(Leave_Cancel,0)),0)
				where emp_ID = @Emp_id and leave_Id= @Leave_ID and For_Date = @For_date
			  end			

				
			
			fetch next from cur_emp into @emp_ID , @for_Date ,@Leave_ID
		end
	
	close cur_emp
	deallocate cur_emp
	
	--Rollback Tran 


		
	RETURN




