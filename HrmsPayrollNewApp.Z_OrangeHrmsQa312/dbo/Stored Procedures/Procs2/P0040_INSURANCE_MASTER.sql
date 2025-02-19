  
  
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_INSURANCE_MASTER]   
 @Ins_Tran_ID NUMERIC OUTPUT  
,@Cmp_ID      NUMERIC  
,@Ins_Name    VARCHAR(50)  
,@Ins_Desc    VARCHAR(150)  
,@Type    varchar(10) = 'Insurance'  
,@Default_value nvarchar(max)  
,@Tran_Type   CHAR(1)  
,@User_Id numeric(18,0) = 0 --Add By PAras 15-10-2012  
,@IP_Address varchar(30)= '' --Add By PAras 15-10-2012  
,@Insurance_Type INT -- Added by Mehul 14032022
  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
--Add By PAras 15-10-2012  
declare @OldValue as  varchar(max)  
declare @OldIns_Name as varchar(50)  
declare @OldIns_Desc as varchar(150)  
declare @OldType as varchar(10)  
declare @OldDefault_value as  varchar(max)  
  
set @OldIns_Name =''  
set @OldIns_Desc = ''  
set @OldType = 'Insurance'  
set @OldDefault_value = ''  
---  
   set @Ins_Name = dbo.fnc_ReverseHTMLTags(@Ins_Name)  --added by Ronak 081021
   set @Ins_Desc = dbo.fnc_ReverseHTMLTags(@Ins_Desc)  --added by Ronak 081021
IF @Tran_Type = 'I'  
 BEGIN  
  IF EXISTS(SELECT Ins_Tran_ID FROM T0040_INSURANCE_MASTER WITH (NOLOCK) WHERE @Cmp_id = Cmp_ID AND UPPER(@Ins_Name) = UPPER(Ins_name))  
   BEGIN  
    SET @Ins_Tran_ID = 0  
    RETURN  
   END  
  SELECT @Ins_Tran_ID = isnull(MAX(Ins_Tran_ID),0)+1 from T0040_INSURANCE_MASTER  WITH (NOLOCK)  
    
  INSERT INTO T0040_INSURANCE_MASTER (Ins_Tran_ID,Cmp_ID,Ins_Name,Ins_Desc,Type,Default_Value,Insurance_Type) VALUES (@Ins_Tran_ID,@Cmp_ID,@Ins_Name,@Ins_Desc,@Type,@Default_value,@Insurance_Type)  
          --Add by PAras 12-10-2012  
          set @OldValue = 'New Value' + '#'+ 'Insurance Name :' +ISNULL( @Ins_Name,'') + '#' + 'Insurance Discription :' + ISNULL( @Ins_Desc,'') + '#' + 'Type :' + @Type + '#' + 'Default Name :' + @Default_value   
          --  
             
 END  
ELSE IF @Tran_Type = 'U'  
 BEGIN  
  IF EXISTS (SELECT Ins_Tran_ID FROM T0040_INSURANCE_MASTER WITH (NOLOCK) WHERE @Cmp_id = Cmp_ID AND UPPER(@Ins_Name) = UPPER(Ins_name)AND @Ins_Tran_ID <> Ins_Tran_ID)  
   BEGIN  
    SET @Ins_Tran_ID = 0  
    RETURN  
   END  
    --Add by PAras 12-10-2012  
    select @OldIns_Name  =ISNULL(Ins_Name,'') ,@OldIns_Desc  =ISNULL(Ins_Desc,''), @OldType = Type , @OldDefault_value = isnull(Default_Value,'') From dbo.T0040_INSURANCE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Ins_Tran_ID = @Ins_Tran_ID  
      
  UPDATE T0040_INSURANCE_MASTER   
   SET Ins_Name = @Ins_Name,  
    Ins_Desc = @Ins_Desc,    
    Type = @Type,  
    Default_Value = @Default_Value,
	Insurance_Type = @Insurance_Type
   WHERE Cmp_ID =@Cmp_ID And Ins_Tran_ID = @Ins_Tran_ID   
     
     set @OldValue = 'old Value' + '#'+ 'Insurance Name :' + @OldIns_Name  + '#' + 'Insurance Discription :' + @OldIns_Desc  + '#' + 'Type :' + @OldType + '#' + 'Default Name :' + @OldDefault_value   
                           + 'New Value' + '#'+ 'Insurance Name :' +ISNULL( @Ins_Name,'') + '#' + 'Insurance Discription :' + ISNULL( @Ins_Desc,'') + '#' + 'Type :' + @Type + '#' + 'Default Name :' + @Default_value  
                              
                            -------------  
 END   
   
ELSE IF @Tran_Type = 'D'  
 BEGIN   
  --Add by PAras 12-10-2012  
    select @OldIns_Name  = Ins_Name ,@OldIns_Desc  =Ins_Desc, @OldType = Type , @OldDefault_value = isnull(Default_Value,'') From dbo.T0040_INSURANCE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Ins_Tran_ID = @Ins_Tran_ID  
  DELETE FROM T0040_INSURANCE_MASTER WHERE Ins_Tran_ID = @Ins_Tran_ID  
  set @OldValue = 'old Value' + '#'+ 'Insurance Name :' + @OldIns_Name  + '#' + 'Insurance Discription :' + @OldIns_Desc  + '#' + 'Type :' + @OldType + '#' + 'Default Name :' + @OldDefault_value   
 END   
  exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Insurance Master',@OldValue,@Ins_Tran_ID,@User_Id,@IP_Address  
  
RETURN  
  
  
  
  