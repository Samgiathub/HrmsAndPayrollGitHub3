


CREATE View [dbo].[V0040_Griev_Status_Master]
As 
select G_StatusID,StatusTitle,isnull(StatusCode,'') as StatusCode,Cmp_ID from T0040_Griev_Status_Master
where Is_Active=1
