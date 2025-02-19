





-- Created By rohit on 03102015 for Canteen Module Change.
CREATE VIEW [dbo].[V0050_CANTEEN_MASTER]
AS

select CM.Cmp_Id ,CM.Cnt_Id ,CM.Cnt_Name ,CM.From_Time ,CM.To_Time ,CM.System_Date,CM.Ip_Id ,
CM.Canteen_Image,CM.Canteen_Group,CM.GST_Percentage,CM.CutOff_Time ,iif(CM.Is_Active = 1,'Active','InActive') as Is_Active
,isnull(IM.Device_Name,'Canteen') as  Canteen
from T0050_CANTEEN_MASTER CM WITH (NOLOCK) left join 
T0040_IP_MASTER IM WITH (NOLOCK)  on CM.Ip_Id = IM.Ip_id




