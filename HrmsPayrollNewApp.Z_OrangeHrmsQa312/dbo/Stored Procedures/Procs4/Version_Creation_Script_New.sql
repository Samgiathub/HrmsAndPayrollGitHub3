



-- created by rohit for create version script on 29122016
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Version_Creation_Script_New]
	@Proc_name varchar(500) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


if exists(select 1 from tempdb.dbo.sysobjects where name ='##TMP_VERSION')
BEGIN
	DROP table ##TMP_VERSION
END

if @Proc_name = ''
	set @Proc_name = NULL 

--This is to configure the xp_cmdshell command.  
 IF NOT EXISTS(SELECT * FROM sys.configurations WHERE name = 'xp_cmdshell' AND value=1) BEGIN  
  
  --configuring xp command  
  EXEC sp_configure 'show advanced option', 1  
  RECONFIGURE  
  
  
  EXEC sp_configure 'xp_cmdshell', 1  
  RECONFIGURE  
 END  

CREATE TABLE ##TMP_VERSION (ID [numeric](18, 0) IDENTITY(1,1) NOT NULL,DDL NVARCHAR(MAX));

declare @cur_Name as NVARCHAR(max)
Declare @Flag as char(3)
Declare @parent_Name as NVARCHAR(max)
declare @Crdate AS DATETIME     
Declare CusrProcedureMST cursor for	  
--select distinct name from 
--sys.procedures 
--where
-- --modify_date > '20-sep-2016' and 
--name not in ('Version_Creation_Script','p_generate_script','sp_helptextNew','INFGenerateStoredProcedureScript')
----order by modify_date asc
select S.name,S.xtype,pS.name,s.Crdate from sysobjects S
left JOIN sysobjects pS on S.parent_Obj = pS.id
where s.Xtype in ('P','V','TR','FN','TF') 
and s.name not in ('Version_Creation_Script','p_generate_script','sp_helptextNew','INFGenerateStoredProcedureScript','P_Default_Resource_Entry','default_resource_form','Version_Creation_Script_New')
and s.name = ISNULL(@Proc_name,S.name)
--and S.name='Insert_Default_Mail_Settings'
--and s.name='Tri_T0100_LEAVE_CF_Advance_Leave_Balance'
--and s.name='P0200_Salary_Budget'
order BY S.xTYPE DESC,s.Crdate ASC
Open CusrProcedureMST
Fetch next from CusrProcedureMST into @cur_Name,@Flag,@parent_Name,@Crdate
While @@fetch_status = 0                    
	Begin     
		
  insert into ##TMP_VERSION values ('IF NOT EXISTS(SELECT 1')
  insert into ##TMP_VERSION values ('                FROM Sysobjects')
  insert into ##TMP_VERSION values ('               WHERE name = ''' + @cur_Name + '''')
  insert into ##TMP_VERSION values ('                 AND Xtype in (''P'',''V'',''TR'',''FN'',''TF''))')
  insert into ##TMP_VERSION values ('BEGIN')
  if (@Flag = 'P')
  begin
	insert into ##TMP_VERSION values ('    EXEC (''CREATE PROCEDURE [dbo].[' + @cur_Name + '] AS BEGIN SELECT 1 END'')')
  end
  else if (@Flag = 'V')
  begin
	  insert into ##TMP_VERSION values ('    EXEC (''CREATE VIEW [dbo].[' + @cur_Name + '] AS SELECT 1 as new'')')
  end
  else If (@Flag = 'TR')
  begin
	  insert into ##TMP_VERSION values ('    EXEC (''CREATE TRIGGER [dbo].[' + @cur_Name + '] on [dbo].['+ @parent_Name +'] for Insert AS  SELECT 1 '')')
  end
  else If (@Flag = 'TF')
  begin
	  insert into ##TMP_VERSION values ('    EXEC (''CREATE FUNCTION [dbo].[' + @cur_Name + '] () returns @Emp Table( EmpID int ) AS BEGIN Insert into @Emp Select 1  RETURN END'')')
  end
  else  
  BEGIN
	 insert into ##TMP_VERSION values ('    EXEC (''CREATE FUNCTION [dbo].[' + @cur_Name + '] ( @check int ) returns int AS BEGIN set @check = 1  RETURN  @check  END'')')
	 --insert into ##TMP_VERSION values ('  EXEC ('CREATE FUNCTION [dbo].[fnc_NumberOfWeekEnds] '
  --  '( '
  --  '@check int'
  --  ') '
  -- 'RETURNS int '
  --  'AS '
  -- ' BEGIN '
  --  set @check = 1  
  --  RETURN  @check  
  --  END')
  END
  
  
  insert into ##TMP_VERSION values ('END')
  insert into ##TMP_VERSION values ('GO ')
  insert into ##TMP_VERSION values (' ')
  insert into ##TMP_VERSION values ('GO')
	print @cur_Name
	INSERT INTO ##TMP_VERSION
	--select replace(left(ISNULL(smsp.definition, ssmsp.definition),CHARINDEX('[' + @cur_Name + ']' ,ISNULL(smsp.definition, ssmsp.definition))- 1 ),'Create ','Alter ') + right(ISNULL(smsp.definition, ssmsp.definition),len(ISNULL(smsp.definition, ssmsp.definition)) - CHARINDEX('[' + @cur_Name + ']',ISNULL(smsp.definition, ssmsp.definition)) + 1 )AS [Definition]
	--select replace(left(ISNULL(smsp.definition, ssmsp.definition),CHARINDEX('dbo' ,ISNULL(smsp.definition, ssmsp.definition))- 1 ),'Create ','Alter ') + right(ISNULL(smsp.definition, ssmsp.definition),len(ISNULL(smsp.definition, ssmsp.definition)) - CHARINDEX('dbo',ISNULL(smsp.definition, ssmsp.definition)) + 1 )AS [Definition]
	--select replace(left(ISNULL(smsp.definition, ssmsp.definition),len(ISNULL(smsp.definition, ssmsp.definition)) - CHARINDEX(@cur_Name ,reverse(ISNULL(smsp.definition, ssmsp.definition))) ),'Create ','Alter ') AS [Definition]
	--select replace(left(ISNULL(smsp.definition, ssmsp.definition),len(ISNULL(smsp.definition, ssmsp.definition)) - CHARINDEX(reverse(@cur_Name) ,reverse(ISNULL(smsp.definition, ssmsp.definition))) + 1 ),'Create ','Alter ')  + right(ISNULL(smsp.definition, ssmsp.definition),len(ISNULL(smsp.definition, ssmsp.definition)) - CHARINDEX(@cur_Name ,ISNULL(smsp.definition, ssmsp.definition)) - LEN(@cur_Name)+1)  AS [Definition]
	--SELECT replace(left(ISNULL(smsp.definition, ssmsp.definition),len(ISNULL(smsp.definition, ssmsp.definition)) - CHARINDEX(reverse(@cur_Name) ,reverse(ISNULL(smsp.definition, ssmsp.definition))) + 1 ),'Create ','Alter ')  + right(ISNULL(smsp.definition, ssmsp.definition), CHARINDEX(reverse(@cur_Name) ,reverse(ISNULL(smsp.definition, ssmsp.definition)))  )  AS [Definition]
	select replace(left(ISNULL(smsp.definition, ssmsp.definition) , dbo.GetLastCharIndex(ISNULL(smsp.definition, ssmsp.definition),@cur_Name) - 1 ),N'CREATE ',N'ALTER ') + SUBSTRING(ISNULL(smsp.definition, ssmsp.definition),dbo.GetLastCharIndex(ISNULL(smsp.definition, ssmsp.definition),@cur_Name),LEN(ISNULL(smsp.definition, ssmsp.definition)) - dbo.GetLastCharIndex(ISNULL(smsp.definition, ssmsp.definition),@cur_Name)+1) as [Definition]
	FROM
	sys.all_objects AS sp
	LEFT OUTER JOIN sys.sql_modules AS smsp ON smsp.object_id = sp.object_id
	LEFT OUTER JOIN sys.system_sql_modules AS ssmsp ON ssmsp.object_id = sp.object_id
	where sp.name = @cur_Name
	and @cur_Name not in ('SP_IT_TAX_PREPARATION','Set_Emp_Salary_Structure','Tri_T0130_LEAVE_APPROVAL_DETAIL','P_Profiler_Start','SP_CALCULATE_PRESENT_DAYS','Set_Salary_Register_Amount_Transfer','Insert_Default_Mail_Settings','SP_RPT_EMP_ATTENDANCE_MUSTER_GET','Get_Recruitment_Application_Records','Get_Candidate_Approval_Record','Get_Appraisal_ScoreSummary_Yearly')

	INSERT INTO ##TMP_VERSION
	select replace(left(ISNULL(smsp.definition, ssmsp.definition),CHARINDEX(@cur_Name,ISNULL(smsp.definition, ssmsp.definition))- 1 ),N'Create ',N'Alter ') + right(ISNULL(smsp.definition, ssmsp.definition),len(ISNULL(smsp.definition, ssmsp.definition)) - CHARINDEX(@cur_Name,ISNULL(smsp.definition, ssmsp.definition)) + 1 )AS [Definition]
	FROM
	sys.all_objects AS sp
	LEFT OUTER JOIN sys.sql_modules AS smsp ON smsp.object_id = sp.object_id
	LEFT OUTER JOIN sys.system_sql_modules AS ssmsp ON ssmsp.object_id = sp.object_id
	where sp.name = @cur_Name
	and @cur_Name in ('SP_IT_TAX_PREPARATION','Set_Emp_Salary_Structure','Tri_T0130_LEAVE_APPROVAL_DETAIL','P_Profiler_Start','SP_CALCULATE_PRESENT_DAYS','Set_Salary_Register_Amount_Transfer','Insert_Default_Mail_Settings','SP_RPT_EMP_ATTENDANCE_MUSTER_GET','Get_Recruitment_Application_Records','Get_Candidate_Approval_Record','Get_Appraisal_ScoreSummary_Yearly')

  insert into ##TMP_VERSION values ('GO')
  --insert into ##TMP_VERSION values (' ')
  	
fetch next from CusrProcedureMST into @cur_Name,@Flag,@parent_Name,@Crdate
	end
	close CusrProcedureMST                    
	deallocate CusrProcedureMST

-- For Generate file from script table data

DECLARE @FileName NVARCHAR(500),
        @bcpCommand NVARCHAR(2000),
        @D_path NVARCHAR(1000)
		
		set @D_path = 'E:\Version\'
		
EXEC master.dbo.xp_create_subdir @D_path
SET @FileName = REPLACE(@D_path + cast(SERVERPROPERTY('MachineName') as NVARCHAR(100))+'_'+ cast(SERVERPROPERTY('InstanceName') as NVARCHAR(100)) + '_'+ DB_NAME() + '_Script1_'+CONVERT(char(8),GETDATE(),1)+'.sql','/','-')

SET @bcpCommand = 'bcp "SELECT DDL FROM [ACER-7\SQL08R2].[orange_hrms].dbo.[##TMP_VERSION] ORDER BY ID ASC" queryout "'
SET @bcpCommand = @bcpCommand + @FileName + '" -U sa -P orange505  -w -T  -S ACER-7\SQL08R2'

EXEC master..xp_cmdshell @bcpCommand

End

