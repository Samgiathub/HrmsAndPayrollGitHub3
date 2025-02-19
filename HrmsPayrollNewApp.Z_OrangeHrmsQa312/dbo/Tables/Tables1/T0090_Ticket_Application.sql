CREATE TABLE [dbo].[T0090_Ticket_Application] (
    [Ticket_App_ID]      NUMERIC (18)    NOT NULL,
    [Cmp_ID]             NUMERIC (18)    NULL,
    [Emp_ID]             NUMERIC (18)    NULL,
    [Ticket_Type_ID]     NUMERIC (18)    NULL,
    [Ticket_Gen_Date]    DATETIME        NULL,
    [Ticket_Dept_ID]     NUMERIC (5)     NULL,
    [Ticket_Priority]    VARCHAR (50)    NULL,
    [Ticket_Attachment]  VARCHAR (500)   NULL,
    [Ticket_Description] VARCHAR (500)   NULL,
    [Ticket_Status]      CHAR (1)        NULL,
    [Sys_Datetime]       DATETIME        NULL,
    [User_ID]            NUMERIC (18)    NULL,
    [Is_Escalation]      TINYINT         DEFAULT ((0)) NOT NULL,
    [Is_Candidate]       TINYINT         CONSTRAINT [DF_T0090_Ticket_Application_Is_Candidate] DEFAULT ((0)) NULL,
    [Escalation_Hours]   NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [SendTo]             NUMERIC (18)    NULL,
    PRIMARY KEY CLUSTERED ([Ticket_App_ID] ASC)
);

