--exec P0100_EMP_RETAINTION_STATUS @Cmp_ID =120,@Emp_ID=,@For_Date ='', @Start_Date='',@Is_Retain='',@End_Date=''
-- =============================================
-- Author:		Deepali Mhaske
-- Create date: 20-12-2021
-- Description:	[P0100_EMP_RETAINTION_STATUS] 
-- =============================================
CREATE PROCEDURE [dbo].[P0100_EMP_RETAINTION_STATUS]
	  @Cmp_ID numeric(18,0)
	 ,@Emp_ID numeric(18,0)
	 ,@For_Date datetime
	 ,@Start_Date datetime
	 ,@Is_Retain	tinyint = 1
	 ,@End_Date datetime=Null
	 ,@tran_type varchar(1) = 'I'
	 ,@User_Id numeric(18,0) = 0 
	 ,@RTRAN_ID NUMERIC(18,0)  = 0 output
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
		if @tran_type = 'D'
			BEGIN
			if( @Is_Retain=0)
			begin
				IF EXISTS (SELECT 1 FROM T0210_Retaining_Payment_Detail WHERE Start_Date = @Start_Date  and Emp_ID = @Emp_id AND End_Date = @End_Date)
					BEGIN
						--print 'Cannot be Deleted Reference Exist In Payment Process'
						Raiserror('Cannot be Deleted Reference Exist In Payment Process',16,2)						
						return -1
					END
				ELSE
				Begin
					--Print 'Delete'
					delete FROM T0100_EMP_RETAINTION_STATUS where Emp_id = @Emp_ID AND Start_Date = @Start_Date AND End_Date = @End_Date AND Is_Retain_ON = @Is_Retain
				End		
			end				
			else
			Begin
				IF(ISNULL(@RTRAN_ID,0) <> 0)
					delete FROM T0100_EMP_RETAINTION_STATUS where TRAN_ID = @RTRAN_ID AND Emp_id = @Emp_ID  
				ELSE
					delete FROM T0100_EMP_RETAINTION_STATUS where Emp_id = @Emp_ID AND Start_Date = @Start_Date AND Is_Retain_ON = @Is_Retain
			End
			END
		else if @tran_type = 'I' or  @tran_type = 'U'
			BEGIN
				declare @tran_id numeric(18,0)
				SELECT @tran_id = isnull(max(Tran_Id),0) + 1 FROM T0100_EMP_RETAINTION_STATUS WITH (NOLOCK)				
				Declare @Is_Retain_ON tinyint = 0
				Declare @DiffDay integer
				Declare @TotDiffDay integer =0		
				
				IF EXISTS (SELECT 1 FROM T0100_EMP_RETAINTION_STATUS WHERE @Start_Date between Start_Date and End_Date  and Emp_ID = @Emp_id )
					BEGIN
						--print 'Cannot be Deleted Reference Exist In Payment Process
						Raiserror('@@ Selected Employee already Exist. Cannot be Inserted Duplicate Record. @@',16,2)						
						return -1
					END
				

				IF exists (SELECT Tran_Id FROM T0100_EMP_RETAINTION_STATUS WITH (NOLOCK) where Emp_id = @Emp_ID AND Start_Date = @Start_Date  and  @tran_type = 'U')
					begin					
							SELECT @Is_Retain_ON = is_Retain_ON FROM T0100_EMP_RETAINTION_STATUS WITH (NOLOCK) where Emp_id = @Emp_ID AND Start_Date = @Start_Date  
							if @Is_Retain_ON = 1   and  @tran_type = 'U'
							begin 
							--------------------

							Declare  @New_Emp_Ret_Count as integer
							set @New_Emp_Ret_Count=0
						

							select @New_Emp_Ret_Count = count(*)  from T0090_Retaining_Lock_Setting MON ,T0100_EMP_RETAINTION_STATUS t
							where  MON.Cmp_Id = @Cmp_ID and Emp_id = @Emp_ID and @Start_Date between  MON.From_Date  and MON.To_Date 
							and  @End_Date between  MON.From_Date  and MON.To_Date 
						
							print @New_Emp_Ret_Count
							
			
						IF Not EXISTS (SELECT 1 from T0090_Retaining_Lock_Setting MON ,T0100_EMP_RETAINTION_STATUS t where  MON.Cmp_Id = @Cmp_ID and Emp_id = @Emp_ID and @Start_Date between  MON.From_Date  and MON.To_Date and  @End_Date between  MON.From_Date  and MON.To_Date )
			
							BEGIN
									--print 'Cannot be Deleted Reference Exist In Payment Process
											Raiserror('@@ Please Select Different End Date As Retaining Month Lock period is different. Record Cannot be Inserted. @@',16,2)						
									return -1
							END
							else
					begin
							---------------------
							set @DiffDay = datediff(d,@Start_Date,@End_Date) +1
								Update T0100_EMP_RETAINTION_STATUS set  is_Retain_ON =0,End_Date=@End_Date,  System_Date_End  = GETDATE() ,Tot_Retain_Days =@DiffDay
								where Emp_id = @Emp_ID AND Start_Date = @Start_Date								 
					end
					End
					end
				else
					begin
							INSERT INTO T0100_EMP_RETAINTION_STATUS
							  (Tran_Id, Cmp_Id, Emp_Id, For_Date,Start_Date, is_Retain_ON,[User_ID],System_Date_Start)
							VALUES     (@tran_id,@Cmp_ID ,@Emp_ID ,@For_Date,@Start_Date,@Is_Retain,@User_Id,GETDATE())
					end
			END

	RETURN




