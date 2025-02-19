



CREATE PROCEDURE [dbo].[P0040_CompanyWise_Branch_Table_BK300125]     
    @Tran_Id         NUMERIC(18,0)=null,    
    @Bank_Id         NUMERIC(18,2),    
    @CMP_ID          NUMERIC(18,0),  
    @Account_No      VARCHAR(MAX), 
    @Branch_Id       VARCHAR(MAX),
    @Effective_Date  DATETIME,  
    @System_Date     DATETIME,  
    @Tran_Type       VARCHAR(1)    
AS    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    

BEGIN    
    -- Handle empty @Branch_Id
    IF (@Branch_Id = '')  
        SET @Branch_Id = NULL;  

    -- Insertion Case
    IF UPPER(@Tran_Type) = 'I'    
    BEGIN   
        -- Check for existing entry
  --      IF EXISTS (SELECT TRAN_ID FROM T0040_CompanyWise_Branch_Table WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND Bank_ID = @Bank_Id)       
  --      BEGIN   
		--print 'in if 1'
  --          SET @Tran_Id = 0      
  --          RETURN       
  --      END   

        -- Split Branch_Id and Account_No
       ; WITH BranchSplit AS (
            SELECT Value AS Branch_Id, RowNum FROM dbo.SplitString1(@Branch_Id, ',')
        ),
        AccountSplit AS (
            SELECT Value AS Account_No, RowNum FROM dbo.SplitString1(@Account_No, ',')
        )       
        --INSERT INTO T0040_CompanyWise_Branch_Table (Bank_Id, CMP_Id, Account_No, Branch_Id, Effective_Date, System_Date)    
        --SELECT DISTINCT  @Bank_Id, @CMP_ID, a.Account_No, b.Branch_Id, @Effective_Date, @System_Date
        --FROM BranchSplit b
        --JOIN AccountSplit a ON b.RowNum = a.RowNum;
		INSERT INTO T0040_CompanyWise_Branch_Table (Bank_Id, CMP_Id, Account_No, Branch_Id, Effective_Date, System_Date)
			SELECT DISTINCT @Bank_Id, @CMP_ID, a.Account_No, b.Branch_Id, @Effective_Date, @System_Date
			FROM BranchSplit b
			JOIN AccountSplit a ON b.RowNum = a.RowNum
			WHERE NOT EXISTS (
				SELECT 1
				FROM T0040_CompanyWise_Branch_Table t
				WHERE t.Bank_Id = @Bank_Id 
				AND t.CMP_Id = @CMP_ID
				AND t.Account_No = a.Account_No
				AND t.Branch_Id = b.Branch_Id
			);
       
    END    

    -- Update Case
    --ELSE IF UPPER(@Tran_Type) = 'U'     
    --BEGIN    
    --    UPDATE T0040_CompanyWise_Branch_Table    
    --    SET Branch_Id = @Branch_Id,    
    --        Account_No = @Account_No  
    --    WHERE Tran_Id = @Tran_Id AND Effective_Date = @Effective_Date AND CMP_Id = @CMP_Id AND Bank_Id = @Bank_Id;   
    --END    
	-- For Update Operation (Transaction Type 'U')
ELSE IF UPPER(@Tran_Type) = 'U'    
BEGIN    
    -- Split Branch_Id and Account_No if they're comma-separated
    ;WITH BranchSplit AS (
        SELECT Value AS Branch_Id, RowNum 
        FROM dbo.SplitString1(@Branch_Id, ',')
    ),
    AccountSplit AS (
        SELECT Value AS Account_No, RowNum 
        FROM dbo.SplitString1(@Account_No, ',')
    )
    -- Update each corresponding pair of Branch_Id and Account_No
    UPDATE T0040_CompanyWise_Branch_Table    
    SET 
        Branch_Id = b.Branch_Id,    
        Account_No = a.Account_No
    FROM T0040_CompanyWise_Branch_Table t
    JOIN BranchSplit b ON t.Tran_Id = @Tran_Id AND t.CMP_Id = @CMP_Id AND t.Bank_Id = @Bank_Id AND t.Effective_Date = @Effective_Date
    JOIN AccountSplit a ON b.RowNum = a.RowNum
    WHERE t.Tran_Id = @Tran_Id 
        AND t.Effective_Date = @Effective_Date 
        AND t.CMP_Id = @CMP_Id 
        AND t.Bank_Id = @Bank_Id;
END

    -- Delete Case
    ELSE IF UPPER(@Tran_Type) = 'D'    
    BEGIN     
        DELETE FROM T0040_CompanyWise_Branch_Table WHERE Tran_Id = @Tran_Id AND CMP_ID = @CMP_ID;    
    END    

    RETURN    
END    

