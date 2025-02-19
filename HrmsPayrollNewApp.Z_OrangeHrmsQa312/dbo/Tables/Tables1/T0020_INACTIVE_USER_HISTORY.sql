CREATE TABLE [dbo].[T0020_INACTIVE_USER_HISTORY] (
    [History_Id]    NUMERIC (18)   NOT NULL,
    [Cmp_Id]        NUMERIC (18)   NOT NULL,
    [Emp_Id]        NUMERIC (18)   NOT NULL,
    [Login_Id]      NUMERIC (18)   NOT NULL,
    [Reason]        NVARCHAR (200) NULL,
    [System_Date]   DATETIME       NOT NULL,
    [Active_Status] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_T0020_INACTIVE_USER_HISTORY] PRIMARY KEY CLUSTERED ([History_Id] ASC) WITH (FILLFACTOR = 80)
);

