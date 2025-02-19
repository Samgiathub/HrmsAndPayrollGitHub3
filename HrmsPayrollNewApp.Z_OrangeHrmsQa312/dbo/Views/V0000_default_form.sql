



CREATE VIEW [dbo].[V0000_default_form]
as
select 
TDF.Form_ID,TDF.Form_Name,tdf.Form_Image_url,TDF.Form_Type,TDF.Form_url,TDF.Is_Active_For_menu,TDF.Sort_ID,TDF.Under_Form_ID,P_TDF.Form_Name as under_Form_name,
case when TDF.Is_Active_For_menu=1 then 'Active' else 'In Active' end as Form_Status,
cast(TDF.Alias as varchar(500)) +' - ' + ISNULL(TDF.Module_name,'') as Alias
from t0000_default_form TDF WITH (NOLOCK)
Left join t0000_default_form P_TDF WITH (NOLOCK) on TDF.Under_Form_ID = P_TDF.Form_ID

where TDF.Form_ID > 6000




