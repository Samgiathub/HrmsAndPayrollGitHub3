-- =============================================
-- Author:		Niraj Parmar
-- Create date: 16-12-2021
-- Description:	To Add Ticekt Approval Feedback
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Ticket_Feedback]
    @Ticket_App_ID Numeric(18,0) Output,
    @Cmp_ID Numeric(18,0),
    @Emp_ID Numeric(18,0),
    @Login_ID Numeric(18,0),
	@Rating Numeric(18,0),
	@Suggestion varchar(max),
    @Trantype char(1),
	@Result VARCHAR(100) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Feedback_Date datetime
	SET @Feedback_Date = GETDATE()

    -- Update statements for procedure here
	if @Trantype = 'F' -- To Add Feedback
	Begin
		BEGIN TRY
			--Select * from T0090_Ticket_Application Where Ticket_App_ID = @Ticket_App_ID and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
			IF EXISTS(SELECT 1 FROM T0100_Ticket_Approval WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Ticket_App_ID = @Ticket_App_ID and Cmp_ID = @Cmp_ID and Feedback_Rating = 0)
			Begin
				UPDATE T0100_Ticket_Approval
					SET Feedback_Rating = @Rating, Feedback_Date = @Feedback_Date
					WHERE Emp_ID = @Emp_ID AND Ticket_App_ID = @Ticket_App_ID and Cmp_ID = @Cmp_ID
				--THROW 51000, 'The record does not exist.', 1;
				SET @Result = 'Ticket Feedback Added Successfully#True#'
				SELECT @Result As Result
			End
			Else IF EXISTS(SELECT 1 FROM T0100_Ticket_Approval WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Ticket_App_ID = @Ticket_App_ID and Cmp_ID = @Cmp_ID and Feedback_Rating > 0)
			Begin
				UPDATE T0100_Ticket_Approval
					SET Feedback_Suggestion = @Suggestion
					WHERE Emp_ID = @Emp_ID AND Ticket_App_ID = @Ticket_App_ID and Cmp_ID = @Cmp_ID
				--THROW 51000, 'The record does not exist.', 1;
				SET @Result = 'Ticket Feedback Suggestion Added Successfully#True#'
				SELECT @Result As Result
			End
			Else
				Begin
					SET @Result = 'Ticket Feedback Allready Added#False#'
					SELECT @Result As Result
				End
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+'#False#'
			SELECT @Result As Result
		END CATCH
	End
END
