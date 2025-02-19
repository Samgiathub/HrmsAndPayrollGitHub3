﻿





CREATE VIEW [dbo].[V0050_AD_MASTER_REIM_EFFECT_GET]
AS
SELECT     Am.AD_NAME, Am.AD_ID, Am.AD_SORT_NAME, Am.AD_LEVEL, ream.RIMB_ID, CASE WHEN isnull(ream.AD_ID, 0) 
                      > 0 THEN 1 ELSE 0 END AS AD_Checked, Am.CMP_ID
FROM         dbo.T0050_AD_MASTER AS Am WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0060_RIMB_EFFECT_AD_MASTER AS ream WITH (NOLOCK)  ON Am.AD_ID = ream.AD_ID




