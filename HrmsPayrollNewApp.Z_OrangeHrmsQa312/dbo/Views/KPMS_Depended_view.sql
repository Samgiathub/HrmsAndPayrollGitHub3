

CREATE VIEW [dbo].[KPMS_Depended_view]
 as
 select * from KPMS_T0110_Goal_Setting_Goal where GSG_Id in (
Select distinct t1.GSG_id from KPMS_T0110_Goal_Setting_Goal T1
inner join (
		Select GSG_Id,GSG_Depend_Goal_Id from KPMS_T0110_Goal_Setting_Goal 	
	) T2 on T1.GSG_Goal_Id = T2.GSG_Depend_Goal_Id)

