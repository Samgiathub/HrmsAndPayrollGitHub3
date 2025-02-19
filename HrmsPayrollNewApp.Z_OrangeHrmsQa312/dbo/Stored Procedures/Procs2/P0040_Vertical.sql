      
      
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---      
CREATE PROCEDURE [dbo].[P0040_Vertical]          
    @Vertical_ID  numeric(9) output        
   ,@Cmp_ID   numeric(9)         
   ,@Vertical_Code varchar(50)        
   ,@Vertical_Name varchar(100)        
   ,@Vertical_Description varchar(250)        
   ,@tran_type  varchar(1)       
   ,@User_Id numeric(18,0) = 0      
   ,@IP_Address varchar(30)= ''       
      ,@IsActive tinyint = 1    ----added by aswini 22/12/2023
 ,@InEffeDate datetime=null    ----added by aswini 22/12/2023    
       
AS      
SET NOCOUNT ON       
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED      
SET ARITHABORT ON      
      
 declare @OldValue as varchar(max)      
 declare @OldCode as varchar(50)      
 declare @OldVerticalName as varchar(100)      
 declare @OldVerticalDescription as varchar(250)      
 declare @OldActive as varchar(20)    ----added by aswini 22/12/2023
 declare @OldEffDate as varchar(50)   ----added by aswini 22/12/2023   
           
       
  set @OldValue = ''      
  set @OldCode = ''      
  set @OldVerticalName = ''      
  set @OldVerticalDescription = ''   
   set @OldActive=1    
 set @OldEffDate=''   
         
         set @Vertical_Name = dbo.fnc_ReverseHTMLTags(@Vertical_Name)  --added by ronak 120122     
         set @Vertical_Code = dbo.fnc_ReverseHTMLTags(@Vertical_Code)  --added by ronak 120122     
         set @Vertical_Description = dbo.fnc_ReverseHTMLTags(@Vertical_Description)  --added by ronak 120122    
  
 If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'      
  BEGIN      
   If @Vertical_Name = ''      
    BEGIN      
     Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Vertical Name is not Properly Inserted',0,'Enter Proper Vertical Name',GetDate(),'Vertical Master','')  --Change by Jaina 11-08-2016            
     Return      
    END      
          
  END      
        
 If Upper(@tran_type) ='I'      
   begin      
    if exists (Select Vertical_ID  from T0040_Vertical_Segment WITH (NOLOCK) Where Upper(Vertical_Name) = Upper(@Vertical_Name) and Cmp_ID = @Cmp_ID)       
     begin      
      set @Vertical_ID = 0      
      Return       
     end      
    if exists (Select Vertical_ID  from T0040_Vertical_Segment WITH (NOLOCK) Where Upper(Vertical_Code) = Upper(@Vertical_Code) and Cmp_ID = @Cmp_ID)       
     begin      
      set @Vertical_ID = 0      
      Return       
     end      
          
    select @Vertical_ID = isnull(max(Vertical_ID),0) + 1 from T0040_Vertical_Segment WITH (NOLOCK)      
      
    INSERT INTO T0040_Vertical_Segment      
                          (Vertical_Id, Cmp_Id, Vertical_Code, Vertical_Name, Vertical_Description,Isactive,InActive_EffeDate)      
    VALUES     (@Vertical_Id,@Cmp_Id,@Vertical_Code,@Vertical_Name, @Vertical_Description,@IsActive,@InEffedate)       
                  
     set @OldValue = 'New Value' + '#'+ 'Vertical Name :' +ISNULL( @Vertical_Name,'') + '#' + 'Vertical Code :' + ISNULL( @Vertical_Code,'') + '#' + 'Vertical_Description :' + ISNULL(@Vertical_Description,'')  + '#'  
	 +'IsActive :' +  CAST(ISNULL(@IsActive,1) AS VARCHAR(18))  + '#' 
			+'InActive_EffeDate :' + CAST(@InEffeDate AS VARCHAR(18))  + '#'  ----added by aswini 22/12/2023
     ----      
   end       
 Else If  Upper(@tran_type) ='U'       
   begin      
    if exists (Select Vertical_ID  from T0040_Vertical_Segment WITH (NOLOCK) Where Upper(Vertical_Name) = Upper(@Vertical_Name) and Vertical_ID <> @Vertical_ID and Cmp_ID = @cmp_ID )       
     begin      
      set @Vertical_ID = 0      
      Return      
     end      
    if exists (Select Vertical_ID  from T0040_Vertical_Segment WITH (NOLOCK) Where Upper(Vertical_Code) = Upper(@Vertical_Code) and Vertical_ID <> @Vertical_ID and Cmp_ID = @Cmp_ID)       
     begin      
      set @Vertical_ID = 0      
      Return       
     end      
          select @OldVerticalName  =ISNULL(Vertical_Name,'') ,@OldCode  =isnull(Vertical_Code,''), @OldVerticalDescription = ISNULL(Vertical_Description,''), @OldActive=isnull(IsActive,0),@OldEffDate=isnull(InActive_EffeDate,'') From dbo.T0040_Vertical_Segment WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Vertical_ID = @Vertical_ID        
           
    UPDATE    T0040_Vertical_Segment      
    SET      Vertical_Name = @Vertical_Name, Vertical_Code = @Vertical_Code, Vertical_Description = @Vertical_Description  ,IsActive=@IsActive,InActive_EffeDate =@InEffedate      
    WHERE     Vertical_Id = @Vertical_ID      
          
    set @OldValue = 'old Value' + '#'+ 'Vertical Name :' + @OldVerticalName  + '#' + 'Vertical Code:' + @OldCode  + '#' + 'Vertical Description :' + @OldVerticalDescription   + '#' + 'IsActive :'+ @OldActive +'#' + 'InActive_EffeDate :' + @OldEffDate + '#'    
               + 'New Value' + '#'+ 'Vertical Name :' +ISNULL( @Vertical_Name,'') + '#' + 'Vertical Code :' + ISNULL( @Vertical_Code,'') + '#' + 'Vertical Description :' + ISNULL(@Vertical_Description,'')  + '#'       
               -----      
    end      
         
 Else If  Upper(@tran_type) ='D'      
   Begin      
   -- Add by nilesh patel on 09042016 --Start      
        
    if Exists(Select 1 From T0095_INCREMENT WITH (NOLOCK) Where Vertical_Id = @Vertical_ID)      
    BEGIN      
     Set @Vertical_ID = 0      
     Return      
    END      
   -- Add by nilesh patel on 09042016 --End      
         
    select @OldVerticalName  =ISNULL(Vertical_Name,'') ,@OldVerticalDescription  =ISNULL(Vertical_Description,''),@OldCode  =isnull(Vertical_Code,''),@OldActive= isnull(IsActive,0),@InEffeDate=isnull(InActive_EffeDate,'') From dbo.T0040_Vertical_Segment WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Vertical_ID = @Vertical_ID      
  
          
     DELETE FROM T0040_Vertical_Segment WHERE Vertical_Id = @Vertical_ID      
           
    set @OldValue = 'old Value' + '#'+ 'Vertical Name :' +ISNULL( @OldVerticalName,'') + '#' + 'Vertical Code :' + ISNULL( @OldCode,'') + '#' + 'Vertical Description :' + ISNULL(@Vertical_Description,'')  + '#'+  'IsActive :'+ISNULL( @OldActive,0) +'#' + 'InActive_EffeDate :' +ISNULL( @OldEffDate,'') + '#'         
    -----      
   End      
   exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Vertical Master',@OldValue,@Vertical_ID,@User_Id,@IP_Address      
         
 RETURN      
      
      