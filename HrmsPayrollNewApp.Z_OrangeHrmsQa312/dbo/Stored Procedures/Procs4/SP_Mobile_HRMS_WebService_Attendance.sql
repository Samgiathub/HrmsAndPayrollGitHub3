CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Attendance]    
 @Emp_ID NUMERIC(18,0),  
 @Cmp_ID NUMERIC(18,0),  
 @Vertical_ID NUMERIC(18,0),  
 @SubVertical_ID NUMERIC(18,0),  
 @ForDate DATETIME,  
 @Time DATETIME,  
 @INOUTFlag char(1),  
 @Reason VARCHAR(100),    
 @IMEINo VARCHAR(50),  
  
 @Latitude VARCHAR(50),  
 @Longitude VARCHAR(50),  
 @Address VARCHAR(MAX),  
 @Emp_Image varchar(50),  
 @strAttendance XML,  
 @Month int,  
 @Year int,  
 @Type Char(1),  
 @Result VARCHAR(100) OUTPUT,  
 @SubVerticalName varchar(50) = ''  
AS      
  
SET NOCOUNT ON    
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 SET ARITHABORT ON  
  
DECLARE @IO_Tran_Id NUMERIC(18,0)   
DECLARE @IPAdd varchar(50)  
DECLARE @In_Time varchar(20)  
DECLARE @Out_Time varchar(20)  
DECLARE @IO_DateTime varchar(20)  
DECLARE @Value varchar(50)  
DECLARE @Flag char(1)  
DECLARE @Inout_Duration NUMERIC(10,0)  
DECLARE @Clock_In_Time DATETIME  
SET @IO_Tran_Id= NULL  
  
IF @IMEINo <> ''  
 BEGIN  
  SET @IPAdd = 'Mobile(' + @IMEINo + ')'  
 END  
ELSE  
 BEGIN  
  SET @IPAdd = ''  
 END  
  
  
IF @Type = 'C' -- For Check IN OUT  
 BEGIN  
  --SELECT @IO_Tran_ID = IO_Tran_Id,@In_Time = In_Time,@Out_Time = Out_Time   
  --FROM T0150_EMP_INOUT_RECORD   
  --WHERE In_Time =   
  --(  
  -- SELECT MAX(In_Time) FROM T0150_EMP_INOUT_RECORD   
  -- WHERE Emp_ID= @Emp_ID AND Cmp_ID= @Cmp_ID AND CONVERT(VARCHAR(10),For_Date,120) = CONVERT(VARCHAR(10),GETDATE(),120)  
  --)  
  --AND Emp_ID= @Emp_ID AND Cmp_ID= @Cmp_ID AND CONVERT(VARCHAR(10),For_Date,120) = CONVERT(VARCHAR(10),GETDATE(),120)  
  --IF @IO_Tran_ID IS NULL  
  -- BEGIN  
  --  SET @Result = 'In#0'  
  --  RETURN  
  -- END  
  --ELSE IF @In_Time IS NOT NULL AND @Out_Time IS NULL  
  -- BEGIN  
  --  SET @Result = 'Out#' + CAST(@In_Time as varchar(20))  
  --  RETURN  
  -- END   
  --ELSE IF @Out_Time IS NOT NULL  
  -- BEGIN  
  --  SET @Result = 'In#' + CAST(@Out_Time as varchar(20))  
  --  RETURN  
  -- END  
    
  /*  
  Following Query commented and new Logic added at bellow by Nimesh On 02-Nov-2018  
  SELECT *   
  INTO #Emp_IORecord  
  FROM  
  (  
   SELECT 0 AS 'IO_Tran_DetailsID',IO_flag AS 'In_Out_Flag',IO_Datetime,SUBSTRING(IO_flag,1,CHARINDEX('_',IO_flag) - 1) + ' : Device Punch' AS 'Location','' AS 'Reason'    
   --INTO #Emp_IORecord  
   FROM   
   (  
    SELECT Emp_ID,Cmp_ID,In_Time,Out_Time   
    FROM T0150_EMP_INOUT_RECORD  
    WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID  
   ) emp  
   UNPIVOT  
   ( IO_Datetime FOR IO_flag IN (In_Time,Out_Time) ) U  
     
   --SELECt 0 AS 'IO_Tran_DetailsID',IO_flag,IO_Datetime,'Device Punch' AS 'Location','' AS 'Reason'   
   --FROM #Emp_IORecord  
     
   UNION ALL  
     
   SELECT IO_Tran_DetailsID,In_Out_Flag AS 'In_Out_Flag',IO_Datetime,Location,Reason  
   FROM T9999_MOBILE_INOUT_DETAIL   
   WHERE Emp_ID= @Emp_ID AND Cmp_ID= @Cmp_ID  
  ) Qry  
    
    
  --SELECT * FROM #Emp_IORecord  
  SELECT IO_Tran_DetailsID,SUBSTRING(In_Out_Flag,1,1) AS 'In_Out_Flag',IO_Datetime,Location,Reason  
  FROM #Emp_IORecord  
  WHERE IO_Datetime =   
  (  
   SELECT MAX(IO_Datetime) FROM #Emp_IORecord   
   --WHERE Emp_ID= @Emp_ID AND Cmp_ID= @Cmp_ID  
  )  
  --AND Emp_ID= @Emp_ID AND Cmp_ID= @Cmp_ID  
    
  DROP TABLE #Emp_IORecord  
    
  */  
  DECLARE @MAX_IO_TIME DATETIME  
  DECLARE @FOR_DATE DATETIME  
    
  SET @FOR_DATE = CAST(GETDATE() AS VARCHAR(11))   
  
  SELECT @MAX_IO_TIME = CASE WHEN MAX(IN_TIME) > MAX(ISNULL(OUT_TIME,'')) THEN MAX(IN_TIME) ELSE MAX(ISNULL(OUT_TIME,'')) END  
  FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK)   
  WHERE EMP_ID = @EMP_ID AND cast(For_Date as DATE) =  @FOR_DATE --@For date comment is remove to check clock in and clock out for All client 30/10/2020 Deepal  
    
  
  
  
  
  Select @Inout_Duration = Inout_Duration from T0010_COMPANY_MASTER where Cmp_Id = @Cmp_ID -- Added By Niraj as on 25062021  
  Select @Clock_In_Time = Min(In_Time) From T0150_Emp_INOUT_RECORD Where For_Date = @ForDate And Emp_ID = @Emp_ID -- Added By Niraj(03022022)  
  
  IF EXISTS(SELECT 1 FROM T9999_MOBILE_INOUT_DETAIL WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND IO_DATETIME >= @MAX_IO_TIME)  
   BEGIN  
    
  
  
  SELECT TOP 1 IO_Tran_DetailsID,In_Out_Flag AS 'In_Out_Flag',IO_Datetime, 'Mobile Punch' AS Type,Location,Reason,@Inout_Duration AS Inout_Duration, @Clock_In_Time as Clock_In_Time -- Added By Niraj(03022022)  
    FROM T9999_MOBILE_INOUT_DETAIL  WITH (NOLOCK)   
    WHERE Emp_ID= @Emp_ID AND Cmp_ID= @Cmp_ID AND IO_DATETIME >= @MAX_IO_TIME  
    --AND Location Like (CASE WHEN Getdate() <= DATEADD(Hour, 8, IO_DATETIME) THEN 'In%' ELSE 'Out%' END) -- Added By Niraj(25012022)  
    -- Commented by prapti 15102022  
    ORDER BY IO_DATETIME DESC  
   END  
  ELSE  
   BEGIN  
  
    SELECT Top 1 0 AS 'IO_Tran_DetailsID',SUBSTRING(Flag,1,1) AS 'In_Out_Flag',IO_Datetime, 'Device Punch' as Type,  
    Flag + ' : ' + Cmp_Address AS 'Location','' AS 'Reason', @Inout_Duration AS Inout_Duration, @Clock_In_Time as Clock_In_Time -- Added By Niraj(03022022)  
    FROM  
    (   
      --- SELECT CAST(CASE WHEN IN_TIME = @MAX_IO_TIME OR IN_TIME >= DATEADD(Hour, 8, @MAX_IO_TIME)THEN 'In' ELSE 'Out' END AS VARCHAR(32)) As 'Flag', -- Flag added by Niraj(24012022)  
     SELECT CAST(CASE WHEN Getdate() <= DATEADD(Hour, 12, @MAX_IO_TIME) AND IN_TIME = @MAX_IO_TIME  THEN 'In' ELSE 'Out' END AS VARCHAR(32)) As 'Flag', -- Flag added by Niraj(24012022)  
      
      
     @MAX_IO_TIME As IO_Datetime,E.*,C.Cmp_Address  
     FROM T0150_EMP_INOUT_RECORD E WITH (NOLOCK)   
     inner join T0010_COMPANY_MASTER C WITH (NOLOCK)  on e.Cmp_ID =c.Cmp_Id  
     WHERE EMP_ID=@EMP_ID AND (IN_TIME = @MAX_IO_TIME OR OUT_TIME = @MAX_IO_TIME)  
    ) T  
    ORDER BY ISNULL(Out_Time, In_Time) Desc  
  
  
   END   
     
    
  
  
    --SELECT Top 1 0 AS 'IO_Tran_DetailsID',SUBSTRING(Flag,1,1) AS 'In_Out_Flag',IO_Datetime, 'Device Punch' as Type,  
    --Flag + ' : ' + Cmp_Address AS 'Location','' AS 'Reason', @Inout_Duration AS Inout_Duration, @Clock_In_Time as Clock_In_Time -- Added By Niraj(03022022)  
    --FROM  
    --(   
    --  --- SELECT CAST(CASE WHEN IN_TIME = @MAX_IO_TIME OR IN_TIME >= DATEADD(Hour, 8, @MAX_IO_TIME)THEN 'In' ELSE 'Out' END AS VARCHAR(32)) As 'Flag', -- Flag added by Niraj(24012022)  
    -- SELECT CAST(CASE WHEN Getdate() <= DATEADD(Hour, 8, @MAX_IO_TIME) AND IN_TIME = @MAX_IO_TIME  THEN 'In' ELSE 'Out' END AS VARCHAR(32)) As 'Flag', -- Flag added by Niraj(24012022)  
    --  
    --  
    -- @MAX_IO_TIME As IO_Datetime,E.*,C.Cmp_Address  
    -- FROM T0150_EMP_INOUT_RECORD E WITH (NOLOCK)   
    -- inner join T0010_COMPANY_MASTER C WITH (NOLOCK)  on e.Cmp_ID =c.Cmp_Id  
    -- WHERE EMP_ID=@EMP_ID AND (IN_TIME = @MAX_IO_TIME OR OUT_TIME = @MAX_IO_TIME)  
    --) T  
    --ORDER BY ISNULL(Out_Time, In_Time) Desc  
  
  
    
  --SELECT @IO_Tran_ID = IO_Tran_DetailsID,@Flag = In_Out_Flag,@In_Time = IO_Datetime,@Out_Time =IO_Datetime,  
  --@Address = Location,@IO_DateTime = IO_Datetime  
  --FROM T9999_MOBILE_INOUT_DETAIL   
  --WHERE IO_Datetime =   
  --(  
  -- SELECT MAX(IO_Datetime) FROM T9999_MOBILE_INOUT_DETAIL   
  -- WHERE Emp_ID= @Emp_ID AND Cmp_ID= @Cmp_ID AND CONVERT(VARCHAR(10),IO_Datetime,120) = CONVERT(VARCHAR(10),GETDATE(),120)  
  --)  
  --AND Emp_ID= @Emp_ID AND Cmp_ID= @Cmp_ID AND CONVERT(VARCHAR(10),IO_Datetime,120) = CONVERT(VARCHAR(10),GETDATE(),120)  
     
  --SELECT @IO_Tran_ID,@Flag  
  --IF @IO_Tran_ID IS NULL  
  -- BEGIN  
  --  SET @Result = 'In#0'  
  -- END  
  --ELSE IF @Flag = 'I'  
  -- BEGIN  
  --  SET @Result = 'In#' + CAST(@In_Time as varchar(20))  
  -- END  
  --ELSE IF @Flag = 'O'  
  -- BEGIN  
  --  SET @Result = 'Out#' + CAST(@Out_Time as varchar(20))  
  -- END  
 END  
ELSE IF @Type = 'I' -- For Attendance Entry  
 BEGIN  
  SET @Time = CONVERT(datetime,CONVERT(varchar(11),GETDATE(),103) + ' ' + CONVERT(varchar(11),GETDATE(),108),103)  
    
  --IF NOT EXISTS (SELECT * FROM T0081_CUSTOMIZED_COLUMN CC INNER JOIN T0082_Emp_Column EC ON CC.Tran_Id = EC.mst_Tran_Id WHERE CC.Column_Name = 'CheckIn/Checkout without Location (Mobile)' AND EC.Emp_Id = @Emp_ID AND EC.Value = '1')  
  SELECT @Value = EC.Value FROM T0081_CUSTOMIZED_COLUMN CC  WITH (NOLOCK) INNER JOIN T0082_Emp_Column EC  WITH (NOLOCK) ON CC.Tran_Id = EC.mst_Tran_Id WHERE CC.Column_Name = 'CheckIn/Checkout without Location (Mobile)' AND EC.Emp_Id = Emp_ID  
  IF ISNULL(@Value,0) <> 1  
   BEGIN  
    IF @Address = '' AND @Latitude = '' AND @Longitude = ''  
     BEGIN  
      SET @Result = 'Internet OR GPS Not Working#False#'  
      RETURN      
     END  
   END  
    
    
  IF @SubVerticalName <> ''  
   BEGIN  
    SELECT @SubVertical_ID = ISNULL(MAX(SubVertical_ID),0) + 1 FROM T0050_SubVertical WITH (NOLOCK)   
  
    --Select * FROM T0050_SubVertical where SubVertical_ID = @SubVertical_ID  
  
    INSERT INTO T0050_SubVertical(SubVertical_ID,Vertical_ID,SubVertical_Code,SubVertical_Name,SubVertical_Description,Cmp_ID)  
    VALUES(@SubVertical_ID,@Vertical_ID,'',@SubVerticalName,@SubVerticalName,@Cmp_ID)  
  
    --Select * FROM T0050_SubVertical where SubVertical_ID = @SubVertical_ID  
   END  
  
  
    
  --IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY where Month_St_Date<= @ForDate And Month_End_Date>= @ForDate and Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID)  
  IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY  WITH (NOLOCK) where ISNULL(Cutoff_Date,Month_End_Date)>= @ForDate and Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID)  
   BEGIN  
    SET @Result = 'Salary Already Exist#False#'  
    RETURN  
   END  
  SELECT @IO_Tran_Id = IO_Tran_Id   FROM T0150_EMP_INOUT_RECORD  WITH (NOLOCK) WHERE Emp_ID= @Emp_ID AND In_Time = ( SELECT MAX(In_Time) FROM T0150_emp_inout_Record  WITH (NOLOCK) WHERE Emp_ID= @Emp_ID AND Cmp_id= @Cmp_ID AND Convert(varchar(10),For_Date,
103) = Convert(varchar(10),@ForDate,103))  
    
    
  IF @INOUTFlag = 'I'  
   BEGIN  
    SET @Address = (CASE WHEN @Address <> '' THEN  'In   : ' + @Address ELSE '' END)  
    SET @Result = 'In Time Inserted#True#In-'+ CONVERT(varchar(11),@Time,108)+'-'+  CONVERT(varchar(11),@Time,103)  
   END  
  ELSE  
   BEGIN  
    SET @Address =  (CASE WHEN @Address <> '' THEN 'Out   : ' + @Address ELSE '' END)  
    SET @Result = 'Out Time Inserted#True#Out-'+ CONVERT(varchar(11),@Time,108)+'-'+  CONVERT(varchar(11),@Time,103)  
   END  
  
   INSERT INTO T9999_MOBILE_INOUT_DETAIL(IO_Tran_ID,Cmp_ID,Emp_ID,IO_Datetime,IMEI_No,In_Out_Flag,Latitude,Longitude,Location,Emp_Image,Reason,Vertical_ID,SubVertical_ID)  
   VALUES(@IO_Tran_ID,@Cmp_ID,@Emp_ID,@Time,@IPAdd,@INOUTFlag,@Latitude,@Longitude,@Address,@Emp_Image,@Reason,@Vertical_ID,@SubVertical_ID)  
  
   RETURN     
 END  
ELSE IF @Type = 'S' --- For Get Attendance Records  
 BEGIN  
  DECLARE @FromDate datetime  
  DECLARE @ToDate datetime  
  DECLARE @Sal_St_Date datetime  
  DECLARE @Branch_ID numeric(18,0)  
  DECLARE @FirstInLastOut tinyint  
    
  SELECT @Branch_ID = Branch_ID FROM V0080_Employee_Master  WITH (NOLOCK) WHERE Emp_ID = @Emp_ID  
    
  SELECT @Sal_St_Date = GS.Sal_St_Date,@FirstInLastOut = GS.First_In_Last_Out_For_InOut_Calculation   
  FROM T0040_GENERAL_SETTING GS WITH (NOLOCK)   
  INNER JOIN  
  (  
   SELECT TG.Gen_ID  
   FROM T0040_GENERAL_SETTING TG WITH (NOLOCK)   
   INNER JOIN  
   (  
    SELECT MAX(For_Date) AS 'For_Date',Branch_ID  
    FROM T0040_GENERAL_SETTING WITH (NOLOCK)   
    --WHERE Branch_ID = 553  
    GROUP BY Branch_ID  
   )TTG ON TG.For_Date = TTG.For_Date  AND TG.Branch_ID = TTG.Branch_ID  
  ) TGS ON GS.Gen_ID = TGS.Gen_ID  
  WHERE Cmp_ID = @Cmp_ID AND GS.Branch_ID = @Branch_ID  
    
  IF DAY(@Sal_St_Date) <> 01  
   BEGIN  
    SET @FromDate = DATEADD(MONTH, -1, CONVERT(DATETIME, CAST(@Month AS VARCHAR) + '/' + CAST(DAY(@Sal_St_Date) as varchar) + '/' +  CAST(@Year AS VARCHAR)))  
    SET @ToDate = CONVERT(DATETIME, CAST(@Month AS VARCHAR) + '/' + CAST(DAY(@Sal_St_Date) as varchar) + '/' + CAST(@Year AS VARCHAR))  -1  
   END  
  ELSE  
   BEGIN  
    SET @FromDate = CONVERT(DATETIME, CAST(@Month AS VARCHAR) + '/01/' + CAST(@Year AS VARCHAR))    
    SET @ToDate = DATEADD(MONTH, 1, CONVERT(DATETIME, CAST(@Month AS VARCHAR)+ '/01/' + CAST(@Year AS VARCHAR))) -1  
   END  
     
  CREATE table #Emp_Cons   
  (        
   Emp_ID numeric ,       
   Branch_ID numeric,  
   Increment_ID numeric      
  )    
    
  INSERT INTO #Emp_Cons (EMP_ID,BRANCH_ID,INCREMENT_ID)  
  SELECT E.EMP_ID,I.BRANCH_ID,I.INCREMENT_ID  
  FROM T0080_EMP_MASTER E  WITH (NOLOCK)   
  INNER JOIN T0095_INCREMENT I  WITH (NOLOCK) ON E.EMP_ID=I.EMP_ID  
  INNER JOIN   
  (  
   SELECT MAX(I2.Increment_ID) AS 'Increment_ID', I2.Emp_ID  
   FROM T0095_INCREMENT I2  WITH (NOLOCK)   
   INNER JOIN  
   (  
    SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS 'INCREMENT_EFFECTIVE_DATE', I3.EMP_ID  
    FROM T0095_INCREMENT I3  WITH (NOLOCK)   
    WHERE I3.Increment_Effective_Date <= @ToDate  
    GROUP BY I3.Emp_ID  
   ) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID                    
   GROUP BY I2.Emp_ID  
  ) I2 ON I.Emp_ID=I2.Emp_ID AND I.Increment_ID=I2.INCREMENT_ID  
  WHERE E.EMP_ID = @Emp_ID  
  
  CREATE TABLE #Data           
  (           
     Emp_Id numeric ,           
     For_date datetime,          
     Duration_in_sec numeric,          
     Shift_ID numeric ,          
     Shift_Type numeric ,          
     Emp_OT  numeric ,          
     Emp_OT_min_Limit numeric,          
     Emp_OT_max_Limit numeric,          
     P_days  numeric(12,3) default 0,          
     OT_Sec  numeric default 0  ,  
     In_Time datetime,  
     Shift_Start_Time datetime,  
     OT_Start_Time numeric default 0,  
     Shift_Change tinyint default 0,  
     Flag int default 0,  
     Weekoff_OT_Sec  numeric default 0,  
     Holiday_OT_Sec  numeric default 0,  
     Chk_By_Superior numeric default 0,  
     IO_Tran_Id    numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)  
     OUT_Time datetime,  
     Shift_End_Time datetime,  
     OT_End_Time numeric default 0,  
     Working_Hrs_St_Time tinyint default 0,  
     Working_Hrs_End_Time tinyint default 0,  
     GatePass_Deduct_Days numeric(18,2) default 0  
  )   
  --INSERT INTO #Data  
  EXEC P_GET_EMP_INOUT @Cmp_ID = @Cmp_ID,@From_Date = @FromDate,@To_Date = @ToDate,@First_In_Last_OUT_Flag = @FirstInLastOut  
  
  --EXEC SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Cmp_ID,@From_Date=@FromDate,@To_Date=@ToDate,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_ID,@constraint='',@Return_Record_set=1,@PBranch_ID='',@PVertical_ID='',@PSubVertical_ID='',@PDept_ID=''  
  --EXEC SP_CALCULATE_PRESENT_DAYS_WebServices @Cmp_ID = @Cmp_ID,@From_Date = @FromDate,@To_Date = @ToDate,@Branch_ID = 0, @Cat_ID = 0,@Grd_ID = 0,@Type_ID = 0,@Dept_ID = 0,@Desig_ID = 0,@Emp_ID = @Emp_ID,@constraint = '',@Return_Record_set = 1,@StrWeekoff_Date = '',@Is_Split_Shift_Req = 0  
    
    
  --SELECT Emp_Id,Emp_Full_Name,CONVERT(varchar(11),For_date,103) AS 'For_Date',CONVERT(varchar(5),In_Time,108) AS 'In_Time',  
  --CONVERT(varchar(5),OUT_Time,108) AS 'Out_Time',CONVERT(varchar(5),Duration,108) AS 'Duration',Shift_Name  
  --FROM #AttendanceReocrd  
    
  --ORDER BY CONVERT(datetime, For_date ,103)   
  --SELECT * from #Data  
    
  --SELECT D.Emp_Id,Emp_Full_Name,CONVERT(varchar(11),For_date,103)AS 'For_Date',ISNULL(CONVERT(varchar(5),In_Time,108),'') AS 'In_Time',  
  --ISNULL(CONVERT(varchar(5),OUT_Time,108),'') AS 'Out_Time',dbo.F_Return_Hours(Duration_in_sec) AS 'Duration'--CONVERT(varchar(5),Duration,108) AS 'Duration',  
  --FROM #Data D  
    
  --INNER JOIN T0080_EMP_MASTER E ON D.EMP_ID = E.EMP_ID   
    
   --SELECT D.Emp_Id,Emp_Full_Name,For_date,In_Time,OUT_Time,  
   --ISNULL(MD.IsOffline,0) AS 'IsOffline',MD.In_Out_Flag,  
   --(CASE WHEN ISNULL(MD.IsOffline,0) = 0 THEN 'ONLINE' ELSE 'OFFLINE' END) AS 'PunchStatus'  
   --FROM #Data D  
   --LEFT JOIN T9999_MOBILE_INOUT_DETAIL MD ON D.Emp_Id = MD.Emp_ID AND CONVERT(varchar(16), D.In_Time,121) = CONVERT(varchar(16), MD.IO_Datetime,121) AND CONVERT(varchar(16), D.OUT_Time,121) = CONVERT(varchar(16), MD.IO_Datetime,121)  
   ----LEFT JOIN T9999_MOBILE_INOUT_DETAIL TMD ON D.Emp_Id = TMD.Emp_ID AND CONVERT(varchar(16), D.In_Time,121) = CONVERT(varchar(16), MD.IO_Datetime,121) AND CONVERT(varchar(16), D.OUT_Time,121) = CONVERT(varchar(16), MD.IO_Datetime,121)  
   --INNER JOIN T0080_EMP_MASTER E ON D.EMP_ID = E.EMP_ID   
    
  SELECT Emp_Id,Emp_Full_Name,CONVERT(varchar(11),For_date,103)AS 'For_Date',  
  ISNULL(CONVERT(varchar(5),In_Time,108),'') AS 'In_Time',  
  ISNULL(CONVERT(varchar(5),OUT_Time,108),'') AS 'Out_Time',  
  Duration,ISNULL(I,0) AS 'In',ISNULL(O,0) AS 'Out'  
  FROM  
  (  
   SELECT D.Emp_Id,Emp_Full_Name,For_date,In_Time,OUT_Time,  
   ISNULL(MD.IsOffline,0) AS 'IsOffline',MD.In_Out_Flag,dbo.F_Return_Hours(Duration_in_sec) AS 'Duration'  
   --(CASE WHEN ISNULL(MD.IsOffline,0) = 0 THEN 'ONLINE' ELSE 'OFFLINE' END) AS 'PunchStatus'  
   FROM #Data D  
   LEFT JOIN T9999_MOBILE_INOUT_DETAIL MD  WITH (NOLOCK) ON D.Emp_Id = MD.Emp_ID AND CONVERT(varchar(16), D.In_Time,121) = CONVERT(varchar(16), MD.IO_Datetime,121) OR CONVERT(varchar(16), D.OUT_Time,121) = CONVERT(varchar(16), MD.IO_Datetime,121)  
   INNER JOIN T0080_EMP_MASTER E  WITH (NOLOCK) ON D.EMP_ID = E.EMP_ID   
  ) E  
  PIVOT  
  (  
   SUM (IsOffline)  
   FOR In_Out_Flag IN ([I],[O])  
  )P  
  ORDER BY CONVERT(datetime,For_Date,103)  desc
  DROP TABLE #Data  
 END  
ELSE IF @Type = 'O' --- For Offline Attendance Entry  
 BEGIN  
  INSERT INTO T9999_MOBILE_INOUT_DETAIL(Emp_ID,Cmp_ID,IO_Datetime,IMEI_No,In_Out_Flag,Latitude,Longitude,  
    Location,Emp_Image,Reason,IsOffline)  
  SELECT Table1.value('(EmpID/text())[1]','numeric(18,0)') AS EmpID,   
    Table1.value('(CmpID/text())[1]','numeric(18,0)') AS CmpID,     
    CONVERT(datetime,Table1.value('(ForDate/text())[1]','varchar(50)'), 103) AS ForDate,      
    'Mobile(' + Table1.value('(IMEINo/text())[1]','varchar(50)') + ')' AS IMEINO,  
    Table1.value('(IOFlage/text())[1]','varchar(50)') AS IOFlage,  
    Table1.value('(Latitude/text())[1]','varchar(50)') AS Latitude,  
    Table1.value('(Logitude/text())[1]','varchar(50)') AS Longitude,  
    Table1.value('(Address/text())[1]','varchar(MAX)') AS Address,  
    Table1.value('(ImageName/text())[1]','varchar(50)') AS ImageName,  
    Table1.value('(Reason/text())[1]','varchar(50)') AS Reason,  
    Table1.value('(Flag/text())[1]','int') AS Flag  
  FROM @strAttendance.nodes('/NewDataSet/Table1') as Temp(Table1)  
    
  /*  
  SELECT Table1.value('(EmpID/text())[1]','numeric(18,0)') AS EmpID,  
  Table1.value('(CmpID/text())[1]','numeric(18,0)') AS CmpID,  
  Table1.value('(ForDate/text())[1]','varchar(50)') AS ForDate,  
  Table1.value('(IOFlage/text())[1]','varchar(50)') AS IOFlage,  
  Table1.value('(IMEINo/text())[1]','varchar(50)') AS IMEINO,  
  Table1.value('(Latitude/text())[1]','varchar(50)') AS Latitude,  
  Table1.value('(Logitude/text())[1]','varchar(50)') AS Longitude,  
  Table1.value('(Address/text())[1]','varchar(MAX)') AS Location,  
  Table1.value('(Reason/text())[1]','varchar(50)') AS Reason,  
  Table1.value('(ImageName/text())[1]','varchar(50)') AS ImageName,  
  Table1.value('(Flag/text())[1]','int') AS Flag  
  INTO #OfflineAttendace FROM @strAttendance.nodes('/NewDataSet/Table1') as Temp(Table1)  
    
  --SELECT  * FROM #OfflineAttendace  
    
  --INSERT INTO T9999_MOBILE_INOUT_DETAIL (Emp_ID,Cmp_ID,IO_Datetime,IMEI_No,In_Out_Flag,Latitude,Longitude,Location,  
  --Emp_Image,Reason)  
  --SELECT EmpID,CmpID,ForDate,IMEINO,IOFlage,Latitude,Longitude,CASE WHEN IOFlage = 'I' THEN 'In   : ' + Location ELSE 'Out   : ' +  Location END,  
  --ImageName,Reason  
  --FROM #OfflineAttendace  
    
    
   
  DECLARE ATTENDANCE_CURSOR CURSOR  Fast_forward FOR  
  SELECT EmpID,CmpID,CONVERT(datetime,ForDate,103),IMEINO,IOFlage,Latitude,Longitude,CASE WHEN IOFlage = 'I' THEN 'In   : ' + Location ELSE 'Out   : ' +  Location END,  
  ImageName,Reason,Flag FROM #OfflineAttendace  
  OPEN ATTENDANCE_CURSOR  
  FETCH NEXT FROM ATTENDANCE_CURSOR INTO @Emp_ID,@Cmp_ID,@ForDate,@IMEINo,@INOUTFlag,@Latitude,@Longitude,@Address,@Emp_Image,@Reason,@Flag  
  WHILE @@FETCH_STATUS = 0  
   BEGIN  
     
    SELECT @IO_Tran_Id = IO_Tran_Id   FROM T0150_EMP_INOUT_RECORD WHERE Emp_ID= @Emp_ID AND In_Time = ( SELECT MAX(In_Time) FROM T0150_emp_inout_Record WHERE Emp_ID= @Emp_ID AND Cmp_id= @Cmp_ID AND Convert(varchar(10),For_Date,103) = Convert(varchar(10),@
ForDate,103))  
    --SELECT @Collection_Detail_ID = ISNULL(MAX(Collection_Detail_ID), 0) + 1 FROM T0050_Collection_Details  
      
    INSERT INTO T9999_MOBILE_INOUT_DETAIL(IO_Tran_ID,Emp_ID,Cmp_ID,IO_Datetime,IMEI_No,In_Out_Flag,Latitude,Longitude,  
    Location,Emp_Image,Reason,IsOffline)  
    VALUES(@IO_Tran_Id,@Emp_ID,@Cmp_ID,@ForDate,'Mobile(' + @IMEINo + ')',@INOUTFlag,@Latitude,@Longitude,@Address,@Emp_Image,@Reason,@Flag)   
      
    FETCH NEXT FROM ATTENDANCE_CURSOR INTO @Emp_ID,@Cmp_ID,@ForDate,@IMEINo,@INOUTFlag,@Latitude,@Longitude,@Address,@Emp_Image,@Reason,@Flag  
   END  
  CLOSE ATTENDANCE_CURSOR       
  DEALLOCATE ATTENDANCE_CURSOR  
    
  */  
  SET @Result = 'Data Sync Successfully !#True#'  
    
 END  
ELSE IF @Type = 'R' --- For Attendance Route  
 BEGIN  
  /*  
  SELECT Table1.value('(EmpID/text())[1]','numeric(18,0)') AS EmpID,  
  Table1.value('(CmpID/text())[1]','numeric(18,0)') AS CmpID,  
  Table1.value('(ForDate/text())[1]','varchar(50)') AS ForDate,  
  Table1.value('(IOFlage/text())[1]','varchar(50)') AS IOFlage,  
  Table1.value('(IMEINo/text())[1]','varchar(50)') AS IMEINO,  
  Table1.value('(Latitude/text())[1]','varchar(50)') AS Latitude,  
  Table1.value('(Logitude/text())[1]','varchar(50)') AS Longitude,  
  Table1.value('(Address/text())[1]','varchar(MAX)') AS Location,  
  Table1.value('(Reason/text())[1]','varchar(50)') AS Reason,  
  Table1.value('(ImageName/text())[1]','varchar(50)') AS ImageName,  
  Table1.value('(Flag/text())[1]','int') AS Flag  
  INTO #RouteAttendace FROM @strAttendance.nodes('/NewDataSet/Table1') as Temp(Table1)  
    
  DECLARE ATTENDANCE_CURSOR CURSOR  Fast_forward FOR  
  SELECT EmpID,CmpID,CONVERT(datetime,ForDate,103),IMEINO,IOFlage,Latitude,Longitude,CASE WHEN IOFlage = 'I' THEN 'In   : ' + Location ELSE 'Out   : ' +  Location END,  
  ImageName,Reason,Flag FROM #RouteAttendace  
  OPEN ATTENDANCE_CURSOR  
  FETCH NEXT FROM ATTENDANCE_CURSOR INTO @Emp_ID,@Cmp_ID,@ForDate,@IMEINo,@INOUTFlag,@Latitude,@Longitude,@Address,@Emp_Image,@Reason,@Flag  
  WHILE @@FETCH_STATUS = 0  
   BEGIN  
     
    --SELECT @IO_Tran_Id = IO_Tran_Id   FROM T0150_EMP_INOUT_RECORD WHERE Emp_ID= @Emp_ID AND In_Time = ( SELECT MAX(In_Time) FROM T0150_emp_inout_Record WHERE Emp_ID= @Emp_ID AND Cmp_id= @Cmp_ID AND Convert(varchar(10),For_Date,103) = Convert(varchar(10)
,@ForDate,103))  
    --SELECT @Collection_Detail_ID = ISNULL(MAX(Collection_Detail_ID), 0) + 1 FROM T0050_Collection_Details  
    INSERT INTO T9999_MOBILE_INOUT_ROUTE(Cmp_ID,Emp_ID,IO_Datetime,IMEI_No,In_Out_Flag,Latitude,Longitude,Location)  
    VALUES(@Cmp_ID,@Emp_ID,@ForDate,'Mobile(' + @IMEINo + ')',@INOUTFlag,@Latitude,@Longitude,@Address)   
      
    FETCH NEXT FROM ATTENDANCE_CURSOR INTO @Emp_ID,@Cmp_ID,@ForDate,@IMEINo,@INOUTFlag,@Latitude,@Longitude,@Address,@Emp_Image,@Reason,@Flag  
   END  
  CLOSE ATTENDANCE_CURSOR       
  DEALLOCATE ATTENDANCE_CURSOR  
  */  
  INSERT INTO T9999_MOBILE_INOUT_ROUTE(Cmp_ID,Emp_ID,IO_Datetime,IMEI_No,In_Out_Flag,Latitude,Longitude,Location)  
  SELECT Table1.value('(CmpID/text())[1]','numeric(18,0)') AS CmpID,  
    Table1.value('(EmpID/text())[1]','numeric(18,0)') AS EmpID,      
    CONVERT(datetime,Table1.value('(ForDate/text())[1]','varchar(50)'), 103) AS ForDate,      
    'Mobile(' + Table1.value('(IMEINo/text())[1]','varchar(50)') + ')' AS IMEINO,  
    Table1.value('(IOFlage/text())[1]','varchar(50)') AS IOFlage,  
    Table1.value('(Latitude/text())[1]','varchar(50)') AS Latitude,  
    Table1.value('(Logitude/text())[1]','varchar(50)') AS Longitude,  
    Table1.value('(Address/text())[1]','varchar(MAX)') AS Address  
  FROM @strAttendance.nodes('/NewDataSet/Table1') as Temp(Table1)  
  ORDER BY ForDate  
  SET @Result = 'Data Sync Successfully !#True#'  
    
 END  
ELSE IF @Type = 'G' --- For Geo Location Records  
 BEGIN  
  SELECT EGL.Emp_Geo_Location_ID,EGL.Emp_ID,EGL.Cmp_ID,EGL.Effective_Date,GLA.Geo_Location_ID,GLA.Meter,  
  GLM.Geo_Location,GLM.Latitude,GLM.Longitude  
  FROM T0095_EMP_GEO_LOCATION_ASSIGN EGL WITH (NOLOCK)   
  INNER JOIN  
  (  
   SELECT MAX(IEG.Emp_Geo_Location_ID) AS 'Emp_Geo_Location_ID',IEG.Emp_ID  
   FROM T0095_EMP_GEO_LOCATION_ASSIGN IEG WITH (NOLOCK)   
   INNER JOIN  
   (  
    SELECT MAX(Effective_Date) AS 'Effective_Date',Emp_ID  
    FROM T0095_EMP_GEO_LOCATION_ASSIGN WITH (NOLOCK)   
    WHERE Effective_Date < GETDATE()  
    GROUP BY Emp_ID  
   ) IEGL ON IEG.Effective_Date = IEGL.Effective_Date AND IEG.Emp_ID = IEGL.Emp_ID  
   GROUP BY IEG.Emp_ID  
  
  ) GL ON EGL.Emp_Geo_Location_ID = GL.Emp_Geo_Location_ID  
  INNER JOIN T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL GLA  WITH (NOLOCK) ON EGL.Emp_Geo_Location_ID = GLA.Emp_Geo_Location_ID  
  INNER JOIN T0040_GEO_LOCATION_MASTER GLM  WITH (NOLOCK) ON GLA.Geo_Location_ID = GLM.Geo_Location_ID  
  WHERE EGL.Emp_ID = @Emp_ID AND EGL.Cmp_ID = @Cmp_ID  
 END  
ELSE IF @Type = 'H' --- For Attendance History with Location  
 BEGIN  
  SELECT IO_Tran_DetailsID,IO_Datetime,(CASE WHEN In_Out_Flag = 'I' THEN 'IN' ELSE 'OUT' END) AS 'In_Out_Flag',  
  IMEI_No,TD.Cmp_ID,Emp_ID,Location,Reason,isnull(VM.Vertical_Name,'')Vertical_Name,isnull(SM.SubVertical_Name,'')SubVertical_Name  
  FROM T9999_MOBILE_INOUT_DETAIL TD WITH (NOLOCK)   
  LEFT JOIN T0040_Vertical_Segment VM  WITH (NOLOCK) ON TD.Vertical_ID = VM.Vertical_ID  
  LEFT JOIN T0050_SubVertical SM  WITH (NOLOCK) ON TD.SubVertical_ID = SM.SubVertical_ID  
  WHERE TD.Emp_ID = @Emp_ID AND TD.Cmp_ID = @Cmp_ID AND TD.IO_Datetime BETWEEN @ForDate AND DATEADD(DAY,1,@Time)  
  order by IO_Datetime desc  
 END
