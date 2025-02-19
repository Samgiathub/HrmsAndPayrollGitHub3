CREATE TABLE [dbo].[T0001_LOGIN_TYPE] (
    [Login_Type_ID] NUMERIC (18) NOT NULL,
    [Login_Type]    VARCHAR (50) NOT NULL,
    [Is_Save]       NUMERIC (1)  NOT NULL,
    [Is_Edit]       NUMERIC (1)  NOT NULL,
    [Is_Delete]     NUMERIC (1)  NOT NULL,
    [Is_Report]     NUMERIC (1)  NOT NULL,
    CONSTRAINT [PK_T0001_LOGIN_TYPE] PRIMARY KEY CLUSTERED ([Login_Type_ID] ASC) WITH (FILLFACTOR = 80)
);

