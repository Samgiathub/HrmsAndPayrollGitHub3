




CREATE PROCEDURE [dbo].[P0100_cf_auto_Log]  
   @Cmp_ID   numeric(18),
   @Leave_Id   numeric(18),
   @SystemDateTime datetime=null,
   @Is_Success tinyint =0, 
   @From_Date datetime=null,
   @To_Date datetime=null,
   @Comment varchar(400) =null
AS  
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON    
   
 
   
  --if exists (Select Res_Id  from dbo.T0100_cf_auto_Log Where Upper(Reason_Name) = Upper(@Reason_Name))   
  --  begin  
		INSERT INTO dbo.T0100_cf_auto_Log(Cmp_ID,Leave_Id,SystemDateTime,Is_Success,From_Date,To_Date,Comment)  
		VALUES(@Cmp_ID,@Leave_Id,@SystemDateTime,@Is_Success,@From_Date,@To_Date,@Comment)
   -- end  
   
 
  return
  
  


