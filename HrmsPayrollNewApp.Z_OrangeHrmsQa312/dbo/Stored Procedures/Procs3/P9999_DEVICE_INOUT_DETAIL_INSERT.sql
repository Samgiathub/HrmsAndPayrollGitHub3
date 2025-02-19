

---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_DEVICE_INOUT_DETAIL_INSERT]
	@ENROLL_NO		NUMERIC,
	@IO_DateTime	Datetime,
	@IP_Address		varchar(50),
	@Ver			Numeric = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @IO_Tran_ID numeric 
	Declare @Cmp_ID		numeric 
	
	if @IO_DateTime > getdate()
		begin 
			return
		end
	
	--------------------- Add by jigensh 30-Apr-2015---- For Canteen Entry Client:- Apollo ----
	
	if  @IP_Address='Canteen'
	begin
	      set @Ver =10
	end
	
	if  exists(select IP_Address from T0040_IP_MASTER WITH (NOLOCK) where IP_Address=@IP_Address and Device_No > 200)
	begin
	     set @Ver =10
	end
	------------------------------- End ------------------------
	
	if not exists(select enroll_no from dbo.T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK) Where Enroll_No=@Enroll_No and IO_DateTime =@IO_DateTime)
		Begin	
			Select @IO_Tran_ID= isnull(Max(IO_Tran_ID),0) + 1  from dbo.T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK)
			
			
			-- Added Condition by Hardik 26/11/2013 for AZURE SAR File Import, ##Enroll_No will create in this SP : Auto_Sync_InOut_Data
			If  OBJECT_ID (N'tempdb..##Enroll_No') Is null
				Begin
					if  not exists( select Cmp_ID from dbo.T0080_emp_Master WITH (NOLOCK) where Enroll_no = @Enroll_No) 
						begin 
							return
						end
					Else
						Begin
							Select @Cmp_ID = Cmp_ID from dbo.T0080_emp_Master WITH (NOLOCK) where Enroll_no =@Enroll_No 
						End
				End
			Else
				Begin
					If not exists(Select 1 from ##Enroll_No Where Enroll_No like '%,' + cast(@Enroll_No as varchar(50)) + ',%')
						Begin					
							return					
						End					
					else					
						begin					
							Select @Cmp_Id = Cmp_ID from ##Enroll_No Where Enroll_No like '%,' + cast(@Enroll_No as varchar(50)) + ',%'
						end					
				End
			
			-------- Modify jigensh 13-Sep-2016---- for Identity column----------
			
			--INSERT INTO dbo.T9999_DEVICE_INOUT_DETAIL
			--					  (IO_Tran_ID, Cmp_ID, Enroll_No, IO_DateTime, IP_Address,In_Out_flag)
			--VALUES     (@IO_Tran_ID, @Cmp_ID, @Enroll_No, @IO_DateTime, @IP_Address,@Ver)
		
		
	if Not Exists ( select COLUMN_NAME, TABLE_NAME
					  from INFORMATION_SCHEMA.COLUMNS
					   where TABLE_SCHEMA = 'dbo'
					   and COLUMNPROPERTY(object_id(TABLE_NAME), COLUMN_NAME, 'IsIdentity') = 1
					   and Table_Name = 'T9999_DEVICE_INOUT_DETAIL'
					   and COLUMN_NAME = 'IO_Tran_ID')
		   begin
			
			INSERT INTO dbo.T9999_DEVICE_INOUT_DETAIL
								  (IO_Tran_ID, Cmp_ID, Enroll_No, IO_DateTime, IP_Address,In_Out_flag)
			VALUES     (@IO_Tran_ID, @Cmp_ID, @Enroll_No, @IO_DateTime, @IP_Address,@Ver)
		
		   end
	 else
	 
			begin
			
			INSERT INTO dbo.T9999_DEVICE_INOUT_DETAIL
								  ( Cmp_ID, Enroll_No, IO_DateTime, IP_Address,In_Out_flag)
			VALUES     ( @Cmp_ID, @Enroll_No, @IO_DateTime, @IP_Address,@Ver)
		
			
			end	   
   
       ---------------------- End -----------------------
		
		
		End	
	RETURN
	



