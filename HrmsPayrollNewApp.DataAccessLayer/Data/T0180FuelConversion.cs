using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0180FuelConversion
{
    public int FuelId { get; set; }

    public int? CmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public string? FuelRate { get; set; }

    public string? FuelType { get; set; }
}
