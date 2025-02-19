

 ---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_TS_Application]     
@Timesheet_ID NUMERIC output,     
@Employee_ID numeric(18,0),    
@Timesheet_Period varchar(50) = NULL,     
@Timesheet_Type varchar(50),    
@Entry_Date datetime,    
@Total_Time varchar(50),    
@Project_Status_ID NUMERIC(18,0), 
@Project_ID numeric(18,0),
@Task_ID numeric(18,0),
@Description varchar(max),    
@TSXML xml,    
@Cmp_ID numeric(18,0),     
@Created_By numeric(18,0),     
@Trans_Type varchar(1),
@Attachment varchar(MAX),
@Client_Id numeric(18,0)     
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
DECLARE @Timesheet_Detail_ID NUMERIC
IF @Project_Status_ID = 0    
	SET @Project_Status_ID = NULL    
IF @Task_ID = 0     
	SET @Task_ID = NULL 
IF @Project_ID = 0
	SET @Project_ID = NULL
  
If @Trans_Type  = 'I'    
	Begin
	
		SELECT @Project_Status_ID = Project_Status_ID  from T0040_Project_Status WITH (NOLOCK) WHERE Project_Status = 'Not Submitted'
		SELECT @Timesheet_ID = ISNULL(MAX(Timesheet_ID), 0) + 1 FROM T0100_TS_Application WITH (NOLOCK)   
		
		INSERT INTO T0100_TS_Application(Timesheet_ID,Employee_ID,Timesheet_Period,Timesheet_Type,Entry_Date,Total_Time,
		Project_Status_ID,Project_ID,Task_ID,Description,Cmp_ID,Created_By,Created_Date,Attachment)    
		VALUES(@Timesheet_ID,@Employee_ID,@Timesheet_Period,@Timesheet_Type,@Entry_Date,@Total_Time,@Project_Status_ID,
		@Project_ID,@Task_ID,@Description,@Cmp_ID,@Created_By,GETDATE(),@Attachment)	
		
		IF @Timesheet_Type = 'Weekly'
			Begin
				select Table1.value('(Project_ID/text())[1]','numeric(18,0)') as Project_ID,
				Table1.value('(Task_ID/text())[1]','numeric(18,0)') as Task_ID,
				(Table1.value('(Monday/text())[1]','varchar(50)')   + '#' + ISNULL(Table1.value('(Monday_Des/text())[1]','varchar(Max)'),' ')) as Monday,
				(Table1.value('(Tuesday/text())[1]','varchar(50)') + '#' +  ISNULL(Table1.value('(Tuesday_Des/text())[1]','varchar(Max)'),' ')) as Tuesday,
				(Table1.value('(Wednesday/text())[1]','varchar(50)') + '#' + ISNULL(Table1.value('(Wednesday_Des/text())[1]','varchar(Max)'),' ')) as Wednesday,    
				(Table1.value('(Thursday/text())[1]','varchar(50)') + '#' + ISNULL(Table1.value('(Thursday_Des/text())[1]','varchar(Max)'),' ')) as Thursday,    
				(Table1.value('(Friday/text())[1]','varchar(50)') + '#' +ISNULL(Table1.value('(Friday_Des/text())[1]','varchar(Max)'),' ')) as Friday,    
				(Table1.value('(Saturday/text())[1]','varchar(50)') + '#' + ISNULL(Table1.value('(Saturday_Des/text())[1]','varchar(Max)'),' ')) as Saturday,    
				(Table1.value('(Sunday/text())[1]','varchar(50)') + '#' +ISNULL(Table1.value('(Sunday_Des/text())[1]','varchar(Max)'),' ')) as Sunday    
				into #TSTemptable from @TSXML.nodes('/Timesheet/Table1')  as Temp(Table1)    
			
				DECLARE TIMESHEET_CURSOR CURSOR  Fast_forward FOR
				SELECT Project_ID,Task_ID,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday from #TSTemptable
				OPEN TIMESHEET_CURSOR
				FETCH NEXT FROM TIMESHEET_CURSOR INTO @Project,@Task,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@Sun
				while @@fetch_status = 0
					Begin
						SELECT @Timesheet_Detail_ID = ISNULL(MAX(Timesheet_Detail_ID), 0) + 1 FROM T0110_TS_Application_Detail WITH (NOLOCK)
						INSERT INTO T0110_TS_Application_Detail(Timesheet_Detail_ID,Timesheet_ID,Project_ID,Task_ID,Mon,Tue,Wed,Thu,Fri,Sat,
						Sun,Cmp_ID,Created_By,Created_Date,Client_id)VALUES(@Timesheet_Detail_ID,@Timesheet_ID,@Project,@Task,@Mon,@Tue,@Wed,
						@Thu,@Fri,@Sat,@Sun,@Cmp_ID,@Created_By,GETDATE(),@Client_Id) 
						FETCH NEXT FROM TIMESHEET_CURSOR INTO @Project,@Task,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@Sun
					End
				CLOSE TIMESHEET_CURSOR     
				DEALLOCATE TIMESHEET_CURSOR
			End
	End
Else if @Trans_Type = 'U'
	Begin
	
		Update T0100_TS_Application SET Employee_ID = @Employee_ID,Timesheet_Period = @Timesheet_Period,
		Timesheet_Type = @Timesheet_Type,Entry_Date = @Entry_Date,Total_Time = @Total_Time,
		Project_Status_ID = @Project_Status_ID,Project_ID = @Project_ID,Task_ID = @Task_ID,Description = @Description,
		Cmp_ID = @Cmp_ID,Modify_By = @Created_By,Modify_Date = GETDATE(),Attachment = @Attachment 
		WHERE Timesheet_ID = @Timesheet_ID
		IF @Timesheet_Type = 'Weekly'
			Begin
				Delete FROM T0110_TS_Application_Detail WHERE Timesheet_ID = @Timesheet_ID
				select Table1.value('(Project_ID/text())[1]','numeric(18,0)') as Project_ID,
				Table1.value('(Task_ID/text())[1]','numeric(18,0)') as Task_ID,
				(Table1.value('(Monday/text())[1]','varchar(50)')   + '#' + ISNULL(Table1.value('(Monday_Des/text())[1]','varchar(Max)'),' ')) as Monday,
				(Table1.value('(Tuesday/text())[1]','varchar(50)') + '#' +  ISNULL(Table1.value('(Tuesday_Des/text())[1]','varchar(Max)'),' ')) as Tuesday,
				(Table1.value('(Wednesday/text())[1]','varchar(50)') + '#' + ISNULL(Table1.value('(Wednesday_Des/text())[1]','varchar(Max)'),' ')) as Wednesday,    
				(Table1.value('(Thursday/text())[1]','varchar(50)') + '#' + ISNULL(Table1.value('(Thursday_Des/text())[1]','varchar(Max)'),' ')) as Thursday,    
				(Table1.value('(Friday/text())[1]','varchar(50)') + '#' +ISNULL(Table1.value('(Friday_Des/text())[1]','varchar(Max)'),' ')) as Friday,    
				(Table1.value('(Saturday/text())[1]','varchar(50)') + '#' + ISNULL(Table1.value('(Saturday_Des/text())[1]','varchar(Max)'),' ')) as Saturday,    
				(Table1.value('(Sunday/text())[1]','varchar(50)') + '#' +ISNULL(Table1.value('(Sunday_Des/text())[1]','varchar(Max)'),' ')) as Sunday    
				into #TSTemptable1 from @TSXML.nodes('/Timesheet/Table1')  as Temp(Table1)
				
				 
			
				DECLARE TIMESHEET_CURSOR CURSOR  Fast_forward FOR
				SELECT Project_ID,Task_ID,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday from #TSTemptable1
				OPEN TIMESHEET_CURSOR
				FETCH NEXT FROM TIMESHEET_CURSOR INTO @Project,@Task,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@Sun
				while @@fetch_status = 0
					Begin
						SELECT @Timesheet_Detail_ID = ISNULL(MAX(Timesheet_Detail_ID), 0) + 1 FROM T0110_TS_Application_Detail WITH (NOLOCK)
						INSERT INTO T0110_TS_Application_Detail(Timesheet_Detail_ID,Timesheet_ID,Project_ID,Task_ID,Mon,Tue,Wed,Thu,Fri,Sat,
						Sun,Cmp_ID,Created_By,Created_Date,Client_id)VALUES(@Timesheet_Detail_ID,@Timesheet_ID,@Project,@Task,@Mon,@Tue,@Wed,
						@Thu,@Fri,@Sat,@Sun,@Cmp_ID,@Created_By,GETDATE(),@Client_Id) 
						FETCH NEXT FROM TIMESHEET_CURSOR INTO @Project,@Task,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@Sun
					End
				CLOSE TIMESHEET_CURSOR     
				DEALLOCATE TIMESHEET_CURSOR
			End
		 		
	End
Else if @Trans_Type = 'D'
	Begin
		 
				Delete FROM T0110_TS_Application_Detail WHERE Timesheet_ID = @Timesheet_ID
			 
			DELETE FROM T0100_TS_Application WHERE Timesheet_ID = @Timesheet_ID
	End
 

