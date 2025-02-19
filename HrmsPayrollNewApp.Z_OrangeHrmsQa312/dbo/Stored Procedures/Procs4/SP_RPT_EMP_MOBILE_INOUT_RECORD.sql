---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_MOBILE_INOUT_RECORD]
	@Cmp_ID numeric,
	@From_Date datetime,
	@To_Date datetime,
	@Branch_ID numeric = 0,
	@Cat_ID numeric = 0,
	@Grd_ID numeric = 0,
	@Type_ID numeric = 0,
	@Dept_ID numeric = 0,
	@Desig_ID numeric = 0,
	@Emp_ID numeric = 0,
	@Constraint varchar(MAX) = '',
	@Report_Type int = 0
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON   
     
IF @Branch_ID = 0
	SET @Branch_ID = NULL
IF @Cat_ID = 0
	SET @Cat_ID = NULL
IF @Type_ID = 0
	SET @Type_ID = NULL
IF @Dept_ID = 0
	SET @Dept_ID = NULL
IF @Grd_ID = 0
	SET @Grd_ID = NULL
IF @Emp_ID = 0
	SET @Emp_ID = NULL
IF @Desig_ID = 0
	SET @Desig_ID = NULL

	CREATE TABLE #Emp_Cons
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)

	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint --,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 

	
	
	--Taking Punching of 1 Month only for Faster Result from T9999_MOBILE_INOUT_DETAIL
	SELECT *  ,Cast(Cast(IO_Datetime As varchar(11)) + ' ' + dbo.F_GET_AMPM(IO_Datetime) As Datetime) AS MOBILE_IO_DATETIME 
	INTO #T9999_MOBILE_INOUT_DETAIL 
	FROM T9999_MOBILE_INOUT_DETAIL WITH (NOLOCK) 
	WHERE IO_Datetime BETWEEN (@From_Date - 1) AND (@To_Date + 1)
	
	
	
/*	
	
	SELECT Emp_ID ,Cmp_ID,IO_flag,IO_Datetime , CAST(CAST(IO_Datetime As varchar(11)) + ' ' + dbo.F_GET_AMPM(IO_Datetime) As Datetime) AS Emp_IORecord_IODATETIME 
	INTO #Emp_IORecord
	FROM (SELECT Emp_ID,Cmp_ID,In_Time,Out_Time FROM #T0150_EMP_INOUT_RECORD) emp
	UNPIVOT
	( IO_Datetime FOR IO_flag IN (In_Time,Out_Time) ) U;
	 
	SELECT I_Q.*,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,E.Emp_Full_Name AS 'Emp_Full_Name',CM.Cmp_Name,CM.Cmp_Address,TM.IO_Datetime,
	SUBSTRING(TM.IMEI_No,8,15) as 'IMEI_No',CONVERT(varchar(20),@From_Date,103) AS 'From_Date',CONVERT(varchar(20), @To_Date,103) AS 'To_Date',
	Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Branch_Address,TM.Location,TM.Reason, --Comp_Name--ip.device_Name,ip.ip_address,
	(RIGHT(REPLICATE(N'0', 10) + E.ALPHA_EMP_CODE, 9) + ' ' + CONVERT(VARCHAR(8), TM.IO_Datetime, 112) + LEFT(REPLACE(CONVERT(varchar, TM.IO_Datetime, 108), ':',''),4) + CASE WHEN TM.In_Out_Flag='I' then '1' ELSE '0' END + '999') AS 'TXT_SAP_TIME',
	TM.Latitude,TM.Longitude,
	(CASE WHEN TM.Emp_Image = '' OR TM.Emp_Image IS NULL THEN (CASE WHEN E.Image_Name = '0.jpg' OR E.Image_Name = '' THEN (CASE WHEN E.Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE E.Image_Name END) ELSE TM.Emp_Image END) AS 'ImageName'
	FROM T9999_MOBILE_INOUT_DETAIL TM
	INNER JOIN #Emp_IORecord EI ON TM.Emp_ID = EI.Emp_ID AND Cast(Cast(TM.IO_Datetime As varchar(11)) + ' ' + dbo.F_GET_AMPM(TM.IO_Datetime) As Datetime) = Cast(Cast(EI.IO_Datetime As varchar(11)) + ' ' + dbo.F_GET_AMPM(EI.IO_Datetime) As Datetime) 
	INNER JOIN T0080_EMP_MASTER E ON TM.Emp_ID = E.Emp_ID
	INNER JOIN #Emp_Cons EL ON E.Emp_ID =EL.Emp_ID 
	LEFT JOIN T0010_Company_master CM ON e.Cmp_ID =Cm.Cmp_ID 
	--LEFT OUTER JOIN (SELECT DISTINCT ip_address,device_Name FROM T0040_ip_master WHERE Cmp_ID =@Cmp_ID) AS ip ON diod.IP_Address = ip.IP_Address 
	INNER JOIN 
	(
		SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
		FROM T0095_Increment I 
		INNER JOIN 
		(
			SELECT MAX(Increment_ID) AS 'Increment_ID',Emp_ID 
			FROM T0095_Increment
			WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID 
			GROUP BY emp_ID  
		) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID  
	) I_Q ON E.Emp_ID = I_Q.Emp_ID  
	INNER JOIN T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID 
	LEFT JOIN T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID 
	LEFT JOIN T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id 
	LEFT JOIN T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id 
	LEFT JOIN T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID     
	WHERE E.Emp_ID = TM.Emp_ID AND (TM.IO_Datetime >= @From_Date AND TM.IO_Datetime <= @To_Date + 1) 
	AND cm.Cmp_ID = @Cmp_ID AND E.Emp_ID in (select Emp_ID From #Emp_Cons) 
	ORDER BY TM.IO_Datetime,CASE WHEN ISNUMERIC(E.Alpha_Emp_Code) = 1 THEN RIGHT(REPLICATE('0',21) + E.Alpha_Emp_Code, 20) WHEN ISNUMERIC(E.Alpha_Emp_Code) = 0 THEN LEFT(E.Alpha_Emp_Code + REPLICATE('',21), 20) ELSE E.Alpha_Emp_Code End
     */
     
     
     --OLD CODE COMMENTED BY RAMIZ ON 29/11/2018 FOR OPTIMIZATION
     
     IF(@Report_Type = 1)
		BEGIN
		
		
			 SELECT		E.Alpha_Emp_Code,E.Emp_Full_Name AS 'Employee Name',SVM.SUBVERTICAL_NAME AS 'Outlet',CSM.VERTICAL_NAME AS 'Distributor',
						--TM.Longitude,
						--TM.Latitude,
						TM.Location as 'Address',TM.Reason,convert(varchar(11),TM.IO_Datetime,103) as 'IO Date',convert(varchar(11),TM.IO_Datetime,108) as 'IO Time'
				FROM #T9999_MOBILE_INOUT_DETAIL TM
					INNER JOIN #Emp_Cons EC ON TM.Emp_ID =EC.Emp_ID
					INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EC.Emp_ID = E.Emp_ID
					INNER JOIN T0010_Company_master CM WITH (NOLOCK) ON e.Cmp_ID =Cm.Cmp_ID 
					LEFT JOIN  T0040_Vertical_Segment CSM WITH (NOLOCK) on TM.VERTICAL_ID = CSM.VERTICAL_ID
					LEFT JOIN T0050_SubVertical SVM WITH (NOLOCK) ON TM.SUBVERTICAL_ID = SVM.SUBVERTICAL_ID
				ORDER BY TM.IO_Datetime,E.Alpha_Emp_Code
		
		END
	ELSE
		BEGIN
		
				--Taking Punching of 1 Month only for Faster Result from T0150_EMP_INOUT_RECORD
				SELECT * 
				INTO #T0150_EMP_INOUT_RECORD 
				FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK)
				WHERE For_Date BETWEEN @From_Date AND @To_Date
				
				SELECT Emp_ID ,Cmp_ID,IO_flag,IO_Datetime
				INTO #Emp_IORecord
				FROM (SELECT Emp_ID,Cmp_ID,In_Time,Out_Time FROM #T0150_EMP_INOUT_RECORD) emp
				UNPIVOT
				( IO_Datetime FOR IO_flag IN (In_Time,Out_Time) ) U;
		
			
				 SELECT Distinct I_Q.*,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,E.Emp_Full_Name AS 'Emp_Full_Name',CM.Cmp_Name,CM.Cmp_Address,TM.IO_Datetime,
				SUBSTRING(TM.IMEI_No,8,15) as 'IMEI_No',CONVERT(varchar(20),@From_Date,103) AS 'From_Date',CONVERT(varchar(20), @To_Date,103) AS 'To_Date',
				Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Branch_Address,TM.Location,TM.Reason, --Comp_Name--ip.device_Name,ip.ip_address,
				(RIGHT(REPLICATE(N'0', 10) + E.ALPHA_EMP_CODE, 9) + ' ' + CONVERT(VARCHAR(8), TM.IO_Datetime, 112) + LEFT(REPLACE(CONVERT(varchar, TM.IO_Datetime, 108), ':',''),4) + CASE WHEN TM.In_Out_Flag='I' then '1' ELSE '0' END + '999') AS 'TXT_SAP_TIME',
				TM.Latitude,TM.Longitude,
				(CASE WHEN TM.Emp_Image = '' OR TM.Emp_Image IS NULL THEN (CASE WHEN E.Image_Name = '0.jpg' OR E.Image_Name = '' THEN (CASE WHEN E.Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE E.Image_Name END) ELSE TM.Emp_Image END) AS 'ImageName',
				SVM.SubVertical_Name,CSM.Vertical_Name, TM.ManagerComment
			FROM #T9999_MOBILE_INOUT_DETAIL TM
				--INNER JOIN #Emp_IORecord EI ON TM.Emp_ID = EI.Emp_ID AND TM.MOBILE_IO_DATETIME = EI.IO_Datetime
				LEFT JOIN #Emp_IORecord EI ON TM.Emp_ID = EI.Emp_ID AND TM.MOBILE_IO_DATETIME = EI.IO_Datetime
				INNER JOIN #Emp_Cons EC ON TM.Emp_ID =EC.Emp_ID
				INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EC.Emp_ID = E.Emp_ID
				INNER JOIN T0095_INCREMENT I_Q WITH (NOLOCK) ON I_Q.Increment_ID = EC.Increment_ID
				INNER JOIN T0010_Company_master CM WITH (NOLOCK) ON e.Cmp_ID =Cm.Cmp_ID 
				INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID     
				LEFT JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
				LEFT JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
				LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
				
				LEFT JOIN  T0040_Vertical_Segment CSM WITH (NOLOCK) on TM.VERTICAL_ID = CSM.VERTICAL_ID
				LEFT JOIN T0050_SubVertical SVM WITH (NOLOCK) ON TM.SUBVERTICAL_ID = SVM.SUBVERTICAL_ID
				
			ORDER BY TM.IO_Datetime,E.Alpha_Emp_Code
			
			DROP TABLE #Emp_IORecord
		END
	
		
		DROP TABLE #T9999_MOBILE_INOUT_DETAIL
		
 RETURN
