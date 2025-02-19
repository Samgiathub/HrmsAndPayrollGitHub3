  
  
  
  
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_COST_CENTER_MASTER]  
 @Center_ID AS NUMERIC output,  
 @CMP_ID AS NUMERIC,  
 @Center_Name AS VARCHAR(100),  
 @Center_Code as varchar(50),--Added by mihir trivedi on 15032012 to add code  
 @tran_type varchar(1),  
 @Cost_element as varchar(50)  
   ,@User_Id numeric(18,0) = 0   --Add By Paras 12-10-2012  
   ,@IP_Address varchar(30)= ''  --Add By Paras 12-10-2012  
  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
declare @OldValue as  varchar(max)  
declare @OldCenter_Name as varchar(100)  
declare @OldCenter_Code as varchar(50)  
declare @OldCost_element as varchar(50)  
  
  set @OldValue = ''  
  set @OldCenter_Name = ''  
  set @OldCenter_Code = ''  
  set @OldCost_element = ''  
    
    set @Center_Name = dbo.fnc_ReverseHTMLTags(@Center_Name)  --added by Ronak 081021    
	 set @Center_Code = dbo.fnc_ReverseHTMLTags(@Center_Code)  --added by Ronak 081021    
	  set @Cost_element = dbo.fnc_ReverseHTMLTags(@Cost_element)  --added by Ronak 081021    
	
 If @tran_type  = 'I'  
  Begin  
    If Exists(Select Center_ID From T0040_COST_CENTER_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Center_Name) = upper(@Center_Name)) -- Modified by Mitesh 04/08/2011 for different collation db.  
     begin  
      set @Center_ID = 0  
      Return   
     end  
      
    select @Center_ID = Isnull(max(Center_ID),0) + 1  From T0040_COST_CENTER_MASTER WITH (NOLOCK)  
      
        
    INSERT INTO T0040_COST_CENTER_MASTER  
                          (Center_ID, Cmp_ID, Center_Name, Center_Code,Cost_Element)  
    VALUES     (@Center_ID, @Cmp_ID, @Center_Name, @Center_Code,@Cost_element)  
      
      
           set @OldValue = 'New Value' + '#'+ 'Center Name :' +ISNULL( @Center_Name,'') + '#' + 'Center Code :' + ISNULL( @Center_Code,'') + '#'   
      
      
  End  
 Else if @Tran_Type = 'U'  
  begin  
    If Exists(Select Center_ID From T0040_COST_CENTER_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Center_Name) = upper(@Center_Name) and Center_ID <> @Center_ID) -- Modified by Mitesh 04/08/2011 for different collation db.  
     begin  
      set @Center_ID = 0  
      Return   
     end  
       
                 select @OldCenter_Name  =ISNULL(Center_Name,'') ,@OldCenter_Code  =ISNULL(Center_Code,''),@OldCost_element  =isnull(Cost_Element,0)  From dbo.T0040_COST_CENTER_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Center_ID = @Center_ID  
                   
    Update T0040_COST_CENTER_MASTER  
    set Center_Name = @Center_Name, Center_Code = @Center_Code --Added by mihir trivedi on 15032012 to add code  
    ,Cost_Element = @Cost_element  
    where Center_ID = @Center_ID  
      
    set @OldValue = 'old Value' + '#'+ 'Center Name :' + @OldCenter_Name  + '#' + 'Center Code :' + @OldCenter_Code  + '#' + 'Code Element :' + @OldCost_element + '#' +   
                              + 'New Value' + '#'+ 'Center Name :' +ISNULL( @Center_Name,'') + '#' + 'Center Code :' + ISNULL( @Center_Code,'') + '#' + 'Center Element :' + ISNULL(@Cost_element,0)  + '#'   
    
      
  end  
 Else if @Tran_Type = 'D'  
  begin  
   select @OldCenter_Name  = Center_Name ,@OldCenter_Code  =Center_Code,@OldCost_element  =isnull(Cost_Element,'')  From dbo.T0040_COST_CENTER_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Center_ID = @Center_ID  
    Delete From T0040_COST_CENTER_MASTER Where Center_ID = @Center_ID  
     set @OldValue = 'old Value' + '#'+ 'Center Name :' + @OldCenter_Name  + '#' + 'Center Code :' + @OldCost_element  + '#'  
       
       
  end  
   exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Cost Master',@OldValue,@Center_ID,@User_Id,@IP_Address  
 RETURN  
  
  
  
  