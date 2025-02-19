

-- =============================================
-- Author:	Sneha
-- ALTER date: 11 July 2013
-- Description:	get Resume detail
-- exec P0055_GetResumeMaster_Detail 'R9:1079',0
-- exec P0055_GetResumeMaster_Detail '',18
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0055_GetResumeMaster_Detail]
	@Resume_Code as varchar(50),
	@Resume_Id as int = null
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Resume_Id = null or @Resume_Id = 0	
		BEGIN		
			IF EXISTS(Select 1 from T0055_Resume_Master WITH (NOLOCK) where Resume_code = @Resume_Code)
				BEGIN				
					 SELECT @Resume_Id=Resume_Id from T0055_Resume_Master WITH (NOLOCK) where Resume_code = @Resume_Code
					--select @Resume_Id
					 SELECT * from v0055_hrms_Resume_Master where Resume_Id = @Resume_Id; 
					 SELECT * from V0090_HRMS_RESUME_EDU where Resume_Id = @Resume_Id order by Row_ID desc; --30July2013 
					 SELECT * from V0090_HRMS_RESUME_EXP where Resume_Id = @Resume_Id order by Row_ID desc; --30July2013 
					 SELECT * from V0090_HRMS_RESUME_Skill where Resume_Id = @Resume_Id order by Row_ID desc; --200420105 Mukti(order by clause) 
					 Select * from V0090_HRMS_RESUME_IMMIGRATION where Resume_Id = @Resume_Id order by Row_ID desc;  --200420105 Mukti(order by clause) 
					 Select * from t0090_HRMS_RESUME_HEALTH WITH (NOLOCK) where Resume_Id = @Resume_Id order by Row_ID desc; --200420105 Mukti(order by clause)
					 Select * from t0091_HRMS_RESUME_HEALTH_detail WITH (NOLOCK) where row_id in (Select row_id from t0090_HRMS_RESUME_HEALTH WITH (NOLOCK) where Resume_Id = @Resume_Id)
					 --get considered joining date
					 select * from T0060_RESUME_FINAL WITH (NOLOCK) where Resume_ID = @Resume_Id
					 select * from V0090_HRMS_RESUME_NOMINEE where Resume_ID = @Resume_Id
			         select bm.Bank_Name,hb.Account_No,hb.Branch_Name,hb.Ifsc_Code,hb.Resume_Id from T0090_HRMS_RESUME_BANK hb WITH (NOLOCK) inner join T0040_Bank_Master bm WITH (NOLOCK) on hb.Bank_Id=bm.Bank_Id and hb.cmp_id=bm.cmp_id where hb.Resume_ID = @Resume_Id  --Mukti 27112015
			         select * from V0090_HRMS_RESUME_DOCUMENT where Resume_ID = @Resume_Id
			         
				End		
			Else
				Begin
					raiserror('This resume code donot exists',16,2)
					return 
				End				
		End
	Else
		Begin
		
		 --select * from v0055_hrms_Resume_Master where Resume_Id = @Resume_Id; --commented By Mukti 03122015
		--Mukti(start)03122015
			 select rm.*,cm.Cmp_Name,cm.Cmp_Address,cm.cmp_logo,hr.emp_file_name from v0055_hrms_Resume_Master rm 
			 inner join T0010_COMPANY_MASTER cm WITH (NOLOCK) on rm.Cmp_id=cm.Cmp_Id
			 left join t0090_HRMS_RESUME_HEALTH hr WITH (NOLOCK) on hr.Resume_ID=rm.Resume_Id
			 where rm.Resume_Id = @Resume_Id; 
		--Mukti(end)03122015
			 select *,left(SUBSTRING(EduCertificate_path,CHARINDEX('$',EduCertificate_path)+1,LEN(EduCertificate_path)),22)+'...' as Edu_File
			 from V0090_HRMS_RESUME_EDU where Resume_Id = @Resume_Id order by Row_ID desc; --30July2013  
			 Select *,left(SUBSTRING(ExpProof,CHARINDEX('$',ExpProof)+1,LEN(ExpProof)),22)+'...'as Exp_File  from V0090_HRMS_RESUME_EXP where Resume_Id = @Resume_Id order by Row_ID desc; --30July2013  
			 Select *,left(SUBSTRING(attach_Documents,CHARINDEX('$',attach_Documents)+1,LEN(attach_Documents)),22)+'...'as Skill_File  from V0090_HRMS_RESUME_Skill where Resume_Id = @Resume_Id order by Row_ID desc; --200420105 Mukti(order by clause)
			 Select *,left(SUBSTRING(attach_Documents,CHARINDEX('$',attach_Documents)+1,LEN(attach_Documents)),22)+'...'as Imm_File  from V0090_HRMS_RESUME_IMMIGRATION where Resume_Id = @Resume_Id order by Row_ID desc; --200420105 Mukti(order by clause)
			 Select * from t0090_HRMS_RESUME_HEALTH WITH (NOLOCK) where Resume_Id = @Resume_Id order by Row_ID desc; --200420105 Mukti(order by clause)
			 Select * from t0091_HRMS_RESUME_HEALTH_detail WITH (NOLOCK) where row_id in (Select row_id from t0090_HRMS_RESUME_HEALTH WITH (NOLOCK) where Resume_Id = @Resume_Id)
			 --get considered joining date
			 select * from T0060_RESUME_FINAL WITH (NOLOCK) where Resume_ID = @Resume_Id
			 select * from V0090_HRMS_RESUME_NOMINEE where Resume_ID = @Resume_Id
			 select bm.Bank_Name,hb.Account_No,hb.Branch_Name,hb.Ifsc_Code,hb.Resume_Id from T0090_HRMS_RESUME_BANK hb WITH (NOLOCK) inner join T0040_Bank_Master bm WITH (NOLOCK) on hb.Bank_Id=bm.Bank_Id and hb.cmp_id=bm.cmp_id where hb.Resume_ID = @Resume_Id  --Mukti 27112015
			 select * from V0090_HRMS_RESUME_DOCUMENT where Resume_ID = @Resume_Id
			 
			 select distinct rp.Resume_Id,cs.data as Branch_Id,(upper(isnull(Branch_Name,'')) + ' » ' + upper(isnull(branch_city,''))) as Location 
			 from T0055_Resume_Master rp WITH (NOLOCK)
			 cross apply (select data from dbo.Split(rp.Location_Preference,'#') where data <>'') cs 
			 inner join T0030_BRANCH_MASTER bm WITH (NOLOCK) on bm.Branch_ID=cs.Data where Resume_Id=@Resume_Id order by Location
			 
			 select Row_Id,Resume_Id,Member_Name,Member_Age,Relationship,Occupation,Comments,Member_Date_of_Birth, Relationship_ID
			 from V0090_HRMS_RESUME_NOMINEE where Resume_ID = @Resume_Id
			 
			 SELECT DISTINCT LM.Lang_ID,LM.Lang_Name,EM.Is_Read,EM.Is_Write,EM.Is_Speak from T0040_LANGUAGE_MASTER LM WITH (NOLOCK)
			 INNER JOIN T0090_HRMS_EMP_LANGUAGE_DETAIL EM WITH (NOLOCK) ON LM.Lang_ID=EM.Lang_ID
			 WHERE EM.Resume_ID=@Resume_Id

		END
END


