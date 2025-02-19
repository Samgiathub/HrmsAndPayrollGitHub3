CREATE TABLE [dbo].[T0040_Vendor_Master] (
    [Vendor_Id]      NUMERIC (18)   NOT NULL,
    [Vendor_Name]    VARCHAR (50)   NOT NULL,
    [Address]        VARCHAR (2000) NULL,
    [City]           VARCHAR (50)   NULL,
    [Contact_Person] VARCHAR (50)   NULL,
    [Contact_Number] VARCHAR (50)   NULL,
    [Cmp_Id]         NUMERIC (18)   NULL,
    [Branch_ID]      INT            NULL,
    CONSTRAINT [PK_T0040_Vendor_Master] PRIMARY KEY CLUSTERED ([Vendor_Id] ASC) WITH (FILLFACTOR = 80)
);

