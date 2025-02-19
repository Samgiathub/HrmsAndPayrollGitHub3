



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_INOUT_SYNCHRONIZATION_FT_COLOR] 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF
	
declare  @Enroll_No as numeric(18,0)
declare  @IO_DateTime as datetime
declare  @IP_Address as varchar(30)

declare  @Emp_id as numeric(18,0)
declare  @cmp_id as numeric(18,0)
declare  @IO_Max_DateTime as datetime
 
DECLARE Cur_Device CURSOR FOR
	
	---Modify Jignesh 02-OCt-2012--------------
	--select Enroll_No,IO_DateTime,IP_Address from t9999_DEVICE_INOUT_DETAIL 
	--where IO_DateTime >= DATEADD(dd,-60,getdate()) order by Enroll_NO,IO_Datetime

	select Enroll_No,IO_DateTime,IP_Address from V9999_DEVICE_INOUT_DETAIL  order by Enroll_NO,IO_Datetime
	
OPEN Cur_Device
	fetch next from Cur_Device into @Enroll_No,@IO_DateTime,@IP_Address
	while @@fetch_status = 0
		Begin
			
		----------------------
		DECLARE Cur_Device_inner CURSOR FOR
			Select Emp_ID,cmp_id from T0080_Emp_master WITH (NOLOCK) where Enroll_No=@Enroll_No
		OPEN Cur_Device_inner
			fetch next from Cur_Device_inner into @Emp_id,@cmp_id
			while @@fetch_status = 0
				Begin
									
				select @IO_Max_DateTime = max(for_date) from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Cmp_ID= @CMP_ID  and Emp_ID =@Emp_id  group by emp_id,cmp_id 
				if @IO_Max_DateTime is not null
					Begin
						if @IO_DateTime > @IO_Max_DateTime	
							Begin
								exec SP_EMP_INOUT_SYNCHRONIZATION @Emp_id,@cmp_id,@IO_DATETIME,@IP_ADDRESS
							End
					End
				else
					Begin
						exec SP_EMP_INOUT_SYNCHRONIZATION @Emp_id,@cmp_id,@IO_DATETIME,@IP_ADDRESS
					End
				fetch next from Cur_Device_inner into @Emp_id,@cmp_id
				End
		close Cur_Device_inner	
		deallocate Cur_Device_inner
		
		fetch next from Cur_Device into @Enroll_No,@IO_DateTime,@IP_Address
		End
close Cur_Device	
deallocate Cur_Device
							
		
RETURN




