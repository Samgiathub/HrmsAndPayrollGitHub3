

-- =============================================
-- Author:		<ANKIT>
-- Create date: <12122014,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0100_NIGHT_HALT_APPLICATION]    
   @Application_ID	NUMERIC OUTPUT    
  ,@Cmp_ID		NUMERIC    
  ,@Emp_ID		NUMERIC    
  ,@S_Emp_ID	NUMERIC    
  ,@FROM_DATE	DATETIME    
  ,@To_Date		DATETIME    
  ,@NoOfDays    NUMERIC(18,2)
  ,@VisitPlace	VARCHAR(100)
  ,@Remarks		VARCHAR(100)
  --,@Is_Effect_Sal INT
  --,@Eff_Month	NUMERIC
  --,@Eff_Year	NUMERIC
  ,@Login_ID	NUMERIC     
  ,@TRAN_TYPE	VARCHAR(1)   
  ,@User_Id numeric(18,0) = 0 -- Add By Mukti 05072016
  ,@IP_Address varchar(30)= '' -- Add By Mukti 05072016
  
AS

	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	DECLARE @App_Status	CHAR(1)    
	SET @App_Status  = 'P'
	
	-- Add By Mukti 05072016(start)
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''
	-- Add By Mukti 05072016(end)	
	
	IF @S_Emp_ID = 0     
	   SET @S_Emp_ID = NULL    
		
	IF EXISTS( SELECT 1 FROM T0100_NIGHT_HALT_APPLICATION WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID And App_Status = 'P' AND
				((From_Date >= @From_Date AND From_Date <= @To_Date) OR (To_Date >= @From_Date AND To_Date <= @To_Date)) AND @TRAN_TYPE = 'I'   --Added tran_type condition by Jimit as in update case no need to check for already applied for nigh halt
			  )
		BEGIN			
			RAISERROR ('Application Already Exists on Same Date' , 16, 2) 
			RETURN	
		END
	
	IF EXISTS( SELECT 1 FROM T0120_NIGHT_HALT_APPROVAL WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID And (App_Status = 'A' or App_Status = 'R') AND
				((From_Date >= @From_Date AND From_Date <= @To_Date) OR (To_Date >= @From_Date AND To_Date <= @To_Date)) 
			  )
		BEGIN
			RAISERROR ('Application Already Approved on Same Date' , 16, 2) 
			RETURN	
		END
		       
	IF @TRAN_TYPE ='I'
		BEGIN
					
			--IF EXISTS( SELECT 1 FROM T0100_NIGHT_HALT_APPLICATION WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND
			--			(@FROM_DATE between From_Date And To_Date OR @To_Date Between From_date And To_Date)
			--		  )
			--	BEGIN
			--		RAISERROR ('Application Alredy Exist on Same Date' , 16, 2) 
			--		RETURN	
			--	END
			
			
			SELECT @Application_ID = ISNULL(MAX(Application_ID),0) + 1 FROM dbo.T0100_NIGHT_HALT_APPLICATION WITH (NOLOCK)    
			
			INSERT INTO dbo.T0100_NIGHT_HALT_APPLICATION    
                            (Application_ID, Cmp_ID, Emp_ID, S_Emp_ID, FROM_DATE, To_Date,No_Of_Days,Visit_Place ,Remarks,App_Status, Login_ID,System_Date)    
			VALUES     (@Application_ID,@Cmp_ID,@Emp_ID,@S_Emp_ID,@FROM_DATE,@To_Date,@NoOfDays,@VisitPlace,@Remarks,@App_Status,@Login_ID,getdate())    
			
		-- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table = 'T0100_NIGHT_HALT_APPLICATION' ,@key_column='Application_ID',@key_Values=@Application_ID,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
		-- Add By Mukti 05072016(end)	
    	END
    ELSE IF @TRAN_TYPE ='U' 
		BEGIN
			
			-- Add By Mukti 05072016(start)
				exec P9999_Audit_get @table='T0100_NIGHT_HALT_APPLICATION' ,@key_column='Application_ID',@key_Values=@Application_ID,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			-- Add By Mukti 05072016(end)
	    
			UPDATE  dbo.T0100_NIGHT_HALT_APPLICATION    
			SET     S_Emp_ID = @S_Emp_ID,FROM_DATE = @FROM_DATE, To_Date = @To_Date,No_Of_Days = @NoOfDays,
					Visit_Place = @VisitPlace,Remarks = @Remarks,
					Login_ID = @Login_ID, System_Date = GETDATE()
			WHERE	Application_ID = @Application_ID    
			
		-- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table = 'T0100_NIGHT_HALT_APPLICATION' ,@key_column='Application_ID',@key_Values=@Application_ID,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
		 -- Add By Mukti 05072016(end)    
		END
	ELSE IF @TRAN_TYPE ='D'	
		BEGIN
			-- Add By Mukti 05072016(start)
				exec P9999_Audit_get @table='T0100_NIGHT_HALT_APPLICATION' ,@key_column='Application_ID',@key_Values=@Application_ID,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			-- Add By Mukti 05072016(end)
			
			DELETE FROM dbo.T0100_NIGHT_HALT_APPLICATION where Application_ID = @Application_ID    
		END
	exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Night Halt Application',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
RETURN

