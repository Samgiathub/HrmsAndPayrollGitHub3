  
  
-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE PROCEDURE [dbo].[P0050_Training_Institute_Master]  
    @Training_InstituteId   NUMERIC(18,0) OUTPUT  
      ,@Cmp_Id       NUMERIC(18,0)  
      ,@Training_InstituteName   VARCHAR(200)  
      ,@Training_InstituteCode   VARCHAR(50)  
      ,@Institute_LocationCode   VARCHAR(50)  
      ,@Institute_Address    VARCHAR(200)  
      ,@Institute_City        VARCHAR(100)  
      ,@Institute_StateId    NUMERIC(18,0)  
      ,@Institute_CountryId    NUMERIC(18,0)  
      ,@Institute_PinCode    VARCHAR(50)  
      ,@Institute_Telephone    NVARCHAR(50)  
      ,@Institute_FaxNo     NVARCHAR(50)  
      ,@Institute_Email     VARCHAR(50)  
      ,@Institute_Website    VARCHAR(100)  
      ,@Institute_AffiliatedBy   Varchar(100)  
      ,@Trans_Type      VARCHAR(1)   
   ,@USER_ID       NUMERIC(18,0) = 0   
      ,@IP_ADDRESS      VARCHAR(30)= ''   
AS  
  
  SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
  
BEGIN  
   
   
 IF @Institute_StateId =0  
  SET @Institute_StateId =NULL  
 IF @Institute_CountryId =0  
  SET @Institute_CountryId =NULL  

   set @Training_InstituteName = dbo.fnc_ReverseHTMLTags(@Training_InstituteName)  --added by Ronak 221021
      set @Training_InstituteCode = dbo.fnc_ReverseHTMLTags(@Training_InstituteCode)  --added by Ronak 221021
	     set @Institute_LocationCode = dbo.fnc_ReverseHTMLTags(@Institute_LocationCode)  --added by Ronak 221021
		    set @Institute_Address = dbo.fnc_ReverseHTMLTags(@Institute_Address)  --added by Ronak 221021
  IF UPPER(@Trans_Type) ='I'   
  BEGIN  
    --Added by Deepali-21112022 -Start
   If Exists(select Training_InstituteId From T0050_Training_Institute_Master WITH (NOLOCK)  Where (Training_InstituteName = @Training_InstituteName OR Training_InstituteName='' or Training_InstituteName='Other') and Cmp_Id = @Cmp_Id)  
      Begin  
       set @Training_InstituteId = 0  
       return   
      End  
       --Added by Deepali-21112022 -End   
   SELECT @Training_InstituteId = ISNULL(MAX(Training_InstituteId),0)+1 FROM T0050_Training_Institute_Master WITH (NOLOCK)  
   INSERT INTO T0050_Training_Institute_Master  
   (  
      Training_InstituteId  
      ,Cmp_Id  
      ,Training_InstituteName  
      ,Training_InstituteCode  
      ,Institute_LocationCode  
      ,Institute_Address  
      ,Institute_City  
      ,Institute_StateId  
      ,Institute_CountryId  
      ,Institute_PinCode  
      ,Institute_Telephone  
      ,Institute_FaxNo  
      ,Institute_Email  
      ,Institute_Website  
      ,Institute_AffiliatedBy  
   )VALUES  
   (  
       @Training_InstituteId  
      ,@Cmp_Id  
      ,@Training_InstituteName  
      ,@Training_InstituteCode  
      ,@Institute_LocationCode  
      ,@Institute_Address  
      ,@Institute_City  
      ,@Institute_StateId  
      ,@Institute_CountryId  
      ,@Institute_PinCode  
      ,@Institute_Telephone  
      ,@Institute_FaxNo  
      ,@Institute_Email  
      ,@Institute_Website  
      ,@Institute_AffiliatedBy  
   )  
  END  
 ELSE IF UPPER(@Trans_Type) ='U'   
  BEGIN  
    --Added by Deepali-21112022 -Start
   If Exists(select Training_InstituteId From T0050_Training_Institute_Master WITH (NOLOCK) Where (Training_InstituteName = @Training_InstituteName OR Training_InstituteName='' or Training_InstituteName='Other')  and Cmp_Id = @Cmp_Id  
           and Training_InstituteId <> @Training_InstituteId )  
    begin  
     set @Training_InstituteId = 0  
     return   
    end  
        --Added by Deepali-21112022 -End
   UPDATE T0050_Training_Institute_Master  
   SET    Training_InstituteName = @Training_InstituteName  
      ,Training_InstituteCode = @Training_InstituteCode  
      ,Institute_LocationCode = @Institute_LocationCode  
      ,Institute_Address  = @Institute_Address  
      ,Institute_City   = @Institute_City  
      ,Institute_StateId  = @Institute_StateId  
      ,Institute_CountryId  = @Institute_CountryId  
      ,Institute_PinCode  = @Institute_PinCode  
      ,Institute_Telephone  = @Institute_Telephone  
      ,Institute_FaxNo   = @Institute_FaxNo  
      ,Institute_Email   = @Institute_Email  
      ,Institute_Website  = @Institute_Website  
      ,Institute_AffiliatedBy = @Institute_AffiliatedBy  
   WHERE Training_InstituteId  = @Training_InstituteId  
  END  
 ELSE IF UPPER(@Trans_Type) ='D'  
  BEGIN  
   DELETE FROM T0055_Training_Faculty where Training_InstituteId = @Training_InstituteId  
   DELETE FROM T0050_Training_Institute_Master where Training_InstituteId = @Training_InstituteId  
  END   
END  