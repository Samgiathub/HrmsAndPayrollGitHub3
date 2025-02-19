  
    
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
CREATE PROCEDURE [dbo].[P0120_OP_HOLIDAY_APPROVAL]        
   @OP_Holiday_Apr_ID  NUMERIC OUTPUT        
  ,@OP_Holiday_App_ID  NUMERIC       
  ,@Emp_ID     NUMERIC     
  ,@Cmp_ID     NUMERIC           
  ,@Hday_ID     NUMERIC        
  ,@S_Emp_ID    NUMERIC        
  ,@Op_Holiday_Apr_Date  DATETIME    
  ,@Op_Holiday_Apr_Status  CHAR(1)     
  ,@Op_Holiday_Apr_Comment  VARCHAR(4000)    
  ,@Created_By    NUMERIC          
  ,@Date_Created   DATETIME    
  ,@Modify_By    NUMERIC          
  ,@Date_Modified   DATETIME    
  ,@Tran_Type    CHAR(1)    
  ,@User_Id numeric(18,0) = 0 -- Add By Mukti 05072016    
  ,@IP_Address varchar(30)= '' -- Add By Mukti 05072016    
  ,@Flag char(1)='N'    
         
AS        
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
    
-- Add By Mukti 05072016(start)    
declare @OldValue as  varchar(max)    
Declare @String as varchar(max)    
set @String=''    
set @OldValue =''    
-- Add By Mukti 05072016(end)    
           set @Op_Holiday_Apr_Comment = dbo.fnc_ReverseHTMLTags(@Op_Holiday_Apr_Comment)  --added by Ronak 100121  
IF @S_Emp_ID = 0    
 SET @S_Emp_ID = NULL    
  
  -- Added By Sajid and Deepal for IFSCA 30-12-2021  
  Declare @Setting_Value INT = 0  
   Select @Setting_Value= Setting_Value From T0040_SETTING  WITH (NOLOCK)   
      Where Setting_Name='This Months Salary Exists Validation If Salary Geneated.' and Cmp_ID=@cmp_Id  
  if (@Setting_Value = 0)  
  BEGIN  
    
  IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WHERE Emp_ID=@Emp_Id and  Month_End_Date >= @Op_Holiday_Apr_Date and Cmp_ID = @Cmp_ID)    
    BEGIN    
     RAISERROR ('Current Months Salary Exists', 16, 2)     
     RETURN    
    END       
 END  
     
 DECLARE @Optional_Holiday_Approval_Days as numeric(18,0)    
 DECLARE @Approval_Days as numeric(18,0)    
 DECLARE @Branch_id as numeric(18,0)  --Added by Ramiz on 15092014    
     
 --Select @Optional_Holiday_Approval_Days = Optional_HOliday_days from T0040_General_setting where Cmp_ID=@Cmp_ID     
 --and  Branch_ID     
 --in (SELECT Branch_ID from T0080_EMP_MASTER where Emp_ID=@Emp_ID and T0040_GENERAL_SETTING.Cmp_ID= @Cmp_ID)    
     
 -------Commented and Added by Ramiz on 15092014  ----------    
      
  -- Commented and added by rohit for get branch id from increment on 11122015    
   select @Branch_ID = Branch_ID From T0095_Increment I WITH (NOLOCK) inner join     
  (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join    
    (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)    
    Where Increment_effective_Date <= @Op_Holiday_Apr_Date Group by emp_ID) new_inc    
    on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date    
    Where TI.Increment_effective_Date <= @Op_Holiday_Apr_Date group by ti.emp_id) Qry on     
    I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID Where I.Emp_ID = @Emp_ID    
  --SELECT @Branch_id = Branch_ID from T0080_EMP_MASTER where Emp_ID=@Emp_ID and Cmp_ID= @Cmp_ID     
  -- Ended by rohit on 11122015    
      
  Select @Optional_Holiday_Approval_Days = Optional_HOliday_days from T0040_General_setting WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Branch_ID = @Branch_id and    
  For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)        
      
  -------Ended by Ramiz on 15092014  ----------     
     
 Declare @F_StartDate datetime --Ankit 05012015    
 Declare @F_EndDate Datetime    
 SET @F_StartDate= DATEADD(yy, DATEDIFF(yy,0,@Op_Holiday_Apr_Date), 0)     
 SET @F_EndDate = DATEADD(yy, DATEDIFF(yy,0,@Op_Holiday_Apr_Date) + 1, -1)     
   --print @F_StartDate  
   --print @OP_Holiday_Apr_Status  
   --  print @F_EndDate  
 SELECT @Approval_Days= COUNT(@OP_Holiday_Apr_Status)     
 FROM T0120_Op_Holiday_Approval WITH (NOLOCK)    
 where emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and (Op_Holiday_Apr_Status = 'A' or Op_Holiday_Apr_Status = 'P')    
  And Op_Holiday_Apr_Date >= @F_StartDate And Op_Holiday_Apr_Date <= @F_EndDate --Ankit 05012015    
     
     
   print @Tran_Type  
IF @Tran_Type = 'I'         
   BEGIN        
 --   print @Approval_Days  
 --print @Optional_Holiday_Approval_Days  
    IF @Approval_Days >= @Optional_Holiday_Approval_Days    
     BEGIN    
  RAISERROR ('You have already approved max optional holiday', 16, 2)     
     RETURN     
     END     
              
 SELECT @OP_Holiday_Apr_ID = isnull(max(Op_Holiday_Apr_ID),0) +1 FROM dbo.T0120_Op_Holiday_Approval WITH (NOLOCK)       
     
 SET @Modify_By = NULL    
 SET @Date_Modified = NULL    
     
                     
 IF (@OP_Holiday_App_ID = 0 and @Flag='N')    
 BEGIN    
            
     SET @Op_Holiday_Apr_Status =@Op_Holiday_Apr_Status    
  EXEC P0100_OP_HOLIDAY_APPLICATION  @OP_Holiday_App_ID OUTPUT ,@Cmp_ID,@Emp_ID,@Hday_ID,@Op_Holiday_Apr_Date,@Op_Holiday_Apr_Status,@Op_Holiday_Apr_Comment,@Created_By,@Date_Created,@Modify_By,@Date_Modified,@Tran_Type    
 END     
     
 if Not Exists(select 1 from T0120_Op_Holiday_Approval WITH (NOLOCK) where Emp_ID=@Emp_ID and HDay_ID=@Hday_ID and Op_Holiday_Apr_Comments=@Op_Holiday_Apr_Comment and Op_Holiday_App_ID=@OP_Holiday_App_ID and Cmp_ID=@Cmp_ID)    
  Begin    
  print 1111  
   INSERT INTO dbo.T0120_Op_Holiday_Approval        
       (Op_Holiday_Apr_ID,    
        Op_Holiday_App_ID,                     
        Emp_ID,    
        Cmp_ID,                      
        HDay_ID,                     
        S_Emp_ID,    
        Op_Holiday_Apr_Date,    
        Op_Holiday_Apr_Status,                                      
        Op_Holiday_Apr_Comments,    
        Created_By,    
        Date_Created,    
        Modify_By,    
        Date_Modified)                      
     VALUES (@OP_Holiday_Apr_ID,    
       @OP_Holiday_App_ID,        
       @Emp_ID,    
       @Cmp_ID,    
       @Hday_ID,    
       @S_Emp_ID,    
       @Op_Holiday_Apr_Date,    
       @Op_Holiday_Apr_Status,    
       @Op_Holiday_Apr_Comment,    
       @Created_By,    
       @Date_Created,    
       @Modify_By,    
       @Date_Modified)       
           
    Update  T0100_OP_Holiday_Application    
    SET Op_Holiday_Status=@Op_Holiday_Apr_Status    
    WHERE  Op_Holiday_App_ID=@OP_Holiday_App_ID and Cmp_ID=@Cmp_ID    
        
   -- Add By Mukti 05072016(start)    
   exec P9999_Audit_get @table = 'T0120_Op_Holiday_Approval' ,@key_column='Op_Holiday_Apr_ID',@key_Values=@OP_Holiday_Apr_ID,@String=@String output    
   set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))      
   -- Add By Mukti 05072016(end)     
   End    
 Else    
  Begin     
   RAISERROR ('Application Already Approved' , 16, 2)    
   RETURN;    
  End                       
   END    
       
 ELSE IF @Tran_Type ='U'         
    BEGIN     
       -- Add By Mukti 05072016(start)    
  exec P9999_Audit_get @table='T0120_Op_Holiday_Approval' ,@key_column='Op_Holiday_Apr_ID',@key_Values=@OP_Holiday_Apr_ID,@String=@String output    
  set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))    
    -- Add By Mukti 05072016(end)    
      
    UPDATE    dbo.T0120_Op_Holiday_Approval        
    SET         
                  Op_Holiday_App_ID   = @OP_Holiday_App_ID,                     
                  Emp_ID     = @Emp_ID,    
                  Cmp_ID     = @Cmp_ID ,                      
                  HDay_ID     = @Hday_ID,                     
                  S_Emp_ID     = @S_Emp_ID,     
                  Op_Holiday_Apr_Date  = @Op_Holiday_Apr_Date,    
                  Op_Holiday_Apr_Status  = @Op_Holiday_Apr_Status,                                      
                  Op_Holiday_Apr_Comments = @Op_Holiday_Apr_Comment ,    
                  Created_By    = @Created_By,    
                  Date_Created    = @Date_Created ,    
                  Modify_By     = @Modify_By,    
                  Date_Modified    =  @Date_Modified             
   WHERE Op_Holiday_App_ID = @OP_Holiday_App_ID    and Cmp_ID=@Cmp_ID    
        
           
  Update  T0100_OP_Holiday_Application    
  SET Op_Holiday_Status=@Op_Holiday_Apr_Status    
  WHERE  Op_Holiday_App_ID=@OP_Holiday_App_ID   and Cmp_ID=@Cmp_ID    
        
    -- Add By Mukti 05072016(start)    
  exec P9999_Audit_get @table = 'T0120_Op_Holiday_Approval' ,@key_column='Op_Holiday_Apr_ID',@key_Values=@OP_Holiday_Apr_ID,@String=@String output    
  set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))    
   -- Add By Mukti 05072016(end)              
   END        
 ELSE IF @tran_type ='D'        
  BEGIN        
      
  IF @Op_Holiday_Apr_Status ='P'    
 BEGIN    
    -- Add By Mukti 05072016(start)    
  exec P9999_Audit_get @table='T0120_Op_Holiday_Approval' ,@key_column='Op_Holiday_Apr_ID',@key_Values=@OP_Holiday_Apr_ID,@String=@String output    
  set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))      -- Add By Mukti 05072016(end)    
        
  DELETE FROM T0100_OP_Holiday_Application where Op_Holiday_App_ID = @OP_Holiday_App_ID AND CMP_ID=@Cmp_ID AND Op_Holiday_Status='P'    
 END    
  ELSE    
  BEGIN     
      
   IF EXISTS(SELECT  1 FROM T0120_Op_Holiday_Approval WITH (NOLOCK) WHERE  Op_Holiday_App_ID = @OP_Holiday_App_ID    AND CMP_ID=@Cmp_ID)    
   BEGIN    
  DELETE FROM dbo.T0120_Op_Holiday_Approval where Op_Holiday_App_ID = @OP_Holiday_App_ID  AND CMP_ID=@Cmp_ID           
   END    
         
   IF EXISTS(SELECT 1 FROM T0100_OP_Holiday_Application WITH (NOLOCK) WHERE Op_Holiday_App_ID = @OP_Holiday_App_ID     AND CMP_ID=@Cmp_ID)    
    BEGIN      
     Update  T0100_OP_Holiday_Application     
     set  Op_Holiday_Status ='P' where Op_Holiday_App_ID = @OP_Holiday_App_ID     AND CMP_ID=@Cmp_ID    
    END     
 END    
      
  END        
  exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Optional Holiday Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1    
 RETURN    
    
    