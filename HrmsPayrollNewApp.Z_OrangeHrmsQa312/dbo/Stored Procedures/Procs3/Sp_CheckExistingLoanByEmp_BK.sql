CREATE  PROCEDURE [dbo].[Sp_CheckExistingLoanByEmp_BK]
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
			IF not EXISTS (select top 1 * from V0120_LOAN_APPROVAL  where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and Loan_Apr_Pending_Amount<> 0.00)
			BEGIN
				print 'part I1'
				SET @IsExists = 0;
			END
			ELSE
			BEGIN 
			    IF EXISTS(select top 1 * from V0100_LOAN_APPLICATION where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and Loan_status = 'R')
				 BEGIN
				 print 'part 0'
				 SET @IsExists = 0;
			    END
				
				else
				begin
				print 'part I2'
				SET @IsExists = 1;
				end
			END
		end
		
		ELSE IF not EXISTS(select top 1 * from V0100_LOAN_APPLICATION where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID)
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
