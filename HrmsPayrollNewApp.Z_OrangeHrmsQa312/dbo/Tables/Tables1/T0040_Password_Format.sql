CREATE TABLE [dbo].[T0040_Password_Format] (
    [Pwd_Frmt_ID] INT            NOT NULL,
    [cmp_ID]      INT            CONSTRAINT [DF_T0040_Password_Format_cmp_ID] DEFAULT ((0)) NULL,
    [Name]        NVARCHAR (MAX) NULL,
    [Format]      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0040_Password_Format] PRIMARY KEY CLUSTERED ([Pwd_Frmt_ID] ASC) WITH (FILLFACTOR = 80)
);

