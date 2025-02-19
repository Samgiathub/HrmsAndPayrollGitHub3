-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[P0080_TRAVEL_TRACKINGPROOF_INSERT]
	-- Add the parameters for the stored procedure here
	 @Cmp_ID as numeric
	,@Emp_ID as numeric
	,@ImageName as Varchar(50)
	,@ImagePath as Varchar(Max)
	,@TravelProofType as numeric
	,@TravelAppCode as numeric
	,@EffectiveDate as datetime
AS
BEGIN
set @EffectiveDate=GETDATE()
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @ProoftypeCount int,@TravelApp_Code int
	set @prooftypecount=(select travel_proof_type from T0080_Emp_Travel_Proof where travel_proof_type=@TravelProofType and Emp_ID=@Emp_ID and TravelApp_Code=@TravelApp_Code)
--	set @TravelApp_Code=(Select * from T0100_TRAVEL_APPLICATION where 



	IF ( @TravelProofType<>0 )
	begin
	insert into T0080_Emp_Travel_Proof (Emp_ID,Cmp_ID,Image_Name,Image_Path,Travel_Proof_Type,TravelApp_Code,Effective_Date)
	Values
	(
	@Emp_ID
	,@Cmp_ID
	,@ImageName
	,@ImagePath
	,@TravelProofType
	,@TravelAppCode
	,@EffectiveDate
	)
	
	end
	
	--else
	--begin


	--end

   --select * from T0080_Emp_Travel_Tracking
END
