

CREATE View [dbo].[V0040_Griev_Master]
As 
select  GrievanceTypeID,GrievanceTypeTitle,isnull(GrievanceTypeCode,'') as GrievanceTypeCode,Cmp_ID from T0040_Grievance_Type_Master
where Is_Active=1
