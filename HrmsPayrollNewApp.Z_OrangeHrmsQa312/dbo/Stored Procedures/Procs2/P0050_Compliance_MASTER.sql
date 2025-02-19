
  
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0050_Compliance_MASTER]      
  @Compliance_ID NUMERIC(18,0) OUTPUT      
 ,@Cmp_ID NUMERIC(18,0)      
 ,@Compliance_Name VARCHAR(MAX)      
 ,@Compliance_Code VARCHAR(Max)
 ,@year_Type tinyint
 ,@Submition_Type tinyint
 ,@cmpdate datetime=null 
 ,@View_IN_Dash tinyint
 ,@view_IN_Repo tinyint
 ,@DueDate Varchar(100)
 ,@DueMonth Varchar(100)
 ,@ToEmail nVarchar(max) = ''
 ,@CCEmail nVarchar(max) = ''
 ,@tran_type VARCHAR(1)  
 ,@User_Id NUMERIC(18,0) = 0   
 ,@IP_Address VARCHAR(30)= ''    
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
  
 DECLARE @OldValue AS VARCHAR(5000)  
 DECLARE @OldCompliance_Name AS VARCHAR(500)  
 DECLARE @OldCompliance_Codes AS VARCHAR(5000)  
 DECLARE @Oldsystemdate  AS VARCHAR(18)  
  
 Set @OldValue = ''  
 SET @OldCompliance_Name = ''  
 SET @OldCompliance_Codes = ''  
 SET @Oldsystemdate = ''  
    
   
 if @cmpdate=''  
  set @cmpdate=null   
        set @Compliance_Name = dbo.fnc_ReverseHTMLTags(@Compliance_Name)  --added by Ronak 081021
	    set @Compliance_Code = dbo.fnc_ReverseHTMLTags(@Compliance_Code)  --added by Ronak 081021
		
 IF @tran_type ='I'       
  BEGIN      
   IF EXISTS(SELECT Compliance_ID FROM T0050_Compliance_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID       
      AND UPPER(Compliance_Name) = UPPER(@Compliance_Name) )    
    BEGIN      
     SET @Compliance_ID = 0      
     RETURN            
    END      
     
   SELECT @Compliance_ID = ISNULL(MAX(Compliance_ID),0) + 1  FROM T0050_Compliance_MASTER WITH (NOLOCK)     
           
   INSERT INTO T0050_Compliance_MASTER      
     (Compliance_ID,Cmp_ID,Compliance_Name,Compliance_Code,Updated_Date,Compliance_Year_Type,Compliance_Submition_Type,Compliance_View_IN_Dash,Compliance_View_IN_Repo,DUE_DATE,DUE_MONTH,TO_EMAIL,CC_EMAIL)      
    VALUES (@Compliance_ID, @Cmp_ID, @Compliance_Name,@Compliance_Code,@cmpdate,@year_Type,@Submition_Type,@View_IN_Dash,@view_IN_Repo,@DueDate,@DueMonth,@ToEmail,@CCEmail)       
       
    SET @OldValue = 'New Value' + '#'+ 'Scale Name :' + ISNULL( @Compliance_Name,'') + '#'  + 'pay of scale :' + ISNULL(@Compliance_Code,'') + '#' + 'Sysdate :' + CAST(@cmpdate AS VARCHAR(18))  
         
  END     
      
 ELSE IF @tran_type ='U'       
  BEGIN      
  
   IF EXISTS(SELECT Compliance_ID FROM T0050_Compliance_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID       
      AND UPPER(Compliance_Name) = UPPER(@Compliance_Name) AND Compliance_ID <> @Compliance_ID)   
    BEGIN
	return
     SET @Compliance_ID = 0      
     RETURN            
    END     
     
   SELECT   @OldCompliance_Name = ISNULL(Compliance_Name,''),  
      @OldCompliance_Codes = ISNULL(Compliance_Code,''),  
      @Oldsystemdate=cast(Updated_Date as varchar(50))  
    FROM dbo.T0050_Compliance_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Compliance_ID = @Compliance_ID   
          
   UPDATE T0050_Compliance_MASTER      
     SET    
      Compliance_Name = @Compliance_Name,  
      Compliance_Code = @Compliance_Code  
	  ,Compliance_Year_Type = @year_Type
      ,Compliance_Submition_Type = @Submition_Type
	  ,Updated_Date = @cmpdate 
	  ,Compliance_View_IN_Dash = @View_IN_Dash
	  ,Compliance_View_IN_Repo = @view_IN_Repo
	  ,DUE_DATE = @DueDate
	  ,DUE_MONTH = @DueMonth
	  ,TO_EMAIL =  @ToEmail
	  ,CC_EMAIL =  @CCEmail
     WHERE (Compliance_ID = @Compliance_ID)      
         
   SET @OldValue = 'old Value' + '#'+ 'Scale Name :' + @OldCompliance_Name   + '#'  + 'pay of scale :' + @OldCompliance_Codes  + '#' + 'Sysdate :' + @Oldsystemdate  
               + 'New Value' + '#'+ 'Scale Name :' + ISNULL( @Compliance_Name,'') + '#'  + 'pay of scale :' + ISNULL(@Compliance_Code,'') + '#' + 'Sysdate :' + CAST(@cmpdate AS VARCHAR(18))  
                     
    
  END      
    
 ELSE IF @tran_type ='d'      
  BEGIN      
   SELECT   @OldCompliance_Name = ISNULL(Compliance_Name,''),  
      @OldCompliance_Codes = ISNULL(Compliance_Code,''),  
      @Oldsystemdate=cast(Updated_Date as varchar(50))  
    FROM dbo.T0050_Compliance_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Compliance_ID = @Compliance_ID   
     
   DELETE FROM T0050_Compliance_MASTER WHERE Compliance_ID = @Compliance_ID      
     
   SET @OldValue = 'old Value' + '#'+ 'Scale Name :' + @OldCompliance_Name + '#'  + 'pay of scale :' + @OldCompliance_Codes  + '#' + 'Sysdate :' + @Oldsystemdate   
  END      
     
   EXEC P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Pay Scale Master',@OldValue,@Compliance_ID,@User_Id,@IP_Address  
   ------      
 RETURN  
  