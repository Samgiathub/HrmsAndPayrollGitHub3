CREATE TABLE [dbo].[T9999_AUDIT_TRAIL_EMP_GEO_LOCATION_ASSIGN] (
    [Audit_Trail_ID]             NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Emp_Geo_Location_ID]        NUMERIC (18) NULL,
    [Emp_Geo_Location_Detail_ID] NUMERIC (18) NULL,
    [Emp_ID]                     NUMERIC (18) NULL,
    [Geo_Location_ID]            NUMERIC (18) NULL,
    [Meter]                      INT          NULL,
    [Cmp_ID]                     NUMERIC (18) NULL,
    [Effective_Date]             DATETIME     NULL,
    [Login_ID]                   NUMERIC (18) NULL,
    [System_Date]                DATETIME     NULL,
    CONSTRAINT [PK_T9999_AUDIT_TRAIL_EMP_GEO_LOCATION_ASSIGN] PRIMARY KEY CLUSTERED ([Audit_Trail_ID] ASC)
);

