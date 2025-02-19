   
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
Create PROCEDURE [dbo].[P0040_BANK_MASTER_Backup_Manisha_03012025]    
  @Bank_ID  numeric output    
 ,@Cmp_Id numeric(18,0)    
 ,@Bank_Code  varchar(10)    
 ,@Bank_Name varchar(100)    
 ,@Bank_Ac_No varchar(30)    
 ,@Bank_Address varchar(250)    
 ,@Bank_Branch_Name varchar(50)    
 ,@Bank_City varchar(50)    
 ,@Is_Default varchar(1)    
 ,@tran_type varchar(1)    
 ,@Bank_BSR_Code varchar(50)    
 ,@User_Id numeric(18,0) = 0    
 ,@IP_Address varchar(30)= '' 
 ,@GUID varchar(2000) = '' 
 ,@Company_Branch numeric(18,0) =0  
 ,@Tran_Id numeric(18,0)=0 --Add by Manisha on 03012025
  ,@Branch_Id numeric(18,0)=0 --Add by Manisha on 03012025
   ,@Account_No numeric(18,0)=0 --Add by Manisha on 03012025
    ,@Effective_Date datetime --Add by Manisha on 03012025
	 ,@System_Date datetime --Add by Manisha on 03012025
AS    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
-- Add By Paras 17-10-2012    
declare @OldValue as  varchar(max)    
declare @OldBank_Code  as varchar(10)    
declare @OldBank_Name as varchar(100)    
declare @OldBank_Ac_No as varchar(30)    
declare  @OldBank_Address  as varchar(50)    
declare  @OldBank_Branch_Name as  varchar(50)    
declare  @OldBank_City as  varchar(50)    
declare  @OldIs_Default as  Varchar(1)    
declare  @OldBank_BSR_Code  as varchar(50)     
 declare @OldCompany_Branch As numeric(18,0)
set @OldValue = ' '    
set @OldBank_Code  = ' '    
set @OldBank_Name = ' '    
set @OldBank_Ac_No = ''    
set  @OldBank_Address  = ''    
set  @OldBank_Branch_Name =  ''    
set  @OldBank_City =  ''    
set  @OldIs_Default =  ''    
set  @OldBank_BSR_Code  = ''    
set  @OldCompany_Branch=0
----    
    
       set @Bank_Name = dbo.fnc_ReverseHTMLTags(@Bank_Name)  --added by mansi 061021    
	   set @Bank_Code = dbo.fnc_ReverseHTMLTags(@Bank_Code)  --added by mansi 061021  
	   set @Bank_Address = dbo.fnc_ReverseHTMLTags(@Bank_Address)  --added by mansi 061021  
	    set @Bank_Branch_Name = dbo.fnc_ReverseHTMLTags(@Bank_Branch_Name)  --added by mansi 061021  
		 set @Bank_City = dbo.fnc_ReverseHTMLTags(@Bank_City)  --added by mansi 061021  
    
 If @tran_type  = 'I' Or @tran_type = 'U'    
 BEGIN    
 
  If @Bank_Name = ''    
   BEGIN    
    Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Bank Name is not Properly Inserted',0,'Enter Proper Bank Name',GetDate(),'Bank Master',@GUID)          
    set @Bank_ID = 0    
    Return    
   END    
      
  If @Bank_Code = ''    
   BEGIN    
    Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Bank Code is not Properly Inserted (' + @Bank_Name + ')',0,'Enter Proper Bank Code',GetDate(),'Bank Master',@GUID)          
    set @Bank_ID = 0    
    Return    
   END    
     
  If @Bank_Branch_Name = ''    
   BEGIN    
    Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Bank Branch Name is not Properly Inserted',0,'Enter Proper Bank Branch Name (' + @Bank_Name + ')',GetDate(),'Bank Master',@GUID)          
    set @Bank_ID = 0    
    Return    
   END    
      
  If @Bank_Ac_No = ''    
   BEGIN    
    Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Bank Account Number is not Properly Inserted',0,'Enter Proper Bank Account No.(' + @Bank_Name + ')',GetDate(),'Bank Master',@GUID)          
    set @Bank_ID = 0    
    Return    
   END    
 END    
     
 If @tran_type  = 'I'     
  Begin    
  
    If Exists(select Bank_ID From T0040_BANK_MASTER WITH (NOLOCK) Where cmp_ID = @Cmp_ID and    
         upper(Bank_Name) = upper(@Bank_Name) 
		 --and upper(Bank_Branch_Name) = upper(@Bank_Branch_Name) 
		 and  Company_Branch = @Company_Branch )    
     Begin 
      Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Same Bank Name & Bank Branch Name is already exists.enter correct details',0,'Same Bank Name & Bank Branch Name is already exists.(Bank Name : ' + @Bank_Name + ')',GetDate(),'Bank Master',@GUID) 
      set @Bank_ID = 0    
      Return     
     end    
         
    --If Exists(select Bank_ID From T0040_BANK_MASTER  Where cmp_ID = @Cmp_ID and    
    --     upper(Bank_Name) = upper(@Bank_Name) and upper(Bank_Code) = upper(@Bank_Code) )    
    -- Begin    
    --  Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Same Bank Name & Bank Code is already exists.enter correct details',0,'Same Bank Name & Bank Code is already exists.enter correct details(Bank Name : ' + @Bank_Name + ')',GetDate(),'Bank Master',@GUID)          
    --  set @Bank_ID = 0    
    --  Return     
    -- end    
     
    select @Bank_ID = Isnull(max(Bank_ID),0) + 1 From T0040_BANK_MASTER WITH (NOLOCK)    
        
    INSERT INTO T0040_BANK_MASTER    
                          (    
            Bank_ID      
           ,Cmp_Id     
           ,Bank_Code     
           ,Bank_Name     
           ,Bank_Ac_No    
           ,Bank_Address     
              ,Bank_Branch_Name     
              ,Bank_City     
              ,Is_Default,    
              Bank_BSR_Code 
			  ,Company_Branch
                          )    
        VALUES         
        (    
               @Bank_ID      
           ,@Cmp_Id     
           ,@Bank_Code     
           ,@Bank_Name    
           ,@Bank_Ac_No     
           ,@Bank_Address     
              ,@Bank_Branch_Name     
              ,@Bank_City    
              ,@Is_Default    
              ,@Bank_BSR_Code    
			  ,@Company_Branch
        )    
            
        -- Add By Paras 17-10-2012    
            
        set @OldValue = 'New Value' + '#'+ 'Bank Code :' +ISNULL(@Bank_Code,'') + '#' + 'Bank Name :' + ISNULL( @Bank_Name,'') + '#' + 'Bank Ac No :' + ISNULL(@Bank_Ac_No,'')  + '#' + 'Bank Address :' +ISNULL(@Bank_Address,'') + '#' + 'Bank Branch Name :'
  
 +ISNULL( @Bank_Branch_Name,'') + ' #'+ 'Bank City :' +ISNULL(@Bank_City,'') + ' #'+ 'Is Default :' + ISNULL(@Is_Default,'') + ' #'+ 'Bank Bca Code :' + ISNULL(@Bank_BSR_Code,'')  + ' #'            
        ------    
            
     If @Is_Default = 'Y'     
      Begin    
        UPDATE    T0040_BANK_MASTER    
        SET       Is_Default = 'N'    
        WHERE     Bank_ID <> @Bank_ID and Cmp_ID = @Cmp_ID     
      End          
  End    
 Else if @Tran_Type = 'U'     
  begin    
    
    If Exists(select Bank_ID From T0040_BANK_MASTER WITH (NOLOCK) Where cmp_ID = @Cmp_ID and Bank_ID <> @Bank_ID and    
         upper(Bank_Name) = upper(@Bank_Name) and upper(Bank_Branch_Name) = upper(@Bank_Branch_Name)  and  upper(Company_Branch) = upper(@Company_Branch) )    
     Begin    
      set @Bank_ID = 0    
      Return     
     end    
         
     select @OldBank_Code  =ISNULL(Bank_Code,'') ,@OldBank_Name  =ISNULL(Bank_Name,''),@OldBank_Ac_No  =isnull(Bank_Ac_No,''),@OldBank_Address  =isnull(Bank_Address,''),@OldBank_Branch_Name =isnull(Bank_Branch_Name,''),@OldBank_City  =isnull(Bank_City,'')
  
,@OldIs_Default  = isnull(Is_Default,''),@OldBank_BSR_Code  =isnull(Bank_BSR_Code ,'') From dbo.T0040_BANK_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Bank_ID = @Bank_ID    
    
    Update T0040_BANK_MASTER    
    set     
      Bank_Code = @Bank_Code    
      ,Bank_Name = @Bank_Name    
      ,Bank_Ac_No = @Bank_Ac_No    
      ,Bank_Address = @Bank_Address    
         ,Bank_Branch_Name = @Bank_Branch_Name    
         ,Bank_City = @Bank_City    
         ,Is_Default = @Is_Default    
         ,Bank_BSR_Code =@Bank_BSR_Code  
		 ,Company_Branch=@Company_Branch
    where Bank_ID  = @Bank_ID    
        
    set @OldValue = 'old Value' + '#'+ 'Bank Code :' +ISNULL(@OldBank_Code,'') + '#' + 'Bank Name :' + ISNULL( @OldBank_Name,'') + '#' + 'Bank Ac No :' + ISNULL(@OldBank_Ac_No,'')  + '#' + 'Bank Address :' +ISNULL(@OldBank_Address,'') + '#' + 'Bank Branch
  
 Name :' +ISNULL( @OldBank_Branch_Name,'') + ' #'+ 'Bank City :' +ISNULL(@OldBank_City,'') + ' #'+ 'Is Default :' + ISNULL(@OldIs_Default,'') + ' #'+ 'Bank Bca Code :' + ISNULL(@OldBank_BSR_Code,'')  + ' #'+    
                              + 'New Value' + '#'+ 'Bank Code :' +ISNULL(@Bank_Code,'') + '#' + 'Bank Name :' + ISNULL( @Bank_Name,'') + '#' + 'Bank Ac No :' + ISNULL(@Bank_Ac_No,'')  + '#' + 'Bank Address :' +ISNULL(@Bank_Address,'') + '#' + 'Bank Branch
  
 Name :' +ISNULL( @Bank_Branch_Name,'') + ' #'+ 'Bank City :' +ISNULL(@Bank_City,'') + ' #'+ 'Is Default :' + ISNULL(@Is_Default,'') + ' #'+ 'Bank Bca Code :' + ISNULL(@Bank_BSR_Code,'')  + ' #'    
      
    
   If @Is_Default = 'Y'     
    Begin    
     UPDATE    T0040_BANK_MASTER    
     SET              Is_Default = 'N'    
     WHERE     Bank_ID <> @Bank_ID and Cmp_ID  = @Cmp_ID    
    End      
  end    
 Else if @Tran_Type = 'D'     
  begin    
      
   if Exists(select 1 from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Bank_ID = @Bank_ID)    
    begin    
     RAISERROR('@@ Reference Esits @@',16,2)    
     RETURN    
    END    
   else if exists (Select 1 From T0095_INCREMENT WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Bank_ID = @Bank_ID)    
     BEGIN    
      RAISERROR('@@ Reference Esits @@',16,2)    
      RETURN    
     END    
   ELSE    
    BEGIN    
     select @OldBank_Code  =ISNULL(Bank_Code,'') ,@OldBank_Name  =ISNULL(Bank_Name,''),@OldBank_Ac_No  =isnull(Bank_Ac_No,''),@OldBank_Address  =isnull(Bank_Address,''),@OldBank_Branch_Name =isnull(Bank_Branch_Name,''),@OldBank_City  =isnull(Bank_City,''
)  
,@OldIs_Default  = isnull(Is_Default,''),@OldBank_BSR_Code  =isnull(Bank_BSR_Code ,'') From dbo.T0040_BANK_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Bank_ID = @Bank_ID    
     Delete From T0040_BANK_MASTER Where Bank_ID  = @Bank_ID    
     set @OldValue = 'Old Value' + '#'+ 'Bank Code :' +ISNULL(@OldBank_Code,'') + '#' + 'Bank Name :' + ISNULL( @OldBank_Name,'') + '#' + 'Bank Ac No :' + ISNULL(@OldBank_Ac_No,'')  + '#' + 'Bank Address :' +ISNULL(@OldBank_Address,'') + '#' + 'Bank Branch Name :' +ISNULL( @OldBank_Branch_Name,'') + ' #'+ 'Bank City :' +ISNULL(@OldBank_City,'') + ' #'+ 'Is Default :' + ISNULL(@OldIs_Default,'') + ' #'+ 'Bank Bca Code :' + ISNULL(@OldBank_BSR_Code,'')       
    END    
      
      
  end    
       exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Bank Master',@OldValue,@Bank_ID,@User_Id,@IP_Address    
    
 RETURN    
    
    
    