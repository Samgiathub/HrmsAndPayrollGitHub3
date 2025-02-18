using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class PresentDataEioDiff
{
    public decimal? EmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public DateTime? OutTime { get; set; }

    public DateTime? InTime { get; set; }

    public decimal? DiffSec { get; set; }
}
