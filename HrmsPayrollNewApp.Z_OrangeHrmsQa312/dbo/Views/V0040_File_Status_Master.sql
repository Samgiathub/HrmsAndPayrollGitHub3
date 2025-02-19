



CREATE View [dbo].[V0040_File_Status_Master]
As 
select F_StatusID,StatusTitle,isnull(StatusCode,'') as StatusCode,Cmp_ID from T0040_File_Status_Master
where Is_Active=1
