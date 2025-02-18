using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040IncomeTaxSetting
{
    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal RowId { get; set; }

    public decimal FromLimit { get; set; }

    public decimal ToLimit { get; set; }

    public decimal? Percentage { get; set; }

    public string Flag { get; set; } = null!;
}
