using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040IncentiveMaster
{
    public decimal IncTranId { get; set; }

    public decimal CmpId { get; set; }

    public string IncentiveName { get; set; } = null!;

    public byte SlabType { get; set; }

    public string CalcType { get; set; } = null!;

    public string? CalcOn { get; set; }

    public string? IncentiveFor { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }
}
