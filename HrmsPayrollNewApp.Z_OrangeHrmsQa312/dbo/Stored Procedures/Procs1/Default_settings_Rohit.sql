




-- Created By rohit for update default setting to all company on 31012013
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Default_settings_Rohit]        
AS        
begin
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @curCMP_ID numeric
	
	Declare CusrCompanyMST cursor for	                  
	select CMP_ID from t0010_company_master WITH (NOLOCK) where IS_Active=1
	Open CusrCompanyMST
	Fetch next from CusrCompanyMST into @curCMP_ID
	While @@fetch_status = 0                    
		Begin     
			declare @StrSetting as Varchar(100)
			
			--set @strsetting = 'exec Insert_Default_Settings ' + cast(@curCMP_ID as varchar) --commented by Mukti(31082016)
			exec Insert_Default_Settings @curCMP_ID 
			exec Insert_Default_Display_Fields @curCMP_ID			
			exec Insert_Default_Mail_Settings_New @curCMP_ID
			exec Insert_Default_Mandatory_Fields @curCMP_ID
			exec Update_Default_Mail_Settings_New @curCMP_ID
		--select  @strsetting
		--	exec(@strsetting) --commented by Mukti(31082016)
			fetch next from CusrCompanyMST into @curCMP_ID	
		end
		close CusrCompanyMST                    
		deallocate CusrCompanyMST
	return
	end

