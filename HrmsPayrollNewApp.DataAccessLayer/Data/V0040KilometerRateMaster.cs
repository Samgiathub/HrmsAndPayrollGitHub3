using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040KilometerRateMaster
{
    public decimal KrId { get; set; }

    public decimal? CmpId { get; set; }

    public string? EffectiveDate { get; set; }

    public string EmpCategory { get; set; } = null!;

    public string VehicleType { get; set; } = null!;

    public decimal RatePerKm { get; set; }

    public int? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }
}
