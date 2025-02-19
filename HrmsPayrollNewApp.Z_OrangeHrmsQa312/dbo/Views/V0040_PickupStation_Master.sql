


 
 
CREATE VIEW [dbo].[V0040_PickupStation_Master]
As

SELECT PM.Pickup_ID,PM.Pickup_Name,PM.Route_ID,PM.Pickup_KM,CONVERT(varchar(11),PM.Effective_Date,103) AS 'Effective_Date',
PM.Cmp_ID,RM.Route_Name
FROM T0040_PickupStation_Master  PM WITH (NOLOCK)
INNER JOIN T0040_Route_Master RM WITH (NOLOCK) ON PM.Route_ID = RM.Route_ID


