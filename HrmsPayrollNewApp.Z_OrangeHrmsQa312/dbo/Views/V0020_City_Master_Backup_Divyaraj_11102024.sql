



CREATE VIEW [dbo].[V0020_City_Master_Backup_Divyaraj_11102024]
AS
SELECT CM.City_ID,City_Name,SM.State_ID,State_Name,LM.Loc_name,SM.Loc_ID,CM.Cmp_ID,isnull(CM.City_Cat_ID,0) as City_Cat_ID
,isnull(CTM.City_Cat_Name,'') as City_Cat_Name
FROM T0030_CITY_MASTER CM WITH (NOLOCK)
inner join
T0020_STATE_MASTER SM WITH (NOLOCK) on SM.State_ID= CM.State_id
INNER JOIN T0001_LOCATION_MASTER LM WITH (NOLOCK) ON SM.Loc_ID = LM.Loc_ID and Cm.Loc_ID=LM.Loc_ID
left join T0040_City_Category_Master CTM WITH (NOLOCK) on CTM.City_Cat_ID=CM.City_Cat_ID and CM.CMp_ID=CTM.Cmp_ID




