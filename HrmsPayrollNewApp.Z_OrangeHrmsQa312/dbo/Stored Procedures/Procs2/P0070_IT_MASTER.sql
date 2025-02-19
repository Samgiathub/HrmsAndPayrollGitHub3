  
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0070_IT_MASTER]  
 @IT_ID    Numeric output,    
 @Cmp_ID    Numeric,   
 @IT_Name   varchar(350),   
 @IT_Alias   varchar(20),   
 @IT_Max_Limit  numeric,   
 @IT_Flag   char(1),   
 @IT_Level   int,   
 @IT_Def_ID   tinyint,   
 @IT_Is_Active  tinyint,   
 @IT_Parent_ID  numeric,   
 @AD_ID    numeric,   
 @RIMB_ID   numeric,   
 @Login_ID   numeric,  
 @IT_Main_Group  tinyint,  
 @IT_Declaration_Req tinyint,  
 @Tran_Type   char(1),  
 @IT_Doc_Req         varchar(max),  
 @User_ID numeric(18,0) = 0,   -- Added for audit trail By Ali 22102013  
 @IP_Address varchar(30)= '',  -- Added for audit trail By Ali 22102013  
 @IT_Is_Header tinyint = 0,  
 @IT_Is_Attah_Comp tinyint = 0,  
 @IT_Is_Details tinyint = 0,  
 @IT_Is_Perquisite tinyint = 0,  
 @AD_String nvarchar(max) = '', --added by Gadriwala Muslim 20122016  
 @Exempt_Percent Numeric(18,2) = 0 --Added By Jimit 19072018  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
            
         -- Added for audit trail By Ali 22102013 -- Start  
          Declare @OldValue varchar(max)  
          Declare @Old_IT_Name varchar(100)  
          Declare @Old_IT_Alias varchar(20)  
          Declare @Old_IT_Max_Limit numeric   
          Declare @Old_IT_Flag char(1)  
          Declare @Old_IT_Level int  
          Declare @Old_IT_Def_ID tinyint  
          Declare @Old_IT_Is_Active tinyint  
          Declare @Old_IT_Parent_ID numeric  
          Declare @Old_AD_ID numeric  
          Declare @Old_RIMB_ID numeric  
          Declare @Old_Login_ID numeric  
          Declare @Old_IT_Main_Group tinyint  
          Declare @Old_IT_Declaration_Req tinyint            
          Declare @Old_IT_Doc_Req varchar(max)  
          Declare @Old_IT_Header tinyint  
          Declare @Old_IT_Is_Attah_Comp tinyint  
          declare @Old_IT_Is_Perquisite Tinyint  
          Declare @OLD_AD_String nvarchar(max) --added by Gadriwala Muslim 20122016  
          Declare @OLD_Exempt_Percent Numeric(18,2)  
            
          Set @OldValue = ''  
          Set @Old_IT_Name = ''  
          Set @Old_IT_Alias = ''  
          Set @Old_IT_Max_Limit = 0  
          Set @Old_IT_Flag = ''  
          Set @Old_IT_Level = 0  
          Set @Old_IT_Def_ID = 0  
          Set @Old_IT_Is_Active = 0  
          Set @Old_IT_Parent_ID = 0  
          Set @Old_AD_ID = 0  
          Set @Old_RIMB_ID = 0  
          Set @Old_Login_ID = 0  
          Set @Old_IT_Main_Group = 0  
          Set @Old_IT_Declaration_Req = 0  
          Set @Old_IT_Doc_Req = ''  
          Set @Old_IT_Header = 0  
          Set @Old_IT_Is_Attah_Comp = 0  
          set @Old_IT_Is_Perquisite= 0  
          set @OLD_AD_String = '' --added by Gadriwala Muslim 20122016  
          set @OLD_Exempt_Percent = 0  
         -- Added for audit trail By Ali 22102013 -- End  
              
   
   
 IF @Login_ID =0    
  set @Login_ID  = null  
  
 IF @AD_ID =0    
  set @AD_ID = null  
  
 IF @Rimb_ID =0    
  set @Rimb_ID = null  
   
 If @IT_Parent_ID =0  
  set @IT_Parent_ID = null  
    set @IT_Name = dbo.fnc_ReverseHTMLTags(@IT_Name) --Ronak_060121  
   set @IT_Alias = dbo.fnc_ReverseHTMLTags(@IT_Alias) --Ronak_060121   
     set @IT_Doc_Req = dbo.fnc_ReverseHTMLTags(@IT_Doc_Req) --Ronak_060121   

 if @Tran_Type = 'I'  
  begin  
    if exists(select Cmp_ID from T0070_IT_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID and upper(IT_Name) = upper(@IT_Name) ) -- Modified by Mitesh 04/08/2011 for different collation db.  
     begin  
      Raiserror('Duplicate Name',16,2)  
      return -1  
     end  
      
    if exists(select Cmp_ID from T0070_IT_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID and upper(It_Alias) = upper(@IT_Alias) ) --Added by rohit because error wile import   
     begin  
      Raiserror('Duplicate Alias',16,2)  
      return -1  
     end  
       
      
    Select @IT_ID = isnull(max(IT_ID),0) + 1  From  T0070_IT_MASTER WITH (NOLOCK)  
       
    INSERT INTO T0070_IT_MASTER  
     (IT_ID, Cmp_ID, IT_Name, IT_Alias, IT_Max_Limit, IT_Flag, IT_Level, IT_Def_ID, IT_Is_Active, IT_Parent_ID, AD_ID, RIMB_ID, Login_ID, System_Date,IT_Main_Group,IT_Declaration_Req,IT_Doc_Name,IT_Is_Header,IT_Is_Atth_Comp,IT_Is_Details,It_is_perquisite,
AD_String,Exempt_Percent) -- Added By Ali 24012014  
    select @IT_ID, @Cmp_ID, @IT_Name, @IT_Alias, @IT_Max_Limit, @IT_Flag, @IT_Level, @IT_Def_ID, @IT_Is_Active, @IT_Parent_ID, @AD_ID, @RIMB_ID, @Login_ID, Getdate(),@IT_Main_Group,@IT_Declaration_Req,@IT_Doc_Req,@IT_Is_Header,@IT_Is_Attah_Comp,@IT_Is_Details,@It_is_perquisite,@Ad_String,@Exempt_Percent -- Added by Gadriwala Muslim 20122016 -- Added By Ali 24012014  
      
          -- Added for audit trail By Ali 22102013 -- Start  
           set @OldValue = 'New Value'   
            + '#' + 'IT Name : ' + ISNULL(@IT_Name,'')  
            + '#' + 'IT Alias : ' + ISNULL(@IT_Alias,'')  
            + '#' + 'Max Limit : ' + CONVERT(nvarchar(200),ISNULL(@IT_Max_Limit,0))  
            + '#' + 'Flag : ' + CASE ISNULL(@IT_Flag,'') When 'I' Then 'Increment' ELSE 'Decrement' END  
            + '#' + 'Sorting No : ' + CONVERT(nvarchar(200),ISNULL(@IT_Level,0))  
            + '#' + 'IT Def ID : ' + CASE ISNULL(@IT_Def_ID,0) WHEN 0 THEN 'None' WHEN 1 THEN 'House Rent' WHEN 10 THEN 'Less TDS' WHEN 11 THEN 'Medical Exemption' WHEN 151 THEN 'LTA Exemption' ELSE 'Leave Exemption' END  
            + '#' + 'IT Parent ID : ' + CONVERT(nvarchar(200),ISNULL(@IT_Parent_ID,0))  
            + '#' + 'Proof Required : ' + ISNULL(@IT_Doc_Req,'')  
            + '#' + 'MainGroup : ' + CASE ISNULL(@IT_Main_Group,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Declaration : ' + CASE ISNULL(@IT_Declaration_Req,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Active : ' + CASE ISNULL(@IT_Is_Active,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Is Header : ' + CASE ISNULL(@IT_Is_Header,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Attachment Mandatory : ' + CASE ISNULL(@IT_Is_Attah_Comp,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Perquisite : ' + CASE ISNULL(@IT_Is_Perquisite,0) WHEN 0 Then 'NO' Else 'YES' END   
            + '#' + 'AD_String : ' +  ISNULL(@AD_String,'') --added by Gadriwala Muslim 20122016  
            + '#' + 'Exempt_Percent : ' +  Convert(nvarchar(200),ISNULL(@Exempt_Percent,0))                                                                 
           exec P9999_Audit_Trail @Cmp_ID,@tran_type,'IT Master',@OldValue,@IT_ID,@User_Id,@IP_Address  
          -- Added for audit trail By Ali 22102013 -- End  
            
  end  
 else if @Tran_Type ='U'  
  begin  
    if exists(select Cmp_ID from T0070_IT_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID and IT_ID <> @IT_ID and upper(IT_Name) = upper(@IT_Name) ) -- Modified by Mitesh 04/08/2011 for different collation db.  
     begin  
      Raiserror('Duplicate Name',16,2)  
      return -1  
     end  
       
     if exists(select Cmp_ID from T0070_IT_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID and IT_ID <> @IT_ID and upper(it_alias) = upper(@It_Alias) ) -- added by rohit for alis used while import declaration.  
     begin  
      Raiserror('Duplicate Alias',16,2)  
      return -1  
     end  
          -- Added for audit trail By Ali 22102013 -- Start  
           Select  
           @Old_IT_Name = IT_Name  
           ,@Old_IT_Alias = IT_Alias  
           ,@Old_IT_Max_Limit = IT_Max_Limit  
           ,@Old_IT_Flag = IT_Flag  
           ,@Old_IT_Level = IT_Level  
           ,@Old_IT_Def_ID = IT_Def_ID  
           ,@Old_IT_Parent_ID = IT_Parent_ID  
           ,@Old_IT_Doc_Req = IT_Doc_Name  
           ,@Old_IT_Main_Group = IT_Main_Group  
           ,@Old_IT_Declaration_Req = IT_Declaration_Req  
           ,@Old_IT_Is_Active = IT_Is_Active  
           ,@Old_IT_Header = IT_Is_Header  
           ,@Old_IT_Is_Attah_Comp = IT_Is_Atth_Comp  
           ,@Old_IT_Is_Perquisite = IT_Is_perquisite  
           ,@OLD_AD_String = AD_String -- Added by Gadriwala Muslim 20122016  
           ,@OLd_Exempt_Percent = Exempt_Percent  
           From T0070_IT_MASTER WITH (NOLOCK)  
           WHERE IT_ID = @IT_ID    
            
           set @OldValue = 'old Value'   
            + '#' + 'IT Name : ' + ISNULL(@Old_IT_Name,'')  
            + '#' + 'IT Alias : ' + ISNULL(@Old_IT_Alias,'')  
            + '#' + 'Max Limit : ' + CONVERT(nvarchar(200),ISNULL(@Old_IT_Max_Limit,0))  
		    + '#' + 'Flag : ' + CASE ISNULL(@Old_IT_Flag,'') When 'I' Then 'Increment' ELSE 'Decrement' END  
            + '#' + 'Sorting No : ' + CONVERT(nvarchar(200),ISNULL(@Old_IT_Level,0))  
            + '#' + 'IT Def ID : ' + CASE ISNULL(@Old_IT_Def_ID,0) WHEN 0 THEN 'None' WHEN 1 THEN 'House Rent' WHEN 10 THEN 'Less TDS' WHEN 11 THEN 'Medical Exemption' WHEN 151 THEN 'LTA Exemption' ELSE 'Leave Exemption' END  
            + '#' + 'IT Parent ID : ' + CONVERT(nvarchar(200),ISNULL(@Old_IT_Parent_ID,0))  
            + '#' + 'Proof Required : ' + ISNULL(@Old_IT_Doc_Req,'')  
            + '#' + 'MainGroup : ' + CASE ISNULL(@Old_IT_Main_Group,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Declaration : ' + CASE ISNULL(@Old_IT_Declaration_Req,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Active : ' + CASE ISNULL(@Old_IT_Is_Active,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Is Header : ' + CASE ISNULL(@Old_IT_Header,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Attachment Mandatory : ' + CASE ISNULL(@Old_IT_Is_Attah_Comp,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Perquisite : ' + CASE ISNULL(@Old_IT_Is_Perquisite,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'AD_String : ' + ISNULL(@OLD_AD_String,'') --added by Gadriwala Muslim 20122016  
            + '#' + 'Exempt_Percent : ' + Convert(nvarchar(200),ISNULL(@OLD_Exempt_Percent,0))  
            + '#' +  
            + 'New Value' +  
            + '#' + 'IT Name : ' + ISNULL(@IT_Name,'')  
            + '#' + 'IT Alias : ' + ISNULL(@IT_Alias,'')  
            + '#' + 'Max Limit : ' + CONVERT(nvarchar(200),ISNULL(@IT_Max_Limit,0))  
            + '#' + 'Flag : ' + CASE ISNULL(@IT_Flag,'') When 'I' Then 'Increment' ELSE 'Decrement' END  
            + '#' + 'Sorting No : ' + CONVERT(nvarchar(200),ISNULL(@IT_Level,0))  
            + '#' + 'IT Def ID : ' + CASE ISNULL(@IT_Def_ID,0) WHEN 0 THEN 'None' WHEN 1 THEN 'House Rent' WHEN 10 THEN 'Less TDS' WHEN 11 THEN 'Medical Exemption' WHEN 151 THEN 'LTA Exemption' ELSE 'Leave Exemption' END  
            + '#' + 'IT Parent ID : ' + CONVERT(nvarchar(200),ISNULL(@IT_Parent_ID,0))  
            + '#' + 'Proof Required : ' + ISNULL(@IT_Doc_Req,'')  
            + '#' + 'MainGroup : ' + CASE ISNULL(@IT_Main_Group,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Declaration : ' + CASE ISNULL(@IT_Declaration_Req,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Active : ' + CASE ISNULL(@IT_Is_Active,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Is Header : ' + CASE ISNULL(@IT_Is_Header,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Attachment Mandatory : ' + CASE ISNULL(@IT_Is_Attah_Comp,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'perquisite : ' + CASE ISNULL(@IT_Is_Perquisite,0) WHEN 0 Then 'NO' Else 'YES' END     
            + '#' + 'AD_String : ' + ISNULL(@AD_String,'')  --added by Gadriwala Muslim 20122016  
            + '#' + 'Exempt_Percent : ' + Convert(nvarchar(200),ISNULL(@Exempt_Percent,0))                                   
           exec P9999_Audit_Trail @Cmp_ID,@tran_type,'IT Master',@OldValue,@IT_ID,@User_Id,@IP_Address  
          -- Added for audit trail By Ali 22102013 -- End  
            
    UPDATE    T0070_IT_MASTER  
    SET       IT_Name = @IT_Name, IT_Alias = @IT_Alias, IT_Max_Limit =@IT_Max_Limit, IT_Flag =@IT_Flag  
      , IT_Level =@IT_Level, IT_Def_ID =@IT_Def_ID, IT_Is_Active =@IT_Is_Active, IT_Parent_ID =@IT_Parent_ID  
      , AD_ID =@AD_ID, RIMB_ID =@RIMB_ID, Login_ID =@Login_ID,   
              System_Date =Getdate(),IT_Declaration_Req = @IT_Declaration_Req , IT_Main_Group = @IT_Main_Group  
            , IT_Doc_Name = @IT_Doc_Req,IT_Is_Header = @IT_Is_Header,IT_Is_Atth_Comp = @IT_Is_Attah_Comp  
            ,IT_Is_Details = @IT_Is_Details -- Added By Ali 24012014  
             ,IT_Is_perquisite = @IT_Is_Perquisite  
             ,AD_String =@AD_String -- Added by Gadriwala Muslim 20122016  
             ,Exempt_Percent = @Exempt_Percent  
    WHERE     IT_ID = @IT_ID   
  end  
 else if @Tran_Type ='D'  
  begin   
          -- Added for audit trail By Ali 22102013 -- Start  
           Select  
           @Old_IT_Name = IT_Name  
           ,@Old_IT_Alias = IT_Alias  
           ,@Old_IT_Max_Limit = IT_Max_Limit  
           ,@Old_IT_Flag = IT_Flag  
           ,@Old_IT_Level = IT_Level  
           ,@Old_IT_Def_ID = IT_Def_ID  
           ,@Old_IT_Parent_ID = IT_Parent_ID  
           ,@Old_IT_Doc_Req = IT_Doc_Name  
           ,@Old_IT_Main_Group = IT_Main_Group  
           ,@Old_IT_Declaration_Req = IT_Declaration_Req  
           ,@Old_IT_Is_Active = IT_Is_Active  
           ,@Old_IT_Header = IT_Is_Header  
           ,@Old_IT_Is_Attah_Comp = IT_Is_Atth_Comp  
           ,@Old_IT_Is_Perquisite  = IT_Is_perquisite  
           ,@OLD_AD_String = AD_String -- Added by Gadriwala Muslim 20122016  
           ,@OLd_Exempt_Percent = Exempt_Percent  
           From T0070_IT_MASTER WITH (NOLOCK)  
           WHERE IT_ID = @IT_ID    
            
           set @OldValue = 'old Value'   
            + '#' + 'IT Name : ' + ISNULL(@Old_IT_Name,'')  
            + '#' + 'IT Alias : ' + ISNULL(@Old_IT_Alias,'')  
            + '#' + 'Max Limit : ' + CONVERT(nvarchar(200),ISNULL(@Old_IT_Max_Limit,0))  
            + '#' + 'Flag : ' + CASE ISNULL(@Old_IT_Flag,'') When 'I' Then 'Increment' ELSE 'Decrement' END  
            + '#' + 'Sorting No : ' + CONVERT(nvarchar(200),ISNULL(@Old_IT_Level,0))  
            + '#' + 'IT Def ID : ' + CASE ISNULL(@Old_IT_Def_ID,0) WHEN 0 THEN 'None' WHEN 1 THEN 'House Rent' WHEN 10 THEN 'Less TDS' WHEN 11 THEN 'Medical Exemption' WHEN 151 THEN 'LTA Exemption' ELSE 'Leave Exemption' END  
            + '#' + 'IT Parent ID : ' + CONVERT(nvarchar(200),ISNULL(@Old_IT_Parent_ID,0))  
            + '#' + 'Proof Required : ' + ISNULL(@Old_IT_Doc_Req,'')  
            + '#' + 'MainGroup : ' + CASE ISNULL(@Old_IT_Main_Group,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Declaration : ' + CASE ISNULL(@Old_IT_Declaration_Req,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Active : ' + CASE ISNULL(@Old_IT_Is_Active,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Is Header : ' + CASE ISNULL(@Old_IT_Header,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'Attachment Mandatory : ' + CASE ISNULL(@Old_IT_Is_Attah_Comp,0) WHEN 0 Then 'NO' Else 'YES' END  
            + '#' + 'perquisite : ' + CASE ISNULL(@Old_IT_Is_Perquisite,0) WHEN 0 Then 'NO' Else 'YES' END                                                
            + '#' + 'AD_String : ' + ISNULL(@OLD_AD_String,'') --added by Gadriwala Muslim 20122016  
            + '#' + 'Exempt_Percent : ' + Convert(nvarchar(200),ISNULL(@OLD_Exempt_Percent,0))  
                                                
           exec P9999_Audit_Trail @Cmp_ID,@tran_type,'IT Master',@OldValue,@IT_ID,@User_Id,@IP_Address  
          -- Added for audit trail By Ali 22102013 -- End  
            
            
    Delete from T0070_IT_MASTER where IT_ID = @IT_ID   
  end   
  
  
  
 RETURN  
   
  
  