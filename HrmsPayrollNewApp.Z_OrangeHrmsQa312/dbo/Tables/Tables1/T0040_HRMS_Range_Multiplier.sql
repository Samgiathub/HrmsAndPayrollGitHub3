CREATE TABLE [dbo].[T0040_HRMS_Range_Multiplier] (
    [Mul_Range_ID]       NUMERIC (18)    NOT NULL,
    [Cmp_ID]             NUMERIC (18)    NULL,
    [Mul_Range_From]     NUMERIC (18, 2) NULL,
    [Mul_Range_To]       NUMERIC (18, 2) NULL,
    [Mul_Range_Slab]     NUMERIC (18, 2) NULL,
    [Mul_Effective_Date] DATETIME        NULL,
    [Modify_by]          NUMERIC (18)    NULL,
    [Modify_date]        DATETIME        NULL,
    [Ip_Address]         VARCHAR (20)    NULL,
    PRIMARY KEY CLUSTERED ([Mul_Range_ID] ASC)
);

