



CREATE PROCEDURE [dbo].[P0040_Late_Extra_Amount]   
 @Late_Amt_ID  numeric output ,  
 @Cmp_ID  numeric,  
 @Allowance_ID numeric,  
 @From_Days  numeric(3,1),  
 @To_days numeric(3,1),  
 @Calcuate_On varchar(50),  
 @Late_mode   varchar(50),  
 @Limit  numeric(5,1),  
 @Tran_Type  char(1)
 ,@User_Id numeric(18,0) = 0
 ,@IP_Address varchar(30)= '' --Add By Paras 19-10-2012  
AS 

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

declare @OldValue as varchar(max)
declare @OldFrom_Days as varchar(5)
declare @OldTo_days as varchar(5)
declare @OldCalcuate_On as varchar(50)
declare @OldLate_mode as varchar(50)
declare @OldLimit as varchar(5)

set @OldFrom_Days = ''
set @OldTo_days = ''
set @OldCalcuate_On = ''
set @OldLate_mode = ''
set @OldLimit = ''


   
   
    
  if @Tran_Type ='I'   
    
  Begin   
  -- if exists(Select Branch_ID from T0040_weekoff_Master where BRanch_ID=@BRanch_ID and cmp_ID=@Cmp_ID)  
   --  Begin   
   --  raiserror('@@Already Exits@@',16,2)  
   -- return  
   --  End  
     
       
    select @Late_Amt_ID = isnull(max(Late_Amt_ID),0) +1 from T0040_late_Extra_Amount WITH (NOLOCK)    
    INSERT INTO T0040_late_Extra_Amount  
                          (Late_Amt_ID, Cmp_ID,  Allowance_ID, From_Days, To_days, Limit,Calculate_On,Late_mode)  
    Values(@Late_Amt_ID, @Cmp_ID,  @Allowance_ID, @From_Days, @To_days, @Limit,@Calcuate_On,@Late_mode)  
      
      set @OldValue = 'New Value' + '#'+ 'From Days :' +CAST(ISNULL(@From_Days,0)as varchar(5)) + '#' + 'To days :' +CAST(ISNULL(@To_days,0)as varchar(5)) + '#' + 'Calcuate On :' + ISNULL(@Calcuate_On,'')  + '#' + 'Late mode :' +ISNULL( @Late_mode,'') + '#' + 'Limit :' +CAST(ISNULL( @Limit,0)AS VARCHAR(10)) 
      
      
  end  
  else if @Tran_Type ='U'  
  begin  
  
  select @OldFrom_Days  =Cast(Isnull(From_Days,0)as varchar(10)) ,@OldTo_days  =CAST( ISNULL(To_days,'')as varchar(10)),@OldCalcuate_On  =isnull(Calculate_On,''),@OldLate_mode  = isnull(Late_mode,''),@OldLimit =CAST(isnull(Limit,0)as varchar(10)) From dbo.T0040_late_Extra_Amount WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and Late_Amt_ID = @Late_Amt_ID
  
    Update T0040_late_Extra_Amount  
     
     set   
    Late_Amt_ID = @Late_Amt_ID,   
    Allowance_ID = @Allowance_ID ,  
    From_Days =@From_Days,   
    To_days=@To_days,  
    Calculate_On=@Calcuate_On,  
    Late_mode=@Late_mode,  
    Limit=@Limit  
    
    where Late_Amt_ID =@Late_Amt_ID   
    
    set @OldValue = 'old Value' + '#'+ 'From Days :' +CAST(ISNULL(@OldFrom_Days,0)as varchar(5)) + '#' + 'To days :' +CAST(ISNULL(@OldTo_days,0)as varchar(5)) + '#' + 'Calcuate On :' + ISNULL(@OldCalcuate_On,'')  + '#' + 'Late mode :' +ISNULL( @OldLate_mode,'') + '#' + 'Limit :' +CAST(ISNULL( @OldLimit,0)AS VARCHAR(10)) 
               + 'New Value' + '#'+ 'From Days :' +CAST(ISNULL(@From_Days,0)as varchar(5)) + '#' + 'To days :' +CAST(ISNULL(@To_days,0)as varchar(5)) + '#' + 'Calcuate On :' + ISNULL(@Calcuate_On,'')  + '#' + 'Late mode :' +ISNULL( @Late_mode,'') + '#' + 'Limit :' +CAST(ISNULL( @Limit,0)AS VARCHAR(10)) 
  
  end  
    
   else if @Tran_Type='D'  
     
     Begin  
     select @OldFrom_Days  =Cast(Isnull(From_Days,0)as varchar(10)) ,@OldTo_days  =CAST( ISNULL(To_days,'')as varchar(10)),@OldCalcuate_On  =isnull(Calculate_On,''),@OldLate_mode  = isnull(Late_mode,''),@OldLimit =CAST(isnull(Limit,0)as varchar(10)) From dbo.T0040_late_Extra_Amount WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and Late_Amt_ID = @Late_Amt_ID
       Delete from T0040_Late_Extra_Amount where Late_Amt_ID=@Late_Amt_ID  
       
       set @OldValue = 'old Value' + '#'+ 'From Days :' +CAST(ISNULL(@OldFrom_Days,0)as varchar(5)) + '#' + 'To days :' +CAST(ISNULL(@OldTo_days,0)as varchar(5)) + '#' + 'Calcuate On :' + ISNULL(@OldCalcuate_On,'')  + '#' + 'Late mode :' +ISNULL( @OldLate_mode,'') + '#' + 'Limit :' +CAST(ISNULL( @OldLimit,0)AS VARCHAR(10)) 
        
     End  
   exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Present Late Scenario',@OldValue,@Late_Amt_ID,@User_Id,@IP_Address
   
 RETURN  
  



