

-- =============================================
-- Author:		Nimesh Parmar
-- ALTER date: 09-Feb-2016
-- Description:	To get count of processed salary
-- =============================================
CREATE FUNCTION [DBO].[fn_Get_Sal_Proc_Count]
(
	@BatchNo Varchar(128),
	@Mode Varchar(32)
)
RETURNS INT
AS
BEGIN	
	DECLARE @RETURN INT;
	
	IF (@Mode = 'Monthly')
		BEGIN
			SELECT	@RETURN = Count(Tran_id) 
			FROM	t0200_Pre_Salary_Data_monthly S  WITH(NOLOCK)					
			WHERE	is_processed=1 AND Batch_id LIKE '%-' + @BatchNo
		END
	ELSE
		BEGIN
			SELECT	@RETURN = Count(Tran_id) 
			FROM	t0200_Pre_Salary_Data S  WITH(NOLOCK)					
			WHERE	is_processed=1 AND Batch_id LIKE '%-' + @BatchNo
			
		END
    
	
	RETURN @RETURN 

END

