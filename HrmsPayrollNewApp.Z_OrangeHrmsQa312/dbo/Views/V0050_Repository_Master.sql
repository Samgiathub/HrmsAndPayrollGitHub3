



--CREATE VIEW [dbo].[V0050_Repository_Master]  
--AS
--SELECT 
--    r.Repository_ID,
--	r.Repository_Name,
--    r.Cmp_ID,
--    r.Branch_ID,
--	b.Branch_Name,
--    c.Compliance_ID,
--	c.Compliance_Name,
--    r.Month,
--    r.YEAR,
--      CONVERT(date, r.Submission_Date) AS Submission_Date,  -- Only date part
--    r.Remark,
--    r.Attachment_path
--FROM 
--    dbo.T0050_Repository_Master r
--Left JOIN 
--    dbo.T0030_BRANCH_MASTER b ON r.Branch_ID = b.Branch_ID
--Left JOIN 
--    dbo.T0050_COMPLIANCE_MASTER c ON r.Compliance_ID = c.Compliance_ID;
--GO
CREATE VIEW [dbo].[V0050_Repository_Master]
AS
SELECT 
    r.Repository_ID,
    r.Repository_Name,
    r.Cmp_ID,
    r.Branch_ID,
    -- Similar logic as the PRIVILEGE query to format Branch_Name
    CASE 
        WHEN r.Branch_ID IS NOT NULL 
        THEN (
            SELECT 
                b.Branch_Name + ', ' 
            FROM 
                T0030_BRANCH_MASTER b 
            WHERE 
                b.Branch_ID IN (
                    SELECT CAST(data AS INT)
                    FROM dbo.Split(ISNULL(r.Branch_ID, '0'), ',')  -- Assuming ',' is the separator
                )
            FOR XML PATH('')
        )
        ELSE 'ALL' 
    END AS Branch_Name,
    r.Compliance_ID,
    c.Compliance_Name,
    r.Month,
    r.YEAR,
    r.Submission_Date,
    r.Remark,
    r.Attachment_path
FROM 
    dbo.T0050_Repository_Master r
LEFT JOIN 
    dbo.T0030_BRANCH_MASTER b ON r.Branch_ID = b.Branch_ID
LEFT JOIN 
    dbo.T0050_COMPLIANCE_MASTER c ON r.Compliance_ID = c.Compliance_ID
