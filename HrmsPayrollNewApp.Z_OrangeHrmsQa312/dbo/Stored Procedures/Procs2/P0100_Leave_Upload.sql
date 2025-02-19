


-- Created by rohit For Leave Upload From SAP to Payroll for Electrotherm
-- created Date 10062016
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_Leave_Upload]  
    @tran_id  numeric(18,0) output  
   ,@Cmp_ID   numeric(18,0)  
   ,@Emp_Code  varchar(100)  
   ,@leave_name varchar(500)  
   ,@month numeric(18,0)
   ,@year Numeric(18,0)
   ,@Opening Numeric(18,2)
   ,@Credit Numeric(18,2)
   ,@Debit Numeric(18,2)
   ,@Late_Adjust_leave Numeric(18,2)
   ,@Balance Numeric(18,2)
   ,@user_id Numeric(18,2)
   ,@Ip_Address nvarchar(max)
   ,@Modify_Date Datetime 
   ,@trans_Type char='I'	
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @leave_Id as numeric
	Declare @Emp_id as numeric
	declare @leave_tran_id as numeric(18,0)
	declare @leave_pre_closing as numeric(18,2)
	Declare @month_end_date as datetime
	set @month_end_date = dbo.GET_MONTH_END_DATE(@month,@year)
	--delete from T0080_Import_Log where Import_type='leave upload' and Cmp_Id = @Cmp_ID

if not Exists(select emp_id from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Emp_Code and Cmp_ID = @Cmp_ID )
begin
		Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Emp_Code,'Employee code not Exist',0,'Enter Proper Employee Code',GetDate(),'Leave Upload',0)						
		Return
end

if not Exists(select Leave_ID from T0040_LEAVE_MASTER WITH (NOLOCK) where leave_name = @leave_name and Cmp_ID = @Cmp_ID )
begin
		Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Emp_Code,'leave not Exist',0,'leave not Exist - ' + @leave_name + '' ,GetDate(),'Leave Upload',0)						
		Return
end


select @Emp_id = emp_id from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Emp_Code and Cmp_ID = @Cmp_ID 
select @leave_Id = Leave_ID from T0040_LEAVE_MASTER WITH (NOLOCK) where leave_name = @leave_name and Cmp_ID = @Cmp_ID 

if Exists(select emp_id from T0100_Leave_Upload WITH (NOLOCK) where emp_id = @Emp_id and leave_id = @leave_Id and MONTH=@month and YEAR=@year )
begin
	update T0100_Leave_Upload 
	set 
	Opening = @Opening
	,Credit =  @Credit
	,Debit = @Debit
	,Late_Adjust_leave = @Late_Adjust_leave
	,Balance = @Balance
	,user_id = @user_id
	,Ip_Address = @Ip_Address
	,Modify_Date = getdate()
	from T0100_Leave_Upload 
	where cmp_id = @Cmp_ID and emp_id = @Emp_id and leave_id = @leave_Id and MONTH=@month and YEAR=@year 
end
else
begin

	insert into T0100_Leave_Upload (cmp_id,Emp_id,leave_id,month,Year,Opening,Credit,Debit,Late_Adjust_leave,Balance,user_id,Ip_Address,Modify_Date)
	values(@Cmp_ID,@Emp_id ,@leave_Id,@month,@Year,@Opening,@Credit,@Debit,@Late_Adjust_leave,@Balance,@user_id,@Ip_Address,GETDATE())

end


if Exists(select * from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID=@Cmp_ID and emp_id = @Emp_id and Leave_ID=@leave_Id and For_Date = @month_end_date)
begin
	update T0140_LEAVE_TRANSACTION 
	set Leave_Credit = @Credit
		,Leave_Adj_L_Mark = @Late_Adjust_leave
	from T0140_LEAVE_TRANSACTION 
	where Cmp_ID=@Cmp_ID and emp_id = @Emp_id and Leave_ID=@leave_Id and For_Date = @month_end_date
end
else
begin

	select @leave_tran_id = isnull(MAX(Leave_Tran_ID),0) + 1 from T0140_LEAVE_TRANSACTION WITH (NOLOCK)

	set @leave_pre_closing = 0

	select top 1 @leave_pre_closing = isnull(Leave_Closing,0) from  T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_id and Leave_ID = @leave_Id and For_Date < = @month_end_date order by For_Date desc


	insert into T0140_LEAVE_TRANSACTION
	(Leave_Tran_ID,Cmp_ID,Leave_ID,Emp_ID,For_Date,Leave_Opening,Leave_Credit,Leave_Used,Leave_Closing,Leave_Posting,Leave_Adj_L_Mark,Leave_Cancel,Eff_In_Salary,Leave_Encash_Days,Comoff_Flag,Arrear_Used,Back_Dated_Leave,CompOff_Credit,CompOff_Debit,CompOff_Balance,CompOff_Used,Half_Payment_Days,CF_Laps_Days)
	values(@leave_tran_id,@Cmp_ID,@leave_Id,@Emp_id,@month_end_date,@leave_pre_closing,@Credit,0,(@leave_pre_closing + @Credit - @Late_Adjust_leave),0,@Late_Adjust_leave,0,0,0,0,0,0,0,0,0,0,0,0)


end
  exec Set_leave_transaction_table @cmp_id,@emp_id,@leave_id,@month_end_date

select @tran_id = tran_id from T0100_Leave_Upload WITH (NOLOCK) where 	 emp_id = @Emp_id and leave_id = @leave_Id and MONTH=@month and YEAR=@year 



 RETURN  
  
  
  

