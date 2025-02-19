


CREATE VIEW [dbo].[V0050_Route_Vehicle_Details]
AS
SELECT TRV.Assign_ID,VM.Vehicle_ID,TRV.Route_ID,CONVERT(varchar(11),TRV.Effective_Date,103) AS 'Effective_Date',
RM.Route_Name,VM.Vehicle_Name,VM.Vehicle_No,TRV.Cmp_ID,VM.Vehicle_Owner,RM.Route_No,RM.Route_KM,VM.Owner_Name,VM.Owner_ContactNo,VM.Driver_Name,VM.Driver_ContactNo
FROM T0050_Route_Vehicle_Details TRV WITH (NOLOCK)
RIGHT JOIN T0040_Route_Master RM WITH (NOLOCK) ON TRV.Route_ID = RM.Route_ID
RIGHT JOIN T0040_Vehicle_Master VM WITH (NOLOCK) ON TRV.Vehicle_ID = VM.Vehicle_ID
