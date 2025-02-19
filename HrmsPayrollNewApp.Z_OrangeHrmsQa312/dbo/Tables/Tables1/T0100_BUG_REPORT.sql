CREATE TABLE [dbo].[T0100_BUG_REPORT] (
    [Bug_ID]           NUMERIC (18)   NOT NULL,
    [Bug_Code]         VARCHAR (30)   NOT NULL,
    [Bug_Type]         VARCHAR (20)   NOT NULL,
    [Bug_Description]  VARCHAR (6000) NOT NULL,
    [Bug_Shanp_Short]  VARCHAR (50)   NOT NULL,
    [Bug_Severity]     VARCHAR (10)   NOT NULL,
    [Bug_Priority]     VARCHAR (10)   NOT NULL,
    [Bug_Reported_By]  VARCHAR (100)  NOT NULL,
    [Bug_Reported_On]  DATETIME       NOT NULL,
    [Bug_Assigned_On]  VARCHAR (50)   NOT NULL,
    [Bug_Exp_Fix_Date] DATETIME       NULL,
    [Bug_Fixed_By]     VARCHAR (100)  NOT NULL,
    [Bug_Fixed_On]     DATETIME       NULL,
    [Bug_Status]       VARCHAR (20)   NOT NULL,
    [Bug_Comment]      VARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_T0100_BUG_REPORT] PRIMARY KEY CLUSTERED ([Bug_ID] ASC) WITH (FILLFACTOR = 80)
);

