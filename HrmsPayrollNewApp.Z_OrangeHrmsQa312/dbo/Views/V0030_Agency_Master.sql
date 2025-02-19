





CREATE VIEW [dbo].[V0030_Agency_Master]
AS
SELECT     dbo.T0020_STATE_MASTER.State_Name, dbo.T0030_AGENCY_MASTER.Agency_ID, dbo.T0030_AGENCY_MASTER.State_ID, 
                      dbo.T0030_AGENCY_MASTER.Agency_Name, dbo.T0030_AGENCY_MASTER.Agency_City, dbo.T0030_AGENCY_MASTER.Agency_Address, 
                      dbo.T0030_AGENCY_MASTER.Agency_phone, dbo.T0030_AGENCY_MASTER.Agency_mobile, dbo.T0030_AGENCY_MASTER.Comment, 
                      dbo.T0030_AGENCY_MASTER.Cmp_ID
FROM         dbo.T0020_STATE_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0030_AGENCY_MASTER WITH (NOLOCK)  ON dbo.T0020_STATE_MASTER.State_ID = dbo.T0030_AGENCY_MASTER.State_ID




