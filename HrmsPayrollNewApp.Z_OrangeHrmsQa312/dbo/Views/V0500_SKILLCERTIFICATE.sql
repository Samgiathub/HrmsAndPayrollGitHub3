create VIEW [dbo].[V0500_SKILLCERTIFICATE]
AS
SELECT     csm.Certi_Id, csm.Certificate_Name, csm.Certificate_Code, CM.Cat_Id, CM.Cat_Name, scm.SubCat_Id, scm.SubCat_Name, csm.Cmp_Id
FROM        dbo.T0500_Certificateskill_Master AS csm LEFT OUTER JOIN
                  dbo.T0500_CatSkill_Master AS CM ON CM.Cat_Id = csm.Cat_Id LEFT OUTER JOIN
                  dbo.T0500_SubCatSkill_Master AS scm ON scm.SubCat_Id = csm.SubCat_Id
