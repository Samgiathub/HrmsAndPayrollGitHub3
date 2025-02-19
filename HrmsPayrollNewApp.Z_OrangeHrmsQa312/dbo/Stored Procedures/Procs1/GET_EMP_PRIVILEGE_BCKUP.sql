

CREATE PROCEDURE [dbo].[GET_EMP_PRIVILEGE_BCKUP]
	@CMP_ID AS numeric,
	@Privilege_ID AS numeric,
	@Flag As Numeric = 0
AS
	Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	IF EXISTS(SELECT 1 FROM information_schema.tables where table_name='T9999_CACHE_GET_EMP_PRIVILEGE') AND @Flag <> 1
		BEGIN
			IF EXISTS(SELECT 1 FROM T9999_CACHE_GET_EMP_PRIVILEGE WITH (NOLOCK) WHERE Privilege_ID=@Privilege_ID AND ExpiryDate > getdate())
				BEGIN
					SELECT	* 			
					FROM	T9999_CACHE_GET_EMP_PRIVILEGE WITH (NOLOCK) 			
					WHERE	Privilege_ID=@Privilege_ID
					print 3
					RETURN
				END
		END
	
		declare @Module_Status as varchar(max)
	declare @query as varchar(max)
	
	select @Module_Status= COALESCE(@Module_Status + ',', '') +  '''' + module_name + ''''
	from T0011_module_detail  WITH (NOLOCK) 
	where Cmp_id = @cmp_id and module_status = 0
	if exists(select 1 from sys.tables where name like '%#TEMP_data%') 
	begin
	drop table #TEMP_data
	end

	--SELECT * 
	--INTO	#TEMP_data 
	--FROM DBO.GET_EMP_PRIVILEGE_VIEW WHERE PRIVILAGE_ID = @PRIVILEGE_ID 
	--AND 1 =(case when @PRIVILEGE_ID=0 then 1 when PRIVILAGE_ID = @PRIVILEGE_ID and CMP_ID = @CMP_ID then 1 else 0 end)
	print 123
	
	SELECT * 
	INTO	#TEMP_data 
	FROM (
	select  row_number()over (ORDER BY CTE.cmp_id,CTE.Privilege_ID,CTE.Form_ID asc)as tran_id,
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
		CTE.Module_name ,
		CTE.Page_Flag
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
		D.Module_name ,
		D.Page_Flag 
		from T0020_PRIVILEGE_MASTER PM  WITH (NOLOCK) Cross Join T0000_DEFAULT_FORM D  WITH (NOLOCK) 
		where PM.Cmp_Id =@cmp_id and pm.Privilege_ID =@PRIVILEGE_ID
		) as CTE
		left join T0050_PRIVILEGE_DETAILS PD  WITH (NOLOCK) on 
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
		DF.FORM_NAME,DF.UNDER_FORM_ID 
		,Df.Module_name 
		,DF.Page_Flag 
		FROM dbo.T0000_DEFAULT_FORM DF WITH (NOLOCK) 
		left JOIN  dbo.T0050_PRIVILEGE_DETAILS PD  WITH (NOLOCK) ON DF.FORM_ID = PD.FORM_ID and Privilage_ID = 0	
		where 
		--(DF.Form_ID < 7000	or DF.Form_ID > 8000)
		(DF.Page_Flag not in ('ER','EP','DE'))
		--and Privilage_ID = @PRIVILEGE_ID 
		AND 1 =(case when @PRIVILEGE_ID=0 then 1 when PRIVILAGE_ID = @PRIVILEGE_ID and CMP_ID = @CMP_ID then 1 else 0 end)
	) as ASP


	select * from #TEMP_data where Form_Name like '%Canteen%'

	select  row_number()over (ORDER BY CTE.cmp_id,CTE.Privilege_ID,CTE.Form_ID asc)as tran_id,
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
		CTE.Module_name ,
		CTE.Page_Flag
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
		D.Module_name ,
		D.Page_Flag 
		from T0020_PRIVILEGE_MASTER PM  WITH (NOLOCK) Cross Join T0000_DEFAULT_FORM D  WITH (NOLOCK) 
		where PM.Cmp_Id =@cmp_id and pm.Privilege_ID =@PRIVILEGE_ID
		) as CTE
		left join T0050_PRIVILEGE_DETAILS PD  WITH (NOLOCK) on 
		CTE.Form_ID = PD.Form_Id and
		CTE.Privilege_ID = PD.Privilage_ID and Cte.cmp_id =PD.Cmp_Id
		where CTE.Cmp_Id =@cmp_id and CTE.Privilege_ID =@PRIVILEGE_ID

	
	set @query= 'update #TEMP_data set Is_View = 0,Is_Edit = 0, Is_Save=0, Is_Delete=0, Is_Print=0	where module_name in (' + cast(@Module_Status as varchar(max)) +') '
	exec(@query)	
	
	if @Flag <> 1
		Begin

			select *,@Privilege_ID,DateAdd(HH,2, GetDate()) from #TEMP_data
		End
	
	 
	if @Flag = 1 
		Begin 
			
			Insert into #Temp_Privilege 
			select Form_Name from #TEMP_data where 
			Page_Flag = 'DE'
			and Is_View = 1 and is_save = 1 and is_delete = 1
			RETURN
		End 
	
	IF EXISTS(SELECT 1 FROM information_schema.tables where table_name='T9999_CACHE_GET_EMP_PRIVILEGE')
		BEGIN
			IF EXISTS(select 1 from tempdb.sys.columns tc 
						where	object_id=object_id('tempdb..#tmp')
								and not exists(select 1 from sys.columns pc where object_id=object_id('T9999_CACHE_GET_EMP_PRIVILEGE') and pc.name=tc.name))						
				BEGIN
					DROP TABLE T9999_CACHE_GET_EMP_PRIVILEGE
				END
		END



	IF NOT EXISTS(SELECT 1 FROM information_schema.tables where table_name='T9999_CACHE_GET_EMP_PRIVILEGE')
		BEGIN
			select top 0 *, Cast(0 As int) As Privilege_ID, GetDate() As ExpiryDate into T9999_CACHE_GET_EMP_PRIVILEGE FROM #TEMP_data
			
		CREATE UNIQUE CLUSTERED INDEX CLIX_T9999_CACHE_GET_EMP_PRIVILEGE ON T9999_CACHE_GET_EMP_PRIVILEGE(Privilege_ID, Form_ID,tran_id)
			CREATE NonClustered INDEX NCIX_T9999_CACHE_GET_EMP_PRIVILEGE ON T9999_CACHE_GET_EMP_PRIVILEGE(Privilege_ID, ExpiryDate Desc)
		END
	
		
	DELETE FROM T9999_CACHE_GET_EMP_PRIVILEGE WHERE Privilage_ID=@Privilege_ID
	INSERT INTO T9999_CACHE_GET_EMP_PRIVILEGE
	SELECT *,@Privilege_ID,DateAdd(HH,2, GetDate()) FROM #TEMP_data
	
	
	
	RETURN




