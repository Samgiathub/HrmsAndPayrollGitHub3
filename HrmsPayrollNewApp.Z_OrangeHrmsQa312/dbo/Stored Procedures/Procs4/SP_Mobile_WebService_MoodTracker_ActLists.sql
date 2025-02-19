---10/3/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_WebService_MoodTracker_ActLists]
	
AS	
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


		SELECT Mood_Activity_Id,Activity,Selected_ImageName,Unselected_ImageName
		FROM T0040_Mood_Activity_Master WITH (NOLOCK)
END


