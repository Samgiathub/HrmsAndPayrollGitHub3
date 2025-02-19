
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_Job_Master] 
 @job_Name 		varchar(max),
 @command varchar(Max)='',
 @from_Time varchar(200)='',
 @job_Id numeric = 0 output,
 @type Varchar(50) ='',
 @date_Run numeric(18,0) = 0,
 @Date_Weekly varchar(50) = '',
 @freq_Subday numeric(18,0) = 1,
 @freq_Subday_Interval numeric(18,0) = 1,
 @tran_Type char='I'
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF;

begin
--BEGIN Try 
 
 declare @Id as nvarchar(max)
 Declare @freq_type_Pass as numeric(18,0)
 declare @freq_interval_pass as numeric(18,0)
 Declare @step_Id as numeric(18,0)
 Declare @Schedule_id as numeric(18,0)
 
 
 set @freq_type_Pass = 4
 set @freq_interval_pass = 1
 
 if @freq_Subday=0
	set @freq_Subday=8
 
 declare @from_Date varchar(20)
	Declare @from_time_Final varchar(200)
	set @from_Date = CONVERT(VARCHAR(10),GETDATE(),112)
	set @from_time_Final = REPLACE(@from_Time,':','') + '00'

	Declare @Query as varchar(max)
	Declare @Query1 as varchar(max)
	Declare @Query2 as varchar(max)
	Declare @Query3 as varchar(max)
	Declare @Query4 as varchar(max)

	set @Query=''
	set @Query1=''
	set @Query2=''
	set @Query3 =''
	set @Query4 =''	

 
 
 if upper(@type)= 'DAILY'
 begin
	set @freq_type_Pass = 4
 end	
 else if upper(@type)= 'WEEKLY'
 begin
	set @freq_type_Pass = 8
	if upper(@Date_Weekly) ='SUNDAY'
	 set @freq_interval_pass	= 1	
	else if upper(@Date_Weekly) ='MONDAY'
		set @freq_interval_pass	= 2
	else if upper(@Date_Weekly) ='TUESDAY'
		Set @freq_interval_pass =4
	else if upper(@Date_Weekly) ='WEDNESDAY'
		Set @freq_interval_pass =8
	else if upper(@Date_Weekly) ='THURSDAY'
		Set @freq_interval_pass =16		
	else if upper(@Date_Weekly) ='FRIDAY'
		Set @freq_interval_pass =32
	else if upper(@Date_Weekly) ='SATURDAY'
		Set @freq_interval_pass =64	
			
 end
  else if upper(@type)= 'MONTHLY'
 	begin
 	 	set @freq_type_Pass = 16
 	 	set @freq_interval_pass = @date_Run
	end

 
 if  @tran_Type ='I'
	BEGIN

	
	
	set @Query = 'msdb.dbo.sp_add_job @job_name =' + cast(@job_Name as varchar(max) ) +';'
	set @Query1 ='msdb.dbo.sp_add_jobstep @job_name = '+ cast(@job_Name as varchar(max) ) + ',@step_name = '+ cast(@job_Name as varchar(max) ) +',@subsystem = ''TSQL'',@command = ''' + cast(@command as varchar(max)) +''', @database_name='+CAST(DB_NAME() as varchar) +',@retry_attempts = 5,@retry_interval = 5 ,@flags=0;'
	set @Query2 ='EXEC msdb.dbo.sp_add_schedule @schedule_name = '+cast(@job_Name as varchar(max) ) +',@enabled=1,@freq_type = '+ CAST(@freq_type_Pass as varchar(max))+ ',@freq_interval='+ Cast(@freq_interval_pass AS varchar(max))+',@freq_subday_type='+CAST(@freq_Subday as varchar(max))+',@freq_subday_interval='+CAST(@freq_Subday_Interval as varchar(max))+',@freq_relative_interval=0,@freq_recurrence_factor=1, @active_start_date='+ cast(@from_Date as varchar(max)) + ',@active_end_date=99991231,@active_start_time=' + cast(@from_time_Final as varchar(max)) + ', @active_end_time=235959;'
	set @Query3 ='EXEC msdb.dbo.sp_attach_schedule  @job_name =' +cast(@job_Name as varchar(max)) +', @schedule_name = '+cast(@job_Name as varchar(max) ) +';'
	set @Query4 ='EXEC msdb.dbo.sp_add_jobserver @job_name =' + CAST(@job_Name as varchar(max)) + ';'

	exec(@Query);
	exec(@Query1);
	exec(@Query2);
	exec(@Query3);
	exec(@Query4);
	set @job_Id =1


	end
	else if  @tran_Type ='U'
	 begin
	 select @step_Id=step_id from msdb.dbo.sysjobsteps where step_name =   REPLACE(@job_Name,'''','')  
	 select @Schedule_id=schedule_id  from msdb.dbo.sysschedules where name =   REPLACE(@job_Name,'''','')  
	--set @Query = 'msdb.dbo.sp_add_job @job_name =' + cast(@job_Name as varchar(max) ) +';'
	set @Query1 ='msdb.dbo.sp_update_jobstep  @step_Id = ' +  cast(@step_Id as varchar(max) ) + ',@job_name = '+ cast(@job_Name as varchar(max) ) + ',@step_name = '+ cast(@job_Name as varchar(max) ) +',@subsystem = ''TSQL'',@command = ''' + cast(@command as varchar(max)) +''', @database_name='+CAST(DB_NAME() as varchar) +',@retry_attempts = 5,@retry_interval = 5 ,@flags=0;'
	set @Query2 ='EXEC msdb.dbo.sp_update_schedule '+  cast(@Schedule_id as varchar(max) ) +',@enabled=1,@freq_type = '+ CAST(@freq_type_Pass as varchar(max))+ ',@freq_interval='+ Cast(@freq_interval_pass AS varchar(max))+',@freq_subday_type='+CAST(@freq_Subday as varchar(max))+',@freq_subday_interval='+CAST(@freq_Subday_Interval as varchar(max))+',@freq_relative_interval=0,@freq_recurrence_factor=1, @active_start_date='+ cast(@from_Date as varchar(max)) + ',@active_end_date=99991231,@active_start_time=' + cast(@from_time_Final as varchar(max)) + ', @active_end_time=235959;'
	--set @Query3 ='EXEC msdb.dbo.sp_attach_schedule  @job_name =' +cast(@job_Name as varchar(max)) +', @schedule_name = '+cast(@job_Name as varchar ) +';'
	--set @Query4 ='EXEC msdb.dbo.sp_add_jobserver @job_name =' + CAST(@job_Name as varchar(max)) + ';'

	--exec(@Query);
	exec(@Query1);
	exec(@Query2);
	exec(@Query3);
	exec(@Query4);
	set @job_Id =1
	 
	 end
	else if @tran_Type ='D'
	begin 
	
		set @job_Name = replace(@job_Name,'''','')
		IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @job_Name)
		begin
			SELECT @Id = job_id FROM msdb.dbo.sysjobs_view WHERE name = @job_Name
			EXEC msdb.dbo.sp_delete_job @job_id=@Id, @delete_unused_schedule=1
		end
		IF  EXISTS (SELECT schedule_id FROM msdb.dbo.sysschedules  WHERE name = @job_Name)
		begin
		EXEC msdb.dbo.sp_delete_schedule @schedule_name = @job_Name,@force_delete = 1;
		end
		set @job_Id = 2
	end
	
		return 
end
--END Try
--Begin Catch
--	set @job_Id =0
--End Catch
