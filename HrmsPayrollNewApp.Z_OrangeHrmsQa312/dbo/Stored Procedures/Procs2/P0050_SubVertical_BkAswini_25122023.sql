    
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
create PROCEDURE [dbo].[P0050_SubVertical_BkAswini_25122023]        
    @SubVertical_ID  numeric(9) output      
   ,@Cmp_ID   numeric(9)       
   ,@Vertical_ID numeric(9)    
   ,@SubVertical_Code varchar(50)      
   ,@SubVertical_Name varchar(100)      
   ,@SubVertical_Description varchar(250)      
   ,@tran_type  varchar(1)     
   ,@User_Id numeric(18,0) = 0    
   ,@IP_Address varchar(30)= ''     
     
AS    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
 declare @OldValue as varchar(max)    
 declare @OldCode as varchar(50)    
 declare @OldSubVerticalName as varchar(100)    
 declare @VerticalName as varchar(100)    
 declare @OldVerticalName as varchar(100)    
 declare @OldSubVerticalDescription as varchar(250)    
 declare @OldVertical_Id as numeric(9)    
     
     
  set @OldValue = ''    
  set @OldCode = ''    
  Set @verticalName = ''    
  set @OldverticalName = ''    
  set @OldSubVerticalName = ''    
  set @OldSubVerticalDescription = ''    
  set @OldVertical_Id = 0    
      
  --------    
         set @SubVertical_Name = dbo.fnc_ReverseHTMLTags(@SubVertical_Name)  --added by mansi 061021    
		 set @SubVertical_Code = dbo.fnc_ReverseHTMLTags(@SubVertical_Code)  --added by mansi 121021 
		  set @SubVertical_Description = dbo.fnc_ReverseHTMLTags(@SubVertical_Description)  --added by mansi 121021   
      
 If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'    
  BEGIN    
   If @SubVertical_Name = ''    
    BEGIN    
     Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Sub Vertical Name is not Properly Inserted',0,'Enter Proper Sub Vertical Name',GetDate(),'SubVertical Master','')          
     Return    
    END    
        
  END    
      
 If Upper(@tran_type) ='I'    
     
   begin    
       
    if exists (Select SubVertical_ID  from T0050_SubVertical WITH (NOLOCK) Where Upper(subVertical_Name) = Upper(@SubVertical_Name) and Cmp_ID = @Cmp_ID)     
     begin    
      set @SubVertical_ID = 0    
      Return     
     end    
     if exists (Select SubVertical_ID  from T0050_SubVertical WITH (NOLOCK) Where Upper(SubVertical_Code) = Upper(@SubVertical_Code) and Cmp_ID = @Cmp_ID)     
     begin    
      set @SubVertical_ID = 0    
      Return     
     end    
        
    select @SubVertical_ID = isnull(max(SubVertical_ID),0) + 1 from T0050_SubVertical WITH (NOLOCK)    
        
    INSERT INTO T0050_SubVertical (SubVertical_Id, Cmp_Id,Vertical_Id,SubVertical_Code, SubVertical_Name, SubVertical_Description)    
     VALUES (@SubVertical_Id,@Cmp_Id,@Vertical_ID,@SubVertical_Code,@SubVertical_Name, @SubVertical_Description)     
         
    select @VerticalName = Vertical_Name from T0040_Vertical_Segment WITH (NOLOCK) where Vertical_ID = @Vertical_ID    
    set @OldValue = 'New Value' + '#'+ 'SubVertical Name :' +ISNULL( @SubVertical_Name,'') + '#' + 'Vertical Name :' + @VerticalName + '#' + 'SubVertical Code :' + ISNULL( @SubVertical_Code,'') + '#' + 'SubVertical_Description :' + ISNULL(@SubVertical_Description,'')  + '#'     
     ----    
         
   end     
 Else If  Upper(@tran_type) ='U'     
   begin    
    if exists (Select SubVertical_ID  from T0050_SubVertical WITH (NOLOCK) Where Upper(SubVertical_Name) = Upper(@SubVertical_Name) and SubVertical_ID <> @SubVertical_ID and Cmp_ID = @cmp_ID )     
     begin    
      set @SubVertical_ID = 0    
      Return    
     end    
    if exists (Select SubVertical_ID  from T0050_SubVertical WITH (NOLOCK) Where Upper(SubVertical_Code) = Upper(@SubVertical_Code) and SubVertical_ID <> @SubVertical_ID and Cmp_ID = @cmp_ID )     
     begin    
      set @SubVertical_ID = 0    
      Return    
     end    
         
          select @OldVertical_Id =  Vertical_ID , @OldSubVerticalName = ISNULL(SubVertical_Name,'') ,@OldSubVerticalDescription  =ISNULL(SubVertical_Description,''),@OldCode  =isnull(SubVertical_Code,'') From T0050_SubVertical WITH (NOLOCK) Where Cmp_ID =
  
 @Cmp_ID and SubVertical_ID = @SubVertical_ID      
    select @OldVerticalName = Vertical_Name from T0040_Vertical_Segment WITH (NOLOCK) where Vertical_ID = @OldVertical_Id    
         
    UPDATE    T0050_SubVertical    
    SET      SubVertical_Name = @SubVertical_Name, SubVertical_Code = @SubVertical_Code    
      , SubVertical_Description = @SubVertical_Description ,Vertical_ID = @Vertical_ID    
    WHERE     SubVertical_Id = @SubVertical_ID    
        
        
    select @VerticalName = vertical_Name from T0040_Vertical_Segment WITH (NOLOCK) where Vertical_ID = @Vertical_ID    
    set @OldValue = 'old Value' + '#'+ 'SubVertical Name :' + @OldSubVerticalName  + '#' + 'VerticalName :' + @OldVerticalName + '#' + 'SubVertical Code:' + @OldCode  + '#' + 'SubVertical Description :' + @OldSubVerticalDescription  + '#' +    
               + 'New Value' + '#'+ 'SubVertical Name :' +ISNULL( @SubVertical_Name,'') + '#' + 'VerticalName :' + @VerticalName + '#' + 'SubVertical Code :' + ISNULL( @SubVertical_Code,'') + '#' + 'SubVertical Description :' + ISNULL(@SubVertical_Description,'')  + '#'     
               -----    
    end    
       
 Else If  Upper(@tran_type) ='D'    
   Begin    
    -- Add by nilesh patel on 09042016 --Start    
        
    if Exists(Select 1 From T0095_INCREMENT WITH (NOLOCK) Where SubVertical_Id = @SubVertical_ID)    
    BEGIN    
     Set @SubVertical_ID = 0    
     Return    
    END    
    -- Add by nilesh patel on 09042016 --End    
        
    select @OldVertical_Id =  Vertical_ID , @OldSubVerticalName = ISNULL(SubVertical_Name,'') ,@OldSubVerticalDescription  =ISNULL(SubVertical_Description,''),@OldCode  =isnull(SubVertical_Code,'') From T0050_SubVertical WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and SubVertical_ID = @SubVertical_ID      
        
    DELETE FROM T0050_SubVertical WHERE SubVertical_Id = @SubVertical_ID    
         
    select @OldVerticalName = Vertical_Name from T0040_Vertical_Segment WITH (NOLOCK) where Vertical_ID = @OldVertical_Id    
        
    set @OldValue = 'old Value' + '#'+ 'SubVertical Name :' +ISNULL( @OldSubVerticalName,'') +'#' +'VerticalName :' + @OldVerticalName + '#' + 'SubVertical Code :' + ISNULL( @OldCode,'') + '#' + 'SubVertical Description :' + ISNULL(@OldSubVerticalDescription,'')  + '#'      
        
        
        
   End    
   exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'SubVertical Master',@OldValue,@SubVertical_ID,@User_Id,@IP_Address     
 RETURN    
    
    
    