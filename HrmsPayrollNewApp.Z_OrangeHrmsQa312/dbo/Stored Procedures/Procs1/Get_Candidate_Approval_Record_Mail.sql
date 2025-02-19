

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Candidate_Approval_Record_Mail]
		 @Cmp_id numeric(18,0)
		,@Emp_id numeric(18,0)
		,@ResumeFinal_id numeric(18,0)
		,@Curr_rpt_level  numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if exists (SELECT Rpt_Level FROM T0052_ResumeFinal_Approval WITH (NOLOCK) WHERE ResumeFinal_ID = @ResumeFinal_id )
		Begin
			Select distinct 
			LLA.ResumeFinal_ID as ResumeFinal_ID, 
			tbl1.Rpt_Level,
			tbl1.Is_Fwd_Leave_Rej, 
			tbl1.is_final_approval AS is_final_approval,
			tbl1.App_Emp_ID		as s_emp_id_Scheme_current	
			from 
			T0052_ResumeFinal_Approval LLA WITH (NOLOCK)
			inner join 		v0060_RESUME_FINAL VLA on VLA.Tran_ID = LLA.ResumeFinal_ID	
			CROSS JOIN
			(
				SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > (select max(Rpt_Level) + 1 from T0052_ResumeFinal_Approval WITH (NOLOCK) where T0052_ResumeFinal_Approval.ResumeFinal_ID = @ResumeFinal_id) THEN 0 ELSE 1 end) as is_final_approval
				,Is_Fwd_Leave_Rej, sd.Is_RM , ISNULL(sd.Is_BM,0) AS is_BM, ISNULL(sd.Is_HOD,0) AS is_Hod, ISNULL(sd.Is_HR,0) AS is_HR	, Leave_Days		
				FROM T0050_Scheme_Detail SD WITH (NOLOCK)
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail  WITH (NOLOCK)
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Candidate Approval')
								And Type = 'Candidate Approval'
							)
							--AND @Request_Type IN (SELECT data FROM dbo.Split(leave,'#')) 
						GROUP BY Scheme_Id
						
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Candidate Approval')
					And Type = 'Candidate Approval'
				)
				--AND @Request_Type IN (SELECT data FROM dbo.Split(SD.leave,'#')) 
				and SD.Rpt_Level = (select max(Rpt_Level) + 1 from T0052_ResumeFinal_Approval WITH (NOLOCK) where T0052_ResumeFinal_Approval.ResumeFinal_ID = @ResumeFinal_id)
				
			) as tbl1
			where lla.ResumeFinal_ID = @ResumeFinal_id 
			 and lla.Rpt_Level = (select max(Rpt_Level) from T0052_ResumeFinal_Approval WITH (NOLOCK) where ResumeFinal_ID = @ResumeFinal_id)
			 and tbl1.Rpt_Level <= @Curr_rpt_level			
		END
	else
			begin			
				SELECT 
				distinct LAD.* , tbl1.Rpt_Level,tbl1.Is_Fwd_Leave_Rej, tbl1.is_final_approval AS is_final_approval,'' As Effective_Date
				, tbl1.App_Emp_ID  as s_emp_id_Scheme_current
				FROM v0060_RESUME_FINAL LAD
				CROSS JOIN
				(
					SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > 1 THEN 0 ELSE 1 end) as is_final_approval
					,Is_Fwd_Leave_Rej, sd.Is_RM , sd.Is_BM,sd.Is_HOD,sd.Is_HR , Leave_Days
					FROM T0050_Scheme_Detail SD WITH (NOLOCK)
					INNER JOIN
						(
							SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail  WITH (NOLOCK)
								WHERE Scheme_Id in
								(
									SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
									and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Candidate Approval')
									And Type = 'Candidate Approval'
								)
								--AND @Request_Type IN (SELECT data FROM dbo.Split(leave,'#')) --and Rpt_Level = 1
							GROUP BY Scheme_Id
							
						) as tblFinal
					ON SD.Scheme_Id = tblFinal.Scheme_Id
					WHERE SD.Scheme_Id in
					(
						SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
						and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Candidate Approval')
						And Type = 'Candidate Approval'
					)
					--AND @Request_Type IN (SELECT data FROM dbo.Split(SD.leave,'#')) 
					and SD.Rpt_Level = 1
				) as tbl1				
				WHERE LAD.Tran_ID = @ResumeFinal_id		
		End
END

