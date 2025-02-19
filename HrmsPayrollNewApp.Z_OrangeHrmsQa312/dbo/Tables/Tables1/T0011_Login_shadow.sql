CREATE TABLE [dbo].[T0011_Login_shadow] (
    [AuditId]         BIGINT        IDENTITY (1, 1) NOT NULL,
    [Login_ID]        NUMERIC (18)  NOT NULL,
    [Cmp_ID]          NUMERIC (18)  NOT NULL,
    [Login_Name]      VARCHAR (50)  NOT NULL,
    [Login_Password]  VARCHAR (50)  NOT NULL,
    [Emp_ID]          NUMERIC (18)  NULL,
    [Branch_ID]       NUMERIC (18)  NULL,
    [Login_Rights_ID] NUMERIC (18)  NULL,
    [Is_Default]      NUMERIC (1)   NULL,
    [AuditAction]     CHAR (1)      NOT NULL,
    [AuditDate]       DATETIME      CONSTRAINT [DF_T0011_Login_shadow_AuditDate] DEFAULT (getdate()) NOT NULL,
    [AuditUser]       VARCHAR (50)  CONSTRAINT [DF_T0011_Login_shadow_AuditUser] DEFAULT (suser_sname()) NOT NULL,
    [AuditApp]        VARCHAR (128) CONSTRAINT [DF_T0011_Login_shadow_AuditApp] DEFAULT (('App=('+rtrim(isnull(app_name(),'')))+') ') NULL,
    CONSTRAINT [PK_T0011_Login_shadow] PRIMARY KEY CLUSTERED ([AuditId] ASC) WITH (FILLFACTOR = 80)
);

