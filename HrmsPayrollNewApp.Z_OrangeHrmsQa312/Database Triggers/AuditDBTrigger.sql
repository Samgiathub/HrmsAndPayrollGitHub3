



CREATE TRIGGER [AuditDBTrigger]
    ON DATABASE
    FOR CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE,
		ALTER_SCHEMA, RENAME, ALTER_FUNCTION, CREATE_VIEW, ALTER_VIEW, ALTER_TABLE, CREATE_TABLE, ALTER_TRIGGER, CREATE_TRIGGER, DROP_TRIGGER
AS
BEGIN
    SET NOCOUNT ON;
	SET ANSI_WARNINGS ON;
	SET	ANSI_NULLS OFF; 	
	SET ANSI_PADDING ON;

    DECLARE @EventData XML = EVENTDATA();
        
    IF @EventData IS NULL
		RETURN;
 	
    
    DECLARE @EventType NVARCHAR(100);    
    SET @EventType = @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)');    

	if (@EventType = 'ALTER_PROCEDURE')
		BEGIN
			DECLARE @AllowModify BIT
			SET @AllowModify = 0
			SELECT Top 1 @AllowModify = Modify FROM AuditDB.dbo.PCDetail WHERE PCNAME = HOST_NAME() AND DBNAME=DB_NAME() Order by EffDate Desc						
			IF @AllowModify = 0
				BEGIN
					RAISERROR (N'This computer does not have a privilege to modify the stored procedure.', 10, -1)
					ROLLBACK
				END
		END
    
    DECLARE @COMMAND VARCHAR(MAX);
	SET @COMMAND = @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)')
	
	--IF CHARINDEX('DISABLEDBYADMIN',@COMMAND) > 0 
	--	RETURN;
	
	IF CHARINDEX('TRIGGER',@COMMAND) > 0 AND @EventType = 'ALTER_TABLE'
		RETURN;
	
	
	--DECLARE @OldData VARCHAR(Max)
	DECLARE @ObjectName Varchar(255) = @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]',  'NVARCHAR(255)');
	
	
	--DECLARE @LastHost VARCHAR(32);
	--SELECT	Top 1 @LastHost = HostName 
	--FROM	AuditDB.dbo.DDLEvents 
	--Where	DatabaseName=DB_NAME() AND ObjectName=@ObjectName AND Datediff(hh,EventDate, getdate()) < 8
	--Order By EventDate Desc
	
		
	--IF EXISTS(SELECT Top 1 FROM AuditDB.dbo.DDLEvents Where DatabaseName=DB_NAME() AND ObjectName=@ObjectName AND EventDDL=@COMMAND)
	--	RETURN;
	
	
	--IF @OldData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)') = @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)') 
	--	AND @OldData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)') IS NOT NULL
	--	RETURN;
	
	
	DECLARE @ip VARCHAR(32) =
        (
            SELECT client_net_address
                FROM sys.dm_exec_connections
                WHERE session_id = @@SPID
        );
    
	DECLARE @EventDate DATETIME
	SET @EventDate = GETDATE();
	
    INSERT AuditDB.dbo.DDLEvents
    (
        EventType,
        EventDDL,
        EventXML,
        DatabaseName,
        SchemaName,
        ObjectName,
        HostName,
        IPAddress,
        ProgramName,
        LoginName,
		EventDate
    )
    SELECT
        @EventType, 
        @COMMAND,
        @EventData,
        DB_NAME(),
        --@EventData.value('(/EVENT_INSTANCE/SchemaName)[1]',  'NVARCHAR(255)'), 
        '',
        @ObjectName,
        HOST_NAME(),
        @ip,
        PROGRAM_NAME(),
        SUSER_SNAME(),
		@EventDate
	END

	DECLARE @ObjectType Varchar(64)
	SET @ObjectType = @EventData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(25)');

	DECLARE	@ObjectTypeVal INT
	SELECT	@ObjectTypeVal =	CASE @ObjectType
									WHEN 'TABLE' THEN 0
									WHEN 'TRIGGER' THEN 2
									WHEN 'VIEW' THEN 4
									WHEN 'FUNCTION' THEN 8
									WHEN 'PROCEDURE' THEN 10													
									ELSE 11
								END
	IF NOT EXISTS(SELECT 1 FROM AuditDB.dbo.DDLEventOverview WHERE ObjectName=@ObjectName AND DatabaseName=DB_NAME())
		BEGIN
			INSERT INTO AuditDB.dbo.DDLEventOverview(DatabaseName,ObjectName,ObjectType,LastEventDate,IsReviewPending,LastUser,TotalCount)
			VALUES(DB_NAME(), @ObjectName, @ObjectTypeVal, GETDATE(), 1, HOST_NAME(), 0)
		END

	DECLARE @Count INT
	SELECT	@Count  = COUNT(1) FROM AuditDB.dbo.DDLEvents WHERE DatabaseName=DB_NAME()and ObjectName=@ObjectName
	
	UPDATE	AuditDB.dbo.DDLEventOverview
	SET		LastEventDate=	@EventDate,			
			IsReviewPending=1,
			LastUser=		HOST_NAME(),
			TotalCount=@Count
	WHERE	DatabaseName=DB_NAME() AND ObjectName=@ObjectName AND ObjectType=@ObjectTypeVal


			

	SET ANSI_PADDING OFF;
	SET	ANSI_NULLS ON; 
	SET ANSI_WARNINGS OFF;

















