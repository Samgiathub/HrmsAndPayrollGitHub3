

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Auto_Sync_InOut_Data]  
 @Path nvarchar(Max),
 @File_Name nvarchar(Max)
as  
 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
 
Declare @LogFile as nvarchar(50)  
Declare @todayDate as nvarchar(20)  
Declare @Date as varchar(10)  
Declare @Time as varchar(10)  
Declare @Enroll as nvarchar(10)  
DECLARE @In_DateTimeValue nvarchar(max)  
DECLARE @Out_DateTimeValue nvarchar(max)    
Declare @Emp_ID numeric(18,0)
Declare @Cmp_Id numeric(18,0)

delete from Attendance_Log
Set @LogFile= @Path 
  
exec sp_readTextFile @Logfile  
 
Declare @Atten_data as varchar(1000)
Declare @id as numeric(18,0)
Declare @data as varchar(max)
Declare @Ipaddress as varchar(max)
Declare @For_date as varchar(max)
set @In_DateTimeValue=''
declare @IO_Duration varchar(30)
 
 declare @Dt_For_date as datetime
 declare @Dt_In_DateTimeValue as datetime
 declare @Dt_Out_DateTimeValue as datetime
 declare @Int_IO_Duration as numeric(18,0)
 
 Declare @Not_Match_Enroll_No as Varchar(Max)
 Set @Not_Match_Enroll_No = ''

If OBJECT_ID('tempdb..##Enroll_No') IS NOT NULL DROP TABLE ##Enroll_No
If OBJECT_ID('tempdb..#Tmp_Split') IS NOT NULL DROP TABLE #Tmp_Split  
  
CREATE table #Tmp_Split
(
	Id numeric(18,0),
	Data nvarchar(50)
)



CREATE table ##Enroll_No
(
	Emp_Id numeric(18,0),
	Cmp_Id Numeric,
	Enroll_No nvarchar(50)
)
  
  Insert Into ##Enroll_No
  Select Emp_Id,Cmp_Id, ',' + cast(DBRD_Code as varchar(50)) + ',' From T0080_EMP_MASTER WITH (NOLOCK) Where isnull(DBRD_Code,'') <> '' and DBRD_Code <> '0'
  --Select Emp_Id,Cmp_Id, ',' + cast(Enroll_No as varchar(50)) + ',' From T0080_EMP_MASTER Where isnull(Enroll_No,0) <> 0

DECLARE Atten_Cursor CURSOR FOR  
 SELECT Atten_data FROM Attendance_Log  
 OPEN Atten_Cursor  
  fetch next from Atten_Cursor into @Atten_data 
  while @@fetch_status = 0  
   Begin   
		if PATINDEX('%date%', @Atten_data) =0 
			Begin 
				 set @Atten_data = replace(@atten_data,SPACE(1) ,'#')
				 set @Atten_data = replace(@atten_data,CHAR(9) ,'#')
			  
			     set @In_DateTimeValue =''
				 set @Out_DateTimeValue=''
				 set @IO_Duration=''
				 set @Emp_ID = null
				 
		         delete from #Tmp_Split
		          
		         insert into #Tmp_Split
					select * from  dbo.SplitString(@Atten_data,'#' )
					
				Select @For_date= data from #Tmp_Split where ID in (1) order by id --for_date  
				Select @Enroll= data from #Tmp_Split where ID in (2) order by id --enroll no
				select @In_DateTimeValue = COALESCE(@In_DateTimeValue + ' ', '') + data from #Tmp_Split where ID in (4,5,6) order by id --in time
				select @Out_DateTimeValue = COALESCE(@Out_DateTimeValue + ' ', '') + data from #Tmp_Split where ID in (7,8,9) order by id --out time 
				select @Ipaddress=data from #Tmp_Split where ID in (3) --ip address
				select @IO_Duration= cast(data as numeric(18,0)) from #Tmp_Split where ID in (10) --duration
				
				if exists(select 1 from #Tmp_Split where ID in (7,8,9) and DATA = '0')
					begin
						set @Out_DateTimeValue =null
					End
		
				if @In_DateTimeValue is not null
					Begin					
						exec P9999_DEVICE_INOUT_DETAIL_INSERT @Enroll,@In_DateTimeValue,@Ipaddress
					End
				if @Out_DateTimeValue is not null
					Begin						
						exec P9999_DEVICE_INOUT_DETAIL_INSERT @Enroll,@Out_DateTimeValue,@Ipaddress
					End

				--Select @Emp_ID = Emp_ID, @Cmp_Id = Cmp_ID from T0080_EMP_MASTER Where Enroll_No = @Enroll
				Select @Emp_ID = Emp_ID, @Cmp_Id = Cmp_ID from ##Enroll_No Where Enroll_No like '%,' + cast(@Enroll as varchar(50)) + ',%'
				--Select @Emp_ID = Emp_ID, @Cmp_Id = Cmp_ID from T0080_EMP_MASTER where  @Enroll IN (SELECT data from dbo.Split(Enroll_No,',')) 
				 
				
				
				if @Emp_ID is not null and @Out_DateTimeValue is not null 
					Begin
					 set @Dt_For_date =CAST(@For_date as datetime)
					 set @Dt_In_DateTimeValue =CAST(@In_DateTimeValue as datetime)
					 set @Dt_Out_DateTimeValue =CAST(@Out_DateTimeValue as datetime)
					 set @Int_IO_Duration =CAST(@IO_Duration as numeric(18,0))
					
					If @In_DateTimeValue <> @Out_DateTimeValue
						Begin
							exec SP_EMP_INOUT_SYNCHRONIZATION_Azure @Emp_ID,@Cmp_Id,@Dt_For_date,@Dt_In_DateTimeValue,@Dt_Out_DateTimeValue,@Int_IO_Duration,@Ipaddress
						End	
				   End
				 Else
					Begin
						If CharIndex(@Enroll,@Not_Match_Enroll_No) = 0
							Begin
								If @Not_Match_Enroll_No = ''									
									Set @Not_Match_Enroll_No = Cast(@Enroll As Varchar(50))
								Else
									Set @Not_Match_Enroll_No = @Not_Match_Enroll_No + ', ' + Cast(@Enroll As Varchar(50))
							End
					End
			 set @In_DateTimeValue =''
			 set @Out_DateTimeValue=''
			 set @IO_Duration=''
			 delete from #Tmp_Split
			End
			
   fetch next from Atten_Cursor into @Atten_data 
   End  
 close Atten_Cursor   
 deallocate Atten_Cursor
 
--Hardik 16/05/2013
If @Not_Match_Enroll_No <> '' 
	Begin
		Insert Into SAR_Not_Match_Enroll_No
		Select Cast(GETDATE() as varchar(11)),@Not_Match_Enroll_No,@File_Name
	End
 
 drop table ##Enroll_No
 delete from Attendance_Log

