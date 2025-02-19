-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 06/09/2023
-- Description:	Insert Live Tracking Data
-- =============================================
CREATE PROCEDURE [dbo].[P0060_Live_Tracking]
	@LT_Id numeric(18, 0) Output,
	@Cmp_Id numeric(18, 0) ,
	@Emp_Id numeric(18, 0) ,
	@Origin_Location nvarchar(max) ,
	@Destination_Location nvarchar(max) ,
	@Distance_Km numeric(16, 2) ,
	@tran_type	varchar(1)		
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

If Upper(@tran_type) ='I'
		Begin
			--IF EXISTS(SELECT 1 FROM T0100_Employee_Template_Response WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND T_Id = @T_Id AND F_Id = @F_Id)
			--	BEGIN
			--		RETURN 0
			--	END

			select @LT_Id = isnull(max(LT_Id),0) + 1 from T0060_Live_Tracking WITH (NOLOCK)
			
			Insert Into T0060_Live_Tracking
			(
				   LT_Id  ,
					Cmp_Id  ,
					Emp_Id  ,
					Origin_Location  ,
					Destination_Location  ,
					Distance_Km  ,
					Created_Date
			)
			Values
			(
				  @LT_Id  ,
					@Cmp_Id  ,
					@Emp_Id  ,
					@Origin_Location  ,
					@Destination_Location  ,
					@Distance_Km  , 
				  GETDATE()
				  
			)

		End
	--Else If  Upper(@tran_type) ='U' 
	--	Begin
			
	--		UPDATE    T0100_Employee_Template_Response
	--		SET       Answer = @Answer,Created_Date=GETDATE()			  				
	--		WHERE ETR_Id = @ETR_Id and cmp_Id=@Cmp_ID

	--	End
	--Else If  Upper(@tran_type) ='D'
	--	Begin
	--		Delete from  T0100_Employee_Template_Response  where ETR_Id = @ETR_Id
	--	End
END
