


---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_ReimClaim_Setting]   
 @Tran_ID		numeric output ,  
 @Cmp_ID		numeric,  
 @AD_ID			numeric,    
 @Non_Taxable_Limit numeric(18,2),
 @Taxable_Limt	  numeric(18,2),
 @Is_CF			numeric,
 @Num_LTA_Block numeric(18,2),
 @Tran_Type    Char(1)	
  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON  
 
 
  if @Tran_Type ='I'
	  Begin   
		select @Tran_ID = isnull(max(TranID),0) + 1 from t0040_ReimClaim_Setting WITH (NOLOCK)
					
	
		INSERT INTO t0040_ReimClaim_Setting  
							  (TranID, Cmp_Id, AD_Id, Non_Taxable_Limit,Taxable_Limit,Is_CF,Num_LTA_Block )  
		Values(@Tran_Id, @Cmp_Id, @AD_Id, @Non_Taxable_Limit,@Taxable_Limt,@Is_CF,@Num_LTA_Block)  
		
	  end  
  else if @Tran_Type ='U'  
	  begin  
		
		
		if Exists(SELECT 1 from t0040_ReimClaim_Setting WITH (NOLOCK) where cmp_ID=@cmp_ID and AD_ID=@AD_ID)
		BEGIN
			Update t0040_ReimClaim_Setting
		set AD_Id = @AD_ID ,  
		Non_Taxable_Limit = @Non_Taxable_Limit,
		Taxable_Limit =@Taxable_Limt,
		Is_CF =@Is_CF,
		Num_LTA_Block=@Num_LTA_Block
		from t0040_ReimClaim_Setting  where AD_ID=@AD_ID and cmp_ID=@cmp_ID
		
		end
		Else
		 BEGIN
		 
		 select @Tran_ID = isnull(max(TranID),0) + 1 from t0040_ReimClaim_Setting WITH (NOLOCK)
		 
		 INSERT INTO t0040_ReimClaim_Setting  
							  (TranID, Cmp_Id, AD_Id, Non_Taxable_Limit,Taxable_Limit,Is_CF,Num_LTA_Block )  
		Values(@Tran_Id, @Cmp_Id, @AD_Id, @Non_Taxable_Limit,@Taxable_Limt,@Is_CF,@Num_LTA_Block)  
		 
		 end
 
	  end
   else if @Tran_Type='D'       
     Begin  
       Delete from T0040_AD_Formula_Setting where Tran_ID =@Tran_ID    and cmp_ID=@cmp_ID     
     End  
   
   
 RETURN  


