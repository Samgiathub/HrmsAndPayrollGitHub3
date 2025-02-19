CREATE PROCEDURE [dbo].[Sp_CheckExistingLoanByEmp]
    @Cmp_ID Numeric,  
    @Emp_ID Numeric,  
    @Loan_ID Numeric, 
    @OperationType VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @IsExists AS BIT;
    SET @IsExists = 0;
    IF @OperationType = 'INSERT'
	BEGIN  		
		-- Check if there is any loan approval for the given employee and company
		IF EXISTS (SELECT TOP 1 1 FROM V0120_LOAN_APPROVAL WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID)
		BEGIN
			print 'in if1'
			-- If no pending loan approval exists (Loan_Apr_Pending_Amount <> 0.00), set IsExists to 0
			IF EXISTS (SELECT TOP 1 1 FROM V0120_LOAN_APPROVAL WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Loan_Apr_status  <> 'R' ORDER BY Loan_App_Id DESC)
			BEGIN    
				print 'in if2'
				IF EXISTS (SELECT TOP 1 1 FROM V0120_LOAN_APPROVAL WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Loan_Apr_Pending_Amount <> 0.00 AND Loan_Apr_status  <> 'R' ORDER BY Loan_App_Id DESC)
				BEGIN
					PRINT 'part I1'
					SET @IsExists = 1;
					SELECT @IsExists AS IsExists;
					Return;
				END
				Else
				Begin
						IF EXISTS (SELECT TOP 1 1 FROM V0100_LOAN_APPLICATION WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Loan_status = 'N' ORDER BY Loan_App_Id DESC)
						BEGIN				
							PRINT 'part I2'
							SET @IsExists = 1;
							SELECT @IsExists AS IsExists;
							Return;
						END	
						else
						Begin
							PRINT 'part I3'
							SET @IsExists = 0;		
							SELECT @IsExists AS IsExists;
							Return;
						End
				END
			END           
		END		
		
		IF EXISTS (SELECT 1 FROM V0100_LOAN_APPLICATION WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID)
		BEGIN
			print 'in if3'
			-- Check for the most recent loan application with Loan_status = 'R'
			IF EXISTS (SELECT TOP 1 1 FROM V0100_LOAN_APPLICATION WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Loan_status <> 'R' ORDER BY Loan_App_Id DESC)
			BEGIN				
				PRINT 'part I4'
				SET @IsExists = 1;					
			END				
		END	 
	END
    ELSE IF @OperationType = 'UPDATE'
    BEGIN
        -- If operation is UPDATE, set @IsExists to 0 by default
        PRINT 'part U1'
        SET @IsExists = 0;
    END

    -- Return the result
    SELECT @IsExists AS IsExists;
END
