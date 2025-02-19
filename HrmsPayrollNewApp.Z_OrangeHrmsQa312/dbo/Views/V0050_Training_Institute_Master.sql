




CREATE VIEW [dbo].[V0050_Training_Institute_Master]
AS
SELECT     TM.Training_InstituteId, TM.Cmp_Id, Training_InstituteName, Training_InstituteCode,Institute_Address, Institute_City, Institute_StateId, 
		   Institute_CountryId, Institute_PinCode, Institute_Telephone, Institute_FaxNo, Institute_Email, Institute_Website, Institute_AffiliatedBy
		   ,TL.Institute_LocationCode
FROM         dbo.T0050_Training_Institute_Master TM WITH (NOLOCK) Left JOIN
			(
				SELECT Training_InstituteId, Institute_LocationCode = 
					STUFF((SELECT ', ' + Institute_LocationCode
						   FROM T0050_Training_Location_Master b WITH (NOLOCK) 
						   WHERE b.Training_InstituteId = a.Training_InstituteId 
						  FOR XML PATH('')), 1, 2, '')
				FROM T0050_Training_Location_Master a WITH (NOLOCK) 
				GROUP BY Training_InstituteId
					
				
			)TL on TL.Training_InstituteId = TM.Training_InstituteId


