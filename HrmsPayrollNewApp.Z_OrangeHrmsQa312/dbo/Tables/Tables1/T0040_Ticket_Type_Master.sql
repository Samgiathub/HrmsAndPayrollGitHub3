CREATE TABLE [dbo].[T0040_Ticket_Type_Master] (
    [Ticket_Type_ID]   NUMERIC (18)  NOT NULL,
    [Cmp_ID]           NUMERIC (18)  NULL,
    [Ticket_Type]      VARCHAR (500) NULL,
    [Ticket_Dept_ID]   NUMERIC (18)  NULL,
    [Ticket_Dept_Name] VARCHAR (50)  NULL,
    [Sys_Datetime]     DATETIME      NULL,
    [User_ID]          NUMERIC (18)  NULL,
    PRIMARY KEY CLUSTERED ([Ticket_Type_ID] ASC)
);

