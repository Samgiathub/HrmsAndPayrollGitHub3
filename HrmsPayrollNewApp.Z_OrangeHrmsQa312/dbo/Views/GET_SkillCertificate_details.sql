

CREATE VIEW [dbo].[GET_SkillCertificate_details]
AS
select Skill_Level,Certi_Detail_Id,csd.Certi_Id,Descriptions,Exp_Years,cm.Certificate_Name ,csd.Cmp_Id
from T0500_Certificateskill_Details as csd 
left outer join T0500_Certificateskill_Master  as cm on cm.Certi_Id=csd.Certi_Id

