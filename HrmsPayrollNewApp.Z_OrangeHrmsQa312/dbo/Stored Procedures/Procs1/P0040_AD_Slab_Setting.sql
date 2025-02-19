
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_AD_Slab_Setting]   
     @Tran_ID       numeric output ,  
     @Cmp_ID        numeric,  
     @AD_ID         numeric,  
     @From_Slab     numeric(18,2),  
     @To_Slab       numeric(18,0),  
     @Calc_Type varchar(100),   
     @Amount        numeric(18,2),  
     @Sal_Calc_Type numeric(18,0),
     @Tran_Type     char(1) 
    ,@User_Id numeric(18,0) = 0
    ,@IP_Address varchar(30)= '' --Add By Paras 19-10-2012
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    -- Add By PAras 19-10-2012
    declare @OldValue as varchar(max)
    declare @OldFrom_Slab as varchar(18)
    declare @OldTo_Slab as varchar(18)
    declare @OldCalc_Type as varchar(100)
    declare @OldAmount as varchar(20)
    declare @OldSal_Calc_Type as numeric(18,0)
    set @OldFrom_Slab = ''
    set @OldTo_Slab = ''
    set @OldCalc_Type = ''
    set @OldAmount = ''
    set @OldSal_Calc_Type = 0
    ----
      
     SET NOCOUNT ON   
      
                
     if exists(Select Tran_Id from T0040_AD_Slab_Setting WITH (NOLOCK) where Cmp_Id=@Cmp_ID and AD_Id=@AD_ID)
     begin 
        declare @cal_on varchar(100)
        Select @cal_on = Calc_Type from T0040_AD_Slab_Setting WITH (NOLOCK) where Cmp_Id=@Cmp_ID and AD_Id=@AD_ID
        
        
        if @cal_on <> @Calc_Type
            Begin               
                set @cal_on = '@@Slab for this allowance already exist for Calculate On '  + @cal_on + '@@'
                RAISERROR (@cal_on , 16, 2) 
                Return
            End
     end 
     
     if exists(Select Tran_Id from T0040_AD_Slab_Setting WITH (NOLOCK) where Cmp_Id=@Cmp_ID and AD_Id=@AD_ID and Calc_Type=@Calc_Type and Sal_Calc_Type = @Sal_Calc_Type and
                    ( (@From_Slab >= From_Slab and @From_Slab <= To_Slab) or 
                                (@To_Slab >= From_Slab and  @To_Slab <= To_Slab) or 
                                (From_Slab >= @From_Slab and From_Slab <= @To_Slab) or
                                (To_Slab >= @From_Slab and To_Slab <= @To_Slab))) 
                Begin               
                    RAISERROR ('@@Same Slab already exist@@' , 16, 2) 
                    Return
                End

             if exists(Select Tran_Id from T0040_AD_Slab_Setting WITH (NOLOCK) where Cmp_Id=@Cmp_ID and AD_Id=@AD_ID and Calc_Type=@Calc_Type and
                    ( (@From_Slab >= From_Slab and @From_Slab <= To_Slab) or 
                                (@To_Slab >= From_Slab and  @To_Slab <= To_Slab) or 
                                (From_Slab >= @From_Slab and From_Slab <= @To_Slab) or
                                (To_Slab >= @From_Slab and To_Slab <= @To_Slab))) 
                Begin   
                    select @Tran_ID = Tran_Id from T0040_AD_Slab_Setting WITH (NOLOCK) where Cmp_Id=@Cmp_ID and AD_Id=@AD_ID and Calc_Type=@Calc_Type and
                    ( (@From_Slab >= From_Slab and @From_Slab <= To_Slab) or 
                                (@To_Slab >= From_Slab and  @To_Slab <= To_Slab) or 
                                (From_Slab >= @From_Slab and From_Slab <= @To_Slab) or
                                (To_Slab >= @From_Slab and To_Slab <= @To_Slab))    
                                    
                    Update T0040_AD_Slab_Setting  
                        set   Sal_Calc_Type = @Sal_Calc_Type  
                        where Tran_ID =@Tran_ID  and Cmp_Id=@Cmp_ID and AD_Id=@AD_ID
                    
                    Return
                End 
                   
      if @Tran_Type ='I'
          Begin   
            select @Tran_ID = isnull(max(Tran_ID),0) + 1 from T0040_AD_Slab_Setting WITH (NOLOCK)    
            INSERT INTO T0040_AD_Slab_Setting  
                                  (Tran_Id, Cmp_Id, AD_Id, From_Slab, To_Slab, Calc_Type, Amount,Sal_Calc_Type)  
            Values(@Tran_Id, @Cmp_Id, @AD_Id, @From_Slab, @To_Slab, @Calc_Type, @Amount,@Sal_Calc_Type)  

            --Add By PAras 20-10-2012
            set @OldValue = 'New Value' + '#'+ 'From Slab :' + cast(ISNULL(@From_Slab,0)as varchar(20)) + '#' + 'To Slab :' +CAST(ISNULL(@To_Slab,0)as varchar(20)) + '#' + 'Calc Type :' +ISNULL(@Calc_Type,'') + '#' + 'Amount :' +CAST(ISNULL(@Amount,0)AS VARCHAR(20)) + '#' + 'Sal Calc Type:' +CAST(ISNULL(@Sal_Calc_Type,0)AS VARCHAR(20)) 
            ---
            
          end  
      else if @Tran_Type ='U'  
          begin  
          
          --Add By PAras 20-10-2012
          select @OldFrom_Slab  =CAST(ISNULL(From_Slab,0)as varchar(20)) ,@OldTo_Slab  =CAST(ISNULL(To_Slab,0)as varchar(20)),@OldCalc_Type  =isnull(Calc_Type,''),@OldAmount  =CAST(isnull(Amount,0)as varchar(20)), @OldSal_Calc_Type = Sal_Calc_Type From dbo.T0040_AD_Slab_Setting WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and AD_Id = @AD_ID
          -----
            Update T0040_AD_Slab_Setting  
            set   
            Tran_Id = @Tran_ID,   
            AD_Id = @AD_ID ,  
            From_Slab = @From_Slab,   
            To_Slab = @To_Slab,  
            Calc_Type = @Calc_Type,  
            Amount = @Amount,
            Sal_Calc_Type = @Sal_Calc_Type  
            where Tran_ID =@Tran_ID   
            --Add By PAras 20-10-2012
            set @OldValue = 'old Value' + '#'+ 'From Slab :' + cast(ISNULL(@OldFrom_Slab,0)as varchar(20)) + '#' + 'To Slab :' +CAST(ISNULL(@OldTo_Slab,0)as varchar(20)) + '#' + 'Calc Type :' +ISNULL(@OldCalc_Type,'') + '#' + 'Amount :' +CAST(ISNULL(@OldAmount,0)AS VARCHAR(20)) + '#' + 'Sal Calc Type:' +CAST(ISNULL(@OldSal_Calc_Type,0)AS VARCHAR(20)) 
                   + 'New Value' + '#'+ 'From Slab :' + cast(ISNULL(@From_Slab,0)as varchar(20)) + '#' + 'To Slab :' +CAST(ISNULL(@To_Slab,0)as varchar(20)) + '#' + 'Calc Type :' +ISNULL(@Calc_Type,'') + '#' + 'Amount :' +CAST(ISNULL(@Amount,0)AS VARCHAR(20)) + '#' + 'Sal Calc Type:' +CAST(ISNULL(@Sal_Calc_Type,0)AS VARCHAR(20)) 
            ----
            
          end
       else if @Tran_Type='D'       
         Begin  
         ----Add By PAras 20-10-2012
         select @OldFrom_Slab  =CAST(ISNULL(From_Slab,0)as varchar(20)) ,@OldTo_Slab  =CAST(ISNULL(To_Slab,0)as varchar(20)),@OldCalc_Type  =isnull(Calc_Type,''),@OldAmount  =CAST(isnull(Amount,0)as varchar(20)), @OldSal_Calc_Type = Sal_Calc_Type From dbo.T0040_AD_Slab_Setting WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and AD_Id = @AD_ID
         ---
           Delete from T0040_AD_Slab_Setting where Tran_ID =@Tran_ID        
           ----Add By PAras 20-10-2012
           set @OldValue = 'old Value' + '#'+ 'From Slab :' + cast(ISNULL(@OldFrom_Slab,0)as varchar(20)) + '#' + 'To Slab :' +CAST(ISNULL(@OldTo_Slab,0)as varchar(20)) + '#' + 'Calc Type :' +ISNULL(@OldCalc_Type,'') + '#' + 'Amount :' +CAST(ISNULL(@OldAmount,0)AS VARCHAR(20))  + '#' + 'Sal Calc Type:' +CAST(ISNULL(@Sal_Calc_Type,0)AS VARCHAR(20)) 
         End  
       
       exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Slab Setting',@OldValue,@AD_ID,@User_Id,@IP_Address
       
       ----
     RETURN 
