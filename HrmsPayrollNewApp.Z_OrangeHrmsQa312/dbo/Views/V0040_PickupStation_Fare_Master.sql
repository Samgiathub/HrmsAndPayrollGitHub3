


 
 
CREATE VIEW [dbo].[V0040_PickupStation_Fare_Master]
AS
SELECT PFM.Fare_ID,PFM.Pickup_ID,PFM.Fare,PFM.Discount,PFM.NetFare,CONVERT(varchar(11),PFM.Effective_Date ,103) AS 'Effective_Date',
PFM.Cmp_ID,PM.Pickup_Name,PM.Route_ID,RM.Route_Name,RM.Route_No,RM.Route_KM,PM.Pickup_KM
FROM T0040_PickupStation_Fare_Master PFM WITH (NOLOCK)
INNER JOIN T0040_PickupStation_Master PM WITH (NOLOCK) ON PFM.Pickup_ID = PM.Pickup_ID
INNER JOIN T0040_Route_Master RM WITH (NOLOCK) ON PM.Route_ID = RM.Route_ID
 



