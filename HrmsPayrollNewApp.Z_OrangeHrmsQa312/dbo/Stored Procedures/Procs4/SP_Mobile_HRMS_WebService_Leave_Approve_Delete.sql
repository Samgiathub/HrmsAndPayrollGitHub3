CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Leave_Approve_Delete]
	@Emp_ID NUMERIC(18,0),
	@Cmp_ID NUMERIC(18,0),
	@Leave_Application_ID NUMERIC(18,0),
	@Approval_Date datetime,
	@Approval_Status varchar(15),
	@Is_BackDated_app int,
	@SEmp_ID int,
	@User_Id varchar(15),
	@Login_ID numeric(18,0),
	@tran_type Char(1),
	@Result varchar(255) OUTPUT
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @System_Date DATETIME
DECLARE @RowID numeric(18,0)
DECLARE @Tran_ID numeric(18,0)
DECLARE @Flag int
DECLARE @DeviceID  NVARCHAR(MAX)
SET @DeviceID = ''

IF  @tran_type='D'
	begin
	
	declare @p1 int set @p1=@Leave_Application_ID exec P0120_LEAVE_APPROVAL @Leave_Approval_ID=@Leave_Application_ID ,@Leave_Application_ID=0,@Cmp_ID=0
		,@Emp_ID=0,@S_Emp_ID=0,@Approval_Date=@Approval_Date,@Approval_Status=@Approval_Status,@Approval_Comments='',@Login_ID=@Login_ID,@System_Date= ''
		,@tran_type=@tran_type,@User_Id=@User_Id,@IP_Address='Mobile',@Is_Backdated_App=0 

		if @p1!=0
		begin
		Select 'Leave Application Deleted'
		end





					--declare curLeave cursor Fast_forward for                    
					--select leave_approval_id from T0120_LEAVE_APPROVAL WITH (NOLOCK) where Leave_Approval_ID = @Leave_Application_ID 
					--open curLeave
					--fetch next from curLeave into @leave_approval_id
					--while @@fetch_status = 0      
					--begin
					
					--	exec P0120_LEAVE_APPROVAL @Leave_Approval_ID=@Leave_Application_ID output,@Leave_Application_ID=0,@Cmp_ID=0,@Emp_ID=0,@S_Emp_ID=0,@Approval_Date = '',@Approval_Status='',@Approval_Comments='',@Login_ID=0,@System_Date = '',@tran_type='Delete'
						
					--	fetch next from curLeave into @leave_approval_id
					--end                    
					--close curLeave                    
					--deallocate curLeave

					--Select 'Deleted '
	end
