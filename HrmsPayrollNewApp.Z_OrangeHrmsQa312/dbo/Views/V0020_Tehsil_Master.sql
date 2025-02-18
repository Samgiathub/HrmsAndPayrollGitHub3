﻿

CREATE VIEW [dbo].[V0020_Tehsil_Master]
AS
SELECT TM.T_ID,TM.T_Name,SM.State_ID,SM.State_Name,LM.Loc_name,SM.Loc_ID,TM.Cmp_ID,DM.Dist_ID,DM.Dist_Name
FROM T0030_TEHSIL_MASTER TM WITH (NOLOCK)
inner join T0020_STATE_MASTER SM WITH (NOLOCK) on SM.State_ID= TM.State_id
inner join T0030_DISTRICT_MASTER DM WITH (NOLOCK) on DM.Dist_ID= TM.Dist_ID
INNER JOIN T0001_LOCATION_MASTER LM WITH (NOLOCK) ON SM.Loc_ID = LM.Loc_ID and TM.Loc_ID=LM.Loc_ID
