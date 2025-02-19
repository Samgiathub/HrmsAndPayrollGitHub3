CREATE TABLE [dbo].[T0040_Ticket_Priority] (
    [Tran_ID]       NUMERIC (18)  NOT NULL,
    [Cmp_ID]        NUMERIC (18)  NULL,
    [Priority_Name] VARCHAR (500) NULL,
    [Hours_Limit]   VARCHAR (10)  NULL,
    [UserID]        NUMERIC (18)  NULL,
    [Modify_Date]   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

