




-- =============================================
-- Author:		<Gadriwala >
-- ALTER date: <02012015>
-- Description:	<Gate Pass Setting for Branch Wise>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0010_Gate_Pass_Settings]
@Tran_ID numeric(18,0) output,
@Cmp_ID numeric(18,0),
@Branch_ID numeric(18,0),
@Upto_days numeric(18,2),
@Upto_Hours varchar(25),
@Deduct_days numeric(18,2),
@Above_Hours varchar(25),
@Deduct_Above_days numeric(18,2)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
 If not exists (select 1 from T0010_Gate_Pass_Settings WITH (NOLOCK) where cmp_id = @Cmp_ID and Branch_id = @Branch_ID)
	begin
			select  @Tran_ID = isnull(max(tran_Id),0) + 1 from  T0010_Gate_Pass_Settings WITH (NOLOCK)
			Insert into T0010_Gate_Pass_Settings(Tran_id,cmp_id,Branch_id,Upto_days,Upto_Hours,Deduct_days,Above_Hours,Deduct_Above_days)
				values(@Tran_ID,@Cmp_ID,@Branch_ID,@Upto_days,@Upto_Hours,@Deduct_days,@Above_Hours,@Deduct_Above_days)
				
	end
 else
	begin
			
			Update T0010_Gate_Pass_Settings set 
				Upto_days = @Upto_days,
				Upto_Hours = @Upto_Hours,
				Deduct_days = @Deduct_days,
				Above_Hours = @Above_Hours,
				Deduct_Above_days = @Deduct_Above_days
				where cmp_id = @Cmp_ID and Branch_id = @Branch_ID
				
	end
    
END


