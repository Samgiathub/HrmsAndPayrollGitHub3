
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_DB_TO_DB_SYNCHRONIZATION_GTPL]  
as  

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @MaxNo as numeric(18,0)  
select  @MaxNo= isnull(MAX(IO_Tran_ID),0)  from dbo.T9999_DEVICE_INOUT_DETAIL  WITH (NOLOCK)
  
insert into dbo.T9999_DEVICE_INOUT_DETAIL  

select @MaxNo+RowNo as SrNo,Cmp_ID,userid,IDateTime,event_point_name as IP_Address,Mx_IoData.[state]  
  
from  
(  
 select ROW_NUMBER() OVER (ORDER BY Pin,[Time]) AS RowNo,  
 Pin as UserId,[Time] as IDateTime,[state] ,event_point_name  
 from 
 --[Orange_Access_New1].
 [New].dbo.acc_monitor_log  
 where [Time] >='29-Nov-2016' and Pin > 0  
   
 )as Mx_IoData  
 left join  
 (  
  select IO_Tran_ID, Enroll_No,IO_DateTime as MaxDate   
  from dbo.T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK) 
 ) as InOut  
 on Mx_IoData.userid = InOut.Enroll_No  
 and Mx_IoData.IDateTime = MaxDate   
 Inner join  
 T0080_EMP_MASTER WITH (NOLOCK) on UserId=T0080_EMP_MASTER.Enroll_No  
 where userid > 0 and isnull(InOut.IO_Tran_ID,0) = 0  
 and isnull(InOut.Enroll_No,0) = 0  
 and Date_Of_Join < IDateTime and IDateTime <= ISNULL(Emp_Left_Date,GETDATE() )--Added By Ramiz on 01-Feb-2016  
 order by userid,IDateTime  
  
exec SP_EMP_INOUT_SYNCHRONIZATION_AUTO 1  
  
  
Return 
