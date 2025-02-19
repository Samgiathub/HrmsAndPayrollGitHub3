

-- =============================================
-- Author:		<Jaina>
-- Create date: <11-04-2018>
-- Description:	<Authorized Signature For Id Card Report>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0095_AUTHORIZED_SIGNATURE]
	 @Tran_ID numeric(18,0)
	,@Cmp_ID numeric(18,0)
	,@Emp_ID numeric(18,0)
	,@Branch_ID varchar(max) 
	,@Effective_Date datetime
	,@Tran_type char(1)	
	,@User_Id numeric(18,0)
	,@IP_Address varchar(200)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    if @Tran_type = 'I'
	begin

		if exists (select 1 from T0095_Authorized_Signature WITH (NOLOCK) where Cmp_Id = @Cmp_Id and Branch_Id = @Branch_Id AND EMp_ID=@Emp_ID and Effective_Date = @Effective_Date)
			BEGIN			
					RAISERROR ('Record already exists' , 16, 2)	
					return
			END

			--added by mehul 12-11-2021 
			if exists (select 1 from T0095_Authorized_Signature WITH (NOLOCK) where Cmp_Id = @Cmp_Id and Branch_Id = @Branch_Id  and Effective_Date = @Effective_Date)
			BEGIN			
					RAISERROR ('Invalid Record' , 16, 2)	
					return
			END


				declare @A_Branch_ID varchar(max)
			
				 DECLARE Sign_Cursor CURSOR FOR 
					SELECT CAST(Data as numeric(18,0))  FROM dbo.Split(@Branch_ID,',')
			         OPEN Sign_Cursor 
					   fetch next from Sign_Cursor into @A_Branch_ID
						while @@fetch_status = 0
						Begin		
								select @Tran_ID = isnull(MAX(Tran_Id),0) + 1 from T0095_Authorized_Signature WITH (NOLOCK)
			
								Insert INTO T0095_authorized_Signature (TRan_id,Cmp_Id,Emp_Id,Branch_Id,Effective_date,System_Date)
								VALUES(@Tran_Id,@Cmp_ID,@Emp_Id,@A_Branch_ID,@Effective_date,GETDATE())			
								
							fetch next from Sign_Cursor into @A_Branch_ID
						End
					 Close Sign_Cursor 
			    deallocate Sign_Cursor
					

		
    End
    
    if @Tran_Type = 'D'
    BEGIN
		 Delete FROM T0095_Authorized_Signature where Tran_Id = @Tran_Id
    end	
END

