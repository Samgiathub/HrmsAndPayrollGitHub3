

 
 
 ---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_Task_Master]         
	@Task_ID NUMERIC output,        
	@Task_Name VARCHAR(50),         
	@Task_Code VARCHAR(50),         
	@Task_Description VARCHAR(MAX),         
	@Task_Priority VARCHAR(50),        
	@Task_Type_ID NUMERIC(18,0),  
	@Project_ID varchar(MAX),  
	@Due_Date DATETIME,  
	@Duration varchar(50),  
	@Completed INT,  
	@IsReOpen INT,  
	@Project_Status_ID NUMERIC,  
	@Milestone_ID NUMERIC(18,0),  
	@Deadline_Date Datetime,  
	@All_Employee_Task int,  
	@All_Project_Task int,  
	@Estimate_Cost NUMERIC(18,2),  
	@Estimate_Duration VARCHAR(50),  
	@Task_Attachment VARCHAR(MAX),  
	@Cmp_ID NUMERIC(18,0),
	@Created_By NUMERIC(18,0),  
	@Emp_ID varchar(MAX),   
	@Trans_Type varchar(1) 
 
AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Task_Detail_ID NUMERIC(18,0)   
DECLARE @ID NUMERIC(18,0)        
IF @Task_Type_ID = 0
	SET @Task_Type_ID = NULL
IF @Project_Status_ID = 0
	SET @Project_Status_ID = NULL
IF @Milestone_ID = 0 
	SET @Milestone_ID = NULL
IF @Trans_Type  = 'I'        
	BEGIN
		--If Exists (SELECT Task_ID FROM T0040_Task_Master WHERE Cmp_ID = @Cmp_ID AND UPPER(Task_Name) = UPPER(@Task_Name))
		-- BEGIN        
		--  SET @Task_ID = 0        
		--   RETURN        
		-- END  
  
		DECLARE Task_Master_CURSOR CURSOR FOR SELECT data FROM dbo.Split(@Project_ID,'#')
		OPEN Task_Master_CURSOR        
		FETCH NEXT FROM Task_Master_CURSOR INTO @ID        
		WHILE @@FETCH_STATUS = 0        
			BEGIN        
				IF NOT EXISTS(SELECT Task_ID FROM T0040_Task_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(Task_Name) = UPPER(@Task_Name) AND Project_ID = @ID AND IsReOpen = 1 )
					BEGIN
						SELECT @Task_ID = ISNULL(MAX(Task_ID), 0) + 1 FROM T0040_Task_Master WITH (NOLOCK)        
						INSERT INTO T0040_Task_Master(Task_ID,Task_Name,Task_Code,Task_Description,Task_Priority,Task_Type_ID,Project_ID,Due_Date,Duration,Completed,
						IsReOpen,Project_Status_ID,Milestone_ID,Deadline_Date,All_Employee_Task,All_Project_Task,Estimate_Cost,Estimate_Duration,Task_Attachment,Cmp_ID,
						Created_By,Created_Date )
						VALUES(@Task_ID,@Task_Name,@Task_Code,@Task_Description,@Task_Priority,@Task_Type_ID,@ID,@Due_Date,@Duration,@Completed,@IsReOpen,
						@Project_Status_ID,@Milestone_ID,@Deadline_Date,@All_Employee_Task,@All_Project_Task,@Estimate_Cost,@Estimate_Duration,@Task_Attachment,
						@Cmp_ID,@Created_By,GETDATE())
					END
					 

				FETCH NEXT FROM Task_Master_CURSOR INTO @ID
			END        
	   CLOSE Task_Master_CURSOR        
	   DEALLOCATE Task_Master_CURSOR 
 --  if @Emp_ID <> ''
	--begin       
	--   DECLARE TASK_CURSOR CURSOR FOR SELECT data from dbo.Split(@Emp_ID,'#')        
	           
	--   OPEN TASK_CURSOR        
	--   FETCH NEXT FROM TASK_CURSOR INTO @ID        
	--   while @@fetch_status = 0        
	--	BEGIN        
	--	 SELECT @Task_Detail_ID = ISNULL(MAX(Task_Detail_ID), 0) + 1 FROM T0050_Task_Detail        
	--	 INSERT INTO T0050_Task_Detail(Task_Detail_ID,Task_ID,Assign_To,Project_ID,Cmp_ID,Created_By,        
	--	 Created_Date)VALUES (@Task_Detail_ID,@Task_ID,@ID,@Project_ID,@Cmp_ID,@Created_By,GETDATE())         
	--	 FETCH NEXT FROM TASK_CURSOR INTO @ID    
	--	END        
	--   CLOSE TASK_CURSOR        
	--   DEALLOCATE TASK_CURSOR 
	--end       
           
           
	END
ELSE IF @Trans_Type = 'U'        
	BEGIN
		IF EXISTS (SELECT Task_ID FROM T0040_Task_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(Task_Name) = UPPER(@Task_Name) AND Task_ID <> @Task_ID AND IsReOpen = 1)        
			BEGIN
				SET @Task_ID = 0
				RETURN
			END
		UPDATE T0040_Task_Master SET Task_Name = @Task_Name,Task_Code = @Task_Code, Task_Description = @Task_Description,  
		Task_Priority = @Task_Priority,Task_Type_ID = @Task_Type_ID,Project_ID = @Project_ID,Due_Date = @Due_Date,  
		Duration = @Duration,Completed = @Completed,IsReOpen = @IsReOpen,Project_Status_ID = @Project_Status_ID,  
		Milestone_ID =@Milestone_ID,Deadline_Date = @Deadline_Date,All_Employee_Task = @All_Employee_Task,  
		All_Project_Task = @All_Project_Task,Estimate_Cost = @Estimate_Cost,Estimate_Duration = @Estimate_Duration,  
		Task_Attachment = @Task_Attachment,Cmp_ID = @Cmp_ID, Modify_By = @Created_By,Modify_Date = GETDATE()
		WHERE Task_ID = @Task_ID
	 END        
ELSE IF @Trans_Type = 'D'        
	BEGIN       
		DELETE FROM T0050_Task_Detail WHERE Task_ID = @Task_ID        
		DELETE FROM T0040_Task_Master WHERE Task_ID = @Task_ID        
	END 



