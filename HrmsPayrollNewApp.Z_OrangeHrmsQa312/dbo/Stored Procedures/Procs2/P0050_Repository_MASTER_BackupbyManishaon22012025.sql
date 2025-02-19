

CREATE PROCEDURE [dbo].[P0050_Repository_MASTER_BackupbyManishaon22012025]      
    @Repository_ID NUMERIC(18,0) OUTPUT,
    @Repository_Name VARCHAR(200) NULL,
    @Cmp_ID NUMERIC(18,0),
    --@Branch_ID INT,
	@Branch_ID VARCHAR(MAX), -- Changed from INT to VARCHAR(MAX)
    @Compliance_ID INT,
    @Month VARCHAR(50),
    @Year VARCHAR(50),
    @Submission_Date DATETIME = NULL,
    @Remark VARCHAR(MAX) = NULL,
    @Attachment_path NVARCHAR(MAX) = NULL,
    @tran_type VARCHAR(1),
    @User_Id NUMERIC(18,0) = 0,
    @IP_Address VARCHAR(30) = ''
	--@Compliance_Year_Type tinyint,
	--@Compliance_Submition_Type Int
AS  
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
    SET ARITHABORT ON;

    DECLARE @OldValue AS VARCHAR(5000);
    DECLARE @OldRemark AS VARCHAR(MAX);
    DECLARE @OldAttachmentPath AS NVARCHAR(MAX);
    DECLARE @OldSubmissionDate AS VARCHAR(50);

    SET @OldValue = '';
    SET @OldRemark = '';
    SET @OldAttachmentPath = '';
    SET @OldSubmissionDate = '';

    IF @tran_type = 'I'  
    BEGIN
		 DECLARE @NewCompliance_Year_Type AS VARCHAR(5000);
		 DECLARE @NewCompliance_Submition_Type AS VARCHAR(MAX);

		 SELECT 
			@NewCompliance_Year_Type = Compliance_Year_Type,@NewCompliance_Submition_Type = Compliance_Submition_Type FROM T0050_COMPLIANCE_MASTER WHERE Cmp_ID = @Cmp_ID  And Compliance_ID=@Compliance_ID;

			IF not EXISTS (
				SELECT 1
				FROM T0050_Repository_Master r
				
				WHERE r.Cmp_ID = @Cmp_ID
				  AND r.Compliance_ID = @Compliance_ID
				  AND r.Branch_ID IN (@Branch_ID) 
				  AND r.Month = @Month
				  AND r.Year=@Year
			)
			BEGIN
				-- Insert logic
				INSERT INTO T0050_Repository_Master 
				(Repository_Name, Cmp_ID, Branch_ID, Compliance_ID, Month, Year, Submission_Date, Remark, Attachment_path)
				VALUES 
				(@Repository_Name, @Cmp_ID, @Branch_ID, @Compliance_ID, @Month, @Year, @Submission_Date, @Remark, @Attachment_path);

				SET @Repository_ID = SCOPE_IDENTITY();
			END
    END      
    ELSE IF @tran_type = 'U'  
    BEGIN
        -- Update logic
        SELECT 
            @OldRemark = ISNULL(Remark, ''),
            @OldAttachmentPath = ISNULL(Attachment_path, ''),
            @OldSubmissionDate = CAST(Submission_Date AS VARCHAR(50))
        FROM T0050_Repository_Master WITH (NOLOCK)
        WHERE Repository_ID = @Repository_ID;

        UPDATE T0050_Repository_Master
        SET 
            Repository_Name = @Repository_Name,
            Cmp_ID = @Cmp_ID,
            Branch_ID = @Branch_ID,
            Compliance_ID = @Compliance_ID,
            Month = @Month,
            Year = @Year,
            Submission_Date = @Submission_Date,
            Remark = @Remark,
            Attachment_path = @Attachment_path
        WHERE Repository_ID = @Repository_ID;

        SET @OldValue = 'Old Value' + '#'+ 'Remark :' + @OldRemark + '#' + 'Attachment :' + @OldAttachmentPath + '#' + 'Submission Date :' + @OldSubmissionDate + 
                        ' New Value' + '#'+ 'Month :' + ISNULL(@Month, '') + '#' + 'Year :' + ISNULL(@Year, '') + '#' + 'Submission Date :' + CAST(@Submission_Date AS VARCHAR(50));
    END      
    ELSE IF @tran_type = 'D'  
    BEGIN
        -- Delete logic
        SELECT 
            @OldRemark = ISNULL(Remark, ''),
            @OldAttachmentPath = ISNULL(Attachment_path, ''),
            @OldSubmissionDate = CAST(Submission_Date AS VARCHAR(50))
        FROM T0050_Repository_Master WITH (NOLOCK)
        WHERE Repository_ID = @Repository_ID;

        DELETE FROM T0050_Repository_Master WHERE Repository_ID = @Repository_ID;

        SET @OldValue = 'Old Value' + '#'+ 'Remark :' + @OldRemark + '#' + 'Attachment :' + @OldAttachmentPath + '#' + 'Submission Date :' + @OldSubmissionDate;
    END      

    -- Call to audit trail procedure
    EXEC P9999_Audit_Trail @Cmp_ID, @tran_type, 'Repository Master', @OldValue, @Repository_ID, @User_Id, @IP_Address;
    RETURN;
END
