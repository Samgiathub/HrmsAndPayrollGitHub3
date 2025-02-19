CREATE TABLE [dbo].[T0095_Ticket_Escalation] (
    [Tran_ID]       NUMERIC (18)  NOT NULL,
    [Ticket_App_ID] NUMERIC (18)  NULL,
    [Emp_ID]        NUMERIC (18)  NULL,
    [Gen_Date]      DATETIME      NULL,
    [Email_ID]      VARCHAR (100) NULL,
    [Ticket_Level]  NUMERIC (18)  NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

