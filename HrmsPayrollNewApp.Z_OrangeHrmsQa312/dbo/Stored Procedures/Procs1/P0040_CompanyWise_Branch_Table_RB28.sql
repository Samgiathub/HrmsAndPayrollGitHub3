


  
CREATE PROCEDURE [dbo].[P0040_CompanyWise_Branch_Table_RB28]     
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
    
  
   SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0040_CompanyWise_Branch_Table WITH (NOLOCK)     
    SET IDENTITY_INSERT T0040_CompanyWise_Branch_Table ON;
    INSERT INTO T0040_CompanyWise_Branch_Table    
               (Tran_Id,Bank_Id,CMP_Id,Account_No ,Branch_Id,Effective_Date,System_Date)    
    VALUES     (@Tran_Id,@Bank_Id,@CMP_ID ,@Account_No ,@Branch_Id,@Effective_Date,@System_Date)     

     end  



 Else If  Upper(@tran_type) ='U'     
   BEGIN    

    SELECT @Tran_Id = ISNULL(MAX(Tran_Id),0) + 1 FROM T0040_CompanyWise_Branch_Table WITH (NOLOCK)    
        
        
    UPDATE    T0040_CompanyWise_Branch_Table    
    SET       Branch_Id = @Branch_Id,    
    Account_No=@Account_No  
  
    WHERE     Tran_Id = @Tran_Id And Effective_Date = @Effective_Date And CMP_Id = @CMP_Id and Bank_Id=@Bank_Id    
  
   END    
 Else If  Upper(@tran_type) ='D'    
   BEGIN     
    DELETE FROM T0040_CompanyWise_Branch_Table WHERE  Tran_Id = @Tran_Id AND CMP_ID = @CMP_ID    
   END    
       
 RETURN    
END    
    
     
