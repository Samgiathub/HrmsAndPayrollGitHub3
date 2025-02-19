


CREATE PROCEDURE [dbo].[P9999_Auto_Escalate_Setting]
		 @Tran_id	numeric(18, 0)	
		,@Cmp_id	numeric(18, 0)	
		,@Is_Enable	tinyint	
		,@Escalate_After_days	numeric(18, 0)	
		,@Auto_Approve	numeric(18, 0)	
		,@is_sql_job_agent	tinyint	
		,@Is_Auto_reject	tinyint	 = 0

AS	

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


		if not exists (SELECT 1 FROM T9999_Auto_Escalate_Setting WITH (NOLOCK) where Cmp_id = @Cmp_id)
			begin
					INSERT INTO T9999_Auto_Escalate_Setting
							  (Cmp_id, Is_Enable, Escalate_After_days, Auto_Approve, is_sql_job_agent,is_auto_reject)
					VALUES     (@Cmp_id,@Is_Enable,@Escalate_After_days,@Auto_Approve,@is_sql_job_agent,@Is_Auto_reject)
			end
		else 
			begin				
					UPDATE    T9999_Auto_Escalate_Setting
					SET  Is_Enable = @Is_Enable, Escalate_After_days = @Escalate_After_days, Auto_Approve = @Auto_Approve, 
						  is_sql_job_agent = @is_sql_job_agent , Is_Auto_reject = @Is_Auto_reject
					WHERE Cmp_id = @Cmp_id					 
			end
		
	
	RETURN




