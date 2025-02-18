using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TblGeoLocationTracking
{
    public int Id { get; set; }

    public int EmpId { get; set; }

    public int CmpId { get; set; }

    public double? Latitude { get; set; }

    public double? Longitude { get; set; }

    public DateTime? TrackingDate { get; set; }

    public string? AddressLocation { get; set; }

    public string? City { get; set; }

    public string? Area { get; set; }

    public string? BatteryLevel { get; set; }

    public string? ImeiNo { get; set; }

    public double? GpsAccuracy { get; set; }

    public string? ModelName { get; set; }

    public string? GpsAccuracyString { get; set; }
}
