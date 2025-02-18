using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055IncentiveSchemeInc
{
    public decimal SchemeId { get; set; }

    public decimal RowId { get; set; }

    public decimal IncTranId { get; set; }

    public string IncentiveName { get; set; } = null!;

    public byte SlabType { get; set; }

    public string CalcType { get; set; } = null!;

    public string CalcOn { get; set; } = null!;

    public decimal FromSlab { get; set; }

    public decimal ToSlab { get; set; }

    public decimal SlabValue { get; set; }

    public string? ConsiderPara { get; set; }

    public string? IncentiveFor { get; set; }
}
