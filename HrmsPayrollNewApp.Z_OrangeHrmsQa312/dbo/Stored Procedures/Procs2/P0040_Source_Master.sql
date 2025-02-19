  
  
CREATE  PROCEDURE [dbo].[P0040_Source_Master]  
   @Source_Id numeric(18,0) output  
  ,@Source_Name  varchar(100)  
  ,@Source_type_id numeric(18,0)  
  ,@Comments varchar(max)=''  
  ,@tran_type varchar(1)  
  ,@User_Id numeric(18,0) = 0   
        ,@IP_Address varchar(30)= ''  
   
AS  
  
  SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
  
declare @OldValue as varchar(max)  
declare @OldSource_Name as varchar(100)  
declare @OldSource_type_id as varchar(100)  
declare  @OldComments  as varchar(Max)  
  
 set @OldValue=''  
  set @OldSource_Name = ''  
  set @OldSource_type_id = ''  
  set @OldComments = ''  
    
  --------  
    
     set @Source_Name = dbo.fnc_ReverseHTMLTags(@Source_Name)  --added by Ronak 081021
 If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'  
  BEGIN  
   If @Source_Name = ''  
    BEGIN  
     Insert Into dbo.T0080_Import_Log Values (0,0,0,'Source Name is not Properly Inserted',0,'Enter Proper Source Name',GetDate(),'Source Master','')        
     Return  
    END  
      
  END  
    
 If Upper(@tran_type) ='I'  
   begin  
     
    if exists (Select Source_Id  from T0040_Source_Master WITH (NOLOCK) Where Upper(Source_Name) = Upper(@Source_Name) )   
     begin  
     
      set @Source_Id = 0  
      Return   
     end  
    
    if 'Employee Referral' = (select source_type_name from T0030_Source_Type_Master WITH (NOLOCK) where source_type_id =@Source_type_id)  
    begin  
     
     RAISERROR('##You Can not add in Employee Referral ##',16,2)  
     RETURN -1  
    end  
     
    SELECT @Source_Id = ISNULL(MAX(Source_Id),0) + 1  FROM T0040_Source_Master WITH (NOLOCK)   
      
    INSERT INTO T0040_Source_Master  
                          (Source_id,Source_Name, Source_type_id, Comments)  
    VALUES     (@Source_id,@Source_Name,@Source_type_id, @Comments)   
               
     set @OldValue = 'New Value' + '#'+ 'Source Name :' +ISNULL( @Source_Name,'') + '#' + 'Source Type Id :' + CAST(ISNULL( @Source_type_id,0)as varchar(18)) + '#' + 'Comments:' + ISNULL(@Comments,'')  + '#'   
       
     ----  
   end   
 Else If  Upper(@tran_type) ='U'   
   begin  
    if exists (Select Source_id  from T0040_Source_Master WITH (NOLOCK) Where Upper(Source_Name) = Upper(@Source_Name) and Source_Id <> @Source_Id )   
     begin  
      set @Source_id = 0  
      Return  
     end  
       
          select @OldSource_Name  =ISNULL(Source_Name,'') ,@OldSource_type_id  =ISNULL(Source_type_id,0),@OldComments  =isnull(@Comments,0) From T0040_Source_Master WITH (NOLOCK) Where Source_id = @Source_Id    
       
    UPDATE    T0040_Source_Master  
    SET       Source_Name = @Source_Name, Source_type_id = @Source_type_id, Comments = @Comments   
    WHERE     Source_id = @Source_Id  
      
    set @OldValue = 'old Value' + '#'+ 'Source Name :' + @OldSource_Name  + '#' + 'Source Type Id:' + @OldSource_type_id  + '#' + 'Comments :' + @OldComments   + '#' +  
               + 'New Value' + '#'+ 'Source Name :' +ISNULL( @Source_Name,'') + '#' + 'Source Type Id:' + CAST(ISNULL( @Source_type_id,0)as varchar(18)) + '#' + 'Comments:' + ISNULL(@Comments,'')  + '#'   
               -----  
    end  
     
 Else If  Upper(@tran_type) ='D'  
   Begin  
     
     select @OldSource_Name  =ISNULL(Source_Name,'') ,@OldSource_type_id  =ISNULL(Source_type_id,0),@OldComments  =isnull(@Comments,0) From T0040_Source_Master WITH (NOLOCK) Where Source_id = @Source_Id    
    if exists(select Resume_Code from T0055_Resume_Master WITH (NOLOCK) where Source_Id=@Source_Id and Source_type_id=@OldSource_type_id)  
    begin  
     RAISERROR('@@Reference Exist @@',16,2)  
     RETURN -1  
    end  
    else  
    begin   
     DELETE FROM T0040_Source_Master WHERE Source_id = @Source_Id  
       
    set @OldValue = 'old Value' + '#'+ 'Source Name :' + @OldSource_Name  + '#' + 'Source Type Id:' + @OldSource_type_id  + '#' + 'Comments :' + @OldComments   + '#'   
    -----  
   end  
   End  
     
   exec P9999_Audit_Trail 0,@Tran_Type,'Source Master',@OldValue,@Source_Id,@User_Id,@IP_Address  
     
     
     
 RETURN  
  
  
  
  