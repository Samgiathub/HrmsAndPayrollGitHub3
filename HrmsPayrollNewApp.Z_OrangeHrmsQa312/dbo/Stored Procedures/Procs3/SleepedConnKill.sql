



---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SleepedConnKill] --15-OCT-2010 -- GIVE NAME SleepedConnKill	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    Declare @StrKill Varchar(30)									
    Declare @SPID_Cur Numeric(18,0)
			
			Declare SysProcess_Cursor Cursor LOCAL  For
			  Select SPID From master..sysprocesses  Where SPID>50 And  Status='sleeping' --And  DateDiff(MINUTE ,Last_Batch,GetDate())>5	
			Open SysProcess_Cursor
			Fetch Next From SysProcess_Cursor Into @SPID_Cur
			While @@Fetch_Status = 0                    
			Begin   
				
					Set @StrKill = 'KILL '+ convert(varchar(10),@SPID_Cur)												
					EXEC(@StrKill)				
				
			Fetch Next From SysProcess_Cursor Into @SPID_Cur
			End				
			Close SysProcess_Cursor
			Deallocate SysProcess_Cursor
    Return




