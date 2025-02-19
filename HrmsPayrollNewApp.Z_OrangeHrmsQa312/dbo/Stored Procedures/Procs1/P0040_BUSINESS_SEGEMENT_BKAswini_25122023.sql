    
    
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
create PROCEDURE [dbo].[P0040_BUSINESS_SEGEMENT_BKAswini_25122023]        
    @Segment_ID  numeric(9) output      
   ,@Cmp_ID   numeric(9)       
   ,@Segment_Code varchar(50)      
   ,@Segment_Name varchar(100)      
   ,@Segment_Description varchar(250)      
   ,@tran_type  varchar(1)     
   ,@User_Id numeric(18,0) = 0    
   ,@IP_Address varchar(30)= ''     
   ,@Is_MachineBased TINYINT  = 0 --Added By Ramiz on 23022018    
   ,@MachineEmpType VARCHAR(20) = null --Added By Ramiz on 23022018    
AS    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
 declare @OldValue as varchar(max)    
 declare @OldCode as varchar(50)    
 declare @OldSegmentName as varchar(100)    
 declare @OldSegmentDescription as varchar(250)    
     
     
  set @OldValue = ''    
  set @OldCode = ''    
  set @OldSegmentName = ''    
  set @OldSegmentDescription = ''    
      
   if  @MachineEmpType = ''    
  set @MachineEmpType = null    
      
  --------    
     set @Segment_Name = dbo.fnc_ReverseHTMLTags(@Segment_Name)  --added by mansi 061021  
           set @Segment_Code = dbo.fnc_ReverseHTMLTags(@Segment_Code)  --added by mansi 121021  
		      set @Segment_Description = dbo.fnc_ReverseHTMLTags(@Segment_Description)  --added by mansi 121021  

 If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'    
  BEGIN    
   If @Segment_Name = ''    
    BEGIN    
     Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Business Segment Name is not Properly Inserted',0,'Enter Proper Business Segment Name',GetDate(),'Business Segment Master','')          
     Return    
    END    
        
  END    
      
 If Upper(@tran_type) ='I'    
   begin    
        
    if exists (Select Segment_ID  from T0040_business_Segment WITH (NOLOCK) Where Upper(Segment_Name) = Upper(@Segment_Name) and Cmp_ID = @Cmp_ID)     
     begin    
      set @Segment_ID = 0    
      Return     
     end    
    if exists (Select Segment_ID  from T0040_business_Segment WITH (NOLOCK) Where Upper(Segment_Code) = Upper(@Segment_Code) and Cmp_ID = @Cmp_ID)     
     begin    
      set @Segment_ID = 0    
      Return     
     end    
    select @Segment_ID = isnull(max(Segment_ID),0) + 1 from T0040_business_Segment WITH (NOLOCK)    
    
    INSERT INTO T0040_business_Segment    
                          (Segment_Id, Cmp_Id, Segment_Code, Segment_Name, Segment_Description,Is_MachineBased,MachineEmpType)    
    VALUES     (@Segment_ID,@Cmp_Id,@Segment_code,@Segment_Name, @Segment_Description,@Is_MachineBased,@MachineEmpType)    
                
     SET @OldValue = 'New Value' + '#'+ 'Segment Name :' +ISNULL( @Segment_Name,'') + '#' + 'Segment Code :' + ISNULL( @Segment_Code,'') + '#' + 'Segment_Description :' + ISNULL(@Segment_Description,'')  + '#'     
     ----    
   end     
 Else If  Upper(@tran_type) ='U'     
   begin    
    if exists (Select Segment_ID  from T0040_business_Segment WITH (NOLOCK) Where Upper(Segment_Name) = Upper(@Segment_Name) and Segment_ID <> @Segment_ID and Cmp_ID = @cmp_ID )     
     begin    
      set @Segment_ID = 0    
      Return    
     end    
    if exists (Select Segment_ID  from T0040_business_Segment WITH (NOLOCK) Where Upper(Segment_Code) = Upper(@Segment_Code)and Segment_ID <> @Segment_ID and Cmp_ID = @Cmp_ID)     
     begin    
      set @Segment_ID = 0    
      Return     
     end    
          select @OldSegmentName  =ISNULL(Segment_Name,'') ,@OldCode  =isnull(Segment_Code,''), @OldSegmentDescription = ISNULL(Segment_Description,'') From dbo.T0040_business_Segment WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Segment_ID = @Segment_ID      
         
    UPDATE    T0040_business_Segment    
    SET       Segment_Name = @Segment_Name, Segment_Code = @Segment_Code, Segment_Description = @Segment_Description     
       ,Is_MachineBased = @Is_MachineBased ,MachineEmpType = @MachineEmpType    
    WHERE     Segment_Id = @Segment_ID    
        
    set @OldValue = 'old Value' + '#'+ 'Segment Name :' + @OldSegmentName  + '#' + 'Segment Code:' + @OldCode  + '#' + 'Segment Description :' + @OldSegmentDescription   + '#' +    
               + 'New Value' + '#'+ 'Segment Name :' +ISNULL( @Segment_Name,'') + '#' + 'Segment Code :' + ISNULL( @Segment_Code,'') + '#' + 'Segment Description :' + ISNULL(@Segment_Description,'')  + '#'     
               -----    
    end    
       
 Else If  Upper(@tran_type) ='D'    
   Begin    
        
    -- Add by nilesh patel on 09042016 --Start    
        
    if Exists(Select 1 From T0095_INCREMENT WITH (NOLOCK) Where Segment_ID = @Segment_ID)    
    BEGIN    
     Set @Segment_ID = 0    
     Return    
    END    
   -- Add by nilesh patel on 09042016 --End    
     if Exists( Select 1 From T0080_EMP_MASTER WITH (NOLOCK) Where Segment_ID = @Segment_ID AND Cmp_ID=@Cmp_ID) -- ADD BY RAJPUT 31032017    
    BEGIN    
        Set @Segment_ID = 0    
     Return    
    END     
    select @OldSegmentName  =ISNULL(segment_Name,'') ,@OldSegmentDescription  =ISNULL(Segment_Description,''),@OldCode  =isnull(segment_Code,'') From dbo.T0040_business_Segment WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Segment_ID = @Segment_ID      
        
    DELETE FROM T0040_business_Segment WHERE Segment_Id = @Segment_ID    
         
    set @OldValue = 'old Value' + '#'+ 'Segment Name :' +ISNULL( @OldSegmentName,'') + '#' + 'Segment Code :' + ISNULL( @OldCode,'') + '#' + 'Segment Description :' + ISNULL(@Segment_Description,'')  + '#'      
    -----    
   End    
   exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Business Segment Master',@OldValue,@Segment_ID,@User_Id,@IP_Address    
       
 RETURN    
    
    
    
    