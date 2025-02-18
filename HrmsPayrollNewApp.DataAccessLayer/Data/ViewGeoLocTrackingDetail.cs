using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewGeoLocTrackingDetail
{
    public int EmpId { get; set; }

    public int CmpId { get; set; }

    public DateTime? Date { get; set; }

    public double? Latitude { get; set; }

    public double? Longitude { get; set; }

    public string? Location { get; set; }
}
