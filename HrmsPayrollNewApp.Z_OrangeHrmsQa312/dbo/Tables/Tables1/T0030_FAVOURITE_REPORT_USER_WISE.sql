CREATE TABLE [dbo].[T0030_FAVOURITE_REPORT_USER_WISE] (
    [Report_Fav_ID] NUMERIC (18)   NOT NULL,
    [Cmp_ID]        NUMERIC (18)   NULL,
    [Emp_ID]        NUMERIC (18)   NULL,
    [Login_ID]      NUMERIC (18)   NULL,
    [Report_Name]   VARCHAR (200)  NULL,
    [Report_Url]    VARCHAR (1000) NULL,
    [Report_Title]  VARCHAR (200)  NULL,
    [Report_Group]  VARCHAR (200)  NULL,
    [Ess_Report]    BIT            DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Report_Fav_ID] ASC)
);

