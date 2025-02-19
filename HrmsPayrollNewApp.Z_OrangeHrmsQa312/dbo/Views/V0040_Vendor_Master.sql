



CREATE VIEW [dbo].[V0040_Vendor_Master]
AS
SELECT    Vendor_Id, Vendor_Name,Address,City, Contact_Person,Contact_Number,Cmp_Id
FROM         dbo.T0040_Vendor_Master WITH (NOLOCK)


