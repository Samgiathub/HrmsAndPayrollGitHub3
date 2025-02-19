  
  
  
  
CREATE  PROCEDURE [dbo].[P0040_QUALIFICATION_MASTER]  
    @Qual_ID numeric(18,0) output  
   ,@Cmp_ID numeric(18,0)  
   ,@Qual_Name varchar(100)  
   ,@tran_type char  
   ,@User_Id numeric(18,0) = 0  
      ,@IP_Address varchar(30)= '' --Add By Paras 19-10-2012  
      ,@Qual_Type varchar(100)=''  
AS  
  
        SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
  
declare @OldValue as varchar(MAx)  
declare @OldQual_Name as varchar(100)  
  
set @OldQual_Name =''  
  set @Qual_Name = dbo.fnc_ReverseHTMLTags(@Qual_Name)  --added by Ronak 081021
 If Upper(@tran_type) ='I'   
  begin  
    
    If exists (Select Qual_ID  from T0040_Qualification_Master WITH (NOLOCK) Where upper(Qual_Name) = Upper(@Qual_Name)   
        and Cmp_ID = @Cmp_ID)   
     begin  
      set @Qual_ID = 0  
      return    
     end  
     
     select @Qual_ID = isnull(max(Qual_ID),0) + 1  from T0040_Qualification_Master WITH (NOLOCK)  
       
     INSERT INTO T0040_QUALIFICATION_MASTER  
                           (Qual_ID, Cmp_ID, Qual_Name,Qual_Type)  
     VALUES     (@Qual_ID,@Cmp_ID,@Qual_Name,@Qual_Type)  
       
     set @OldValue = 'New Value' + '#'+ 'Qual Name :' +ISNULL( @Qual_Name,'')   
       
  end   
 Else If upper(@tran_type) ='U'   
  begin  
   if exists (Select Qual_ID  from T0040_QUALIFICATION_MASTER WITH (NOLOCK) Where Upper(Qual_Name )= upper(@Qual_Name) and Cmp_ID = @cmp_Id   
        and Qual_ID <> @Qual_ID)   
    begin  
     set @Qual_ID = 0  
     return  
    end     
    select @OldQual_Name  =ISNULL(Qual_Name,'')  From dbo.T0040_QUALIFICATION_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Qual_ID = @Qual_ID    
  
     UPDATE    T0040_QUALIFICATION_MASTER  SET       Qual_Name = @Qual_Name,Qual_Type=@Qual_Type  
     WHERE     Qual_ID = @Qual_ID  
       
     set @OldValue = 'old Value' + '#'+ 'Qual Name :' +ISNULL( @OldQual_Name,'')   
                                  + 'New Value' + '#'+ 'Qual Name :' +ISNULL( @Qual_Name,'')   
   
  
  end   
 Else If upper(@tran_type) ='D'  
  Begin  
    
  select @OldQual_Name  =ISNULL(Qual_Name,'')  From dbo.T0040_QUALIFICATION_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Qual_ID = @Qual_ID    
    
   DELETE FROM T0040_QUALIFICATION_MASTER  WHERE     (Qual_ID = @Qual_ID)  
     
   set @OldValue = 'old Value' + '#'+ 'Qual Name :' +ISNULL( @OldQual_Name,'')  
  end  
      exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Qulification Master',@OldValue,@Qual_ID,@User_Id,@IP_Address  
  
 RETURN  
  
  
  
  