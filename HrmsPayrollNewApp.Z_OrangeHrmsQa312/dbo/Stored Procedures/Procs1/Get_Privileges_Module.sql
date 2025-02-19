

-- Created By Sumit 14072015
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Privileges_Module]  
@cmp_id Numeric = 0,
@Flag_ESS tinyint=0
--@Flag_Menu tinyint=0
AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @Module_Status as varchar(max)
	
	--select @Module_Status=Left((select  ''''+ module_name +'''' + ',' 
	--			from T0011_module_detail 
	--			where Cmp_id = @cmp_id and module_status=1
	--			for XML Path('')) + '',
	--			LEN((select '''' + module_name +'''' + ',' 
	--				from T0011_module_detail 
	--				where Cmp_id = @cmp_id and module_status=1
	--		for XML Path('')) + '') - 1 )
	
	--select @Module_Status= COALESCE(@Module_Status + ',', '') +  '''' + module_name + ''''
	--				from T0011_module_detail 
	--				where Cmp_id = @cmp_id and module_status=1	
	--	declare @query nvarchar(max);
	select @Module_Status= COALESCE(@Module_Status + ',', '') +  '''' + module_name + ''''
					from T0011_module_detail WITH (NOLOCK)
					where Cmp_id = @cmp_id and module_status=1	
	declare @query nvarchar(max);
	set @query=''
	if @Flag_ESS=1
		begin
		set @query='';
		
		set @query='select * from T0000_DEFAULT_FORM WITH (NOLOCK)
				where ((Form_Id > 7000 and form_id <=9000) or (form_id >9200) ) 
				and Is_Active_For_menu = 1 and (Module_name in (' + isnull(@Module_Status,'''''') + ') or Module_Name IS NULL)				
				order by Sort_ID,Sort_id_check'
		Exec (@query)		
		End
	Else if @Flag_ESS=0
		Begin
			set @query='';
			
			set @query = 'select * from T0000_DEFAULT_FORM WITH (NOLOCK)
							where Form_Id > 6000 and Is_Active_For_menu = 1 
							and (Module_name  in (' + isnull(@Module_Status,'''''') + ') OR Module_Name IS NULL)
							order by Sort_ID,Sort_id_check';			
			
			exec(@query);
			
	End	
	
--select Distinct F.* from 
--T0000_DEFAULT_FORM  F LEFT OUTER JOIN T0011_module_detail M ON F.Module_name=M.module_name OR F.Module_name IS NULL
--where Form_Id > 6000 and Is_Active_For_menu = 1 AND Cmp_id = 55 and module_status=1
--order by Sort_ID,Sort_id_check
			
		
		
return
	


