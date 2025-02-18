using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040GeoLocationMaster
{
    public decimal GeoLocationId { get; set; }

    public decimal? CmpId { get; set; }

    public string? GeoLocation { get; set; }

    public string? Latitude { get; set; }

    public string? Longitude { get; set; }

    public int? Meter { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }
}
