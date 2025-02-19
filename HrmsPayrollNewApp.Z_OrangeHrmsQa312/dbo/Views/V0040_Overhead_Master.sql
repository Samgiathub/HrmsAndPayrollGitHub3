


CREATE VIEW [dbo].[V0040_Overhead_Master]
AS

select OH.Overhead_ID,OH.Project_ID,OH.OverHead_Month,OH.OverHead_Year,Oh.Project_cost,PM.Project_Name,OH.Cmp_ID,
OH.Exchange_Rate
from T0040_OverHead_Master OH WITH (NOLOCK)
LEFT join T0040_TS_Project_Master PM WITH (NOLOCK) on OH.Project_ID=PM.Project_ID
