-- =============================================
-- Author:		<Jaina>
-- Create date: <22-12-2016>
-- Description:	<Exit Application (Mail Approval)>
-- =============================================
CREATE PROCEDURE [dbo].[Get_Exit_Detail_For_Mail_Apporval]
	@Cmp_id numeric(18,0),
	@Emp_id numeric(18,0),
	@Exit_Id numeric(18,0),	
	@Curr_rpt_level  numeric(18,0)	
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
			--Added by Jaina 01-07-2020
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


	
	if exists (SELECT Rpt_Level FROM T0300_Emp_Exit_Approval_Level WITH (NOLOCK) WHERE Exit_id = @Exit_id )
		begin
			
			Select distinct e.Last_date as Last_Date_Level,
			 VEX.*, tbl1.Rpt_Level,tbl1.Is_Fwd_Leave_Rej,tbl1.is_final_approval ,
			 ISNULL((Case when isnull(tbl1.App_Emp_ID,0) =  0 then (case when isnull(tbl1.Is_RM,0) = 1  then VEX.S_Emp_ID 
																	when isnull(tbl1.Is_RMToRM,0) = 1 THEN	@R_Emp_Id2  --Added By Jimit 18012018
			 ELSE (CASE WHEN tbl1.Is_BM > 0 THEN 
			(
						SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
						WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = 
						(
							
						SELECT  inc.branch_id FROM dbo.T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN 
							dbo.T0095_INCREMENT inc WITH (NOLOCK) ON inc.increment_id = em.Increment_ID 
							WHERE em.emp_id = E.Emp_ID
						
						) 
						AND Effective_Date <= E.Resignation_date) AND dbo.T0095_MANAGERS.branch_id = 
						(
						SELECT  inc.branch_id FROM dbo.T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN 
							dbo.T0095_INCREMENT inc WITH (NOLOCK) ON inc.increment_id = em.Increment_ID 
							WHERE em.emp_id = E.Emp_ID
						)

			)
			 else tbl1.App_Emp_ID END) END ) ELSE tbl1.App_Emp_ID  end ),0) as s_emp_id_Scheme_current
			from 
			T0300_Emp_Exit_Approval_Level E WITH (NOLOCK)
			inner join 	V0200_Emp_EXITAPPLICATION VEX on VEX.Exit_Id = E.Exit_id	
			CROSS JOIN
			(
				SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > (select max(Rpt_Level) + 1 from T0300_Emp_Exit_Approval_Level WITH (NOLOCK) where Exit_id = @Exit_Id) THEN 0 ELSE 1 end) as is_final_approval
				,Is_Fwd_Leave_Rej, sd.Is_RM , ISNULL(sd.Is_BM,0) AS is_BM	, Leave_Days,isnull(Is_RMToRM,0) as Is_RMToRM
				FROM T0050_Scheme_Detail SD WITH (NOLOCK) 
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail WITH (NOLOCK)  
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Exit')
								And Type = 'Exit'
							)
							GROUP BY Scheme_Id
						
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Exit')
					And Type = 'Exit'
				)
				and SD.Rpt_Level = (select max(Rpt_Level) + 1 from T0300_Emp_Exit_Approval_Level WITH (NOLOCK) where Exit_id = @Exit_id)
				
			) as tbl1
			where E.Exit_id = @Exit_ID
			and E.RPT_Level = (select max(Rpt_Level) from T0300_Emp_Exit_Approval_Level WITH (NOLOCK) where Exit_id = @Exit_ID)
			and tbl1.Rpt_Level <= @Curr_rpt_level
		
		end
	else
		begin
			
			SELECT distinct VEX.* , tbl1.Rpt_Level,tbl1.Is_Fwd_Leave_Rej,tbl1.is_final_approval,last_date as Last_Date_Level,
			(Case when isnull(tbl1.App_Emp_ID,0) =  0 then (case when isnull(tbl1.Is_RM,0) = 1  then 
				(
					SELECT  TOP 1 ERD.R_Emp_ID   FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
 					( select max(Effect_Date) as Effect_Date,ERD1.Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
 					INNER join (Select Emp_ID From T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE Emp_ID = VEX.Emp_ID ) Qry 
 						on ERD1.Emp_ID = Qry.Emp_ID
 						where ERD1.Effect_Date <= getdate() and ERD1.Emp_ID = VEX.Emp_ID GROUP by ERD1.Emp_ID
 					) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 					T0080_EMP_MASTER EM WITH (NOLOCK) ON Em.Emp_ID = ERD.Emp_ID
					WHERE ERD.Emp_ID = VEX.Emp_ID
				    
				
				)
				when isnull(tbl1.Is_RMToRM,0) = 1 THEN	@R_Emp_Id2  
				
			else tbl1.App_Emp_ID end ) else tbl1.App_Emp_ID end) as s_emp_id_Scheme_current
			
			
			FROM V0200_Emp_EXITAPPLICATION VEX
			CROSS JOIN
			(
				SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > 1 THEN 0 ELSE 1 end) as is_final_approval
				,Is_Fwd_Leave_Rej, sd.Is_RM , sd.Is_BM , Leave_Days,isnull(Is_RMToRM,0) as Is_RMToRM
				FROM T0050_Scheme_Detail SD WITH (NOLOCK)
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail WITH (NOLOCK)  
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Exit')
								And Type = 'Exit'
							)
							GROUP BY Scheme_Id
						
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Exit')
					And Type = 'Exit'
				)
				and SD.Rpt_Level = 1
			) as tbl1
			WHERE VEX.exit_id = @Exit_ID
			
			
		end
	

END
