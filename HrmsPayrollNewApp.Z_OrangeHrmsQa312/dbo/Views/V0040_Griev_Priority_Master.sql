



CREATE View [dbo].[V0040_Griev_Priority_Master]
As 

select G_PriorityID,PriorityTitle,isnull(PriorityCode,'') as PriorityCode,Cmp_ID from T0040_Griev_Priority_Master
where Is_Active=1

