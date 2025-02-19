--SELECT * from T0040_MOBILE_STORE_MASTER_New    
-- =============================================    
-- Author: satish viramgami    
-- Create date: 02/09/2020    
-- Description: Add Mobile brand and Sub-models master in vivo WB     
-- Table T0040_MOBILE_CATEGORY    
-- =============================================    
CREATE  PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Mobile_Store]    
  @Mobile_Store_ID numeric(18,0),    
  @Cmp_ID numeric(18,0),    
  @CurrOutMapping varchar(100),    
  @StoreCode varchar(50),    
  @DealerCode varchar(50),    
  @KROType varchar(50),    
  @RDSName varchar(50),    
  @ASMName varchar(50),    
  @ZSMName varchar(50),    
  @Login_ID numeric(18,0),    
  @IsActive numeric,    
  @Tran_Type CHAR(1),    
  @Result VARCHAR(100) OUTPUT    
AS    
BEGIN    
    set @CurrOutMapping = dbo.fnc_ReverseHTMLTags(@CurrOutMapping)  --added by Ronak 081021    
	 set @StoreCode = dbo.fnc_ReverseHTMLTags(@StoreCode)  --added by Ronak 081021    
	  set @DealerCode = dbo.fnc_ReverseHTMLTags(@DealerCode)  --added by Ronak 081021    
	   set @KROType = dbo.fnc_ReverseHTMLTags(@KROType)  --added by Ronak 081021    
	   set @RDSName = dbo.fnc_ReverseHTMLTags(@RDSName)  --added by Ronak 081021    
	    set @ASMName = dbo.fnc_ReverseHTMLTags(@ASMName)  --added by Ronak 081021  
		 set @ZSMName = dbo.fnc_ReverseHTMLTags(@ZSMName)  --added by Ronak 081021  
  IF @Tran_Type='I'    
  BEGIN    
   IF Exists (SELECT 1 FROM T0040_MOBILE_STORE_MASTER_New WHERE Cmp_Id = @Cmp_ID AND Current_Outlet_Mapping = @CurrOutMapping     
      AND Store_Code = @StoreCode AND Dealer_Code = @DealerCode AND KRO_Type = @KROType    
        AND RDS_Name = @RDSName AND ASM_Name = @ASMName AND ZSM_Name = @ZSMName)    
   BEGIN    
    SET @Result = ''    
   END    
   ELSE    
   BEGIN    
            
    INSERT INTO T0040_MOBILE_STORE_MASTER_New (Cmp_ID,Current_Outlet_Mapping,Store_Code,Dealer_Code,KRO_Type,RDS_Name,ASM_Name    
    ,ZSM_Name,Is_Active,System_Date,Login_ID)    
    VALUES (@Cmp_ID,@CurrOutMapping,@StoreCode,@DealerCode,@KROType,@RDSName,@ASMName,@ZSMName,@IsActive,GETDATE(),@Login_ID)    
        
    SET @Result = 'Record Insert Sucessfully#True'    
   END    
  END    
  ELSE IF @Tran_Type='U'    
  BEGIN    
   IF EXISTS(SELECT 1 FROM T0040_MOBILE_STORE_MASTER_New WITH(NOLOCK) WHERE Store_ID =@Mobile_Store_ID)     
   BEGIN    
       
     IF Exists (SELECT 1 FROM T0040_MOBILE_STORE_MASTER_New WHERE Cmp_Id = @Cmp_ID     
        AND Current_Outlet_Mapping = @CurrOutMapping AND Store_Code = @StoreCode AND Dealer_Code = @DealerCode AND KRO_Type = @KROType    
        AND RDS_Name = @RDSName AND ASM_Name = @ASMName AND ZSM_Name = @ZSMName AND Store_ID <> @Mobile_Store_ID)    
     BEGIN    
      SET @Result = ''    
     END    
     ELSE    
     BEGIN    
    
       UPDATE T0040_MOBILE_STORE_MASTER_New    
       SET Current_Outlet_Mapping = @CurrOutMapping,    
        Store_Code = @StoreCode,    
        Dealer_Code = @DealerCode,    
        KRO_Type = @KROType    
        ,RDS_Name = @RDSName    
        ,ASM_Name = @ASMName    
        ,ZSM_Name = @ZSMName    
        ,Cmp_ID=@Cmp_ID    
        ,Is_Active = @IsActive    
       WHERE Store_ID = @Mobile_Store_ID    
           
       SET @Result = 'Record Updated Sucessfully#True'    
     END    
   END    
   ELSE    
   BEGIN    
     SET @Result = 'Record Not Found#False'    
   END    
 END    
 ELSE IF @Tran_Type='D'    
 BEGIN    
   DELETE FROM T0040_MOBILE_STORE_MASTER_New where Store_ID = @Mobile_Store_ID    
  SET @Result = 'Record Delete Sucessfully#True'    
 END    
END    
    