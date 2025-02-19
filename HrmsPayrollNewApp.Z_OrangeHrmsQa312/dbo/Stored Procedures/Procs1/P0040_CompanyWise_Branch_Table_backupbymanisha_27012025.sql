

  
Create PROCEDURE [dbo].[P0040_CompanyWise_Branch_Table_backupbymanisha_27012025]     
      @Tran_ID   NUMERIC(18,0) OUTPUT,    
     @Bank_Id  NUMERIC(18,2),    
  @CMP_ID NUMERIC(18,0),  
   @Account_No    VARCHAR(MAX), 
   --- @Branch_Id  NUMERIC(18,2),  
   @Branch_Id VARCHAR(MAX),
  @Effective_Date Datetime,  
  @System_Date Datetime,  
   @Tran_Type   VARCHAR(1)    
AS    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
BEGIN    
 If Upper(@Tran_Type) = 'I'    
   BEGIN    
   --- begin    
    SET IDENTITY_INSERT T0040_CompanyWise_Branch_Table ON;
    if exists (Select TRAN_ID  from T0040_CompanyWise_Branch_Table WITH (NOLOCK) Where CMP_ID  = @CMP_ID and Bank_ID = @Bank_Id)       
     begin      
      set @TRAN_ID = 0      
      Return       
     end      
	
   SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0040_CompanyWise_Branch_Table WITH (NOLOCK)     
    SET IDENTITY_INSERT T0040_CompanyWise_Branch_Table ON;
    INSERT INTO T0040_CompanyWise_Branch_Table    
               (TRAN_ID,Bank_Id,CMP_Id,Account_No ,Branch_Id,Effective_Date,System_Date)    
    VALUES     (@Tran_ID,@Bank_Id,@CMP_ID ,@Account_No ,@Branch_Id,@Effective_Date,@System_Date)     


        
     end  
--IF UPPER(@Tran_Type) = 'I'
--BEGIN
--    -- Check if a record with the same CMP_ID and Bank_ID already exists
--    IF EXISTS (SELECT TRAN_ID 
--               FROM T0040_CompanyWise_Branch_Table WITH (NOLOCK) 
--               WHERE CMP_ID = CAST(@CMP_ID AS INT) AND Bank_ID = CAST(@Bank_Id AS INT))
--    BEGIN
--        -- If a matching record exists, set TRAN_ID to 0 and return
--        SET @TRAN_ID = 0;
--        RETURN;
--    END

--    -- Enable IDENTITY_INSERT to allow manual insertion into the identity column TRAN_ID
--    SET IDENTITY_INSERT T0040_CompanyWise_Branch_Table ON;

--    -- Get the next available TRAN_ID by finding the maximum TRAN_ID and adding 1
--    SELECT @TRAN_ID = ISNULL(MAX(CAST(TRAN_ID AS INT)), 0) + 1 
--    FROM T0040_CompanyWise_Branch_Table WITH (NOLOCK);

--    -- Insert the new record including an explicit value for TRAN_ID
--    INSERT INTO T0040_CompanyWise_Branch_Table
--               (TRAN_ID, Bank_Id, CMP_Id, Account_No, Branch_Id, Effective_Date, System_Date)
--    VALUES (@TRAN_ID, CAST(@Bank_Id AS INT), CAST(@CMP_ID AS INT), @Account_No, @Branch_Id, @Effective_Date, @System_Date);

--    -- Disable IDENTITY_INSERT to restore the default behavior (auto-generation of TRAN_ID)
--    SET IDENTITY_INSERT T0040_CompanyWise_Branch_Table OFF;
--END



 Else If  Upper(@tran_type) ='U'     
   BEGIN    
        
        
  
        
    SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0040_CompanyWise_Branch_Table WITH (NOLOCK)    
        
        
    UPDATE    T0040_CompanyWise_Branch_Table    
    SET       Branch_Id = @Branch_Id,    
    Account_No=@Account_No  
    --Flag_Grd_Desig=@Flag_GrdDesig,    
    --City_Cat_Flag=@Flag_CityCat    
    ----Amount=@Amount    
    WHERE     Tran_ID = @Tran_ID And Effective_Date = @Effective_Date And CMP_Id = @CMP_Id and Bank_Id=@Bank_Id    
    --and Effective_Date=@EffectDate    
        
    --INSERT INTO T0050_EXPENSE_TYPE_MAX_LIMIT    
    --           (TRAN_ID,CMP_ID,Expense_Type_ID,Grd_Id,Amount,Flag_Grd_Desig,City_Cat_ID,City_Cat_Amount,Desig_ID,Effective_Date,City_Cat_Flag)    
    --VALUES     (@Tran_ID,@Cmp_ID,@Expense_Type_ID,@Grd_Id,@Amount,@Flag_GrdDesig,@CityCatID,@CityCatAmnt,@DesigID,@EffectDate,@Flag_CityCat)     
        
    --IF EXISTS (SELECT TRAN_ID FROM T0050_EXPENSE_TYPE_MAX_LIMIT WHERE Grd_ID = @Grd_Id AND EXPENSE_TYPE_ID <> @EXPENSE_TYPE_ID )     
    -- BEGIN    
    --  SET @Tran_ID = 0    
    --  RETURN    
    -- END    
        
    --UPDATE    T0050_EXPENSE_TYPE_MAX_LIMIT    
    --SET       Amount = @Amount    
    --WHERE     Tran_ID = @Tran_ID And Expense_Type_ID = @Expense_Type_ID And Cmp_ID = @Cmp_ID    
   END    
 Else If  Upper(@tran_type) ='D'    
   BEGIN     
    DELETE FROM T0040_CompanyWise_Branch_Table WHERE  TRAN_ID = @Tran_ID AND CMP_ID = @CMP_ID    
   END    
       
 RETURN    
END    
    
     
