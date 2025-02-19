    
    
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
CREATE PROCEDURE [dbo].[P0299_schedule_master]      
 @Sch_Id  numeric(18,0) output      
   ,@Cmp_ID   numeric(18,0)      
   ,@Sch_Name  varchar(200)      
   ,@Reminder_Name varchar(500)      
   ,@Sch_Type varchar(100)      
   ,@Date_run varchar(30)      
   ,@Date_Weekly varchar(250)      
   ,@Sch_time varchar(50)=''      
   ,@Cc_Email_Id varchar(max)     
   ,@User_Id numeric(18,0) = 0     
   ,@IP_Address varchar(30)= ''    
   ,@tran_type  varchar(1)     
   ,@Sch_Hours Numeric(18,0)=0    
   ,@is_Time Numeric(18,0)=1    
   ,@parameter varchar(max) = ''    
   ,@LeaveIDs Varchar(1024) = ''    
AS      
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
 Declare @loginname as varchar(50)      
 Declare @Domain_Name as varchar(50)      
    
     
     
 Declare @OldValue as varchar(max)    
 Declare @OldCode as varchar(50)    
 Declare @OldSch_Name as varchar(100)    
 Declare @OldReminder_Name as varchar(30)    
 Declare @OldSch_Type as varchar(250)    
 Declare @OldDate_run as varchar(50)    
 Declare @OldDate_Weekly As Varchar(400)    
 Declare @OldSch_time as varchar(50)    
 Declare @OldCc_Email_Id as varchar(500)    
 Declare @oldcmp_id as varchar(10)    
     
 Declare @OldSch_Hours Varchar(20)    
 Declare @Oldis_Time varchar(5)    
 Declare @OldLeaveIDs Varchar(1024)    
    
 Declare @job_Name NVarchar(Max)    
     
 set @job_Name = ''    
     
 if upper(@Sch_Type) = 'DAILY'    
  begin    
   set @Date_Weekly=''    
   set @Date_run=0    
  end    
 Else if upper(@Sch_Type) = 'WEEKLY'    
  begin    
   set @Date_run=0    
  end    
 Else if upper(@Sch_Type) = 'MONTHLY'    
  begin    
   set @Date_Weekly=''    
  end    
     
     
 set @OldValue = ''    
 set @OldCode =''    
 set @OldSch_Name =''    
 set @OldReminder_Name =''    
 set @OldSch_Type =''    
 set @OldDate_run =''    
 set @OldDate_Weekly =''    
 set @OldSch_time =''    
 set @OldCc_Email_Id =''    
 set @oldcmp_id =''    
     
 Set @OldSch_Hours =''    
 set @Oldis_Time =''    
        
 if isnull(@Date_run,'')=''    
 begin     
 set @Date_run = 0    
 end        
       set @Sch_Name = dbo.fnc_ReverseHTMLTags(@Sch_Name)  --added by Ronak 261021     
 
 If @tran_type  = 'I'      
 BEGIN      
   IF exists (Select sch_id from t0299_schedule_master WITH (NOLOCK) Where Upper(Sch_Name) = Upper(@Sch_Name))       
  BEGIN      
   set @Sch_Id  = 0      
   Return      
  END    
        
  SELECT @Sch_Id= Isnull(max(Sch_id),0) + 1  From T0299_schedule_master WITH (NOLOCK)    
           
          
  INSERT INTO dbo.t0299_schedule_master      
       (Sch_id,Sch_Name,Reminder_Name,Sch_Type,Date_run,Date_Weekly,Sch_time,Cc_Email_Id,modify_date,cmp_id,Sch_Hours,is_time,parameter,LeaveIDs)    
  VALUES     (@Sch_Id,@Sch_Name,@Reminder_Name,@Sch_Type,@Date_run,@Date_Weekly,@Sch_time,@Cc_Email_Id,GETDATE(),@cmp_id,@Sch_Hours,@is_time,@parameter,@LeaveIDs)      
          
  Set @OldValue =  'New Value' + '#'+ 'schedule Name:' + cast(@Sch_Name as varchar)+ '#' + 'Reminder Name :' + cast(@Reminder_Name as varchar)+ '#' + 'Schedule Type :' + cast(@Sch_Type as varchar)+ '#' + 'run Date:' +cast(@Date_run as varchar)+ '#' + 'Wee
  
kly Date:' + cast(@Date_Weekly as varchar)+ ' #'+ 'Schedule time:'  + cast(@Sch_time as varchar)+ '#' + 'other Email:'  + cast(@Cc_Email_Id as varchar)+ '#' + 'Cmp Id:'  + cast(@cmp_id as varchar)+ '#' + 'Schedule Hours:'  + cast(@Sch_Hours as varchar)+ '
  
#' + 'Is Time'  + cast(@is_Time as varchar)+ '#'           
 END      
 ELSE IF @Tran_Type = 'U'      
 BEGIN      
    IF Exists(SELECT sch_id From t0299_schedule_master WITH (NOLOCK) WHERE upper(Sch_Name) = upper(@Sch_Name) and Sch_id <> @Sch_Id)      
   BEGIN      
    set @Sch_Id= 0      
    Return       
   END      
         
  SELECT @OldSch_Name =Sch_name,@OldReminder_Name =isnull(Reminder_name,''),@OldSch_Type= isnull(Sch_Type,''),    
    @OldDate_run= isnull(Date_run,''),@oldDate_Weekly =CAST(ISNULL(Date_Weekly,'')as varchar(1)),    
    @OldSch_time =Sch_time,@OldCc_Email_Id=Cc_Email_Id ,@oldcmp_id=cmp_id,@OldSch_Hours=sch_hours,    
    @Oldis_Time=Is_Time , @OldLeaveIDs = IsNull(LeaveIDs,'')    
  FROM T0299_schedule_master WITH (NOLOCK)    
  WHERE Sch_id = @sch_id    
      
  UPDATE    dbo.t0299_schedule_master      
  SET Sch_Name = @Sch_Name     
  ,Reminder_Name=@Reminder_Name    
  ,Sch_Type=@Sch_Type    
  ,Date_run=@Date_run    
  ,Date_Weekly=@Date_Weekly    
  ,Sch_time=@Sch_time    
  ,Cc_Email_Id=@Cc_Email_Id    
  ,modify_date=GETDATE()    
  ,cmp_id = @cmp_id    
  ,sch_hours=@Sch_Hours     
  ,is_time=@is_Time    
  ,parameter=@parameter    
  ,LeaveIDs=@LeaveIDs    
  WHERE sch_id = @Sch_Id    
      
  SET @OldValue = 'old Value' + '#'+ 'schedule Name:' + cast(@OldSch_Name as varchar)+ '#' + 'Reminder Name :' + cast(@oldReminder_Name as varchar)+ '#' + 'Schedule Type :' + cast(@OldSch_Type as varchar)+ '#' + 'run Date:' + cast(@OldDate_run  as varchar
  
)+ '#' + 'Weekly Date:' + cast(@OldDate_Weekly as varchar)+ ' #'+ 'Schedule time:'  + cast(@oldSch_time as varchar)+ '#' + 'other Email:'  + cast(@OldCc_Email_Id as varchar)+ '#' + 'Cmp Id:'  + cast(@Oldcmp_id as varchar)+ '#' + 'Schedule Hours:'  + cast(
  
@OldSch_Hours as varchar)+ '#' + 'Is Time'  + cast(@Oldis_Time as varchar)+ '#' +    
      + 'New Value' + '#'+ 'schedule Name:' + cast(@Sch_Name as varchar)+ '#' + 'Reminder Name :' + cast(@Reminder_Name as varchar)+ '#' + 'Schedule Type :' + cast(@Sch_Type as varchar)+ '#' + 'run Date:' + cast(@Date_run as varchar)+ '#' + 'Weekly Date:'
  
 + cast(@Date_Weekly as varchar)+ ' #'+ 'Schedule time:'  + cast(@Sch_time as varchar)+ '#' + 'other Email:'  + cast(@Cc_Email_Id as varchar)+ '#' + 'Cmp Id:'  + cast(@cmp_id as varchar)+ '#' + 'Schedule Hours:'  + cast(@Sch_Hours as varchar)+ '#' + 'Is T
  
ime'  + cast(@is_Time as varchar)+ '#LeaveIDs'  + @OldLeaveIDs + '#'    
         
 END      
 ELSE IF @Tran_Type = 'D'      
   BEGIN    
  SELECT @OldSch_Name =Sch_name,@OldReminder_Name =isnull(Reminder_name,''),@OldSch_Type= isnull(Sch_Type,''),@OldDate_run= isnull(Date_run,''),@oldDate_Weekly =CAST(ISNULL(Date_Weekly,'')as varchar(1)),@OldSch_time =Sch_time,@OldCc_Email_Id=Cc_Email_Id ,
  
@oldcmp_id=cmp_id,@OldSch_Hours=sch_hours,@Oldis_Time=Is_Time From t0299_schedule_master Where Sch_id = @sch_id    
  SET @OldValue = 'old Value' + '#'+ 'schedule Name:' + cast(@OldSch_Name as varchar)+ '#' + 'Reminder Name :' + cast(@oldReminder_Name as varchar)+ '#' + 'Schedule Type :' + cast(@OldSch_Type as varchar)+ '#' + 'run Date:' + cast(@OldDate_run as varchar)
  
+ '#' + 'Weekly Date:' + cast(@OldDate_Weekly as varchar)+ ' #'+ 'Schedule time:'  + cast(@oldSch_time as varchar)+ '#' + 'other Email:'  + cast(@OldCc_Email_Id as varchar)+ '#' + 'Cmp Id:'  + cast(@Oldcmp_id as varchar)+ '#' + 'Schedule Hours:'  + cast(@OldSch_Hours as varchar)+ '#' + 'Is Time'  + cast(@Oldis_Time as varchar)+ '#LeaveIDs'  + @OldLeaveIDs + '#'    
  Delete From dbo.t0299_schedule_master Where sch_id = @Sch_Id      
   END     
      
      
  IF isnull(@parameter ,'')<> ''     
 SET @parameter = ',' + @parameter     
     
 IF (dbo.GetLastCharIndex(@parameter,'@Format') > 0)     
  SET @parameter = left(@parameter,dbo.GetLastCharIndex(@parameter,'@Format') - 2 )    
    
 /*     
  The Following Code added by Nimesh on 09-Feb-2018    
  Parameter @Sch_Id added dynamically if Schedular Proceudure contains parameter @Sch_Id     
  This parameter may be used to get any information of created job master.    
 */    
     
 if @parameter <> '' and Upper(@Reminder_Name) = Upper('SP_Email_Notification_Experince_Wise')    
  Set @parameter = @parameter + ',' + '@Notification_Subject = ''''' + cast(@Sch_Name as varchar) + ''''''    
     
 if EXISTS(SELECT 1 from sys.procedures p inner join sys.parameters r on p.object_id=r.object_id where p.name=@Reminder_Name and r.name='@Sch_Id')    
  AND CHARINDEX('@Sch_Id',@parameter) < 1    
  SET @parameter = @parameter + ', @Sch_Id = ' + Cast(@Sch_Id As Varchar(10))    
      
 SET @job_Name = '''' + CAST(@Sch_Id as varchar) + '_' + CAST(@Sch_Name as nvarchar)+ ''''    
 SET @Reminder_Name ='EXEC '+ cast(@Reminder_Name as varchar(max)) + ' @CMP_ID_PASS = ' + CAST(@Cmp_ID as varchar) + ',@CC_Email = '''''+ CAST(@Cc_Email_Id as varchar(max)) +'''''' + @parameter    
     
 EXEC P9999_Job_Master @job_Name =@job_Name,@command=@Reminder_Name,@from_Time=@Sch_time,@job_Id=@Sch_Id,@type=@Sch_Type,@date_Run=@Date_run,@Date_Weekly=@Date_Weekly,@freq_Subday =@is_Time,@freq_Subday_Interval=@Sch_Hours, @tran_Type=@tran_type    
 EXEC P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Schedule Master',@OldValue,@Sch_Id,@User_Id,@IP_Address    
     
 RETURN      
      
      
      