﻿



CREATE VIEW [dbo].[V0020_State_Master]
AS
SELECT State_ID,State_Name,LM.Loc_name,SM.Loc_ID,Cmp_ID  
FROM T0020_STATE_MASTER SM WITH (NOLOCK)
INNER JOIN T0001_LOCATION_MASTER LM WITH (NOLOCK) ON SM.Loc_ID = LM.Loc_ID


