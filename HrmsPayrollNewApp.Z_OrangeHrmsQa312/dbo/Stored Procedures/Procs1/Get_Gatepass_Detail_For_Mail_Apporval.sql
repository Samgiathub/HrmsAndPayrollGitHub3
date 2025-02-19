

CREATE PROCEDURE [dbo].[Get_Gatepass_Detail_For_Mail_Apporval]
	  @Cmp_id numeric(18,0)
	 ,@Emp_id numeric(18,0)	
	 ,@Curr_rpt_level  numeric(18,0)
	 ,@App_ID numeric(18,0)
AS
BEGIN
			SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


		
			--Added By Jimit 21122017
			DECLARE @R_Emp_Id1 as NUMERIC
			SET	@R_Emp_Id1 = 0
			DECLARE @R_Emp_Id2 as NUMERIC
			
			SELECT	@R_Emp_Id1 = R_Emp_ID 
			FROM	T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
					(
						select	max(Effect_Date) as Effect_Date,emp_id 
						from	T0090_EMP_REPORTING_DETAIL ERD1  WITH (NOLOCK)
						where	ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
						GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
			where ERD.Emp_ID = @Emp_ID
			
			
			
			If @R_Emp_Id1 <> 0
				BEGIN
						
						SELECT @R_Emp_Id2 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD  WITH (NOLOCK) INNER JOIN 
							(select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1  WITH (NOLOCK)
								where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
							GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
						where ERD.Emp_ID = @R_Emp_Id1								
						
						
				END
			------------------Ended----------------------	
		
		
    if exists (SELECT Rpt_Level FROM T0115_GATE_PASS_LEVEL_APPROVAL  WITH (NOLOCK) WHERE App_ID = @App_ID )
		begin
			Select distinct
			LLA.*,RM.Reason_Name , tbl1.Rpt_Level as Rpt_Level_1,tbl1.Is_Fwd_Leave_Rej, tbl1.is_final_approval AS is_final_approval,tbl1.Is_Fwd_Leave_Rej
			,ISNULL((Case when isnull(tbl1.App_Emp_ID,0) =  0 then (case when isnull(tbl1.Is_RM,0) = 1  then VLA.Emp_ID  
				when isnull(tbl1.Is_RMToRM,0) = 1 THEN	@R_Emp_Id2  --Added By Jimit 21122017
			ELSE (CASE WHEN tbl1.Is_BM > 0 THEN 
			(
						SELECT Emp_id FROM T0095_MANAGERS  WITH (NOLOCK) 
						WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS  WITH (NOLOCK) WHERE branch_id = 
						(
							
						SELECT  inc.branch_id FROM dbo.T0080_EMP_MASTER EM  WITH (NOLOCK) INNER JOIN 
							dbo.T0095_INCREMENT inc  WITH (NOLOCK) ON inc.increment_id = em.Increment_ID 
							WHERE em.emp_id = LLA.Emp_ID
						
						) 
						AND Effective_Date <= LLA.For_Date) AND dbo.T0095_MANAGERS.branch_id = 
						(
						SELECT  inc.branch_id FROM dbo.T0080_EMP_MASTER EM  WITH (NOLOCK) INNER JOIN 
							dbo.T0095_INCREMENT inc  WITH (NOLOCK) ON inc.increment_id = em.Increment_ID 
							WHERE em.emp_id = lla.Emp_ID
						)

			)
			
			 else tbl1.App_Emp_ID END) END ) ELSE tbl1.App_Emp_ID  end ),0) as s_emp_id_Scheme_current
			 ,vla.Remarks
			from 
			T0115_GATE_PASS_LEVEL_APPROVAL LLA  WITH (NOLOCK)
			inner join  T0100_GATE_PASS_APPLICATION	VLA  WITH (NOLOCK) on VLA.App_ID = LLA.App_ID	
			INNER JOIN T0040_Reason_Master RM  WITH (NOLOCK) ON RM.Res_Id = VLA.Reason_ID
			CROSS JOIN
			(
				SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > (select max(Rpt_Level) + 1 from T0115_GATE_PASS_LEVEL_APPROVAL  WITH (NOLOCK) where T0115_GATE_PASS_LEVEL_APPROVAL.App_ID = @App_ID) THEN 0 ELSE 1 end) as is_final_approval
				,Is_Fwd_Leave_Rej, sd.Is_RM , ISNULL(sd.Is_BM,0) AS is_BM	, Leave_Days		
				,SD.Is_RMToRM --Added By Jimit 21122017
				FROM T0050_Scheme_Detail SD  WITH (NOLOCK)
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail  WITH (NOLOCK) 
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME  WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME  WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'GatePass')
								And Type = 'GatePass'
							) 
						GROUP BY Scheme_Id
						
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME  WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'GatePass')
					And Type = 'GatePass'
				)
				and SD.Rpt_Level = (select max(Rpt_Level) + 1 from T0115_GATE_PASS_LEVEL_APPROVAL WITH (NOLOCK) where T0115_GATE_PASS_LEVEL_APPROVAL.App_ID = @App_ID)
				
			) as tbl1
			where lla.App_ID = @App_ID 
			 and lla.Rpt_Level = (select max(Rpt_Level) from T0115_GATE_PASS_LEVEL_APPROVAL WITH (NOLOCK) where T0115_GATE_PASS_LEVEL_APPROVAL.App_ID = @App_ID)
			 and tbl1.Rpt_Level <= @Curr_rpt_level
		End
	Else
		Begin
			
			
			
			SELECT 
			distinct LAD.*,RM.Reason_Name , tbl1.Rpt_Level as Rpt_Level_1,tbl1.Is_Fwd_Leave_Rej, tbl1.is_final_approval AS is_final_approval,tbl1.Is_Fwd_Leave_Rej,'' As Effective_Date,
			(Case when isnull(tbl1.App_Emp_ID,0) =  0 then (case when isnull(tbl1.Is_RM,0) = 1  then 
				(
					SELECT ERD.R_Emp_ID FROM T0090_EMP_REPORTING_DETAIL ERD  WITH (NOLOCK) INNER JOIN 
 					( select max(Effect_Date) as Effect_Date,ERD1.Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1  WITH (NOLOCK)
 					INNER join (Select Emp_ID From T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE Emp_ID = LAD.Emp_ID ) Qry 
 						on ERD1.Emp_ID = Qry.Emp_ID
 						where ERD1.Effect_Date <= getdate() and ERD1.Emp_ID = LAD.Emp_ID GROUP by ERD1.Emp_ID
 					) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 					T0080_EMP_MASTER EM  WITH (NOLOCK) ON Em.Emp_ID = ERD.Emp_ID
					WHERE ERD.Emp_ID = LAD.Emp_ID
				)
			when isnull(tbl1.Is_RMToRM,0) = 1 THEN	@R_Emp_Id2  --Added By Jimit 21122017
			else tbl1.App_Emp_ID end ) else tbl1.App_Emp_ID end) as s_emp_id_Scheme_current
			,lad.Remarks
			FROM T0100_GATE_PASS_APPLICATION LAD WITH (NOLOCK)
			INNER JOIN T0040_Reason_Master RM WITH (NOLOCK) ON RM.Res_Id = LAD.Reason_ID
			CROSS JOIN
			(
				SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > 1 THEN 0 ELSE 1 end) as is_final_approval,Is_Fwd_Leave_Rej, sd.Is_RM , sd.Is_BM , Leave_Days
						,SD.Is_RMToRM
				FROM T0050_Scheme_Detail SD WITH (NOLOCK) 
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail  WITH (NOLOCK) 
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'GatePass')
								And Type = 'GatePass'
							)
						GROUP BY Scheme_Id
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'GatePass')
					And Type = 'GatePass'
				)
				
				--and SD.Rpt_Level = 1
				
			) as tbl1
			WHERE LAD.App_ID = @App_ID and LAD.App_Status = 'P'
		End
END



