









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
Create  PROCEDURE [dbo].[Sp_CheckExistingLoanByEmp_BK0901]
 @Cmp_ID Numeric  
 ,@Emp_ID Numeric  
 ,@Loan_ID Numeric 
 ,@OperationType VARCHAR(10)  
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExisingLoanName AS VARCHAR(100);
	 DECLARE @ExisingLoanName1 AS VARCHAR(100);
	  DECLARE @NewLoanName1 AS VARCHAR(100);
    DECLARE @NewLoanName AS VARCHAR(100);
    DECLARE @IsExists AS BIT;

  
    IF @OperationType = 'INSERT'
    BEGIN	      
        IF EXISTS (select top 1 * from V0120_LOAN_APPROVAL  where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID)
        BEGIN        
			IF not EXISTS (select top 1 * from V0120_LOAN_APPROVAL  where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and Loan_Apr_Pending_Amount<> 0.00 and loan_apr_status <> 'R' )
			BEGIN
				print 'part I1'
				SET @IsExists = 0;
			END
			ELSE
			BEGIN
				print 'part I2'
				SET @IsExists = 1;
			END
		end
		ELSE IF not EXISTS(select top 1 * from V0100_LOAN_APPLICATION where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and Loan_status ='R')
		 BEGIN
		
            SET @IsExists = 0;
        END
        ELSE
        BEGIN
			print 'part I3'
            SET @IsExists = 1;
        END
END
ELSE IF @OperationType = 'UPDATE'
BEGIN
    print 'part U1'
    SET @IsExists = 0;
END

    -- Return the result
    SELECT @IsExists AS IsExists;
END
