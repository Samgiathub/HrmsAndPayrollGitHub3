



CREATE VIEW [dbo].[V0299_schedule_master]
AS
SELECT 
Sch_id,Sch_Name,RM.Reminder_Name,Sch_Type,Date_run,Date_Weekly,
Case When isnull(is_time,0) = 1 then Sch_time else cast(Sch_Hours as varchar(max)) end as Sch_time
,Cc_Email_Id,modify_date,cmp_id,Sch_Hours,is_time
,isnull(Parameter,'') as Parameter, IsNull(LeaveIDs,'') As LeaveIDs
FROM t0299_schedule_master SM WITH (NOLOCK) left join t0298_Reminder_Mail RM WITH (NOLOCK)  on  SM.Reminder_Name = RM.Reminder_Sp




