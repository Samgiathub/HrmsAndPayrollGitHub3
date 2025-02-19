CREATE TABLE [dbo].[T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL] (
    [Emp_Geo_Location_Detail_ID] NUMERIC (18) NOT NULL,
    [Emp_Geo_Location_ID]        NUMERIC (18) NULL,
    [Geo_Location_ID]            NUMERIC (18) NULL,
    [Meter]                      INT          NULL,
    CONSTRAINT [PK_T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL] PRIMARY KEY CLUSTERED ([Emp_Geo_Location_Detail_ID] ASC)
);

