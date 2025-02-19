

-- =============================================
-- Author:		Gadriwala Muslim
-- Create date: <05/05/2015>
-- Description:	CompOff Leave Approval Using Import 
--  ---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0120_COMPOFF_APPROVAL_IMPORT]
	@CMP_ID numeric(18,0)
   ,@Emp_Code varchar(30)
   ,@EMP_ID  numeric(18,0)
   ,@Leave_Name varchar(50)  
   ,@Leave_id  numeric(18,0)
   ,@From_Date datetime
   ,@Leave_Period numeric(18,2) 
   ,@LEave_Assign varchar(15)  
   ,@APPROVAL_COMMENTS varchar(250)
   ,@LOGIN_ID numeric(18,0)   
   ,@Is_Import int
   ,@TRAN_TYPE as varchar(1)
   ,@Row_No int = 0
   ,@Log_Status Int = 0 Output
   ,@CancelWOHO tinyint = 0
   ,@Leave_negative_Allow tinyint = 0	
   ,@S_Emp_ID numeric(18,0)
   ,@DEFAULT_SHORT_NAME NVARCHAR(50) = 'COMP'  --Added by SUmit on 29092016
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		Declare @To_Date as datetime
		set @To_Date = null
		Declare @CompOff_String as nvarchar(max)
		set @CompOff_String = ''
		Declare @LEAVE_APPLICATION_ID AS NUMERIC(18,0)
		Declare @LEAVE_APPROVAL_ID AS NUMERIC(18,0)	   
		Declare @APPROVAL_STATUS char(1)
		Declare @System_Date As DateTime
		Set @System_Date=GetDate()
		SET @LEAVE_APPLICATION_ID = NULL  
		SET @LEAVE_APPROVAL_ID=0  
		SET @APPROVAL_STATUS ='A'
		if @S_EMP_ID  = 0 
			set @S_Emp_ID = null
		
		IF OBJECT_ID('tempdb..#leave_detail') IS NOT NULL
		  DROP TABLE #leave_detail
		
		CREATE table #leave_detail
		(
			From_Date datetime,
			End_Date datetime,
			Period numeric(18,2),
			leave_Date nvarchar(max), 
			StrWeekoff_Date nvarchar(max), 
			StrHoliday_Date nvarchar(max)
		)
		
		IF OBJECT_ID('tempdb..#temp_CompOff') IS NOT NULL
		  DROP TABLE #temp_CompOff
		
		   create table #temp_CompOff
			(
				Leave_opening	decimal(18,2),
				Leave_Used		decimal(18,2),
				Leave_Closing	decimal(18,2),
				Leave_Code		varchar(max),
				Leave_Name		varchar(max),
				Leave_ID		numeric,
				CompOff_String  varchar(max) default null 
			)	
			
			
	insert into #leave_detail
		exec dbo.Calculate_Leave_End_Date @cmp_id,@emp_id,@leave_id,@from_date,@Leave_Period,'E',@CancelWOHO
	
		select @To_Date = End_Date from #leave_detail 
	
		

	if @LEave_Assign = ''
		begin
			set @LEave_Assign = 'Full Day'
		end
		
	if @Leave_Id =0
	begin
		Set @Log_Status=1
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Leave Doesn''t exists',@Leave_Name,'Enter proper Leave Name',GetDate(),'Leave Approval',Null)
		return
	end
    
     if @Emp_Id =0
			begin
				Set @Log_Status=1
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee Doesn''t exists',@EMP_CODE,'Enter proper Employee Code',GetDate(),'Leave Approval',Null)			
				return
			end
   
   IF @DEFAULT_SHORT_NAME = 'COPH'
		BEGIN
			EXEC GET_COPH_DETAILS @TO_DATE,@CMP_ID,@EMP_ID,@LEAVE_ID,0,3,@LEAVE_PERIOD	
		END
	ELSE IF @DEFAULT_SHORT_NAME = 'COND'
		BEGIN
			EXEC GET_COND_DETAILS @TO_DATE,@CMP_ID,@EMP_ID,@LEAVE_ID,0,3,@LEAVE_PERIOD	
		END
	ELSE
		BEGIN
			EXEC GET_COMPOFF_DETAILS @TO_DATE,@CMP_ID,@EMP_ID,@LEAVE_ID,0,0,3,@LEAVE_PERIOD	
		END	
   SELECT @COMPOFF_STRING = ISNULL(COMPOFF_STRING,'') FROM #TEMP_COMPOFF
		--exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Emp_ID,@leave_ID,0,0,3,@Leave_Period	
		--select @CompOff_String = isnull(CompOff_String,'') from #temp_CompOff
		
		
		If @CompOff_String  = ''
			begin
				
				Set @Log_Status=1
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee have not sufficient balance for compOff Leave',@EMP_CODE,'should be Credited CompOff Balance ',GetDate(),'Leave Approval',NULL)			
				return
			end
		
		
		
		If exists(select Emp_ID From dbo.T0130_Leave_Approval_detail LAD WITH (NOLOCK) inner join
								T0120_Leave_Approval LA WITH (NOLOCK) ON LAD.Leave_Approval_ID = LA.Leave_Approval_ID
									where LA.Cmp_ID = @Cmp_ID and LA.Emp_ID = @Emp_ID  and LA.Approval_Status <> 'R' and 
								((@From_Date >= from_date and @From_Date <= to_date) or 
								(@To_Date >= from_date and 	@To_Date <= to_date) or 
								(from_date >= @From_Date and from_date <= @To_Date) or
								(to_date >= @From_Date and to_date <= @To_Date)) AND @Leave_Period <> 0.5
			 )			
				BEGIN
										
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Leave Already Assign for given Date',@From_Date,'Enter proper Leave Period',GetDate(),'Leave Approval',NULL)
					set @Log_Status = 1
					
					RETURN 
				END
		ELSE
				BEGIN
				
					If exists(select Emp_ID From dbo.T0130_Leave_Approval_detail LAD WITH (NOLOCK) inner join
								T0120_Leave_Approval LA WITH (NOLOCK) ON LAD.Leave_Approval_ID = LA.Leave_Approval_ID
									where LA.Cmp_ID = @Cmp_ID and LA.Emp_ID = @Emp_ID  and LA.Approval_Status <> 'R' and 
								((@From_Date >= from_date and @From_Date <= to_date) or 
								(@To_Date >= from_date and 	@To_Date <= to_date) or 
								(from_date >= @From_Date and from_date <= @To_Date) or
								(to_date >= @From_Date and to_date <= @To_Date)) AND Leave_Period = 0.5 AND Leave_Assign_As = @LEave_Assign )			
					BEGIN
						Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Leave Already Assign for given Date',@From_Date,'Enter proper Leave Period',GetDate(),'Leave Approval',NULL)
						set @Log_Status = 1
						RETURN 
					END
				END
			
	 IF @TRAN_TYPE  = 'I'  
		BEGIN      
       
			SELECT  @Leave_Approval_ID = ISNULL(MAX(Leave_Approval_ID),0) + 1  FROM T0120_LEAVE_APPROVAL WITH (NOLOCK)
		
			INSERT INTO T0120_LEAVE_APPROVAL  
				  (Leave_Approval_ID, Leave_Application_ID, Cmp_ID, Emp_ID, S_Emp_ID, Approval_Date, Approval_Status, Approval_Comments, Login_ID,System_Date)                
			VALUES     
			  (@Leave_Approval_ID,@Leave_Application_ID,@Cmp_ID,@Emp_ID,@S_Emp_ID,@System_Date,@Approval_Status,@Approval_Comments,@Login_ID,@System_Date)
		    
			If @Leave_Period = 0.5 or @Leave_Period = 0.25 or @Leave_Period = 0.75  
				exec P0130_LEAVE_APPROVAL_DETAIL NULL,@Leave_Approval_ID,@CMP_ID,@Leave_Id,@From_Date,@To_Date,@Leave_Period,@LEave_Assign,@APPROVAL_COMMENTS,@LOGIN_ID,@SYSTEM_DATE,@Is_Import,@TRAN_TYPE,@CancelWOHO,Null,@LOGIN_ID,'','','',0,@CompOff_String,0
			Else	
				exec P0130_LEAVE_APPROVAL_DETAIL NULL,@Leave_Approval_ID,@CMP_ID,@Leave_Id,@From_Date,@To_Date,@Leave_Period,@LEave_Assign,@APPROVAL_COMMENTS,@LOGIN_ID,@SYSTEM_DATE,@Is_Import,@TRAN_TYPE,@CancelWOHO,Null,@LOGIN_ID,'','','',0,@CompOff_String,0
				
		END
	
	if Exists(Select Im_Id from T0080_Import_Log WITH (NOLOCK) where convert(varchar(50),for_date,103) = Convert(varchar(50),getdate(),103) and import_type = 'Leave Approval' and Cmp_Id = @CMP_ID)
		begin 
				set @Log_Status = 1
	    end
 
END

