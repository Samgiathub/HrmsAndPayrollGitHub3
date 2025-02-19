  
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0020_STATE_MASTER]  
	 @STATE_ID AS NUMERIC output,  
	 @CMP_ID AS NUMERIC,  
	 @STATE_NAME AS VARCHAR(100),  
	 @tran_type varchar(1)  
	,@User_Id numeric(18,0) = 0 
    ,@IP_Address varchar(30)= ''
    ,@PT_Deduct_Type varchar(100) = 'Monthly' 
    ,@PT_Deduct_month varchar(100) = NULL 
    ,@PT_Enroll_Cert_NO Varchar(50) = NULL  
    ,@Loc_ID as numeric(18,2) = NULL  
    ,@Applicable_PT_Male_Female as numeric(18,0) = 0  
    ,@Esic_State_Code as varchar(100) = ''  
    ,@Esic_Reg_Addr as varchar(max) = ''  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
set @STATE_NAME = dbo.fnc_ReverseHTMLTags(@STATE_NAME)  
set @Esic_Reg_Addr = dbo.fnc_ReverseHTMLTags(@Esic_Reg_Addr)  

  
  
declare @OldValue as  varchar(max)  
Declare @String as varchar(max)  
set @String=''  
set @OldValue =''  
  
 If @tran_type  = 'I'  
  Begin  
    If Exists(Select State_ID From T0020_STATE_MASTER WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and upper(State_Name) = upper(@State_Name) AND Loc_ID = @Loc_ID) -- Modified by Mitesh 04/08/2011 for different collation db.  
     begin  
      set @STATE_ID = 0  
      Return        end  
      
    select @State_ID = Isnull(max(state_id),0) + 1  From T0020_STATE_MASTER WITH (NOLOCK)  
         
        
    INSERT INTO T0020_STATE_MASTER  
                          (State_ID, Cmp_ID, State_Name,Loc_ID,PT_Deduction_Type,PT_Deduction_Month,PT_Enroll_Cert_NO,Applicable_PT_Male_Female,Esic_State_Code,Esic_Reg_Addr)  
    VALUES     (@State_ID, @Cmp_ID, @State_Name,@Loc_ID,@PT_Deduct_Type,Replace(@PT_Deduct_month,'#0','#'),@PT_Enroll_Cert_NO,@Applicable_PT_Male_Female,@Esic_State_Code,@Esic_Reg_Addr)  
      
	    
  
    exec P0040_PROFESSIONAL_SETTING_statewise @State_ID,@Cmp_ID,@State_Name -- Added by rohit on 05122013  
      
	 exec P9999_Audit_get @table = 'T0020_STATE_MASTER' ,@key_column='state_id',@key_Values=@State_ID,@String=@String output  
     set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))  
       
      
  End  
 Else if @Tran_Type = 'U'  
  begin  
    If Exists(Select State_ID From T0020_STATE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(State_Name) = upper(@State_Name) AND Loc_ID = @Loc_ID  and State_ID <> @State_ID) -- Modified by Mitesh 04/08/2011 for different collation db.  
     begin  
      set @STATE_ID = 0  
      Return   
     end  
     ----Add By PAras 12-10-20102  
     --         select @OldStateName  =ISNULL(State_ID,'')  From dbo.T0020_STATE_MASTER Where Cmp_ID = @Cmp_ID and State_ID = @STATE_ID  
       
         exec P9999_Audit_get @table='T0020_STATE_MASTER' ,@key_column='state_id',@key_Values=@state_id,@String=@String output  
    set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
         
                
    Update T0020_STATE_MASTER  
    set STate_Name = @State_Name,Loc_ID=@Loc_ID,  
        PT_Deduction_Type = @PT_Deduct_Type,  
        PT_Deduction_Month = Replace(@PT_Deduct_month,'#0','#'),  
        PT_Enroll_Cert_NO = @PT_Enroll_Cert_NO,  
        Applicable_PT_Male_Female = @Applicable_PT_Male_Female  
        ,Esic_State_Code =@Esic_State_Code   
        ,Esic_Reg_Addr =@Esic_Reg_Addr   
    where State_ID = @State_ID  
      
          
     --set @OldValue = 'old Value' + '#'+ 'State Name :' + @OldStateName  + '#'   
     --          + 'New Value' + '#'+ 'State Name :' +ISNULL( @STATE_NAME,'') + '#'   
  
     exec P9999_Audit_get @table = 'T0020_STATE_MASTER' ,@key_column='state_id',@key_Values=@State_ID,@String=@String output  
     set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))  
       
      
    ----------  
  end  
 Else if @Tran_Type = 'D'  
  begin  
   --Add By PAras 12-10-20102  
   --select @OldStateName = State_Name  From dbo.T0020_STATE_MASTER Where  State_ID = @STATE_ID  
     
   exec P9999_Audit_get @table='T0020_STATE_MASTER' ,@key_column='state_id',@key_Values=@state_id,@String=@String output  
   set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
         
		 --Added by ronakk 18022022
		  if Exists(select Dist_ID  from T0030_DISTRICT_MASTER where Cmp_ID=@CMP_ID and State_ID=@State_ID)  
		begin  
		set @State_ID = 0  
      --RAISERROR('@@ Reference Esits @@',16,2)  
		RETURN   
		end  
   
    Delete From T0020_STATE_MASTER Where State_ID = @State_ID  
      
    --set @OldValue = 'old Value' + '#'+ 'State Name :' + @OldStateName  + '#'   
  end  
    
    
   exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'State Master',@OldValue,@STATE_ID,@User_Id,@IP_Address  
   -------  
     
   -- ended by rohit on 28032016  
  
 RETURN  