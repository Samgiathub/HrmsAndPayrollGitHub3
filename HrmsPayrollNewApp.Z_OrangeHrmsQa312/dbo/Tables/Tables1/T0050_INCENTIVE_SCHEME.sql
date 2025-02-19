CREATE TABLE [dbo].[T0050_INCENTIVE_SCHEME] (
    [Scheme_ID]      NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]         NUMERIC (18)  NOT NULL,
    [Effective_Date] DATETIME      NOT NULL,
    [Login_ID]       NUMERIC (18)  NOT NULL,
    [System_Date]    DATETIME      NOT NULL,
    [Desig_ID]       VARCHAR (MAX) NULL,
    [Branch_ID]      VARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0050_SCHEME] PRIMARY KEY CLUSTERED ([Scheme_ID] ASC)
);

