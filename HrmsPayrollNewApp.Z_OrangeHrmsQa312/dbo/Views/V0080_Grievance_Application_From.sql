
CREATE View [dbo].[V0080_Grievance_Application_From]
As
select GAP.GrievanceID,GAP.Type_of_Grie_id,GTM.GrievanceTypeTitle,
Format(GAP.Date_of_Grievance,'dd/MM/yyyy') as Date_of_Grievance,GAP.Grie_Against_id,GAP.Grievance_Desc,GAP.Cmp_ID from T0080_Grie_App_Form GAP
left join T0040_Grievance_Type_Master GTM on GTM.GrievanceTypeID = GAP.Type_of_Grie_id
where GAP.Is_Active=1
