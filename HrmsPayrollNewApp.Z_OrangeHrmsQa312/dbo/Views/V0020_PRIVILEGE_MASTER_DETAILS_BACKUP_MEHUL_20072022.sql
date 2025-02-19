





CREATE VIEW [dbo].[V0020_PRIVILEGE_MASTER_DETAILS_BACKUP_MEHUL_20072022]
AS
SELECT     dbo.T0020_PRIVILEGE_MASTER.Privilege_ID, dbo.T0020_PRIVILEGE_MASTER.Cmp_Id, dbo.T0020_PRIVILEGE_MASTER.Privilege_Name, 
                      dbo.T0050_PRIVILEGE_DETAILS.Form_Id, dbo.T0050_PRIVILEGE_DETAILS.Is_View, dbo.T0050_PRIVILEGE_DETAILS.Is_Edit, 
                      dbo.T0050_PRIVILEGE_DETAILS.Is_Save, dbo.T0050_PRIVILEGE_DETAILS.Is_Delete, dbo.T0000_DEFAULT_FORM.Form_Name, 
                      dbo.T0000_DEFAULT_FORM.Under_Form_ID, dbo.T0000_DEFAULT_FORM.Sort_ID, dbo.T0000_DEFAULT_FORM.Form_Type
                      ,T0000_DEFAULT_FORM.Form_url,T0000_DEFAULT_FORM.form_image_url
                      , case when dbo.T0050_PRIVILEGE_DETAILS.Is_View = 1 then 1 when dbo.T0050_PRIVILEGE_DETAILS.Is_Edit= 1 then 1 when dbo.T0050_PRIVILEGE_DETAILS.Is_Save = 1 then 1 when dbo.T0050_PRIVILEGE_DETAILS.Is_Delete=1 then 1 else 0 end as Is_Active
                      ,T0000_DEFAULT_FORM.Is_Active_For_menu
                      ,T0000_DEFAULT_FORM.Alias
                      ,t0000_default_form.sort_id_check
                      ,t0000_default_form.module_name
                      ,t0000_default_form.Page_Flag
                      ,t0000_default_form.chinese_alias
FROM         dbo.T0050_PRIVILEGE_DETAILS WITH (NOLOCK) INNER JOIN
                      dbo.T0020_PRIVILEGE_MASTER  WITH (NOLOCK) ON dbo.T0050_PRIVILEGE_DETAILS.Privilage_ID = dbo.T0020_PRIVILEGE_MASTER.Privilege_ID INNER JOIN
                      dbo.T0000_DEFAULT_FORM WITH (NOLOCK)  ON dbo.T0050_PRIVILEGE_DETAILS.Form_Id = dbo.T0000_DEFAULT_FORM.Form_ID




