

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Claim_Detail_For_Mail_Apporval]
	  @Cmp_id numeric(18,0)
	 ,@Emp_id numeric(18,0)
	 ,@Claim_application_id numeric(18,0)	
	 ,@Curr_rpt_level  numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	--Added By Jimit 03112018
			DECLARE @R_Emp_Id1 as NUMERIC
			SET	@R_Emp_Id1 = 0
			DECLARE @R_Emp_Id2 as NUMERIC
			
			SELECT	@R_Emp_Id1 = R_Emp_ID 
			FROM	T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
					(
						select	max(Effect_Date) as Effect_Date,emp_id 
						from	T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
						where	ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
						GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
			where ERD.Emp_ID = @Emp_ID
			
			
			
			If @R_Emp_Id1 <> 0
				BEGIN
						
						SELECT @R_Emp_Id2 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
							(select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
								where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
							GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
						where ERD.Emp_ID = @R_Emp_Id1								
						
						
				END
			------------------Ended----------------------	
			


    if exists (SELECT Rpt_Level FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL  WITH (NOLOCK) WHERE Claim_App_ID = @Claim_application_id)
		begin
		
			Select distinct
			LLA.* , tbl1.Rpt_Level as Rpt_Level_1,tbl1.Is_Fwd_Leave_Rej, tbl1.is_final_approval AS is_final_approval,tbl1.Is_Fwd_Leave_Rej
			,
				ISNULL(	(	Case when isnull(tbl1.App_Emp_ID,0) =  0 
							then (
								case when isnull(tbl1.Is_RM,0) = 1  
								then CA.Emp_ID 
								when isnull(tbl1.Is_RMToRM,0) = 1 THEN	@R_Emp_Id2 
								ELSE (CASE WHEN tbl1.Is_BM > 0 THEN 
			(
						SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
						WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = 
						(
							
						SELECT  inc.branch_id FROM dbo.T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN 
							dbo.T0095_INCREMENT inc WITH (NOLOCK) ON inc.increment_id = em.Increment_ID 
							WHERE em.emp_id = LLA.Emp_ID
						
						) 
						AND Effective_Date <= LLA.For_Date) AND dbo.T0095_MANAGERS.branch_id = 
						(
						SELECT  inc.branch_id FROM dbo.T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN 
							dbo.T0095_INCREMENT inc WITH (NOLOCK) ON inc.increment_id = em.Increment_ID 
							WHERE em.emp_id = lla.Emp_ID
						)

			)
			 else tbl1.App_Emp_ID END) END ) ELSE tbl1.App_Emp_ID  end ),0) as s_emp_id_Scheme_current
			from T0100_CLAIM_APPLICATION CA WITH (NOLOCK) 
			inner join T0115_CLAIM_LEVEL_APPROVAL_DETAIL LLA WITH (NOLOCK) ON CA.CLAIM_APP_ID = LLA.CLAIM_APP_ID
			inner join  T0110_CLAIM_APPLICATION_DETAIL	VLA WITH (NOLOCK) on VLA.Claim_App_ID = LLA.Claim_App_ID	
			CROSS JOIN
			(
				SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > (select max(Rpt_Level) + 1 from T0115_CLAIM_LEVEL_APPROVAL_DETAIL WITH (NOLOCK) where T0115_CLAIM_LEVEL_APPROVAL_DETAIL.Claim_App_ID = @Claim_application_id) THEN 0 ELSE 1 end) as is_final_approval
				,Is_Fwd_Leave_Rej, sd.Is_RM , ISNULL(sd.Is_BM,0) AS is_BM	, Leave_Days		
				,SD.Is_RMToRM 
				FROM T0050_Scheme_Detail SD WITH (NOLOCK)
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail WITH (NOLOCK) 
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Claim')
								And Type = 'Claim'
							) 
						GROUP BY Scheme_Id
						
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Claim')
					And Type = 'Claim'
				)
				and SD.Rpt_Level = (select max(Rpt_Level) + 1 from T0115_CLAIM_LEVEL_APPROVAL_DETAIL WITH (NOLOCK) where T0115_CLAIM_LEVEL_APPROVAL_DETAIL.Claim_App_ID = @Claim_application_id)
				
			) as tbl1
			where lla.Claim_App_ID = @Claim_application_id 
			 and lla.Rpt_Level = (select max(Rpt_Level) from T0115_CLAIM_LEVEL_APPROVAL_DETAIL WITH (NOLOCK) where T0115_CLAIM_LEVEL_APPROVAL_DETAIL.Claim_App_ID = @Claim_application_id)
			 and tbl1.Rpt_Level <= @Curr_rpt_level
		End
	Else
		Begin
		
		
			--SELECT 
			--distinct  LAD.* , tbl1.Rpt_Level as Rpt_Level_1,tbl1.Is_Fwd_Leave_Rej, tbl1.is_final_approval AS is_final_approval,tbl1.Is_Fwd_Leave_Rej,'' As Effective_Date,
			--(Case when isnull(tbl1.App_Emp_ID,0) =  0 then (case when isnull(tbl1.Is_RM,0) = 1  then 
			--	(
			--		SELECT  TOP 1 ERD.R_Emp_ID   FROM T0090_EMP_REPORTING_DETAIL ERD INNER JOIN 
 		--			( select max(Effect_Date) as Effect_Date,ERD1.Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 
 		--			INNER join (
 		--							Select Emp_ID From T0090_EMP_REPORTING_DETAIL WHERE Emp_ID = LAD.Emp_ID ) Qry 
 		--							on ERD1.Emp_ID = Qry.Emp_ID
 		--							where ERD1.Effect_Date <= getdate() and ERD1.Emp_ID = LAD.Emp_ID GROUP by ERD1.Emp_ID
 		--			) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 		--			T0080_EMP_MASTER EM ON Em.Emp_ID = ERD.Emp_ID
			--		WHERE ERD.Emp_ID = LAD.Emp_ID
				    
				
			--	)
			--	when isnull(tbl1.Is_RMToRM,0) = 1 THEN	@R_Emp_Id2 
			--else tbl1.App_Emp_ID end ) else tbl1.App_Emp_ID end) as s_emp_id_Scheme_current
			--FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL LAD
			--CROSS JOIN
			--(
			--	SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > 1 THEN 0 ELSE 1 end) as is_final_approval
			--	,Is_Fwd_Leave_Rej, sd.Is_RM , sd.Is_BM , Leave_Days
			--	,SD.Is_RMToRM
			--	FROM T0050_Scheme_Detail SD 
			--	INNER JOIN
			--		(
			--			SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail  
			--				WHERE Scheme_Id in
			--				(
			--					SELECT Scheme_ID FROM T0095_EMP_SCHEME WHERE Emp_ID = @Emp_id
			--					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Claim')
			--					And Type = 'Claim'
			--				)
						
			--			GROUP BY Scheme_Id
						
			--		) as tblFinal
			--	ON SD.Scheme_Id = tblFinal.Scheme_Id
			--	WHERE SD.Scheme_Id in
			--	(
			--		SELECT Scheme_ID FROM T0095_EMP_SCHEME WHERE Emp_ID = @Emp_id
			--		and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Claim')
			--		And Type = 'Claim'
			--	)
			
			--	and SD.Rpt_Level = 1
			--) as tbl1
			--WHERE LAD.Claim_App_Id = @Claim_application_id --and LAD.Chk_By_Superior = 0
			
			SELECT SD.Rpt_Level,
			(Case when isnull(SD.App_Emp_ID,0) =  0 then (case when isnull(SD.Is_RM,0) = 1  then @R_Emp_Id1
						when isnull(SD.Is_RMToRM,0) = 1 THEN	@R_Emp_Id2   else sd.App_Emp_ID end ) else sd.App_Emp_ID end) as s_emp_id_Scheme_current,
			--SD.App_Emp_ID as s_emp_id_Scheme_current,
			 (CASE WHEN isnull(tblFinal.Rpt_Level,1) > 1 THEN 0 ELSE 1 end) as is_final_approval
				,Is_Fwd_Leave_Rej, sd.Is_RM , sd.Is_BM , Leave_Days
				,SD.Is_RMToRM
				FROM T0050_Scheme_Detail SD WITH (NOLOCK)
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail  WITH (NOLOCK)
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Claim')
								And Type = 'Claim'
							)
						and not_mandatory = 0
						GROUP BY Scheme_Id
						
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK)  WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Claim')
					And Type = 'Claim'
				)
			
				and SD.Rpt_Level = @Curr_rpt_level
			
		End
END

