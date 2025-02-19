  
  
  
CREATE PROCEDURE [dbo].[P0040_TYPE_MASTER]  
  @Type_ID      numeric(9) output  
 ,@Cmp_ID       numeric(9)  
 ,@Type_Name    varchar(100)  
 ,@Type_Dis_No  numeric(9,0)  
 ,@Type_Def_ID   numeric(9,0)    
 ,@tran_type    varchar(1)  
 ,@User_Id numeric(18,0) = 0 --Add By paras 12-10-2012  
    ,@IP_Address varchar(30)= '' --Add By paras 12-10-2012  
    ,@Type_Code   VARCHAR(30) = ''  
    ,@Encashment_Rate   numeric(18,2) = 1  
    ,@IsActive tinyint=1   
    ,@InEffeDate datetime=null --Added by Sumit 10042015  
AS  
  
  SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
  
  
--Add By paras 12-10-2012  
declare @OldValue as  varchar(max)  
declare @OldTypeName as varchar(100)  
declare @OldDisNo as varchar(9)  
declare @OldTypeDefID as varchar(9)  
declare @OldEncashment_Rate as varchar(9)  
  
set @OldTypeName =''  
set @OldDisNo =''  
set @OldTypeDefID =''  
set @OldEncashment_Rate =''  
  
if @InEffeDate=''  
 set @InEffeDate=null  
  
-----  
    set @Type_Name = dbo.fnc_ReverseHTMLTags(@Type_Name)  --added by Ronak 081021
	 set @Type_Code = dbo.fnc_ReverseHTMLTags(@Type_Code)  --added by Ronak 081021
 If @tran_type  = 'I'  
  Begin  
    
   Set @Type_Name = LTRIM(@Type_Name)  
   SET @Type_Name = RTRIM(@Type_Name)  
     
   If exists(select Type_ID from T0040_Type_Master WITH (NOLOCK) where Upper(Type_Name) = Upper(@Type_Name)   
       And Cmp_ID = @Cmp_ID)   
   begin  
    set @Type_ID = 0  
    return  
   end  
    
   select @Type_ID = Isnull(max(Type_ID),0) + 1  From T0040_TYPE_MASTER WITH (NOLOCK)  
     INSERT INTO T0040_TYPE_MASTER  
                        (  
         Type_ID    
        ,Cmp_ID     
                                ,Type_Name  
                                ,Type_Dis_No   
                 ,Type_Def_ID     
                 ,Encashment_Rate  
                 ,type_code  
                 ,IsActive  
                 ,InActive_EffeDate  
                        )  
      VALUES       
        (  
              @Type_ID    
          ,@Cmp_ID     
                                     ,@Type_Name  
                                     ,@Type_Dis_No   
                   ,@Type_Def_ID   
                   ,@Encashment_Rate    
                   ,@Type_Code   
                   ,@IsActive  
                   ,@InEffeDate  
        )  
          
        --Add By paras 12-10-2012  
         set @OldValue = 'New Value' + '#'+ 'Type Name :' +ISNULL( @Type_Name,'') + '#' + 'Type Discription No :' +CAST(ISNULL( @Type_Dis_No,'')as varchar(9)) + '#' + 'Type DisID :' + CAST(ISNULL(@Type_Def_ID,0) AS VARCHAR(9)) + '#' + 'Encashment Rate :' 
+ CAST(ISNULL(@Encashment_Rate ,0) AS VARCHAR(9)) + '#'   
        ----  
  End  
 Else if @Tran_Type = 'U'   
  begin  
     
   If exists(select Type_ID from T0040_Type_Master WITH (NOLOCK) where Upper(Type_Name) = Upper(@Type_Name)   
       And Cmp_ID = @Cmp_ID and TYPE_ID <> @Type_ID )   
   begin  
    set @Type_ID = 0  
    return  
   end  
   -- Add By Paras 12-10-2012  
     
   select @OldTypeName  =ISNULL(Type_Name,'') ,@OldDisNo  =ISNULL(Type_Dis_No,''),@OldTypeDefID  =isnull(Type_Def_ID,0),@OldEncashment_Rate =Encashment_Rate    From dbo.T0040_Type_Master WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and Type_ID = @Type_ID  
     
    Update T0040_TYPE_MASTER  
    set   
                     Type_Name = @Type_Name  
                    ,Type_Dis_No = @Type_Dis_No  
              ,Type_Def_ID   = @Type_Def_ID  
              ,Encashment_Rate=@Encashment_Rate   
              ,type_code = @Type_Code  
              ,IsActive = @IsActive  
              ,InActive_EffeDate = @InEffeDate  
    where Type_ID = @Type_ID  
      
          set @OldValue = 'old Value' + '#'+ 'Type Name :' + @OldTypeName  + '#' + 'Type Dis No :' + @OldDisNo  + '#' + 'Type_Def_Id :' + @OldTypeDefID + '#' + 'Encashement_Rate :' + @OldEncashment_Rate  + '#' +   
                                + 'New Value' + '#'+ 'Type Name :' +ISNULL( @Type_Name,'') + '#' + 'Type Dis No :' +CAST(ISNULL( @Type_Dis_No,'')as varchar(9)) + '#' + 'Type_Def_ID :' + CAST(ISNULL(@Type_Dis_No,0) AS VARCHAR(9)) + '#' + 'encashment_Rate :
' + CAST(ISNULL(@Encashment_Rate ,0) AS VARCHAR(9)) + '#'   
            --  
  
  end  
 Else if @Tran_Type = 'D'   
  begin  
    if exists (Select 1 From T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and [Type_ID] = @Type_ID)  
     BEGIN  
      RAISERROR('@@ Reference Esits @@',16,2)  
      RETURN  
     END  
    else if exists (Select 1 From T0095_INCREMENT WITH (NOLOCK) where Cmp_ID = @Cmp_ID and [Type_ID] = @Type_ID)  
     BEGIN  
      RAISERROR('@@ Reference Esits @@',16,2)  
      RETURN  
     END  
    ELSE  
     BEGIN  
      select @OldTypeName  = Type_Name ,@OldDisNo =Type_Dis_No,@OldTypeDefID  =isnull(Type_Def_ID,'') ,@OldEncashment_Rate =encashment_Rate From dbo.T0040_Type_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and TYPE_ID = @Type_ID  
      Delete From T0040_TYPE_MASTER Where Type_ID = @Type_ID  
      set @OldValue = 'old Value' + '#'+ 'Type Name :' + @OldTypeName  + '#' + 'Type Dis No :' + @OldDisNo  + '#' + 'Type_def_ID :' + @OldTypeDefID + '#' + 'Encashement_Rate :' + @OldEncashment_Rate   
     END  
   -- Add By Paras 12-10-2012  
       
    ---  
  end  
  exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Emp Type Master',@OldValue,@Type_ID,@User_Id,@IP_Address  
  
 RETURN  
  
  
  
  