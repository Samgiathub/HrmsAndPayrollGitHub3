




--zalak --28-sep-2010 fro table to handle common request of employee
-- status 0 -- Pending
-- status 1 -- done
-- status 2  -- cancel
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0090_Common_Request_Detail]
	 @request_id	numeric(18,0) output
	,@cmp_id		numeric(18,0)
	,@emp_login_id		numeric(18,0)
	,@request_type	varchar(100)
	,@request_date	datetime
	,@request_detail	varchar(500)
	,@status		int
	,@Login_id		numeric(18,0)
	,@feedback_detail varchar(500)
	,@tran_type		char(1)
	,@User_Id numeric(18,0) = 0 -- Add By Mukti 23102019
    ,@IP_Address varchar(50)= '' -- Add By Mukti 23102019
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 DECLARE @OldValue as varchar(max)
 SET @OldValue = ''
 Declare @String as varchar(max)
 SET @String=''	
	
	if @cmp_id =0 
	   set @cmp_id = null
	if @emp_login_id =0
	   set @emp_login_id = null
	if @Login_id = 0
	   set @Login_id = null
	         
	If @tran_type  = 'I'
		Begin
				If Exists(Select request_id From T0090_Common_Request_Detail WITH (NOLOCK) Where emp_login_id = @emp_login_id and request_type = @request_type and request_date=@request_date and Login_id=@Login_id)
				begin
					Select @request_id=request_id From T0090_Common_Request_Detail WITH (NOLOCK) Where emp_login_id = @emp_login_id and request_type = @request_type and request_date=@request_date and  Login_id=@Login_id
					Return 
				end
				
				select @request_id= Isnull(max(request_id),0) + 1 	From T0090_Common_Request_Detail WITH (NOLOCK)
				
				INSERT INTO T0090_Common_Request_Detail
				                      ( request_id
										,cmp_id
										,emp_login_id
										,request_type
										,request_date
										,request_detail
										,status
										,Login_id
										,feedback_detail
										,[User_Id]
										,IP_Address)
								VALUES  ( @request_id
										,@cmp_id
										,@emp_login_id
										,@request_type
										,@request_date
										,@request_detail
										,@status
										,@Login_id
										,@feedback_detail
										,@User_Id
										,@IP_Address)
	-- Add By Mukti 24102019(start)
				set @OldValue = 'New Value' + '#'+ 'request_id  :' +CAST(ISNULL( @request_id,'')AS VARCHAR(20)) 
										+ '#' + 'cmp_id :' + CAST(ISNULL( @cmp_id,'')AS VARCHAR(20)) + '#' 
										+ '#' + 'emp_login_id :' + CAST(ISNULL( @emp_login_id,'')AS VARCHAR(20)) + '#' 
										+ '#' + 'request_type :' + ISNULL( @request_type,'') + '#' 
										+ '#' + 'request_date :' + CAST(ISNULL( @request_date,'')AS VARCHAR(50)) + '#' 
										+ '#' + 'IP_Address :' + ISNULL( @IP_Address,'')										
	-- Add By Mukti 24102019(end)	    
		End
	Else if @Tran_Type = 'U'
		begin
				Update T0090_Common_Request_Detail
				set 
					request_detail=@request_detail
					,status=@status
				where request_id = @request_id
				
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From T0090_Common_Request_Detail Where request_id= @request_id
		end
  EXEC P9999_Audit_Trail @CMP_ID,@Tran_type,@request_type,@OldValue,@emp_login_id,@emp_login_id,@IP_Address,0
	RETURN




