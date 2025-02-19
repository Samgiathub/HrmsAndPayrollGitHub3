
CREATE PROCEDURE [dbo].[P0100_Emp_Manager_History]
 @row_id	numeric(18, 0)	output
,@Cmp_id	numeric(18, 0)	
,@Emp_id	numeric(18, 0)	
,@Increment_id	numeric(18, 0)	
,@emp_superior	numeric(18, 0)	
,@For_date	datetime	

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON  

declare @For_date1 as datetime
set @For_date1= cast(getdate() as varchar(11))

		if exists(select row_id from t0100_Emp_Manager_History WITH (NOLOCK) where cmp_id=@cmp_id and emp_id=@emp_id and Increment_id=@Increment_id)
			Begin
				update t0100_Emp_Manager_History set emp_superior=@emp_superior,For_date=@For_date1 where cmp_id=@cmp_id and emp_id=@emp_id and Increment_id=@Increment_id
				return
			End
			
				select @row_id = isnull(max(row_id),0) + 1  from t0100_Emp_Manager_History WITH (NOLOCK)
								
				insert into t0100_Emp_Manager_History ( row_id
												,Cmp_id
												,Emp_id
												,Increment_id
												,emp_superior
												,For_date )
										Values( @row_id
												,@Cmp_id
												,@Emp_id
												,@Increment_id
												,@emp_superior
												,@For_date )
				
			
	
RETURN




