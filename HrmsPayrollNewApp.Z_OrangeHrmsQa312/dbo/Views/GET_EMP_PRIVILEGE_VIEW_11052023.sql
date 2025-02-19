




Create VIEW [dbo].[GET_EMP_PRIVILEGE_VIEW_11052023]
as

--SELECT pd.Trans_Id,
--pd.Privilage_ID,
--isnull(PD.Cmp_Id,0) as cmp_id,
--Df.Form_Id,
--isnull(pd.Is_View,0) as Is_View,
--isnull(pd.Is_Edit,0) as is_edit,
--isnull(pd.Is_Save,0) as is_save,
--isnull(pd.Is_Delete,0) as is_delete,
--isnull(pd.Is_Print,0) as is_print,
--DF.FORM_NAME,DF.UNDER_FORM_ID 
--,Df.Module_name 
--FROM dbo.T0000_DEFAULT_FORM DF
--left outer JOIN  dbo.T0050_PRIVILEGE_DETAILS PD ON DF.FORM_ID = PD.FORM_ID		

--union all

--SELECT pd.Trans_Id,
--isnull(pd.Privilage_ID,0) as Privilage_ID,
--isnull(PD.Cmp_Id,0) as cmp_id,
--Df.Form_Id,
--isnull(pd.Is_View,1) as Is_View,
--isnull(pd.Is_Edit,1) as is_edit,
--isnull(pd.Is_Save,1) as is_save,
--isnull(pd.Is_Delete,1) as is_delete,
--isnull(pd.Is_Print,1) as is_print,
--DF.FORM_NAME,DF.UNDER_FORM_ID 
--,Df.Module_name 
--FROM dbo.T0000_DEFAULT_FORM DF
--left JOIN  dbo.T0050_PRIVILEGE_DETAILS PD ON DF.FORM_ID = PD.FORM_ID and Privilage_ID = 0	
--where (DF.Form_ID < 7000	or DF.Form_ID > 8000)

select row_number()over (ORDER BY CTE.cmp_id,CTE.Privilege_ID asc)as tran_id,
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
CTE.Module_name, 
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
from T0020_PRIVILEGE_MASTER PM WITH (NOLOCK)
cross join 
T0000_DEFAULT_FORM D WITH (NOLOCK) ) as CTE
left join T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK) on 
CTE.Form_ID = PD.Form_Id and CTE.Privilege_ID = PD.Privilage_ID and Cte.cmp_id =PD.Cmp_Id

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
left JOIN  dbo.T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK) ON DF.FORM_ID = PD.FORM_ID and Privilage_ID = 0	
where 
--(DF.Form_ID < 7000	or DF.Form_ID > 8000)
(DF.Page_Flag not in ('ER','EP'))




