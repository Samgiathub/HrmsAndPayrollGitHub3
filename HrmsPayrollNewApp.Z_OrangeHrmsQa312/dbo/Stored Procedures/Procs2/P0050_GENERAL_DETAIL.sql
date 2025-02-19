


---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_GENERAL_DETAIL]  
    @GEN_TRAN_ID numeric output  
   ,@CMP_ID numeric  
   ,@GEN_ID numeric  
   ,@ACC_1_1 numeric(18,3)  
   ,@ACC_1_2 numeric(18,3)  
   ,@ACC_2_3 numeric(18,3)  
   ,@ACC_10_1 numeric(18,3)  
   ,@ACC_21_1 numeric(18,3)  
   ,@ACC_22_3 numeric(18,3)  
   ,@ACC_10_1_MAX_LIMIT numeric(18,3)  
   ,@PF_LIMIT numeric  
   ,@tran_type varchar(1)  
   ,@Is_Ncp_Prorata as numeric  = 0
	
     
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 If @tran_type  = 'I'   
  Begin  
   If exists (Select GEN_TRAN_ID  from T0050_GENERAL_DETAIL WITH (NOLOCK) Where GEN_ID = @GEN_ID and Cmp_ID =@cmp_ID)   
     begin  
      set @GEN_TRAN_ID = 0  
      Return  
     end  
      
     select @GEN_TRAN_ID = Isnull(max(GEN_TRAN_ID),0) + 1  From T0050_GENERAL_DETAIL WITH (NOLOCK)  
      
    INSERT INTO T0050_GENERAL_DETAIL  
                          (GEN_TRAN_ID, CMP_ID, GEN_ID, ACC_1_1, ACC_1_2, ACC_2_3, ACC_10_1, ACC_21_1, ACC_22_3, ACC_10_1_MAX_LIMIT, PF_LIMIT,PF_PENSION_AGE,Is_Ncp_Prorata)  
    VALUES       
    (@GEN_TRAN_ID, @CMP_ID, @GEN_ID, @ACC_1_1, @ACC_1_2, @ACC_2_3, @ACC_10_1, @ACC_21_1, @ACC_22_3, @ACC_10_1_MAX_LIMIT, @PF_LIMIT,58.0,@Is_Ncp_Prorata)  
            
  End  
 Else if @Tran_Type = 'U'   
  begin  

   --UPDATE    T0050_GENERAL_DETAIL  
   --SET       GEN_ID = @GEN_ID, ACC_1_1 = @ACC_1_1, ACC_1_2 = @ACC_1_2, ACC_2_3 = @ACC_2_3, ACC_10_1 = @ACC_10_1,ACC_21_1 = @ACC_21_1,ACC_22_3 = @ACC_22_3, ACC_10_1_MAX_LIMIT = @ACC_10_1_MAX_LIMIT, PF_LIMIT = @PF_LIMIT,PF_PENSION_AGE=58.0,Is_Ncp_Prorata=@Is_Ncp_Prorata
   --where GEN_TRAN_ID = @GEN_TRAN_ID AND CMP_ID = @CMP_ID  
   
   UPDATE    T0050_GENERAL_DETAIL  
   SET       ACC_1_1 = @ACC_1_1, ACC_1_2 = @ACC_1_2, ACC_2_3 = @ACC_2_3, ACC_10_1 = @ACC_10_1,ACC_21_1 = @ACC_21_1,ACC_22_3 = @ACC_22_3, ACC_10_1_MAX_LIMIT = @ACC_10_1_MAX_LIMIT, PF_LIMIT = @PF_LIMIT,PF_PENSION_AGE=58.0,Is_Ncp_Prorata=@Is_Ncp_Prorata
   where CMP_ID = @CMP_ID AND  GEN_ID = @GEN_ID
         
  end  
 Else if @Tran_Type = 'D'   
  begin  
    Delete From T0050_GENERAL_DETAIL Where GEN_TRAN_ID = @GEN_TRAN_ID  
  end  
     
 RETURN  
  
  


