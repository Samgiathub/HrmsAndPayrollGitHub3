


CREATE VIEW [dbo].[V0050_NO_PRIVILEGE_DETAIL]
AS 
SELECT PD.Privilage_ID, DF.Form_Id ,DF.Form_Name, DF.Alias,DF.Form_url 
FROM T0050_PRIVILEGE_DETAILS  PD WITH (NOLOCK) INNER JOIN T0000_DEFAULT_FORM DF WITH (NOLOCK)  ON PD.Form_Id=DF.Form_ID
WHERE (Is_View = 1 OR Is_Edit = 1 OR Is_Save = 1 OR Is_Delete = 1) and Form_url IS NOT NULL
--WHERE (Is_View =0 AND Is_Edit = 0 AND Is_Save = 0 AND Is_Delete = 0)


