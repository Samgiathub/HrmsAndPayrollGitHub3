using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0160LateEarlyValidation
{
    public decimal TransId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? SalTranId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? SalMonth { get; set; }

    public decimal? SalYear { get; set; }

    public decimal? LateSec { get; set; }

    public decimal? EarlySec { get; set; }

    public decimal? LateDeduction { get; set; }

    public decimal? EarlyDeduction { get; set; }

    public bool? FlagNoExepmtion { get; set; }
}
