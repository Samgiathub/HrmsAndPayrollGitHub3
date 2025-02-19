CREATE TABLE [dbo].[T0080_Get_EMP_Data_join_left_For_Logs] (
    [Id]        INT           IDENTITY (1, 1) NOT NULL,
    [URL]       VARCHAR (MAX) NULL,
    [Object]    NUMERIC (18)  NULL,
    [Response]  VARCHAR (MAX) NULL,
    [Body]      VARCHAR (MAX) NULL,
    [Timestamp] DATETIME      NULL,
    CONSTRAINT [PK_T0080_Get_EMP_Data_join_left_For__Logs] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

