CREATE TABLE [dbo].[T0095_EMP_GEO_LOCATION_ASSIGN] (
    [Emp_Geo_Location_ID] NUMERIC (18) NOT NULL,
    [Emp_ID]              NUMERIC (18) NULL,
    [Cmp_ID]              NUMERIC (18) NULL,
    [Effective_Date]      DATETIME     NULL,
    [Login_ID]            NUMERIC (18) NULL,
    [System_Date]         DATETIME     NULL,
    CONSTRAINT [PK_T0095_EMP_GEO_LOCATION_ASSIGN] PRIMARY KEY CLUSTERED ([Emp_Geo_Location_ID] ASC)
);

