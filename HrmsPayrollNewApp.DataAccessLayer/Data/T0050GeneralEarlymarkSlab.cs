using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050GeneralEarlymarkSlab
{
    public decimal TransId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? FromMin { get; set; }

    public decimal? ToMin { get; set; }

    public decimal? Deduction { get; set; }

    public string? DeductionType { get; set; }

    public decimal? GenId { get; set; }
}
