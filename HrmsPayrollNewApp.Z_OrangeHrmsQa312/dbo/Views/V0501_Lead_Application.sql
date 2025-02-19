



CREATE VIEW [dbo].[V0501_Lead_Application]

AS 

	SELECT TLA.Lead_App_ID, TLA.Cmp_ID, TLA.Emp_ID, ISNULL(TEM.Emp_Full_Name,'') AS 'Assigned_To_Name', ISNULL(TLA.Cust_Name,'') AS 'Cust_Name', ISNULL(TLA.Cust_Address,'') AS 'Cust_Address'
		, ISNULL(TLA.Cust_City,'') AS 'Cust_City', ISNULL(TLA.Cust_State,'') AS 'Cust_State', ISNULL(TLA.Cust_Pincode,0) AS 'Cust_Pincode'
		, ISNULL(TLA.Cust_Mobile,0) AS 'Cust_Mobile', ISNULL(TLA.Cust_Email,'') AS 'Cust_Email', ISNULL(TLA.Cust_PANNO,'') AS 'Cust_PANNO'
		, ISNULL(TLA.BackOfficeCode,'') AS 'BackOfficeCode'
		, ISNULL(TLA.Lead_Type_ID,0) AS 'Lead_Type_ID', ISNULL(TLT.Lead_Type_Name,'') AS 'Lead_Type_Name'
		, ISNULL(TLA.Lead_Product_ID,0) AS 'Lead_Product_ID', ISNULL(TLP.Lead_Product_Name,'') AS 'Lead_Product_Name'
		, ISNULL(TLA.Visit_Type_ID,0) AS 'Visit_Type_ID',ISNULL(TVT.Visit_Type_Name,'') AS 'Visit_Type_Name'
		, ISNULL(TLA.Lead_Status_ID,0) AS 'Lead_Status_ID', ISNULL(TLS.Lead_Status_Name,'') AS 'Lead_Status_Name'
		, (CASE WHEN ISNULL(TLA.Visit_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Visit_Date,103) END) AS 'Visit_Date'
		, (CASE WHEN ISNULL(TLA.Follow_Up_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Follow_Up_Date,103) END) AS 'Follow_Up_Date'
		, ISNULL(TLA.Follow_Date_History,'') AS 'Follow_Date_History'
		, ISNULL(TLA.Remarks,'') AS 'Remarks', ISNULL(TLA.Collected_Amt,0) AS 'Collected_Amt'
		, CONVERT(VARCHAR(11),TLA.Modify_Date,103) AS 'Modify_Date', ISNULL(TLA.Modify_By,'') AS 'Modify_By'		
		, ISNULL(TLA.Assign_TO,0) AS 'Assign_TO', ISNULL(TLA.Reg_HeadID,0) AS 'Reg_HeadID'
		, (CASE WHEN ISNULL(TLA.Assign_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Assign_Date,103) END) AS 'Assign_Date'

	FROM T0501_Lead_Application TLA WITH (NOLOCK)
	LEFT JOIN T0500_Lead_Type TLT WITH (NOLOCK) ON TLA.Lead_Type_ID = TLT.Lead_Type_ID
	LEFT JOIN T0500_Lead_Product TLP WITH (NOLOCK) ON TLA.Lead_Product_ID = TLP.Lead_Product_ID
	LEFT JOIN T0500_Lead_Visit_Type TVT WITH (NOLOCK) ON TLA.Visit_Type_ID = TVT.Visit_Type_ID
	LEFT JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
	LEFT JOIN T0080_EMP_MASTER TEM WITH (NOLOCK) ON TLA.Emp_ID = TEM.Emp_ID




