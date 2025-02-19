  
  
  
-- ============================================================  
-- Author:  <Hiral>  
-- ALTER date: <18 July,2013>  
-- Description: <To Add, Update And Delete Scheme Master Data>  
-- ============================================================  
CREATE PROCEDURE [dbo].[P0040_Scheme_Master]  
  @Scheme_Id  Numeric(18,0) Output  
 ,@Cmp_Id  Numeric(18,0)  
 ,@Scheme_Name Varchar(100)  
 ,@Scheme_Type Varchar(50)  
 ,@User_Id numeric(18,0) = 0   
    ,@IP_Address varchar(30)= ''  --Added by Sumit for Audit Trail 05/08/2016  
 ,@Tran_Type  Varchar(1)  
 ,@Default_Scheme bit = 0 --Added By Jimit 02052019  
AS  
  
        SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
  
BEGIN  
   
 declare @OldValue as  varchar(max)  
 Declare @String as varchar(max)  
 set @String=''  
 set @OldValue =''  
   
   set @Scheme_Name = dbo.fnc_ReverseHTMLTags(@Scheme_Name)  --added by Ronak 251021
 If @Tran_Type = 'I'  
  Begin  
   If Exists (Select Scheme_Id From T0040_Scheme_Master WITH (NOLOCK) Where Scheme_Name = @Scheme_Name AND Cmp_Id = @Cmp_Id)  
    Begin  
     Raiserror('@@Scheme Already Exists@@',16,2)  
     return -1  
    End  
  
      
   --Added By Jimit 02052019  
   IF EXISTS(SELECT 1 FROM T0040_SCHEME_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND SCHEME_TYPE = @SCHEME_TYPE AND DEFAULT_SCHEME = 1) ANd  
      @Default_Scheme = 1  
     BEGIN  
      print 1  
      UPDATE T0040_SCHEME_MASTER  
      SET  DEFAULT_SCHEME = 0  
      WHERE CMP_ID = @CMP_ID AND SCHEME_TYPE = @SCHEME_TYPE   
        AND DEFAULT_SCHEME = 1  
     END  
   --Ended  
  
   Select @Scheme_Id = Isnull(Max(Scheme_Id),0)+ 1  From dbo.T0040_Scheme_Master WITH (NOLOCK)  
   Insert Into T0040_Scheme_Master(Scheme_Id, Cmp_Id, Scheme_Name, Scheme_Type,Default_Scheme)  
    Values(@Scheme_Id, @Cmp_Id, @Scheme_Name, @Scheme_Type,@Default_Scheme)  
      
   exec P9999_Audit_get @table = 'T0040_Scheme_Master' ,@key_column='Scheme_Id',@key_Values=@Scheme_Id,@String=@String output  
   set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))   
  End  
 If @Tran_Type = 'U'  
  Begin  
   If Exists (Select Scheme_Id From T0040_Scheme_Master WITH (NOLOCK) Where Scheme_Name = @Scheme_Name And Scheme_Id <> @Scheme_Id AND Cmp_Id = @Cmp_Id)  
    Begin  
     Raiserror('@@Scheme Name Already Exists@@',16,2)  
     return -1  
    End  
    exec P9999_Audit_get @table='T0040_Scheme_Master' ,@key_column='Scheme_ID',@key_Values=@Scheme_Id,@String=@String output  
    set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))   
     
  
   --Added By Jimit 02052019  
   IF EXISTS(SELECT 1 FROM T0040_SCHEME_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND SCHEME_TYPE = @SCHEME_TYPE AND DEFAULT_SCHEME = 1) ANd  
      @Default_Scheme = 1  
     BEGIN  
      print 1  
      UPDATE T0040_SCHEME_MASTER  
      SET  DEFAULT_SCHEME = 0  
      WHERE CMP_ID = @CMP_ID AND SCHEME_TYPE = @SCHEME_TYPE   
        AND DEFAULT_SCHEME = 1  
     END  
   --Ended  
  
  
   Update T0040_Scheme_Master   
    Set Scheme_Name = @Scheme_Name,  
     Scheme_Type = @Scheme_Type,  
     Default_Scheme= @Default_Scheme  
    Where Scheme_Id = @Scheme_Id  
      
    exec P9999_Audit_get @table='T0040_Scheme_Master' ,@key_column='Scheme_ID',@key_Values=@Scheme_Id,@String=@String output  
    set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))    
  End  
 Else If @Tran_Type = 'D'  
  Begin  
   exec P9999_Audit_get @table='T0040_Scheme_Master' ,@key_column='Scheme_ID',@key_Values=@Scheme_Id,@String=@String output  
   set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
    
   Delete From T0040_Scheme_Master Where Scheme_Id = @Scheme_Id  
  End  
  exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Scheme Master',@OldValue,@Scheme_Id,@User_Id,@IP_Address  
   
END  
  
  