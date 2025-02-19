


---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_AR_APPLICATION]    
    @AR_App_ID				NUMERIC(18,2) OUTPUT,
	@Cmp_ID					NUMERIC(18,2),
	@Emp_ID					NUMERIC(18,2),
	@Grd_ID					NUMERIC(18,2),
	@For_Date				DATETIME,
	@Eligibile_Amount		NUMERIC(18,2),
	@Total_Amount			NUMERIC(18,2),
	@App_Status				NUMERIC(18,2),
	@AR_ApplicationDetail   XML ,
	@User_ID				NUMERIC(18,0),
	@Tran_Type				CHAR(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  IF @Tran_Type  = 'I'     
  BEGIN
  
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
		Else IF exists(select 1 from T0100_AR_APPLICATION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and For_Date >= @For_Date and App_Status <> 2)
				BEGIN
					set @AR_App_ID = 0
					return
				END
			
			
     SELECT @AR_App_ID = Isnull(max(AR_APP_ID),0) + 1  FROM T0100_AR_APPLICATION WITH (NOLOCK)   
	 INSERT INTO T0100_AR_APPLICATION (AR_App_ID
					  ,Cmp_ID
					  ,Emp_ID
					  ,Grd_ID
					  ,For_Date
					  ,Eligibile_Amount
					  ,Total_Amount
					  ,App_Status
					  ,CreatedBy
					  ,DateCreated) 
				VALUES
					(@AR_App_ID
					  ,@Cmp_ID
					  ,@Emp_ID
					  ,@Grd_ID
					  ,@For_Date
					  ,@Eligibile_Amount
					  ,@Total_Amount
					  ,@App_Status
					  ,@User_ID
					  ,Getdate())
					  
		exec P0100_AR_ApplicationDetail 0,@AR_App_ID,@Cmp_ID,@AR_ApplicationDetail,@User_ID,@Tran_Type
	
  End    
 Else if @Tran_Type = 'U'     
  BEGIN
          
        UPDATE T0100_AR_Application
			   SET Total_Amount = @Total_Amount
				  ,App_Status = @App_Status
				  ,Eligibile_Amount = @Eligibile_Amount
				  ,Modifiedby = @User_ID
				  ,DateModified = Getdate()
		WHERE  AR_APP_ID =@AR_APP_ID and Cmp_ID=@Cmp_ID
		
		exec P0100_AR_ApplicationDetail 0,@AR_App_ID,@Cmp_ID,@AR_ApplicationDetail,@User_ID,@Tran_Type
		                         	
  END  
 Else if @Tran_Type = 'D'     
  BEGIN
  
	 Delete From dbo.T0100_AR_ApplicationDetail 
		where AR_APP_ID =@AR_APP_ID and Cmp_ID=@Cmp_ID
     DELETE FROM dbo.T0100_AR_Application 
		where AR_APP_ID =@AR_APP_ID and Cmp_ID=@Cmp_ID
    
  END
     
 RETURN




