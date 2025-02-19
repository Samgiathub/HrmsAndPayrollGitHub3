CREATE TABLE [dbo].[T0040_Role_Master] (
    [Role_ID]     NUMERIC (18)  NOT NULL,
    [Cmp_ID]      NUMERIC (18)  NULL,
    [Role_Name]   VARCHAR (100) NULL,
    [Modify_Date] DATETIME      NULL,
    [Modify_By]   NUMERIC (18)  NULL,
    [Ip_Address]  VARCHAR (20)  NULL,
    PRIMARY KEY CLUSTERED ([Role_ID] ASC)
);

