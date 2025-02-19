


-- =============================================
-- Author:	Sneha
-- ALTER date: 11 July 2013
-- Description:	get Resume detail
-- exec P0055_GetResumeMaster_Detail 'R9:1079',0
-- exec P0055_GetResumeMaster_Detail '',18
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[rpt_ResumeMaster_Detail]
	@Cmp_ID int,
	@From_Date datetime,
	@To_Date datetime,	
	@Job_Code as int,
	@Resume_Code as varchar(2000) = null,
	@flag bit
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @Job_Code =0
		set @Job_Code=NULL
		
	CREATE TABLE #Resume_Code 
		 (      
		   Resume_Code int 
		 )  
		 if @Resume_Code <> ''
		begin
			Insert Into #Resume_Code
			select  cast(data  as numeric) from dbo.Split (@Resume_Code,'#')
		end
	  
	if @flag=0 --for Resume Deatils Report 
		BEGIN
			select DISTINCT Resume_Id as emp_Id,Resume_Code as Alpha_Emp_Code,Resume_Code as Emp_Code,App_Full_name as Emp_Full_Name 
			from v0055_hrms_Resume_Master where Cmp_id=@cmp_id AND Rec_Post_Id=ISNULL(@Job_Code,Rec_Post_Id)
		END
	else --for Resume Deatils Report and all forms
		BEGIN	
			--if @Resume_Id = 0 or @Resume_Code =''	
			--	begin
				
			--		if exists(Select 1 from T0055_Resume_Master  where Resume_code = @Resume_Code)
			--			begin
						
			--				Select @Resume_Id=Resume_Id from T0055_Resume_Master  where Resume_code = @Resume_Code
			--				--select @Resume_Id
			--				 select * from v0055_hrms_Resume_Master where Resume_Id = @Resume_Id; 
			--				 select * from V0090_HRMS_RESUME_EDU where Resume_Id = @Resume_Id order by Row_ID desc; --30July2013 
			--				 Select * from V0090_HRMS_RESUME_EXP where Resume_Id = @Resume_Id order by Row_ID desc; --30July2013 
			--				 Select * from V0090_HRMS_RESUME_Skill where Resume_Id = @Resume_Id order by Row_ID desc; --200420105 Mukti(order by clause) 
			--				 Select * from V0090_HRMS_RESUME_IMMIGRATION where Resume_Id = @Resume_Id order by Row_ID desc;  --200420105 Mukti(order by clause) 
			--				 Select * from t0090_HRMS_RESUME_HEALTH where Resume_Id = @Resume_Id order by Row_ID desc; --200420105 Mukti(order by clause)
			--				 Select * from t0091_HRMS_RESUME_HEALTH_detail where row_id in (Select row_id from t0090_HRMS_RESUME_HEALTH where Resume_Id = @Resume_Id)
			--				 --get considered joining date
			--				 select * from T0060_RESUME_FINAL where Resume_ID = @Resume_Id
			--				 select * from V0090_HRMS_RESUME_NOMINEE where Resume_ID = @Resume_Id
			--				 select bm.Bank_Name,hb.Account_No,hb.Branch_Name,hb.Ifsc_Code,hb.Resume_Id from T0090_HRMS_RESUME_BANK hb inner join T0040_Bank_Master bm on hb.Bank_Id=bm.Bank_Id and hb.cmp_id=bm.cmp_id where hb.Resume_ID = @Resume_Id  --Mukti 27112015
			--				 select * from V0090_HRMS_RESUME_DOCUMENT where Resume_ID = @Resume_Id
			--			End		
			--		Else
			--			Begin
			--				raiserror('This resume code donot exists',16,2)
			--				return 
			--			End				
			--	End
			--Else
			--	Begin
				PRINT 'k'
				 --select * from v0055_hrms_Resume_Master where Resume_Id = @Resume_Id; --commented By Mukti 03122015
				--Mukti(start)03122015
					 select rm.*,cm.Cmp_Name,cm.Cmp_Address,cm.cmp_logo,ISNULL(hr.emp_file_name,'')emp_file_name from v0055_hrms_Resume_Master rm 
					 inner join T0010_COMPANY_MASTER cm WITH (NOLOCK) on rm.Cmp_id=cm.Cmp_Id
					 left join t0090_HRMS_RESUME_HEALTH hr WITH (NOLOCK) on hr.Resume_ID=rm.Resume_Id
					 where rm.Resume_Id in (select * from #Resume_Code); 
				--Mukti(end)03122015
					 select *,left(SUBSTRING(EduCertificate_path,CHARINDEX('$',EduCertificate_path)+1,LEN(EduCertificate_path)),22)+'...' as Edu_File
					 from V0090_HRMS_RESUME_EDU where Resume_Id in (select * from #Resume_Code) order by Row_ID desc; --30July2013  
					
					 Select *,left(SUBSTRING(ExpProof,CHARINDEX('$',ExpProof)+1,LEN(ExpProof)),22)+'...'as Exp_File
					 from V0090_HRMS_RESUME_EXP where Resume_Id in (select * from #Resume_Code) order by Row_ID desc; --30July2013  
					
					 Select *,left(SUBSTRING(attach_Documents,CHARINDEX('$',attach_Documents)+1,LEN(attach_Documents)),22)+'...'as Skill_File 
					 from V0090_HRMS_RESUME_Skill where Resume_Id in (select * from #Resume_Code) order by Row_ID desc; --200420105 Mukti(order by clause)
					 
					 Select *,left(SUBSTRING(attach_Documents,CHARINDEX('$',attach_Documents)+1,LEN(attach_Documents)),22)+'...'as Imm_File
					 from V0090_HRMS_RESUME_IMMIGRATION where Resume_Id in (select * from #Resume_Code) order by Row_ID desc; --200420105 Mukti(order by clause)
					 
					 Select * from t0090_HRMS_RESUME_HEALTH WITH (NOLOCK) where Resume_Id in (select * from #Resume_Code) order by Row_ID desc; --200420105 Mukti(order by clause)
					 Select * from t0091_HRMS_RESUME_HEALTH_detail WITH (NOLOCK) where row_id in (Select row_id from t0090_HRMS_RESUME_HEALTH WITH (NOLOCK) where Resume_Id in (select * from #Resume_Code))
					 --get considered joining date
					 select * from T0060_RESUME_FINAL WITH (NOLOCK) where Resume_ID in (select * from #Resume_Code)
					 select * from V0090_HRMS_RESUME_NOMINEE where Resume_ID in (select * from #Resume_Code)
					 select bm.Bank_Name,hb.Account_No,hb.Branch_Name,hb.Ifsc_Code,hb.Resume_Id from T0090_HRMS_RESUME_BANK hb WITH (NOLOCK) inner join T0040_Bank_Master bm WITH (NOLOCK) on hb.Bank_Id=bm.Bank_Id and hb.cmp_id=bm.cmp_id where hb.Resume_ID in (select * from #Resume_Code)  --Mukti 27112015
					 select * from V0090_HRMS_RESUME_DOCUMENT where Resume_ID in (select * from #Resume_Code)
					 
					 select distinct rp.Resume_Id,cs.data as Branch_Id,(upper(isnull(Branch_Name,'')) + ' » ' + upper(isnull(branch_city,''))) as Location 
					 from T0055_Resume_Master rp WITH (NOLOCK)
					 cross apply (select data from dbo.Split(rp.Location_Preference,'#') where data <>'') cs 
					 inner join T0030_BRANCH_MASTER bm WITH (NOLOCK) on bm.Branch_ID=cs.Data where rp.Cmp_ID =@Cmp_ID 
					 and Resume_Id in (select * from #Resume_Code) order by Location
				END
			END


