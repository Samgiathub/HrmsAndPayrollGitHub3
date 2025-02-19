-- =============================================
-- Author:		Samir
-- Create date: 25Nov2024
-- Description:	Log archived
-- =============================================
CREATE PROCEDURE [dbo].[SpLogsArchived] 	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRANSACTION;

	SET IDENTITY_INSERT LogsArchived ON;
	-- Insert into destination table
	INSERT INTO LogsArchived (
		   [Id]
	      ,[Message]
	      ,[MessageTemplate]
	      ,[Level]
	      ,[TimeStamp]
	      ,[Exception]
	      ,[Properties]
	      ,[LogEvent])
	SELECT [Id]
	      ,[Message]
	      ,[MessageTemplate]
	      ,[Level]
	      ,[TimeStamp]
	      ,[Exception]
	      ,[Properties]
	      ,[LogEvent]
	  FROM [dbo].[Logs]
	
	  SET IDENTITY_INSERT LogsArchived OFF;
	-- Delete from source table
	DELETE FROM Logs;
	
	COMMIT;

END
