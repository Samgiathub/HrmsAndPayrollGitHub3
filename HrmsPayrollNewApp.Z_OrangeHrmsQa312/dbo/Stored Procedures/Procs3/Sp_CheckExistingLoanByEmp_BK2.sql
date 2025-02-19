












 --exec Sp_CheckExistingLoanByEmp 2,248,2



--CREATE PROCEDURE [dbo].[Sp_CheckExistingLoanByEmp]
-- @Cmp_ID Numeric  
-- ,@Emp_ID Numeric  
-- ,@Loan_ID Numeric 
-- ,@OperationType VARCHAR(10)  
--AS
--BEGIN
--    SET NOCOUNT ON;

--    DECLARE @ExisingLoanName AS VARCHAR(100);
--	 DECLARE @ExisingLoanName1 AS VARCHAR(100);
--	  DECLARE @NewLoanName1 AS VARCHAR(100);
--    DECLARE @NewLoanName AS VARCHAR(100);
--    DECLARE @IsExists AS BIT;

  
--    IF @OperationType = 'INSERT'
--    BEGIN
	      
           
--        -- Check if there is any existing loan for the employee
--        IF EXISTS (
--            SELECT TOP 1 1
--            FROM T0100_LOAN_APPLICATION la
--            INNER JOIN T0040_LOAN_MASTER lm ON lm.Loan_ID = la.Loan_ID
--            WHERE la.Cmp_ID = @Cmp_ID AND la.Emp_ID = @Emp_ID
--        )
--        BEGIN
--            -- Retrieve the existing loan name
--            SELECT TOP 1 @ExisingLoanName = Loan_Name
--            FROM T0100_LOAN_APPLICATION la
--            INNER JOIN T0040_LOAN_MASTER lm ON lm.Loan_ID = la.Loan_ID
--            WHERE la.Cmp_ID = @Cmp_ID AND la.Emp_ID = @Emp_ID AND Loan_status <> 'R' 
--            ORDER BY Loan_App_Date DESC;

--            -- Retrieve the new loan name
--            SELECT @NewLoanName = Loan_Name 
--            FROM T0040_LOAN_MASTER 
--            WHERE Cmp_ID = @Cmp_ID AND Loan_ID = @Loan_ID;


--            -- Check if there is an approval with Loan_Apr_Pending_Amount = 0
--			 IF EXISTS (
--                SELECT 1
--                FROM V0120_LOAN_APPROVAL
--                WHERE Loan_Apr_Pending_Amount = 0.00
--                AND Emp_ID = @Emp_ID
--                AND Cmp_ID = @Cmp_ID
--			   and Loan_ID= @Loan_ID
--			and Loan_Apr_Status  IN ('A', 'R')
--            )
--            BEGIN

--                -- Set @IsExists to 0 if pending amount is 0
--                SET @IsExists = 0;
--            END

--            ELSE
--            BEGIN

--                IF (@ExisingLoanName != @NewLoanName)
--                BEGIN
--                    SET @IsExists = 1; 
--                END
--                ELSE
--                BEGIN
--                    SET @IsExists = 0;  
--                END
--            END
--        END
--        ELSE
--        BEGIN

--            SET @IsExists = 0;
--        END
		
--		IF EXISTS (SELECT TOP 1 1 
--            FROM T0120_LOAN_APPROVAL la
--            INNER JOIN T0040_LOAN_MASTER lm ON lm.Loan_ID = la.Loan_ID
--            WHERE la.Cmp_ID = @Cmp_ID AND la.Emp_ID = @Emp_ID 
--			)
--		   BEGIN	 
--			 SELECT TOP 1 @ExisingLoanName1 = Loan_Name
--            FROM T0120_LOAN_APPROVAL la
--            INNER JOIN T0040_LOAN_MASTER lm ON lm.Loan_ID = la.Loan_ID
--            WHERE la.Cmp_ID = @Cmp_ID AND la.Emp_ID = @Emp_ID
			
--			SELECT @NewLoanName1 = Loan_Name 
--            FROM T0040_LOAN_MASTER 
--            WHERE Cmp_ID = @Cmp_ID AND Loan_ID = @Loan_ID;

--			-- Check if there is an approval with Loan_Apr_Pending_Amount = 0
--            IF EXISTS (
--                SELECT 1
--                FROM V0120_LOAN_APPROVAL
--                WHERE Loan_Apr_Pending_Amount = 0.00
--                AND Emp_ID = @Emp_ID
--                AND Cmp_ID = @Cmp_ID
--			    and Loan_ID= @Loan_ID
--				and Loan_Apr_Status  IN ('A', 'R')
--            )
--            BEGIN
--                -- Set @IsExists to 0 if pending amount is 0
--                SET @IsExists = 0;
--            END
			
--            ELSE

--			BEGIN
--                IF (@ExisingLoanName1 != @NewLoanName1)
--                BEGIN
--                    SET @IsExists = 1; 
--                END
--                ELSE
--                BEGIN
--                    SET @IsExists = 0;  
--                END
--            END
--			end
--        IF EXISTS(SELECT Emp_ID FROM V0120_LOAN_APPROVAL WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID  and Emp_ID =@Emp_ID and Loan_ID=@Loan_ID and loan_app_id IS NULL 
--		and Loan_Apr_Pending_Amount<>0.00)
--			    BEGIN

--                -- Set @IsExists to 0 if pending amount is 0
--                SET @IsExists = 1;
--                END
--        IF EXISTS (SELECT  top 1 LA.Emp_ID from T0100_LOAN_APPLICATION LA ,V0120_LOAN_APPROVAL VA where la.Emp_ID=@Emp_ID and la.Cmp_ID=@Cmp_ID 
--	       and la.Loan_ID=@Loan_ID
--		   and VA.Loan_Apr_Pending_Amount<> 0.00 )
--	       BEGIN

--          SET @IsExists = 1;
--          END
		
--    END
--    ELSE IF @OperationType = 'UPDATE'
--    BEGIN
       
--        SET @IsExists = 0;
--    END

--    -- Return the result
--    SELECT @IsExists AS IsExists;
--END
--GO
CREATE PROCEDURE [dbo].[Sp_CheckExistingLoanByEmp_BK2]
    @Cmp_ID Numeric,  
    @Emp_ID Numeric,  
    @Loan_ID Numeric, 
    @OperationType VARCHAR(10),
	@Ttype VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @IsExists AS BIT;
    SET @IsExists = 0;
    IF @OperationType = 'INSERT'
    BEGIN  
		If(@Ttype='APPROVAL')
		Begin
			-- Check if there is any loan approval for the given employee and company
			IF EXISTS (SELECT TOP 1 1 FROM V0120_LOAN_APPROVAL WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID)
			BEGIN        
				-- If no pending loan approval exists (Loan_Apr_Pending_Amount <> 0.00), set IsExists to 0
				IF EXISTS (SELECT TOP 1 1 FROM V0120_LOAN_APPROVAL WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Loan_Apr_status  <> 'R' ORDER BY Loan_App_Id DESC)
				BEGIN                
					IF EXISTS (SELECT TOP 1 1 FROM V0120_LOAN_APPROVAL WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Loan_Apr_Pending_Amount <> 0.00 ORDER BY Loan_App_Id DESC)
					BEGIN
						PRINT 'part I1'
						SET @IsExists = 1;
						Return;
					END
				END           
			END
			-- If no loan approval exists, check if a loan application exists
		END
		If(@Ttype='APPLICATION')
		Begin
			IF EXISTS (SELECT 1 FROM V0100_LOAN_APPLICATION WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID)
			BEGIN
				-- Check for the most recent loan application with Loan_status = 'R'
				IF EXISTS (SELECT TOP 1 1 FROM V0100_LOAN_APPLICATION WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Loan_status <> 'R' ORDER BY Loan_App_Id DESC)
				BEGIN
					PRINT 'part I2'
					SET @IsExists = 1;
					return;
				END				
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
