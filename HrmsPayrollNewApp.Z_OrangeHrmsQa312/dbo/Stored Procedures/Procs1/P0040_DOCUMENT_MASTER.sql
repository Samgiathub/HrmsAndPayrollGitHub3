  
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_DOCUMENT_MASTER]  
 @Doc_ID numeric(18,0) output  
   ,@Cmp_ID numeric(18,0)  
   ,@Doc_Name varchar(100)  
   ,@Doc_Comments varchar(250)   
   ,@tran_type varchar(1)  
   ,@Doc_required tinyint = 0  
   ,@User_Id numeric(18,0) = 0  
   ,@IP_Address varchar(30)= '' --Add By Paras 19-10-2012  
 ,@Document_type_Id numeric(18,0) = 0  
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
declare @OldValue as  varchar(max)  
declare @OldDoc_Name as varchar(100)  
declare @OldDoc_Comments as varchar(250)  
Declare @oldDocument_type_id as varchar (100)  
  
set @OldDoc_Name=''  
set @OldDoc_Comments=''  
set @oldDocument_type_id=''  
   set @Doc_Name = dbo.fnc_ReverseHTMLTags(@Doc_Name)  --added by Ronak 081021
    set @Doc_Comments = dbo.fnc_ReverseHTMLTags(@Doc_Comments)  --added by Ronak 081021
  If Upper(@tran_type) ='I'   
   begin  
    If exists (Select Doc_ID  from T0040_DOCUMENT_MASTER WITH (NOLOCK) Where Upper(Doc_Name) = Upper(@Doc_Name) and Cmp_ID =@cmp_ID)   
     begin  
      set @Doc_ID = 0  
      Return  
     end  
  
     select @Doc_ID = isnull(max(Doc_ID),0) + 1 from T0040_DOCUMENT_MASTER WITH (NOLOCK)  
  
     INSERT INTO T0040_DOCUMENT_MASTER  
                           (Doc_ID, Cmp_ID, Doc_Name, Doc_Comments,Doc_Required,Document_type_id)  
     VALUES     (@Doc_ID,@Cmp_ID,@Doc_Name,@Doc_Comments,@Doc_required,@Document_type_Id)  
       
     set @OldValue = 'New Value' + '#'+ 'Doc Name:' +ISNULL( @Doc_Name,'') + '#' + 'Doc Comments:' + ISNULL( @Doc_Comments,'') + '#' + 'Document Type Id :' + cast(ISNULL( @Document_type_Id,'') as varchar)  
       
    end   
 Else If Upper(@tran_type) ='U'   
    begin  
     If exists (Select Doc_ID  from T0040_DOCUMENT_MASTER WITH (NOLOCK) Where Upper(Doc_Name) = Upper(@Doc_Name)   
         and Cmp_ID =@cmp_ID and Doc_ID <> @Doc_ID )   
      begin  
       set @Doc_ID = 0  
       Return  
      end  
                  select @OldDoc_Name  =ISNULL(Doc_Name,'') ,@OldDoc_Comments  =ISNULL(Doc_Comments,''),@oldDocument_type_id  =ISNULL(Document_type_id,'') From dbo.T0040_DOCUMENT_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Doc_ID = @Doc_ID  
     UPDATE    T0040_DOCUMENT_MASTER  
     SET              Doc_Name = @Doc_Name, Doc_Comments = @Doc_Comments, Cmp_ID = @Cmp_ID  
          ,Doc_required = @Doc_required  
          ,Document_type_id=@Document_type_id  
     WHERE     (Doc_ID = @Doc_ID)  
       
     set @OldValue = 'old Value' + '#'+ 'Doc Name :' + @OldDoc_Name  + '#' + 'Doc Comments :' + @OldDoc_Comments   + '#' + 'Document type id :' + cast(@oldDocument_type_id as varchar)  
                                  + 'New Value' + '#'+ 'Doc Name :' +ISNULL( @Doc_Name,'') + '#' + 'Doc Comments  :' + ISNULL( @Doc_Comments,'') + '#' + 'Document type id :' + cast(ISNULL( @Document_type_id,'') as varchar)  
    
    end  
      
 Else If UPPER(@tran_type) ='D'  
   Begin  
   select @OldDoc_Name  =ISNULL(Doc_Name,'') ,@OldDoc_Comments  =ISNULL(Doc_Comments,''),@oldDocument_type_id  =ISNULL(Document_type_id,'')  From dbo.T0040_DOCUMENT_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Doc_ID = @Doc_ID  
     DELETE FROM T0040_DOCUMENT_MASTER WHERE Doc_ID = @Doc_ID  
     set @OldValue = 'old Value' + '#'+ 'Doc Name :' + @OldDoc_Name  + '#' + 'Doc Comments :' + @OldDoc_Comments   + '#' + 'Document type id:' + cast(@oldDocument_type_id  as varchar)  
   End  
   exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Document Master',@OldValue,@Doc_ID,@User_Id,@IP_Address  
     
 RETURN  
  
  
  
  