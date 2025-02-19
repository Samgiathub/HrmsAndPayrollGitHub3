CREATE TABLE [dbo].[T0250_Payment_PUBLISH_ESS] (
    [Publish_ID]      NUMERIC (18)  NOT NULL,
    [Cmp_ID]          NUMERIC (18)  NOT NULL,
    [Branch_ID]       NUMERIC (18)  NULL,
    [Month]           NUMERIC (5)   NOT NULL,
    [Year]            NUMERIC (5)   NULL,
    [Is_Publish]      NUMERIC (1)   NOT NULL,
    [User_ID]         NUMERIC (18)  NOT NULL,
    [System_Date]     DATETIME      NOT NULL,
    [Emp_ID]          NUMERIC (18)  NOT NULL,
    [Comments]        VARCHAR (MAX) NULL,
    [Ad_id]           NUMERIC (12)  NOT NULL,
    [Process_Type]    VARCHAR (100) NOT NULL,
    [process_type_id] VARCHAR (100) NOT NULL
);

