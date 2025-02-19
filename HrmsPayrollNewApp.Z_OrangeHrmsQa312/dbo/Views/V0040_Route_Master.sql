


 
CREATE VIEW [dbo].[V0040_Route_Master]

AS

SELECT RM.Route_ID,RM.Route_Name,RM.Route_No,RM.Route_KM,RM.Fuel_Place,RM.Vehicle_ID,
CONVERT(varchar(11),RM.Effective_Date,103) as 'Effective_Date',RM.Cmp_ID--,VM.Vehicle_Name
FROM T0040_Route_Master RM WITH (NOLOCK)
--INNER JOIN T0040_Vehicle_Master VM ON RM.Vehicle_ID = VM.Vehicle_ID


