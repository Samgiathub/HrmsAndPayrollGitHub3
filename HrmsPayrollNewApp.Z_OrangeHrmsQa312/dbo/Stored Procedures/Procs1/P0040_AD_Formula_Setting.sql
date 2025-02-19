

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_AD_Formula_Setting]   
 @Tran_ID		numeric output ,  
 @Cmp_ID		numeric,  
 @AD_ID			numeric,    
 @AD_Formula	nvarchar(max),   
 @Tran_Type		char(1) 
  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON  
 
 Declare @Out_Formula as nvarchar(max)
 Declare @Actual_Formula as nvarchar(max)
 
  if @Tran_Type ='I'
	  Begin   
		select @Tran_ID = isnull(max(Tran_ID),0) + 1 from T0040_AD_Formula_Setting WITH (NOLOCK)
		
		exec Get_AD_Formula @Cmp_ID,@AD_Formula,@Out_Formula output,@Actual_Formula output   
		INSERT INTO T0040_AD_Formula_Setting  
							  (Tran_Id, Cmp_Id, AD_Id, AD_Formula,Actual_AD_Formula )  
		Values(@Tran_Id, @Cmp_Id, @AD_Id, @AD_Formula,@Actual_Formula)  
	  end  
  else if @Tran_Type ='U'  
	  begin  
		exec Get_AD_Formula @Cmp_ID,@AD_Formula,@Out_Formula output,@Actual_Formula output 
		

		
		
		if Exists(SELECT 1 from T0040_AD_Formula_Setting WITH (NOLOCK) where ad_ID=@AD_ID AND cmp_ID=@Cmp_ID)
		begin
		
			Update T0040_AD_Formula_Setting  
			set
			AD_Id = @AD_ID ,  
			AD_Formula = @AD_Formula,
			Actual_AD_Formula =@Actual_Formula 
			where AD_ID =@AD_ID
		
		End
		Else
		 BEGIN
		 
		 select @Tran_ID = isnull(max(Tran_ID),0) + 1 from T0040_AD_Formula_Setting WITH (NOLOCK) 
		 INSERT INTO T0040_AD_Formula_Setting  
							  (Tran_Id, Cmp_Id, AD_Id, AD_Formula,Actual_AD_Formula )  
		Values(@Tran_Id, @Cmp_Id, @AD_Id, @AD_Formula,@Actual_Formula)  
		 end
	  end
   else if @Tran_Type='D'       
     Begin  
       Delete from T0040_AD_Formula_Setting where Tran_ID =@Tran_ID        
     End  
   
   
 RETURN  

