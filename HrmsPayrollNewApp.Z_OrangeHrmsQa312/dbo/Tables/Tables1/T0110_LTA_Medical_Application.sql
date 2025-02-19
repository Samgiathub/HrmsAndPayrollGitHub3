CREATE TABLE [dbo].[T0110_LTA_Medical_Application] (
    [LM_App_ID]       NUMERIC (18)    NOT NULL,
    [Cmp_ID]          NUMERIC (18)    NOT NULL,
    [Emp_ID]          NUMERIC (18)    NOT NULL,
    [APP_Date]        DATETIME        NULL,
    [APP_Code]        VARCHAR (20)    NULL,
    [APP_Amount]      NUMERIC (18, 2) NULL,
    [APP_Comments]    VARCHAR (250)   NULL,
    [File_Name]       VARCHAR (50)    NULL,
    [File_Name1]      VARCHAR (50)    NULL,
    [System_Date]     DATETIME        NULL,
    [APP_Status]      INT             NOT NULL,
    [Leave_From_Date] DATETIME        NULL,
    [Leave_to_Date]   DATETIME        NULL,
    [no_of_Days]      INT             NULL,
    [Type_ID]         INT             NULL,
    CONSTRAINT [PK_T00110_LTA_Medical_Application] PRIMARY KEY CLUSTERED ([LM_App_ID] ASC) WITH (FILLFACTOR = 80)
);

