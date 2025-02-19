  
  
CREATE PROCEDURE [dbo].[P0301_Process_Type_Master]   
  @Process_Type_Id   Numeric(9) output  
 ,@Cmp_ID   Numeric(9)  
 ,@Process_Type  varchar(max)  
 ,@Sort_Id  Numeric(9)  
 ,@Ad_Id_Multi varchar(Max)  
 ,@Ad_Name_Multi   varchar(max)  
 ,@tran_type   varchar(1)  
 ,@User_Id numeric(18,0)= 0   
    ,@IP_Address varchar(max)= ''  
    ,@Loan_Id_Multi varchar(Max)=''  
 ,@Loan_Name_Multi   varchar(max)=''  
 ,@Leave_Id_Multi varchar(Max)=''  
 ,@Leave_Name_Multi   varchar(max)=''  
AS  
SET NOCOUNT ON;  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
SET ARITHABORT ON;  
  
--declare @OldValue as  varchar(max)  
--declare @OldProcess_Type_Id as varchar(Max)  
--declare @OldProcess_Type as varchar(max)  
--declare @OldAd_Id_Multi varchar(Max)  
--declare @oldSort_Id  varchar(max)  
--declare @OldAd_Name_Multi   varchar(max)  
  
  
-- set @OldValue = ''  
--set @OldProcess_Type_Id =''  
--set @OldProcess_Type =''  
--set @OldAd_Id_Multi =''  
--set @oldSort_Id =''  
--set @OldAd_Name_Multi=''  
  
            
-- if @Process_Type ='Allowance'  
-- begin  
    
--  Raiserror('@@Process name Allowance not Allowed@@',16,2)  
--  return -1  
    
-- end  
   
-- if @Ad_Id_Multi = '' and (@tran_type  = 'I' or @Tran_Type = 'U')  
-- begin  
--  Raiserror('@@Please select atleast one Allowance@@',16,2)  
--  return -1  
   
-- end  
    
    
-- If @tran_type  = 'I'   
--  Begin  
     
--   If Exists(select Process_Type_id From T0301_Process_Type_Master  Where Cmp_ID = @Cmp_ID and upper(Process_Type) = upper(@Process_Type))   
--    begin  
--     set @Process_Type_id = 0  
--     return   
--    end  
     
--   --select @Process_Type_id = Isnull(max(Process_Type_Id),0) + 1  From T0301_Process_Type_Master   
     
--   INSERT INTO T0301_Process_Type_Master  
--           (  
        
--      Process_Type  
--      ,Ad_Id_Multi  
--      ,modify_Date  
--      ,Cmp_id  
--      ,Sort_Id  
--      ,Ad_Name_Multi  
        
--           )  
--    VALUES       
--     (     
--       @Process_Type  
--      ,@Ad_Id_Multi  
--      ,GETDATE()  
--      ,@Cmp_id  
--      ,@Sort_Id  
--      ,@Ad_Name_Multi  
--     )    
       
     
--   select @Process_Type_id = Isnull(max(Process_Type_Id),0) From T0301_Process_Type_Master   
     
--    set @OldValue = 'New Value' + '#'+ 'Process Name :' +ISNULL( @Process_Type,'') + '#' + '@ad_name :' + ISNULL( @Ad_Name_Multi,'') + '#' + 'sort_id :' + CAST(ISNULL(@Sort_Id,0) AS VARCHAR(20)) + '#'    
      
--  End  
-- Else if @Tran_Type = 'U'  
--   begin  
--   If Exists(select Process_Type_Id From T0301_Process_Type_Master  Where Cmp_ID = @Cmp_ID and upper(Process_Type) = upper(@Process_Type)  
--           and Process_Type_Id <> @Process_Type_Id)  
--    begin  
--     set @Process_Type_Id = 0  
--     return   
--    end  
--    --Add By Paras 12-10-2012  
--      select @OldProcess_Type  =ISNULL(Process_Type,'') ,@OldAd_Name_Multi  =ISNULL(ad_name_multi,''),@oldSort_Id  =isnull(sort_id,0)  
--      From dbo.T0301_Process_Type_Master Where Cmp_ID = @Cmp_ID and Process_Type_Id = @Process_Type_id  
--      ---  
--    UPDATE    T0301_Process_Type_Master  
--    SET                
--     Process_Type = @Process_Type,  
--     modify_Date= GETDATE(),  
--     sort_id=@Sort_id,  
--     Ad_Id_Multi = @Ad_Id_Multi,  
--     Ad_name_multi = @Ad_Name_Multi  
       
--    where Process_Type_Id = @Process_Type_Id  
--    ----Add By Paras 12-10-2012  
--    set @OldValue = 'old Value' + '#'+ 'Process Name :' + @OldProcess_Type  + '#' + 'Ad name :' + @OldAd_Name_Multi  + '#' + 'sort id :' + CAST(ISNULL(@Sort_Id,0) AS VARCHAR(20))  + '#'  
--                + 'New Value' + '#'+ 'Process Name :' +ISNULL( @Process_Type,'') + '#' + 'Ad name :' + ISNULL( @Ad_Name_Multi,'') + '#' + 'sort id :' + CAST(ISNULL(@Sort_Id,0) AS VARCHAR(20)) + '#'    
                  
--                ------  
--  end  
-- Else If @Tran_Type = 'D'  
--  begin  
--       --Add By Paras 12-10-2012  
--      select @OldProcess_Type  =ISNULL(Process_Type,'') ,@OldAd_Name_Multi  =ISNULL(ad_name_multi,''),@oldSort_Id  =isnull(sort_id,0)  
--    From dbo.T0301_Process_Type_Master Where Cmp_ID = @Cmp_ID and Process_Type_Id = @Process_Type_id    
         
--      set @OldValue = 'old Value' + '#'+ 'Process Name :' + @OldProcess_Type  + '#' + 'Ad name :' + @OldAd_Name_Multi  + '#' + 'sort id :' + CAST(ISNULL(@Sort_Id,0) AS VARCHAR(20))  + '#'  
--       -----  
    
--    if not exists(select Process_Type from MONTHLY_EMP_BANK_PAYMENT where Process_Type_Id = @Process_Type_Id)  
--    begin  
--     Delete From T0301_Process_Type_Master Where Process_Type_Id = @Process_Type_Id  
--    end  
--   else  
--    begin  
--     set @Process_Type_id = 0  
--     return   
--    end   
--  --Added By Mukti 21012015(end)  
--  end  
--       exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Process Type Master',@OldValue,@Process_Type_Id,@User_Id,@IP_Address  
   
-- RETURN  
   set @Process_Type = dbo.fnc_ReverseHTMLTags(@Process_Type) --Ronak_060121  
declare @OldValue as  varchar(max)  
Declare @String as varchar(max)  
set @String=''  
set @OldValue =''  
            
 if @Process_Type ='Allowance'  
 begin  
    
  Raiserror('@@Process name Allowance not Allowed@@',16,2)  
  return -1  
    
 end  
   
 if @Ad_Id_Multi = '' and @Loan_Id_Multi = '' and @Leave_Id_Multi = '' and (@tran_type  = 'I' or @Tran_Type = 'U')  
 begin  
  Raiserror('@@Please select atleast one Allowance/Loan/Leave @@',16,2)  
  return -1  
   
 end  
    
    
 If @tran_type  = 'I'   
  Begin  
     
   If Exists(select Process_Type_id From T0301_Process_Type_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Process_Type) = upper(@Process_Type))   
    begin  
     set @Process_Type_id = 0  
     return   
    end  
   
   INSERT INTO T0301_Process_Type_Master  
           (  
        
      Process_Type  
      ,Ad_Id_Multi  
      ,modify_Date  
      ,Cmp_id  
      ,Sort_Id  
      ,Ad_Name_Multi  
      ,Loan_Id_Multi  
      ,Loan_Name_Multi  
      ,Leave_Id_Multi  
      ,Leave_Name_Multi  
           )  
    VALUES       
     (     
       @Process_Type  
      ,@Ad_Id_Multi  
      ,GETDATE()  
      ,@Cmp_id  
      ,@Sort_Id  
      ,@Ad_Name_Multi  
      ,@Loan_Id_Multi  
      ,@Loan_Name_Multi  
      ,@Leave_Id_Multi  
      ,@Leave_Name_Multi  
     )    
       
     
   select @Process_Type_id = Isnull(max(Process_Type_Id),0) From T0301_Process_Type_Master WITH (NOLOCK)   
     
     exec P9999_Audit_get @table = 'T0301_Process_Type_Master' ,@key_column='Process_Type_Id',@key_Values=@Process_Type_Id,@String=@String output  
     set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))  
      
  End  
 Else if @Tran_Type = 'U'  
   begin  
   If Exists(select Process_Type_Id From T0301_Process_Type_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Process_Type) = upper(@Process_Type)  
           and Process_Type_Id <> @Process_Type_Id)  
    begin  
     set @Process_Type_Id = 0  
     return   
    end  
    
       exec P9999_Audit_get @table='T0301_Process_Type_Master' ,@key_column='Process_Type_Id',@key_Values=@Process_Type_Id,@String=@String output  
    set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
      
    UPDATE    T0301_Process_Type_Master  
    SET                
     Process_Type = @Process_Type,  
     modify_Date= GETDATE(),  
     sort_id=@Sort_id,  
     Ad_Id_Multi = @Ad_Id_Multi,  
     Ad_name_multi = @Ad_Name_Multi  
     ,Loan_Id_Multi = @Loan_Id_Multi  
     ,Loan_Name_Multi= @Loan_Name_Multi  
     ,Leave_Id_Multi = @Leave_Id_Multi  
     ,Leave_Name_Multi = @Leave_Name_Multi  
       
    where Process_Type_Id = @Process_Type_Id  
     
                exec P9999_Audit_get @table = 'T0301_Process_Type_Master' ,@key_column='Process_Type_Id',@key_Values=@Process_Type_Id,@String=@String output  
    set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))  
                  
  end  
 Else If @Tran_Type = 'D'  
  begin  
      exec P9999_Audit_get @table='T0301_Process_Type_Master' ,@key_column='Process_Type_Id',@key_Values=@Process_Type_Id,@String=@String output  
    set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
         
    
    if not exists(select Process_Type from MONTHLY_EMP_BANK_PAYMENT WITH (NOLOCK) where Process_Type_Id = @Process_Type_Id)  
    begin  
     Delete From T0301_Process_Type_Master Where Process_Type_Id = @Process_Type_Id  
    end  
   else  
    begin  
     set @Process_Type_id = 0  
     return   
    end   
    
  end  
       exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Process Type Master',@OldValue,@Process_Type_Id,@User_Id,@IP_Address  
   
 RETURN  
   
  
  
  