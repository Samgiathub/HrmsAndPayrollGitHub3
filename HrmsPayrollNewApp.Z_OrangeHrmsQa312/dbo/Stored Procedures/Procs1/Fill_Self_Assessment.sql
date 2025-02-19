


---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[Fill_Self_Assessment]
	  @cmp_id	 numeric(18,0)
	 ,@init_id numeric(18,0)	
	 ,@emp_id  numeric(18,0)	 
	 ,@flag int --1 for self assessment form and 2 for all others form
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @sa_start_date as DATETIME
	DECLARE @dept_id as INT
	DECLARE @desig_id as INT
	DECLARE @branch_id as INT
	
	
	if @flag=1
		BEGIN
			select @sa_start_date=SA_Startdate from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where InitiateId=@init_id and Cmp_ID= @cmp_id
		
			select  @dept_id=IE.Dept_ID,@desig_id=IE.Desig_Id,@branch_id=IE.Branch_ID
			from T0080_EMP_MASTER em WITH (NOLOCK)
			INNER JOIN	
			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Cat_ID,I.Dept_ID
			FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
				(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
				 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
					(
						SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
						FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = @cmp_id GROUP BY EMP_ID
					) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
				 WHERE CMP_ID = @cmp_id
				 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
			where I.Cmp_ID= @cmp_id
			)IE on ie.Emp_ID = em.Emp_ID
			where em.cmp_id=@cmp_id  and em.Emp_Left<>'Y' and em.Emp_ID=@emp_id
		
		--select  IE.Dept_ID,IE.Desig_Id,IE.Branch_ID
		--	from T0080_EMP_MASTER em
		--	INNER JOIN	
		--	(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Cat_ID,I.Dept_ID
		--	FROM T0095_INCREMENT I INNER JOIN
		--		(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
		--		 FROM T0095_INCREMENT Inner JOIN
		--			(
		--				SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
		--				FROM T0095_INCREMENT WHERE CMP_ID = @cmp_id GROUP BY EMP_ID
		--			) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
		--		 WHERE CMP_ID = @cmp_id
		--		 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
		--	where I.Cmp_ID= @cmp_id
		--	)IE on ie.Emp_ID = em.Emp_ID
		--	where em.cmp_id=@cmp_id  and em.Emp_Left<>'Y' and em.Emp_ID=@emp_id

   --print 'k'
   --print @branch_id
   --PRINT @desig_id
   --PRINT @dept_id
			select h.SApparisal_ID,h.Cmp_ID,h.SApparisal_ID,h.SCateg_Id,h.SBranch_Id,h.SApparisal_Content,SAppraisal_Sort,isnull(SIsMandatory,0)as SIsMandatory,
				isnull(SWeight,0)as SWeight,isnull(SKPAWeight,0)as Weightage,h.Ref_SID,
				es.* from T0040_SelfAppraisal_Master h WITH (NOLOCK)
			LEFT join T0052_HRMS_EmpSelfAppraisal ES WITH (NOLOCK) on h.SApparisal_ID=ES.SApparisal_ID and ES.InitiateId=@init_id and es.Emp_ID=@emp_id 
			where h.cmp_id=@cmp_id and 
			((@dept_id IS NULL or ISNULL(@dept_id,0) in (select data from dbo.Split(isnull(sdept_id,0),'#')) or isnull(SDept_Id,'')='') 
            and (@branch_id is null or @branch_id in (select data from dbo.Split(isnull(SBranch_Id,0),'#')) or isnull(SBranch_Id,'')='') 
            and (@desig_id is NULL or @desig_id in (select data from dbo.Split(isnull(SCateg_Id,0),'#')) or isnull(SCateg_Id,'')='')) 
            and isnull(SType,1)=1 and h.Effective_Date =(select max(Effective_Date) from T0040_SelfAppraisal_Master am WITH (NOLOCK) where cmp_id=@cmp_id
			and Effective_Date <= @sa_start_date and isnull(am.Ref_SID,am.SApparisal_ID) = isnull(h.Ref_SID,h.SApparisal_ID)) 
				
		END
	else	
		BEGIN
		DECLARE @count_sa as int
		set @count_sa=0
			select @count_sa=count(ESA_ID) from T0052_HRMS_EmpSelfAppraisal WITH (NOLOCK) where Cmp_ID=@cmp_id and InitiateId=@init_id and emp_Id=@emp_id
		
		if @count_sa > 0
			BEGIN
				SELECT distinct sa.SApparisal_ID,sa.SApparisal_Content,es.Emp_Weightage,es.Emp_Rating,es.Final_Emp_Score,
				ISNULL(ES.RM_Weightage,ES.Emp_Weightage)as RM_Weightage,							
				case when ISNULL(HOD_Weightage,0) > 0 then ISNULL(HOD_Weightage,0)
				when ISNULL(RM_Weightage,0) > 0 then ISNULL(RM_Weightage,0) 
				when ISNULL(Emp_Weightage,0) > 0 then ISNULL(Emp_Weightage,0) end as HOD_Weightage,
				
				case when ISNULL(GH_Weightage,0) > 0 then ISNULL(GH_Weightage,0)
				when ISNULL(HOD_Weightage,0) > 0 then ISNULL(HOD_Weightage,0)
				when ISNULL(RM_Weightage,0) > 0 then ISNULL(RM_Weightage,0)
				when ISNULL(Emp_Weightage,0) > 0 then ISNULL(Emp_Weightage,0) end as GH_Weightage,
				
				case when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) else ISNULL(Emp_Rating,0) end as RM_Rating,
				case when ISNULL(HOD_Rating,0) > 0 then ISNULL(HOD_Rating,0)
				when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) 
				when ISNULL(Emp_Rating,0) > 0 then ISNULL(Emp_Rating,0) end as HOD_Rating,
				
				case when ISNULL(GH_Rating,0) > 0 then ISNULL(GH_Rating,0)
				when ISNULL(HOD_Rating,0) > 0 then ISNULL(HOD_Rating,0)
				when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0)
				when ISNULL(Emp_Rating,0) > 0 then ISNULL(Emp_Rating,0) end as GH_Rating,
				
				--ISNULL(ES.Final_RM_Score,ES.Final_Emp_Score)as Final_RM_Score,
				case when ISNULL(ES.Final_RM_Score,0) > 0 then ISNULL(Final_RM_Score,0)
				else ISNULL(ES.Final_Emp_Score,0)end as Final_RM_Score,		
				
				case when ISNULL(ES.Final_HOD_Score,0) > 0 then ISNULL(Final_HOD_Score,0)
				when ISNULL(Final_RM_Score,0) > 0 then ISNULL(Final_RM_Score,0) 
				when ISNULL(Final_Emp_Score,0) > 0 then ISNULL(Final_Emp_Score,0) end as Final_HOD_Score,
				
				case when ISNULL(ES.Final_GH_Score,0) > 0 then ISNULL(Final_GH_Score,0)
				when ISNULL(Final_HOD_Score,0) > 0 then ISNULL(Final_HOD_Score,0)
				when ISNULL(Final_RM_Score,0) > 0 then ISNULL(Final_RM_Score,0)
				when ISNULL(Final_Emp_Score,0) > 0 then ISNULL(Final_Emp_Score,0) end as Final_GH_Score,	
				es.GH_Comments,es.HOD_Comments,es.RM_Comments,isnull(SWeight,0)as SWeight,isnull(SIsMandatory,0)as SIsMandatory,InitiateId
				from T0040_SelfAppraisal_Master sa WITH (NOLOCK)
				left Join T0052_HRMS_EmpSelfAppraisal  ES  WITH (NOLOCK) on sa.SApparisal_ID = ES.SApparisal_ID 
				where sa.Cmp_ID=@cmp_id and InitiateId=@init_id and emp_Id=@emp_id
			END
		ELSE
			BEGIN
				select @sa_start_date=SA_Startdate from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where InitiateId=@init_id and Cmp_ID= @cmp_id
		
				select  @dept_id=IE.Dept_ID,@desig_id=IE.Cat_ID,@branch_id=IE.Branch_ID
				from T0080_EMP_MASTER em WITH (NOLOCK)
				INNER JOIN	
				(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Cat_ID,I.Dept_ID
				FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
					(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
					 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
						(
							SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
							FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = @cmp_id GROUP BY EMP_ID
						) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
					 WHERE CMP_ID = @cmp_id
					 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
				where I.Cmp_ID= @cmp_id
				)IE on ie.Emp_ID = em.Emp_ID
				where em.cmp_id=@cmp_id  and em.Emp_Left<>'Y' and em.Emp_ID=@emp_id
			--select 555
			--SELECT @dept_id,@desig_id,@branch_id,@sa_start_date
				select distinct sa.SApparisal_ID,sa.SApparisal_Content,sa.SKPAWeight as Emp_Weightage,es.Emp_Rating,es.Final_Emp_Score,
				ISNULL(ES.RM_Weightage,sa.SKPAWeight)as RM_Weightage,							
				case when ISNULL(HOD_Weightage,0) > 0 then ISNULL(HOD_Weightage,0)
				when ISNULL(RM_Weightage,0) > 0 then ISNULL(RM_Weightage,0) 
				when ISNULL(Emp_Weightage,0) > 0 then ISNULL(Emp_Weightage,0) end as HOD_Weightage,
				
				case when ISNULL(GH_Weightage,0) > 0 then ISNULL(GH_Weightage,0)
				when ISNULL(HOD_Weightage,0) > 0 then ISNULL(HOD_Weightage,0)
				when ISNULL(RM_Weightage,0) > 0 then ISNULL(RM_Weightage,0)
				when ISNULL(Emp_Weightage,0) > 0 then ISNULL(Emp_Weightage,0) end as GH_Weightage,
				
				case when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) else ISNULL(Emp_Rating,0) end as RM_Rating,
				case when ISNULL(HOD_Rating,0) > 0 then ISNULL(HOD_Rating,0)
				when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) 
				when ISNULL(Emp_Rating,0) > 0 then ISNULL(Emp_Rating,0) end as HOD_Rating,
				
				case when ISNULL(GH_Rating,0) > 0 then ISNULL(GH_Rating,0)
				when ISNULL(HOD_Rating,0) > 0 then ISNULL(HOD_Rating,0)
				when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0)
				when ISNULL(Emp_Rating,0) > 0 then ISNULL(Emp_Rating,0) end as GH_Rating,
				
				--ISNULL(ES.Final_RM_Score,ES.Final_Emp_Score)as Final_RM_Score,
				case when ISNULL(ES.Final_RM_Score,0) > 0 then ISNULL(Final_RM_Score,0)
				else ISNULL(ES.Final_Emp_Score,0)end as Final_RM_Score,				
				case when ISNULL(ES.Final_HOD_Score,0) > 0 then ISNULL(Final_HOD_Score,0)
				when ISNULL(Final_RM_Score,0) > 0 then ISNULL(Final_RM_Score,0) 
				when ISNULL(Final_Emp_Score,0) > 0 then ISNULL(Final_Emp_Score,0) end as Final_HOD_Score,
				
				case when ISNULL(ES.Final_GH_Score,0) > 0 then ISNULL(Final_GH_Score,0)
				when ISNULL(Final_HOD_Score,0) > 0 then ISNULL(Final_HOD_Score,0)
				when ISNULL(Final_RM_Score,0) > 0 then ISNULL(Final_RM_Score,0)
				when ISNULL(Final_Emp_Score,0) > 0 then ISNULL(Final_Emp_Score,0) end as Final_GH_Score,	
				es.GH_Comments,es.HOD_Comments,es.RM_Comments,isnull(SWeight,0)as SWeight,isnull(SIsMandatory,0)as SIsMandatory,InitiateId
				from T0040_SelfAppraisal_Master sa WITH (NOLOCK)
				LEFT join T0052_HRMS_EmpSelfAppraisal ES WITH (NOLOCK) on sa.SApparisal_ID=ES.SApparisal_ID and es.Emp_ID=@emp_id and sa.Cmp_ID=es.Cmp_ID
				where 
				sa.Effective_Date = (select max(Effective_Date) Effective_Date
				from T0040_SelfAppraisal_Master am WITH (NOLOCK) where am.cmp_id=@cmp_id
				and am.Effective_Date <= @sa_start_date) --and isnull(am.Ref_SID,am.SApparisal_ID) = isnull(sa.Ref_SID,sa.SApparisal_ID)) and
				and sa.cmp_id=@cmp_id and 
				((@dept_id IS NULL  or @dept_id in (select data from dbo.Split(sdept_id,'#')) or isnull(sa.SDept_Id,'')='') 
				and (@branch_id IS NULL  or @branch_id in (select data from dbo.Split(SBranch_Id,'#')) or isnull(sa.SBranch_Id,'')='') 
				and (@desig_id IS NULL  or @desig_id in (select data from dbo.Split(SCateg_Id,'#')) or isnull(sa.SCateg_Id,'')='')) 
				and isnull(SType,1)=1
			END
			
	END
END

