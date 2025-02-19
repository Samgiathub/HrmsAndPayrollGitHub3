

--Created by rohit For Check menu Search option with Module rights.
--Created date 23072015
CREATE PROCEDURE [dbo].[Get_Menu_Detail]  
@cmp_id Numeric(18,0) = 0,
@Privilege_Id numeric(18,0) = 0,
@Url nvarchar(100)=''
AS        
		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON  
	declare @Module_Status as varchar(max)
	
	select @Module_Status= COALESCE(@Module_Status + ',', '') +  '''' + module_name + ''''
					from T0011_module_detail WITH (NOLOCK)
					where Cmp_id = @cmp_id and module_status=1	
	declare @query nvarchar(max);
	set @query=''
	
if @Privilege_Id = 0
	set @query = 'select form_id,form_name ,form_url,form_image_url,under_form_id,Alias as Alias  from t0000_default_form WITH (NOLOCK) where  (Module_name  in (' + isnull(@Module_Status,'''''') + ') OR Module_Name IS NULL)'
else
	set @query = 'select form_id,form_name as Form_name,form_url,form_image_url,under_form_id, Alias as Alias   FROM V0020_PRIVILEGE_MASTER_DETAILS where  (Module_name  in (' + isnull(@Module_Status,'''''') + ') OR Module_Name IS NULL) and is_active=1 and Privilege_ID =' + cast(@Privilege_Id as varchar(20))+ ''
 

--if @Url ='HRMS'
--	set @query = @query +  'and Form_id >= 6500 and Form_id < 6700 and Form_url <> ''HRMS/HR_Home.aspx'' and isnull(form_url,'''') <> '''' and is_active_for_menu = 1 '
--else		
--	set @query = @query +   'and Form_id > 6000 and Form_id < 6500 and is_active_for_menu = 1 and Form_url<>''Home.aspx'' and isnull(form_url,'''') <> '''' and  is_active_for_menu = 1' 	

if @Url ='HRMS'
	set @query = @query +  'and Page_Flag=''HP'' and Form_url <> ''HRMS/HR_Home.aspx'' and isnull(form_url,'''') <> '''' and is_active_for_menu = 1 '
else		
	set @query = @query +   'and  Page_Flag=''AP'' and is_active_for_menu = 1 and Form_url<>''Home.aspx'' and isnull(form_url,'''') <> '''' and  is_active_for_menu = 1' 	

	
set @query = @query + ' order by sort_id,Sort_Id_Check'	

	exec(@query);
	
return
	


