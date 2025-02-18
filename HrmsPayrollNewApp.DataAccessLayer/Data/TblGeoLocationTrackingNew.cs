using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TblGeoLocationTrackingNew
{
    public int Id { get; set; }

    public int EmpId { get; set; }

    public int CmpId { get; set; }

    public double? Latitude { get; set; }

    public double? Longitude { get; set; }

    public DateTime? Date { get; set; }

    public string? AddressLocation { get; set; }

    public decimal? Timestamp { get; set; }
}
