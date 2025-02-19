CREATE TABLE [dbo].[T0250_Password_Format_Setting] (
    [Pwd_ID]    INT           NOT NULL,
    [Cmp_ID]    INT           CONSTRAINT [DF_T0250_Password_Format_Setting_Cmp_ID] DEFAULT ((0)) NULL,
    [Name]      NVARCHAR (50) NULL,
    [Format_ID] NVARCHAR (50) NULL
);

