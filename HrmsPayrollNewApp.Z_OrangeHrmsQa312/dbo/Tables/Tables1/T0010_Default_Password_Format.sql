CREATE TABLE [dbo].[T0010_Default_Password_Format] (
    [Tran_ID]       NUMERIC (18)   NOT NULL,
    [Cmp_ID]        NUMERIC (18)   NULL,
    [EffectiveDate] DATETIME       NULL,
    [Pwd_Type]      VARCHAR (15)   NULL,
    [Pwd_Format]    VARCHAR (1000) NULL,
    [UserID]        NUMERIC (18)   NULL,
    [SysDate]       DATETIME       NULL,
    [IP_Address]    VARCHAR (50)   NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

