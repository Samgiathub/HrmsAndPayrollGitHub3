

-- created by rohit for set leave transaction 
--exec Set_leave_transaction_table 1,0,3,'30-apr-2014'
-- note leave opening Should be not Entered between that period.
CREATE PROCEDURE [dbo].[Set_leave_transaction_table]
 @Cmp_id_set  numeric(18,0) 
 ,@emp_id_Set numeric(18,0) 
 ,@leave_id_set numeric(18,0) 
 ,@max_Date_Set datetime
AS  
        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

Declare @Cmp_Id as numeric
Declare @Leave_Id as numeric
Declare @Temp_Max_Date as datetime
Declare @Pre_Closing as numeric(18,3)
Declare @Emp_Id as numeric
Declare @Chg_For_Date as Datetime
Declare @Chg_Tran_Id as numeric
Declare @Leave_Closing as numeric(18,3)
Declare @leave_Encash as numeric(18,3)
declare @emp_id_Cur2 as numeric(18,0)
Declare @leave_posting as numeric(18,2)
declare @flag_leave_posting as tinyint
set @flag_leave_posting = 0

if @Cmp_id_set=0 
begin 
set @Cmp_id_set = null
end

if @emp_id_Set=0
begin
	set @emp_id_Set = null
end

SEt @leave_Id = @leave_id_set
Set @Temp_Max_Date = @max_Date_Set


declare cur2 cursor for 
	Select Emp_id,Cmp_id from dbo.t0080_emp_master WITH (NOLOCK) where Cmp_ID = isnull(@Cmp_id_set,cmp_id) and emp_id = Isnull(@emp_id_Set,Emp_ID) order by emp_id
open cur2
fetch next from cur2 into @emp_id_Cur2,@cmp_id
while @@fetch_status = 0
begin

Set @Emp_Id = @emp_id_Cur2
Set @Leave_Closing = 0
Set @leave_Encash = 0
set @leave_posting = 0




DECLARE cur1 CURSOR FOR 
SELECT	leave_tran_id,For_Date,Emp_Id,Leave_Closing,leave_encash_days,leave_posting 
FROM	dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK)
WHERE	leave_id = @leave_Id AND emp_id = IsNull(@emp_id,Emp_ID)
		AND Cmp_ID = @Cmp_ID AND for_date >= @Temp_Max_Date 
ORDER BY for_date
OPEN cur1

--SELECT * FROM dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE leave_id = @leave_Id and emp_id = @emp_id 
--			and Cmp_ID = @Cmp_ID and for_date < @Temp_Max_Date

--SELECT	*
--				FROM	dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK)
--				WHERE	leave_id = @leave_Id and emp_id = @emp_id AND Cmp_ID = @Cmp_ID 
--						AND for_date = (SELECT	MAX(For_Date) For_date 
--										FROM	dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK)
--										WHERE	leave_id = @leave_Id AND emp_id = @emp_id 
--												AND Cmp_ID = @Cmp_ID AND for_date < @Temp_Max_Date)




FETCH NEXT FROM cur1 into @Chg_Tran_Id,@Chg_For_Date,@Emp_Id,@Leave_Closing,@leave_Encash,@leave_posting
WHILE @@FETCH_STATUS = 0
	BEGIN
	
		IF EXISTS(SELECT 1 FROM dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE leave_id = @leave_Id and emp_id = @emp_id 
			and Cmp_ID = @Cmp_ID and for_date < @Chg_For_Date)
			BEGIN
				SELECT	@Pre_Closing = Leave_Closing 
				FROM	dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK)
				WHERE	leave_id = @leave_Id and emp_id = @emp_id AND Cmp_ID = @Cmp_ID 
						AND for_date = (SELECT	MAX(For_Date) For_date 
										FROM	dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK)
										WHERE	leave_id = @leave_Id AND emp_id = @emp_id 
												AND Cmp_ID = @Cmp_ID AND for_date < @Chg_For_Date)
				
				UPDATE	dbo.T0140_LEAVE_TRANSACTION 
				SET		Leave_Opening = @Pre_Closing,
						Leave_Closing = CASE WHEN Leave_Posting IS NOT NULL THEN 0 ELSE @Pre_Closing + Leave_Credit - isnull(Leave_Used,0) - isnull(Leave_Encash_Days,0) - isnull(leave_posting,0) - isnull(Leave_Adj_L_Mark,0) - isnull(Back_Dated_Leave,0) - isnull(CF_Laps_Days,0) END
				WHERE	For_Date = @Chg_For_Date AND emp_id = @Emp_Id AND Leave_ID = @leave_id
			END
		FETCH NEXT FROM cur1 into @Chg_Tran_Id,@Chg_For_Date,@Emp_Id,@Leave_Closing,@leave_Encash,@leave_posting
	END

CLOSE cur1
DEALLOCATE cur1	
	fetch next from cur2 into @emp_id_Cur2,@cmp_id
end

close cur2
deallocate cur2
	
