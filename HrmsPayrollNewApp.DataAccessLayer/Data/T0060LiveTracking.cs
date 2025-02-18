using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0060LiveTracking
{
    public decimal LtId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string? OriginLocation { get; set; }

    public string? DestinationLocation { get; set; }

    public decimal? DistanceKm { get; set; }

    public DateTime? CreatedDate { get; set; }
}
