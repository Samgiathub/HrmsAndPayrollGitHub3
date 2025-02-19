    
    
-- =============================================    
-- Author:  <Author,,Name>    
-- ALTER date: <ALTER Date,,>    
-- Description: <Description,,>    
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
-- =============================================    
CREATE PROCEDURE [dbo].[P0040_Expense_Type_MASTER]    
    
      @Expense_Type_ID numeric(18,0) output,    
      @CMP_ID   NUMERIC(18,0),    
   @Expense_Type_name nvarchar(30),    
   @Expense_Type_Group nvarchar(30),    
   @Grade_Id_Multi  Varchar(50),    
   @Grade_Wise_ExAmount NUMERIC(18,0), --ANKIT 18102014    
   @Display_FrmTime NUMERIC(18,0)=0, --Sumit 09032015    
   @Is_Overlimit tinyint=0,    
   @Remove_PreeDate tinyint =0, --Sumit 30092015    
   @Is_Petrol tinyint =0,    
   @Is_Deduct tinyint=0,    
   @Deduct_per numeric(18,2)=0,    
   @Travel_Mode tinyint =0,    
   @tran_type varchar(1),    
   @Gst_Applicable tinyint = 0,  --Added by Jaina 15-09-2017    
   @No_of_days tinyint = 0,-- Added by Yogesh on  16-05-2024  
   @GuestName tinyint = 0,-- Added by Yogesh on  16-05-2024  
   @TravelType integer = 0    
      
AS    
BEGIN    
    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
   set @Expense_Type_Group = dbo.fnc_ReverseHTMLTags(@Expense_Type_Group)  --added by Ronak 081021  
   set @Expense_Type_name = dbo.fnc_ReverseHTMLTags(@Expense_Type_name)  --added by Ronak 081021  
 If Upper(@tran_type) ='I'    
   begin    

    if exists (Select Expense_Type_ID  from T0040_Expense_Type_Master WITH (NOLOCK) Where Upper(Expense_Type_name) = Upper(@Expense_Type_name) AND CMP_ID  = @CMP_ID and TravelTypeId = @TravelType)     
     begin  
	
      set @Expense_Type_ID = 0    
      Return     
     end    
        
    select @Expense_Type_ID = isnull(max(Expense_Type_ID),0) + 1 from T0040_Expense_Type_Master WITH (NOLOCK)    
     print 123
    INSERT INTO T0040_Expense_Type_Master    
                          (Expense_Type_ID, Expense_Type_name, Expense_Type_Group, Grade_Id_Multi,CMP_ID,Grade_Wise_ExAmount,Display_FromTime,is_overlimit,is_not_pree_post_date,is_petrol_wise,Is_deduct,Deduct_Per,Travel_Mode,Gst_Applicable,TravelTypeId,No_of_Days,GuestName)    
    VALUES     (@Expense_Type_ID,@Expense_Type_name,@Expense_Type_Group, @Grade_Id_Multi,@CMP_ID,@Grade_Wise_ExAmount,@Display_FrmTime,@Is_Overlimit,@Remove_PreeDate,@Is_Petrol,@Is_Deduct,@Deduct_per,@Travel_Mode,@Gst_Applicable,@TravelType,@No_of_days,@GuestName)     
        
     end     
 Else If  Upper(@tran_type) ='U'     
   begin    
    if exists (Select Expense_Type_ID  from T0040_Expense_Type_Master WITH (NOLOCK) Where Upper(Expense_Type_name) = Upper(@Expense_Type_name)   
 and Expense_Type_ID <> @Expense_Type_ID AND CMP_ID  = @CMP_ID and TravelTypeId = @TravelType )     
     begin    
      set @Expense_Type_ID = 0    
      Return    
     end    
            
    UPDATE    T0040_Expense_Type_Master    
    SET       Expense_Type_name = @Expense_Type_name, Expense_Type_Group = @Expense_Type_Group, Grade_Id_Multi = @Grade_Id_Multi ,Grade_Wise_ExAmount = @Grade_Wise_ExAmount,Display_FromTime=@Display_FrmTime    
        ,is_overlimit=@is_overlimit,is_not_pree_post_date=@Remove_PreeDate,Is_Petrol_wise=@Is_Petrol,    
        Is_Deduct=@Is_Deduct,Deduct_Per=@Deduct_per,    
        Travel_Mode=@Travel_Mode,    
        Gst_Applicable = @Gst_Applicable,  
  TravelTypeId = @TravelType,  
  No_of_Days=@No_of_days,  
  GuestName=@GuestName  
    WHERE     Expense_Type_ID = @Expense_Type_ID AND CMP_ID  = @CMP_ID    
           
    end    
       
 Else If  Upper(@tran_type) ='D'    
   Begin    
       
     if Exists(select Expense_Type_ID from T0140_Travel_Settlement_Expense WITH (NOLOCK) where Cmp_ID=@CMP_ID and Expense_Type_id=@Expense_Type_ID)    
      begin    
       RAISERROR('@@ Reference Exists @@',16,2)    
       RETURN     
      end    
     IF Exists(SELECT 1 FROM T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK) WHERE  Expense_Type_ID = @Expense_Type_ID AND CMP_ID  = @CMP_ID)    
      BEGIN    
       DELETE FROM T0050_EXPENSE_TYPE_MAX_LIMIT WHERE  Expense_Type_ID = @Expense_Type_ID AND CMP_ID  = @CMP_ID    
      END    
     IF Exists(SELECT 1 FROM T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY WITH (NOLOCK) WHERE  Expense_Type_ID = @Expense_Type_ID AND CMP_ID  = @CMP_ID)    
      BEGIN    
       DELETE FROM T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY WHERE  Expense_Type_ID = @Expense_Type_ID AND CMP_ID  = @CMP_ID    
      END     
     IF Exists(SELECT 1 FROM T0050_EXPENSE_TYPE_MAX_KM WITH (NOLOCK) WHERE  Expense_Type_ID = @Expense_Type_ID AND CMP_ID  = @CMP_ID)    
      BEGIN    
       DELETE FROM T0050_EXPENSE_TYPE_MAX_KM WHERE  Expense_Type_ID = @Expense_Type_ID AND CMP_ID  = @CMP_ID    
      END            
     DELETE FROM T0040_Expense_Type_Master WHERE Expense_Type_ID = @Expense_Type_ID AND CMP_ID  = @CMP_ID    
        
   End    
       
       
 RETURN    
END    
    
    