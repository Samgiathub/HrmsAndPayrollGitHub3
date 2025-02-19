
CREATE PROCEDURE [dbo].[P0040_ESOP_Master]  
    @Tran_ID  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@EffectiveDate DateTime
   ,@MarketPrice   numeric(18,2)  
   ,@EmpPrice   numeric(18,2)  
   ,@MonthLocked   numeric(9,0)  
   ,@tran_type  varchar(1) 

AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
  If @tran_type  = 'I'  
  Begin  
		IF EXISTS (Select 1  from dbo.T0020_ESOP_SharePrice_Master WITH (NOLOCK) Where EffectiveDate = @EffectiveDate and MarketPrice = @MarketPrice and EmployeePrice = @EmpPrice and Cmp_id = @Cmp_id)   
		BEGIN  
		 SET @TRAN_ID = 0  
		 RETURN  
		END 
				INSERT INTO dbo.T0020_ESOP_SharePrice_Master (EffectiveDate,MarketPrice,EmployeePrice,MonthWiseLockingPeriod,CreatedDate,Cmp_Id)  
				VALUES(@EffectiveDate,@MarketPrice,@EmpPrice,isnull(@MonthLocked,0),GETUTCDATE(),@Cmp_ID)
				set @TRAN_ID = @@identity
  End  
 Else if @Tran_Type = 'U'  
  begin  
		 IF Exists(select 1 From dbo.T0020_ESOP_SharePrice_Master WITH (NOLOCK) Where EffectiveDate = @EffectiveDate and Tran_id <> @Tran_ID and Cmp_id = @Cmp_id)  
		Begin  
				
			 set @Tran_ID = 0
			 Return   
		End  

		UPDATE dbo.T0020_ESOP_SharePrice_Master
		SET 
		EffectiveDate = @EffectiveDate,
		MarketPrice = @MarketPrice,
		EmployeePrice = @EmpPrice,
		MonthWiseLockingPeriod =  @MonthLocked
		where Tran_Id = @Tran_ID and Cmp_Id = @Cmp_ID
  end  
 Else if @Tran_Type = 'D'  
  begin  
		Delete From dbo.T0020_ESOP_SharePrice_Master Where Tran_Id = @Tran_ID
  end  
 RETURN