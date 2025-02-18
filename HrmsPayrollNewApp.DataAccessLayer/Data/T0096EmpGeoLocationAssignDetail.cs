using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0096EmpGeoLocationAssignDetail
{
    public decimal EmpGeoLocationDetailId { get; set; }

    public decimal? EmpGeoLocationId { get; set; }

    public decimal? GeoLocationId { get; set; }

    public int? Meter { get; set; }
}
