CREATE TABLE [dbo].[T0040_Client_Master] (
    [Client_ID]      NUMERIC (18)  NOT NULL,
    [Client_Name]    VARCHAR (50)  NULL,
    [Client_Address] VARCHAR (MAX) NULL,
    [Contact_Person] VARCHAR (50)  NULL,
    [Phone_No]       VARCHAR (50)  NULL,
    [Mobile_No]      VARCHAR (50)  NULL,
    [Email]          VARCHAR (50)  NULL,
    [Cmp_ID]         NUMERIC (18)  NULL,
    [Created_By]     NUMERIC (18)  NULL,
    [Created_Date]   DATETIME      NULL,
    [Modify_By]      NUMERIC (18)  NULL,
    [Modify_Date]    DATETIME      NULL,
    CONSTRAINT [PK_T0040_Client_Master] PRIMARY KEY CLUSTERED ([Client_ID] ASC) WITH (FILLFACTOR = 80)
);

