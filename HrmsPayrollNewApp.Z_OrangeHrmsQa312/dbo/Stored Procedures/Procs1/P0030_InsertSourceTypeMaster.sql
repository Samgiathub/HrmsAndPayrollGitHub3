

-- =============================================
-- Author:		<Author,,Rohit Patel>
-- Create date: <Create Date,,10032014>
-- Description:	<Description,,Insert Source type in T0030_Source_TYPE_MASTER>
-- =============================================
CREATE PROCEDURE [dbo].[P0030_InsertSourceTypeMaster] 
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


BEGIN

		Declare @Source_Type_Master Table(Source_Type_Name varchar(MAX))

		INSERT INTO @Source_Type_Master([Source_Type_Name]) VALUES (N'Advertising')
		INSERT INTO @Source_Type_Master([Source_Type_Name]) VALUES (N'Employee Referral')
		INSERT INTO @Source_Type_Master([Source_Type_Name]) VALUES (N'Direct Referral')
		INSERT INTO @Source_Type_Master([Source_Type_Name]) VALUES (N'Consultant')
		INSERT INTO @Source_Type_Master([Source_Type_Name]) VALUES (N'Job Fairs')
		INSERT INTO @Source_Type_Master([Source_Type_Name]) VALUES (N'State Unemployment Department')
		INSERT INTO @Source_Type_Master([Source_Type_Name]) VALUES (N'Networking')
		INSERT INTO @Source_Type_Master([Source_Type_Name]) VALUES (N'Job Portals')
		INSERT INTO @Source_Type_Master([Source_Type_Name]) VALUES (N'Others')
		
		--Select * from @Source_Type_Master

		DECLARE @Source_Type_Name varchar(max)
				

		DECLARE L_Master CURSOR FOR SELECT Source_Type_Name FROM @Source_Type_Master
		OPEN L_Master
		FETCH NEXT FROM L_Master INTO @Source_Type_Name
		WHILE @@FETCH_STATUS = 0
		BEGIN

			DECLARE @CNT as int
			SET @CNT = 0	
			SET @CNT = (Select COUNT(*) from T0030_Source_Type_Master WITH (NOLOCK) WHERE UPPER(Source_Type_Name) = UPPER(@Source_Type_Name))
			IF @CNT = 0
			BEGIN
				INSERT INTO T0030_Source_Type_Master (Source_Type_Name) VALUES (@Source_Type_Name)
			END
		   FETCH NEXT FROM L_Master INTO @Source_Type_Name
		END

		CLOSE L_Master
		DEALLOCATE L_Master
END

