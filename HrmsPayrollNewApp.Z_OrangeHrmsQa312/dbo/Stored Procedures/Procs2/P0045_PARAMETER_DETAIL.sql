    
    
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
CREATE PROCEDURE [dbo].[P0045_PARAMETER_DETAIL]    
    @Cmp_Id numeric(18,0)    
   ,@Para_Id numeric(18,0)    
   ,@From_Slab numeric(18,2)    
   ,@To_Slab numeric(18,2)    
   ,@Slab_Value numeric(18,2)    
   ,@Para_Name VARCHAR(100)    
   ,@Para_For varchar(50) -- ADDED ON 31012018 PARAMETER OR QUALIFYING CONDITION STATUS    
   ,@TRAN_TYPE Char(1)    
AS    
    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
     
      
    DECLARE @ROW_ID NUMERIC(18,0)    
        
 IF ISNULL(@CMP_ID,0)=0    
    BEGIN    
   RAISERROR('@@ Company ID must be specified @@',16,2)     
   RETURN    
    END    
 --IF (ISNULL(@EFFECT_DATE,'1900-01-01') ='1900-01-01' )       
 -- BEGIN    
 --  RAISERROR('@@ EFFECT Date must be specified  @@',16,2)        
 --  RETURN    
 -- END    
	    
      set @Para_Name = dbo.fnc_ReverseHTMLTags(@Para_Name)  --added by Ronak 081021   
 IF @TRAN_TYPE  = 'I'    
 BEGIN     
      
     IF (@PARA_ID <> 0)    
      SET @PARA_ID=@PARA_ID    
     ELSE    
   SELECT @PARA_ID=MAX(PARA_ID) FROM dbo.T0040_PARAMETER_MASTER WITH (NOLOCK)    
      
  SELECT @ROW_ID = ISNULL(MAX(ROW_ID),0) + 1  FROM DBO.T0045_PARAMETER_DETAIL WITH (NOLOCK)    
  SET @ROW_ID=@ROW_ID;    
      
   IF NOT EXISTS(SELECT 1 FROM dbo.T0045_PARAMETER_DETAIL WITH (NOLOCK) WHERE PARA_ID=@PARA_ID AND ROW_ID=@ROW_ID AND CMP_ID=@CMP_ID)    
    BEGIN    
    INSERT INTO DBO.T0045_PARAMETER_DETAIL(ROW_ID,CMP_ID,PARA_ID,FROM_SLAB,TO_SLAB,SLAB_VALUE,PARA_NAME,PARA_FOR)    
    VALUES(@ROW_ID,@CMP_ID,@PARA_ID,@FROM_SLAB,@TO_SLAB,@SLAB_VALUE,@PARA_NAME,@PARA_FOR)     
   END    
 END    
     
IF @TRAN_TYPE= 'E'    
 BEGIN    
     
  SELECT ROW_ID,CMP_ID,PARA_ID,FROM_SLAB,TO_SLAB,SLAB_VALUE,PARA_NAME,PARA_FOR FROM dbo.T0045_PARAMETER_DETAIL WITH (NOLOCK)    
  WHERE PARA_ID=@PARA_ID AND CMP_ID=@CMP_ID    
     
 END    
     
IF(@TRAN_TYPE='D')    
 BEGIN    
  print 111    
  IF EXISTS(SELECT 1 FROM T0045_PARAMETER_DETAIL WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND PARA_ID=@PARA_ID)    
  BEGIN    
      
   DELETE FROM T0045_PARAMETER_DETAIL WHERE CMP_ID=@CMP_ID AND PARA_ID=@PARA_ID    
   DELETE FROM T0040_PARAMETER_MASTER WHERE CMP_ID=@CMP_ID AND PARA_ID=@PARA_ID    
  END    
 END    
     
     
END    
    
    
    