CREATE PROCEDURE [dbo].[SP_RPT_EMP_MOBILE_INOUT_RECORD_with_PHOTO]
	@From_Date datetime,
	@To_Date datetime,
	@Cmp_ID numeric,
	@Emp_ID varchar(MAX),
	@Groupby varchar(50)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

IF @Groupby = 'No Group'
	BEGIN
	
	
		SELECT EM.Emp_ID,EM.Emp_code,EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,
		(EM.Alpha_Emp_Code + ' - '+ EM.Emp_First_Name +' '+ ISNULL(EM.Emp_Second_Name,'') +' '+ ISNULL(EM.Emp_Last_Name,'')) AS 'EmpFullName',
		IC.Grd_ID,IC.Dept_ID,IC.Desig_Id,IC.Branch_ID,IC.Vertical_ID,IC.SubVertical_ID,IC.subBranch_ID,IC.Segment_ID,IC.Type_ID,GM.Grd_Name,
		DM.Dept_Name,TDM.Desig_Name,BM.Branch_Name,Branch_Address,VS.Vertical_Name,TS.SubVertical_Name,SB.SubBranch_Name,TM.Type_Name,
		MI.IO_Datetime,SUBSTRING(MI.IMEI_No,8,15) as 'IMEI_No',MI.In_Out_Flag,MI.Location,MI.Emp_Image AS 'Photo' 
		,Case when Mi.IMEI_No = 'PAYROLL' then 'Image Capture From WebCam' else
		MI.Reason END As Reason,CM.Cmp_Name,CM.Cmp_Address,
		CAST(0 AS VARBINARY(MAX)) AS 'Emp_Image',--'D:\01052017065114_13706.png' AS 'ImgPath'
		(CASE WHEN ISNULL(MI.Emp_Image ,'') = '' THEN 
		MI.Emp_Image  
		ELSE Case when Mi.IMEI_No = 'PAYROLL' 
		then 
			--'F:\Working\Orange_Hrms_12032020\App_File\EMPIMAGES\'+ MI.Emp_Image 
			'D:\SVN_Working\Orange_HRMS_1203\App_File\EMPIMAGES\'+ MI.Emp_Image --Added by Niraj(25012022)
			else
			--'F:\Working\Orange_Hrms_Mobile_12032020\EmpImage\'+ CAST(YEAR(MI.IO_Datetime) AS VARCHAR(10))+'\'+ CAST(MONTH(MI.IO_Datetime) AS varchar(3)) +'\'+ REPLACE(CONVERT(varchar(11), MI.IO_Datetime,103),'/','') + '\' + MI.Emp_Image END
			'D:\SVN_Working\Orange_HRMS_Mobile_Soap\EmpImage\'+ CAST(YEAR(MI.IO_Datetime) AS VARCHAR(10))+'\'+ CAST(MONTH(MI.IO_Datetime) AS varchar(3)) +'\'+ REPLACE(CONVERT(varchar(11), MI.IO_Datetime,103),'/','') + '\' + MI.Emp_Image END --Added by Niraj(25012022)
			END )	AS 'ImgPath'
		FROM T0080_EMP_MASTER EM WITH (NOLOCK)
		LEFT OUTER JOIN T0095_INCREMENT AS IC WITH (NOLOCK) ON EM.Emp_ID = IC.Emp_ID 
		INNER JOIN 
		( 
			SELECT MAX(IC2.Increment_ID) AS 'Increment_ID', IC2.Emp_ID
			FROM T0095_INCREMENT AS IC2 WITH (NOLOCK)
			INNER JOIN
			(
				SELECT MAX(Increment_Effective_Date) AS 'INCREMENT_EFFECTIVE_DATE',Emp_ID
				FROM T0095_INCREMENT AS IC3 WITH (NOLOCK)
				WHERE (Increment_Effective_Date <= GETDATE())
				GROUP BY Emp_ID
			) AS IC3 ON IC2.Increment_Effective_Date = IC3.INCREMENT_EFFECTIVE_DATE AND IC2.Emp_ID = IC3.Emp_ID
			GROUP BY IC2.Emp_ID
		) AS IC2 ON IC.Emp_ID=IC2.Emp_ID AND IC.Increment_ID = IC2.Increment_ID 
		INNER JOIN
		(
			SELECT Data FROM dbo.Split(@Emp_ID,'#')
		)TEM ON EM.Emp_ID = TEM.Data
		LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IC.Grd_ID = GM.Grd_ID
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on IC.Dept_ID = DM.Dept_Id
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON IC.Desig_Id = TDM.Desig_ID
		LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON IC.Branch_ID = BM.Branch_ID
		LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON IC.Vertical_ID = VS.Vertical_ID
		LEFT OUTER JOIN T0050_SubVertical TS WITH (NOLOCK) ON IC.SubVertical_ID = TS.SubVertical_ID
		LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) ON IC.subBranch_ID = SB.SubBranch_ID
		LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON IC.Type_ID = TM.Type_ID
		INNER JOIN T9999_MOBILE_INOUT_DETAIL MI WITH (NOLOCK) ON EM.Emp_ID = MI.Emp_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id

		WHERE CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) >= CAST(CONVERT(varchar,@From_Date,111) as datetime)
		AND CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) <= CAST(CONVERT(varchar,@To_Date,111) AS datetime)
		AND EM.Cmp_ID = @Cmp_ID
		
		ORDER BY EM.Emp_ID,MI.IO_Datetime
	END
ELSE IF @Groupby = 'Employee Type'
	BEGIN
		SELECT EM.Emp_ID,EM.Emp_code,EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,
		(EM.Alpha_Emp_Code + ' - '+ EM.Emp_First_Name +' '+ ISNULL(EM.Emp_Second_Name,'') +' '+ ISNULL(EM.Emp_Last_Name,'')) AS 'EmpFullName',
		IC.Grd_ID,IC.Dept_ID,IC.Desig_Id,IC.Branch_ID,IC.Vertical_ID,IC.SubVertical_ID,IC.subBranch_ID,IC.Segment_ID,IC.Type_ID,GM.Grd_Name,
		DM.Dept_Name,TDM.Desig_Name,BM.Branch_Name,VS.Vertical_Name,TS.SubVertical_Name,SB.SubBranch_Name,TM.Type_Name,
		MI.IO_Datetime,SUBSTRING(MI.IMEI_No,8,15) as 'IMEI_No',MI.In_Out_Flag,MI.Location,MI.Emp_Image AS 'Photo' ,MI.Reason,CM.Cmp_Name,CM.Cmp_Address,
		CAST(0 AS VARBINARY(MAX)) AS 'Emp_Image',--'D:\01052017065114_13706.png' AS 'ImgPath'
		(CASE WHEN ISNULL(MI.Emp_Image ,'') = '' THEN MI.Emp_Image  ELSE 'F:\Working\Orange_Hrms_Mobile_12032020\EmpImage\'+ CAST(YEAR(MI.IO_Datetime) AS VARCHAR(10))+'\'+ CAST(MONTH(MI.IO_Datetime) AS varchar(3)) +'\'+ REPLACE(CONVERT(varchar(11), MI.IO_Datetime,103),'/','') + '\' + MI.Emp_Image END) AS 'ImgPath'
		--'D:\InetRoot\wwwroot\VIVO_GLOBAL_Mobile_Webservice\EmpImage\' + MI.Emp_Image  AS 'ImgPath'
		FROM T0080_EMP_MASTER EM WITH (NOLOCK)
		LEFT OUTER JOIN T0095_INCREMENT AS IC WITH (NOLOCK) ON EM.Emp_ID = IC.Emp_ID 
		INNER JOIN 
		( 
			SELECT MAX(IC2.Increment_ID) AS 'Increment_ID', IC2.Emp_ID
			FROM T0095_INCREMENT AS IC2 WITH (NOLOCK)
			INNER JOIN
			(
				SELECT MAX(Increment_Effective_Date) AS 'INCREMENT_EFFECTIVE_DATE',Emp_ID
				FROM T0095_INCREMENT AS IC3 WITH (NOLOCK)
				WHERE (Increment_Effective_Date <= GETDATE())
				GROUP BY Emp_ID
			) AS IC3 ON IC2.Increment_Effective_Date = IC3.INCREMENT_EFFECTIVE_DATE AND IC2.Emp_ID = IC3.Emp_ID
			GROUP BY IC2.Emp_ID
		) AS IC2 ON IC.Emp_ID=IC2.Emp_ID AND IC.Increment_ID = IC2.Increment_ID 
		INNER JOIN
		(
			SELECT Data FROM dbo.Split(@Emp_ID,'#')
		)TEM ON EM.Emp_ID = TEM.Data
		LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IC.Grd_ID = GM.Grd_ID
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on IC.Dept_ID = DM.Dept_Id
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON IC.Desig_Id = TDM.Desig_ID
		LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON IC.Branch_ID = BM.Branch_ID
		LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON IC.Vertical_ID = VS.Vertical_ID
		LEFT OUTER JOIN T0050_SubVertical TS WITH (NOLOCK) ON IC.SubVertical_ID = TS.SubVertical_ID
		LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) ON IC.subBranch_ID = SB.SubBranch_ID
		LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON IC.Type_ID = TM.Type_ID
		INNER JOIN T9999_MOBILE_INOUT_DETAIL MI WITH (NOLOCK) ON EM.Emp_ID = MI.Emp_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id

		WHERE CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) >= CAST(CONVERT(varchar,@From_Date,111) as datetime)
		AND CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) <= CAST(CONVERT(varchar,@To_Date,111) AS datetime)
		AND EM.Cmp_ID = @Cmp_ID
		
		ORDER BY IC.Type_ID,EM.Emp_ID,MI.IO_Datetime
	END
ELSE IF @Groupby = 'Grade'
	BEGIN
		SELECT EM.Emp_ID,EM.Emp_code,EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,
		(EM.Alpha_Emp_Code + ' - '+ EM.Emp_First_Name +' '+ ISNULL(EM.Emp_Second_Name,'') +' '+ ISNULL(EM.Emp_Last_Name,'')) AS 'EmpFullName',
		IC.Grd_ID,IC.Dept_ID,IC.Desig_Id,IC.Branch_ID,IC.Vertical_ID,IC.SubVertical_ID,IC.subBranch_ID,IC.Segment_ID,IC.Type_ID,GM.Grd_Name,
		DM.Dept_Name,TDM.Desig_Name,BM.Branch_Name,VS.Vertical_Name,TS.SubVertical_Name,SB.SubBranch_Name,TM.Type_Name,
		MI.IO_Datetime,SUBSTRING(MI.IMEI_No,8,15) as 'IMEI_No',MI.In_Out_Flag,MI.Location,MI.Emp_Image AS 'Photo' ,MI.Reason,CM.Cmp_Name,CM.Cmp_Address,
		CAST(0 AS VARBINARY(MAX)) AS 'Emp_Image',--'D:\01052017065114_13706.png' AS 'ImgPath'
		(CASE WHEN ISNULL(MI.Emp_Image ,'') = '' THEN MI.Emp_Image  ELSE 'F:\Working\Orange_Hrms_Mobile_12032020\EmpImage\'+ CAST(YEAR(MI.IO_Datetime) AS VARCHAR(10))+'\'+ CAST(MONTH(MI.IO_Datetime) AS varchar(3)) +'\'+ REPLACE(CONVERT(varchar(11), MI.IO_Datetime,103),'/','') + '\' + MI.Emp_Image END) AS 'ImgPath'
		--'D:\InetRoot\wwwroot\VIVO_GLOBAL_Mobile_Webservice\EmpImage\' + MI.Emp_Image  AS 'ImgPath'
		FROM T0080_EMP_MASTER EM WITH (NOLOCK)
		LEFT OUTER JOIN T0095_INCREMENT AS IC WITH (NOLOCK) ON EM.Emp_ID = IC.Emp_ID 
		INNER JOIN 
		( 
			SELECT MAX(IC2.Increment_ID) AS 'Increment_ID', IC2.Emp_ID
			FROM T0095_INCREMENT AS IC2 WITH (NOLOCK) 
			INNER JOIN
			(
				SELECT MAX(Increment_Effective_Date) AS 'INCREMENT_EFFECTIVE_DATE',Emp_ID
				FROM T0095_INCREMENT AS IC3 WITH (NOLOCK)
				WHERE (Increment_Effective_Date <= GETDATE())
				GROUP BY Emp_ID
			) AS IC3 ON IC2.Increment_Effective_Date = IC3.INCREMENT_EFFECTIVE_DATE AND IC2.Emp_ID = IC3.Emp_ID
			GROUP BY IC2.Emp_ID
		) AS IC2 ON IC.Emp_ID=IC2.Emp_ID AND IC.Increment_ID = IC2.Increment_ID 
		INNER JOIN
		(
			SELECT Data FROM dbo.Split(@Emp_ID,'#')
		)TEM ON EM.Emp_ID = TEM.Data
		LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IC.Grd_ID = GM.Grd_ID
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on IC.Dept_ID = DM.Dept_Id
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON IC.Desig_Id = TDM.Desig_ID
		LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON IC.Branch_ID = BM.Branch_ID
		LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON IC.Vertical_ID = VS.Vertical_ID
		LEFT OUTER JOIN T0050_SubVertical TS WITH (NOLOCK) ON IC.SubVertical_ID = TS.SubVertical_ID
		LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) ON IC.subBranch_ID = SB.SubBranch_ID
		LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON IC.Type_ID = TM.Type_ID
		INNER JOIN T9999_MOBILE_INOUT_DETAIL MI WITH (NOLOCK) ON EM.Emp_ID = MI.Emp_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id

		WHERE CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) >= CAST(CONVERT(varchar,@From_Date,111) as datetime)
		AND CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) <= CAST(CONVERT(varchar,@To_Date,111) AS datetime)
		AND EM.Cmp_ID = @Cmp_ID
		
		ORDER BY IC.Grd_ID,EM.Emp_ID,MI.IO_Datetime
	END
ELSE IF @Groupby = 'Department'
	BEGIN
		SELECT EM.Emp_ID,EM.Emp_code,EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,
		(EM.Alpha_Emp_Code + ' - '+ EM.Emp_First_Name +' '+ ISNULL(EM.Emp_Second_Name,'') +' '+ ISNULL(EM.Emp_Last_Name,'')) AS 'EmpFullName',
		IC.Grd_ID,IC.Dept_ID,IC.Desig_Id,IC.Branch_ID,IC.Vertical_ID,IC.SubVertical_ID,IC.subBranch_ID,IC.Segment_ID,IC.Type_ID,GM.Grd_Name,
		DM.Dept_Name,TDM.Desig_Name,BM.Branch_Name,VS.Vertical_Name,TS.SubVertical_Name,SB.SubBranch_Name,TM.Type_Name,
		MI.IO_Datetime,SUBSTRING(MI.IMEI_No,8,15) as 'IMEI_No',MI.In_Out_Flag,MI.Location,MI.Emp_Image AS 'Photo' ,MI.Reason,CM.Cmp_Name,CM.Cmp_Address,
		CAST(0 AS VARBINARY(MAX)) AS 'Emp_Image',--'D:\01052017065114_13706.png' AS 'ImgPath'
		(CASE WHEN ISNULL(MI.Emp_Image ,'') = '' THEN MI.Emp_Image  ELSE 'F:\Working\Orange_Hrms_Mobile_12032020\EmpImage\'+ CAST(YEAR(MI.IO_Datetime) AS VARCHAR(10))+'\'+ CAST(MONTH(MI.IO_Datetime) AS varchar(3)) +'\'+ REPLACE(CONVERT(varchar(11), MI.IO_Datetime,103),'/','') + '\' + MI.Emp_Image END) AS 'ImgPath'
		--'D:\InetRoot\wwwroot\VIVO_GLOBAL_Mobile_Webservice\EmpImage\' + MI.Emp_Image  AS 'ImgPath'
		FROM T0080_EMP_MASTER EM WITH (NOLOCK)
		LEFT OUTER JOIN T0095_INCREMENT AS IC WITH (NOLOCK) ON EM.Emp_ID = IC.Emp_ID 
		INNER JOIN 
		( 
			SELECT MAX(IC2.Increment_ID) AS 'Increment_ID', IC2.Emp_ID
			FROM T0095_INCREMENT AS IC2 WITH (NOLOCK)
			INNER JOIN
			(
				SELECT MAX(Increment_Effective_Date) AS 'INCREMENT_EFFECTIVE_DATE',Emp_ID
				FROM T0095_INCREMENT AS IC3 WITH (NOLOCK)
				WHERE (Increment_Effective_Date <= GETDATE())
				GROUP BY Emp_ID
			) AS IC3 ON IC2.Increment_Effective_Date = IC3.INCREMENT_EFFECTIVE_DATE AND IC2.Emp_ID = IC3.Emp_ID
			GROUP BY IC2.Emp_ID
		) AS IC2 ON IC.Emp_ID=IC2.Emp_ID AND IC.Increment_ID = IC2.Increment_ID 
		INNER JOIN
		(
			SELECT Data FROM dbo.Split(@Emp_ID,'#')
		)TEM ON EM.Emp_ID = TEM.Data
		LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IC.Grd_ID = GM.Grd_ID
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on IC.Dept_ID = DM.Dept_Id
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON IC.Desig_Id = TDM.Desig_ID
		LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON IC.Branch_ID = BM.Branch_ID
		LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON IC.Vertical_ID = VS.Vertical_ID
		LEFT OUTER JOIN T0050_SubVertical TS WITH (NOLOCK) ON IC.SubVertical_ID = TS.SubVertical_ID
		LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) ON IC.subBranch_ID = SB.SubBranch_ID
		LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON IC.Type_ID = TM.Type_ID
		INNER JOIN T9999_MOBILE_INOUT_DETAIL MI WITH (NOLOCK) ON EM.Emp_ID = MI.Emp_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id

		WHERE CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) >= CAST(CONVERT(varchar,@From_Date,111) as datetime)
		AND CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) <= CAST(CONVERT(varchar,@To_Date,111) AS datetime)
		AND EM.Cmp_ID = @Cmp_ID
		
		ORDER BY IC.Dept_ID,EM.Emp_ID,MI.IO_Datetime
	END
ELSE IF @Groupby = 'Designation'
	BEGIN
		SELECT EM.Emp_ID,EM.Emp_code,EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,
		(EM.Alpha_Emp_Code + ' - '+ EM.Emp_First_Name +' '+ ISNULL(EM.Emp_Second_Name,'') +' '+ ISNULL(EM.Emp_Last_Name,'')) AS 'EmpFullName',
		IC.Grd_ID,IC.Dept_ID,IC.Desig_Id,IC.Branch_ID,IC.Vertical_ID,IC.SubVertical_ID,IC.subBranch_ID,IC.Segment_ID,IC.Type_ID,GM.Grd_Name,
		DM.Dept_Name,TDM.Desig_Name,BM.Branch_Name,VS.Vertical_Name,TS.SubVertical_Name,SB.SubBranch_Name,TM.Type_Name,
		MI.IO_Datetime,SUBSTRING(MI.IMEI_No,8,15) as 'IMEI_No',MI.In_Out_Flag,MI.Location,MI.Emp_Image AS 'Photo' ,MI.Reason,CM.Cmp_Name,CM.Cmp_Address,
		CAST(0 AS VARBINARY(MAX)) AS 'Emp_Image',--'D:\01052017065114_13706.png' AS 'ImgPath'
		(CASE WHEN ISNULL(MI.Emp_Image ,'') = '' THEN MI.Emp_Image  ELSE 'F:\Working\Orange_Hrms_Mobile_12032020\EmpImage\'+ CAST(YEAR(MI.IO_Datetime) AS VARCHAR(10))+'\'+ CAST(MONTH(MI.IO_Datetime) AS varchar(3)) +'\'+ REPLACE(CONVERT(varchar(11), MI.IO_Datetime,103),'/','') + '\' + MI.Emp_Image END) AS 'ImgPath'
		--'D:\InetRoot\wwwroot\VIVO_GLOBAL_Mobile_Webservice\EmpImage\' + MI.Emp_Image  AS 'ImgPath'
		FROM T0080_EMP_MASTER EM WITH (NOLOCK)
		LEFT OUTER JOIN T0095_INCREMENT AS IC WITH (NOLOCK) ON EM.Emp_ID = IC.Emp_ID 
		INNER JOIN 
		( 
			SELECT MAX(IC2.Increment_ID) AS 'Increment_ID', IC2.Emp_ID
			FROM T0095_INCREMENT AS IC2 WITH (NOLOCK)
			INNER JOIN
			(
				SELECT MAX(Increment_Effective_Date) AS 'INCREMENT_EFFECTIVE_DATE',Emp_ID
				FROM T0095_INCREMENT AS IC3 WITH (NOLOCK)
				WHERE (Increment_Effective_Date <= GETDATE())
				GROUP BY Emp_ID
			) AS IC3 ON IC2.Increment_Effective_Date = IC3.INCREMENT_EFFECTIVE_DATE AND IC2.Emp_ID = IC3.Emp_ID
			GROUP BY IC2.Emp_ID
		) AS IC2 ON IC.Emp_ID=IC2.Emp_ID AND IC.Increment_ID = IC2.Increment_ID 
		INNER JOIN
		(
			SELECT Data FROM dbo.Split(@Emp_ID,'#')
		)TEM ON EM.Emp_ID = TEM.Data
		LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IC.Grd_ID = GM.Grd_ID
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on IC.Dept_ID = DM.Dept_Id
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON IC.Desig_Id = TDM.Desig_ID
		LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON IC.Branch_ID = BM.Branch_ID
		LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON IC.Vertical_ID = VS.Vertical_ID
		LEFT OUTER JOIN T0050_SubVertical TS WITH (NOLOCK) ON IC.SubVertical_ID = TS.SubVertical_ID
		LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) ON IC.subBranch_ID = SB.SubBranch_ID
		LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON IC.Type_ID = TM.Type_ID
		INNER JOIN T9999_MOBILE_INOUT_DETAIL MI WITH (NOLOCK) ON EM.Emp_ID = MI.Emp_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id

		WHERE CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) >= CAST(CONVERT(varchar,@From_Date,111) as datetime)
		AND CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) <= CAST(CONVERT(varchar,@To_Date,111) AS datetime)
		AND EM.Cmp_ID = @Cmp_ID
		
		ORDER BY IC.Desig_Id,EM.Emp_ID,MI.IO_Datetime
	END
ELSE IF @Groupby = 'Branch'
	BEGIN
		SELECT EM.Emp_ID,EM.Emp_code,EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,
		(EM.Alpha_Emp_Code + ' - '+ EM.Emp_First_Name +' '+ ISNULL(EM.Emp_Second_Name,'') +' '+ ISNULL(EM.Emp_Last_Name,'')) AS 'EmpFullName',
		IC.Grd_ID,IC.Dept_ID,IC.Desig_Id,IC.Branch_ID,IC.Vertical_ID,IC.SubVertical_ID,IC.subBranch_ID,IC.Segment_ID,IC.Type_ID,GM.Grd_Name,
		DM.Dept_Name,TDM.Desig_Name,BM.Branch_Name,VS.Vertical_Name,TS.SubVertical_Name,SB.SubBranch_Name,TM.Type_Name,
		MI.IO_Datetime,SUBSTRING(MI.IMEI_No,8,15) as 'IMEI_No',MI.In_Out_Flag,MI.Location,MI.Emp_Image AS 'Photo' ,MI.Reason,CM.Cmp_Name,CM.Cmp_Address,
		CAST(0 AS VARBINARY(MAX)) AS 'Emp_Image',--'D:\01052017065114_13706.png' AS 'ImgPath'
		(CASE WHEN ISNULL(MI.Emp_Image ,'') = '' THEN MI.Emp_Image  ELSE 'F:\Working\Orange_Hrms_Mobile_12032020\EmpImage\'+ CAST(YEAR(MI.IO_Datetime) AS VARCHAR(10))+'\'+ CAST(MONTH(MI.IO_Datetime) AS varchar(3)) +'\'+ REPLACE(CONVERT(varchar(11), MI.IO_Datetime,103),'/','') + '\' + MI.Emp_Image END) AS 'ImgPath'
		--'D:\InetRoot\wwwroot\VIVO_GLOBAL_Mobile_Webservice\EmpImage\' + MI.Emp_Image  AS 'ImgPath'
		FROM T0080_EMP_MASTER EM WITH (NOLOCK)
		LEFT OUTER JOIN T0095_INCREMENT AS IC WITH (NOLOCK) ON EM.Emp_ID = IC.Emp_ID 
		INNER JOIN 
		( 
			SELECT MAX(IC2.Increment_ID) AS 'Increment_ID', IC2.Emp_ID
			FROM T0095_INCREMENT AS IC2 WITH (NOLOCK)
			INNER JOIN
			(
				SELECT MAX(Increment_Effective_Date) AS 'INCREMENT_EFFECTIVE_DATE',Emp_ID
				FROM T0095_INCREMENT AS IC3 WITH (NOLOCK)
				WHERE (Increment_Effective_Date <= GETDATE())
				GROUP BY Emp_ID
			) AS IC3 ON IC2.Increment_Effective_Date = IC3.INCREMENT_EFFECTIVE_DATE AND IC2.Emp_ID = IC3.Emp_ID
			GROUP BY IC2.Emp_ID
		) AS IC2 ON IC.Emp_ID=IC2.Emp_ID AND IC.Increment_ID = IC2.Increment_ID 
		INNER JOIN
		(
			SELECT Data FROM dbo.Split(@Emp_ID,'#')
		)TEM ON EM.Emp_ID = TEM.Data
		LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IC.Grd_ID = GM.Grd_ID
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on IC.Dept_ID = DM.Dept_Id
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON IC.Desig_Id = TDM.Desig_ID
		LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON IC.Branch_ID = BM.Branch_ID
		LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON IC.Vertical_ID = VS.Vertical_ID
		LEFT OUTER JOIN T0050_SubVertical TS WITH (NOLOCK) ON IC.SubVertical_ID = TS.SubVertical_ID
		LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) ON IC.subBranch_ID = SB.SubBranch_ID
		LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON IC.Type_ID = TM.Type_ID
		INNER JOIN T9999_MOBILE_INOUT_DETAIL MI WITH (NOLOCK) ON EM.Emp_ID = MI.Emp_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id

		WHERE CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) >= CAST(CONVERT(varchar,@From_Date,111) as datetime)
		AND CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) <= CAST(CONVERT(varchar,@To_Date,111) AS datetime)
		AND EM.Cmp_ID = @Cmp_ID
		
		ORDER BY IC.Branch_ID,EM.Emp_ID,MI.IO_Datetime
	END
ELSE IF @Groupby = 'Zone'
	BEGIN
		SELECT EM.Emp_ID,EM.Emp_code,EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,
		(EM.Alpha_Emp_Code + ' - '+ EM.Emp_First_Name +' '+ ISNULL(EM.Emp_Second_Name,'') +' '+ ISNULL(EM.Emp_Last_Name,'')) AS 'EmpFullName',
		IC.Grd_ID,IC.Dept_ID,IC.Desig_Id,IC.Branch_ID,IC.Vertical_ID,IC.SubVertical_ID,IC.subBranch_ID,IC.Segment_ID,IC.Type_ID,GM.Grd_Name,
		DM.Dept_Name,TDM.Desig_Name,BM.Branch_Name,VS.Vertical_Name,TS.SubVertical_Name,SB.SubBranch_Name,TM.Type_Name,
		MI.IO_Datetime,SUBSTRING(MI.IMEI_No,8,15) as 'IMEI_No',MI.In_Out_Flag,MI.Location,MI.Emp_Image AS 'Photo' ,MI.Reason,CM.Cmp_Name,CM.Cmp_Address,
		CAST(0 AS VARBINARY(MAX)) AS 'Emp_Image',--'D:\01052017065114_13706.png' AS 'ImgPath'
		(CASE WHEN ISNULL(MI.Emp_Image ,'') = '' THEN MI.Emp_Image  ELSE 'F:\Working\Orange_Hrms_Mobile_12032020\EmpImage\'+ CAST(YEAR(MI.IO_Datetime) AS VARCHAR(10))+'\'+ CAST(MONTH(MI.IO_Datetime) AS varchar(3)) +'\'+ REPLACE(CONVERT(varchar(11), MI.IO_Datetime,103),'/','') + '\' + MI.Emp_Image END) AS 'ImgPath'
		--'D:\InetRoot\wwwroot\VIVO_GLOBAL_Mobile_Webservice\EmpImage\' + MI.Emp_Image  AS 'ImgPath'
		FROM T0080_EMP_MASTER EM WITH (NOLOCK)
		LEFT OUTER JOIN T0095_INCREMENT AS IC WITH (NOLOCK) ON EM.Emp_ID = IC.Emp_ID 
		INNER JOIN 
		( 
			SELECT MAX(IC2.Increment_ID) AS 'Increment_ID', IC2.Emp_ID
			FROM T0095_INCREMENT AS IC2 WITH (NOLOCK)
			INNER JOIN
			(
				SELECT MAX(Increment_Effective_Date) AS 'INCREMENT_EFFECTIVE_DATE',Emp_ID
				FROM T0095_INCREMENT AS IC3 WITH (NOLOCK)
				WHERE (Increment_Effective_Date <= GETDATE())
				GROUP BY Emp_ID
			) AS IC3 ON IC2.Increment_Effective_Date = IC3.INCREMENT_EFFECTIVE_DATE AND IC2.Emp_ID = IC3.Emp_ID
			GROUP BY IC2.Emp_ID
		) AS IC2 ON IC.Emp_ID=IC2.Emp_ID AND IC.Increment_ID = IC2.Increment_ID 
		INNER JOIN
		(
			SELECT Data FROM dbo.Split(@Emp_ID,'#')
		)TEM ON EM.Emp_ID = TEM.Data
		LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IC.Grd_ID = GM.Grd_ID
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on IC.Dept_ID = DM.Dept_Id
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON IC.Desig_Id = TDM.Desig_ID
		LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON IC.Branch_ID = BM.Branch_ID
		LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON IC.Vertical_ID = VS.Vertical_ID
		LEFT OUTER JOIN T0050_SubVertical TS WITH (NOLOCK) ON IC.SubVertical_ID = TS.SubVertical_ID
		LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) ON IC.subBranch_ID = SB.SubBranch_ID
		LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON IC.Type_ID = TM.Type_ID
		INNER JOIN T9999_MOBILE_INOUT_DETAIL MI WITH (NOLOCK) ON EM.Emp_ID = MI.Emp_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id

		WHERE CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) >= CAST(CONVERT(varchar,@From_Date,111) as datetime)
		AND CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) <= CAST(CONVERT(varchar,@To_Date,111) AS datetime)
		AND EM.Cmp_ID = @Cmp_ID
		
		ORDER BY IC.Vertical_ID,EM.Emp_ID,MI.IO_Datetime
	END
ELSE IF @Groupby = 'SubVertical'
	BEGIN
		SELECT EM.Emp_ID,EM.Emp_code,EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,
		(EM.Alpha_Emp_Code + ' - '+ EM.Emp_First_Name +' '+ ISNULL(EM.Emp_Second_Name,'') +' '+ ISNULL(EM.Emp_Last_Name,'')) AS 'EmpFullName',
		IC.Grd_ID,IC.Dept_ID,IC.Desig_Id,IC.Branch_ID,IC.Vertical_ID,IC.SubVertical_ID,IC.subBranch_ID,IC.Segment_ID,IC.Type_ID,GM.Grd_Name,
		DM.Dept_Name,TDM.Desig_Name,BM.Branch_Name,VS.Vertical_Name,TS.SubVertical_Name,SB.SubBranch_Name,TM.Type_Name,
		MI.IO_Datetime,SUBSTRING(MI.IMEI_No,8,15) as 'IMEI_No',MI.In_Out_Flag,MI.Location,MI.Emp_Image AS 'Photo' ,MI.Reason,CM.Cmp_Name,CM.Cmp_Address,
		CAST(0 AS VARBINARY(MAX)) AS 'Emp_Image',--'D:\01052017065114_13706.png' AS 'ImgPath'
		(CASE WHEN ISNULL(MI.Emp_Image ,'') = '' THEN MI.Emp_Image  ELSE 'F:\Working\Orange_Hrms_Mobile_12032020\EmpImage\'+ CAST(YEAR(MI.IO_Datetime) AS VARCHAR(10))+'\'+ CAST(MONTH(MI.IO_Datetime) AS varchar(3)) +'\'+ REPLACE(CONVERT(varchar(11), MI.IO_Datetime,103),'/','') + '\' + MI.Emp_Image END) AS 'ImgPath'
		--'D:\InetRoot\wwwroot\VIVO_GLOBAL_Mobile_Webservice\EmpImage\' + MI.Emp_Image  AS 'ImgPath'
		FROM T0080_EMP_MASTER EM WITH (NOLOCK)
		LEFT OUTER JOIN T0095_INCREMENT AS IC WITH (NOLOCK) ON EM.Emp_ID = IC.Emp_ID 
		INNER JOIN 
		( 
			SELECT MAX(IC2.Increment_ID) AS 'Increment_ID', IC2.Emp_ID
			FROM T0095_INCREMENT AS IC2 WITH (NOLOCK)
			INNER JOIN
			(
				SELECT MAX(Increment_Effective_Date) AS 'INCREMENT_EFFECTIVE_DATE',Emp_ID
				FROM T0095_INCREMENT AS IC3 WITH (NOLOCK)
				WHERE (Increment_Effective_Date <= GETDATE())
				GROUP BY Emp_ID
			) AS IC3 ON IC2.Increment_Effective_Date = IC3.INCREMENT_EFFECTIVE_DATE AND IC2.Emp_ID = IC3.Emp_ID
			GROUP BY IC2.Emp_ID
		) AS IC2 ON IC.Emp_ID=IC2.Emp_ID AND IC.Increment_ID = IC2.Increment_ID 
		INNER JOIN
		(
			SELECT Data FROM dbo.Split(@Emp_ID,'#')
		)TEM ON EM.Emp_ID = TEM.Data
		LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IC.Grd_ID = GM.Grd_ID
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on IC.Dept_ID = DM.Dept_Id
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON IC.Desig_Id = TDM.Desig_ID
		LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON IC.Branch_ID = BM.Branch_ID
		LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON IC.Vertical_ID = VS.Vertical_ID
		LEFT OUTER JOIN T0050_SubVertical TS WITH (NOLOCK) ON IC.SubVertical_ID = TS.SubVertical_ID
		LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) ON IC.subBranch_ID = SB.SubBranch_ID
		LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON IC.Type_ID = TM.Type_ID
		INNER JOIN T9999_MOBILE_INOUT_DETAIL MI WITH (NOLOCK) ON EM.Emp_ID = MI.Emp_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id

		WHERE CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) >= CAST(CONVERT(varchar,@From_Date,111) as datetime)
		AND CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) <= CAST(CONVERT(varchar,@To_Date,111) AS datetime)
		AND EM.Cmp_ID = @Cmp_ID
		
		ORDER BY IC.SubVertical_ID,EM.Emp_ID,MI.IO_Datetime
	END
ELSE IF @Groupby = 'Sub Branch'
	BEGIN
		SELECT EM.Emp_ID,EM.Emp_code,EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,
		(EM.Alpha_Emp_Code + ' - '+ EM.Emp_First_Name +' '+ ISNULL(EM.Emp_Second_Name,'') +' '+ ISNULL(EM.Emp_Last_Name,'')) AS 'EmpFullName',
		IC.Grd_ID,IC.Dept_ID,IC.Desig_Id,IC.Branch_ID,IC.Vertical_ID,IC.SubVertical_ID,IC.subBranch_ID,IC.Segment_ID,IC.Type_ID,GM.Grd_Name,
		DM.Dept_Name,TDM.Desig_Name,BM.Branch_Name,VS.Vertical_Name,TS.SubVertical_Name,SB.SubBranch_Name,TM.Type_Name,
		MI.IO_Datetime,SUBSTRING(MI.IMEI_No,8,15) as 'IMEI_No',MI.In_Out_Flag,MI.Location,MI.Emp_Image AS 'Photo' ,MI.Reason,CM.Cmp_Name,CM.Cmp_Address,
		CAST(0 AS VARBINARY(MAX)) AS 'Emp_Image',--'D:\01052017065114_13706.png' AS 'ImgPath'
		(CASE WHEN ISNULL(MI.Emp_Image ,'') = '' THEN MI.Emp_Image  ELSE 'F:\Working\Orange_Hrms_Mobile_12032020\EmpImage\'+ CAST(YEAR(MI.IO_Datetime) AS VARCHAR(10))+'\'+ CAST(MONTH(MI.IO_Datetime) AS varchar(3)) +'\'+ REPLACE(CONVERT(varchar(11), MI.IO_Datetime,103),'/','') + '\' + MI.Emp_Image END) AS 'ImgPath'
		--'D:\InetRoot\wwwroot\VIVO_GLOBAL_Mobile_Webservice\EmpImage\' + MI.Emp_Image  AS 'ImgPath'
		FROM T0080_EMP_MASTER EM WITH (NOLOCK)
		LEFT OUTER JOIN T0095_INCREMENT AS IC WITH (NOLOCK) ON EM.Emp_ID = IC.Emp_ID 
		INNER JOIN 
		( 
			SELECT MAX(IC2.Increment_ID) AS 'Increment_ID', IC2.Emp_ID
			FROM T0095_INCREMENT AS IC2 WITH (NOLOCK)
			INNER JOIN
			(
				SELECT MAX(Increment_Effective_Date) AS 'INCREMENT_EFFECTIVE_DATE',Emp_ID
				FROM T0095_INCREMENT AS IC3 WITH (NOLOCK)
				WHERE (Increment_Effective_Date <= GETDATE())
				GROUP BY Emp_ID
			) AS IC3 ON IC2.Increment_Effective_Date = IC3.INCREMENT_EFFECTIVE_DATE AND IC2.Emp_ID = IC3.Emp_ID
			GROUP BY IC2.Emp_ID
		) AS IC2 ON IC.Emp_ID=IC2.Emp_ID AND IC.Increment_ID = IC2.Increment_ID 
		INNER JOIN
		(
			SELECT Data FROM dbo.Split(@Emp_ID,'#')
		)TEM ON EM.Emp_ID = TEM.Data
		LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IC.Grd_ID = GM.Grd_ID
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on IC.Dept_ID = DM.Dept_Id
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON IC.Desig_Id = TDM.Desig_ID
		LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON IC.Branch_ID = BM.Branch_ID
		LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON IC.Vertical_ID = VS.Vertical_ID
		LEFT OUTER JOIN T0050_SubVertical TS WITH (NOLOCK) ON IC.SubVertical_ID = TS.SubVertical_ID
		LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) ON IC.subBranch_ID = SB.SubBranch_ID
		LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON IC.Type_ID = TM.Type_ID
		INNER JOIN T9999_MOBILE_INOUT_DETAIL MI WITH (NOLOCK) ON EM.Emp_ID = MI.Emp_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id

		WHERE CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) >= CAST(CONVERT(varchar,@From_Date,111) as datetime)
		AND CAST(CONVERT(varchar, MI.IO_Datetime,111) as datetime) <= CAST(CONVERT(varchar,@To_Date,111) AS datetime)
		AND EM.Cmp_ID = @Cmp_ID
		
		ORDER BY IC.subBranch_ID,EM.Emp_ID,MI.IO_Datetime
	END




