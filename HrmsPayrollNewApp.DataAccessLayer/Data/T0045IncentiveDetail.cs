using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0045IncentiveDetail
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal IncTranId { get; set; }

    public decimal? FromSlab { get; set; }

    public decimal? ToSlab { get; set; }

    public decimal? SlabValue { get; set; }

    public string? IncentiveName { get; set; }

    public byte? SlabType { get; set; }

    public string? CalcType { get; set; }

    public string? CalcOn { get; set; }

    public string? IncentiveFor { get; set; }

    public virtual T0040IncentiveMaster IncTran { get; set; } = null!;
}
