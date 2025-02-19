





CREATE VIEW [dbo].[V0040_Clearance_Attribute]
AS
SELECT     DM.Dept_Name, C.Clearance_id, C.Cmp_id, C.Dept_id, C.Item_code, C.Item_name, C.Active as Active,Cost_Center_ID,CM.Center_Name,
(CASE WHEN C.Active=1 THEN 'awards_link'	WHEN C.Active=0 THEN 'awards_link clsinactive' ELSE 'awards_link clsinactive' END)  as Status_Color
FROM         dbo.T0040_Clearance_Attribute AS C WITH (NOLOCK) LEFT JOIN
                      dbo.T0040_DEPARTMENT_MASTER AS DM WITH (NOLOCK)  ON C.Dept_id = DM.Dept_Id LEFT JOIN
                      dbo.T0040_COST_CENTER_MASTER	AS CM WITH (NOLOCK)  ON CM.Center_ID = C.Cost_Center_ID




