


CREATE  PROCEDURE [dbo].[Sync_Auto_FromDate_To_Date]
(
@Cmp_ID NUMERIC(18,0)
)
as

 	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON  
	SET ANSI_WARNINGS OFF;

DECLARE @Emp_ID NUMERIC(18,0)
DECLARE @From_Date datetime
DECLARE @To_Date datetime
	
	
	IF OBJECT_ID('tempdb..#EMP_INOUT_RECORD') IS NOT NULL
    DROP TABLE #EMP_INOUT_RECORD
    
	SELECT * Into #EMP_INOUT_RECORD FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK)
	Where For_Date > GETDATE()-45


DECLARE Emp_InOut_cursor cursor Fast_forward for

SELECT 
EMP.Cmp_ID,
EMP.Emp_ID,
Cast(Cast(MIN(IDateTime) as varchar(11)) as DateTime)as From_Date
--,Device_IoData.*,Emp_InOut.*
From (
	select  Enroll_No as userid ,IO_DateTime as IDateTime ,ip_address  
	from dbo.T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK)   
	Where IO_DateTime > Getdate()-30
	
	UNION all	
	
	SELECT EM.Enroll_No,DID.IO_DateTime,DID.IMEI_No AS 'IP_Address'
	FROM T9999_MOBILE_INOUT_DETAIL DID WITH (NOLOCK)
	INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON DID.Emp_ID = EM.Emp_ID
	WHERE DID.IO_DateTime >Getdate()-30
	)as Device_IoData  
 Left join  
 (  
  
SELECT IO_Tran_ID,T0080_EMP_MASTER.Enroll_No ,MaxDate from (
	SELECT IO_Tran_ID,Emp_ID,in_time as MaxDate ,ip_address FROM #EMP_INOUT_RECORD 
	UNION all
	SELECT IO_Tran_ID,Emp_ID ,Out_time as MaxDate,ip_address FROM #EMP_INOUT_RECORD
) as Inout 
 Inner join  
		T0080_EMP_MASTER WITH (NOLOCK) on Inout.Emp_id=T0080_EMP_MASTER.Emp_id 
		where MaxDate IS NOT NULL 
) as Emp_InOut  

 on Device_IoData.userid = Emp_InOut.Enroll_No  
 and Device_IoData.IDateTime = Emp_InOut.MaxDate   
 
 Inner join  
 T0080_EMP_MASTER AS EMP WITH (NOLOCK) on UserId=EMP.Enroll_No  
 
 Left Outer Join
 (
 SELECT Emp_id,Isnull(MAX(Month_End_Date) ,'01-01-1900') as Month_End_Date 
 FROM  T0200_MONTHLY_SALARY WITH (NOLOCK) Group BY Emp_ID 
 )As SAL on 
	EMP.Emp_ID  = SAL.Emp_Id
	
 
 where 
 userid > 0 and
 isnull(Emp_InOut.IO_Tran_ID,0) = 0  
 and isnull(Emp_InOut.Enroll_No,0) = 0  
 
 And Cast(Cast(Device_IoData.IDateTime as varchar(11)) as DateTime) > Isnull(SAL.Month_End_Date ,'01-01-1900')
 
 
AND NOT EXISTS
    (SELECT 
     * From 
     (
			SELECT Distinct Emp_id ,For_Date  From #EMP_INOUT_RECORD  
			--WHERE For_Date > getdate()-30
			WHERE (isnull(Reason,'') <> '' OR isnull(ManualEntryFlag,'N') <> 'N' )
			)As IO_DATA
   
			WHERE  IO_DATA.For_Date=Cast(Cast(Device_IoData.IDateTime as varchar(11)) as DateTime) 
			AND IO_DATA.Emp_Id=EMP.Emp_ID 
        )

        
GROUP BY EMP.Cmp_ID,EMP.Emp_ID
ORDER BY EMP.Emp_ID Asc
  
OPEN Emp_InOut_cursor

FETCH NEXT FROM Emp_InOut_cursor INTO @Cmp_ID,@Emp_ID,@From_Date

WHILE @@FETCH_STATUS = 0
BEGIN

Set @To_Date=cast(cast(Getdate() as varchar(11)) as DateTime)
------Set @From_Date = @From_Date-1

 exec SP_EMP_INOUT_SYNCHRONIZATION_FromDate_ToDate 
  @Cmp_ID		=	@Cmp_ID
 ,@From_Date	=	@From_Date    
 ,@To_Date		=	@To_Date
 ,@Branch_ID	=	0      
 ,@Cat_ID		=	0       
 ,@Grd_ID		=	0      
 ,@Type_ID		=	0      
 ,@Dept_ID		=	0      
 ,@Desig_ID		=	0      
 ,@Emp_ID		=	@Emp_ID     
 ,@constraint   =	''


   FETCH NEXT FROM Emp_InOut_cursor INTO @Cmp_ID,@Emp_ID,@From_Date
END 
CLOSE Emp_InOut_cursor
DEALLOCATE Emp_InOut_cursor


