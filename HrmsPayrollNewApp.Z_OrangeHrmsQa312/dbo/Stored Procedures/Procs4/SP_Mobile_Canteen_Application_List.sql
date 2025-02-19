
---28/1/2021 (EDIT BY Yogesh ) 
-- exec [dbo].[SP_Mobile_Canteen_Application_List] 120,29677,'2023-03-01 17:36:41.000','2023-05-30 17:36:41.000'
CREATE PROCEDURE [dbo].[SP_Mobile_Canteen_Application_List]
	--@Compoff_App_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(18,0),
	@From_Date Datetime,
	@To_Date Datetime
	
	
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--select @Cmp_ID
--	select @Emp_ID 
	--select @From_Date
	--select @To_Date 
	--select Convert(varchar,@From_Date,107)
	--select Convert(varchar,@From_Date,103)
select App_No as 'App_No',Receive_Date as 'App_Date',Emp_Name,Cnt_Name as Food
,case when Duration = 0 then 'Unlimited' else 'Limited' end as Duration
,Canteen as 'Canteen_Name'
,App_Type as 'Application_Type'
,case When App_Type='Guest' then Guest_Type else '' end as 'Guest_Type'
,case When App_Type='Guest' then Guest_Name else '' end as 'Guest_Name'
,App_Id as 'App_id'
from V0080_Canteen_Application
where 
App_Id <> 0 and Cmp_Id =@Cmp_ID and Emp_Id = @Emp_ID
and Convert(datetime,Receive_Date,105) between Convert(datetime,@From_Date,105) and convert(datetime,@To_Date,105)
order by App_Id

--select * from V0080_Canteen_Application






