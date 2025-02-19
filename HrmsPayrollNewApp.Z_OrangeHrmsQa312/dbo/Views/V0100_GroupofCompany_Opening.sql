


CREATE VIEW [dbo].[V0100_GroupofCompany_Opening]
AS
SELECT     TOP (100) PERCENT co.Cmp_Id, co.Cmp_Name, co.Cmp_Address + ',' + co.Cmp_City + ',' + lm.Loc_name + ',' + co.Cmp_PinCode AS cmp_address, co.Image_name, 
                      co.is_Main, ISNULL(p.cnt, 0) AS No_of_Position
FROM         dbo.T0010_COMPANY_MASTER AS co WITH (NOLOCK) INNER JOIN
                      dbo.T0001_LOCATION_MASTER AS lm WITH (NOLOCK)  ON co.Loc_ID = lm.Loc_ID LEFT OUTER JOIN
                          (SELECT     ISNULL(COUNT(Rec_Post_Id), 0) AS cnt, Cmp_id
                            FROM          dbo.V0052_HRMS_Recruitement_Posted WITH (NOLOCK) 
                            WHERE      (Rec_Start_date <= GETDATE()) AND (Rec_End_date >= GETDATE()) AND (Posted_status = 1)
                            GROUP BY Cmp_id) AS p ON p.Cmp_id = co.Cmp_Id
WHERE     (co.is_GroupOFCmp = 1) AND (p.cnt <> 0)
ORDER BY co.is_Main DESC

