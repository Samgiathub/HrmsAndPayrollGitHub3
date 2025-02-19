


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---12/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0055_Training_Faculty]
	   @Training_FacultyId				NUMERIC(18,0)	
      ,@Cmp_Id							NUMERIC(18,0)
      ,@Training_InstituteId			NUMERIC(18,0)
      ,@Faculty_Name					VARCHAR(100)
      ,@Faculty_Contact					VARCHAR(50)
      ,@Active							bit = 1
      ,@Training_Institute_LocId		NUMERIC(18,0)   = Null
      ,@Training_Id						NUMERIC(18,0)	= Null
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	if @Training_Institute_LocId = 0
		set @Training_Institute_LocId = NULL
	
		
	IF @Training_FacultyId = 0
		BEGIN
			SELECT @Training_FacultyId = ISNULL(MAX(Training_FacultyId),0) + 1 FROM T0055_Training_Faculty WITH (NOLOCK)
			INSERT INTO T0055_Training_Faculty
			(
			   Training_FacultyId
			  ,Cmp_Id
			  ,Training_InstituteId
			  ,Faculty_Name
			  ,Faculty_Contact
			  ,Active
			  ,Training_Institute_LocId
			  ,Training_Id
			)
			VALUES
			(
				@Training_FacultyId
			   ,@Cmp_Id
			   ,@Training_InstituteId
			   ,@Faculty_Name
			   ,@Faculty_Contact
			   ,@Active
			   ,@Training_Institute_LocId
			   ,@Training_Id
			)
		END
	ELSE
		BEGIN
			UPDATE T0055_Training_Faculty
			SET  Faculty_Name		=   @Faculty_Name
			    ,Faculty_Contact	=	@Faculty_Contact
			    ,Active				=	@Active
			    ,Training_Institute_LocId	=	@Training_Institute_LocId
			    ,Training_Id		=	@Training_Id
			WHERE Training_FacultyId =  @Training_FacultyId
		END
END

