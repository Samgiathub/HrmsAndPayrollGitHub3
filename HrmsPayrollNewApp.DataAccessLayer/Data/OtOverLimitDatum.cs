using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class OtOverLimitDatum
{
    public string? EmpFullName { get; set; }

    public string? Period { get; set; }

    public decimal? TotQtHoursLimit { get; set; }

    public decimal? QtrOtApprovedHrs { get; set; }

    public decimal? QtrOtHrsAvailable { get; set; }
}
