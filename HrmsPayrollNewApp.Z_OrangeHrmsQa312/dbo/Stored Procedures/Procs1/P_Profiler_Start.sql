

-- created by rohit for trace record without profiler.
-- created date 21032016
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Profiler_Start]
(
	@profiler_Status NVARCHAR(1000)='' output,
	@server_path sql_variant = 'C:\orange_hrms.trc',
	@trans_type char(1) = 'I',
	@Str_Event varchar(1000) = '10#12'
)
as

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

begin

declare @rc int
declare @TraceID int
declare @db_name as NVARCHAR(256)
declare @on bit
Declare @trace_path as NVARCHAR(2000)
DECLARE @File_Exist INT
declare @TraceToStop int
Declare @command as NVARCHAR(2000)
--declare @Str_Event varchar(max)

set @db_name = DB_NAME()

--select @server_path = LEFT (physical_name, CHARINDEX(@db_name, physical_name) - 1) + @db_name + '.trc' from sys.master_files where database_id = DB_ID(@db_name) and type=1

SELECT @server_path = SUBSTRING(physical_name, 1, CHARINDEX(N'master.mdf', LOWER(physical_name)) - 1) + @db_name + '.trc' FROM master.sys.master_files WHERE database_id = 1 AND file_id =1

set @trace_path = left (cast(@server_path as NVARCHAR(max)),LEN(cast(@server_path as NVARCHAR(max))) - 4) 

-- Check file Exist on path
EXEC master.dbo.xp_fileexist @server_path , @File_Exist OUTPUT



if @trans_type = 'I'
begin
	if @File_Exist = 1
	begin

		select @TraceToStop = TraceId from fn_trace_getinfo(default) where value = @server_path
		if isnull(@TraceToStop,0) <> 0
		begin 
			exec sp_trace_setstatus @TraceToStop, 0
			exec sp_trace_setstatus @TraceToStop, 2
		end
		--EXECUTE master.dbo.xp_delete_file 0,@server_path 
		
		set @command = 'DEL "'  + CAST(@server_path as NVARCHAR(1000)) + '"'
		
		EXEC xp_cmdshell @command
		

	end

	-- ALTER the trace
	
	exec @rc = sp_trace_create @TraceID output, 0, @trace_path

	-- set which events to capture
	set @on = 1
	
	--set @Str_Event = '10#12'
	--set @Str_Event = '11#13#43'
	
	declare @curevent_id int
	
	Declare CusrEventMST cursor for	                  
	SELECT cast(data  as numeric)  FROM dbo.Split(@Str_Event,'#') T
	Open CusrEventMST
	Fetch next from CusrEventMST into @curevent_id
	While @@fetch_status = 0                    
		Begin     
	
	
	exec sp_trace_setevent @TraceID, @curevent_id, 1, @on
	--exec sp_trace_setevent @TraceID, @curevent_id, 2, @on
	exec sp_trace_setevent @TraceID, @curevent_id, 6, @on
	exec sp_trace_setevent @TraceID, @curevent_id, 9, @on
	exec sp_trace_setevent @TraceID, @curevent_id, 10, @on
	exec sp_trace_setevent @TraceID, @curevent_id, 11, @on
	exec sp_trace_setevent @TraceID, @curevent_id, 12, @on
	--exec sp_trace_setevent @TraceID, @curevent_id, 13, @on ' commented due to starting event start on 
	exec sp_trace_setevent @TraceID, @curevent_id, 14, @on
	--exec sp_trace_setevent @TraceID, @curevent_id, 15, @on 
	--exec sp_trace_setevent @TraceID, @curevent_id, 16, @on
	--exec sp_trace_setevent @TraceID, @curevent_id, 17, @on
	--exec sp_trace_setevent @TraceID, @curevent_id, 18, @on
	exec sp_trace_setevent @TraceID, @curevent_id, 35, @on
	
	fetch next from CusrEventMST into @curevent_id	
	end
	close CusrEventMST                    
	deallocate CusrEventMST

	--exec sp_trace_setevent @TraceID, 12, 1, @on
	--exec sp_trace_setevent @TraceID, 12, 6, @on
	--exec sp_trace_setevent @TraceID, 12, 9, @on
	--exec sp_trace_setevent @TraceID, 12, 10, @on
	--exec sp_trace_setevent @TraceID, 12, 11, @on
	--exec sp_trace_setevent @TraceID, 12, 12, @on
	--exec sp_trace_setevent @TraceID, 12, 13, @on
	--exec sp_trace_setevent @TraceID, 12, 14, @on
	--exec sp_trace_setevent @TraceID, 12, 15, @on
	--exec sp_trace_setevent @TraceID, 12, 16, @on
	--exec sp_trace_setevent @TraceID, 12, 17, @on
	--exec sp_trace_setevent @TraceID, 12, 18, @on
	--exec sp_trace_setevent @TraceID, 12, 35, @on
	
	-- Set filter of trace
	exec sp_trace_setfilter @TraceID,35, 0,6, @db_name

	-- start the trace
	exec sp_trace_setstatus @TraceID, 1
	
end
else if @trans_type = 'R'  -- Read trace File
begin
	
	
	SELECT EventClass, Events.Name As EventClassName, Replace(cast(TextData as nvarchar(max)),'amp;amp;','') as TextData , DatabaseName ,
	Duration, StartTime, EndTime, Reads, Writes
	--INTO Trace_Cols
	FROM fn_trace_gettable(cast(@server_path as NVARCHAR(100)), default) Trace
	INNER JOIN sys.trace_events Events
		ON Trace.EventClass = Events.trace_event_id
	WHERE ApplicationName <> 'Report Server'
	--AND EventClass IN (12,10)  
	AND SUBSTRING(Replace(cast(TextData as nvarchar(max)),'amp;amp;',''), 1,24 ) <> 'exec sp_reset_connection' AND SUBSTRING(Replace(cast(TextData as nvarchar(max)),'amp;amp;',''), 1,21 ) <> 'exec P_Profiler_Start' 
	ORDER BY Starttime

end
else if @trans_type = 'S'  -- Stop tracing file
begin

		select @TraceToStop = TraceId from fn_trace_getinfo(default) where value = @server_path
		exec sp_trace_setstatus @TraceToStop, 0
		exec sp_trace_setstatus @TraceToStop, 2
		
end


	return
end


