




CREATE View [dbo].[V0090_EMP_CHILDRAN_DETAI]
As
select 
	   ECD.Emp_ID
      ,ECD.Row_ID
      ,ECD.Cmp_ID
      ,ECD.Name
      ,ECD.Gender
      ,isnull(ECD.Date_Of_Birth,'') Date_Of_Birth
      ,isnull(ECD.C_Age,0) C_Age
      ,ECD.Relationship
      ,isnull(ECD.Is_Resi,0) Is_Resi
      ,isnull(ECD.Is_Dependant,0) Is_Dependant
      ,ECD.Image_Path
      ,ECD.Pan_Card_No
      ,ECD.Adhar_Card_No
      ,ECD.Height
      ,ECD.Weight
      ,isnull(ECD.OccupationID,0) OccupationID
      ,ECD.HobbyID
      ,ECD.HobbyName
      ,ECD.DepCompanyName
      ,isnull(ECD.Standard_ID,0) Standard_ID
	  ,ECD.Std_Specialization --added by ronakk 25072022
      ,ECD.Shcool_College
      ,ECD.ExtraActivity
      ,ECD.City
      ,ECD.CDTM
      ,ECD.CmpCity
      ,OM.Occupation_Name
      ,DSM.StandardName 
	from T0090_EMP_CHILDRAN_DETAIL ECD
	Left join T0040_Occupation_Master OM on OM.O_ID = ECD.OccupationID 
	Left join T0040_Dep_Standard_Master DSM on DSM.S_ID = ECD.Standard_ID
