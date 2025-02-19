


---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0120_AR_APPROVAL_DIRECT]        
    @AR_Apr_ID				numeric(18,0) output,
    @AR_App_ID				numeric(18,0) ,	
	@Cmp_ID					numeric(18,0) ,
	@Emp_ID					numeric(18,0) ,
	@Increment_Id			numeric(18,0) ,
	@For_Date				DateTime,
	@Eligibility_amount		numeric(18,2),
	@Total_Amount			numeric(18,2),
	@App_Status				numeric(2,0),
	@AR_ApplicationDetail	xml,	
	@UserID					numeric(18,0),
	@Tran_Type				CHAR(1),
	@AdminManager			int = 1,		-- 1-Admin 2-Manager
	@IP_Address varchar(30)= '' -- Add By Mukti 11072016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

-- Add By Mukti 11072016(start)
	declare @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''
-- Add By Mukti 11072016(end)

  IF @Tran_Type  = 'I'     
  BEGIN
  
		if @AdminManager = 2
		Begin
			if Exists(select * from T0100_AR_APPLICATION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and App_Status <> 2 and For_Date between 
						DATEADD(dd,0, DATEDIFF(dd,0, DATEADD( mm, -(((12 + DATEPART(m, getdate())) - 4)%12), getdate() ) - datePart(d,DATEADD( mm, -(((12 + DATEPART(m, getdate())) - 4)%12),getdate() ))+1 ) ) and 
						DATEADD(dd,-1,DATEADD(mm,12,DATEADD(dd,0, DATEDIFF(dd,0, DATEADD( mm, -(((12 + DATEPART(m, getdate())) - 4)%12), getdate() ) - datePart(d,DATEADD( mm, -(((12 + DATEPART(m, getdate())) - 4)%12),getdate() ))+1 ) ) ))
						)
				Begin
					set @AR_App_ID = 0
					return
				End
			else if Exists(select * from T0120_AR_Approval WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Apr_Status <> 2 and For_Date between 
						DATEADD(dd,0, DATEDIFF(dd,0, DATEADD( mm, -(((12 + DATEPART(m, getdate())) - 4)%12), getdate() ) - datePart(d,DATEADD( mm, -(((12 + DATEPART(m, getdate())) - 4)%12),getdate() ))+1 ) ) and 
						DATEADD(dd,-1,DATEADD(mm,12,DATEADD(dd,0, DATEDIFF(dd,0, DATEADD( mm, -(((12 + DATEPART(m, getdate())) - 4)%12), getdate() ) - datePart(d,DATEADD( mm, -(((12 + DATEPART(m, getdate())) - 4)%12),getdate() ))+1 ) ) ))
						)
					Begin
						set @AR_App_ID = 0
						return
					End
			Else IF exists(select 1 from T0100_AR_APPLICATION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and App_Status <> 2 and For_Date >= @For_Date)
					BEGIN
						set @AR_App_ID = 0
						return
					END
		End
		else if @AdminManager = 1
		Begin
			IF exists(select 1 from T0100_AR_APPLICATION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and App_Status = 0 and For_Date between 
						DATEADD(dd,0, DATEDIFF(dd,0, DATEADD( mm, -(((12 + DATEPART(m, getdate())) - 4)%12), getdate() ) - datePart(d,DATEADD( mm, -(((12 + DATEPART(m, getdate())) - 4)%12),getdate() ))+1 ) ) and 
						DATEADD(dd,-1,DATEADD(mm,12,DATEADD(dd,0, DATEDIFF(dd,0, DATEADD( mm, -(((12 + DATEPART(m, getdate())) - 4)%12), getdate() ) - datePart(d,DATEADD( mm, -(((12 + DATEPART(m, getdate())) - 4)%12),getdate() ))+1 ) ) ))
					)
					BEGIN
						set @AR_App_ID = 0
						return
					END
			Else IF exists(select 1 from T0100_AR_APPLICATION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and  App_Status <> 2 and For_Date = @For_Date)
					BEGIN
						set @AR_App_ID = 0
						return
					END
			Else IF exists(select 1 from T0120_AR_Approval WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and  Apr_Status <> 2 and For_Date = @For_Date)
					BEGIN
						set @AR_App_ID = 0
						return
					END
					
		End
		
		 select @Increment_Id = max(Increment_ID) from T0095_INCREMENT WITH (NOLOCK)
				where Cmp_id = @Cmp_ID and emp_id = @Emp_ID group by emp_id

		--Hardik 13/04/2016
		Declare @Increment_Eff_Date as datetime
		Set @Increment_Eff_Date = Cast('01-Apr-' + Cast(Year(Getdate()) As Varchar(4)) As Datetime)
		exec [dbo].[SP_INSERT_INCREMENT_AR_APPROVAL] @Cmp_ID, @Emp_ID,@Increment_Id,@Increment_Id Output, @Increment_Eff_Date
	  
		 SELECT @AR_Apr_ID = isnull(max(AR_Apr_ID),0)+1 from T0120_AR_Approval WITH (NOLOCK)
		 INSERT INTO T0120_AR_Approval 
			(AR_Apr_ID,Cmp_ID,Emp_ID,Increment_Id,For_Date,Eligibility_amount,Total_Amount,
			 Apr_Status,CreatedBy,DateCreated) 
		 Values 
			(@AR_Apr_ID,@Cmp_ID,@Emp_ID,@Increment_Id,@For_Date,@Eligibility_amount,@Total_Amount,
			 @App_Status,@UserID,Getdate())
		
		 EXEC P0130_AR_ApprovalDetail @AR_App_ID,@AR_Apr_ID,@Cmp_ID,@Emp_ID,@Increment_Id,@For_Date,@AR_ApplicationDetail,@Tran_Type,@UserID

		-- Add By Mukti 11072016(start)
			exec P9999_Audit_get @table = 'T0120_AR_Approval' ,@key_column='AR_Apr_ID',@key_Values=@AR_Apr_ID,@String=@String_val output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
		-- Add By Mukti 11072016(end)		
  End    
 
 Else if @Tran_Type = 'D'     
  BEGIN  

	declare @AR_APP_STATUS AS NUMERIC(18,0)
	
	select @AR_App_ID = AR_App_ID,@AR_APP_STATUS= Apr_Status,@Increment_Id = Increment_Id, @Emp_Id = Emp_ID 
	from T0120_AR_Approval WITH (NOLOCK) where AR_Apr_ID =@AR_Apr_ID AND Cmp_ID=@cMP_id 	
	
	IF @AR_APP_STATUS = 1 OR @AR_APP_STATUS = 2
	BEGIN		
		DECLARE @AR_AprDetaill_ID as numeric(18,2)
		
		if exists(select 1 from T0130_AR_Approval_DEtail WITH (NOLOCK) where AR_Apr_ID =@AR_Apr_ID AND Cmp_ID=@cMP_id)
		BEGIN		   				
			DELETE FROM T0130_AR_Approval_DEtail WHERE AR_Apr_ID=@AR_Apr_ID
		end
			DELETE FROM T0120_AR_Approval WHERE AR_Apr_ID =@AR_Apr_ID AND Cmp_ID=@cMP_id         
		UPDATE T0100_AR_Application SET APP_Status=0 WHERE AR_App_ID=@AR_App_ID AND CMP_ID=@CMP_id    
		
		--Hardik 14/04/2016
		If @Increment_Id>0
			Exec P0095_INCREMENT_DELETE @Increment_Id,@Emp_Id,@Cmp_ID
    END
  END
	exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Optional Allowance Approval',@OldValue,@Emp_ID,@UserID,@IP_Address,1
 RETURN




