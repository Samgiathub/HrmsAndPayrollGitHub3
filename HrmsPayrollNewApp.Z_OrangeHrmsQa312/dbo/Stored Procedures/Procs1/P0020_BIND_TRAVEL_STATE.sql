
-- =============================================
-- Author:		<Yogesh Patel>
-- Create date: <26052023,,>
-- Description:	<To bind State as per Travel Type selection>
-- =============================================
-- exec [dbo].[P0020_BIND_TRAVEL_STATE] 187,'Out of State',28201
CREATE PROCEDURE [dbo].[P0020_BIND_TRAVEL_STATE]
	-- Add the parameters for the stored procedure here
	 @Cmp_ID as numeric
	,@TravelTypeName as Varchar(50)
	,@Emp_ID as numeric
	--,@Branch_ID as numeric
	
AS
BEGIN
Declare @Branch_ID as numeric
Declare @State_ID as numeric
set @Branch_ID= ((select Branch_ID from T0095_INCREMENT IC where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID
and Increment_Effective_Date= (select max(Increment_Effective_Date) as Increment_Effective_Date from T0095_INCREMENT where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID ))
)
Set @State_ID=(Select State_ID from T0030_BRANCH_MASTER where Branch_ID=@Branch_ID and Cmp_ID=@Cmp_ID)


if @TravelTypeName in ('Local Tour','Within District','Within State')--,'Within Block')
begin

Select * from T0020_STATE_MASTER where Cmp_ID=@Cmp_ID and State_ID=@State_ID
end
else 
begin

Select * from T0020_STATE_MASTER where Cmp_ID=@Cmp_ID and State_ID !=@State_ID
end



END
