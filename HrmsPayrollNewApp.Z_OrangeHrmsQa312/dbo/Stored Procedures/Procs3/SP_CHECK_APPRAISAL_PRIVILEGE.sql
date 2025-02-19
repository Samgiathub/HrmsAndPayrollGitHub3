

CREATE PROCEDURE [dbo].[SP_CHECK_APPRAISAL_PRIVILEGE]
	@Cmp_ID    numeric
	,@Check		tinyint output
AS	
	    SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

	set @Check = 0
	
	if exists (	select	1 
				from	T0011_module_detail WITH (NOLOCK)
				where	module_name='HRMS' and module_status=1 and  Cmp_id = @Cmp_ID
			)
		BEGIN
			if exists	(
							select	1
							from	T0011_module_detail WITH (NOLOCK)
							where	Cmp_id = @Cmp_ID and module_name in ('Appraisal1','Appraisal2','Appraisal3') and  module_status=1 
						)
				BEGIN
					set @Check = 1
				end
		END
	ELSE
		BEGIN
			set @Check = 0
		END
