

CREATE PROCEDURE [dbo].[Get_PreCompOff_For_Mail_Apporval]
	 @Cmp_id numeric(18,0)
	 ,@Emp_id numeric(18,0)
	 ,@PreCompOff_App_ID numeric(18,0)		
	 ,@Curr_rpt_level  numeric(18,0)	
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


BEGIN
	
	

	
--Added By Jimit 05082019
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
	
	
	if exists (SELECT Rpt_Level FROM T0115_PreCompOff_Approval_Level WITH (NOLOCK) WHERE PreCompOff_App_ID = @PreCompOff_App_ID )
		begin
			
				select 
				distinct LLA.Emp_ID, 
						 LLA.PreCompOff_App_ID,
						 LLA.PreCompOff_Apr_Date,
						 LLA.PrecompOff_App_Date, 
						 LLA.Approval_Status,
						 LLA.Final_Approval,
						 LLa.From_Date,
						 LLA.To_Date,
						 LLA.Period,
						 LLA.PreCompOff_Apr_Date,
						 LLA.PrecompOff_App_Date,
						 LLa.Remarks,
						 tbl1.rpt_Level,
						 tbl1.Is_Fwd_Leave_Rej,
			case when tbl1.Leave_Days > 0 then 
					case when LLA.Period <tbl1.Leave_Days then 
						1 
					else 
						0 
					end 
			else 
					tbl1.is_final_approval 
			end is_Final_Approval,
			ISNULL((
			Case when isnull(tbl1.App_Emp_ID,0) =  0 then 
			(
				case when isnull(tbl1.Is_RM,0) = 1  then 
					VPA.S_Emp_ID  
				when isnull(tbl1.Is_RMToRM,0) = 1 THEN	@R_Emp_Id2  --Added By Jimit 18012018
				ELSE 
				(
					CASE WHEN tbl1.Is_BM > 0 THEN 
					(	
						SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
						WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = 
						(
							
						SELECT  inc.branch_id FROM dbo.T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN 
							dbo.T0095_INCREMENT inc WITH (NOLOCK) ON inc.increment_id = em.Increment_ID 
							WHERE em.emp_id = lla.Emp_ID
						
						) 
						AND Effective_Date <= lla.From_Date) AND dbo.T0095_MANAGERS.branch_id = 
						(
						SELECT  inc.branch_id FROM dbo.T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN 
							dbo.T0095_INCREMENT inc WITH (NOLOCK) ON inc.increment_id = em.Increment_ID 
							WHERE em.emp_id = lla.Emp_ID
						)

					)
			 else 
				tbl1.App_Emp_ID 
			 END
			 ) 
			 END 
			 ) 
			 ELSE 
			 tbl1.App_Emp_ID  
			 end 
			 ),0) as s_emp_id_Scheme_current
			from 
			T0115_PreCompOff_Approval_Level LLA WITH (NOLOCK)
			inner join  V0110_PrecompOff_Application VPA on VPA.PreCompOff_App_ID = VPA.PreCompOff_App_ID
			CROSS JOIN
			(
				SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > (select max(Rpt_Level) + 1 from T0115_PreCompOff_Approval_Level WITH (NOLOCK) where PreCompOff_App_ID = @PreCompOff_App_ID) THEN 0 ELSE 1 end) as is_final_approval
				,Is_Fwd_Leave_Rej, sd.Is_RM , ISNULL(sd.Is_BM,0) AS is_BM	, Leave_Days		
				,SD.Is_RMToRM --Added By Jimit 05082019
				FROM T0050_Scheme_Detail SD WITH (NOLOCK)
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail WITH (NOLOCK) 
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Pre-CompOff')
								And Type = 'Pre-CompOff'
							)
						GROUP BY Scheme_Id
						
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Pre-CompOff')
					And Type = 'Pre-CompOff'
				)
				 and SD.Rpt_Level = (select max(Rpt_Level) + 1 from T0115_PreCompOff_Approval_Level WITH (NOLOCK) where PreCompOff_App_ID = @PreCompOff_App_ID)
				
			) as tbl1
			where lla.PreCompOff_App_ID = @PreCompOff_App_ID 
			and lla.Rpt_Level = (select max(Rpt_Level) from T0115_PreCompOff_Approval_Level WITH (NOLOCK) where PreCompOff_App_ID = @PreCompOff_App_ID)
			and tbl1.Rpt_Level <= @Curr_rpt_level
		
		end
	else
		begin
			
			SELECT distinct		LAd.[PreCompOff_App_ID]
								  ,LAd.[cmp_ID]
								  ,LAd.[Emp_ID]
								  ,LAd.[S_Emp_ID]
								  ,LAd.[From_Date]
								  ,LAd.[To_Date]
								  ,LAd.[Period]
								  ,LAd.[Remarks]
								  ,LAd.[App_Status]
								  ,LAd.[Emp_Full_Name]
								  ,LAd.[Alpha_Emp_Code]
								  ,LAd.[Emp_First_Name]
								  ,LAd.[PreCompOff_App_date] , 
								tbl1.Rpt_Level,
								tbl1.Is_Fwd_Leave_Rej, 
			CASE WHEN tbl1.Leave_Days > 0 THEN 
				CASE WHEN Period <= tbl1.leave_Days THEN 
					1 
				ELSE 
					0 
				end   
			ELSE	 
				tbl1.is_final_approval 
			END AS is_final_approval,
			(
				Case when isnull(tbl1.App_Emp_ID,0) =  0 then 
					(
						case when isnull(tbl1.Is_RM,0) = 1  then 
							lad.S_Emp_ID 
						when isnull(tbl1.Is_RMToRM,0) = 1 THEN	@R_Emp_Id2  --Added By Jimit 18012018
						else 
							tbl1.App_Emp_ID 
						end 
					 ) 
				 else 
					tbl1.App_Emp_ID 
				end
			  ) as s_emp_id_Scheme_current
			
			FROM V0110_PrecompOff_Application LAD
			CROSS JOIN
			(
				SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > 1 THEN 0 ELSE 1 end) as is_final_approval
				,Is_Fwd_Leave_Rej, sd.Is_RM , sd.Is_BM , Leave_Days
				,SD.Is_RMToRM
				FROM T0050_Scheme_Detail SD WITH (NOLOCK) 
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail WITH (NOLOCK)  
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Pre-CompOff')
								And Type = 'Pre-CompOff'
							)
							
						GROUP BY Scheme_Id
						
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Pre-CompOff')
					And Type = 'Pre-CompOff'
				)
				 and SD.Rpt_Level = 1
			) as tbl1
			
			WHERE PreCompOff_App_ID = @PreCompOff_App_ID
			
		
		end
	

END

