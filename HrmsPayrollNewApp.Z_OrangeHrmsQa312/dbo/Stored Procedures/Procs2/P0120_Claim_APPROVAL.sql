


--ALTER PROCEDURE [dbo].[P0120_Claim_APPROVAL]  
--   @Claim_Apr_ID numeric(18, 0) output  
--  ,@Cmp_ID numeric(18, 0)  
--  ,@Claim_App_ID numeric(18, 0)  
--  ,@Emp_ID numeric(18, 0)  
--  ,@Claim_ID numeric(18, 0)  
--  ,@Claim_Apr_Date datetime  
--  ,@Claim_Apr_Code varchar(20) output 
--  ,@Claim_Apr_Comments varchar(250)  
--  ,@Claim_Apr_By varchar(100)  
--  ,@Claim_Apr_Amount numeric(18, 0)  
--  ,@Claim_Apr_Deduct_From_Sal numeric(18, 0)  
--  ,@Claim_Apr_Pending_Amount numeric(18, 0)  
--  ,@Claim_App_Status Char(1)   
--  ,@tran_type char  
  
--AS  
  
   
-- If @Claim_App_ID  =0   
--  set @Claim_App_ID  = null  
 
-- --set @Claim_Apr_Date = convert(varchar(20),@Claim_Apr_Date ,103)
-- --select @Claim_Apr_Date
  
--  if @tran_type ='I'   
--   begin  
     
--  --declare @Emp_Code as numeric  
--  --declare @str_Emp_Code as varchar(20)  
    
--  select @Claim_Apr_ID = Isnull(max(Claim_Apr_ID),0) + 1  From T0120_Claim_APPROVAL  
    
--  /*select @Emp_Code = EMP_CODE From T0080_EMP_MASTER WHERE EMP_ID  = @EMP_ID  
    
--  SELECT @str_Emp_Code =DATA  FROM dbo.F_Format('0000',@Emp_Code)   
     
--  select @Claim_Apr_Code =   cast(isnull(max(substring(Claim_Apr_Code,10,len(Claim_Apr_Code))),0) + 1 as varchar)    
--     from T0120_Claim_APPROVAL where Emp_ID = @Emp_ID  
      
--  If charindex(':',@Claim_Apr_Code) > 0   
--    Select @Claim_Apr_Code = right(@Claim_Apr_Code,len(@Claim_Apr_Code) - charindex(':',@Claim_Apr_Code))  
      
--    if @Claim_Apr_Code is not null  
--     begin  
--      while len(@Claim_Apr_Code) <> 4  
--        begin  
--          set @Claim_Apr_Code = '0' + @Claim_Apr_Code  
--         end  
--        set @Claim_Apr_Code = 'CAPR'+ @str_Emp_Code +':'+ @Claim_Apr_Code    
--       end  
--      else  
--     SET @Claim_Apr_Code = 'CAPR' + @str_Emp_Code + ':' + '0001' */  
       
--     set @Claim_Apr_Code = cast(@Claim_App_ID as varchar(2))  
--     UPDATE    T0100_Claim_APPLICATION  
--      SET         Claim_App_status = @Claim_App_Status  
              
--        WHERE     (Claim_App_ID = @Claim_App_ID and Cmp_ID=@Cmp_ID)  
           
--     INSERT INTO T0120_CLAIM_APPROVAL (Claim_Apr_ID,Cmp_ID,Claim_App_ID,Emp_ID,Claim_ID,Claim_Apr_Date,Claim_Apr_Code  
--         ,Claim_Apr_Amount,Claim_Apr_Comments,Claim_Apr_By,Claim_Apr_Deduct_From_Sal,Claim_Apr_Pending_Amount,Claim_Apr_Status)  
--     VALUES (@Claim_Apr_ID,@Cmp_ID,@Claim_App_ID,@Emp_ID,@Claim_ID,@Claim_Apr_Date,@Claim_Apr_Code  
--        ,@Claim_Apr_Amount,@Claim_Apr_Comments,@Claim_Apr_By,@Claim_Apr_Deduct_From_Sal,@Claim_Apr_Pending_Amount,@Claim_App_Status)    
       
--   end   
--  else if @tran_type ='U'   
--   begin  
--     UPDATE    T0100_CLAIM_APPLICATION  SET Claim_App_Status = @Claim_App_Status  
--     WHERE     Claim_App_ID = @Claim_App_ID and Cmp_ID=@Cmp_ID  
          
--    Update T0120_CLAIM_APPROVAL  
--     set Claim_ID=@Claim_ID  
--      ,Claim_Apr_Date=@Claim_Apr_Date  
--      ,Claim_Apr_Amount=@Claim_Apr_Amount  
--      ,Claim_Apr_Comments=@Claim_Apr_Comments  
--      ,Claim_Apr_By=@Claim_Apr_By  
--      ,Claim_Apr_Deduct_From_Sal=@Claim_Apr_Deduct_From_Sal  
--      ,Claim_Apr_Pending_Amount=@Claim_Apr_Pending_Amount  
--      ,Claim_Apr_Status=@Claim_App_Status  
--      where  Claim_App_ID = @Claim_App_ID and Cmp_ID=@Cmp_ID  
--    end  
-- else if @tran_type ='D'  
--   begin  
--     DELETE FROM T0120_Claim_APPROVAL where Claim_Apr_ID = @Claim_Apr_ID  
       
--     UPDATE    T0100_Claim_APPLICATION SET  Claim_App_status = 'P'  
--     WHERE     Claim_App_ID = @Claim_App_ID and Cmp_ID=@Cmp_ID  
--   end  
-- RETURN  
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0120_Claim_APPROVAL]  
   @Claim_Apr_ID numeric(18, 0) output  
  ,@Cmp_ID numeric(18, 0)  
  ,@Claim_App_ID numeric(18, 0)  
  ,@Emp_ID numeric(18, 0)  
  ,@Claim_ID numeric(18, 0)  
  ,@Claim_Apr_Date datetime  
  ,@Claim_Apr_Code varchar(20) output 
  ,@Claim_Apr_Comments varchar(250)  
  ,@Claim_Apr_By varchar(100)  
  ,@Claim_Apr_Amount numeric(18, 3)  
  ,@Claim_Apr_Deduct_From_Sal numeric(18, 0)  
  ,@Claim_Apr_Pending_Amount numeric(18, 3)  
  ,@Claim_App_Status Char(1)   
  ,@Claim_App_Date as datetime
  ,@Claim_App_Amount as numeric(18,3)
  ,@Curr_ID as numeric(18,0)
  ,@Curr_Rate as numeric(18,3)
  ,@Purpose as nvarchar(250)
  ,@Claim_App_Total_Amount as numeric(18,3)
  ,@S_Emp_ID numeric(18,0)  
  ,@tran_type char  
  ,@Petrol_KM	NUMERIC(18,2)--Ankit 05022015
  ,@User_Id numeric(18,0) = 0 -- Add By Mukti 08072016
  ,@IP_Address varchar(30)= '' -- Add By Mukti 08072016
 
AS  
 SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
   
 If @Claim_App_ID  =0   
  set @Claim_App_ID  = null  
 
 --set @Claim_Apr_Date = convert(varchar(20),@Claim_Apr_Date ,103)
 --select @Claim_Apr_Date
   if @Claim_ID=0
 set @Claim_ID=null
 
    -- Add By Mukti 08072016(start)
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''
	-- Add By Mukti 08072016(end)
	
  if @tran_type ='I'   
   begin  
     
  --declare @Emp_Code as numeric  
  --declare @str_Emp_Code as varchar(20)  
    
  select @Claim_Apr_ID = Isnull(max(Claim_Apr_ID),0) + 1  From T0120_Claim_APPROVAL  WITH (NOLOCK) 
    
	
	
  /*select @Emp_Code = EMP_CODE From T0080_EMP_MASTER WHERE EMP_ID  = @EMP_ID  
    
  SELECT @str_Emp_Code =DATA  FROM dbo.F_Format('0000',@Emp_Code)   
     
  select @Claim_Apr_Code =   cast(isnull(max(substring(Claim_Apr_Code,10,len(Claim_Apr_Code))),0) + 1 as varchar)    
     from T0120_Claim_APPROVAL where Emp_ID = @Emp_ID  
      
  If charindex(':',@Claim_Apr_Code) > 0   
    Select @Claim_Apr_Code = right(@Claim_Apr_Code,len(@Claim_Apr_Code) - charindex(':',@Claim_Apr_Code))  
      
    if @Claim_Apr_Code is not null  
     begin  
      while len(@Claim_Apr_Code) <> 4  
        begin  
          set @Claim_Apr_Code = '0' + @Claim_Apr_Code  
         end  
        set @Claim_Apr_Code = 'CAPR'+ @str_Emp_Code +':'+ @Claim_Apr_Code    
       end  
      else  
     SET @Claim_Apr_Code = 'CAPR' + @str_Emp_Code + ':' + '0001' */  
     
	 --Added by Jaina 7-10-2020
	 
	 If @Claim_Apr_Code != 'Import'
	 Begin
			set @Claim_Apr_Code = cast(@Claim_App_ID as varchar(10))  
	 END
	 			
			UPDATE    T0100_Claim_APPLICATION  
			SET         Claim_App_status = @Claim_App_Status  
            WHERE     Claim_App_ID = @Claim_App_ID --and Cmp_ID=@Cmp_ID)  
           

           
     --INSERT INTO T0120_CLAIM_APPROVAL (Claim_Apr_ID,Cmp_ID,Claim_App_ID,Emp_ID,Claim_ID,Claim_Apr_Date,Claim_Apr_Code  
     --    ,Claim_Apr_Amount,Claim_Apr_Comments,Claim_Apr_By,Claim_Apr_Deduct_From_Sal,Claim_Apr_Pending_Amount,Claim_Apr_Status)  
     --VALUES (@Claim_Apr_ID,@Cmp_ID,@Claim_App_ID,@Emp_ID,@Claim_ID,@Claim_Apr_Date,@Claim_Apr_Code  
     --   ,@Claim_Apr_Amount,@Claim_Apr_Comments,@Claim_Apr_By,@Claim_Apr_Deduct_From_Sal,@Claim_Apr_Pending_Amount,@Claim_App_Status)  
      INSERT INTO T0120_CLAIM_APPROVAL (Claim_Apr_ID,Cmp_ID,Claim_App_ID,Emp_ID,Claim_ID,Claim_Apr_Date,Claim_Apr_Code  
         ,Claim_Apr_Amount,Claim_Apr_Comments,Claim_Apr_By,Claim_Apr_Deduct_From_Sal,Claim_Apr_Pending_Amount,Claim_Apr_Status,Claim_App_Date,Claim_App_Amount,Curr_ID,
		 Curr_Rate,Purpose,Claim_App_Total_Amount,S_Emp_ID,Petrol_KM)  
     VALUES (@Claim_Apr_ID,@Cmp_ID,@Claim_App_ID,@Emp_ID,@Claim_ID,@Claim_Apr_Date,@Claim_Apr_Code  
        ,@Claim_Apr_Amount,@Claim_Apr_Comments,@Claim_Apr_By,@Claim_Apr_Deduct_From_Sal,@Claim_Apr_Pending_Amount,
		@Claim_App_Status,@Claim_App_Date,@Claim_App_Amount,@Curr_ID,@Curr_Rate,@Purpose,@Claim_App_Total_Amount,@S_Emp_ID,@Petrol_KM)
       
	   
       -- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table = 'T0120_CLAIM_APPROVAL' ,@key_column='Claim_Apr_ID',@key_Values=@Claim_Apr_ID,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
		-- Add By Mukti 05072016(end)	
   end   
  else if @tran_type ='U'   
   begin  
	-- Add By Mukti 05072016(start)
		exec P9999_Audit_get @table='T0120_CLAIM_APPROVAL' ,@key_column='Claim_Apr_ID',@key_Values=@Claim_Apr_ID,@String=@String output
		set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
	-- Add By Mukti 05072016(end)
				
     UPDATE    T0100_CLAIM_APPLICATION  SET Claim_App_Status = @Claim_App_Status  
     WHERE     Claim_App_ID = @Claim_App_ID and Cmp_ID=@Cmp_ID  
          
          
    Update T0120_CLAIM_APPROVAL  
     set Claim_ID=@Claim_ID  
      ,Claim_Apr_Date=@Claim_Apr_Date  
      ,Claim_Apr_Amount=@Claim_Apr_Amount  
      ,Claim_Apr_Comments=@Claim_Apr_Comments  
      ,Claim_Apr_By=@Claim_Apr_By  
      ,Claim_Apr_Deduct_From_Sal=@Claim_Apr_Deduct_From_Sal  
      ,Claim_Apr_Pending_Amount=@Claim_Apr_Pending_Amount  
      ,Claim_Apr_Status=@Claim_App_Status  
      ,Claim_App_Date =@Claim_App_Date
      ,Claim_App_Amount=@Claim_App_Amount
      ,Curr_ID=@Curr_ID
      ,Curr_Rate=@Curr_Rate
      ,Purpose=@Purpose
      ,Claim_App_Total_Amount=@Claim_App_Total_Amount
      ,S_Emp_ID=@S_Emp_ID
      ,Petrol_KM = @Petrol_KM
	  --where  Claim_App_ID = @Claim_App_ID and Cmp_ID=@Cmp_ID  
      where  Claim_Apr_ID = @Claim_Apr_ID and Cmp_ID=@Cmp_ID  
    
		-- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table = 'T0120_CLAIM_APPROVAL' ,@key_column='Claim_Apr_ID',@key_Values=@Claim_Apr_ID,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
		-- Add By Mukti 05072016(end)    
    end  
 --else if @tran_type ='D'  
 --  begin  
 --    --delete from T0115_CLAIM_LEVEL_APPROVAL where Claim_App_ID=@Claim_App_ID
     
 --    DELETE FROM T0120_Claim_APPROVAL where Claim_App_ID = @Claim_App_ID
       
 --    UPDATE    T0100_Claim_APPLICATION SET  Claim_App_status = 'P'  
 --    WHERE     Claim_App_ID = @Claim_App_ID and Cmp_ID=@Cmp_ID  
 --  end
 --else if @tran_type ='D'  
 --  begin          
 --    declare @Tran_id as numeric(18,0)
	-- declare @Rm_emp_id as numeric(18,0)
	-- set @Rm_emp_id = 0
	-- set @Tran_id = 0
	
	--Select @Rm_emp_id = S_Emp_ID,@Tran_id = Tran_ID from T0115_CLAIM_LEVEL_APPROVAL where  Claim_App_ID= @Claim_App_ID AND Rpt_Level IN (SELECT max(Rpt_Level) from T0115_CLAIM_LEVEL_APPROVAL where Claim_App_ID= @Claim_App_ID )				    
 --    If @Rm_emp_id = @S_Emp_ID 
	--					Begin							
	--						Delete from T0115_CLAIM_LEVEL_APPROVAL Where Claim_App_ID= @Claim_App_ID and S_Emp_ID=@S_Emp_ID
	--					End
	--Else
	--					Begin							
	--						Delete from T0115_CLAIM_LEVEL_APPROVAL Where Claim_App_ID= @Claim_App_ID and S_Emp_ID=@S_Emp_ID
	--					End	
					
	--				--End
     
     
     
 --    DELETE FROM T0120_Claim_APPROVAL where Claim_App_ID = @Claim_App_ID
       
       
 --    UPDATE    T0100_Claim_APPLICATION SET  Claim_App_status = 'P'  
 --    WHERE     Claim_App_ID = @Claim_App_ID and Cmp_ID=@Cmp_ID  
 --  end
 
 else if @tran_type ='D'  
   begin          
     declare @Tran_id as numeric(18,0)
	 declare @Rm_emp_id as numeric(18,0)
	 set @Rm_emp_id = 0
	 set @Tran_id = 0
	-- Add By Mukti 05072016(start)
		exec P9999_Audit_get @table='T0120_CLAIM_APPROVAL' ,@key_column='Claim_Apr_ID',@key_Values=@Claim_Apr_ID,@String=@String output
		set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
	-- Add By Mukti 05072016(end)
		IF EXISTS(SELECT 1 FROM T0140_CLAIM_TRANSACTION AS CT 
				INNER JOIN ( SELECT DISTINCT CLAIM_APR_ID,CLAIM_ID,CLAIM_APR_DATE,CMP_ID FROM T0130_CLAIM_APPROVAL_DETAIL ) CAD ON CAD.CLAIM_APR_DATE = CT.FOR_DATE  
				INNER JOIN T0120_CLAIM_APPROVAL AS CA ON CA.CLAIM_APR_ID = CAD.CLAIM_APR_ID AND CT.EMP_ID=CA.EMP_ID AND CT.CLAIM_ID=CAD.CLAIM_ID 
				INNER JOIN T0040_CLAIM_MASTER CLM ON CLM.CLAIM_ID=CAD.CLAIM_ID AND CLM.CMP_ID=CAD.CMP_ID 
				INNER JOIN T0200_MONTHLY_SALARY MS ON MS.Sal_Tran_ID=CT.Salary_Tran_ID
				left join T0050_AD_MASTER ADM on ADm.Claim_ID = CAd.Claim_ID   
				WHERE CT.CMP_ID=@CMP_ID AND CT.EMP_ID=@EMP_ID AND CA.CLAIM_APR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date
				AND CLM.CLAIM_APR_DEDUCT_FROM_SAL=1 and  ADM.Claim_ID is Null AND ISNULL(CT.Salary_Tran_ID,0) > 0)
			BEGIN
				RAISERROR('Month Salary Exists',16,2)
				Return -1
			END

		IF EXISTS(SELECT 1 FROM T0130_CLAIM_APPROVAL_DETAIL AS CAD 
				WHERE Cmp_ID=@Cmp_ID and Claim_App_ID=@Claim_App_ID And Cad.Payment_Process_ID IS NOT NULL)
			BEGIN
				RAISERROR('Payment Process Exists For this Record',16,2)
				Return -1
			END

	SELECT @RM_EMP_ID = S_EMP_ID,@TRAN_ID = TRAN_ID 
	FROM T0115_CLAIM_LEVEL_APPROVAL WITH (NOLOCK)
	WHERE  CLAIM_APP_ID= @CLAIM_APP_ID AND 
			RPT_LEVEL IN (SELECT MAX(RPT_LEVEL) 
						  FROM T0115_CLAIM_LEVEL_APPROVAL WITH (NOLOCK)
						  WHERE CLAIM_APP_ID= @CLAIM_APP_ID )		
			
     IF @RM_EMP_ID = @S_EMP_ID 
		BEGIN
			DELETE FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL WHERE CLAIM_APP_ID=@CLAIM_APP_ID AND S_EMP_ID=@S_EMP_ID			
			DELETE FROM T0115_CLAIM_LEVEL_APPROVAL WHERE CLAIM_APP_ID= @CLAIM_APP_ID AND S_EMP_ID=@S_EMP_ID
		END
	 ELSE IF @S_EMP_ID=0
		BEGIN 
			DELETE FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL WHERE CLAIM_APP_ID=@CLAIM_APP_ID --AND S_EMP_ID=@S_EMP_ID			
			DELETE FROM T0115_CLAIM_LEVEL_APPROVAL WHERE CLAIM_APP_ID= @CLAIM_APP_ID-- AND S_EMP_ID=@S_EMP_ID
		END					
	 ELSE
		BEGIN							
			DELETE FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL WHERE CLAIM_APP_ID=@CLAIM_APP_ID AND S_EMP_ID=@S_EMP_ID
			DELETE FROM T0115_CLAIM_LEVEL_APPROVAL WHERE CLAIM_APP_ID= @CLAIM_APP_ID AND S_EMP_ID=@S_EMP_ID
		END	
					
					--End
     
 
	IF isnull(@CLAIM_APP_ID,0) = 0  --Added by Jaina 12-10-2020
		BEGIN
			DELETE FROM T0130_CLAIM_APPROVAL_DETAIL WHERE CLAIM_APR_ID=@CLAIM_APR_ID
			DELETE FROM T0120_CLAIM_APPROVAL WHERE CLAIM_APR_ID = @CLAIM_APR_ID
		END
	ELSE
		BEGIN
			DELETE FROM T0130_CLAIM_APPROVAL_DETAIL WHERE CLAIM_APP_ID=@CLAIM_APP_ID
			DELETE FROM T0120_CLAIM_APPROVAL WHERE CLAIM_APP_ID = @CLAIM_APP_ID
		END
     
     
      --delete from T0140_CLAIM_TRANSACTION where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and 
       
     UPDATE    T0100_Claim_APPLICATION SET  Claim_App_status = 'P'  
     WHERE     Claim_App_ID = @Claim_App_ID --and Cmp_ID=@Cmp_ID 
     
   end    
   			
	exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Claim Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
RETURN  
  
  
  

