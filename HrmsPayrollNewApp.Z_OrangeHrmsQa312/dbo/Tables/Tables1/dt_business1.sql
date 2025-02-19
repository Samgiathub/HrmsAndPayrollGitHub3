CREATE TABLE [dbo].[dt_business1] (
    [dt_Dept_id]    NUMERIC (18)  NULL,
    [dt_Segment_id] NUMERIC (18)  NULL,
    [dt_Shift_id]   NUMERIC (18)  NULL,
    [Total]         NUMERIC (18)  NOT NULL,
    [Total_Present] NUMERIC (18)  NOT NULL,
    [Total_Leave]   NUMERIC (18)  NOT NULL,
    [Total_OD]      NUMERIC (18)  NOT NULL,
    [Total_Absent]  NUMERIC (18)  NOT NULL,
    [Total_Weekoff] NUMERIC (18)  NOT NULL,
    [Dept_Name]     VARCHAR (100) NOT NULL,
    [SEGMENT_NAME]  VARCHAR (100) NULL,
    [Cmp_Name]      VARCHAR (100) NOT NULL,
    [Cmp_Address]   VARCHAR (250) NOT NULL,
    [From_Date]     DATETIME      NULL,
    [Shift_Name]    VARCHAR (100) NOT NULL
);

