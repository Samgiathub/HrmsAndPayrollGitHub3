

  
  
  
-- =============================================  
-- Author:  Ankit  
-- Create date: 09052016  
-- Description: Gate Pass Application Record  
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
-- =============================================  
CREATE PROCEDURE [dbo].[P0100_GATE_PASS_APPLICATION]   
 @App_ID  NUMERIC(18, 0) OUTPUT,  
 @Cmp_ID  NUMERIC(18, 0) ,  
 @Emp_ID  NUMERIC(18, 0) ,  
 @App_Date DATETIME ,  
 @For_Date DATETIME ,  
 @From_Time DATETIME ,  
 @To_Time DATETIME ,  
 @Duration VARCHAR(10) ,  
 @Reason_ID NUMERIC(18, 0) ,  
 @Remarks VARCHAR(250) ,  
 @Login_ID NUMERIC(18, 0) ,  
 @Tran_Type  CHAR(1)   
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  set @Remarks = dbo.fnc_ReverseHTMLTags(@Remarks)  --added by ronak 120122      
 IF EXISTS( SELECT 1 FROM T0120_GATE_PASS_APPROVAL WITH (NOLOCK) WHERE App_ID = @App_ID )  
  BEGIN  
   RAISERROR('@@ Gate Pass Application is already approved, you can''t delete @@',16,2)  
   RETURN;  
  END  
   
       
 IF @Tran_Type = 'I'  
  BEGIN    
  -- Check if the employee has an approved leave on the same date
    IF EXISTS (
        SELECT 1
        FROM V0120_LEAVE_APPROVAL WITH (NOLOCK)
        WHERE Emp_ID = @Emp_ID
          AND Approval_Status = 'A'  -- Approved leave
          AND CONVERT(DATE, From_Date) = CONVERT(DATE, @App_Date)  -- Compare only the date part
    )
    BEGIN
        RAISERROR('@@ Leave Approved for the Same Date. Cannot Create GatePass @@', 16, 2)
        RETURN
    END
   IF EXISTS( SELECT 1 FROM T0100_GATE_PASS_APPLICATION WITH (NOLOCK)  
      WHERE Emp_ID = @Emp_Id AND   
        --From_Time = @From_Time AND To_Time = @To_Time   
        ((@From_Time between From_Time and To_Time)   
        OR (@To_Time between From_Time and To_Time) )  
        --AND Duration = @Duration   
        
      )  
    BEGIN  
     RAISERROR('@@ GatePass For Same Time Already Applied @@',16,2)  
     RETURN;  
    END
	--ronakb051224
	 IF Not EXISTS( Select * from V0100_Emp_shift_Change vesc , T0040_SHIFT_MASTER tsm
					Where vesc.Shift_ID = tsm.Shift_ID And vesc.Emp_ID=@Emp_Id
					And CONVERT(TIME, tsm.Shift_St_Time) <= CAST(@From_Time AS TIME)
					And   CONVERT(TIME, tsm.Shift_End_Time) >=  CAST(@To_Time AS TIME))  
    BEGIN  
		 RAISERROR('@@Gate pass is not allowed after over shift time.@@',16,2)  
		RETURN 
    END

   SELECT @App_ID = ISNULL(MAX(App_ID),0) + 1 FROM dbo.T0100_GATE_PASS_APPLICATION WITH (NOLOCK)  
     
   INSERT INTO dbo.T0100_GATE_PASS_APPLICATION  
     (App_ID,Cmp_ID,Emp_ID,App_Date,For_Date,From_Time,To_Time,Duration,Reason_ID,Remarks,App_User_ID,System_DateTime,App_Status)  
   VALUES (@App_ID,@Cmp_ID,@Emp_ID,@App_Date,@For_Date,@From_Time,@To_Time,@Duration,@Reason_ID,@Remarks,@Login_ID,GETDATE(),'P')  
  END  
 ELSE IF @Tran_Type = 'U'  
  BEGIN  
   IF EXISTS( SELECT 1 FROM T0100_GATE_PASS_APPLICATION WITH (NOLOCK) WHERE App_ID <> @App_ID AND Emp_ID = @Emp_Id AND From_Time = @From_Time AND To_Time = @To_Time AND Duration = @Duration )  
    BEGIN  
     RAISERROR('@@ GatePass For Same Time Already Applied @@',16,2)  
     RETURN;  
    END  
      
   UPDATE dbo.T0100_GATE_PASS_APPLICATION  
   SET  For_Date = @For_Date ,From_Time = @From_Time ,To_Time = @To_Time ,Duration = @Duration ,Reason_ID = @Reason_ID ,Remarks = @Remarks  
   WHERE App_ID = @App_ID AND Emp_ID = @Emp_ID  
  END  
 ELSE IF @Tran_Type = 'D'  
  BEGIN  
     
   IF EXISTS( SELECT 1 FROM T0115_GATE_PASS_LEVEL_APPROVAL WITH (NOLOCK) WHERE App_ID = @App_ID  )  
    BEGIN  
     RAISERROR('@@ GatePass Already Approved From Scheme Level @@',16,2)  
     RETURN;  
    END  
     
   DELETE FROM dbo.T0100_GATE_PASS_APPLICATION WHERE App_ID = @App_ID --AND Emp_ID = @Emp_ID  
     
  END   
   
   
END  
  
