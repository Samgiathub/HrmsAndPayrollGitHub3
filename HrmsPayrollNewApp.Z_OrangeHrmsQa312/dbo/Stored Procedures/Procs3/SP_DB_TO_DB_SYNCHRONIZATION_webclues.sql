
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_DB_TO_DB_SYNCHRONIZATION_webclues]
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

/*
DECLARE @LastDays INT
SET @LastDays  = 16 
Declare @MaxNo as numeric(18,0)
select @MaxNo= isnull(MAX(IO_Tran_ID),0) from [HRMS].[webclues].dbo.[T9999_DEVICE_INOUT_DETAIL]


/*Getting Existing Records of 15 Days before from Today*/
select	T.Enroll_No, IO_DateTime
INTO	#ExistingRecords
from	 [HRMS].[webclues].[dbo].[T9999_DEVICE_INOUT_DETAIL] T		
WHERE	IO_DATETIME > DATEADD(D, @LastDays * -1, getDate())
		--INNER JOIN #LastRecords L ON T.ENROLL_NO = L.ENROLL_NO AND T.IO_DateTime > L.Max_IO_DateTime



insert into [HRMS].[webclues].[dbo].[T9999_DEVICE_INOUT_DETAIL]
IO_Tran_ID,Cmp_ID,Enroll_No,IO_DateTime,IP_Address,In_Out_flag,Is_Verify)
SELECT	@MaxNo+RowNo as IO_Tran_ID,1 As Cmp_ID,UserID,IDateTime,Ip_address,In_Out_flag,'0'
FROM	(
			SELECT  ROW_NUMBER() OVER (ORDER BY cardNO,In_Out_Time) AS RowNo, cardNO as UserId,In_Out_Time AS IDateTime,deviceip as Ip_address,case when d.mode = 'IN' then 0 when d.mode = 'OUT' then 1 else -1 end as In_Out_flag
			From tmpDmpTerminalData t inner join devicemaster d on t.devicecode = d.devicecode
					LEFT  OUTER JOIN #ExistingRecords ER ON T.cardNO collate SQL_Latin1_General_CP1_CI_AS = ER.Enroll_No And T.In_Out_Time  = ER.IO_DateTime --Join existing record in Orange_HRMS database to check if it is already exist
			WHERE	ER.Enroll_No Is Null -- This condition is used to check if record exist then it should not be taken 
					--AND eDateTime > '01-JAN-2019' --and UserID Like '%001%'		
					AND In_Out_Time > DATEADD(D, @LastDays * -1, getDate()) --and UserID Like '%001%'		
		)AS T
order by UserID,IDateTime
drop table #ExistingRecords
*/

