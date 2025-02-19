



CREATE PROCEDURE [DBO].[SP_EMP_INOUT_SYNCHRONIZATION_AUTO_19_Jul_2014]
	@CMP_ID NUMERIC 
As


 	SET NOCOUNT ON;    
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT OFF;  
	SET ANSI_WARNINGS OFF;

DECLARE @Emp_ID NUMERIC(18,0)
DECLARE @From_Date datetime
DECLARE @To_Date datetime

DECLARE @Day_Sync Numeric
SET @Day_Sync = 30
	
	
	IF OBJECT_ID('tempdb..#EMP_INOUT_RECORD') IS NOT NULL
    DROP TABLE #EMP_INOUT_RECORD
    
	SELECT * Into #EMP_INOUT_RECORD FROM T0150_EMP_INOUT_RECORD 
	----Where For_Date > cast(cast(Getdate() AS varchar(11))AS datetime) -30
	WHERE(
	(cast(cast(In_Time AS varchar(11))AS datetime) > cast(cast(Getdate() AS varchar(11))AS datetime) - @Day_Sync)
	OR
	(cast(cast(Out_Time AS varchar(11))AS datetime) > cast(cast(Getdate() AS varchar(11))AS datetime) - @Day_Sync)
	)

DECLARE Emp_InOut_cursor cursor Fast_forward for

SELECT 
EMP.Cmp_ID,
EMP.Emp_ID,
Cast(Cast(MIN(IDateTime) as varchar(11)) as DateTime)as From_Date
--,Device_IoData.*,Emp_InOut.*
From (
	select  Enroll_No as userid ,IO_DateTime as IDateTime ,ip_address ,Isnull(Is_Verify ,0) as Is_Verify
	from dbo.T9999_DEVICE_INOUT_DETAIL   
	Where cast(cast(IO_DateTime AS varchar(11))AS datetime) > cast(cast(Getdate() AS varchar(11))AS datetime) - @Day_Sync
	
	UNION all	
	
	SELECT EM.Enroll_No,DID.IO_DateTime,DID.IMEI_No AS 'IP_Address',Isnull(Is_Verify ,0) as Is_Verify
	FROM T9999_MOBILE_INOUT_DETAIL DID 
	INNER JOIN T0080_EMP_MASTER EM ON DID.Emp_ID = EM.Emp_ID
	WHERE  cast(cast(DID.IO_DateTime AS varchar(11))AS datetime) > cast(cast(Getdate() AS varchar(11))AS datetime) - @Day_Sync
	
	)as Device_IoData  
 Left join  
 (  
  
SELECT IO_Tran_ID,T0080_EMP_MASTER.Enroll_No ,MaxDate from (
	SELECT IO_Tran_ID,Emp_ID,in_time as MaxDate ,ip_address FROM #EMP_INOUT_RECORD 
	UNION all
	SELECT IO_Tran_ID,Emp_ID ,Out_time as MaxDate,ip_address FROM #EMP_INOUT_RECORD
) as Inout 
 Inner join  
		T0080_EMP_MASTER on Inout.Emp_id=T0080_EMP_MASTER.Emp_id 
		where MaxDate IS NOT NULL 
) as Emp_InOut  

 on Device_IoData.userid = Emp_InOut.Enroll_No  
 --and Device_IoData.IDateTime = Emp_InOut.MaxDate   
	And CAST((cast( Device_IoData.IDateTime as varchar(11)) + ' ' + dbo.F_GET_AMPM( Device_IoData.IDateTime)) as datetime)
	= CAST((cast(Emp_InOut.MaxDate as varchar(11)) + ' ' + dbo.F_GET_AMPM(Emp_InOut.MaxDate)) AS datetime)
 
 
 Inner join  
 T0080_EMP_MASTER AS EMP on UserId=EMP.Enroll_No  
 
 Left Outer Join
 (
 
 ----SELECT Emp_id,Isnull(MAX(Month_End_Date) ,'01-01-1900') as Month_End_Date 
 ----FROM  T0200_MONTHLY_SALARY Group BY Emp_ID 
 SELECT Emp_id,
 Isnull(MAX(ISNULL(Cutoff_Date,Month_End_Date)),'01-01-1900')as Month_End_Date
 FROM  T0200_MONTHLY_SALARY
 Group BY Emp_ID 
 
 )As SAL on 
	EMP.Emp_ID  = SAL.Emp_Id
	
 WHERE
  
 userid > 0 
 AND isnull(Emp_InOut.IO_Tran_ID,0) = 0  
 AND isnull(Emp_InOut.Enroll_No,0) = 0 
  
 AND Date_Of_Join < Cast(Cast(Device_IoData.IDateTime as varchar(11)) as DateTime) 
 AND Cast(Cast(Device_IoData.IDateTime as varchar(11)) as DateTime) <= ISNULL(Emp_Left_Date,cast(cast(Getdate() AS varchar(11))AS datetime) )
   
 AND Cast(Cast(Device_IoData.IDateTime as varchar(11)) as DateTime) > Isnull(SAL.Month_End_Date ,'01-01-1900')
 
 AND isnull(is_verify,0) = 0
 
   
 AND NOT EXISTS
    (SELECT 
     * From 
     (
			SELECT Distinct Emp_id ,For_Date  From #EMP_INOUT_RECORD  
			WHERE (isnull(Reason,'') <> '' OR isnull(ManualEntryFlag,'N') <> 'N' )
			
			)As IO_DATA
   
			WHERE  IO_DATA.For_Date=Cast(Cast(Device_IoData.IDateTime as varchar(11)) as DateTime) 
			AND IO_DATA.Emp_Id=EMP.Emp_ID 
        )

AND Not Exists
(
	Select IP_Address from 
	(select IP_Address From T0040_IP_MASTER Where Device_No > 200) as IP_Mast
	
	Where Device_IoData.IP_Address = IP_Mast.IP_ADDRESS
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
 ,@PBranch_ID = '0'  
 ,@Check_Regularization_Flag  = 0 
 ,@PVertical_ID	= '' 
 ,@PSubVertical_ID	= '' 
 ,@PDept_ID ='' 
 ,@User_Id =0 
 ,@IPAddress  ='' 
 ,@Return_Record  =0  

   FETCH NEXT FROM Emp_InOut_cursor INTO @Cmp_ID,@Emp_ID,@From_Date
END 
CLOSE Emp_InOut_cursor
DEALLOCATE Emp_InOut_cursor


/*
	--Added by Hardik 15/06/2016
	DECLARE	@In_Out_Flag_SP tinyint
	SET @In_Out_Flag_SP = 0

	SELECT	@In_Out_Flag_SP = ISNULL(Setting_Value,0) 
	FROM	T0040_SETTING 
	WHERE	Setting_Name='In and Out Punch depends on Device In-Out Flag' and Cmp_ID = @Cmp_ID
	 

	DECLARE @Emp_ID NUMERIC(18,0)
	--DECLARE @Cmp_ID int
	DECLARE @IO_DateTime datetime
	DECLARE @IP_Address nvarchar(50)
	Declare @In_Out_flag numeric 

	DECLARE Emp_InOut_cursor CURSOR FOR 

	SELECT	MaxDt.Emp_ID,MaxDt.Cmp_ID,InOut.IO_DateTime,InOut.IP_Address,(CASE WHEN  ISNULL(InOut.In_Out_flag,'') = '' THEN 0 ELSE InOut.In_Out_Flag END) AS In_Out_flag
	FROM	T9999_DEVICE_INOUT_DETAIL AS InOut
			INNER JOIN (
						SELECT	e.Cmp_Id,e.Emp_ID,E.Enroll_No,
								ISNULL(CASE WHEN ISNULL(In_Time,'01-01-1900') > ISNULL(Out_Time,'01-01-1900') THEN In_Time ELSE Out_Time END,'01-01-1900') AS InOut_Time 
						FROM	T0080_Emp_Master e 
								LEFT OUTER JOIN (	SELECT	eir.Emp_ID ,max(In_Time)In_Time,max(Out_time)Out_Time 
													FROM	T0150_Emp_Inout_Record eir 
													GROUP BY emp_ID ) q ON e.emp_ID = q.emp_ID  
						WHERE isnull(emp_Left,'N') <> 'Y'  
						) AS MaxDt ON InOut.Enroll_No = MaxDt.Enroll_No 
	WHERE	CAST(CAST(InOut.IO_DateTime AS VARCHAR(11)) + ' ' + dbo.F_GET_AMPM(InOut.IO_DateTime) AS DATETIME) > CAST(CAST(MaxDt.InOut_Time AS VARCHAR(11)) + ' ' + dbo.F_GET_AMPM(MaxDt.InOut_Time) AS DATETIME)
	ORDER BY InOut.Enroll_No,InOut.IO_DateTime
	  
	OPEN Emp_InOut_cursor
	FETCH NEXT FROM Emp_InOut_cursor INTO @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address,@In_Out_flag
	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @IO_DATETIME = CAST(CAST(@IO_DATETIME AS VARCHAR(11)) + ' ' + dbo.F_GET_AMPM(@IO_DATETIME) AS DATETIME)

			IF @In_Out_Flag_SP = 1 --Added by Hardik 15/06/2016
				EXEC SP_EMP_INOUT_SYNCHRONIZATION_WITH_INOUT_FLAG @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address ,@in_out_flag,0 --------------Sp will Execute for HNG Halol 17022016----------------------------------
			ELSE if @In_Out_Flag_SP = 2
				EXEC SP_EMP_INOUT_SYNCHRONIZATION_12AM_SHIFT_TIME @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address ,@in_out_flag,0 --- Added for Aculife 
			Else	
				EXEC SP_EMP_INOUT_SYNCHRONIZATION  @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address ,0,0


			FETCH NEXT FROM Emp_InOut_cursor INTO  @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address,@In_Out_flag
		END 
	CLOSE Emp_InOut_cursor
	DEALLOCATE Emp_InOut_cursor

*/




