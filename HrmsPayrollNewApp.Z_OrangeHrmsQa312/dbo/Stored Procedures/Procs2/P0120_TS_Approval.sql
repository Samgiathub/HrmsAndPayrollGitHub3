

 
 ---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0120_TS_Approval]   
@Timesheet_Approval_ID NUMERIC output,  
@Project_Status_ID numeric(18,0),  
@Timesheet_ID numeric(18,0),  
@Employee_ID numeric(18,0),  
--@Approval_By numeric(18,0),   
@Timesheet_Period varchar(50),   
@Approval_Remarks varchar(MAX),  
@TSXML xml,      
@Cmp_ID numeric(18,0),       
@Created_By numeric(18,0),       
@Trans_Type varchar(1),
@Attachment varchar(MAX)     
AS


SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Mon VARCHAR(MAX)      
DECLARE @Tue VARCHAR(MAX)      
DECLARE @Wed VARCHAR(MAX)      
DECLARE @Thu VARCHAR(MAX)      
DECLARE @Fri VARCHAR(MAX)      
DECLARE @Sat VARCHAR(MAX)      
DECLARE @Sun VARCHAR(MAX)     
DECLARE @Project VARCHAR(MAX)     
DECLARE @Task VARCHAR(MAX)   
DECLARE @Status_ID numeric  
DECLARE @TS_Approval_Detail_ID NUMERIC  
IF @Project_Status_ID = 0      
 SET @Project_Status_ID = NULL      
If @Trans_Type  = 'I'  
 BEGIN  
  IF Not Exists (SELECT Timesheet_Approval_ID  FROM T0120_TS_Approval WITH (NOLOCK) WHERE Timesheet_ID = @Timesheet_ID)  
   BEGIN  
    SELECT @Timesheet_Approval_ID = ISNULL(MAX(Timesheet_Approval_ID), 0) + 1 FROM T0120_TS_Approval  WITH (NOLOCK)
    INSERT INTO T0120_TS_Approval(Timesheet_Approval_ID,Project_Status_ID,Timesheet_ID,Employee_ID,Approval_By,Timesheet_Period,Approval_Remarks,Cmp_ID,Created_By,Created_Date,Attachment )  
    VALUES(@Timesheet_Approval_ID,@Project_Status_ID,@Timesheet_ID,@Employee_ID,@Created_By,@Timesheet_Period,@Approval_Remarks,@Cmp_ID,@Created_By,GETDATE(),@Attachment)  
       
       
    select Table1.value('(Project_ID/text())[1]','numeric(18,0)') as Project_ID,  
    Table1.value('(Task_ID/text())[1]','numeric(18,0)') as Task_ID,  
    (Table1.value('(Monday/text())[1]','varchar(50)')   + '#' + Table1.value('(Monday_Des/text())[1]','varchar(Max)')) as Monday,  
    (Table1.value('(Tuesday/text())[1]','varchar(50)') + '#' + Table1.value('(Tuesday_Des/text())[1]','varchar(Max)')) as Tuesday,  
    (Table1.value('(Wednesday/text())[1]','varchar(50)') + '#' + Table1.value('(Wednesday_Des/text())[1]','varchar(Max)')) as Wednesday,      
    (Table1.value('(Thursday/text())[1]','varchar(50)') + '#' + Table1.value('(Thursday_Des/text())[1]','varchar(Max)')) as Thursday,      
    (Table1.value('(Friday/text())[1]','varchar(50)') + '#' +Table1.value('(Friday_Des/text())[1]','varchar(Max)')) as Friday,      
    (Table1.value('(Saturday/text())[1]','varchar(50)') + '#' + Table1.value('(Saturday_Des/text())[1]','varchar(Max)')) as Saturday,      
    (Table1.value('(Sunday/text())[1]','varchar(50)') + '#' +Table1.value('(Sunday_Des/text())[1]','varchar(Max)')) as Sunday      
    into #TSTemptable from @TSXML.nodes('/Timesheet/Table1')  as Temp(Table1)      
       
    DECLARE TIMESHEETAPPROVE_CURSOR CURSOR  Fast_forward FOR  
    SELECT Project_ID,Task_ID,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday from #TSTemptable  
    OPEN TIMESHEETAPPROVE_CURSOR  
    FETCH NEXT FROM TIMESHEETAPPROVE_CURSOR INTO @Project,@Task,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@Sun  
    while @@fetch_status = 0  
     Begin  
      SELECT @TS_Approval_Detail_ID = ISNULL(MAX(TS_Approval_Detail_ID), 0) + 1 FROM T0130_TS_Approval_Detail WITH (NOLOCK) 
      INSERT INTO T0130_TS_Approval_Detail(TS_Approval_Detail_ID,Timesheet_Approval_ID,Project_ID,Task_ID,Mon,Tue,Wed,Thu,Fri,Sat,Sun,Cmp_ID,Created_By,Created_Date)  
      VALUES(@TS_Approval_Detail_ID,@Timesheet_Approval_ID,@Project,@Task,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@Sun,@Cmp_ID,@Created_By,GETDATE())   
      FETCH NEXT FROM TIMESHEETAPPROVE_CURSOR INTO @Project,@Task,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@Sun  
     End  
     CLOSE TIMESHEETAPPROVE_CURSOR       
     DEALLOCATE TIMESHEETAPPROVE_CURSOR  
       
     Update T0100_TS_Application SET Project_Status_ID = @Project_Status_ID,Description= @Approval_Remarks where Timesheet_ID = @Timesheet_ID  
       
   END  
  ELSE  
   BEGIN  
   
    SELECT @Timesheet_Approval_ID = Timesheet_Approval_ID  FROM T0120_TS_Approval WITH (NOLOCK) WHERE Timesheet_ID = @Timesheet_ID  
    UPDATE T0120_TS_Approval SET Project_Status_ID = @Project_Status_ID,Timesheet_ID = @Timesheet_ID,Employee_ID = @Employee_ID,  
    Approval_By = @Created_By,Timesheet_Period = @Timesheet_Period,Approval_Remarks =@Approval_Remarks,  
    Cmp_ID = @Cmp_ID,Modify_By = @Created_By,Modify_Date = GETDATE(),Attachment = @Attachment  
    WHERE Timesheet_Approval_ID = @Timesheet_Approval_ID  
      
    DELETE FROM T0130_TS_Approval_Detail Where Timesheet_Approval_ID =  @Timesheet_Approval_ID  
      
    select Table1.value('(Project_ID/text())[1]','numeric(18,0)') as Project_ID,  
    Table1.value('(Task_ID/text())[1]','numeric(18,0)') as Task_ID,  
    (Table1.value('(Monday/text())[1]','varchar(50)')   + '#' + Table1.value('(Monday_Des/text())[1]','varchar(Max)')) as Monday,  
    (Table1.value('(Tuesday/text())[1]','varchar(50)') + '#' + Table1.value('(Tuesday_Des/text())[1]','varchar(Max)')) as Tuesday,  
    (Table1.value('(Wednesday/text())[1]','varchar(50)') + '#' + Table1.value('(Wednesday_Des/text())[1]','varchar(Max)')) as Wednesday,      
    (Table1.value('(Thursday/text())[1]','varchar(50)') + '#' + Table1.value('(Thursday_Des/text())[1]','varchar(Max)')) as Thursday,      
    (Table1.value('(Friday/text())[1]','varchar(50)') + '#' +Table1.value('(Friday_Des/text())[1]','varchar(Max)')) as Friday,      
    (Table1.value('(Saturday/text())[1]','varchar(50)') + '#' + Table1.value('(Saturday_Des/text())[1]','varchar(Max)')) as Saturday,      
    (Table1.value('(Sunday/text())[1]','varchar(50)') + '#' +Table1.value('(Sunday_Des/text())[1]','varchar(Max)')) as Sunday      
    into #TSTemptable1 from @TSXML.nodes('/Timesheet/Table1')  as Temp(Table1)      
       
    DECLARE TIMESHEETAPPROVE_CURSOR CURSOR  Fast_forward FOR  
    SELECT Project_ID,Task_ID,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday from #TSTemptable1  
    OPEN TIMESHEETAPPROVE_CURSOR  
    FETCH NEXT FROM TIMESHEETAPPROVE_CURSOR INTO @Project,@Task,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@Sun  
    while @@fetch_status = 0  
     Begin  
	 
      SELECT @TS_Approval_Detail_ID = ISNULL(MAX(TS_Approval_Detail_ID), 0) + 1 FROM T0130_TS_Approval_Detail WITH (NOLOCK) 
      INSERT INTO T0130_TS_Approval_Detail(TS_Approval_Detail_ID,Timesheet_Approval_ID,Project_ID,Task_ID,Mon,Tue,Wed,Thu,Fri,Sat,Sun,Cmp_ID,Created_By,Created_Date)  
      VALUES(@TS_Approval_Detail_ID,@Timesheet_Approval_ID,@Project,@Task,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@Sun,@Cmp_ID,@Created_By,GETDATE())   
      FETCH NEXT FROM TIMESHEETAPPROVE_CURSOR INTO @Project,@Task,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@Sun  
     End  
     CLOSE TIMESHEETAPPROVE_CURSOR       
     DEALLOCATE TIMESHEETAPPROVE_CURSOR  
       
     Update T0100_TS_Application SET Project_Status_ID = @Project_Status_ID,Description= @Approval_Remarks where Timesheet_ID = @Timesheet_ID  
   END  
 END  
ELSE If @Trans_Type  = 'D'  
 BEGIN  
    
  IF Exists (SELECT Timesheet_Approval_ID  FROM T0120_TS_Approval WITH (NOLOCK) WHERE Timesheet_ID = @Timesheet_ID)  
   BEGIN  
     
   SET @Timesheet_Approval_ID  = (SELECT Timesheet_Approval_ID  FROM T0120_TS_Approval WITH (NOLOCK) WHERE Timesheet_ID = @Timesheet_ID)  
      
    DELETE FROM T0130_TS_Approval_Detail WHERE Timesheet_Approval_ID = @Timesheet_Approval_ID  
    DELETE FROM T0120_TS_Approval WHERE Timesheet_Approval_ID = @Timesheet_Approval_ID  
    SELECT @Status_ID = Project_Status_ID FROM T0040_Project_Status WITH (NOLOCK)  
    WHERE Status_Type = 4 AND Cmp_ID = @Cmp_ID  
    Update T0100_TS_Application SET Project_Status_ID = @Status_ID,Description= ''   
    where Timesheet_ID = @Timesheet_ID  
   END   
    
 END 
