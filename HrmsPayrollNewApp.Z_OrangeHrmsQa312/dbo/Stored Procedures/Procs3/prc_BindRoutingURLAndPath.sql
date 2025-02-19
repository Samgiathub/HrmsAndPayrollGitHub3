-- exec prc_BindRoutingURLAndPath 'admin-associates-master-hr-document'
-- drop proc prc_BindRoutingURLAndPath
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE procedure [dbo].[prc_BindRoutingURLAndPath]
@rURL varchar(100) = null
as
begin
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	select distinct case Page_Flag when 'AP' then 'admin_associates' + '/' + replace(replace(replace(replace(replace(replace(replace(replace(lower(Form_url),' ','-'),'../',''),'~/',''),'.aspx',''),'_','-'),'/','-'),'?rid=','/'),'?id=','/') when 'HP' then 
	'hrms_forms' + '/' + replace(replace(replace(replace(replace(replace(replace(replace(lower(Form_url),' ','-'),'../',''),'~/',''),'.aspx',''),'_','-'),'/','-'),'?rid=','/'),'?id=','/') when 'EP' then 
	'ess_forms' + '/' + replace(replace(replace(replace(replace(replace(replace(replace(lower(Form_url),' ','-'),'../',''),'~/',''),'.aspx',''),'_','-'),'/','-'),'?rid=','/'),'?id=','/') when 'DA' then 
	'admin_dashboard' + '/' + replace(replace(replace(replace(replace(replace(replace(replace(lower(Form_url),' ','-'),'../',''),'~/',''),'.aspx',''),'_','-'),'/','-'),'?rid=','/'),'?id=','/') when 'ER' then 
	'ess_reports' + '/' + replace(replace(replace(replace(replace(replace(replace(replace(replace(lower(Form_url),' ','-'),'../',''),'~/',''),'.aspx',''),'_','-'),'/','-'),'?rid=','/'),'?id=','/'),'?id=','/') when 'AR' then 
	'admin_reports' + '/' + replace(replace(replace(replace(replace(replace(replace(replace(lower(Form_url),' ','-'),'../',''),'~/',''),'.aspx',''),'_','-'),'/','-'),'?rid=','/'),'?id=','/') when 'DH' then 
	'hrms_dashboard' + '/' + replace(replace(replace(replace(replace(replace(replace(replace(lower(Form_url),' ','-'),'../',''),'~/',''),'.aspx',''),'_','-'),'/','-'),'?rid=','/'),'?id=','/') when 'IP' then 
	'import_forms' + '/' + replace(replace(replace(replace(replace(replace(replace(replace(lower(Form_url),' ','-'),'../',''),'~/',''),'.aspx',''),'_','-'),'/','-'),'?rid=','/'),'?id=','/') when 'DE' then 
	'ess_dashboard' + '/' + replace(replace(replace(replace(replace(replace(replace(replace(lower(Form_url),' ','-'),'../',''),'~/',''),'.aspx',''),'_','-'),'/','-'),'?rid=','/'),'?id=','/') Else Form_url End  As pageURL,
	case Page_Flag when 'AP' then'~/admin_associates/' when 'HP' then '~/' else '~/' end + replace(Form_url,'../admin_associates/','') as pagePath,
	replace(replace(replace(replace(replace(replace(replace(replace(lower(Form_url),' ','-'),'../',''),'~/',''),'.aspx',''),'_','-'),'/','-'),'?rid=','-'),'?id=','-') as Alias
	From T0000_DEFAULT_FORM WITH (NOLOCK) where Form_url <> '' and Page_Flag in ('AP','HP') --and Form_ID = 20399
	
	select Form_ID,Form_url from T0000_DEFAULT_FORM WITH (NOLOCK) where replace(replace(replace(replace(replace(replace(replace(lower(Form_url),' ','-'),'../',''),'~/',''),'.aspx',''),'_','-'),'/','-'),'?rid=','') = @rURL
end