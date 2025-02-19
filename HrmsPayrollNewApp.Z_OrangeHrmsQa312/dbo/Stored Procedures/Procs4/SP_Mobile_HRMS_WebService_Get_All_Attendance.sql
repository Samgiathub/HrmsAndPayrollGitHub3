
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Get_All_Attendance]  
	@Cmp_ID NUMERIC(18,0),
	@FromDate DATETIME,
	@ToDate DATETIME
AS    

SET NOCOUNT ON		
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	BEGIN
		DECLARE @FirstInLastOut tinyint
		
		SELECT @FirstInLastOut = GS.First_In_Last_Out_For_InOut_Calculation 
		FROM T0040_GENERAL_SETTING GS WITH (NOLOCK) 
		INNER JOIN
		(
			SELECT TG.Gen_ID
			FROM T0040_GENERAL_SETTING TG WITH (NOLOCK) 
			INNER JOIN
			(
				SELECT MAX(For_Date) AS 'For_Date',Branch_ID
				FROM T0040_GENERAL_SETTING WITH (NOLOCK) 
				GROUP BY Branch_ID
			)TTG ON TG.For_Date = TTG.For_Date  AND TG.Branch_ID = TTG.Branch_ID
		) TGS ON GS.Gen_ID = TGS.Gen_ID
		WHERE Cmp_ID = @Cmp_ID
		 
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
		--WHERE E.EMP_ID = @Emp_ID

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
		   IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
		   OUT_Time datetime,
		   Shift_End_Time datetime,
		   OT_End_Time numeric default 0,
		   Working_Hrs_St_Time tinyint default 0,
		   Working_Hrs_End_Time tinyint default 0,
		   GatePass_Deduct_Days numeric(18,2) default 0
		) 
		
		---EXEC P_GET_EMP_INOUT @Cmp_ID = @Cmp_ID,@From_Date = @FromDate,@To_Date = @ToDate,@First_In_Last_OUT_Flag = @FirstInLastOut
		
		Declare @CmpID numeric(18,0);
		set @CmpID =0

			Declare COMPANY_CURSOR CURSOR for 
			SELECT Cmp_ID from T0010_COMPANY_MASTER where ( @Cmp_ID= 0 Or Cmp_ID = @Cmp_ID)  ;
			OPEN COMPANY_CURSOR;
				FETCH  FROM COMPANY_CURSOR into @CmpID;
				
				WHILE @@FETCH_STATUS = 0
					Begin
						EXEC P_GET_EMP_INOUT @Cmp_ID = @CmpID,@From_Date = @FromDate,@To_Date = @ToDate,@First_In_Last_OUT_Flag = @FirstInLastOut
					FETCH NEXT FROM COMPANY_CURSOR into @CmpID;
					End
			CLOSE COMPANY_CURSOR;
			DEALLOCATE COMPANY_CURSOR;

			
			if @Cmp_ID = 0
			Begin 
				--SELECT distinct Company_Code,Company_Name, Employee_Code, Enroll_Number, Employee_Name, CONVERT(varchar(11),For_date,103)AS 'For_Date',
				--ISNULL(CONVERT(varchar(5),In_Time,108),'') AS 'In_Time',
				--ISNULL(CONVERT(varchar(5),OUT_Time,108),'') AS 'Out_Time'
				--FROM
				--(
				--	SELECT CM.Cmp_Id AS 'Company_Code', CM.Cmp_Name AS 'Company_Name', E.Alpha_Emp_Code AS 'Employee_Code'
				--	, E.Enroll_No AS 'Enroll_Number', E.Emp_Full_Name as 'Employee_Name', For_date,In_Time,OUT_Time
				--	FROM #Data D
				--	Left JOIN T9999_DEVICE_INOUT_DETAIL MD  WITH (NOLOCK) ON D.Emp_Id = MD.Enroll_No 
				--	AND (CONVERT(varchar(16), D.In_Time,121) = CONVERT(varchar(16), MD.IO_Datetime,121) 
				--	OR CONVERT(varchar(16), D.OUT_Time,121) = CONVERT(varchar(16), MD.IO_Datetime,121))
				--	INNER JOIN T0080_EMP_MASTER E  WITH (NOLOCK) ON D.EMP_ID = E.EMP_ID 
				--	INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.Cmp_Id
				--) E
				--union 
				SELECT distinct Company_Code,Company_Name, Employee_Code, Enroll_Number, Employee_Name, CONVERT(varchar(11),For_date,103)AS 'For_Date',
				ISNULL(CONVERT(varchar(5),In_Time,108),'') AS 'In_Time',
				ISNULL(CONVERT(varchar(5),OUT_Time,108),'') AS 'Out_Time'
				FROM
				(
					SELECT CM.Cmp_Id AS 'Company_Code', CM.Cmp_Name AS 'Company_Name', E.Alpha_Emp_Code AS 'Employee_Code'
					, E.Enroll_No AS 'Enroll_Number', E.Emp_Full_Name as 'Employee_Name', For_date,In_Time,OUT_Time
					FROM #Data D
					--Left JOIN T9999_MOBILE_INOUT_DETAIL MD  WITH (NOLOCK) ON D.Emp_Id = MD.Emp_ID 
					--AND (CONVERT(varchar(16), D.In_Time,121) = CONVERT(varchar(16), MD.IO_Datetime,121) 
					--OR CONVERT(varchar(16), D.OUT_Time,121) = CONVERT(varchar(16), MD.IO_Datetime,121))
					INNER JOIN T0080_EMP_MASTER E  WITH (NOLOCK) ON D.EMP_ID = E.EMP_ID 
					INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.Cmp_Id
				) E
				ORDER BY Company_Code,CONVERT(varchar(11),For_date,103)
			END
			ELSE
			BEGIN
				SELECT Company_Code,Company_Name, Employee_Code, Enroll_Number, Employee_Name, CONVERT(varchar(11),For_date,103)AS 'For_Date',
				ISNULL(CONVERT(varchar(5),In_Time,108),'') AS 'In_Time',
				ISNULL(CONVERT(varchar(5),OUT_Time,108),'') AS 'Out_Time'
				FROM
				(
					SELECT CM.Cmp_Id AS 'Company_Code', CM.Cmp_Name AS 'Company_Name', E.Alpha_Emp_Code AS 'Employee_Code'
					, E.Enroll_No AS 'Enroll_Number', E.Emp_Full_Name as 'Employee_Name', For_date,In_Time,OUT_Time
					FROM #Data D
					--LEFT JOIN T9999_MOBILE_INOUT_DETAIL MD  WITH (NOLOCK) ON D.Emp_Id = MD.Emp_ID
					--AND CONVERT(varchar(16), D.In_Time,121) = CONVERT(varchar(16), MD.IO_Datetime,121) 
					--OR CONVERT(varchar(16), D.OUT_Time,121) = CONVERT(varchar(16), MD.IO_Datetime,121)
					INNER JOIN T0080_EMP_MASTER E  WITH (NOLOCK) ON D.EMP_ID = E.EMP_ID 
					INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.Cmp_Id
					where cm.Cmp_Id = @Cmp_ID
				) E
				ORDER BY Company_Code,CONVERT(varchar(11),For_date,103)
		END
		DROP TABLE #Data
	END