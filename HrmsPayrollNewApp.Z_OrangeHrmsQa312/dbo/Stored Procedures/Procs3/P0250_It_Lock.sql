

---12/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

 
CREATE PROCEDURE [dbo].[P0250_It_Lock]  
     @Lock_ID 	numeric(18,0)=0 output 
    ,@Cmp_ID 	numeric(18,0)
    ,@Financial_Year 	nvarchar(50)=''
 	,@Is_Lock		tinyint=0
 	,@User_ID numeric(18,0)= 0			-- Added for audit trail By Ali 22102013
	,@IP_Address varchar(30)= ''	-- Added for audit trail By Ali 22102013
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


									-- Added for audit trail By Ali 22102013 -- Start
										Declare @OldValue varchar(max)
										Declare @Old_Financial_Year nvarchar(50)
 										Declare @Old_Is_Lock tinyint
 										
 										Set @OldValue  = ''
										Set @Old_Financial_Year  = ''
 										Set @Old_Is_Lock  = 0
									-- Added for audit trail By Ali 22102013 -- End		
									
	Set NoCount On;
    Set ARITHABORT ON;     
	 
   
   if not exists(select 1 from t0250_It_Lock WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Financial_Year=@Financial_Year)
    begin
        insert into t0250_It_Lock
        (Cmp_ID,Financial_Year,Is_Lock)
        values(@Cmp_ID,@Financial_Year,@Is_Lock)
        set @Lock_ID=1
									-- Added for audit trail By Ali 22102013 -- Start
										set @OldValue = 'New Value' 
											+ '#' + 'Financial Year  : ' + ISNULL(@Financial_Year,'')
											+ '#' + 'Status : ' + CASE ISNULL(@Is_Lock,0) When 0 Then 'Unlock' ELSE 'Lock' END
											
										exec P9999_Audit_Trail @Cmp_ID,'I','IT Lock ',@OldValue,@Lock_ID,@User_Id,@IP_Address
									-- Added for audit trail By Ali 22102013 -- Start
								
    end
  else if exists(select 1 from t0250_It_Lock WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Financial_Year=@Financial_Year)
    begin
    
									-- Added for audit trail By Ali 22102013 -- Start
										Select
										@Old_Financial_Year = Financial_Year
										,@Old_Is_Lock =  Is_Lock									
										From t0250_It_Lock WITH (NOLOCK)
										where Cmp_ID=@Cmp_ID and Financial_Year=@Financial_Year
										set @OldValue = 'old Value' 
											+ '#' + 'Financial Year  : ' + ISNULL(@Old_Financial_Year,'')
											+ '#' + 'Status : ' + CASE ISNULL(@Old_Is_Lock,0) When 0 Then 'Unlock' ELSE 'Lock' END
											+ '#' +
											+ 'New Value' +
											+ '#' + 'Financial Year  : ' + ISNULL(@Financial_Year,'')
											+ '#' + 'Status : ' + CASE ISNULL(@Is_Lock,0) When 0 Then 'Unlock' ELSE 'Lock' END
											
										exec P9999_Audit_Trail @Cmp_ID,'U','IT Lock ',@OldValue,@Lock_ID,@User_Id,@IP_Address
									-- Added for audit trail By Ali 22102013 -- Start
								
       update t0250_It_Lock set 
		   Is_Lock=@Is_Lock
       where Cmp_ID=@Cmp_ID and Financial_Year=@Financial_Year
       set @Lock_ID=2
       
    end
   else 
       set @Lock_ID=0
      
   
  

