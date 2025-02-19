


  
Create PROCEDURE [dbo].[P0040_CompanyWise_Branch_Table_W]     
      @Tran_Id   NUMERIC(18,0) OUTPUT,    
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
   
 if(@Branch_Id='')  
 set @Branch_Id=Null;  
   
    
 create table #tempBranch    
 (  
 branch_ID numeric(18,0)  
 ) 
 If Upper(@Tran_Type) = 'I'    
   BEGIN    
   --- begin    
    SET IDENTITY_INSERT T0040_CompanyWise_Branch_Table ON;
    if exists (Select TRAN_ID  from T0040_CompanyWise_Branch_Table WITH (NOLOCK) Where CMP_ID  = @CMP_ID and Bank_ID = @Bank_Id)       
     begin      
      set @Tran_Id = 0      
      Return       
     end      
	  ---declare @branchID as numeric(18,0)    
    
  
   SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0040_CompanyWise_Branch_Table WITH (NOLOCK)     
    SET IDENTITY_INSERT T0040_CompanyWise_Branch_Table ON;
    INSERT INTO T0040_CompanyWise_Branch_Table    
               (Tran_Id,Bank_Id,CMP_Id,Account_No ,Branch_Id,Effective_Date,System_Date)    
    VALUES     (@Tran_Id,@Bank_Id,@CMP_ID ,@Account_No ,@Branch_Id,@Effective_Date,@System_Date)     

	 --declare BranchUpdate Cursor for  
  --  select @branchID from #tempBranch  
      
  --  Open BranchUpdate  
  --   Fetch next from BranchUpdate into @branchID  
	 --select @branchID
  --   While @@FETCH_STATUS=0  
  --    Begin  
  --     if Not Exists(select 1 from T0040_CompanyWise_Branch_Table WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Bank_ID = @Bank_Id and Branch_Id=@branchID)  
  --      Begin  
  --       insert into T0040_CompanyWise_Branch_Table  (TRAN_ID,Bank_Id,CMP_Id,Account_No ,branch_ID,Effective_Date,System_Date)      
  --         values (@Tran_ID,@Bank_Id,@CMP_ID ,@Account_No ,@branchID,@Effective_Date,@System_Date) 
  --      End   
  --     Fetch next from BranchUpdate into @branchID  
  --    End  
  --  Close BranchUpdate  
  --  Deallocate BranchUpdate
        
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
        
        
  
        
    SELECT @Tran_Id = ISNULL(MAX(Tran_Id),0) + 1 FROM T0040_CompanyWise_Branch_Table WITH (NOLOCK)    
        
        
    UPDATE    T0040_CompanyWise_Branch_Table    
    SET       Branch_Id = @Branch_Id,    
    Account_No=@Account_No  
    --Flag_Grd_Desig=@Flag_GrdDesig,    
    --City_Cat_Flag=@Flag_CityCat    
    ----Amount=@Amount    
    WHERE     Tran_Id = @Tran_Id And Effective_Date = @Effective_Date And CMP_Id = @CMP_Id and Bank_Id=@Bank_Id    
  
   END    
 Else If  Upper(@tran_type) ='D'    
   BEGIN     
    DELETE FROM T0040_CompanyWise_Branch_Table WHERE  Tran_Id = @Tran_Id AND CMP_ID = @CMP_ID    
   END    
       
 RETURN    
END    
    
     
