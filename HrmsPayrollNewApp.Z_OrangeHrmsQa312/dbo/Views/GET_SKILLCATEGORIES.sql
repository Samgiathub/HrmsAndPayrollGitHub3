

CREATE VIEW [dbo].[GET_SKILLCATEGORIES]
AS

SELECT     SubCat_ID,SubCat_Code,SubCat_Name,cm.Cat_Name as Cat_Name,cm.Cat_Id as Cat_Id,Scm.Cmp_Id as Cmp_ID
FROM         T0500_SubCatSkill_Master SCM
left outer join T0500_CatSkill_Master CM on Cm.Cat_Id = Scm.Cat_Id


