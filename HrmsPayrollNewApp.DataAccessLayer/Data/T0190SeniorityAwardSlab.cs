using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0190SeniorityAwardSlab
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AdId { get; set; }

    public decimal? FromAge { get; set; }

    public decimal? ToAge { get; set; }

    public string? Mode { get; set; }

    public decimal? Amount { get; set; }

    public string? Remarks { get; set; }
}
