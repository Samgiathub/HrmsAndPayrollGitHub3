

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[Appraisal_Final_Score_Calculation] 
	 @Cmp_Id     Numeric(18,0)
	,@Emp_ID	 Numeric(18,0)
	,@Initiation_ID  Numeric(18,0)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
	declare @SA_RestrictWeightage as NUMERIC(18,2)
	declare @SA_Weightage as NUMERIC(18,2)
	declare @EKPA_RestrictWeightage as NUMERIC(18,2)
	declare @KPA_Weightage1 as NUMERIC(18,2)
	declare @PoA_Weightage as NUMERIC(18,2)
	declare @tot_SA_Score as NUMERIC(18,2)=0
	declare @tot_KPA_Score as NUMERIC(18,2)=0
	declare @tot_PO_Score as NUMERIC(18,2)=0
	declare @Overall_Score as NUMERIC(18,2)=0
	declare @Range_ID as NUMERIC(18,0)
	
	begin	
		select @SA_RestrictWeightage=ISNULL(SA_RestrictWeightage,0),@SA_Weightage=ISNULL(SA_Weightage,0),
			   @EKPA_RestrictWeightage=ISNULL(EKPA_RestrictWeightage,0),
		       @KPA_Weightage1=ISNULL(EKPA_Weightage,0),@PoA_Weightage=ISNULL(PoA_Weightage,0)
		from T0060_Appraisal_EmpWeightage WITH (NOLOCK) where Emp_Id=@Emp_id and Cmp_Id=@Cmp_Id and 
		isnull(Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id)) =
		(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id)) 
		 from [T0060_Appraisal_EmpWeightage] WITH (NOLOCK) where cmp_id=@Cmp_Id and effective_date<= GETDATE())
					
		--select @tot_SA_Score=sum(ISNULL(Manager_Score,0)) from T0052_Emp_SelfAppraisal 
		--where Emp_Id=@Emp_id and InitiateId=@Initiation_ID and Cmp_Id=@Cmp_Id
		--group by Emp_Id,InitiateId 
		
		create table #tempsum
		(
			Manager_Score numeric(18,2),
			SAppraisal_ID numeric(18,0)
		)		
			
		insert into #tempsum
		SELECT DISTINCT Manager_Score,SAppraisal_ID FROM T0052_Emp_SelfAppraisal WITH (NOLOCK)
		WHERE CMP_ID = @Cmp_Id and InitiateId=@Initiation_ID and Emp_Id=@Emp_id
			
		set @tot_SA_Score=(select sum(Manager_Score) from #tempsum)				
		DROP TABLE #tempsum
						
		select @tot_KPA_Score=sum(ISNULL(KPA_Achievement,0)) from T0052_HRMS_KPA WITH (NOLOCK) where Emp_Id=@Emp_id and Cmp_Id=@Cmp_Id and InitiateId=@Initiation_ID
		group by Emp_Id,InitiateId
				
		select @tot_PO_Score=sum(ISNULL(Att_Achievement,0)) from T0052_HRMS_AttributeFeedback WITH (NOLOCK) where Emp_Id=@Emp_id and Cmp_Id=@Cmp_Id and Initiation_Id=@Initiation_ID
		group by Emp_Id,Initiation_Id
			
			--print @tot_SA_Score
			--print @tot_KPA_Score
			--print @tot_PO_Score
				
			if @SA_RestrictWeightage=1
				BEGIN
					set @Overall_Score = @tot_SA_Score
				END
			ELSE
				BEGIN
					set @Overall_Score = (@tot_SA_Score*@SA_Weightage)/100
				END
			
			if @EKPA_RestrictWeightage=1
				BEGIN				
					set @Overall_Score = ISNULL(@Overall_Score,0) + @tot_KPA_Score					
					--print @Overall_Score
				END
			ELSE 
				BEGIN
					set @Overall_Score =ISNULL(@Overall_Score,0) + (@tot_KPA_Score*@KPA_Weightage1)/100
				END							
			set @Overall_Score = ISNULL(@Overall_Score,0) + ((@tot_PO_Score*@PoA_Weightage)/100)
			--print @Overall_Score
			select @Range_ID=Range_ID from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@Cmp_Id and @Overall_Score BETWEEN Range_From and Range_To
		
			update T0050_HRMS_InitiateAppraisal set Overall_Score=@Overall_Score,Achivement_Id=@Range_ID
			where InitiateId=@Initiation_ID and Cmp_ID=@Cmp_Id
		end	
RETURN


