


-- Created by rohit For Send Active Employee mail on 10122013
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_Active Employee_Info]
as

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @CurDBName varchar(max)
	
	Declare CusrCompanyMST cursor for	                  
	select name from sys.databases where database_id > 5  
	Open CusrCompanyMST
	Fetch next from CusrCompanyMST into @CurDBName
	While @@fetch_status = 0                    
		Begin     
			declare @StrSetting as Varchar(max)
			
			--set @strsetting = 'exec Insert_Default_Settings ' + cast(@curCMP_ID as varchar) 

		--select  @strsetting
			--exec(@strsetting)
			
			set @strsetting = 'USE msdb
			GO			
			EXEC sp_send_dbmail @profile_name=''Orange1'',
			@recipients=''Rohit@orangewebtech.com'',
			@subject= ''' + cast(@CurDBName as varchar) + ' Employee Information'',
			@body=''Dear Sir,
			This Week Active Employee Count of '+ cast(@CurDBName as varchar) + 'are given below'', @query = ''use ' + cast(@CurDBName as varchar) + ' ;select count(Emp_ID) as Active_Emp From T0080_Emp_Master WITH (NOLOCK) where Emp_Left<>''''y'''' and Cmp_Id not in (select Cmp_id from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Name like ''''%orange%'''' or Cmp_Name like ''''%Demo%''''); select count(Emp_ID) as Total_Emp From T0080_Emp_Master WITH (NOLOCK) where  Cmp_Id not in (select Cmp_id from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Name like ''''%orange%'''' or Cmp_Name like ''''%Demo%'''')'''

			--select @strsetting
			exec (@strsetting)
			fetch next from CusrCompanyMST into @CurDBName	
		end
		close CusrCompanyMST                    
		deallocate CusrCompanyMST
	
	
	

