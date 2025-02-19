CREATE TABLE [dbo].[T0080_Emp_Auth_Master] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [EmpId]         INT            NULL,
    [CmpId]         INT            NULL,
    [LoginName]     NVARCHAR (MAX) NULL,
    [AuthType]      NVARCHAR (MAX) NULL,
    [SecurityStamp] NVARCHAR (MAX) NULL,
    [RecoveryCodes] NVARCHAR (MAX) NULL,
    [Is_Enable]     BIT            NULL,
    [CreatedDate]   DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

