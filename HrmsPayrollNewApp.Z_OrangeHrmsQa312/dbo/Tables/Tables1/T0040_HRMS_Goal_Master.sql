CREATE TABLE [dbo].[T0040_HRMS_Goal_Master] (
    [Goal_id]     NUMERIC (18)   NOT NULL,
    [Goal_Title]  NVARCHAR (100) NULL,
    [cmp_id]      NUMERIC (18)   NULL,
    [Login_id]    NUMERIC (18)   NULL,
    [Description] NVARCHAR (500) NULL,
    [Start_Date]  DATETIME       NULL,
    [End_Date]    DATETIME       NULL,
    [for_date]    DATETIME       NULL,
    CONSTRAINT [PK_T0040_HRMS_Goal_Master] PRIMARY KEY CLUSTERED ([Goal_id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_HRMS_Goal_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_HRMS_Goal_Master_T0011_LOGIN] FOREIGN KEY ([Login_id]) REFERENCES [dbo].[T0011_LOGIN] ([Login_ID])
);

