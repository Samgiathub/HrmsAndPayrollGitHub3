CREATE TABLE [dbo].[T0110_LoginDetails_LOG] (
    [ID]           NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]       NUMERIC (18)   NOT NULL,
    [User_ID]      VARCHAR (50)   NOT NULL,
    [IPAddress]    NVARCHAR (100) NOT NULL,
    [Datetime]     DATETIME       NOT NULL,
    [Is_Logged_in] TINYINT        NULL,
    [Logout_Date]  DATETIME       NULL,
    CONSTRAINT [PK_T0110_LoginDetails_LOG] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95)
);

