  
  
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0120_Asset_Approval]  
 @Asset_Approval_ID numeric OUTPUT  
 ,@Asset_Application_ID numeric  
 ,@Cmp_ID numeric  
 ,@Emp_ID numeric  
 ,@Branch_ID numeric  
 ,@Receiver_ID numeric  
 ,@Comments varchar(max)  
 ,@Status varchar(20)  
 ,@LoginId numeric  
 ,@Asset_Approval_Date datetime  
 ,@Tran_type CHAR(1)  
 ,@IP_Address varchar(30)= ''  
 ,@Allocation_Date datetime  
 ,@Dept_ID numeric  
 ,@Transfer_Emp_ID numeric=0  
 ,@Transfer_Branch_ID numeric=0  
 ,@Transfer_Dept_ID numeric=0  
 ,@Application_Type numeric=0  
 ,@User_Id numeric(18,0) = 0 -- Add By Mukti 11072016   
 ,@Branch_For_Dept int=0  
 ,@Transfer_Branch_For_Dept int=0  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
 declare @Application_code numeric  
 declare @Applied_by numeric  
 declare @Transfer_ID as numeric  
 declare @TransAsset_Approval_ID as numeric  
  
-- Add By Mukti 11072016(start)  
 declare @OldValue as  varchar(max)  
 Declare @String_val as varchar(max)  
 set @String_val=''  
 set @OldValue =''  
-- Add By Mukti 11072016(end)  

   set @Comments = dbo.fnc_ReverseHTMLTags(@Comments) --Ronak_060121  
   
IF @Tran_type = 'I'  
 BEGIN  
  if @Asset_Application_ID=0  
   begin  
    set @Applied_by=0  
   end  
  else  
   begin  
    select @Applied_by = Emp_id  from T0100_Asset_Application WITH (NOLOCK) where Asset_Application_ID=@Asset_Application_ID and cmp_id=@cmp_id  
   end      
     
   select @Asset_Approval_ID = isnull(max(Asset_Approval_ID),0) + 1  from T0120_Asset_Approval WITH (NOLOCK)  
   insert into T0120_Asset_Approval(Asset_Approval_ID,Asset_Application_ID,Cmp_ID,Emp_ID,Branch_ID,Receiver_ID,Comments,[Status],LoginId,System_date,asset_approval_date,Allocation_Date,Applied_by,Dept_ID,Transfer_Emp_ID,Transfer_Branch_ID,Transfer_Dept_ID
,Application_Type,Branch_For_Dept,Transfer_Branch_For_Dept)  
   values(@Asset_Approval_ID,@Asset_Application_ID,@Cmp_ID,@Emp_ID,@Branch_ID,@Receiver_ID,@Comments,@Status,@LoginId,GETDATE(),@Asset_Approval_Date,'01/01/1900',@Applied_by,@Dept_ID,@Transfer_Emp_ID,@Transfer_Branch_ID,@Transfer_Dept_ID,@Application_Type
,@Branch_For_Dept,@Transfer_Branch_For_Dept)  
    
  -- Add By Mukti 11072016(start)  
   exec P9999_Audit_get @table = 'T0120_Asset_Approval' ,@key_column='Asset_Approval_ID',@key_Values=@Asset_Approval_ID,@String=@String_val output  
   set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))    
  -- Add By Mukti 11072016(end)   
 END    
else if @Tran_type = 'U'  
 Begin   
  --select @OldAsset_Application_ID  =ISNULL(Asset_Application_ID,0) ,@OldEmp_ID  =ISNULL(Emp_ID,0),@OldBranch_ID  =ISNULL(Branch_ID,0),@OldReceiver_ID  =ISNULL(Receiver_ID,0),@OldComments  =ISNULL(Comments,''),@OldStatus  =ISNULL([Status],''),@OldAsset_Approval_Date  =ISNULL(Asset_Approval_Date,'') From dbo.T0120_Asset_Approval where Asset_Approval_ID = @Asset_Approval_ID And Cmp_ID = @Cmp_Id  
     
   -- Add By Mukti 11072016(start)  
     exec P9999_Audit_get @table='T0120_Asset_Approval' ,@key_column='Asset_Approval_ID',@key_Values=@Asset_Approval_ID,@String=@String_val output  
     set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))  
   -- Add By Mukti 11072016(end)  
     
    update  T0120_Asset_Approval  
     set Emp_ID=@Emp_ID,  
      Branch_ID=@Branch_ID,  
      Receiver_ID=@Receiver_ID,  
      LoginId=@LoginId,  
      System_date=GETDATE(),  
      Asset_Approval_Date=@Asset_Approval_Date,  
      Dept_ID=@Dept_ID,  
      Comments=@Comments,  
      [Status]=@Status,  
      Branch_For_Dept=@Branch_For_Dept  
     where Asset_Approval_ID = @Asset_Approval_ID And Cmp_ID = @Cmp_Id   
       
     update T0120_Asset_Approval  
     set Transfer_Emp_ID=@Transfer_Emp_ID,  
      Transfer_Branch_ID=@Transfer_Branch_ID,  
      Transfer_Dept_ID=@Transfer_Dept_ID,   
      Transfer_Branch_For_Dept=@Transfer_Branch_For_Dept     
     where Asset_Approval_ID = @Asset_Approval_ID And Cmp_ID = @Cmp_Id and Application_Type=3  
    
  -- Add By Mukti 11072016(start)  
    exec P9999_Audit_get @table = 'T0120_Asset_Approval' ,@key_column='Asset_Approval_ID',@key_Values=@Asset_Approval_ID,@String=@String_val output  
    set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))  
  -- Add By Mukti 11072016(end)    
 End  
 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Asset Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1  
   
RETURN @Asset_Approval_ID  
  
  
  
  