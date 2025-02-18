﻿

-- =============================================
-- Author:		<Jaina>
-- Create date: <05-07-2016>
-- Description:	<Exit Clearance Status>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0350_Exit_Clearance_Status]
	@Cmp_ID Numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF NOT EXISTS(SELECT 1 FROM T0350_EXIT_CLEARANCE_STATUS WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND STATUS = 'Pending')
	BEGIN
		INSERT INTO T0350_EXIT_CLEARANCE_STATUS (CMP_ID,STATUS) VALUES (@CMP_ID,'Pending')
    END
    
    IF NOT EXISTS(SELECT 1 FROM T0350_EXIT_CLEARANCE_STATUS WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND STATUS = 'Hold')
    BEGIN
    INSERT INTO T0350_EXIT_CLEARANCE_STATUS (CMP_ID,STATUS) VALUES (@CMP_ID,'Hold')
    END
    
    IF NOT EXISTS(SELECT 1 FROM T0350_EXIT_CLEARANCE_STATUS WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND STATUS = 'Accepted')
    BEGIN
    INSERT INTO T0350_EXIT_CLEARANCE_STATUS (CMP_ID,STATUS) VALUES (@CMP_ID,'Accepted')
    END
    
    IF NOT EXISTS(SELECT 1 FROM T0350_EXIT_CLEARANCE_STATUS WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND STATUS = 'Received')
    BEGIN
    INSERT INTO T0350_EXIT_CLEARANCE_STATUS (CMP_ID,STATUS) VALUES (@CMP_ID,'Received')
    END
    
END

