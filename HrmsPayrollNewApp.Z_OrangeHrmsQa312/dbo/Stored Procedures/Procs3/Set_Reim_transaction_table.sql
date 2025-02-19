

-- created by rohit for set leave transaction 
--exec Set_leave_transaction_table 1,0,3,'30-apr-2014'
-- note leave opening Should be not Entered between that period.
CREATE PROCEDURE [dbo].[Set_Reim_transaction_table]
 @Cmp_id_set  numeric(18,0) 
 ,@emp_id_Set numeric(18,0) 
 ,@Reim_id_set numeric(18,0) 
 ,@max_Date_Set datetime
AS 

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


Declare @Cmp_Id as numeric
Declare @Reim_Id as numeric
Declare @Temp_Max_Date as datetime
Declare @Pre_Closing as numeric(18,3)
Declare @Emp_Id as numeric
Declare @Chg_For_Date as Datetime
Declare @Chg_Tran_Id as numeric
Declare @Leave_Closing as numeric(18,3)
Declare @leave_Encash as numeric(18,3)
declare @emp_id_Cur2 as numeric(18,0)

if @Cmp_id_set=0 
begin 
set @Cmp_id_set = null
end

if @emp_id_Set=0
begin
	set @emp_id_Set = null
end

SEt @Reim_Id = @Reim_id_set
Set @Temp_Max_Date = @max_Date_Set


declare cur2 cursor for 
	Select Emp_id from dbo.t0080_emp_master WITH (NOLOCK) where Cmp_ID = isnull(@Cmp_id_set,cmp_id) and emp_id = Isnull(@emp_id_Set,Emp_ID) order by emp_id
open cur2
fetch next from cur2 into @emp_id_Cur2
while @@fetch_status = 0
begin

Set @Emp_Id = @emp_id_Cur2
Set @Leave_Closing = 0
Set @leave_Encash = 0

declare cur1 cursor for 
	Select reim_tran_id,For_Date,Emp_Id,reim_Closing from dbo.T0140_ReimClaim_Transacation WITH (NOLOCK) where rc_id = @Reim_Id and emp_id = Isnull(@emp_id,Emp_ID)
	and Cmp_ID = @Cmp_ID and for_date >= @Temp_Max_Date order by for_date
open cur1
fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date,@Emp_Id,@Leave_Closing
while @@fetch_status = 0
begin
		
	If exists(Select 1 from dbo.T0140_ReimClaim_Transacation WITH (NOLOCK) where RC_Id = @Reim_Id and emp_id = @emp_id 
		and Cmp_ID = @Cmp_ID and for_date < @Chg_For_Date)
		Begin
				Select @Pre_Closing = Reim_Closing from dbo.T0140_ReimClaim_Transacation WITH (NOLOCK) where rc_id = @Reim_Id and emp_id = @emp_id 
				and Cmp_ID = @Cmp_ID and for_date =
								(Select Max(For_Date) For_date from dbo.T0140_ReimClaim_Transacation WITH (NOLOCK) where rc_id = @Reim_Id and emp_id = @emp_id 
				and Cmp_ID = @Cmp_ID and for_date < @Chg_For_Date)
		
				update dbo.T0140_ReimClaim_Transacation set 
				Reim_Opening = @Pre_Closing
				,Reim_Closing = @Pre_Closing + (Isnull(Reim_Credit,0) + Isnull(Reim_Sett_CR_Amount,0)) - Reim_Debit
				where For_Date = @Chg_For_Date and emp_id = @Emp_Id and Rc_id = @Reim_Id

		End


	fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date,@Emp_Id,@Leave_Closing
end

close cur1
deallocate cur1	
	
	fetch next from cur2 into @emp_id_Cur2
end

close cur2
deallocate cur2
	
