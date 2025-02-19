

-- Created By rohit on 11012016
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[GET_Emp_Privilege_Import]
	
	@CMP_ID AS numeric,
	@Privilege_ID AS numeric
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Begin

	
	declare @Module_Status as varchar(max)
	declare @query as varchar(max)
	
	declare @int_Prd as tinyint
	declare @int_import as tinyint
	
	
	select @Module_Status= COALESCE(@Module_Status + ',', '') +  '''' + module_name + ''''
	from T0011_module_detail WITH (NOLOCK)
	where Cmp_id = @cmp_id and module_status = 0
	
	-- Delete Temp table if Exist
	if exists(select 1 from sys.tables where name like '%#TEMP_data%') 
	begin
		drop table #TEMP_data
	end

	-- Do the Entry in temp table with priviledge.
	--SELECT * 
	--INTO	#TEMP_data 
	--FROM DBO.GET_EMP_PRIVILEGE_VIEW WHERE PRIVILAGE_ID = @PRIVILEGE_ID 
	--AND 1 =(case when @PRIVILEGE_ID=0 then 1 when PRIVILAGE_ID = @PRIVILEGE_ID and CMP_ID = @CMP_ID then 1 else 0 end)
	
	SELECT * 
	INTO	#TEMP_data 
	FROM (
	select  row_number()over (ORDER BY CTE.cmp_id,CTE.Privilege_ID asc)as tran_id,
		CTE.Privilege_ID as Privilage_ID,
		CTE.Cmp_Id as cmp_id,
		CTE.Form_ID,
		case when isnull(PD.Is_View,0)=0 then 0 else PD.Is_View end as Is_View,
		case when isnull(PD.is_edit,0)=0 then 0 else PD.is_edit end as is_edit,
		case when isnull(PD.is_save,0)=0 then 0 else PD.is_save end as is_save,
		case when isnull(PD.is_delete,0)=0 then 0 else PD.is_delete end as is_delete,
		case when isnull(PD.is_print,0)=0 then 0 else PD.is_print end as is_print,
		CTE.Form_Name,
		CTE.Under_Form_ID ,
		CTE.Module_name 
		,CTE.Page_Flag
		from ( SELECT   
		PM.Privilege_ID,
		PM.Cmp_Id as cmp_id,
		D.Form_ID,
		0 as Is_View,
		0 as is_edit,
		0 as is_save,
		0 as is_delete,
		0 as is_print,
		D.Form_Name,
		D.Under_Form_ID ,
		D.Module_name 
		,D.Page_Flag
		from T0020_PRIVILEGE_MASTER PM WITH (NOLOCK) Cross Join T0000_DEFAULT_FORM D WITH (NOLOCK)
		where PM.Cmp_Id =@cmp_id and pm.Privilege_ID =@PRIVILEGE_ID
		and D.Is_Active_for_Menu=1
		) as CTE
		left join T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK) on 
		CTE.Form_ID = PD.Form_Id and
		CTE.Privilege_ID = PD.Privilage_ID and Cte.cmp_id =PD.Cmp_Id
		where CTE.Cmp_Id =@cmp_id and CTE.Privilege_ID =@PRIVILEGE_ID
		
	--	AND 1 =(case when @PRIVILEGE_ID=0 then 1 when PRIVILAGE_ID = @PRIVILEGE_ID and CTE.CMP_ID = @CMP_ID then 1 else 0 end)

		union all

		SELECT pd.Trans_Id,
		isnull(pd.Privilage_ID,0) as Privilage_ID,
		isnull(PD.Cmp_Id,0) as cmp_id,
		Df.Form_Id,
		isnull(pd.Is_View,1) as Is_View,
		isnull(pd.Is_Edit,1) as is_edit,
		isnull(pd.Is_Save,1) as is_save,
		isnull(pd.Is_Delete,1) as is_delete,
		isnull(pd.Is_Print,1) as is_print,
		DF.Form_Name ,DF.UNDER_FORM_ID 
		,Df.Module_name 
		,Df.Page_Flag
		FROM dbo.T0000_DEFAULT_FORM DF WITH (NOLOCK)
		left JOIN  dbo.T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK) ON DF.FORM_ID = PD.FORM_ID and Privilage_ID = 0	
		where 
		--(DF.Form_ID < 7000	or DF.Form_ID > 8000)
		(DF.Page_Flag not in ('ER','EP'))
		--and Privilage_ID = @PRIVILEGE_ID 
		AND 1 =(case when @PRIVILEGE_ID=0 then 1 when PRIVILAGE_ID = @PRIVILEGE_ID and CMP_ID = @CMP_ID then 1 else 0 end)
		and DF.Is_Active_for_Menu=1 --Added this condition by Sumit on 25102016
	) as ASP
	
	
	
	-- update rights of module whose rights not given
	set @query= 'update #TEMP_data set Is_View = 0,Is_Edit = 0, Is_Save=0, Is_Delete=0, Is_Print=0	where module_name in (' + cast(@Module_Status as varchar(max)) +') '
	exec(@query)
	
	if exists(select 1 from sys.tables where name like '%#TEMP_data_1%') 
	begin
		drop table #TEMP_data_1
	end
	
	-- Check the import Page Form
	select ID.*  into #TEMP_data_1 from #TEMP_data TD inner join t0000_import_data ID WITH (NOLOCK) on Td.Form_Name = ID.Name where UNDER_FORM_ID = 6007 and TD.is_edit = 1 and  TD.is_save=1
	
	--select Form_Name,* from #TEMP_data as TD where TD.FORM_NAME in ('Branch Master','Grade Master','Department Master','Designation Master','Bank Master','State Master','City Category Expense Master','Business Segment Master','Cost Center Master','Asset Master','Asset Details','Employee Master') 
	--and TD.Is_Save = 0
	
	-- Check the master Page right along with import page rights
	delete 	from #TEMP_data_1 
	where Form_Name in ( select Form_Name from #TEMP_data as TD where TD.FORM_NAME in ('Branch Master','Grade Master','Department Master','Designation Master','Bank Master','State Master','City Category Expense Master','Business Segment Master','Cost Center Master','Asset Master','Asset Details','Employee Master') 
	and TD.Is_Save = 0 )

	
	set @int_Prd = 0
	set @int_import = 0
	
	---- Check admin setting and update temp table
	select @int_Prd= isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID=@CMP_ID and Setting_Name in ('Calculate Salary Base on Production Details')
	select @int_import = ISNULL(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID=@CMP_ID and Setting_Name in ('Enable Import Option for Estimated Amount')
	
	if @int_Prd= 0
	begin
		delete from #TEMP_data_1 where Name='Product Details Import'	
	end
	
	if @int_import=0
	begin
		delete from #TEMP_data_1 where Name='Estimated Amount Import'	
	end 
	
	select * from #TEMP_data_1 
	
End
