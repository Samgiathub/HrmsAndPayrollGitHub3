CREATE TABLE [dbo].[T0250_Form16_Publish_ESS] (
    [Publish_Id]     NUMERIC (18)  NOT NULL,
    [Cmp_Id]         NUMERIC (18)  NOT NULL,
    [Emp_Id]         NUMERIC (18)  NOT NULL,
    [Financial_Year] VARCHAR (10)  NOT NULL,
    [Is_Publish]     TINYINT       NOT NULL,
    [System_Date]    DATETIME      NOT NULL,
    [Comments]       VARCHAR (500) NULL,
    CONSTRAINT [PK_T0250_Form16_Publish_ESS] PRIMARY KEY CLUSTERED ([Publish_Id] ASC)
);

